import 'package:flutter/material.dart';

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

