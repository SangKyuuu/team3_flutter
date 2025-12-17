import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'common_widgets.dart';
import '../../fund_detail/fund_detail_screen.dart';
import '../../subscription/fund_subscription_screen.dart';
import '../../investment_propensity/investment_propensity_screen.dart';
import '../../terms_agreement/terms_agreement_screen.dart';

class FundCard extends StatelessWidget {
  const FundCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.rankLabel,
    required this.badge,
    this.badge2,
    required this.yieldText,
  });

  final String title;
  final String? subtitle;
  final String rankLabel;
  final String badge;
  final String? badge2;
  final String yieldText;

  factory FundCard.placeholder() {
    return const FundCard(
      title: '',
      rankLabel: '',
      badge: '',
      yieldText: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (rankLabel.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CrownIcon(
                        color: rankLabel == '1위'
                            ? Colors.amber
                            : rankLabel == '2위'
                                ? AppColors.silver
                                : AppColors.bronze,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rankLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11,
                    color: badge == '높은위험' ? Colors.red : AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (badge2 != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge2!,
                    style: TextStyle(
                      fontSize: 11,
                      color: badge == '높은위험' ? Colors.red : AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // 상품명 클릭 시 상세 화면으로 이동
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FundDetailScreen(
                    title: title,
                    subtitle: subtitle,
                    badge: badge,
                    yieldText: yieldText,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '3개월 수익률',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_up, color: Colors.red, size: 18),
                  Text(
                    yieldText,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    // 1단계: 투자성향 조사
                    final propensityResult = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InvestmentPropensityScreen(
                          fundTitle: title,
                          badge: badge,
                          yieldText: yieldText,
                        ),
                      ),
                    );
                    
                    // 투자성향 조사 완료 후 약관 동의 화면으로 이동
                    if (propensityResult != null && context.mounted) {
                      // 2단계: 약관 동의
                      final termsResult = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TermsAgreementScreen(
                            fundTitle: title,
                            badge: badge,
                            yieldText: yieldText,
                          ),
                        ),
                      );
                      
                      // 약관 동의 완료 후 펀드 가입 화면으로 이동
                      if (termsResult == true && context.mounted) {
                        // 3단계: 펀드 가입
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FundSubscriptionScreen(
                              fundTitle: title,
                              badge: badge,
                              yieldText: yieldText,
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '가입',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right, color: Colors.black87, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

