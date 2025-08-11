import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';

// kApiBaseUrl이 정의되어 있지 않다면 아래 라인의 주석을 해제하고 실제 서버 주소를 입력하세요.
// const String kApiBaseUrl = 'https://your.api.server.com';

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  State<UserLoginPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserLoginPage> {
  final _nameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false; // API 통신 중 로딩 상태를 관리

  Future<void> requestCameraPermission() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      print("카메라 및 마이크 권한이 허용되었습니다.");
    } else {
      print("카메라 및 마이크 권한이 거부되었습니다.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카메라와 마이크 권한이 필요합니다. 설정에서 허용해주세요.')),
        );
      }
      openAppSettings();
    }
  }

  String _formatBirth(DateTime? d) {
    if (d == null) return '';
    return '${d.year.toString().padLeft(4, '0')}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _formatBirthForApi(DateTime? d) {
    if (d == null) return null;
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final step1Response = await http.post(
        Uri.parse('$kApiBaseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _nameCtrl.text.trim(),
          'password': _passwordCtrl.text.trim(),
        }),
      );

      if (step1Response.statusCode == 200 || step1Response.statusCode == 201) {
        final responseData = jsonDecode(step1Response.body);
        final userId = responseData['result']['userId'];

        final step2Response = await http.get(
          Uri.parse('$kApiBaseUrl/members/$userId/profile'),
          headers: {'Content-Type': 'application/json'},
        );

        if (step2Response.statusCode == 200 || step2Response.statusCode == 201) {
          final Map<String, dynamic> data = jsonDecode(step2Response.body);
          final prefs = await SharedPreferences.getInstance();

          // --- 이 부분이 수정되었습니다 ---
          // null-aware 연산자(??)를 사용해 null 값을 빈 문자열로 대체

          await prefs.setInt('user_id', data['result']['userId']);
          await prefs.setString('user_name', data['result']['nickname']);
          await prefs.setString('user_email', data['result']['email']);
          await prefs.setString('user_gender', data['result']['gender']);
          await prefs.setString('user_birth', data['result']['birth']);
          await prefs.setBool('user_is_first', false);
          await prefs.setInt('user_point', data['result']['userPoint']);
          await prefs.setStringList('user_coupons', []);

          await requestCameraPermission();

          if (!mounted) return;

          Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);

        } else {
          final errorData = jsonDecode(step2Response.body);
          final errorMessage = errorData['message'] ?? '추가 정보 등록에 실패했습니다.';
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      } else {
        final errorData = jsonDecode(step1Response.body);
        final errorMessage = "a" + (errorData['message'] ?? '아이디 생성에 실패했습니다. (예: 중복된 아이디)');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      print(e);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('오류가 발생했습니다. 잠시 후 다시 시도해주세요.')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration get _underlineInputDeco => const InputDecoration(
    border: UnderlineInputBorder(),
    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE0E0E0))),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kPrimaryColor, width: 2)),
    contentPadding: EdgeInsets.symmetric(vertical: 12),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '로그인',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              const Text('이름(닉네임)', style: kSubBodyTextStyle),
              TextFormField(
                controller: _nameCtrl,
                decoration: _underlineInputDeco,
                validator: (v) => (v == null || v.trim().isEmpty) ? '이름(닉네임)을 입력해주세요.' : null,
              ),
              const SizedBox(height: 20),
              const Text('비밀번호', style: kSubBodyTextStyle),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: _underlineInputDeco,
                validator: (v) => (v == null || v.trim().isEmpty) ? '비밀번호를 입력해주세요.' : null,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                disabledBackgroundColor: kPrimaryColor.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('저장하고 시작하기', style: kButtonTextStyle),
            ),
          ),
        ),
      ),
    );
  }
}