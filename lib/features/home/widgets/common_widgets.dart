import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 앱바 아이콘 버튼
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.imagePath,
    this.onTap,
  });

  final String imagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap ?? () {},
          child: Center(
            child: Image.asset(
              imagePath,
              width: 28,
              height: 28,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 24, color: Colors.red);
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// 왕관 아이콘
class CrownIcon extends StatelessWidget {
  const CrownIcon({
    super.key,
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CrownPainter(color: color),
      ),
    );
  }
}

class CrownPainter extends CustomPainter {
  CrownPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24;

    final path = Path();
    path.moveTo(11.562 * scale, 3.266 * scale);
    path.arcToPoint(
      Offset(12.438 * scale, 3.266 * scale),
      radius: Radius.circular(0.5 * scale),
      clockwise: false,
    );
    path.lineTo(15.39 * scale, 8.87 * scale);
    path.arcToPoint(
      Offset(16.906 * scale, 9.164 * scale),
      radius: Radius.circular(1 * scale),
      clockwise: false,
    );
    path.lineTo(21.183 * scale, 5.5 * scale);
    path.arcToPoint(
      Offset(21.981 * scale, 6.019 * scale),
      radius: Radius.circular(0.5 * scale),
      clockwise: false,
    );
    path.lineTo(19.147 * scale, 16.265 * scale);
    path.arcToPoint(
      Offset(18.191 * scale, 16.999 * scale),
      radius: Radius.circular(1 * scale),
      clockwise: false,
    );
    path.lineTo(5.81 * scale, 16.999 * scale);
    path.arcToPoint(
      Offset(4.853 * scale, 16.265 * scale),
      radius: Radius.circular(1 * scale),
      clockwise: false,
    );
    path.lineTo(2.02 * scale, 6.02 * scale);
    path.arcToPoint(
      Offset(2.818 * scale, 5.501 * scale),
      radius: Radius.circular(0.5 * scale),
      clockwise: false,
    );
    path.lineTo(7.094 * scale, 9.165 * scale);
    path.arcToPoint(
      Offset(8.61 * scale, 8.871 * scale),
      radius: Radius.circular(1 * scale),
      clockwise: false,
    );
    path.close();

    final basePath = Path();
    basePath.moveTo(5 * scale, 21 * scale);
    basePath.lineTo(19 * scale, 21 * scale);

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
    canvas.drawPath(basePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 챗봇 플로팅 버튼
class ChatFab extends StatelessWidget {
  const ChatFab({
    super.key,
    required this.label,
    required this.onClose,
  });

  final String label;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              child: Image.asset(
                'assets/images/bot-message-square.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

