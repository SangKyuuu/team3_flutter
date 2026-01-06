import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'fund_detail_screen.dart';

class FundManagementScreen extends StatelessWidget {
  const FundManagementScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '펀드조회/관리',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 오늘의 평가금액
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '오늘의 평가금액',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '2,000원',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '0원(0.00%)',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 한국 대표 주식 펀드 카드
            _FundCard(
              flagIcon: '🇰🇷',
              title: '한국 대표 주식에 투자하기',
              fundName: '교보악사파워인덱스증권자투자신탁1호(주식)Ce',
              value: '1,000원',
              change: '0원(0.00%)',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FundDetailScreen(
                      title: '한국 대표 주식에 투자하기',
                      fundName: '교보악사파워인덱스증권자투자신탁1호(주식)Ce',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // 미국 공모주 펀드 카드
            _FundCard(
              flagIcon: '🇺🇸',
              title: '미국 공모주 쉽게 투자하기',
              fundName: '우리미국단기채공모주증권자투자신탁1호UH(채권혼)Ce',
              value: '1,000원',
              change: '0원(0.00%)',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FundDetailScreen(
                      title: '미국 공모주 쉽게 투자하기',
                      fundName: '우리미국단기채공모주증권자투자신탁1호UH(채권혼)Ce',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FundCard extends StatelessWidget {
  const _FundCard({
    required this.flagIcon,
    required this.title,
    required this.fundName,
    required this.value,
    required this.change,
    required this.onTap,
  });

  final String flagIcon;
  final String title;
  final String fundName;
  final String value;
  final String change;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    fundName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

