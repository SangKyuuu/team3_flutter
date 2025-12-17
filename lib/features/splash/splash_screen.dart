import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:team3/features/auth/login_screen.dart';
import 'package:team3/features/home/home_screen.dart';
import 'package:team3/data/service/token_storage.dart';
import 'package:team3/data/service/auth_api.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // 스플래시 연출용 딜레이 (UX)
    await Future.delayed(const Duration(seconds: 2));

    final token = await TokenStorage.getToken();

    if (token == null) {
      _goLogin();
      return;
    }

    try {
      // 🔐 JWT 유효성 서버 검증
      await AuthApi.me();

      if (!mounted) return;
      _goHome();
    } catch (e) {
      // ❌ 토큰 만료 / 위조
      await TokenStorage.clear();
      _goLogin();
    }
  }

  void _goLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                width: 160,
                height: 160,
              ),
            ),
            const SizedBox(height: 30),

            Text(
              'OASIS',
              style: GoogleFonts.fredoka(
                fontSize: 40,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4FC3F7),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Open AI Smart Investment Service',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF90A4AE),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
