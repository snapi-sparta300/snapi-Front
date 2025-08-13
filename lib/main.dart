import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';
import 'main_page.dart';
import 'onboarding_page.dart';
import 'package:flutter/services.dart';

void main() async{
  // runApp을 호출하기 전에 Flutter 엔진 바인딩을 초기화해야 합니다.
  // SharedPreferences를 사용하기 전에 필요합니다.
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // 상태 표시줄 배경색을 투명하게 설정
    statusBarIconBrightness: Brightness.dark, // Android: 아이콘 색상을 검은색으로 설정
    statusBarBrightness: Brightness.light, // iOS: 아이콘 색상을 검은색으로 설정
  ));

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // 'is_first' 값을 읽어옵니다. 저장된 값이 없으면 true를 기본값으로 사용합니다.
  final bool user_is_first = prefs.getBool('user_is_first') ?? true;

  runApp(SnapiApp(user_is_first: user_is_first));
}

class SnapiApp extends StatelessWidget {
  final bool user_is_first;

  const SnapiApp({super.key, required this.user_is_first});

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
      initialRoute: user_is_first ? '/onboarding' : '/main',
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/main': (context) => const MainPage(),
      },
    );
  }
}