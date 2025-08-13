import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app_constants.dart';
import 'camera_page.dart'; // 카메라 페이지

// 데이터 선택 옵션을 위한 모델
class ChallengeOption {
  final int id;
  final String title;
  final int points;
  final bool userJoined;
  final String iconPath;

  ChallengeOption({
    required this.id,
    required this.title,
    required this.points,
    required this.userJoined,
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
  int? _selectedOptionId;
  int? _selectedOptionPoints;

  String? _name;
  String? _company_name;
  String? _comment;
  int? _progress_rate;
  int? _total_point;

  // 아이콘 경로를 최종 파일 이름으로 수정
  late List<ChallengeOption> options = [];

  bool _is_loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final step2Response = await http.get(
      Uri.parse('$kApiBaseUrl/challenges/all'),
      headers: {'Content-Type': 'application/json'},
    );

    if (step2Response.statusCode == 200 || step2Response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(step2Response.body);

      if(data['isSuccess'] == false) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        return;
      }

      Map<String, dynamic> challenge = data['result']['challenges'].firstWhere(
            (_challenge) => _challenge['challengeId'] == widget.challengeId,
        orElse: () => {},
      );

      if (challenge != {}) {
        setState(() {
          _name = challenge['name'];
          _company_name = challenge['companyName'];
          _comment = challenge['comment'];
          _progress_rate = challenge['progressRate'];
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }

    final step3Response = await http.get(
      Uri.parse('$kApiBaseUrl/challenges/detail/${widget.challengeId}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (step3Response.statusCode == 200 || step3Response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(step3Response.body);

      if(data['isSuccess'] == false) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        return;
      }

      dynamic missions = data['result']['missions'];

      for(int i = 0; i < missions.length; i++){
        options = options + [
          ChallengeOption(
            id: missions[i]['missionId'],
            title: missions[i]['name'],
            points: missions[i]['point'],
            userJoined : missions[i]['userJoined'],
            iconPath: 'assets/images/objects/${widget.challengeId}/${widget.challengeId}_${missions[i]['missionId']}/cover.png',
          ),
        ];
      }

      setState(() {});

    } else {
      final errorData = jsonDecode(step2Response.body);
      final errorMessage = errorData['message'] ?? '챌린지 정보를 불러오는데 실패했습니다.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }

    setState(() {
      _is_loading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: Builder(
        builder: (BuildContext context) {
          if(!_is_loading) {
            return SizedBox();
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 230,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/objects/${widget.challengeId}/title.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_name ?? '', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_company_name ?? '', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 24),
                      const Text('챌린지 설명', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        _comment ?? '',
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
                                Text("${_total_point ?? 0} P", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            Column(
                              children: [
                                const Text('달성률', style: TextStyle(color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text("${_progress_rate ?? 0}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('데이터 종류 선택*', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(onPressed: (){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('사진 촬영 가이드라인'),
                                  content: Text(_comment!),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 다이얼로그 닫기
                                      },
                                      child: Text('닫기'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }, icon: Icon(Icons.help_outline, color: Colors.grey[400])),
                        ],
                      ),
                      const SizedBox(height: 8), // 제목과 리스트 사이에 적절한 간격 추가
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero, // ListView의 기본 패딩 제거
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options[index];
                          final isSelected = _selectedOptionId == option.id;
                          // 이미 참여했는지 여부
                          final isJoined = option.userJoined;

                          return IgnorePointer(
                            ignoring: isJoined, // 이미 참여했으면 터치 무시
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _selectedOptionId = option.id;
                                _selectedOptionPoints = option.points;
                              }),
                              // 마우스 커서 변경을 위해 MouseRegion 추가
                              child: MouseRegion(
                                cursor: isJoined ? SystemMouseCursors.basic : SystemMouseCursors.click,
                                child: Card(
                                  elevation: 0,
                                  // 배경색을 userJoined 상태에 따라 변경
                                  color: isJoined ? Colors.grey[200] : Colors.white, // <-- 이 부분을 추가
                                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      // 테두리 색상과 굵기를 userJoined 상태에 따라 변경
                                      color: isJoined ? Colors.grey[400]! : (isSelected ? primaryColor : Colors.grey[300]!),
                                      width: isJoined ? 1.0 : (isSelected ? 2.0 : 1.0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        // 이미지 위젯도 userJoined 상태에 따라 투명도 조절 가능
                                        // Image.asset(
                                        //   option.iconPath,
                                        //   width: 40,
                                        //   height: 40,
                                        //   color: isJoined ? Colors.grey : null,
                                        //   colorBlendMode: isJoined ? BlendMode.saturation : null,
                                        //   errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                        // ),
                                        // 이미지에 그레이스케일 필터 적용 예시
                                        ColorFiltered(
                                          colorFilter: isJoined
                                              ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                                              : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                                          child: Image.asset(
                                            option.iconPath,
                                            width: 40,
                                            height: 40,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                option.title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  // 텍스트 색상을 userJoined 상태에 따라 변경
                                                  color: isJoined ? Colors.grey[600] : Colors.black,
                                                ),
                                                textAlign: TextAlign.start,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              option.points.toString() + " P",
                                              style: TextStyle(
                                                // 포인트 텍스트 색상도 변경
                                                color: isJoined ? Colors.grey[600] : primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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
          );
        },
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
                builder: (context) => CameraPage(missionId: _selectedOptionId!, challengeId: widget.challengeId, missionPoint: _selectedOptionPoints!),
              ),
            );
          },
          child: const Text('촬영하기', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}