import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart'; // SVG 패키지 import

var uuid = const Uuid();

// 쿠폰 데이터를 담을 간단한 모델 클래스
class Coupon {
  final String imageUrl;
  final String title;
  final int price;

  Coupon({required this.imageUrl, required this.title, required this.price});
}

class ShopTabPage extends StatefulWidget {
  @override
  _ShopTabPageState createState() => _ShopTabPageState();
}

class _ShopTabPageState extends State<ShopTabPage> {
  late SharedPreferences _prefs;

  int? _user_id = null;
  String? _user_name = null;
  String? _user_email = null;
  String? _user_gender = null;
  String? _user_birth = null;
  bool? _user_is_first = null;
  int? _user_point = null;
  List<String>? _user_coupons = null;

  // 쿠폰 데이터 (로컬 asset 이미지 경로 사용)
  final List<Coupon> allCoupons = [
    Coupon(imageUrl: 'assets/images/coupons/mega_coffee.png', title: '메가 커피 1만원 쿠폰', price: 1100),
    Coupon(imageUrl: 'assets/images/coupons/baemin_coupon.png', title: '배달의 민족 5천원 쿠폰', price: 6000),
    Coupon(imageUrl: 'assets/images/coupons/chicken.png', title: '우리집 닭강정 2만원 쿠폰', price: 21000),
    Coupon(imageUrl: 'assets/images/coupons/myjju.png', title: '마이쮸 쿠폰', price: 10),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
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
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6A00C9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.0,),
            Text(
              'Snapi 쇼핑',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 25.0,),
            // 광고 영역
            // 인기 있는 쿠폰 섹션 (SVG 아이콘 적용)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/cookie.svg',
                    width: 24, // SVG 아이콘 크기 조절
                    height: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '쿠폰',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.0,),
            // 쿠폰 그리드
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: allCoupons.length,
              itemBuilder: (context, index) {
                final coupon = allCoupons[index];
                return GestureDetector(
                  onTap: () {
                    _showPurchaseBottomSheet(context, coupon, primaryColor);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11), // 테두리 안쪽으로 부드럽게 잘리도록
                            child: Image.asset(
                              coupon.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(coupon.title, style: TextStyle(fontSize: 16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                        child: Text(
                          coupon.price.toString() + "원",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 구매하기 Bottom Sheet
  void _showPurchaseBottomSheet(BuildContext context, Coupon coupon, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // builder 함수를 StatefulBuilder로 감쌉니다.
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter bottomSheetSetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Text(
                            'P',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('내 포인트', style: TextStyle(color: Colors.grey[600])),
                            // 바텀시트가 다시 빌드될 때마다 업데이트된 _user_point 값을 사용합니다.
                            Text(
                              (_user_point.toString() ?? "0") + "원",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(coupon.title, style: TextStyle(fontSize: 16)),
                          Text(
                            coupon.price.toString() + "원",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          _prefs = await SharedPreferences.getInstance();
                          if(_user_point! < coupon.price){
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('포인트가 부족합니다.')),
                            );
                          } else {
                            // SharedPreferences와 _user_point 값을 먼저 업데이트
                            _prefs.setInt("user_point", _user_point! - coupon.price);
                            _user_coupons?.add(coupon.title + "/" + DateTime.now().toString() + "/" + uuid.v4());
                            _prefs.setStringList("user_coupons", _user_coupons!);

                            // 바텀시트의 상태를 업데이트하는 setState 호출
                            bottomSheetSetState(() {
                              // setState 내에서 _user_point 값을 변경하여 UI를 갱신합니다.
                              _user_point = _user_point! - coupon.price;
                            });

                            // 메인 위젯의 상태를 업데이트하는 setState도 호출 (옵션)
                            setState(() {});

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('쿠폰을 구입하였습니다!')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '구입하기',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}