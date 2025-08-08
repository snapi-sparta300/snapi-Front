import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';
import 'challenge_detail_page.dart';
import 'main_page.dart';
import 'my_activity_page.dart';
import 'onboarding_page.dart';
import 'user_info_page.dart';
import 'verification_page.dart';

void main() async{
  // runApp을 호출하기 전에 Flutter 엔진 바인딩을 초기화해야 합니다.
  // SharedPreferences를 사용하기 전에 필요합니다.
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // 'is_first' 값을 읽어옵니다. 저장된 값이 없으면 true를 기본값으로 사용합니다.
  final bool isFirstTime = prefs.getBool('is_first') ?? true;

  runApp(SnapiApp(isFirstTime: isFirstTime));
}

class SnapiApp extends StatelessWidget {
  final bool isFirstTime;

  const SnapiApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snapi',
      // 앱의 전반적인 테마 설정
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
        ),
        fontFamily: 'Pretendard', // 앱 전체에 적용할 기본 폰트
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      // 앱의 초기 화면을 OnboardingPage로 설정
      // 실제 앱에서는 SharedPreferences 등을 확인하여 온보딩 완료 여부에 따라 MainPage로 바로 이동하는 로직 추가 필요
      home: const OnboardingPage(),
      // 라우트 설정
      initialRoute: isFirstTime ? '/onboarding' : '/main',
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/user_info': (context) => const UserInfoPage(),
        '/main': (context) => const MainPage(),
        '/challenge_detail': (context) => ChallengeDetailPage(),
        //'/verification': (context) => VerificationPage(), // 테스트를 위해 기본값을 true로 설정
        '/my_activity': (context) => MyActivityPage(),
      },
    );
  }
}