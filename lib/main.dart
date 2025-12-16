import 'package:flutter/material.dart';
import 'package:team3/features/splash/splash_screen.dart'; // 경로 주의

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4B8EC6)),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(), // 시작은 무조건 스플래시
    );
  }
}