import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';

class ShopTab extends StatefulWidget {
  @override
  _ShopTabState createState() => _ShopTabState();
}

class _ShopTabState extends State<ShopTab> {
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
      length: 2, // 카테고리 개수
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Snapi 쇼핑'),
          // 포인트 현황을 AppBar 아래에 배치
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('보유 포인트'),
                          _user_point == null ?
                          const CircularProgressIndicator() :
                          Text(
                              "${_user_point} P",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // 포인트 충전(챌린지 참여) 페이지로 이동
                        },
                        child: const Text('포인트 충전'),
                      )
                    ],
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab(text: '카페/음료'),
                    Tab(text: '편의점'),
                  ],
                  labelColor: kPrimaryColor,
                  unselectedLabelColor: kSubTextColor,
                  indicatorColor: kPrimaryColor,
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            // 각 카테고리별 쿠폰 목록
            CouponGrid(category: 'cafe'),
            CouponGrid(category: 'convenience'),
          ],
        ),
      ),
    );
  }
}

// 쿠폰 목록을 보여주는 그리드 위젯
class CouponGrid extends StatelessWidget {
  final String category;
  const CouponGrid({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // 더미 데이터
    final List<Map<String, dynamic>> coupons = [
      {'name': '스타벅스 아메리카노 T', 'point': 4500, 'image': 'assets/images/starbucks.png'},
      {'name': '이디야커피 아이스티', 'point': 2500, 'image': 'assets/images/ediya.png'},
      {'name': 'CU 1,000원권', 'point': 1000, 'image': 'assets/images/cu.png'},
      {'name': 'GS25 2,000원권', 'point': 2000, 'image': 'assets/images/gs25.png'},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        return CouponCard(
          name: coupon['name'],
          point: coupon['point'],
          image: coupon['image'],
        );
      },
    );
  }
}

// 개별 쿠폰 카드 위젯
class CouponCard extends StatelessWidget {
  final String name;
  final int point;
  final String image;

  const CouponCard({
    super.key,
    required this.name,
    required this.point,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.image_not_supported)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${point}P', style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // 교환하기 로직
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                    child: const Text('교환하기'),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}