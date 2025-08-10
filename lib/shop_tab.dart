import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SVG 패키지 import

// 쿠폰 데이터를 담을 간단한 모델 클래스
class Coupon {
  final String imageUrl;
  final String title;
  final String price;

  Coupon({required this.imageUrl, required this.title, required this.price});
}

class ShopTabPage extends StatelessWidget {
  ShopTabPage({super.key});

  // 쿠폰 데이터 (로컬 asset 이미지 경로 사용)
  final List<Coupon> allCoupons = [
    Coupon(imageUrl: 'assets/images/coupons/mega_coffee.png', title: '메가 커피 1만원 쿠폰', price: '12,000원'),
    Coupon(imageUrl: 'assets/images/coupons/baemin_coupon.png', title: '배달의 민족 5천원 쿠폰', price: '6,000원'),
    Coupon(imageUrl: 'assets/images/coupons/chicken.png', title: '우리집 닭강정 2만원 쿠폰', price: '21,000원'),
    Coupon(imageUrl: 'assets/images/coupons/myjju.png', title: '마이쮸 쿠폰', price: '1,000원'),
  ];


  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6A00C9);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Snapi 쇼핑',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 광고 영역
            Container(
              height: 120,
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('광고', style: TextStyle(color: Colors.grey[600])),
              ),
            ),
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
                    '인기 있는 쿠폰',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
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
                          coupon.price,
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
      builder: (context) {
        return Padding(
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
                      Text(
                        '120원',
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
                      coupon.price,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
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
        );
      },
    );
  }
}