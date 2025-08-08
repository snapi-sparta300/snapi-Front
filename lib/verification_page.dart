import 'dart:io';

import 'package:flutter/material.dart';
import 'app_constants.dart';

class VerificationPage extends StatefulWidget {
  // 테스트를 위해 성공/실패 여부를 외부에서 전달받도록 설정
  final File file;

  const VerificationPage({
    super.key,
    required this.file,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool _isVerifying = true;
  bool success = false;

  @override
  void initState() {
    super.initState();
    // AI 검증 과정을 시뮬레이션하기 위한 딜레이
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    });

    success = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 검증'),
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨김
      ),
      body: SafeArea(
        child: Center(
          child: _isVerifying
              ? const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('AI가 사진을 검증하고 있어요...', style: kBodyTextStyle),
            ],
          )
              : success
              ? _buildSuccessView(context)
              : _buildFailureView(context),
        ),
      ),
    );
  }

  // 검증 성공 화면
  Widget _buildSuccessView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: kSecondaryColor, size: 80),
          const SizedBox(height: 20),
          const Text('+100P 적립!', style: kHeadline1Style),
          const SizedBox(height: 12),
          const Text(
            'AI 검증이 통과되었습니다.\n감사합니다.',
            style: kSubBodyTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          // 제출된 사진 미리보기 (Placeholder)
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.file(
              widget.file, //조심
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover, // 이미지 크기에 맞춰 자르거나 늘립니다.
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context); // 챌린지 상세 페이지로 돌아가기
                  },
                  child: const Text('더 찍으러 가기'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                  },
                  child: const Text('메인으로'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 검증 실패 화면
  Widget _buildFailureView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cancel, color: Colors.red, size: 80),
          const SizedBox(height: 20),
          const Text('AI 검증 실패...', style: kHeadline1Style),
          const SizedBox(height: 12),
          const Text(
            '사진이 너무 흐릿해요.\n다시 찍어주세요.',
            style: kSubBodyTextStyle,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // 카메라(챌린지 상세)로 돌아가기
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.red,
            ),
            child: const Text('다시 찍기'),
          ),
        ],
      ),
    );
  }
}