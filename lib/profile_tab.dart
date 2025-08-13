import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_thousand/onboarding_page.dart'; // SharedPreferences 사용을 위해 import

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
  late SharedPreferences _prefs;

  int? _user_id = null;
  String? _user_name = null;
  String? _user_email = null;
  String? _user_gender = null;
  String? _user_birth = null;
  bool? _user_is_first = null;
  int? _user_point = null;
  List<String>? _user_coupons = null;

  bool is_loading = false;

  @override
  void initState() {
    super.initState();
    // 위젯이 생성될 때 사용자 데이터 로드
    _loadUserData();
  }

  // SharedPreferences에서 사용자 데이터를 불러오는 함수
  Future<void> _loadUserData() async {
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

      is_loading = true;
    });

    print(_user_coupons);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6A00C9);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.0,),
              Text(
                '프로필',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              SizedBox(height: 25.0,),
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
                            _user_name ?? '', // null이면 '이름...' 표시
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          // [수정된 부분]
                          Text(
                            _user_email ?? '', // null이면 '이메일...' 표시
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
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
                    Builder(
                        builder: (_){
                          if(is_loading){
                            if(_user_coupons?.length == 0){
                              return Padding(
                                  padding: EdgeInsets.all(50.0),
                                  child: const Center(
                                    child: Text('보관된 쿠폰이 없습니다', style: TextStyle(fontSize: 16.0, color: Colors.grey)),
                                  ));
                            }
                            return _buildMyCouponGrid();
                          }
                          else{
                            return CircularProgressIndicator();
                          }
                        }
                    ),
                    // 두 번째 탭: 설정
                    Column(
                      children: <Widget>[
                        TextButton(
                            onPressed: () async{
                              _prefs = await SharedPreferences.getInstance();
                              _prefs.setBool("user_is_first", true);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => OnboardingPage()),
                                    (Route<dynamic> route) => false, // 이 조건이 false일 때까지 모든 라우트 제거
                              );
                            },
                            child: Text(
                                "로그아웃",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.red,
                              ),
                            ),
                        )
                      ],
                    ),
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
    return ListView.builder(
      itemCount: _user_coupons?.length,
      itemBuilder: (BuildContext context, int index) {
        List<String>? couponInfo = _user_coupons?[index].split('/');
        String? coupon_title = couponInfo?[0];
        String? coupon_date = couponInfo?[1];
        String? coupon_code = couponInfo?[2];

        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: (){

          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(coupon_title!, style: const TextStyle(fontSize: 16,)),
                      Text(coupon_date!, style: const TextStyle(fontSize: 14, color: Colors.black45))
                    ],
                  )
                ),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: coupon_code!)).then((_) {
                  // 복사 성공 시 SnackBar로 사용자에게 알림
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('클립보드에 쿠폰 코드가 복사되었습니다.'),
                      duration: Duration(seconds: 2), // 메시지가 표시되는 시간
                    ),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black54,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              child: const Text('쿠폰 번호 복사'),
            ),
              ],
            ),
          ),
        );
      },
    );
  }
}