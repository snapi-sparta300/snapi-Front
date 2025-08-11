import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app_constants.dart';
import 'camera_page.dart'; // 카메라 페이지

// 데이터 선택 옵션을 위한 모델
class ChallengeOption {
  final String id;
  final String title;
  final String description;
  final String points;
  final String iconPath;

  ChallengeOption({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.iconPath,
  });
}

class ChallengeDetailPage extends StatefulWidget {
  final int challengeId;

  const ChallengeDetailPage({
    super.key,
    required this.challengeId,
  });

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  String? _selectedOptionId;

  String? _name;
  String? _company_name;
  String? _comment;
  int? _total_mission;
  int? _max_count;
  int? _current_count;
  int? _total_point;

  // 아이콘 경로를 최종 파일 이름으로 수정
  final List<ChallengeOption> options = [
    ChallengeOption(
      id: 'palm',
      title: '손바닥',
      description: '손바닥 전체를 정면에서...',
      points: '200P',
      iconPath: 'assets/images/icon_palm.png', // [변경]
    ),
    ChallengeOption(
      id: 'v_sign',
      title: '브이',
      description: "손가락 '브이(V)' 모양, 손...",
      points: '250P',
      iconPath: 'assets/images/icon_v_sign.png', // [변경]
    ),
    ChallengeOption(
      id: 'cup',
      title: '컵을 잡은 손',
      description: '컵을 잡은 손, 컵 윗 부분...',
      points: '300P',
      iconPath: 'assets/images/icon_cup.png', // [변경]
    )
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // API 요청 2: 추가 정보 전송
    final step2Response = await http.get(
      Uri.parse('$kApiBaseUrl/challenges'),
      headers: {'Content-Type': 'application/json'},
    );

    if (step2Response.statusCode == 200 || step2Response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(step2Response.body);

      Map<String, dynamic> challenge = data['result']['challenges'].firstWhere(
            (_challenge) => _challenge['challengeId'] == widget.challengeId,
        orElse: () => {}, // 못 찾으면 빈 맵 반환
      );

      // 'challenges'가 리스트이므로 인덱스(challengeId)를 사용하여 접근합니다.
      final List<dynamic> challengesList = data['result']['challenges'];

      if (challenge != {}) {
        setState(() {
          _name = challenge['name'];
          _company_name = challenge['companyName'];
          _comment = challenge['comment'];
          _total_mission = challenge['totalMission'];
          _max_count = challenge['maxCount'];
          _current_count = challenge['currentCount'];
          _total_point = challenge['totalPoint'];
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('해당 챌린지를 찾을 수 없습니다.')),
          );
        }
      }
    } else {
      final errorData = jsonDecode(step2Response.body);
      final errorMessage = errorData['message'] ?? '챌린지 정보를 불러오는데 실패했습니다.';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = _selectedOptionId == null
        ? null
        : options.firstWhere((opt) => opt.id == _selectedOptionId);
    const primaryColor = Color(0xFF6A0DAD);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 230,
              width: double.infinity,
              child: Image.asset(
                'assets/images/challenge_main_hand.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_name ?? '챌린지 이름', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_company_name ?? '회사명', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 24),
                  const Text('챌린지 설명', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    _comment ?? '챌린지 설명 내용',
                    style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text('총 보상', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text("${_max_count ?? 0}원", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('달성률', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text("${_current_count ?? 0}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('데이터 종류 선택*', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Icon(Icons.help_outline, color: Colors.grey[400]),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isSelected = _selectedOptionId == option.id;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedOptionId = option.id),
                        child: Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? primaryColor : Colors.grey[300]!,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Image.asset(option.iconPath, width: 40, height: 40, errorBuilder: (context, error, stackTrace) => const Icon(Icons.error)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(option.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      Text(option.description, style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                                Text(
                                  option.points,
                                  style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            disabledBackgroundColor: Colors.grey[300],
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _selectedOptionId == null
              ? null
              : () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CameraPage(objectName: _selectedOptionId!, challengeId: widget.challengeId,),
              ),
            );
          },
          child: const Text('촬영하기', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}