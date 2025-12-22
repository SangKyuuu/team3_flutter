import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../home/constants/app_colors.dart';
import '../subscription/fund_subscription_screen.dart';
import '../investment_propensity/investment_propensity_screen.dart';
import '../terms_agreement/terms_agreement_screen.dart';
import 'pdf_viewer_screen.dart';

class FundDetailScreen extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String badge;
  final String yieldText;
  final String? description;

  const FundDetailScreen({
    super.key,
    required this.title,
    this.subtitle,
    required this.badge,
    required this.yieldText,
    this.description,
  });

  @override
  State<FundDetailScreen> createState() => _FundDetailScreenState();
}

class _FundDetailScreenState extends State<FundDetailScreen> {
  int _selectedPeriod = 0;
  final List<String> _periods = ['3개월', '6개월', '1년', '3년'];

  // 샘플 자산 구성 데이터 (파란색과 조화로운 부드러운 색상 팔레트)
  final List<AssetComposition> _assets = [
    AssetComposition(name: '채권', percentage: 69.3, color: const Color(0xFF4DB6AC)), // 부드러운 청록색
    AssetComposition(name: '유동성', percentage: 28.9, color: const Color(0xFF9575CD)), // 부드러운 라벤더
    AssetComposition(name: '수익증권', percentage: 1.7, color: const Color(0xFF64B5F6)), // 연한 스카이 블루
    AssetComposition(name: '주식', percentage: 0.1, color: const Color(0xFF90A4AE)), // 부드러운 블루 그레이
  ];

