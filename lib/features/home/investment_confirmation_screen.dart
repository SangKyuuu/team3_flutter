import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'password_input_screen.dart';
import 'investment_success_screen.dart';

class InvestmentConfirmationScreen extends StatefulWidget {
  const InvestmentConfirmationScreen({
    super.key,
    required this.amount,
  });

  final String amount;

  static void show(BuildContext context, String amount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvestmentConfirmationScreen(amount: amount),
    );
  }

  @override
  State<InvestmentConfirmationScreen> createState() => _InvestmentConfirmationScreenState();
}

class _InvestmentConfirmationScreenState extends State<InvestmentConfirmationScreen> {
  String _selectedAccount = '설유진의 통장 (5081)';
  final List<String> _accounts = [
    '설유진의 통장 (5081)',
    '설유진의 통장 (1234)',
  ];

  // 완료예정일 계산 (오늘로부터 3일 후)
  String get _completionDate {
    final date = DateTime.now().add(const Duration(days: 3));
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
        height: screenHeight * 0.4,
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
                      // 확인 화면만 닫고 투자 금액 입력 화면으로 돌아가기
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: Text(
                      '${_formatAmount(widget.amount)}원 투자할게요',
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
                      // 확인 화면만 닫고 투자 금액 입력 화면으로 돌아가기
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
            // 메인 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 출금계좌
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '출금계좌',
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
                      const SizedBox(height: 16),
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
                    ],
                  ),
                ),
              ),
            ),
            // 확인 버튼
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      
                      Navigator.of(context).pop(); // 확인 화면 닫기
                      PasswordInputScreen.show(
                        context,
                        widget.amount,
                        accountName,
                        accountNumber,
                      ); // 비밀번호 입력 화면 표시
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
}

