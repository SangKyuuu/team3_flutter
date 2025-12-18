import 'package:flutter/material.dart';
import '../../home/constants/app_colors.dart'; //
import '../../../data/service/mock_api.dart';

class MockDashboardScreen extends StatefulWidget {
  const MockDashboardScreen({super.key});

  @override
  State<MockDashboardScreen> createState() => _MockDashboardScreenState();
}

class _MockDashboardScreenState extends State<MockDashboardScreen> {
  bool _isLoading = true;
  double _totalAsset = 0;
  double _profitRate = 0;
  List<dynamic> _myFunds = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final data = await MockApi.getMockDashboardSummary();
    if (data != null) {
      setState(() {
        _totalAsset = data['totalAsset']?.toDouble() ?? 0;
        _profitRate = data['profitRate']?.toDouble() ?? 0;
        _myFunds = data['funds'] ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 수익률에 따른 강조 색상 결정 (기존 프로젝트 스타일 적용)
    final Color trendColor = _profitRate >= 0 ? Colors.redAccent : Colors.blueAccent;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('모의투자 대시보드', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 총 자산 및 수익률 카드
            _buildSummaryCard(trendColor),

            const SizedBox(height: 20),

            // 2. AI 포트폴리오 진단 배너 (강조 포인트)
            _buildAIDiagnosisBanner(),

            const SizedBox(height: 24),

            const Text('보유 펀드 내역', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // 3. 보유 펀드 리스트
            ..._myFunds.map((fund) => _buildFundItem(fund)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Color trendColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Text('총 평가금액', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            '${_totalAsset.toStringAsFixed(0)}원',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: trendColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_profitRate >= 0 ? '+' : ''}$_profitRate%',
              style: TextStyle(color: trendColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
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
}