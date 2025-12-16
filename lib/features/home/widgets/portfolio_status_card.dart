import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PortfolioStatusCard extends StatelessWidget {
  const PortfolioStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Row(
        children: [
          StatusItem(label: '보유', value: '1'),
          VerticalDividerThin(),
          StatusItem(label: '관심', value: '2'),
          VerticalDividerThin(),
          InvestTendency(),
        ],
      ),
    );
  }
}

class StatusItem extends StatelessWidget {
  const StatusItem({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(width: 20),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class InvestTendency extends StatelessWidget {
  const InvestTendency({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '투자성향',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 6),
          ColorFiltered(
            colorFilter: ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
            child: Image.asset(
              'assets/images/file-chart-column-increasing.png',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.insert_chart_outlined, color: AppColors.primaryColor, size: 20);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VerticalDividerThin extends StatelessWidget {
  const VerticalDividerThin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}

