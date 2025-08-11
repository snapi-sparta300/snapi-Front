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
      "highlights": ["수익 창출"]
    },
    {
      "image": "assets/images/illustrations/ill2.svg",
      "title": "사진 한 장으로\nAI 발전 기여",
      "description": "AI는 제공 받는 데이터로 학습합니다",
      "highlights": ["AI 발전 기여"]
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
                    highlights: List<String>.from(data["highlights"] as List),
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
  final List<String> highlights;

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
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: kHeadline1Style.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5.0,),
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

  // 텍스트 안에서 여러 키워드를 위치 기준으로 찾아 강조 (중복·순서 안전)
  Widget _buildHighlightedParagraph(String text, List<String> keys) {
    if (keys.isEmpty) {
      return Text(
        text,
        style: kSubBodyTextStyle.copyWith(fontSize: 14, height: 1.5, color: kSubTextColor),
      );
    }

    // 모든 키워드의 최초 등장 위치 수집
    final matches = <_Hit>[];
    for (final k in keys) {
      final idx = text.indexOf(k);
      if (idx != -1) {
        matches.add(_Hit(start: idx, end: idx + k.length));
      }
    }
    if (matches.isEmpty) {
      return Text(
        text,
        style: kSubBodyTextStyle.copyWith(fontSize: 14, height: 1.5, color: kSubTextColor),
      );
    }

    // 위치 순으로 정렬하고 겹치는 구간 정리
    matches.sort((a, b) => a.start.compareTo(b.start));
    final merged = <_Hit>[];
    for (final m in matches) {
      if (merged.isEmpty || m.start > merged.last.end) {
        merged.add(m);
      } else {
        // 겹치면 확장
        merged.last = _Hit(
          start: merged.last.start,
          end: m.end > merged.last.end ? m.end : merged.last.end,
        );
      }
    }

    // 일반/강조 span 조립
    final spans = <TextSpan>[];
    int cursor = 0;
    for (final h in merged) {
      if (cursor < h.start) {
        spans.add(TextSpan(text: text.substring(cursor, h.start)));
      }
      spans.add(TextSpan(
        text: text.substring(h.start, h.end),
        style: kSubBodyTextStyle.copyWith(
          color: kPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
      ));
      cursor = h.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return Text.rich(
      TextSpan(
        style: kSubBodyTextStyle.copyWith(fontSize: 14, height: 1.5, color: kSubTextColor),
        children: spans,
      ),
    );
  }
}

class _Hit {
  final int start;
  final int end;
  const _Hit({required this.start, required this.end});
}
