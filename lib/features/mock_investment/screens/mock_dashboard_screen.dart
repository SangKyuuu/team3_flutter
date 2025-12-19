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
  bool _hasError = false;
  double _totalAsset = 0;
  double _profitRate = 0;
  List<dynamic> _myFunds = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
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

  @override
  Widget build(BuildContext context) {
    final Color trendColor = _profitRate >= 0 ? Colors.redAccent : Colors.blueAccent;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('모의투자 대시보드', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      // 🔥 삼항 연산자를 사용하여 화면을 3가지 상태로 나눕니다.
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) //로딩 중
          : _hasError
          ? _buildErrorView() //에러 발생 시
          : RefreshIndicator( //정상 데이터 로드 시 (새로고침 기능 포함)
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // 리스트가 짧아도 새로고침 작동
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //총 자산 및 수익률 카드
              _buildSummaryCard(trendColor),
              const SizedBox(height: 20),
              //AI 포트폴리오 진단 배너
              _buildAIDiagnosisBanner(),
              const SizedBox(height: 24),
              const Text('보유 펀드 내역', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              //보유 펀드 리스트
              ..._myFunds.map((fund) => _buildFundItem(fund)).toList(),
            ],
          ),
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