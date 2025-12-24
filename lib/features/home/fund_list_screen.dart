import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'models/fund_data.dart';
import 'widgets/fund_card.dart';
import 'widgets/category_tabs.dart';

class FundListScreen extends StatefulWidget {
  final String categoryTitle;
  final List<FundData> funds;

  const FundListScreen({
    super.key,
    required this.categoryTitle,
    required this.funds,
  });

  @override
  State<FundListScreen> createState() => _FundListScreenState();
}

class _FundListScreenState extends State<FundListScreen> {
  static const List<String> _categories = [
    '판매량 best',
    '수익률 best',
  ];

  late int _selectedCategoryIndex;

  @override
  void initState() {
    super.initState();
    // 초기 선택된 카테고리 인덱스 찾기
    // '신상품'이 전달되면 기본값으로 처리
    final categoryTitle = widget.categoryTitle == '신상품' 
        ? '판매량 best' 
        : widget.categoryTitle;
    _selectedCategoryIndex = _categories.indexOf(categoryTitle);
    if (_selectedCategoryIndex == -1) {
      _selectedCategoryIndex = 0; // 기본값
    }
  }

  // 카테고리별 전체 펀드 데이터 (메인 페이지 데이터 + 추가 데이터)
  static List<FundData> getAllFundsForCategory(String category) {
    switch (category) {
      case '판매량 best':
        return const [
          FundData(
            title: '신한 초단기채 증권투자신탁(채권)',
            rankLabel: '1위',
            badge: '낮은위험',
            badge2: '안정추구형이상 가입',
            yieldText: '3.2%',
          ),
          FundData(
            title: 'KB 국채안정형 펀드',
            rankLabel: '2위',
            badge: '낮은위험',
            badge2: '안정추구형이상 가입',
            yieldText: '2.8%',
          ),
          FundData(
            title: '하나 단기채권형 펀드',
            rankLabel: '3위',
            badge: '높은위험',
            badge2: '공격투자형만 가입',
            yieldText: '2.5%',
          ),
          FundData(
            title: 'NH-Amundi 단기채권 펀드',
            rankLabel: '4위',
            badge: '낮은위험',
            badge2: '안정추구형이상 가입',
            yieldText: '2.3%',
          ),
          FundData(
            title: '미래에셋 단기채권형 펀드',
            rankLabel: '5위',
            badge: '낮은위험',
            badge2: '안정추구형이상 가입',
            yieldText: '2.1%',
          ),
        ];
      case '수익률 best':
        return const [
          FundData(
            title: '미국 나스닥 100 주식형 펀드',
            rankLabel: '1위',
            badge: '높은위험',
            badge2: '공격투자형만 가입',
            yieldText: '5.8%',
          ),
          FundData(
            title: '글로벌 테크 주식형 펀드',
            rankLabel: '2위',
            badge: '높은위험',
            badge2: '공격투자형만 가입',
            yieldText: '5.2%',
          ),
          FundData(
            title: '중국 A주 혼합형 펀드',
            rankLabel: '3위',
            badge: '높은위험',
            badge2: '공격투자형만 가입',
            yieldText: '4.9%',
          ),
          FundData(
            title: 'KODEX 미국S&P500TR',
            rankLabel: '4위',
            badge: '높은위험',
            badge2: '공격투자형만 가입',
            yieldText: '4.7%',
          ),
          FundData(
            title: 'TIGER 미국나스닥100',
            rankLabel: '5위',
            badge: '높은위험',
            badge2: '공격투자형만 가입',
            yieldText: '4.5%',
          ),
        ];
      case '신상품':
        return const [
          FundData(
            title: 'KB ESG 리더스 펀드',
            rankLabel: '1위',
            badge: 'NEW',
            badge2: '안정추구형이상 가입',
            yieldText: '—',
          ),
          FundData(
            title: '신한 메타버스 테마 펀드',
            rankLabel: '2위',
            badge: 'NEW',
            badge2: '공격투자형만 가입',
            yieldText: '—',
          ),
          FundData(
            title: '하나 디지털 자산 펀드',
            rankLabel: '3위',
            badge: 'NEW',
            badge2: '공격투자형만 가입',
            yieldText: '—',
          ),
          FundData(
            title: '미래에셋 AI 테마 펀드',
            rankLabel: '4위',
            badge: 'NEW',
            badge2: '적극투자형이상 가입',
            yieldText: '—',
          ),
          FundData(
            title: 'NH-Amundi 바이오 헬스케어 펀드',
            rankLabel: '5위',
            badge: 'NEW',
            badge2: '적극투자형이상 가입',
            yieldText: '—',
          ),
        ];
      default:
        return [];
    }
  }

  void _onCategoryTap(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = _categories[_selectedCategoryIndex];
    final allFunds = getAllFundsForCategory(selectedCategory);
    final showRank = true; // 모든 카테고리가 순위를 표시

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '펀드 목록',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 카테고리 탭
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: CategoryTabs(
              categories: _categories,
              selectedIndex: _selectedCategoryIndex,
              onTap: _onCategoryTap,
            ),
          ),
          // 펀드 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allFunds.length,
              itemBuilder: (context, index) {
                final fund = allFunds[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FundCard(
                    title: fund.title,
                    subtitle: fund.subtitle,
                    rankLabel: showRank ? fund.rankLabel : '',
                    badge: fund.badge,
                    badge2: fund.badge2,
                    yieldText: fund.yieldText,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

