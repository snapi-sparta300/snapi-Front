import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:three_thousand/user_info_page.dart';
import 'package:three_thousand/user_login_page.dart';
import 'app_constants.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 페이지별 이미지/텍스트/강조어
  static const List<Map<String, dynamic>> _onboardingData = [
    {
      "image": "assets/images/illustrations/ill1.svg",
      "title": "사진 한 장으로\n수익 창출",
      "description": "소소한 수익을 얻어 보세요",
      "highlights": "수익 창출",
    },
    {
      "image": "assets/images/illustrations/ill2.svg",
      "title": "사진 한 장으로\nAI 발전 기여",
      "description": "AI는 제공 받는 데이터로 학습합니다",
      "highlights": "AI 발전 기여"
    },
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
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return OnboardingContent(
                    image: data["image"] as String,
                    title: data["title"] as String,
                    description: data["description"] as String,
                    highlights: data['highlights'] as String,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => _buildDot(active: _currentPage == index),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserInfoPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "시작하기",
                        style: kButtonTextStyle,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserLoginPage()),
                        );
                      },
                      child: Text(
                        "이미 계정이 있나요?",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black26
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: active ? 8 : 6,
      width: active ? 8 : 6,
      decoration: BoxDecoration(
        color: active ? kPrimaryColor : kPrimaryColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  const OnboardingContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.highlights,
  });

  final String image;
  final String title;
  final String description;
  final String highlights;

  bool get _isSvg => image.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.black12,
            child: Center(
              child: SizedBox(
                height: 220,
                child: _isSvg
                    ? SvgPicture.asset(image, fit: BoxFit.contain)
                    : Image.asset(image, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
        Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          style: const TextStyle(fontSize: 24.0, color: Colors.black),
                          children: buildTextSpans(title, highlights),
                        ),
                      ),
                      SizedBox(height: 10.0,),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: kSubBodyTextStyle
                      ),
                    ],
                  ),
                ),
              ),
            )
        ),
      ],
    );
  }

  List<TextSpan> buildTextSpans(String text, String highlight) {
    if (highlight.isEmpty) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    final RegExp regex = RegExp(highlight, caseSensitive: false); // 대소문자 구분 없이 찾기
    int start = 0;

    for (final match in regex.allMatches(text)) {
      // 강조할 부분 앞의 일반 텍스트
      spans.add(TextSpan(text: text.substring(start, match.start)));

      // 강조할 텍스트
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: kPrimaryColor,
        ),
      ));

      start = match.end;
    }

    // 마지막 남은 일반 텍스트
    spans.add(TextSpan(text: text.substring(start)));

    return spans;
  }
}