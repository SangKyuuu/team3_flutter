import 'package:flutter/material.dart';
import 'package:team3/features/splash/splash_screen.dart';

import 'features/home/home_screen.dart';
import 'features/mock_investment/screens/mock_account_create_screen.dart';
import 'features/mock_investment/screens/mock_dashboard_screen.dart'; // 경로 주의

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team3 Project',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FC3F7),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      //home: const SplashScreen(), // 시작은 무조건 스플래시
      initialRoute: '/', // 시작 경로를 명시적으로 지정.
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/mock/create': (context) => const MockAccountCreateScreen(), // 개설 화면
        '/mock/dashboard': (context) => const MockDashboardScreen(), // 대시보드 화면 추가!
      },
    );
  }
}