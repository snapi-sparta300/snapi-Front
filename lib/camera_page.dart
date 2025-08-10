import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'verification_page.dart'; // 검증 페이지

class CameraPage extends StatefulWidget {
  final String overlayImagePath; // 이전 페이지에서 전달받은 가이드라인 경로

  const CameraPage({super.key, required this.overlayImagePath});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first, // 첫 번째 카메라(보통 후면) 사용
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _cameraController.initialize();
    // 화면을 다시 그려서 카메라 미리보기를 표시
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    // 위젯이 종료될 때 컨트롤러를 반드시 해제
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      // 컨트롤러가 초기화될 때까지 대기
      await _initializeControllerFuture;

      // 사진 촬영
      final image = await _cameraController.takePicture();

      if (!mounted) return;

      // 촬영한 사진을 가지고 검증 페이지로 이동
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VerificationPage(
            file: File(image.path),
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Future가 완료되면, 미리보기와 오버레이를 Stack으로 표시
            return Stack(
              fit: StackFit.expand,
              children: [
                // 카메라 미리보기
                CameraPreview(_cameraController),
                // 가이드라인 오버레이 이미지
                Image.asset(
                  widget.overlayImagePath,
                  fit: BoxFit.contain, // 화면에 맞게 조절
                ),
                // 하단 촬영 버튼 영역
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 150,
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: IconButton(
                        onPressed: _takePicture,
                        icon: const Icon(Icons.camera, size: 70, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // 대기 중이면 로딩 인디케이터 표시
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}