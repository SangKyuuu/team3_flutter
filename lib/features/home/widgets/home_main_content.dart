import 'package:flutter/material.dart';
import '../models/fund_data.dart';
import '../constants/app_colors.dart';
import '../fund_list_screen.dart';
import 'hero_carousel.dart';
import 'portfolio_status_card.dart';
import 'search_bar_card.dart';
import 'category_tabs.dart';
import 'fund_card.dart';
import 'common_widgets.dart';

class HomeMainContent extends StatefulWidget {
  const HomeMainContent({super.key});

  @override
  State<HomeMainContent> createState() => _HomeMainContentState();
}

class _HomeMainContentState extends State<HomeMainContent> {
  final List<String> _categories = const [
    '판매량 best',
    '수익률 best',
    '신상품',
  ];

  final List<List<FundData>> _fundsByCategory = const [
    // 판매량 best
    [
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
    ],
    // 수익률 best
    [
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
    ],
    // 신상품
    [
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
    ],
  ];

  int _selectedCategory = 0;
  bool _showChatBot = true;

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
              selectedCategoryTitle: _categories[_selectedCategory],
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
    required this.selectedCategoryTitle,
  });

  final bool isWide;
  final List<String> categories;
  final int selectedCategory;
  final ValueChanged<int> onCategoryTap;
  final List<FundData> fundsList;
  final String selectedCategoryTitle;

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
        ...fundsList.map((fund) => Column(
              children: [
                FundCard(
                  title: fund.title,
                  subtitle: fund.subtitle,
                  rankLabel: selectedCategory == 2 ? '' : fund.rankLabel,
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
                foregroundColor: AppColors.primaryColor,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FundListScreen(
                      categoryTitle: selectedCategoryTitle,
                      funds: fundsList,
                    ),
                  ),
                );
              },
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

