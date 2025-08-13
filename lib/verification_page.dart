import 'dart:convert';
import 'dart:io';
import 'dart:math'; // 랜덤 결과를 위해 추가
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_thousand/main_page.dart';
import 'app_constants.dart';

// 1. 검증 상태를 명확하게 정의하기 위한 enum
enum VerificationStatus {
  verifying,
  success,
  failureDuplicate,
  failureInvalid,
  already,
  guitar,
}

class VerificationPage extends StatefulWidget {
  final int challengeId;
  final int missionId;
  final int missionPoint;
  final File file;

  const VerificationPage({
    super.key,
    required this.challengeId,
    required this.missionId,
    required this.missionPoint,
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
    _one();
  }

  // AI 검증 시뮬레이션 로직
  Future<void> _one() async {
    final prefs = await SharedPreferences.getInstance();

    int? userId = await prefs.getInt("user_id");

    final uri = Uri.parse('$kApiBaseUrl/challenges/${widget.challengeId}/missions/${widget.missionId}/images?userId=$userId');

    final request = http.MultipartRequest('POST', uri);

    try {
      request.files.add(await http.MultipartFile.fromPath(
        // S3 업로드 API의 파일 키 이름이 'file'이라고 가정합니다.
        'file',
        widget.file.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ 미션 참여 성공!');
        print('서버 응답: ${response.body}');
        final rrr = jsonDecode(response.body);

        if(rrr['isSuccess'] == false) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(rrr['message'])));
          return;
        }

        final results = [
          VerificationStatus.success,
          VerificationStatus.failureDuplicate,
          VerificationStatus.failureInvalid,
        ];

        String sstatus = rrr['result']['status'];
        int sstatus_index = 2;
        if(sstatus == 'FAIL'){
          sstatus_index = 2;
        }
        else if(sstatus == 'PASS') {
          sstatus_index = 0;

          final step2Response = await http.post(
            Uri.parse('$kApiBaseUrl/challenges/${prefs.getInt("user_id")}/${widget.challengeId}'), // URL에 String으로 변환된 값 사용
            headers: {'Content-Type': 'application/json'},
          );
          // --- 수정된 부분 끝 ---

          if (step2Response.statusCode == 200 || step2Response.statusCode == 201) {
            final responseData2 = jsonDecode(step2Response.body);

            if(responseData2['isSuccess'] == false) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData2['message'])));
              return;
            }
          } else {
            final errorData = jsonDecode(step2Response.body);
            final errorMessage = "${errorData['message'] ?? '추가 정보 등록에 실패했습니다.'}";
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
          }

        }

        prefs.setInt("user_point", prefs.getInt("user_point")! + widget.missionPoint);

        final rrresult = results[sstatus_index];

        if (mounted) {
          setState(() {
            _status = rrresult;
          });
        }

        return;
      } else {
        print('❌ 미2션 참여 실패. 상태 코드: ${response.statusCode}');
        print('에러 응답: ${response.body}');

        if(response.statusCode == 409){
          final rrresult = VerificationStatus.already;

          if (mounted) {
            setState(() {
              _status = rrresult;
            });
          }

          return;
        }
        else {
          if (mounted) {
            setState(() {
              _status = VerificationStatus.guitar;
            });
          }

          return;
        }
      }
    } catch (e) {
      print('🚨 미션 참여 중 예외 발생: $e');

      if (mounted) {
        setState(() {
          _status = VerificationStatus.guitar;
        });
      }

      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: _status != VerificationStatus.verifying,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          // 아이콘은 원하는 것으로 변경 가능합니다.
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
                  (route) => false, // 이 조건이 false이므로 이전 모든 라우트를 제거합니다.
            );
          },
        ),
      ),
      body: Center(
        child: switch (_status) {
          VerificationStatus.verifying => _buildVerifyingView(),
          VerificationStatus.success => _buildSuccessView(widget.missionPoint),
          VerificationStatus.failureDuplicate => _buildFailureDuplicateView(),
          VerificationStatus.failureInvalid => _buildFailureInvalidView(),
          VerificationStatus.already => _buildAlreadyView(),
          VerificationStatus.guitar => _buildGuitarView(),
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
  Widget _buildSuccessView(int p) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🔥', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 24),
        Text('+${p}P 수집!', style: kHeadline1Style),
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

  Widget _buildAlreadyView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('😚', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 24),
        const Text('이미 참여한 미션입니다', style: kHeadline2Style),
        const SizedBox(height: 12),
        const Text('다른 미션에 참여해주세요!', style: kSubBodyTextStyle), // 스타일 수정
      ],
    );
  }

  Widget _buildGuitarView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('👾', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 24),
        const Text('예상치 못한 에러가 생겼습니다', style: kHeadline2Style),
        const SizedBox(height: 12),
        const Text('네트워크를 확인해주세요', style: kSubBodyTextStyle), // 스타일 수정
      ],
    );
  }
}