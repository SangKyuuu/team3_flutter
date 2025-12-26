import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'common_widgets.dart';
import '../../fund_detail/fund_detail_screen.dart';
import '../../subscription/fund_subscription_screen.dart';
import '../../investment_propensity/investment_propensity_screen.dart';
import '../../terms_agreement/terms_agreement_screen.dart';

class FundCard extends StatefulWidget {
  const FundCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.rankLabel,
    required this.badge,
    this.badge2,
    required this.yieldText,
    this.showDetailedView = false, // 더보기 화면에서만 true
  });

  final String title;
  final String? subtitle;
  final String rankLabel;
  final String badge;
  final String? badge2;
  final String yieldText;
  final bool showDetailedView; // 하트 아이콘과 1,3,6,12개월 수익률 표시 여부

  factory FundCard.placeholder() {
    return const FundCard(
      title: '',
      rankLabel: '',
      badge: '',
      yieldText: '',
    );
  }

  @override
  State<FundCard> createState() => _FundCardState();
}

class _FundCardState extends State<FundCard> {
  bool _isFavorite = false; // 관심상품 여부

  // 샘플 수익률 데이터 (1, 3, 6, 12개월)
  // TODO: 나중에 실제 API에서 받아온 데이터로 교체
  Map<String, String> get _yieldData {
    // yieldText를 기반으로 샘플 데이터 생성
    final baseYield = double.tryParse(widget.yieldText.replaceAll('%', '')) ?? 0.0;
    return {
      '1개월': (baseYield * 0.6).toStringAsFixed(2),
      '3개월': baseYield.toStringAsFixed(2),
      '6개월': (baseYield * 2.3).toStringAsFixed(2),
      '12개월': (baseYield * 5.4).toStringAsFixed(2),
    };
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
              Expanded(
                child: Row(
                  children: [
                    if (widget.rankLabel.isNotEmpty) ...[
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
                              color: widget.rankLabel == '1위'
                                  ? Colors.amber
                                  : widget.rankLabel == '2위'
                                      ? AppColors.silver
                                      : AppColors.bronze,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.rankLabel,
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
                        widget.badge,
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.badge == '높은위험' ? Colors.red : AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (widget.badge2 != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.badge2!,
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.badge == '높은위험' ? Colors.red : AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 하트 아이콘 (더보기 화면에서만 표시)
              if (widget.showDetailedView)
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.grey.shade600,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    // TODO: 나중에 실제 API 호출로 관심상품 추가/제거
                    // if (_isFavorite) {
                    //   // 관심상품 추가 API 호출
                    // } else {
                    //   // 관심상품 제거 API 호출
                    // }
                  },
                ),
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
                    title: widget.title,
                    subtitle: widget.subtitle,
                    badge: widget.badge,
                    yieldText: widget.yieldText,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // 수익률 표시 (더보기 화면: 1,3,6,12개월 / 메인 화면: 3개월만)
          widget.showDetailedView
              ? _buildYieldTable()
              : _buildSimpleYield(),
          // 가입 버튼 (메인 화면에서만 표시)
          if (!widget.showDetailedView) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // 1단계: 투자성향 조사 (각 화면에서 다음 화면으로 직접 push)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InvestmentPropensityScreen(
                        fundTitle: widget.title,
                        badge: widget.badge,
                        yieldText: widget.yieldText,
                      ),
                    ),
                  );
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
        ],
      ),
    );
  }

  Widget _buildYieldTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildYieldCell('1개월', _yieldData['1개월']!),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _buildYieldCell('3개월', _yieldData['3개월']!),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _buildYieldCell('6개월', _yieldData['6개월']!),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _buildYieldCell('12개월', _yieldData['12개월']!),
          ),
        ],
      ),
    );
  }

  Widget _buildYieldCell(String period, String yield, {bool isHighlight = false}) {
    final isThreeMonth = period == '3개월';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.transparent,
      child: Column(
        children: [
          Text(
            period,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$yield%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isThreeMonth ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // 메인 화면용 간단한 수익률 표시 (3개월만)
  Widget _buildSimpleYield() {
    return Row(
      children: [
        const Text(
          '3개월 수익률',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_drop_up, color: Colors.red, size: 18),
        Text(
          widget.yieldText,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

