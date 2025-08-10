import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 사용을 위해 import

// Coupon 클래스를 별도 파일로 분리하는 것을 권장합니다.
// 예: lib/models/coupon_model.dart
class Coupon {
  final String imageUrl;
  final String title;

  Coupon({required this.imageUrl, required this.title});
}

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  // 사용자 정보를 담을 상태 변수
  String? _userName;
  String? _userEmail;

  // 더미 데이터
  final List<Coupon> myCoupons = [
    Coupon(imageUrl: 'assets/images/coupons/mega_coffee.png', title: '메가커피 디지털상품권'),
    Coupon(imageUrl: 'assets/images/coupons/baemin_coupon.png', title: '배달의민족 상품권'),
  ];

  @override
  void initState() {
    super.initState();
    // 위젯이 생성될 때 사용자 데이터 로드
    _loadUserData();
  }

  // SharedPreferences에서 사용자 데이터를 불러오는 함수
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // setState를 통해 화면을 다시 그려서 데이터를 반영
    setState(() {
      // 'user_name'과 'user_email' 키로 저장된 값을 불러옵니다.
      // 키 이름은 실제 프로젝트에 맞게 확인/수정이 필요할 수 있습니다.
      _userName = prefs.getString('user_name');
      _userEmail = prefs.getString('user_email');
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6A00C9);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            '프로필',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // 프로필 정보
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[200],
                      child: Icon(Icons.person, size: 30, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // [수정된 부분]
                          // 데이터 로딩 중이면 '이름...'을, 로딩 후엔 실제 이름을 표시
                          Text(
                            _userName ?? '이름...', // null이면 '이름...' 표시
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          // [수정된 부분]
                          Text(
                            _userEmail ?? '이메일...', // null이면 '이메일...' 표시
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // 수정 페이지로 이동하는 로직
                      },
                      child: const Text(
                        '수정',
                        style: TextStyle(color: primaryColor, fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 탭 바
              TabBar(
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey[500],
                indicatorColor: primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 16),
                tabs: const [
                  Tab(text: '보관된 쿠폰'),
                  Tab(text: '설정'),
                ],
              ),
              // 탭 바 뷰
              Expanded(
                child: TabBarView(
                  children: [
                    // 첫 번째 탭: 보관된 쿠폰
                    _buildMyCouponGrid(),
                    // 두 번째 탭: 설정
                    const Center(child: Text('설정 페이지 입니다.')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyCouponGrid() {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 24.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: myCoupons.length,
      itemBuilder: (context, index) {
        final coupon = myCoupons[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.asset(
              coupon.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}