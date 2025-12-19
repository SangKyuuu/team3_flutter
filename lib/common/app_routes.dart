import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/mock_investment/screens/mock_account_create_screen.dart';
import '../features/mock_investment/screens/mock_dashboard_screen.dart';

class AppRoutes {
  // 라우트 이름 상수 정의
  static const String splash = '/';
  static const String home = '/home';
  static const String mockCreate = '/mock/create';
  static const String mockDashboard = '/mock/dashboard';

  // 라우트 맵 정의
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      home: (context) => const HomeScreen(),
      mockCreate: (context) => const MockAccountCreateScreen(),
      mockDashboard: (context) => const MockDashboardScreen(),
    };
  }
}