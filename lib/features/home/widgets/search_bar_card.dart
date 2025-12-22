import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../customized_fund_search_screen.dart';

class SearchBarCard extends StatelessWidget {
  const SearchBarCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryColor, width: 1.2),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  '펀드명, 키워드 입력',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: CustomPaint(
                  painter: SearchIconPainter(color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CustomizedFundSearchScreen(),
                ),
              );
            },
            icon: const SizedBox.shrink(),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '맞춤형 펀드검색',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.chevron_right, color: Colors.black54),
              ],
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
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

