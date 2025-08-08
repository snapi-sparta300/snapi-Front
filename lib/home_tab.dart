import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();

}

class _HomeTabState extends State<HomeTab> {
  late SharedPreferences _prefs;
  String? _user_name;
  List<String>? _user_interests;
  int? _user_point;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _user_name = _prefs.getString('user_name');
      _user_interests = _prefs.getStringList('user_interests');
      _user_point = _prefs.getInt("user_point");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 헤더
            _user_name == null ?
              CircularProgressIndicator() :
              Text(
                  '안녕하세요, $_user_name님!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
              ),
            const SizedBox(height: 24),
            // 포인트 현황 카드
            _buildPointCard(context),
            const SizedBox(height: 32),
            // 챌린지 목록
            _buildChallengeSection(
              context,
              icon: '🎯',
              title: '나에게 적합한 챌린지',
              challenges: [
                {'title': '우리 동네 맛집 찍기', 'reward': '15,000P'},
                {'title': '가을 하늘 사진 챌린지', 'reward': '10,000P'},
              ],
            ),
            const SizedBox(height: 24),
            _buildChallengeSection(
              context,
              icon: '✨',
              title: '인기 있는 챌린지',
              challenges: [
                {'title': '전동 킥보드 주차 사진 찍기', 'reward': '50,000P'},
                {'title': '출근길 풍경 챌린지', 'reward': '20,000P'},
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 포인트 현황 카드 위젯
  Widget _buildPointCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/my_activity');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '보유 포인트',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                _user_point == null ?
                const CircularProgressIndicator(color: Colors.white,) :
                Text(
                  "${_user_point} P",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  '검수 대기 중: 1,200 P', // 실제 검수 대기 포인트 데이터로 변경
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 18,
              ),
            )
          ],
        ),
      ),
    );
  }

  // 챌린지 섹션 위젯
  Widget _buildChallengeSection(BuildContext context,
      {required String icon,
        required String title,
        required List<Map<String, String>> challenges}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$icon $title',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: challenges.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildChallengeCard(
              context,
              title: challenges[index]['title']!,
              reward: challenges[index]['reward']!,
            );
          },
        )
      ],
    );
  }

  // 챌린지 카드 위젯
  Widget _buildChallengeCard(BuildContext context,
      {required String title, required String reward}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/challenge_detail');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Placeholder for challenge image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    '총 보상: $reward',
                    style: const TextStyle(color: kPrimaryColor, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}