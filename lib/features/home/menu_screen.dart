import 'package:flutter/material.dart';
import '../../common/app_routes.dart';
import '../../common/utils.dart';
import '../../data/service/mock_api.dart';
import 'constants/app_colors.dart';
import 'personal_info_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Drawer(
      width: screenWidth,
      backgroundColor: const Color(0xFFF8F9FB),
      child: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // 설정 버튼 제거를 위해 빈 공간 추가 (중앙 정렬 유지)
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // 사용자 정보 섹션
            Container(
              color: const Color(0xFFF8F9FB),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/user.png',
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        color: Colors.black87,
                        size: 40,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PersonalInfoScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        '설유진',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '로그아웃',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
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
            const SizedBox(height: 10),
            // 바로가기 바
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
                    Expanded(
                      child: _buildQuickAccessItem(
                        imagePath: 'assets/images/user-lock.png',
                        label: '인증/보안',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _buildQuickAccessItem(
                        imagePath: 'assets/images/bot-message-square.png',
                        label: '챗봇',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _buildQuickAccessItem(
                        icon: Icons.phone,
                        label: '전화상담',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 검색 바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CustomPaint(
                            painter: SearchIconPainter(color: Colors.black87),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            '궁금한 것을 검색해 보세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 1),
                    height: 1,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
            // 메뉴 카드 영역
            Expanded(
              child: Container(
                color: const Color(0xFFF8F9FB),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 모의투자 진입 배너를 보이게 추가
                      _buildMockInvestmentEntry(context),

                      const SizedBox(height: 12),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildFundCard(),
                            const SizedBox(height: 12),
                            _buildSavingsCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundCard() {
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
                    Icon(
                      Icons.trending_up,
                      color: Colors.purple.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '펀드',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16, bottom: 16),
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                _buildMenuItem('펀드가입', Icons.add),
                const SizedBox(height: 12),
                _buildMenuItem('펀드관리', Icons.add),
        ],
      ),
    );
  }

  Widget _buildSavingsCard() {
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
                    Icon(
                      Icons.account_balance,
                      color: const Color(0xFF4FC3F7),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '예적금',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16, bottom: 16),
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                _buildMenuItem('예금 가입', Icons.add),
                const SizedBox(height: 12),
                _buildMenuItem('적금 가입', Icons.add),
        ],
      ),
    );
  }

  Widget _buildCustomerSupportCard() {
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
              Icon(
                Icons.headset_mic,
                color: Colors.green.shade400,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '고객지원',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMenuItem('고객센터', Icons.add),
          const SizedBox(height: 12),
          _buildMenuItem('FAQ', Icons.add),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon) {
    return InkWell(
      onTap: () {
        // 메뉴 항목 클릭 처리
      },
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(
            icon,
            color: Colors.grey.shade600,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessItem({
    IconData? icon,
    String? imagePath,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {
        // 기본 클릭 처리
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          imagePath != null
              ? Image.asset(
                  imagePath,
                  width: 24,
                  height: 24,
                  color: Colors.black87,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      icon ?? Icons.error,
                      color: Colors.black87,
                      size: 24,
                    );
                  },
                )
              : Icon(
                  icon ?? Icons.error,
                  color: Colors.black87,
                  size: 24,
                ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockInvestmentEntry(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          // 1. 로딩 시작
          AppUtils.showLoading(context);

          // 2. 계좌 여부 확인 API 호출
          bool hasAccount = await MockApi.checkHasAccount();

          // 3. 로딩 종료 (context가 유효한지 확인)
          if (!context.mounted) return;
          AppUtils.hideLoading(context);

          // 4. 결과에 따른 화면 이동
          if (hasAccount) {
            Navigator.pushNamed(context, AppRoutes.mockDashboard);
          } else {
            Navigator.pushNamed(context, AppRoutes.mockCreate);
          }
        } catch (e) {
          // 5. 예외 발생 시 처리
          if (context.mounted) {
            AppUtils.hideLoading(context);
            AppUtils.showError(context, '서버 통신 중 오류가 발생했습니다. 다시 시도해주세요.');
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.analytics_outlined, color: AppColors.primaryColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'AI 모의투자 시작하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '가상 자산으로 투자 실력을 쌓아보세요',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class SearchIconPainter extends CustomPainter {
  SearchIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // SVG viewBox는 0 0 24 24이므로 스케일 계산
    final scale = size.width / 24;
    final offsetX = 0.0;
    final offsetY = 0.0;

    // 원 그리기 (cx="11" cy="11" r="8")
    canvas.drawCircle(
      Offset(11 * scale + offsetX, 11 * scale + offsetY),
      8 * scale,
      paint,
    );

    // 선 그리기 (m21 21-4.34-4.34)
    final path = Path();
    path.moveTo(21 * scale + offsetX, 21 * scale + offsetY);
    path.lineTo(
      (21 - 4.34) * scale + offsetX,
      (21 - 4.34) * scale + offsetY,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

