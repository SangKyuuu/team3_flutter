import 'package:flutter/material.dart';
import '../../home/constants/app_colors.dart';

/// 전자서명용 비밀번호 입력 다이얼로그 (커스텀 숫자패드)
class PasswordInputDialog extends StatefulWidget {
  final String title;
  final String description;
  final Function(String password) onConfirm;
  final VoidCallback? onCancel;

  const PasswordInputDialog({
    super.key,
    this.title = '전자서명',
    this.description = '가입을 완료하려면 비밀번호를 입력해주세요.',
    required this.onConfirm,
    this.onCancel,
  });

  @override
  State<PasswordInputDialog> createState() => _PasswordInputDialogState();
}

class _PasswordInputDialogState extends State<PasswordInputDialog> {
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
          widget.onConfirm(_password);
          Navigator.pop(context);
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

  void _onClearPressed() {
    setState(() {
      _password = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            // 제목
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            // 설명
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            // PIN 입력 표시
            _buildPinDisplay(),
            const SizedBox(height: 28),
            // 숫자 패드
            _buildNumberPad(),
            const SizedBox(height: 16),
            // 취소 버튼
            TextButton(
              onPressed: () {
                widget.onCancel?.call();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade500,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_maxLength, (index) {
        final isFilled = index < _password.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppColors.primaryColor : Colors.transparent,
            border: Border.all(
              color: isFilled ? AppColors.primaryColor : Colors.grey.shade300,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumberPad() {
    return Column(
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
        const SizedBox(height: 12),
        // 4, 5, 6
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('4'),
            _buildNumberButton('5'),
            _buildNumberButton('6'),
          ],
        ),
        const SizedBox(height: 12),
        // 7, 8, 9
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('7'),
            _buildNumberButton('8'),
            _buildNumberButton('9'),
          ],
        ),
        const SizedBox(height: 12),
        // 전체삭제, 0, 삭제
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.refresh_rounded,
              onPressed: _onClearPressed,
            ),
            _buildNumberButton('0'),
            _buildActionButton(
              icon: Icons.backspace_outlined,
              onPressed: _onDeletePressed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNumberPressed(number),
        borderRadius: BorderRadius.circular(40),
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
        borderRadius: BorderRadius.circular(40),
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

/// 전자서명 비밀번호 입력 다이얼로그 표시
Future<String?> showPasswordInputDialog({
  required BuildContext context,
  String title = '전자서명',
  String description = '가입을 완료하려면 비밀번호를 입력해주세요.',
}) async {
  String? result;
  
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PasswordInputDialog(
      title: title,
      description: description,
      onConfirm: (password) {
        result = password;
      },
    ),
  );
  
  return result;
}
