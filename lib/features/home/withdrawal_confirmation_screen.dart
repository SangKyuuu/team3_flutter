import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'password_input_screen.dart';

class WithdrawalConfirmationScreen extends StatefulWidget {
  const WithdrawalConfirmationScreen({
    super.key,
    required this.amount,
  });

  final String amount;

  static void show(BuildContext context, String amount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WithdrawalConfirmationScreen(amount: amount),
    );
  }

  @override
  State<WithdrawalConfirmationScreen> createState() => _WithdrawalConfirmationScreenState();
}

class _WithdrawalConfirmationScreenState extends State<WithdrawalConfirmationScreen> {
  String _selectedAccount = '설유진의 통장 (5081)';
  final List<String> _accounts = [
    '설유진의 통장 (5081)',
    '설유진의 통장 (1234)',
  ];

  // 금액확정일 계산 (오늘로부터 2일 후)
  String get _confirmationDate {
    final date = DateTime.now().add(const Duration(days: 2));
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }

  // 완료예정일 계산 (오늘로부터 5일 후)
  String get _completionDate {
    final date = DateTime.now().add(const Duration(days: 5));
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
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
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        height: screenHeight * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    color: Colors.black87,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: Text(
                      '${_formatAmount(widget.amount)}원 출금할게요',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 메인 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 입금계좌
                      Row(
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
                              child: DropdownButton<String>(
                                value: _selectedAccount,
                                underline: Container(),
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                items: _accounts.map((String account) {
                                  return DropdownMenuItem<String>(
                                    value: account,
                                    child: Text(account),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedAccount = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // 과세대상이익
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '과세대상이익',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const Text(
                            '0원',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // 예상세금
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '예상세금',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const Text(
                            '0원',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // 금액확정일
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '금액확정일',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _confirmationDate,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // 완료예정일
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '완료예정일',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _completionDate,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // 안내 사항
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoItem('일부 출금 시 신청 금액에 대한 세금이 추가로 출금됩니다.'),
                          const SizedBox(height: 12),
                          _buildInfoItem('전액 출금 시 금액확정일 기준 잔액 전액이 출금되며, 세금 공제 후 금액이 지급됩니다.'),
                          const SizedBox(height: 12),
                          _buildInfoItem('투자규칙에 따라 실행된 금액도 함께 출금될 수 있습니다.'),
                          const SizedBox(height: 12),
                          _buildInfoItem('최종 출금금액은 금액확정일에 결정되며, 기준가 변동, 세금 등으로 신청금액보다 적게 지급될 수 있습니다.'),
                          const SizedBox(height: 12),
                          _buildInfoItem('기준시간 이후 거래 시 금액확정일과 완료예정일이 변경될 수 있습니다.'),
                          const SizedBox(height: 12),
                          _buildInfoItem('과세대상이익은 종합소득세에 포함되며, 건강보험료 산정에 영향을 줄 수 있습니다.'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 확인 버튼
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // 계좌 정보 파싱
                      final accountParts = _selectedAccount.split(' ');
                      final accountName = accountParts.isNotEmpty ? accountParts[0] : '설유진의 통장';
                      final accountNumber = accountParts.length > 1 
                          ? accountParts[1].replaceAll('(', '').replaceAll(')', '')
                          : '3333-26-8285081';
                      
                      Navigator.of(context).pop(); // 출금 확인 화면 닫기
                      PasswordInputScreen.show(
                        context,
                        widget.amount,
                        accountName,
                        accountNumber,
                        isWithdrawal: true, // 출금임을 표시
                      ); // 비밀번호 입력 화면 표시
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
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6, right: 8),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade600,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

