import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../home/constants/app_colors.dart';
import '../../../data/service/mock_api.dart';

class MockAiReportScreen extends StatefulWidget {
  final int custNo;
  final String userName;

  const MockAiReportScreen({super.key, required this.custNo, required this.userName});

  @override
  State<MockAiReportScreen> createState() => _MockAiReportScreenState();
}

class _MockAiReportScreenState extends State<MockAiReportScreen> {
  bool _isLoading = true;
  String _reportContent = "";

  @override
  void initState() {
    super.initState();
    _fetchAiReport();
  }

  Future<void> _fetchAiReport() async {
    final report = await MockApi.getAiInvestmentReport(widget.custNo);
    if (mounted) {
      setState(() {
        _reportContent = report ?? "데이터를 불러오는 데 실패했습니다. 잠시 후 다시 시도해주세요.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // 👈 대시보드와 동일한 연한 배경색
      appBar: AppBar(
        title: const Text('OASIS AI 진단', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading ? _buildLoadingView() : _buildReportView(),
    );
  }

  // 로딩 상태 위젯
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primaryColor),
          const SizedBox(height: 24),
          const Text('OASIS AI가 포트폴리오를 분석 중입니다...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
          const SizedBox(height: 8),
          Text('${widget.userName}님의 최신 데이터를 확인하고 있습니다.',
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  // 리포트 뷰 위젯
  Widget _buildReportView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBadge(), // 상단 배지
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white, // 👈 화이트 카드 디자인
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
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.primaryColor, size: 20),
                    SizedBox(width: 8),
                    Text('전문 진단 결과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 32, thickness: 0.5),
                // Markdown 스타일 적용으로 가독성 향상
                MarkdownBody(
                  data: _reportContent,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                    h1: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 2.0),
                    strong: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                    listBullet: const TextStyle(color: AppColors.primaryColor, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('확인 완료', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('AI 맞춤형 자산 관리 리포트',
          style: TextStyle(color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}