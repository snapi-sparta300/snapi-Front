import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:three_thousand/verification_page.dart';
// 이미지 처리 및 파일 경로를 위해 추가된 패키지
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

List<CameraDescription> cameras = [];

Future<void> is_available_camera() async {
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    // 에러 발생 시 처리
    print('Error: $e.code\nError Message: $e.description');
  }
}

class CameraPage extends StatefulWidget {
  final String objectName;
  final int challengeId;

  const CameraPage({
    super.key,
    required this.objectName,
    required this.challengeId
  });


  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;

  CameraDescription? _backCamera;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // 후면 카메라를 찾는 함수
  void _findBackCamera() {
    // cameras 리스트에서 후면 카메라(CameraLensDirection.back)를 찾습니다.
    _backCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () {
        // 후면 카메라가 없으면 첫 번째 카메라를 반환 (최후의 수단)
        return cameras.first;
      },
    );
  }

  Future<void> _initializeCamera() async {
    await is_available_camera();

    if (cameras.isEmpty) {
      // 카메라가 없으면 아무것도 하지 않고 함수 종료
      return;
    }

    _findBackCamera();

    CameraDescription camera = _backCamera!;

    _cameraController = CameraController(
      camera,
      // 해상도 설정 (높은 해상도를 사용해야 고화질의 결과물을 얻을 수 있습니다)
      ResolutionPreset.high,
      enableAudio: false, // 오디오는 사용하지 않으므로 비활성화
    );

    // 카메라 초기화 작업을 수행하고, Future를 변수에 할당
    _initializeControllerFuture = _cameraController!.initialize();
    // initialize()가 완료되면 UI를 다시 빌드하도록 setState 호출
    _initializeControllerFuture!.then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // 사진 찍고 3:4 비율로 자르는 함수
  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final XFile file = await _cameraController!.takePicture();

      //--- 이미지 자르기 로직 시작 ---

      // 1. 촬영된 파일에서 이미지 데이터를 읽어옵니다.
      final Uint8List imageBytes = await file.readAsBytes();

      // 2. 'image' 패키지를 사용하여 이미지를 디코딩합니다.
      final img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        print('이미지 디코딩에 실패했습니다.');
        return;
      }

      // 3. 3:4 비율에 맞춰 자를 영역을 계산합니다.
      final int width = originalImage.width;
      final int height = originalImage.height;
      final double originalAspectRatio = width / height;
      const double targetAspectRatio = 3.0 / 4.0;

      int cropWidth;
      int cropHeight;
      int x, y;

      if (originalAspectRatio > targetAspectRatio) {
        // 이미지가 목표 비율보다 넓은 경우 (예: 16:9), 좌우를 자릅니다.
        cropHeight = height;
        cropWidth = (height * targetAspectRatio).round();
        x = ((width - cropWidth) / 2).round();
        y = 0;
      } else {
        // 이미지가 목표 비율보다 길거나 같은 경우 (예: 4:3), 위아래를 자릅니다.
        cropWidth = width;
        cropHeight = (width / targetAspectRatio).round();
        x = 0;
        y = ((height - cropHeight) / 2).round();
      }

      // 4. 계산된 영역으로 이미지를 자릅니다.
      final img.Image croppedImage = img.copyCrop(originalImage, x: x, y: y, width: cropWidth, height: cropHeight);

      // 5. 잘린 이미지를 JPEG 형식으로 다시 인코딩합니다.
      final List<int> croppedBytes = img.encodeJpg(croppedImage, quality: 95);

      // 6. 잘린 이미지를 저장할 새 파일 경로를 생성합니다.
      final String dir = (await getTemporaryDirectory()).path;
      final String newPath = '$dir/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File croppedFile = File(newPath);
      await croppedFile.writeAsBytes(croppedBytes);

      //--- 이미지 자르기 로직 끝 ---


      // 사진 자르기가 완료된 후 다음 화면으로 이동
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationPage(objectName: widget.objectName, file: croppedFile),
          ),
        );
      }
    } catch (e) {
      print('사진 촬영 또는 자르기 중 오류 발생: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose(); // null이 아닐 때만 dispose 호출
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameras.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('사용 가능한 카메라가 없습니다.'),
        ),
      );
    }

    if (_initializeControllerFuture == null || _cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. 카메라 미리보기
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 4 / 3,
              child: Stack(
                fit: StackFit.expand, // StackFit.expand를 사용하여 Stack이 SizedBox 크기를 채우도록 합니다.
                children: [
                  CameraPreview(_cameraController!),
                  Opacity(
                    opacity: 0.4,
                    child: Image.asset(
                      'assets/images/black.png',
                      fit: BoxFit.cover, // 이미지가 비율을 유지하며 가능한 크게 채우도록 설정합니다. 필요에 따라 다른 BoxFit 속성을 사용할 수 있습니다.
                    ),
                  ),
                  Image.asset(
                    'assets/images/guidelines/icon_${widget.objectName}_guideline.png',
                    fit: BoxFit.cover, // 이미지가 비율을 유지하며 가능한 크게 채우도록 설정합니다. 필요에 따라 다른 BoxFit 속성을 사용할 수 있습니다.
                  ),
                ],
              ),
            ),
          ),

          // 2. 하단 컨트롤 바
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.transparent, // 배경을 투명하게 설정
                padding: const EdgeInsets.all(24.0),
                child: GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 6),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}