import 'package:flutter/material.dart';
import '../../../data/models/market_index.dart';
import '../../home/constants/app_colors.dart';
import '../../../data/service/mock_api.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class MockDashboardScreen extends StatefulWidget {
  const MockDashboardScreen({super.key});

  @override
  State<MockDashboardScreen> createState() => _MockDashboardScreenState();
}

class _MockDashboardScreenState extends State<MockDashboardScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  double _totalAsset = 0;
  double _profitRate = 0;
  List<dynamic> _myFunds = [];

  // 자동 스크롤을 위한 컨트롤러와 타이머
  final ScrollController _tickerController = ScrollController();
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _startTickerAnimation(); // 티커 애니메이션 시작
  }

  @override
  void dispose() {
    _tickerTimer?.cancel(); // 메모리 누수 방지
    _tickerController.dispose();
    super.dispose();
  }

  // 자동 스크롤 로직
  void _startTickerAnimation() {
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_tickerController.hasClients) {
        double maxScroll = _tickerController.position.maxScrollExtent;
        double currentScroll = _tickerController.offset;

        // 끝에 도달하면 다시 처음으로 점프 (무한 루프 느낌)
        if (currentScroll >= maxScroll) {
          _tickerController.jumpTo(0);
        } else {
          _tickerController.animateTo(
            currentScroll + 1, // 1픽셀씩 이동
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _hasError = false; // 시작할 때 에러 상태 초기화
    });

    try {
      final data = await MockApi.getMockDashboardSummary();
      if (data != null) {
        setState(() {
          _totalAsset = data['totalAsset']?.toDouble() ?? 0;
          _profitRate = data['profitRate']?.toDouble() ?? 0;
          _myFunds = data['funds'] ?? [];
          _isLoading = false;
        });
      } else {
        // 데이터가 비어있거나 응답이 비정상일 때
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      // 네트워크 연결 실패 등 예외 발생 시
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  List<PieChartSectionData> _getSections() {
    if (_myFunds.isEmpty) {
      // 펀드가 없을 때는 현금 100% 표시
      return [
        PieChartSectionData(
          color: AppColors.primaryColor,
          value: 100,
          title: '현금 100%',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ];
    }

    // 펀드가 있을 경우: (이해를 돕기 위한 예시 로직)
    return _myFunds.asMap().entries.map((entry) {
      int idx = entry.key;
      var fund = entry.value;
      return PieChartSectionData(
        color: Colors.primaries[idx % Colors.primaries.length], // 펀드별 다른 색상
        value: fund['ratio'].toDouble(),
        title: '${fund['ratio']}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Color trendColor = _profitRate >= 0 ? Colors.redAccent : Colors.blueAccent;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('OASIS 모의투자', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildMarketTicker(), // 자동 스크롤 티커
          const Divider(height: 1, thickness: 0.5),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(trendColor),
                    const SizedBox(height: 20),
                    _buildAIDiagnosisBanner(), // AI 배너
                    const SizedBox(height: 32),
                    const Text('보유 펀드 내역',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...(_myFunds.isEmpty
                        ? [_buildEmptyFundView()]
                        : _myFunds.map((fund) => _buildFundItem(fund)).toList()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Color trendColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('나의 투자 원금', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_totalAsset.toStringAsFixed(0)}원',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_profitRate >= 0 ? '+' : ''}$_profitRate%',
                  style: TextStyle(color: trendColor, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 80,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 1),
                      const FlSpot(1, 1.2),
                      const FlSpot(2, 1.1),
                      const FlSpot(3, 1.3),
                      const FlSpot(4, 1.2),
                      const FlSpot(5, 1.5), // 현재는 더미 데이터, 나중에 DB와 연동
                    ],
                    isCurved: true,
                    color: trendColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: trendColor.withOpacity(0.1),
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

  Widget _buildEmptyFundView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.pie_chart_outline_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            '아직 보유하신 펀드가 없어요',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // 펀드 목록 화면으로 이동 로직
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              foregroundColor: AppColors.primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('첫 모의투자 시작하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildAIDiagnosisBanner() {
    return GestureDetector(
      onTap: () {
        // AI 진단 로직 연결 예정
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryColor, Color(0xFF81D4FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Image.asset('assets/images/bot-message-square.png', width: 40, height: 40, color: Colors.white), //
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI 포트폴리오 진단', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('내 투자 성향에 맞는지 확인해보세요', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFundItem(Map<String, dynamic> fund) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fund['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('비중 ${fund['ratio']}%', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          Text(
            '${fund['profit'] >= 0 ? '+' : ''}${fund['profit']}%',
            style: TextStyle(
              color: fund['profit'] >= 0 ? Colors.redAccent : Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  //시장 지수 티커 위젯
  Widget _buildMarketTicker() {
    // 무한 루프처럼 보이게 하기 위해 리스트를 복사
    final doubleList = [...mockIndices, ...mockIndices, ...mockIndices];

    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        controller: _tickerController, // 컨트롤러 연결
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(), // 사용자가 직접 스크롤하지 못하게 함
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: doubleList.length,
        itemBuilder: (context, index) {
          final item = doubleList[index];
          final Color color = item.isUp ? Colors.red : Colors.blue;

          return Container(
            margin: const EdgeInsets.only(right: 32),
            child: Row(
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 8),
                Text(item.value, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(item.change, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                Icon(item.isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: color, size: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  //파이 차트 위젯
  Widget _buildPortfolioChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('자산 구성 비중', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              // 파이 차트 영역
              SizedBox(
                width: 130,
                height: 130,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40, // 도넛 모양으로 만들기
                    sections: _getSections(),
                  ),
                ),
              ),
              const SizedBox(width: 30),
              // 범례 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _myFunds.isEmpty
                      ? [_buildLegendItem(AppColors.primaryColor, '현금(예치금)')]
                      : _myFunds.asMap().entries.map((e) =>
                      _buildLegendItem(Colors.primaries[e.key % Colors.primaries.length], e.value['name'])
                  ).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 범례 아이템 빌더
  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 에러 발생 시 보여줄 화면 위젯
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            '데이터를 불러올 수 없습니다',
            style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            '네트워크 연결 상태를 확인해주세요.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDashboardData, // 다시 시도 버튼
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}