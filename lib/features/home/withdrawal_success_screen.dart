import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'constants/app_colors.dart';
import 'investment_delay_info_screen.dart';
import 'withdrawal_cancel_screen.dart';

class WithdrawalSuccessScreen extends StatelessWidget {
  const WithdrawalSuccessScreen({
    super.key,
    required this.amount,
    required this.accountName,
    required this.accountNumber,
  });

  final String amount;
  final String accountName;
  final String accountNumber;

  static void show(BuildContext context, String amount, String accountName, String accountNumber) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => WithdrawalSuccessScreen(
          amount: amount,
          accountName: accountName,
          accountNumber: accountNumber,
        ),
      ),
    );
  }

  // 출금신청일 (오늘)
  String get _applicationDate {
    final date = DateTime.now();
    final year = date.year.toString().substring(2);
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }

  // 금액확정일 계산 (오늘로부터 1일 후)
  String get _confirmationDate {
    final date = DateTime.now().add(const Duration(days: 1));
    final year = date.year.toString().substring(2);
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day 예정';
  }

  // 출금완료일 계산 (오늘로부터 4일 후)
  String get _completionDate {
    final date = DateTime.now().add(const Duration(days: 4));
    final year = date.year.toString().substring(2);
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day 예정';
  }

  // 금액 포맷팅 (천 단위 콤마 추가)
  String _formatAmount(String amount) {
    final parsed = int.tryParse(amount);
    if (parsed == null) return amount;
    return parsed.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      '펀드 출금이\n4일 뒤에 완료돼요',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 진행 단계
                    Stack(
                      children: [
                        // 배경 선
                        Positioned(
                          left: 16,
                          top: 32,
                          bottom: 32,
                          child: Container(
                            width: 2,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ),
                        // 단계들
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1단계: 출금신청
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: CustomPaint(
                                    painter: CheckIconPainter(),
                                    size: const Size(32, 32),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  '출금신청',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _applicationDate,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            // 2단계: 금액확정
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '2',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  '금액확정',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _confirmationDate,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            // 3단계: 출금완료
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '3',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  '출금완료',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _completionDate,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 왜 시간이 걸리나요? 링크
                    Center(
                      child: InkWell(
                        onTap: () {
                          InvestmentDelayInfoScreen.show(context);
                        },
                        child: Text(
                          '왜 시간이 걸리나요?',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 24),
                    // 신청금액(예상)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '신청금액(예상)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${_formatAmount(amount)}원',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 입금계좌
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '입금계좌',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  accountName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  accountNumber,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 안내 문구
                    Text(
                      '일부 출금의 경우 신청금액에 대한 세금이 추가로 출금됩니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 출금 취소 버튼
                    OutlinedButton(
                      onPressed: () {
                        WithdrawalCancelScreen.show(context, amount);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        child: Text(
                          '출금 취소',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 확인 버튼 (하단 고정)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 체크 아이콘 커스텀 페인터
class CheckIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 체크 마크를 더 작게 그리기 위해 중앙에 배치하고 크기 조정
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final checkSize = size.width * 0.4; // 전체 크기의 40%로 축소
    
    final path = Path();
    
    // 체크 마크 경로 (중앙 기준)
    path.moveTo(centerX - checkSize * 0.4, centerY);
    path.lineTo(centerX - checkSize * 0.1, centerY + checkSize * 0.3);
    path.lineTo(centerX + checkSize * 0.4, centerY - checkSize * 0.3);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

