import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      "image": "assets/images/illustrations/img_wallet.svg",
      "title": "일상의 모든 순간이 보상으로",
      "description": "Snapi와 함께 주변의 데이터를 수집하고\n포인트 혜택을 받아보세요.",
      "highlights": ["포인트 혜택"]
    },
    {
      "image": "assets/images/illustrations/img_phone.svg",
      "title": "간편한 챌린지 참여",
      "description": "사진 한 장으로 간편하게 챌린지에 참여하고\n포인트를 획득할 수 있습니다.",
      "highlights": ["사진 한 장"]
    },
    {
      "image": "assets/images/illustrations/img_social.svg",
      "title": "AI 기술 기여",
      "description": "AI가 여러분의 소중한 데이터를\n안전하고 정확하게 검증합니다.\n세상을 바꿉니다.",
      "highlights": ["소중한 데이터", "세상을 바꿉니다."]
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
                        if (_currentPage == _onboardingData.length - 1) {
                          Navigator.pushReplacementNamed(context, '/user_info');
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == _onboardingData.length - 1 ? '시작하기' : '계속하기',
                        style: kButtonTextStyle,
                      ),
                    ),
                  ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Text(
            title,
            style: kHeadline1Style.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildHighlightedParagraph(description, highlights),
          const Spacer(),
          Center(
            child: SizedBox(
              height: 220,
              child: _isSvg
                  ? SvgPicture.asset(image, fit: BoxFit.contain)
                  : Image.asset(image, fit: BoxFit.contain),
            ),
          ),
          const Spacer(),
        ],
      ),
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
