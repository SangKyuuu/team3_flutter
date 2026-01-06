import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'password_input_screen.dart';

class WithdrawalConfirmationScreen extends StatefulWidget {
  const WithdrawalConfirmationScreen({
    super.key,
    required this.amount,
  });

  final String amount;

  static void show(
      BuildContext context,
      String amount,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WithdrawalConfirmationScreen(
        amount: amount,
      ),
    );
  }

  @override
  State<WithdrawalConfirmationScreen> createState() =>
      _WithdrawalConfirmationScreenState();
}

class _WithdrawalConfirmationScreenState
    extends State<WithdrawalConfirmationScreen> {

  late String _selectedAccount;
  late List<String> _accounts;

  @override
  void initState() {
    super.initState();

    _accounts = [
      '설유진의 통장 (5081)',
      '설유진의 통장 (1234)',
    ];

    _selectedAccount = _accounts.first;
  }

  // 금액확정일 (2일 후)
  String get _confirmationDate {
    final date = DateTime.now().add(const Duration(days: 2));
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  // 완료예정일 (5일 후)
  String get _completionDate {
    final date = DateTime.now().add(const Duration(days: 5));
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _formatAmount(String amount) {
    final parsed = int.tryParse(amount);
    if (parsed == null) return amount;
    return parsed.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      '${_formatAmount(widget.amount)}원 출금할게요',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                ],
              ),
            ),
            const Divider(),

            // 본문
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _row('입금계좌', DropdownButton<String>(
                      value: _selectedAccount,
                      underline: const SizedBox(),
                      items: _accounts.map((e) =>
                          DropdownMenuItem(value: e, child: Text(e))
                      ).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedAccount = v);
                        }
                      },
                    )),
                    const SizedBox(height: 20),
                    _row('금액확정일', Text(_confirmationDate)),
                    const SizedBox(height: 20),
                    _row('완료예정일', Text(_completionDate)),
                  ],
                ),
              ),
            ),

            // 확인 버튼
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final parts = _selectedAccount.split(' ');
                    final accountName = parts[0];
                    final accountNumber =
                    parts[1].replaceAll('(', '').replaceAll(')', '');

                    Navigator.pop(context);
                    PasswordInputScreen.show(
                      context,
                      widget.amount,
                      accountName,
                      accountNumber,
                      isWithdrawal: true,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('확인'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, Widget right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        right,
      ],
    );
  }
}
