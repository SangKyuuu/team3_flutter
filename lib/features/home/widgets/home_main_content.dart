import 'package:flutter/material.dart';
import '../models/fund_data.dart';
import '../constants/app_colors.dart';
import 'hero_carousel.dart';
import 'portfolio_status_card.dart';
import 'search_bar_card.dart';
import 'category_tabs.dart';
import 'fund_card.dart';
import 'common_widgets.dart';
import '../../../data/service/fund_api.dart';

class HomeMainContent extends StatefulWidget {
  const HomeMainContent({super.key});

  @override
  State<HomeMainContent> createState() => _HomeMainContentState();
}

class _HomeMainContentState extends State<HomeMainContent> {
  final List<String> _categories = const [
    '판매량 best',
    '수익률 best',
  ];

  // 하드코딩된 데이터 대신 상태 변수로 변경
  List<List<FundData>> _fundsByCategory = [[], []];
  bool _isLoading = true;

  int _selectedCategory = 0;
  bool _showChatBot = true;

  @override
  void initState() {
    super.initState();
    _loadFunds();
  }

  Future<void> _loadFunds() async {
    setState(() => _isLoading = true);
    
    try {
      // 각 카테고리별로 개별 호출
      final salesFunds = await FundApi.getFundsByCategory('sales');
      final yieldFunds = await FundApi.getFundsByCategory('yield');
      
      setState(() {
        _fundsByCategory = [salesFunds, yieldFunds];
        _isLoading = false;
      });
    } catch (e) {
      print('펀드 로딩 오류: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onCategoryTap(int index) {
    setState(() => _selectedCategory = index);
  }

  void _onChatBotClose() {
    setState(() => _showChatBot = false);
  }

  @override
  Widget build(BuildContext context) {
    final funds = _fundsByCategory[_selectedCategory];
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 900;
            final Widget left = LeftColumn(
              isWide: isWide,
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategoryTap: _onCategoryTap,
              fundsList: funds,
              isLoading: _isLoading,
            );
            final Widget right = RightColumn(isWide: isWide);

            if (!isWide) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    left,
                    const SizedBox(height: 16),
                    right,
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 16),
                  SizedBox(width: 360, child: right),
                ],
              ),
            );
          },
        ),
        if (_showChatBot)
          Positioned(
            bottom: 40,
            right: 20,
            child: ChatFab(
              label: '챗봇',
              onClose: _onChatBotClose,
            ),
          ),
      ],
    );
  }
}

class LeftColumn extends StatelessWidget {
  const LeftColumn({
    super.key,
    required this.isWide,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryTap,
    required this.fundsList,
    this.isLoading = false,
  });

  final bool isWide;
  final List<String> categories;
  final int selectedCategory;
  final ValueChanged<int> onCategoryTap;
  final List<FundData> fundsList;
  final bool isLoading;

  static const double filterToCardSpacing = 20.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HeroCarousel(),
        const SizedBox(height: 24),
        const PortfolioStatusCard(),
        const SizedBox(height: 20),
        const SearchBarCard(),
        const SizedBox(height: 20),
        CategoryTabs(
          categories: categories,
          selectedIndex: selectedCategory,
          onTap: onCategoryTap,
        ),
        SizedBox(height: filterToCardSpacing),
        // 로딩 중일 때
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(child: CircularProgressIndicator()),
          )
        // 데이터가 없을 때
        else if (fundsList.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(child: Text('펀드 목록이 없습니다.')),
          )
        // 데이터 표시 (최대 3개만)
        else
          ...fundsList.take(3).map((fund) => Column(
                children: [
                  FundCard(
                    title: fund.title,
                    subtitle: fund.subtitle,
                    rankLabel: fund.rankLabel,
                    badge: fund.badge,
                    badge2: fund.badge2,
                    yieldText: fund.yieldText,
                  ),
                  const SizedBox(height: 12),
                ],
              )),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: Center(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {},
              child: const Text('더보기  >'),
            ),
          ),
        ),
      ],
    );
  }
}

class RightColumn extends StatelessWidget {
  const RightColumn({super.key, required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

