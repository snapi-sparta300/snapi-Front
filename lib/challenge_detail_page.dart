import 'package:flutter/material.dart';
import 'camera_page.dart'; // 카메라 페이지

// 데이터 선택 옵션을 위한 모델
class ChallengeOption {
  final String id;
  final String title;
  final String description;
  final String points;
  final String iconPath;
  final String overlayPath;

  ChallengeOption({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.iconPath,
    required this.overlayPath,
  });
}

class ChallengeDetailPage extends StatefulWidget {
  const ChallengeDetailPage({super.key});

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  String? _selectedOptionId;

  // 아이콘 경로를 최종 파일 이름으로 수정
  final List<ChallengeOption> options = [
    ChallengeOption(
        id: 'palm',
        title: '손바닥',
        description: '손바닥 전체를 정면에서...',
        points: '200P',
        iconPath: 'assets/images/icon_palm.png', // [변경]
        overlayPath: 'assets/guidelines/guideline_palm.png'),
    ChallengeOption(
        id: 'v_sign',
        title: '브이',
        description: "손가락 '브이(V)' 모양, 손...",
        points: '250P',
        iconPath: 'assets/images/icon_v_sign.png', // [변경]
        overlayPath: 'assets/guidelines/guideline_v_sign.png'),
    ChallengeOption(
        id: 'cup',
        title: '컵을 잡은 손',
        description: '컵을 잡은 손, 컵 윗 부분...',
        points: '300P',
        iconPath: 'assets/images/icon_cup.png', // [변경]
        overlayPath: 'assets/guidelines/guideline_cup.png'),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedOption = _selectedOptionId == null
        ? null
        : options.firstWhere((opt) => opt.id == _selectedOptionId);
    const primaryColor = Color(0xFF6A0DAD);

    return Scaffold(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [변경] 상단 대표 이미지를 실제 이미지로 교체
            SizedBox(
              height: 180,
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
                  const Text('손 사진', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('모션캡쳐 AI 회사', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 24),
                  const Text('챌린지 설명', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    '모션 캡쳐 AI 회사는 애니메이션 제작에 필요한 손 사진이 필요합니다. 다양한 각도의 손 데이터를 만들어 화려한 애니메이션 발달에 기여합시다!',
                    style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text('총 보상', style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 4),
                            Text('50,000 P', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('달성률', style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 4),
                            Text('75%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  const SizedBox(height: 16),
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
                      builder: (context) => CameraPage(
                        overlayImagePath: selectedOption!.overlayPath,
                      ),
                    ),
                  );
                },
          child: const Text('촬영하기', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}