import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  final _genders = const ['남자', '여자', '선택 안함'];
  String? _gender;
  DateTime? _birth;
  bool _agree = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
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

  String _formatBirth(DateTime? d) {
    if (d == null) return '';
    return '${d.year.toString().padLeft(4, '0')}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
    // 예: 2006.03.11
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
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              const SizedBox(height: 4),
              const Text(
                'Snapi에서 사용할\n프로필을 설정하세요.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 28),

              // 이름
              const Text('이름', style: kSubBodyTextStyle),
              TextFormField(
                controller: _nameCtrl,
                decoration: _underlineInputDeco,
                validator: (v) => (v == null || v.trim().isEmpty) ? '이름을 입력해주세요.' : null,
              ),
              const SizedBox(height: 20),

              // 이메일
              const Text('이메일', style: kSubBodyTextStyle),
              TextFormField(
                controller: _emailCtrl,
                decoration: _underlineInputDeco,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return null; // 선택 입력
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
                          _birth == null ? '' : _formatBirth(_birth),
                          style: const TextStyle(fontSize: 16),
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
                  const Expanded(child: Text('동의?')),
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

      // 하단 고정 버튼
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                if (!_agree) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('약관에 동의해 주세요.')),
                  );
                  return;
                }

                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('is_first', false);
                await prefs.setString('user_name', _nameCtrl.text.trim());
                await prefs.setString('user_email', _emailCtrl.text.trim());
                await prefs.setString('user_gender', _gender ?? '');
                await prefs.setString('user_birth', _formatBirth(_birth));
                await prefs.setBool('user_agree', _agree);
                await prefs.setInt('user_point', prefs.getInt('user_point') ?? 0);

                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('저장하고 시작하기', style: kButtonTextStyle),
            ),
          ),
        ),
      ),
    );
  }
}
