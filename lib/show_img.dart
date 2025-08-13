import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:three_thousand/verification_page.dart';
// 이미지 처리 및 파일 경로를 위해 추가된 패키지
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ShowImgPage extends StatefulWidget {
  final int challengeId;
  final int missionId;
  final int missionPoint;
  final File file;

  const ShowImgPage({
    super.key,
    required this.challengeId,
    required this.missionId,
    required this.missionPoint,
    required this.file,
  });

  @override
  _ShowImgPageState createState() => _ShowImgPageState();
}

class _ShowImgPageState extends State<ShowImgPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: Image.file(
                widget.file,
                fit: BoxFit.cover,
              )
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
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VerificationPage(challengeId: widget.challengeId, missionId: widget.missionId, missionPoint: widget.missionPoint, file: widget.file)),
                    );
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 6),
                    ),
                    child: Center(
                      child: Text(
                        "확인",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white
                        ),
                      ),
                    )
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