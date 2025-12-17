import 'package:flutter/material.dart';
import 'constants/app_colors.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WithdrawalScreen(),
    );
  }

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final TextEditingController _amountController = TextEditingController();
  final String _availableBalance = '958'; // 사용 가능한 잔액
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 키보드 자동 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onWithdrawAllPressed() {
    setState(() {
      _amountController.text = _availableBalance;
    });
  }

  bool get _canProceed {
    final amount = _amountController.text;
    if (amount.isEmpty) return false;
    final parsed = int.tryParse(amount);
    return parsed != null && parsed >= 100;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        height: screenHeight * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
        children: [
          // 메인 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '얼마를 출금할까요?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
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
                    const SizedBox(height: 40),
                    // 금액 입력 필드
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: TextField(
                            controller: _amountController,
                            focusNode: _focusNode,
                            keyboardType: const TextInputType.numberWithOptions(decimal: false),
                            textAlign: TextAlign.center,
                            autofocus: true,
                            style: TextStyle(
                              fontSize: _amountController.text.isEmpty ? 24 : 32,
                              fontWeight: FontWeight.w600,
                              color: _amountController.text.isEmpty ? Colors.grey.shade400 : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: '금액 입력',
                              hintStyle: TextStyle(
                                fontSize: 24,
                                color: Colors.grey.shade400,
                              ),
                              border: InputBorder.none,
                              suffixText: _amountController.text.isNotEmpty ? '원' : '',
                              suffixStyle: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 최소 출금 안내
                    Text(
                      '최소 100원부터 출금 할 수 있어요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // 모두 출금 옵션
                    InkWell(
                      onTap: _onWithdrawAllPressed,
                      child: Text(
                        '$_availableBalance원 모두 출금',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 다음 버튼
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canProceed ? () {
                    // 다음 단계로 이동
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canProceed ? AppColors.primaryColor : Colors.grey.shade300,
                    foregroundColor: _canProceed ? Colors.white : Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '다음',
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