  // 샘플 TOP 10 종목 데이터
  final List<TopStock> _topStocks = [
    TopStock(rank: 1, name: 'HD현대14-1', percentage: 3.8),
    TopStock(rank: 2, name: '하나크레딧플러스증권투자신탁(채권)C-F', percentage: 2.0),
    TopStock(rank: 3, name: '미래에셋증권70', percentage: 1.9),
    TopStock(rank: 4, name: 'BNK캐피탈370-2', percentage: 1.9),
    TopStock(rank: 5, name: 'CJ ENM23-2', percentage: 1.9),
    TopStock(rank: 6, name: 'LS130-1', percentage: 1.9),
    TopStock(rank: 7, name: 'SK렌터카55-3', percentage: 1.9),
    TopStock(rank: 8, name: 'SK이노베이션12-1', percentage: 1.9),
    TopStock(rank: 9, name: 'SK인텔릭스12', percentage: 1.9),
    TopStock(rank: 10, name: 'SK지오센트릭20-2', percentage: 1.9),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 상단 정보 영역
                  _buildHeaderSection(),
                  const SizedBox(height: 12),
                  // 자산 구성 카드
                  _buildAssetCompositionCard(),
                  const SizedBox(height: 12),
                  // 펀드 설명 카드
                  _buildDescriptionCard(),
                  const SizedBox(height: 12),
                  // 상세 정보 버튼들
                  _buildDetailButtons(),
                  const SizedBox(height: 16),
                  // 출처 안내
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '펀드 수익률 및 주요정보는 제로인에서 제공합니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // 하단 가입 버튼
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 펀드 제목
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              widget.subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
          const SizedBox(height: 8),
          // 해시태그
          Row(
            children: [
              _buildHashtag('#수수료없음'),
              const SizedBox(width: 6),
              _buildHashtag('#온라인전용'),
            ],
          ),
          const SizedBox(height: 24),
          // 수익률
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '3개월 전보다',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '+${widget.yieldText}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 그래프 영역
          _buildChartArea(),
          const SizedBox(height: 20),
          // 기간 선택 탭
          _buildPeriodTabs(),
        ],
      ),
    );
  }

  Widget _buildHashtag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildChartArea() {
    // 샘플 데이터 - 우상향 수익률 곡선
    final List<FlSpot> spots = [
      const FlSpot(0, 1.0),
      const FlSpot(1, 1.2),
      const FlSpot(2, 1.1),
      const FlSpot(3, 1.4),
      const FlSpot(4, 1.3),
      const FlSpot(5, 1.5),
      const FlSpot(6, 1.6),
      const FlSpot(7, 1.55),
      const FlSpot(8, 1.7),
      const FlSpot(9, 1.65),
      const FlSpot(10, 1.8),
      const FlSpot(11, 1.9),
      const FlSpot(12, 2.0),
    ];

    return Container(
      height: 150,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 12,
          minY: 0.5,
          maxY: 2.5,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Colors.white,
              tooltipBorder: BorderSide(color: Colors.grey.shade300),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '+${((spot.y - 1) * 100).toStringAsFixed(2)}%',
                    TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.primaryColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.15),
                    AppColors.primaryColor.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_periods.length, (index) {
          final isSelected = _selectedPeriod == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  border: isSelected
                      ? Border.all(color: Colors.grey.shade300)
                      : null,
                ),
                child: Text(
                  _periods[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.black87 : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAssetCompositionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '펀드 자산 구성 중',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${_assets.first.name} 비중이 가장 높아요',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          // 비율 바
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: _assets.map((asset) {
                return Expanded(
                  flex: (asset.percentage * 10).toInt(),
                  child: Container(
                    height: 28,
                    color: asset.color,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // 자산 목록
          ..._assets.map((asset) => _buildAssetRow(asset)).toList(),
          const SizedBox(height: 16),
          // TOP 10 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showTop10BottomSheet(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '구성 종목 TOP 10',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetRow(AssetComposition asset) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: asset.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            asset.name,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            '${asset.percentage}%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '단기 채권에 투자해요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '국내 채권 중 만기 3~9개월 내외인 채권에 주로 투자하는 펀드에요. 만기가 짧은 단기 채권에 투자하여 시장 금리 움직임에 따른 위험을 줄이고, 시장 상황에 맞게 채권의 만기 비율을 조정하여 손실을 방어해요. 이 펀드는 위험이 매우 낮아서 투자성향 상관 없이 누구나 투자할 수 있어요.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow('위험등급', '매우낮은위험 (6등급)', hasTooltip: true),
          _buildInfoRow('보수', '연 0.13%', hasTooltip: true),
          _buildInfoRow('수수료', '없음'),
          _buildInfoRow('운용사', '하나자산운용'),
          _buildInfoRow('펀드 총 금액', '5,264억원'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool hasTooltip = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              if (hasTooltip) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.help_outline,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailButtons() {
    return Column(
      children: [
        _buildDetailButton('투자에 따른 위험', () => _navigateToRiskInfo()),
        _buildDetailButton('매매 기준일', () => _navigateToTradingDate()),
        _buildDetailButton('펀드 설명서', () => _showFundDocuments()),
      ],
    );
  }

  Widget _buildDetailButton(String text, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        title: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    );
  }

  // 투자에 따른 위험 화면으로 이동
  void _navigateToRiskInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InvestmentRiskScreen(),
      ),
    );
  }

  // 매매 기준일 화면으로 이동
  void _navigateToTradingDate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TradingDateScreen(),
      ),
    );
  }

  // 펀드 설명서 바텀시트
  void _showFundDocuments() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '펀드설명서',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _buildDocumentLink('핵심상품설명서'),
              _buildDocumentLink('간이투자설명서'),
              _buildDocumentLink('투자설명서'),
              const SizedBox(height: 24),
              const Text(
                '상품 이용 약관',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _buildDocumentLink('집합투자규약'),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentLink(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: () {
          // PDF 뷰어 화면으로 이동
          Navigator.pop(context); // 바텀시트 닫기
          _openPdfViewer(title);
        },
        child: Row(
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 18,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.primaryColor,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _openPdfViewer(String documentTitle) {
    // 문서 타입 매핑
    String documentType = 'core';
    switch (documentTitle) {
      case '핵심상품설명서':
        documentType = 'core';
        break;
      case '간이투자설명서':
        documentType = 'simple';
        break;
      case '투자설명서':
        documentType = 'full';
        break;
      case '집합투자규약':
        documentType = 'terms';
        break;
    }

    // TODO: 나중에 실제 PDF URL이나 경로를 전달
    // 예: documentUrl: 'https://example.com/pdfs/$documentType.pdf'
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          documentTitle: documentTitle,
          documentType: documentType,
          // documentUrl: 'https://example.com/pdfs/$documentType.pdf', // 나중에 실제 URL 사용
          // documentPath: 'assets/pdfs/$documentType.pdf', // 나중에 실제 경로 사용
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
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
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            '가입하기',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showTop10BottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOP 10',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateTime.now().year}.${DateTime.now().month.toString().padLeft(2, '0')}.01 기준',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _topStocks.length,
                    itemBuilder: (context, index) {
                      final stock = _topStocks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                '${stock.rank}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                stock.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '${stock.percentage}%',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ============== 데이터 클래스 ==============

class AssetComposition {
  final String name;
  final double percentage;
  final Color color;

  AssetComposition({
    required this.name,
    required this.percentage,
    required this.color,
  });
}

class TopStock {
  final int rank;
  final String name;
  final double percentage;

  TopStock({
    required this.rank,
    required this.name,
    required this.percentage,
  });
}

// ============== 투자에 따른 위험 화면 ==============

class InvestmentRiskScreen extends StatelessWidget {
  const InvestmentRiskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '투자에 따른 위험',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '투자에 따른 위험',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '• 해당 펀드는 원금손실위험, 시장위험, 신용위험, 펀드해지위험이 있을 수 있으므로 투자에 신중해 주시기 바랍니다.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            // 테이블
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // 헤더
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Center(
                            child: Text(
                              '종류',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '위험안내',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 위험 항목들
                  _buildRiskRow(
                    '원금손실위험',
                    '펀드는 운용실적에 따라 손익이 결정되는 실적 배당형 상품으로 투자원금이 보장 또는 보호되지 않으며 투자금액의 손실위험은 전적으로 수익자가 부담합니다.',
                  ),
                  _buildRiskRow(
                    '시장위험',
                    '주가, 금리 등 거시경제지표의 변화 뿐만아니라 예상치 못한 정치/경제 상황, 세제 변경 등이 펀드 수익률에 영향을 줄 수 있습니다.',
                  ),
                  _buildRiskRow(
                    '신용위험',
                    '투자대상 증권을 발행한 회사의 영업환경, 재무상황, 신용상태 등이 악화되는 경우 펀드 수익률에 영향을 줄 수 있습니다.',
                  ),
                  _buildRiskRow(
                    '펀드해지위험',
                    '펀드 설정 후 1년이 되는 날에 펀드 원본액이 50억원 미만이거나, 펀드를 설정하고 1년이 지난 후 1개월간 계속하여 펀드 원본액이 50억원 미만인 경우 투자자의 동의없이 펀드가 해지될 수 있습니다.',
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskRow(String title, String description, {bool isLast = false}) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== 매매 기준일 화면 ==============

class TradingDateScreen extends StatelessWidget {
  const TradingDateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '매매기준일',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '매매기준일',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            // 첫 번째 테이블
            _buildTradingTable(),
            const SizedBox(height: 32),
            const Text(
              '매매기준일이란?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '• 펀드는 주식처럼 투자, 출금 신청 당일에 주문이 체결되지 않습니다. 금액결정일(기준가격 적용일) 시점의 기준가격으로 거래금액이 확정되며 그 후 며칠 뒤에 투자, 출금 거래가 완료됩니다. 펀드별로 금액결정일과 매매완료일이 다르기 때문에 거래 전 반드시 매매기준일을 확인해 주세요.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              '예시 : 17시 이전 출금 시 금액결정 3영업일,\n매매완료 7영업일인 경우',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            // 예시 캘린더
            _buildExampleCalendar(),
            const SizedBox(height: 28),
            const Text(
              '펀드 투자 즉시 체결되지 않는 이유',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '• 펀드는 투자자를 모집하여 자산에 투자하는 상품이에요.\n  하루 동안 (영업일 기준) 투자자를 모은 후 한번에 펀드를 구성하는 자산에 투자를 진행하므로 주식과 달리 즉시 주문체결 되지 않아요.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '※ 펀드 투자 및 해지 시 신청일과 매매완료일이 다른 이유로 예상하지 못한 손실이 발생할 수 있기 때문에 꼭 유의해주시기 바랍니다.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red.shade700,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTradingTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _buildFixedCell('', width: 60, isHeader: true, hasBorder: true),
                  _buildExpandedCellWithBorder('신청시간', isHeader: true),
                  _buildExpandedCellWithBorder('금액결정', isHeader: true),
                  _buildExpandedCell('매매완료', isHeader: true),
                ],
              ),
            ),
          ),
          // 투자 행
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // 투자 레이블 (2줄 가운데 정렬)
                  Container(
                    width: 60,
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: const Center(
                      child: Text(
                        '투자',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // 오른쪽 내용
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                _buildExpandedCellWithBorder('17시 이전'),
                                _buildExpandedCellWithBorder('1영업일'),
                                _buildExpandedCell('1영업일'),
                              ],
                            ),
                          ),
                        ),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              _buildExpandedCellWithBorder('17시 이후'),
                              _buildExpandedCellWithBorder('2영업일'),
                              _buildExpandedCell('2영업일'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 출금 행
          IntrinsicHeight(
            child: Row(
              children: [
                // 출금 레이블 (2줄 가운데 정렬)
                Container(
                  width: 60,
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: const Center(
                    child: Text(
                      '출금',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // 오른쪽 내용
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              _buildExpandedCellWithBorder('17시 이전'),
                              _buildExpandedCellWithBorder('2영업일'),
                              _buildExpandedCell('2영업일'),
                            ],
                          ),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            _buildExpandedCellWithBorder('17시 이후'),
                            _buildExpandedCellWithBorder('3영업일'),
                            _buildExpandedCell('3영업일'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedCell(String text, {required double width, bool isHeader = false, bool hasBorder = false}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: hasBorder
          ? BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
            )
          : null,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isHeader ? Colors.grey.shade700 : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildExpandedCell(String text, {bool isHeader = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isHeader ? FontWeight.w600 : FontWeight.w500,
              color: isHeader ? Colors.grey.shade700 : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedCellWithBorder(String text, {bool isHeader = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isHeader ? FontWeight.w600 : FontWeight.w500,
              color: isHeader ? Colors.grey.shade700 : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildExampleCalendar() {
    const primaryColor = Color(0xFF4B8EC6);
    const highlightColor = Color(0xFFFFEB3B);
    
    return Column(
      children: [
        // 첫 번째 주
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              _buildCalendarCell('월', isHighlight: true, highlightColor: highlightColor),
              _buildCalendarCell('화'),
              _buildCalendarCell('수'),
              _buildCalendarCell('목', isHighlight: true, highlightColor: primaryColor, textColor: Colors.white),
              _buildCalendarCell('금'),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.grey.shade200),
              right: BorderSide(color: Colors.grey.shade200),
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              _buildCalendarCell('출금신청', isSmall: true),
              _buildCalendarCell('1영업일', isSmall: true),
              _buildCalendarCell('2영업일', isSmall: true),
              _buildCalendarCell('3영업일\n금액결정', isSmall: true, isMultiLine: true),
              _buildCalendarCell('4영업일', isSmall: true),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 두 번째 주
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              _buildCalendarCell('월'),
              _buildCalendarCell('화'),
              _buildCalendarCell('수'),
              _buildCalendarCell('목', isHighlight: true, highlightColor: primaryColor, textColor: Colors.white),
              _buildCalendarCell('금'),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.grey.shade200),
              right: BorderSide(color: Colors.grey.shade200),
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
          child: Row(
            children: [
              _buildCalendarCell('5영업일', isSmall: true),
              _buildCalendarCell('공휴일', isSmall: true),
              _buildCalendarCell('6영업일', isSmall: true),
              _buildCalendarCell('7영업일\n출금완료', isSmall: true, isMultiLine: true),
              _buildCalendarCell('8영업일', isSmall: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCell(String text, {
    bool isHighlight = false, 
    Color? highlightColor, 
    Color? textColor,
    bool isSmall = false,
    bool isMultiLine = false,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 14),
        decoration: BoxDecoration(
          color: isHighlight ? highlightColor : Colors.transparent,
          borderRadius: BorderRadius.circular(isHighlight ? 20 : 0),
        ),
        margin: isHighlight ? const EdgeInsets.all(4) : EdgeInsets.zero,
        child: Text(
          text,
          style: TextStyle(
            fontSize: isSmall ? 11 : 14,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
            color: textColor ?? (isSmall ? Colors.grey.shade600 : Colors.black87),
            height: isMultiLine ? 1.3 : 1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

