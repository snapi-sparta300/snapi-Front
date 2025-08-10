import 'package:flutter/material.dart';
import 'app_constants.dart';
import 'home_tab.dart';
import 'shop_tab.dart';
import 'profile_tab.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // 이 부분을 확인해주세요!
  static final List<Widget> _widgetOptions = <Widget>[
    HomeTab(),        // 0번 인덱스: 홈
    ShopTabPage(),    // 1번 인덱스: Snapi 쇼핑
    ProfileTabPage(), // 2번 인덱스: 프로필
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Snapi 쇼핑'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
