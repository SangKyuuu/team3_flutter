import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../fund_management_screen.dart';

class PortfolioStatusCard extends StatelessWidget {
  const PortfolioStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: StatusItem(
              label: '보유',
              value: '1',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FundManagementScreen(),
                  ),
                );
              },
            ),
          ),
          const VerticalDividerThin(),
          const Expanded(
            child: StatusItem(label: '관심', value: '2'),
          ),
          const VerticalDividerThin(),
          const Expanded(
            child: InvestTendency(),
          ),
        ],
      ),
    );
  }
}

class StatusItem extends StatelessWidget {
  const StatusItem({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final widget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.grey.shade800,
            height: 1.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.primaryColor,
              height: 1.0,
            ),
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: widget,
      );
    }

    return widget;
  }
}

class InvestTendency extends StatelessWidget {
  const InvestTendency({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '투자성향',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black87,
            height: 1.0,
          ),
        ),
        const SizedBox(width: 8),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

