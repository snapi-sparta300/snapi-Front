import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late SharedPreferences _prefs;
  String _userName = '';
  int _userPoint = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = _prefs.getString('user_name') ?? '';
      _userPoint = _prefs.getInt('user_point') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 인사말
            Text(
              _userName.isEmpty ? '안녕하세요!' : '안녕하세요, $_userName님!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 포인트 카드
            _PointCard(point: _userPoint),

            const SizedBox(height: 16),
            const Divider(height: 32),

            // 참여 중인 챌린지
            const _SectionTitle('참여 중인 챌린지'),
            const SizedBox(height: 8),
            _ChallengeTile(
              assetPng: 'assets/images/home/main1.png',
              title: '마우스 사진',
              rewardText: '총 1,500,000원',
              onTap: () => Navigator.pushNamed(context, '/challenge_detail'),
            ),

            const SizedBox(height: 12),
            const Divider(height: 32),

            // 챌린지
            const _SectionTitle('챌린지'),
            const SizedBox(height: 8),
            _ChallengeTile(
              assetPng: 'assets/images/home/main2.png',
              title: '손 사진',
              rewardText: '총 1,000,000원',
              onTap: () => Navigator.pushNamed(context, '/challenge_detail'),
            ),
            _ChallengeTile(
              assetPng: 'assets/images/home/main3.png',
              title: '맨홀 뚜껑 사진',
              rewardText: '총 500,000원',
              onTap: () => Navigator.pushNamed(context, '/challenge_detail'),
            ),
            _ChallengeTile(
              assetPng: 'assets/images/home/main4.png',
              title: '음료수 사진',
              rewardText: '총 200,000원',
              onTap: () => Navigator.pushNamed(context, '/challenge_detail'),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------- Sub widgets -------------------------------- */

class _PointCard extends StatelessWidget {
  final int point;
  const _PointCard({required this.point});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Text('P', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('내 포인트', style: TextStyle(color: kSubTextColor)),
              Text('${point}원', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          // 피그마의 회색 '내역' 느낌
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/my_activity'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black54,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text('내역'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
  }
}

class _ChallengeTile extends StatelessWidget {
  final String assetPng;    // e.g. assets/images/home/main1.png
  final String title;
  final String rewardText;  // e.g. "총 1,500,000원"
  final VoidCallback onTap;

  const _ChallengeTile({
    required this.assetPng,
    required this.title,
    required this.rewardText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // 썸네일 (피그마 기준 56×56)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                assetPng,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(rewardText, style: const TextStyle(fontSize: 14, color: kPrimaryColor)),
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
