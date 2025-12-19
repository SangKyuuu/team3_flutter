import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'menu_screen.dart';
import 'widgets/common_widgets.dart';
import 'widgets/home_main_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _pages = [
    const HomeMainContent(),
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
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        scrolledUnderElevation: 2,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        titleSpacing: 0,
        toolbarHeight: 56,
        title: Text(
          'OASIS',
          style: GoogleFonts.fredoka(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4FC3F7),
          ),
        ),
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: AppIconButton(imagePath: 'assets/images/user.png'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: AppIconButton(imagePath: 'assets/images/bell.png'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: AppIconButton(
              imagePath: 'assets/images/text-align-justify.png',
              onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      endDrawer: const MenuScreen(),
    );
  }
}
