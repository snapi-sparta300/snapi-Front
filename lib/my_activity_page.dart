import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';

class MyActivityPage extends StatefulWidget {
  @override
  _MyActivityPageState createState() => _MyActivityPageState();
}

class _MyActivityPageState extends State<MyActivityPage> {
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('내 활동'),
        ),
        body: Column(
          children: [
            // 상단 포인트 현황 및 출금 버튼
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('총 보유 포인트', style: kSubBodyTextStyle),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _user_point == null ?
                      const CircularProgressIndicator() :
                      Text(
                        "${_user_point} P",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          // 현금으로 출금 로직
                        },
                        child: const Text('현금으로 출금'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 탭 바
            const TabBar(
              tabs: [
                Tab(text: '제출 내역'),
                Tab(text: '쿠폰 교환 내역'),
              ],
              labelColor: kPrimaryColor,
              unselectedLabelColor: kSubTextColor,
              indicatorColor: kPrimaryColor,
            ),
            // 탭 바 뷰
            Expanded(
              child: TabBarView(
                children: [
                  _buildSubmissionHistory(),
                  _buildCouponHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 제출 내역 탭
  Widget _buildSubmissionHistory() {
    // 더미 데이터
    final List<Map<String, String>> history = [
      {'title': '우리 동네 킥보드 챌린지', 'point': '+100P', 'status': '검수 완료'},
      {'title': '우리 동네 킥보드 챌린지', 'point': '+100P', 'status': '검수 대기중'},
      {'title': '가을 하늘 사진 챌린지', 'point': '+50P', 'status': '검수 실패'},
      {'title': '우리 동네 맛집 찍기', 'point': '+150P', 'status': '검수 완료'},
    ];

    return ListView.separated(
      itemCount: history.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = history[index];
        Color statusColor = Colors.grey;
        if (item['status'] == '검수 완료') statusColor = kSecondaryColor;
        if (item['status'] == '검수 실패') statusColor = Colors.red;

        return ListTile(
          title: Text(item['title']!),
          subtitle: Text(item['status']!, style: TextStyle(color: statusColor)),
          trailing: Text(item['point']!, style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
        );
      },
    );
  }

  // 쿠폰 교환 내역 탭
  Widget _buildCouponHistory() {
    // 더미 데이터
    final List<Map<String, String>> history = [
      {'name': '스타벅스 아메리카노 T', 'point': '-4,500P', 'date': '2023.10.26'},
      {'name': 'CU 편의점 1,000원권', 'point': '-1,000P', 'date': '2023.10.20'},
    ];

    if (history.isEmpty) {
      return const Center(child: Text('쿠폰 교환 내역이 없습니다.'));
    }

    return ListView.separated(
      itemCount: history.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = history[index];
        return ListTile(
          title: Text(item['name']!),
          subtitle: Text(item['date']!),
          trailing: Text(item['point']!, style: const TextStyle(color: Colors.red)),
        );
      },
    );
  }
}