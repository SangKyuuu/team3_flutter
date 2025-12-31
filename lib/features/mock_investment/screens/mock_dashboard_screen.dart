import 'package:flutter/material.dart';
import '../../../data/models/market_index.dart';
import '../../home/constants/app_colors.dart';
import '../../../data/service/mock_api.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'mock_ai_report_screen.dart';

class MockDashboardScreen extends StatefulWidget {
  const MockDashboardScreen({super.key});

  @override
  State<MockDashboardScreen> createState() => _MockDashboardScreenState();
}

class _MockDashboardScreenState extends State<MockDashboardScreen> {
  //테스트를 위한 고정 고객 번호 (로그인 기능 완성 전까지 사용)
  static const int testCustNo = 18;
  String _userName = "고객";

  bool _isLoading = true;
  bool _hasError = false;
  double _totalAsset = 0;
  double _profitRate = 0;
  List<dynamic> _myFunds = [];

  final ScrollController _tickerController = ScrollController();
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _startTickerAnimation();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _tickerController.dispose();
    super.dispose();
  }

  void _startTickerAnimation() {
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_tickerController.hasClients) {
        double maxScroll = _tickerController.position.maxScrollExtent;
        double currentScroll = _tickerController.offset;
        if (currentScroll >= maxScroll) {
          _tickerController.jumpTo(0);
        } else {
          _tickerController.animateTo(
            currentScroll + 1,
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
      _hasError = false;
    });

    try {
      final data = await MockApi.getMockDashboardSummary(testCustNo);
      if (data != null) {
        setState(() {
          _totalAsset = data['totalAsset']?.toDouble() ?? 0;
          _profitRate = data['profitRate']?.toDouble() ?? 0;
          _myFunds = data['funds'] ?? [];
          _userName = data['userName'] ?? "고객";
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  List<PieChartSectionData> _getSections() {
    if (_myFunds.isEmpty) {
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
    return _myFunds.asMap().entries.map((entry) {
      int idx = entry.key;
      var fund = entry.value;
      return PieChartSectionData(
        color: Colors.primaries[idx % Colors.primaries.length],
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

    // 👈 에러 발생 시 에러 뷰를 보여주도록 처리 추가
    if (_hasError) return Scaffold(body: _buildErrorView());

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
          _buildMarketTicker(),
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
                    _buildAIDiagnosisBanner(), // 👈 AI 배너 터치 가능하게 수정됨
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
                      const FlSpot(5, 1.5),
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
            onPressed: () {},
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
        // AI 리포트 화면으로 이동하며 18번 전달
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MockAiReportScreen(custNo: testCustNo, userName: _userName,),
          ),
        );
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
            // 👈 이미지 에셋이 없어도 에러나지 않게 아이콘으로 대체 처리
            const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fund['name'] ?? '펀드명 없음',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text('비중 ${fund['ratio']}%', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(fund['profit'] ?? 0) >= 0 ? '+' : ''}${fund['profit']}%',
            style: TextStyle(
              color: (fund['profit'] ?? 0) >= 0 ? Colors.redAccent : Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketTicker() {
    final doubleList = [...mockIndices, ...mockIndices, ...mockIndices];
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        controller: _tickerController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
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

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('데이터를 불러올 수 없습니다', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDashboardData,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}