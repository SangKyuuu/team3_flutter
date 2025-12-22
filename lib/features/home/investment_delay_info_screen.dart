import 'package:flutter/material.dart';
import 'constants/app_colors.dart';

class InvestmentDelayInfoScreen extends StatelessWidget {
  const InvestmentDelayInfoScreen({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InvestmentDelayInfoScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
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
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '왜 시간이 걸리나요?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  color: Colors.black87,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),
          // 내용
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '펀드는 투자자를 모집하여 자산에 투자하는 상품이에요.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '하루 동안 (영업일 기준) 투자자를 모은 후 한 번에 펀드를 구성하는 자산에 투자가 진행되므로 주식과 달리 즉시 주문이 체결되지 않아요.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '펀드 신청을 하면 기준가 적용일에 펀드 가격이 먼저 결정되고 이후 며칠 뒤에 펀드 투자 또는 출금이 최종적으로 완료돼요.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

