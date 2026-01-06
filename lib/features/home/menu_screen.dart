import 'package:flutter/material.dart';
import '../../common/app_routes.dart';
import '../../common/utils.dart';
import '../../data/service/mock_api.dart';
import '../../data/service/token_storage.dart';
import 'constants/app_colors.dart';
import 'personal_info_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  ///  로그아웃 처리
  Future<void> _logout() async {
    // 1. 토큰 삭제
    await TokenStorage.clearToken();

    if (!mounted) return;

    // 2. Drawer 닫기
    Navigator.of(context).pop();

    // 3. 로그인 화면으로 이동 (스택 초기화)
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
          (route) => false,
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

            // ===================== 상단 헤더 =====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
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

            // ===================== 사용자 정보 + 로그아웃 =====================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/user.png',
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(width: 12),

                  // 사용자 이름
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
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

                  // 🔥 로그아웃 버튼
                  InkWell(
                    onTap: _logout,
                    child: Row(
                      children: [
                        const Text(
                          '로그아웃',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ===================== 바로가기 =====================
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
                    _quickItem('assets/images/user-lock.png', '인증/보안'),
                    _divider(),
                    _quickItem('assets/images/bot-message-square.png', '챗봇'),
                    _divider(),
                    _quickItem(null, '전화상담', icon: Icons.phone),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===================== 메뉴 영역 =====================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildMockInvestmentEntry(context),
                    const SizedBox(height: 12),
                    _buildFundCard(),
                    const SizedBox(height: 12),
                    _buildSavingsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== 공통 위젯 =====================

  Widget _divider() => Container(
    width: 1,
    height: 40,
    color: Colors.grey.shade300,
  );

  Widget _quickItem(String? image, String label, {IconData? icon}) {
    return Expanded(
      child: Column(
        children: [
          image != null
              ? Image.asset(image, width: 24, height: 24)
              : Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFundCard() => _menuCard(
    title: '펀드',
    icon: Icons.trending_up,
    color: Colors.purple,
    items: ['펀드가입', '펀드관리'],
  );

  Widget _buildSavingsCard() => _menuCard(
    title: '예적금',
    icon: Icons.account_balance,
    color: Colors.lightBlue,
    items: ['예금 가입', '적금 가입'],
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
          Row(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 16),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(item),
            ),
        ],
      ),
    );
  }

  // ===================== 모의투자 =====================
  Widget _buildMockInvestmentEntry(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        AppUtils.showLoading(context);
        final hasAccount = await MockApi.checkHasAccount();
        if (!context.mounted) return;
        AppUtils.hideLoading(context);

        Navigator.pushNamed(
          context,
          hasAccount ? AppRoutes.mockDashboard : AppRoutes.mockCreate,
        );
      },
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
            Expanded(child: Text('AI 모의투자 시작하기')),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
