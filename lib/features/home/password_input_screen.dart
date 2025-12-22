import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'investment_success_screen.dart';
import 'investment_confirmation_screen.dart';
import 'withdrawal_success_screen.dart';

class PasswordInputScreen extends StatefulWidget {
  const PasswordInputScreen({
    super.key,
    required this.amount,
    required this.accountName,
    required this.accountNumber,
    this.isWithdrawal = false,
  });

  final String amount;
  final String accountName;
  final String accountNumber;
  final bool isWithdrawal; // 출금인지 투자인지 구분

  static void show(BuildContext context, String amount, String accountName, String accountNumber, {bool isWithdrawal = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PasswordInputScreen(
        amount: amount,
        accountName: accountName,
        accountNumber: accountNumber,
        isWithdrawal: isWithdrawal,
      ),
    );
  }

  @override
  State<PasswordInputScreen> createState() => _PasswordInputScreenState();
}

class _PasswordInputScreenState extends State<PasswordInputScreen> {
  String _password = '';
  static const int _maxLength = 6;

  void _onNumberPressed(String number) {
    if (_password.length < _maxLength) {
      setState(() {
        _password += number;
      });
      
      // 6자리 입력 완료 시 자동으로 확인
      if (_password.length == _maxLength) {
        Future.delayed(const Duration(milliseconds: 200), () {
          // 비밀번호 입력 화면 닫기
          Navigator.of(context).pop();
          // 확인 화면 닫기
          Navigator.of(context).pop();
          
          // 출금인지 투자인지에 따라 다른 화면으로 이동
          if (widget.isWithdrawal) {
            // 출금 성공 화면으로 이동
            WithdrawalSuccessScreen.show(
              context,
              widget.amount,
              widget.accountName,
              widget.accountNumber,
            );
          } else {
            // 투자 성공 화면으로 이동
            InvestmentSuccessScreen.show(
              context,
              widget.amount,
              widget.accountName,
              widget.accountNumber,
            );
          }
        });
      }
    }
  }

  void _onDeletePressed() {
    if (_password.isNotEmpty) {
      setState(() {
        _password = _password.substring(0, _password.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        height: screenHeight * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 상단 헤더 (파란색 배경)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, size: 24),
                        color: Colors.white,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        '인증 비밀번호 6자리',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 48), // X 버튼과 균형 맞추기
                    ],
                  ),
                  const SizedBox(height: 48),
                  // PIN 인디케이터
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_maxLength, (index) {
                      final isFilled = index < _password.length;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled ? Colors.white : Colors.white.withOpacity(0.3),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            // 숫자 키패드
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1, 2, 3
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNumberButton('1'),
                        _buildNumberButton('2'),
                        _buildNumberButton('3'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 4, 5, 6
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNumberButton('4'),
                        _buildNumberButton('5'),
                        _buildNumberButton('6'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 7, 8, 9
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNumberButton('7'),
                        _buildNumberButton('8'),
                        _buildNumberButton('9'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 빈칸, 0, 백스페이스
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 70, height: 70), // 빈칸
                        _buildNumberButton('0'),
                        _buildActionButton(
                          icon: Icons.backspace_outlined,
                          onPressed: _onDeletePressed,
                        ),
                      ],
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

  Widget _buildNumberButton(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNumberPressed(number),
        borderRadius: BorderRadius.circular(35),
        child: Container(
          width: 70,
          height: 70,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade50,
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(35),
        child: Container(
          width: 70,
          height: 70,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 26,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

