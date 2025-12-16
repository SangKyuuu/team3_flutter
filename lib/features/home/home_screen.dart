import 'dart:async';
import 'package:flutter/material.dart';
import 'package:team3/features/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _primaryColor = Color(0xFF4B8EC6);
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    const _HomeMainContent(),
    const Center(child: Text('투자 내역')),
    const Center(child: Text('설정')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        scrolledUnderElevation: 2,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        titleSpacing: 0,
        toolbarHeight: 56,
        title: const Text(
          'OASIS',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _primaryColor,
            letterSpacing: 0.5,
          ),
        ),
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: _IconButton(imagePath: 'assets/images/user.png'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: _IconButton(imagePath: 'assets/images/bell.png'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: _IconButton(imagePath: 'assets/images/text-align-justify.png'),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
    );
  }
}

class _HomeMainContent extends StatefulWidget {
  const _HomeMainContent({super.key});

  @override
  State<_HomeMainContent> createState() => _HomeMainContentState();
}

class _HomeMainContentState extends State<_HomeMainContent> {
  static const Color primaryColor = Color(0xFF4B8EC6);
  static const double corner = 14;

  final List<String> _categories = const [
    '판매량 best',
    '수익률 best',
    '추천펀드',
    '신상품',
  ];

  final List<List<_FundData>> _fundsByCategory = const [
    // 판매량 best
    [
      _FundData(
        title: '신한 초단기채 증권투자신탁(채권)',
        rankLabel: '1위',
        badge: '낮은위험',
        badge2: '안정추구형이상 가입',
        yieldText: '3.2%',
      ),
      _FundData(
        title: 'KB 국채안정형 펀드',
        rankLabel: '2위',
        badge: '낮은위험',
        badge2: '안정추구형이상 가입',
        yieldText: '2.8%',
      ),
      _FundData(
        title: '하나 단기채권형 펀드',
        rankLabel: '3위',
        badge: '높은위험',
        badge2: '공격투자형만 가입',
        yieldText: '2.5%',
      ),
    ],
    // 수익률 best
    [
      _FundData(
        title: '미국 나스닥 100 주식형 펀드',
        rankLabel: '1위',
        badge: '높은위험',
        badge2: '공격투자형만 가입',
        yieldText: '5.8%',
      ),
      _FundData(
        title: '글로벌 테크 주식형 펀드',
        rankLabel: '2위',
        badge: '높은위험',
        badge2: '공격투자형만 가입',
        yieldText: '5.2%',
      ),
      _FundData(
        title: '중국 A주 혼합형 펀드',
        rankLabel: '3위',
        badge: '높은위험',
        badge2: '공격투자형만 가입',
        yieldText: '4.9%',
      ),
    ],
    // 추천펀드
    [
      _FundData(
        title: 'KB 밸런스 혼합형 펀드',
        rankLabel: '1위',
        badge: '추천',
        badge2: '안정추구형이상 가입',
        yieldText: '2.1%',
      ),
      _FundData(
        title: '신한 글로벌 리밸런싱 펀드',
        rankLabel: '2위',
        badge: '추천',
        badge2: '안정투구형만 가입',
        yieldText: '1.9%',
      ),
      _FundData(
        title: '하나 다자산 배분형 펀드',
        rankLabel: '3위',
        badge: '추천',
        badge2: '안정추구형이상 가입',
        yieldText: '1.7%',
      ),
    ],
    // 신상품
    [
      _FundData(
        title: 'KB ESG 리더스 펀드',
        rankLabel: '1위',
        badge: 'NEW',
        badge2: '안정추구형이상 가입',
        yieldText: '—',
      ),
      _FundData(
        title: '신한 메타버스 테마 펀드',
        rankLabel: '2위',
        badge: 'NEW',
        badge2: '공격투자형만 가입',
        yieldText: '—',
      ),
      _FundData(
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
            final Widget left = _LeftColumn(
              isWide: isWide,
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategoryTap: _onCategoryTap,
              fundsList: funds,
            );
            final Widget right = _RightColumn(isWide: isWide);

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
            child: _ChatFab(
              label: '챗봇',
              onClose: _onChatBotClose,
            ),
          ),
      ],
    );
  }
}

