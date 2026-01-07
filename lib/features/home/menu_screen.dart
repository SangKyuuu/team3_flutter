import 'package:flutter/material.dart';
import 'package:team3/common/app_routes.dart';
import 'package:team3/common/utils.dart';
import 'package:team3/features/cs/cs_chatbot_screen.dart';
import 'package:team3/features/cs/cs_main_screen.dart';
import 'package:team3/data/service/mock_api.dart';
import 'package:team3/data/service/token_storage.dart';
import 'constants/app_colors.dart';
import 'personal_info_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  /* ===================== 로그아웃 ===================== */
  Future<void> _logout() async {
    await TokenStorage.clearToken();
    if (!mounted) return;

    Navigator.pop(context); // Drawer 닫기
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
          (_) => false,
    );
  }

  /* ===================== 모의투자 진입 ===================== */
  Future<void> _enterMockInvestment() async {
    AppUtils.showLoading(context);
    final hasAccount = await MockApi.checkHasAccount();
    if (!mounted) return;
    AppUtils.hideLoading(context);

    Navigator.pushNamed(
      context,
      hasAccount ? AppRoutes.mockDashboard : AppRoutes.mockCreate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      width: screenWidth,
      backgroundColor: const Color(0xFFF8F9FB),
      child: SafeArea(
        child: Column(
          children: [

            /* ===================== 헤더 ===================== */
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      '전체메뉴',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            /* ===================== 사용자 영역 ===================== */
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PersonalInfoScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        '설유진',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _logout,
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /* ===================== 바로가기 ===================== */
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _quickItem(Icons.lock, '인증/보안'),
                    _divider(),
                    _quickItem(Icons.smart_toy, '챗봇', onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CsChatbotScreen(),
                        ),
                      );
                    }),
                    _divider(),
                    _quickItem(Icons.headset_mic, '고객센터', onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CsMainScreen(),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /* ===================== 메뉴 영역 ===================== */
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    /* ===== AI 모의투자 ===== */
                    InkWell(
                      onTap: _enterMockInvestment,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.analytics_outlined),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'AI 모의투자 시작하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _menuCard(
                      title: '펀드',
                      icon: Icons.trending_up,
                      color: Colors.purple,
                      items: ['펀드가입', '펀드관리'],
                    ),

                    const SizedBox(height: 12),

                    _menuCard(
                      title: '예적금',
                      icon: Icons.account_balance,
                      color: Colors.lightBlue,
                      items: ['예금 가입', '적금 가입'],
                    ),

                    const SizedBox(height: 12),

                    _menuCard(
                      title: '고객지원',
                      icon: Icons.headset_mic,
                      color: Colors.green,
                      items: ['고객센터', 'FAQ'],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ===================== 공통 위젯 ===================== */

  Widget _quickItem(IconData icon, String label, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 40,
    color: Colors.grey.shade300,
  );

  Widget _menuCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(item),
            ),
        ],
      ),
    );
  }
}

/* ===================== 검색 아이콘 Painter ===================== */

class SearchIconPainter extends CustomPainter {
  SearchIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final scale = size.width / 24;

    canvas.drawCircle(
      Offset(11 * scale, 11 * scale),
      8 * scale,
      paint,
    );

    canvas.drawLine(
      Offset(16.66 * scale, 16.66 * scale),
      Offset(21 * scale, 21 * scale),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
