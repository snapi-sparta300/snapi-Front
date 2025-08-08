import 'package:flutter/material.dart';
import 'app_constants.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 온보딩 페이지 데이터
  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/onboarding1.png", // 실제 이미지 경로로 변경 필요
      "title": "일상의 모든 순간이 보상으로",
      "description": "Snapi와 함께 주변의 데이터를 수집하고\n포인트 혜택을 받아보세요."
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "간편한 챌린지 참여",
      "description": "사진 한 장으로 간편하게 챌린지에 참여하고\n리워드를 획득할 수 있습니다."
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "AI 기반의 스마트한 검증",
      "description": "AI가 여러분의 소중한 데이터를\n안전하고 정확하게 검증합니다."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingContent(
                    image: _onboardingData[index]['image']!,
                    title: _onboardingData[index]['title']!,
                    description: _onboardingData[index]['description']!,
                  );
                },
              ),
            ),
            // 하단 인디케이터 및 버튼
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                          (index) => buildDot(index: index),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // 마지막 페이지에서 '시작하기' 버튼 표시
                  if (_currentPage == _onboardingData.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        // SharedPreferences에 온보딩 완료 상태 저장 로직 추가
                        Navigator.pushReplacementNamed(context, '/user_info');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('시작하기'),
                    )
                  else
                  // 그 외 페이지에서는 '다음' 버튼 표시
                    ElevatedButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('다음'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 인디케이터 UI
  AnimatedContainer buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? kPrimaryColor : const Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// 온보딩 페이지의 내용을 구성하는 위젯
class OnboardingContent extends StatelessWidget {
  const OnboardingContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder for image
          Image.asset(
            image,
            height: 300,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image, size: 300, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: kHeadline1Style,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: kSubBodyTextStyle.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}