import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _nameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _genders = const ['남자', '여자', '선택 안함'];
  String? _gender;
  final _formKey = GlobalKey<FormState>();
  DateTime? _birth;
  bool _agree = false;
  bool _isLoading = false;

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
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirth() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 100, 1, 1);
    final last = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(now.year - 20, 1, 1),
      firstDate: first,
      lastDate: last,
      helpText: '생년월일 선택',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: kPrimaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _birth = picked);
  }

  String _formatBirthForDisplay(DateTime? d) {
    if (d == null) return '';
    return '${d.year.toString().padLeft(4, '0')}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
  }

  String? _formatBirthForApi(DateTime? d) {
    if (d == null) return null;
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('약관에 동의해 주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final step1Response = await http.post(
        Uri.parse('$kApiBaseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _nameCtrl.text.trim(),
          'password': _passwordCtrl.text.trim(),
        }),
      );

      if (step1Response.statusCode == 200 || step1Response.statusCode == 201) {
        final responseData = jsonDecode(step1Response.body);
        final dynamic userId = responseData['result']['userId'];

        // --- 수정된 부분 시작 ---
        // SharedPreferences에 String으로 저장하기 위해 userId를 String으로 변환
        final String userIdString = userId.toString();
        print(userIdString); // 로그로 확인

        final step2Response = await http.post(
          Uri.parse('$kApiBaseUrl/signup/$userIdString'), // URL에 String으로 변환된 값 사용
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nickname': _nameCtrl.text.trim(),
            'email': _emailCtrl.text.trim(),
            'gender': _gender ?? '',
            'birth': _formatBirthForApi(_birth),
            'term': _agree,
          }),
        );
        // --- 수정된 부분 끝 ---

        if (step2Response.statusCode == 200 || step2Response.statusCode == 201) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', int.parse(userIdString)); // 수정: userIdString을 저장
          await prefs.setString('user_name', _nameCtrl.text.trim());
          await prefs.setString('user_email', _emailCtrl.text.trim());
          await prefs.setString('user_gender', _gender ?? '');
          await prefs.setString('user_birth', _formatBirth(_birth));
          await prefs.setBool('user_is_first', false);
          await prefs.setInt('user_point', prefs.getInt('user_point') ?? 0);
          await prefs.setStringList('user_coupons', []);

          await requestCameraPermission();

          if (!mounted) return;

          Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);

        } else {
          final errorData = jsonDecode(step2Response.body);
          final errorMessage = "aa${errorData['message'] ?? '추가 정보 등록에 실패했습니다. (1)'}";
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      } else {
        final errorData = jsonDecode(step1Response.body);
        final errorMessage = "bb${errorData['message'] ?? '아이디 생성에 실패했습니다. (예: 중복된 아이디) (101)'}";
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      print(e);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('오류가 발생했습니다. 잠시 후 다시 시도해주세요.')));
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
          '회원가입',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              // 이름
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
              const SizedBox(height: 20),

              // 이메일
              const Text('이메일', style: kSubBodyTextStyle),
              TextFormField(
                controller: _emailCtrl,
                decoration: _underlineInputDeco,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return '이메일을 입력해주세요.';
                  final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v);
                  return ok ? null : '올바른 이메일 형식이 아니에요.';
                },
              ),
              const SizedBox(height: 20),

              // 성별
              const Text('성별', style: kSubBodyTextStyle),
              DropdownButtonFormField<String>(
                value: _gender,
                items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _gender = v),
                decoration: _underlineInputDeco,
                hint: const Text('성별을 선택하세요'),
                validator: (v) => v == null ? '성별을 선택해주세요.' : null,
              ),
              const SizedBox(height: 20),

              // 생년월일
              const Text('생년월일', style: kSubBodyTextStyle),
              InkWell(
                onTap: _pickBirth,
                child: InputDecorator(
                  decoration: _underlineInputDeco,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _birth == null ? '생년월일을 선택하세요' : _formatBirthForDisplay(_birth),
                          style: TextStyle(
                            fontSize: 16,
                            color: _birth == null ? Colors.grey.shade600 : Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 동의
              const Text('정보동의 약관', style: kSubBodyTextStyle),
              Row(
                children: [
                  const Expanded(child: Text('계정 정보 동의')),
                  Checkbox(
                    value: _agree,
                    activeColor: kPrimaryColor,
                    onChanged: (v) => setState(() => _agree = v ?? false),
                  ),
                ],
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