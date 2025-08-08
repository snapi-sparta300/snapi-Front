import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final List<String> _interests = [
    '일상/풍경',
    '맛집/카페',
    '쇼핑/패션',
    '교통/차량',
    '반려동물',
    '운동/건강'
  ];
  final Set<String> _selectedInterests = {};

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 설정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Snapi에서 사용할\n프로필을 설정해주세요.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: '닉네임',
                  hintText: '2자 이상 10자 이하로 입력',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '닉네임을 입력해주세요.';
                  }
                  if (value.length < 2) {
                    return '닉네임은 2자 이상이어야 합니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              const Text(
                '관심 분야 (1개 이상 선택)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _interests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedInterests.add(interest);
                        } else {
                          _selectedInterests.remove(interest);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () async{
                  if (_formKey.currentState!.validate()) {
                    if (_selectedInterests.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('관심 분야를 1개 이상 선택해주세요.')),
                      );
                      return;
                    }

                    // API를 통해 백엔드에 사용자 정보 저장 로직 추가
                    // 저장 성공 시 MainPage로 이동

                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    // 'is_first' 값을 false로 설정합니다.
                    await prefs.setBool('is_first', false);
                    await prefs.setString('user_name', _nicknameController.text);
                    await prefs.setStringList('user_interests', _selectedInterests.toList());
                    await prefs.setInt('user_point', 0);
                    // main_page로 이동하고 이전 라우트를 모두 제거합니다.
                    // Navigator.pushAndRemoveUntil을 사용하면 사용자가 뒤로 가기 버튼으로
                    // user_info_page로 돌아오는 것을 방지할 수 있습니다.
                    Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('저장하고 시작하기'),
              )
            ],
          ),
        ),
      ),
    );
  }
}