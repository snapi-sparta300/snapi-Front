import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();

}

class _ProfileTabState extends State<ProfileTab> {
  late SharedPreferences _prefs;
  String? _user_name;
  List<String>? _user_interests;
  int? _user_point;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _user_name = _prefs.getString('user_name');
      _user_interests = _prefs.getStringList('user_interests');
      _user_point = _prefs.getInt("user_point");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
      ),
      body: ListView(
        children: [
          // 프로필 정보 섹션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _user_name == null ?
                    CircularProgressIndicator() :
                    Text(
                        _user_name.toString(),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 4),
                    Text('test@snapi.com', style: kSubBodyTextStyle),
                  ],
                ),
                const Spacer(),
                OutlinedButton(onPressed: () {}, child: const Text('수정')),
              ],
            ),
          ),
          const Divider(thickness: 8, color: kBackgroundColor),
          // 설정 메뉴
          _buildSectionTitle('설정 메뉴'),
          _buildMenuTile(Icons.notifications_none, '알림 설정', () {}),
          _buildMenuTile(Icons.settings_outlined, '앱 설정', () {}),
          const Divider(thickness: 8, color: kBackgroundColor),
          // 고객 지원 및 정보
          _buildSectionTitle('고객 지원 및 정보'),
          _buildMenuTile(Icons.support_agent_outlined, '고객센터', () {}),
          _buildMenuTile(Icons.campaign_outlined, '공지사항', () {}),
          _buildMenuTile(Icons.description_outlined, '이용 약관 및 개인정보 처리방침', () {}),
          const Divider(),
          // 로그아웃
          ListTile(
            title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            onTap: () {
              // 로그아웃 확인 다이얼로그 표시 후 로그아웃 처리
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('로그아웃'),
                    content: const Text('정말 로그아웃 하시겠습니까?'),
                    actions: [
                      TextButton(
                        child: const Text('취소'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('로그아웃', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          // 로그아웃 로직 실행
                          Navigator.of(context).pop();
                          // 로그인 페이지로 이동
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // 메뉴 섹션 타이틀 위젯
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  // 메뉴 리스트 타일 위젯
  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: kSubTextColor),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}