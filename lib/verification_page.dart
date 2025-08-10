import 'dart:io';
import 'dart:math'; // 랜덤 결과를 위해 추가
import 'package:flutter/material.dart';
import 'app_constants.dart';

// 1. 검증 상태를 명확하게 정의하기 위한 enum
enum VerificationStatus {
  verifying,
  success,
  failureDuplicate,
  failureInvalid,
}

class VerificationPage extends StatefulWidget {
  final File file;

  const VerificationPage({
    super.key,
    required this.file,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  // 2. 상태 변수를 enum으로 변경
  VerificationStatus _status = VerificationStatus.verifying;

  @override
  void initState() {
    super.initState();
    _startVerification();
  }

  // AI 검증 시뮬레이션 로직
  Future<void> _startVerification() async {
    // 2초간 "검토 중" 상태를 표시
    await Future.delayed(const Duration(seconds: 2));

    // 실제 앱에서는 이 부분에 서버와 통신하는 API 호출 코드가 들어갑니다.
    // 지금은 결과를 랜덤으로 시뮬레이션합니다.
    final results = [
      VerificationStatus.success,
      VerificationStatus.failureDuplicate,
      VerificationStatus.failureInvalid,
    ];
    final randomResult = results[Random().nextInt(results.length)];

    if (mounted) {
      setState(() {
        _status = randomResult;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: _status != VerificationStatus.verifying,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: switch (_status) {
          VerificationStatus.verifying => _buildVerifyingView(),
          VerificationStatus.success => _buildSuccessView(),
          VerificationStatus.failureDuplicate => _buildFailureDuplicateView(),
          VerificationStatus.failureInvalid => _buildFailureInvalidView(),
        },
      ),
    );
  }

  // "검토 중" 화면
  Widget _buildVerifyingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 24),
        Text(
          '검증 AI가 사진을\n검토하고 있어요...',
          style: kHeadline2Style.copyWith(height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // "성공" 화면
  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🔥', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 24),
        const Text('+500P 수집!', style: kHeadline1Style),
        const SizedBox(height: 12),
        const Text('정확한 데이터 입니다!', style: kSubBodyTextStyle), // 스타일 수정
      ],
    );
  }

  // "실패 - 중복" 화면
  Widget _buildFailureDuplicateView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🤔', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 24),
        const Text('중복되는 사진 입니다', style: kHeadline2Style),
        const SizedBox(height: 12),
        const Text('다시 촬영 해주세요!', style: kSubBodyTextStyle), // 스타일 수정
      ],
    );
  }

  // "실패 - 부적절" 화면
  Widget _buildFailureInvalidView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('❌', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 24),
        const Text('올바른 사진이 아닙니다', style: kHeadline2Style),
        const SizedBox(height: 12),
        const Text('다시 촬영 해주세요!', style: kSubBodyTextStyle), // 스타일 수정
      ],
    );
  }
}