class _LeftColumn extends StatelessWidget {
  const _LeftColumn({
    super.key,
    required this.isWide,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryTap,
    required this.fundsList,
  });

  final bool isWide;
  final List<String> categories;
  final int selectedCategory;
  final ValueChanged<int> onCategoryTap;
  final List<_FundData> fundsList;

  static const Color primaryColor = Color(0xFF4B8EC6);
  static const double corner = 14;
  static const double filterToCardSpacing = 20.0; // 필터 탭과 첫 번째 카드 사이 고정 간격

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _HeroCarousel(),
        const SizedBox(height: 24),
        const _PortfolioStatusCard(),
        const SizedBox(height: 20),
        const _SearchBarCard(),
        const SizedBox(height: 20),
        _CategoryTabs(
          categories: categories,
          selectedIndex: selectedCategory,
          onTap: onCategoryTap,
        ),
        SizedBox(height: filterToCardSpacing),
        ...fundsList.map((fund) => Column(
              children: [
                _FundCard(
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
                foregroundColor: primaryColor,
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

class _RightColumn extends StatelessWidget {
  const _RightColumn({super.key, required this.isWide});

  final bool isWide;

  static const Color primaryColor = Color(0xFF4B8EC6);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _RoundedBox extends StatelessWidget {
  const _RoundedBox({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({super.key, required this.imagePath});

  final String imagePath;

  static const Color primaryColor = Color(0xFF4B8EC6);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {},
          child: Center(
            child: Image.asset(
              imagePath,
              width: 28,
              height: 28,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 24, color: Colors.red);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel({super.key});

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final PageController _controller = PageController();
  final List<String> _labels = const ['이미지 1', '이미지 2', '이미지 3'];
  int _current = 0;
  Timer? _timer;

  static const Color primaryColor = Color(0xFF4B8EC6);

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_controller.hasClients) {
        final nextPage = (_current + 1) % _labels.length;
        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _controller,
              itemCount: _labels.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (context, index) {
                return Image.asset(
                  'assets/images/치이카와1.webp',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: primaryColor.withOpacity(0.85),
                      child: Center(
                        child: Text(
                          _labels[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _labels.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _current == i ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _current == i
                    ? primaryColor
                    : primaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PortfolioStatusCard extends StatelessWidget {
  const _PortfolioStatusCard({super.key});

  static const Color primaryColor = Color(0xFF4B8EC6);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: const [
          _StatusItem(label: '보유', value: '1'),
          _VerticalDividerThin(),
          _StatusItem(label: '관심', value: '2'),
          _VerticalDividerThin(),
          _InvestTendency(),
        ],
      ),
    );
  }
}

class _InvestTendency extends StatelessWidget {
  const _InvestTendency({super.key});

  static const Color primaryColor = Color(0xFF4B8EC6);

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
            colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
            child: Image.asset(
              'assets/images/file-chart-column-increasing.png',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.insert_chart_outlined, color: primaryColor, size: 20);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({super.key, required this.label, required this.value});

  final String label;
  final String value;

  static const Color primaryColor = Color(0xFF4B8EC6);

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
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDividerThin extends StatelessWidget {
  const _VerticalDividerThin({super.key});

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

class _SearchBarCard extends StatelessWidget {
  const _SearchBarCard({super.key});

  static const Color primaryColor = Color(0xFF4B8EC6);

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
            border: Border.all(color: primaryColor, width: 1.6),
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
              Icon(Icons.search, size: 32, color: primaryColor),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {},
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

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const Color primaryColor = Color(0xFF4B8EC6);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          categories.length,
          (i) {
            final bool selected = i == selectedIndex;
            return Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 0 : 7,
                right: i == categories.length - 1 ? 0 : 7,
              ),
              child: GestureDetector(
                onTap: () => onTap(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  constraints: const BoxConstraints(
                    minHeight: 36,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? primaryColor : Colors.grey.shade300,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      categories[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.white : Colors.black87,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FundData {
  const _FundData({
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
}

class _FundCard extends StatelessWidget {
  const _FundCard({
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

  static const Color primaryColor = Color(0xFF4B8EC6);

  factory _FundCard.placeholder() {
    return const _FundCard(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CrownIcon(
                      color: rankLabel == '1위'
                          ? Colors.amber
                          : rankLabel == '2위'
                              ? const Color(0xFFC0C0C0) // 은색
                              : const Color(0xFFCD7F32), // 동색
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11,
                    color: badge == '높은위험' ? Colors.red : primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (badge2 != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge2!,
                    style: TextStyle(
                      fontSize: 11,
                      color: badge == '높은위험' ? Colors.red : primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
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
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerRight,
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

class _ChatFab extends StatelessWidget {
  const _ChatFab({
    super.key,
    required this.label,
    required this.onClose,
  });

  final String label;
  final VoidCallback onClose;

  static const Color primaryColor = Color(0xFF4B8EC6);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: const Color(0xFF4B8EC6),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              child: Image.asset(
                'assets/images/bot-message-square.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CrownIcon extends StatelessWidget {
  const _CrownIcon({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CrownPainter(color: color),
      ),
    );
  }
}

class _CrownPainter extends CustomPainter {
  _CrownPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Fill paint
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Stroke paint
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Scale factor: SVG viewBox is 24x24, so divide by 24
    final scale = size.width / 24;

    final path = Path();
    // M11.562 3.266 -> move to (11.562, 3.266)
    path.moveTo(11.562 * scale, 3.266 * scale);
    // a.5.5 0 0 1 .876 0 -> arc
    path.arcToPoint(
      Offset(12.438 * scale, 3.266 * scale),
      radius: Radius.circular(0.5 * scale),
      clockwise: false,
    );
    // L15.39 8.87 -> line to
    path.lineTo(15.39 * scale, 8.87 * scale);
    // a1 1 0 0 0 1.516.294 -> arc
    path.arcToPoint(
      Offset(16.906 * scale, 9.164 * scale),
      radius: Radius.circular(1 * scale),
      clockwise: false,
    );
    // L21.183 5.5 -> line to
    path.lineTo(21.183 * scale, 5.5 * scale);
    // a.5.5 0 0 1 .798.519 -> arc
    path.arcToPoint(
      Offset(21.981 * scale, 6.019 * scale),
      radius: Radius.circular(0.5 * scale),
      clockwise: false,
    );
    // l-2.834 10.246 -> relative line to
    path.lineTo(19.147 * scale, 16.265 * scale);
    // a1 1 0 0 1-.956.734 -> arc
    path.arcToPoint(
      Offset(18.191 * scale, 16.999 * scale),
      radius: Radius.circular(1 * scale),
      clockwise: false,
    );
    // H5.81 -> horizontal line to
    path.lineTo(5.81 * scale, 16.999 * scale);
    // a1 1 0 0 1-.957-.734 -> arc
    path.arcToPoint(
      Offset(4.853 * scale, 16.265 * scale),
      radius: Radius.circular(1 * scale),
      clockwise: false,
    );
    // L2.02 6.02 -> line to
    path.lineTo(2.02 * scale, 6.02 * scale);
    // a.5.5 0 0 1 .798-.519 -> arc
    path.arcToPoint(
      Offset(2.818 * scale, 5.501 * scale),
      radius: Radius.circular(0.5 * scale),
      clockwise: false,
    );
    // l4.276 3.664 -> relative line to
    path.lineTo(7.094 * scale, 9.165 * scale);
    // a1 1 0 0 0 1.516-.294 -> arc
    path.arcToPoint(
      Offset(8.61 * scale, 8.871 * scale),
      radius: Radius.circular(1 * scale),
      clockwise: false,
    );
    path.close();

    // Base line: M5 21h14
    final basePath = Path();
    basePath.moveTo(5 * scale, 21 * scale);
    basePath.lineTo(19 * scale, 21 * scale);

    // Draw fill first, then stroke
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
    canvas.drawPath(basePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}