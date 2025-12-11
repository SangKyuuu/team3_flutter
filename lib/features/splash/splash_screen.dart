import 'dart:async'; // Timer 사용을 위해 추가
import 'package:flutter/material.dart';
import 'package:team3/features/home/home_screen.dart'; // HomeScreen import (경로 확인 필요)

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    // 2초 뒤에 메인 화면으로 이동
    Timer(const Duration(seconds: 2), () {
      // pushReplacement: 뒤로가기 했을 때 스플래시 화면으로 돌아오지 않도록 함
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 이미지 (기존 코드 유지)
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'OASIS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E), // 로고 색상에 맞춰 조정
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Open AI Smart Investment Service',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}