import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_thousand/challenge_detail_page.dart';
import 'app_constants.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late SharedPreferences _prefs;

  int? _user_id = null;
  String? _user_name = null;
  String? _user_email = null;
  String? _user_gender = null;
  String? _user_birth = null;
  bool? _user_is_first = null;
  int? _user_point = null;
  List<String>? _user_coupons = null;

  List<Map<dynamic, dynamic>> _challenges = [];
  List<Map<dynamic, dynamic>> _me_challenges = [];

  bool _is_loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _user_id = _prefs.getInt("user_id") ?? null;
      _user_name = _prefs.getString('user_name') ?? null;
      _user_email = _prefs.getString("user_email") ?? null;
      _user_gender = _prefs.getString("user_gender") ?? null;
      _user_birth = _prefs.getString('user_birth') ?? null;
      _user_is_first = _prefs.getBool('user_is_first') ?? null;
      _user_point = _prefs.getInt('user_point') ?? null;
      _user_coupons = _prefs.getStringList('user_coupons') ?? null;
    });

    // API 요청 2: 추가 정보 전송
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

      final List<dynamic> challengesFromApi = data['result']['challenges'];
      setState(() {
        _challenges = challengesFromApi.map((item) => item as Map<dynamic, dynamic>).toList();
      });

    } else {
      // 2단계 실패
      final errorData = jsonDecode(step2Response.body);
      final errorMessage = errorData['message'] ?? '추가 정보 등록에 실패했습니다.';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }

    // API 요청 2: 추가 정보 전송
    final step3Response = await http.get(
      Uri.parse('$kApiBaseUrl/challenges/${_user_id}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (step3Response.statusCode == 200 || step3Response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(step3Response.body);

      if(data['isSuccess'] == false) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        return;
      }

      final List<dynamic> meChallengesFromApi = data['result']['challenges'];
      setState(() {
        _me_challenges = meChallengesFromApi.map((item) => item as Map<dynamic, dynamic>).toList();
      });

    } else {
      // 2단계 실패
      final errorData = jsonDecode(step3Response.body);
      final errorMessage = errorData['message'] ?? '추가 정보 등록에 실패했습니다.';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }

    setState(() {
      _is_loading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if(!_is_loading) {
              return SizedBox();
            }

            return ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.0,),
                      // 인사말
                      Text(
                        'Snapi',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 25),

                      // 포인트 카드
                      _PointCard(point: _user_point ?? 0, un: _user_name!,),
                    ],
                  ),
                ),

                Divider(
                  thickness: 15.0, // 선의 실제 두께
                  color: Color(0xFFF3F3F3), // 선의 색상
                  height: 50.0, // 위아래 여백을 포함한 전체 높이
                ),

                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 5.0, right: 20.0, bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const _SectionTitle('참여 중인 챌린지'),
                      const SizedBox(height: 8),
                      _me_challenges.isNotEmpty
                          ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _me_challenges.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = _me_challenges[index];
                          return _ChallengeTile(
                            assetPng: 'assets/images/objects/${item['challengeId']}/title.png',
                            title: item['name'],
                            rewardText: item['totalPoint'].toString(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChallengeDetailPage(challengeId: item['challengeId']),
                                ),
                              );
                            },
                          );
                        },
                      )
                          : Padding(
                          padding: EdgeInsets.all(50.0),
                          child: const Center(
                            child: Text('참여 중인 챌린지가 없습니다.', style: TextStyle(fontSize: 16.0, color: Colors.grey)),
                          )),
                    ],
                  )
                ),

                Divider(
                  thickness: 15.0, // 선의 실제 두께
                  color: Color(0xFFF3F3F3), // 선의 색상
                  height: 50.0, // 위아래 여백을 포함한 전체 높이
                ),

                Padding(
                    padding: EdgeInsets.only(left: 20.0, top: 5.0, right: 20.0, bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const _SectionTitle('챌린지'),
                      const SizedBox(height: 8),
                      _challenges.isNotEmpty
                          ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _challenges.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = _challenges[index];
                          return _ChallengeTile(
                            assetPng: 'assets/images/objects/${item['challengeId']}/title.png',
                            title: item['name'],
                            rewardText: item['totalPoint'].toString(),
                            onTap: () async{
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChallengeDetailPage(challengeId: item['challengeId']),
                                ),
                              );

                              setState(() {});
                            },
                          );
                        },
                      )
                          : Padding(
                          padding: EdgeInsets.all(50.0),
                          child: const Center(
                            child: Text('챌린지가 없습니다.', style: TextStyle(fontSize: 16.0, color: Colors.grey)),
                          )),
                    ],
                  )
                ),
                // 챌린지

              ],
            );
          }
        ),
      ),
    );
  }
}

/* -------------------------------- Sub widgets -------------------------------- */

class _PointCard extends StatelessWidget {
  final int point;
  final String un;
  const _PointCard({required this.point, required this.un});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(color: const Color(0x4D6A0DAD), borderRadius: BorderRadius.circular(20)),
            alignment: Alignment.center,
            child: const Text(
                'P',
                style: TextStyle(fontSize: 28.0, color: kPrimaryColor, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('내 포인트', style: TextStyle(color: kSubTextColor, fontSize: 16.0)),
              Text('${point}원', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          // 피그마의 회색 '내역' 느낌
          IgnorePointer(
            ignoring: true,
            child: ElevatedButton(
              onPressed: () => null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black54,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              child: Text(un + "님"),
            ),
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
    return Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600));
  }
}

class _ChallengeTile extends StatelessWidget {
  final String assetPng;
  final String title;
  final String rewardText;
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text("총 ${rewardText} P", style: const TextStyle(fontSize: 14, color: kPrimaryColor)),
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