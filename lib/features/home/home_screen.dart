import 'package:flutter/material.dart';
import 'package:team3/features/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // 탭별 화면을 나중에 이곳에 추가하면 됩니다.
  final List<Widget> _pages = [
    const Center(child: Text('메인 홈 (대시보드)')),
    const Center(child: Text('투자 내역')),
    const Center(child: Text('설정')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OASIS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0, // 그림자 제거 (깔끔한 느낌)
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context,
              MaterialPageRoute(builder: (_)=> const LoginScreen(),
              ),
            );
          },
            child: const Text(
              '로그인',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue, // 프로젝트 메인 컬러로 변경 가능
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: '투자',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}