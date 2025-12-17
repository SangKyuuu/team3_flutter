import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 폰트 패키지 임포트 필수
import 'package:team3/features/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 배경을 완전히 흰색보다는 아주 연한 크림색이나 블루 틴트로 하면 더 부드럽습니다.
      backgroundColor: const Color(0xFFFDFDFD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 이미지 (그림자 효과 추가로 입체감 주기)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4FC3F7).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 160, // 크기 살짝 키움
                height: 160,
              ),
            ),
            const SizedBox(height: 30),

            // 메인 타이틀 (귀여운 폰트 적용)
            Text(
              'OASIS',
              style: GoogleFonts.fredoka( // 둥글둥글한 Fredoka 폰트
                fontSize: 40,
                fontWeight: FontWeight.w600,
                // 기존 남색보다 밝고 산뜻한 '오션 블루' 또는 '민트' 계열 추천
                color: const Color(0xFF4FC3F7),
              ),
            ),
            const SizedBox(height: 12),

            // 서브 타이틀
            Text(
              'Open AI Smart Investment Service',
              style: GoogleFonts.nunito( // 가독성 좋고 부드러운 Nunito 폰트
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF90A4AE), // 너무 검지 않은 회색
                letterSpacing: 1.2, // 자간을 넓혀서 시원하게
              ),
            ),
          ],
        ),
      ),
    );
  }
}