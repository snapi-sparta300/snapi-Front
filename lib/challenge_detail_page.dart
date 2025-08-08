import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:three_thousand/picture_game.dart';
import 'package:three_thousand/verification_page.dart';
import 'app_constants.dart';

class ChallengeDetailPage extends StatefulWidget{
  @override
  _ChallengeDetailPageState createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  // 선택한 이미지를 저장할 변수
  File? _image;
  // ImagePicker 인스턴스 생성
  final ImagePicker _picker = ImagePicker();

  // 갤러리에서 사진 가져오기
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        _image = File(image.path);
      }
    });
  }

  // 카메라로 사진 찍기
  Future<void> _takePhotoWithCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    setState(() {
      if (image != null) {
        _image = File(image.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  '전동 킥보드 주차 사진 찍기',
                  style: TextStyle(fontSize: 16),
                ),
                background: Image.asset(
                  'assets/images/challenge_kickboard.png', // 실제 이미지 경로로 변경 필요
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey,
                    child: const Icon(Icons.image, size: 100, color: Colors.white),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '챌린지 설명',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '길거리에 주차된 전동 킥보드 사진을 찍어주세요. 더 나은 공유 모빌리티 문화를 만드는 데 기여할 수 있습니다.',
                      style: TextStyle(fontSize: 15, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    const Text(
                      '참여 가이드라인',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const ListTile(
                      leading: Icon(Icons.check_circle_outline, color: kPrimaryColor),
                      title: Text('킥보드 전체가 나오도록 촬영해주세요.'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.check_circle_outline, color: kPrimaryColor),
                      title: Text('번호판이 잘 보이도록 선명하게 찍어주세요.'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.privacy_tip_outlined, color: kSecondaryColor),
                      title: Text('개인정보(사람 얼굴, 차량 번호 등)는 AI가 자동으로 가려줍니다.'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PictureGamePage(),
                      ),
                    );
                  },
                  child: const Text('숨은 그림 찾기'),
                ),
              ),
              SizedBox(width: 20.0,),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async{
                    await _takePhotoWithCamera();
                    // image_picker 등을 이용한 카메라 실행 로직 추가
                    // 사진 촬영 후 VerificationPage로 이동
        
                    if(_image == null){
                      //사진 안찍음
                    }
                    else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => VerificationPage(file: _image!)),
                            (Route<dynamic> route) => false, // 이 부분이 모든 이전 페이지를 제거
                      );
                    }
                  },
                  child: const Text('사진 찍기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('총 보상', style: kSubBodyTextStyle),
              SizedBox(height: 4),
              Text('50,000 P', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            children: [
              Text('사진 1장당', style: kSubBodyTextStyle),
              SizedBox(height: 4),
              Text('100 P', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryColor)),
            ],
          ),
          Column(
            children: [
              Text('달성률', style: kSubBodyTextStyle),
              SizedBox(height: 4),
              Text('75%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}