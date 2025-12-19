import 'package:flutter/material.dart';
import '../../home/constants/app_colors.dart';

class MockDiagnosisResultScreen extends StatelessWidget {
  const MockDiagnosisResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AI 포트폴리오 진단', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 헤더: 총평 요약
            _buildSectionHeader('📊 전체 투자 요약'),
            _buildSummaryText('현재 설유진 님의 포트폴리오는 **적극투자형** 성향에 비해 **안정형 자산 비중이 다소 높습니다.** 최근 시장 변동성을 고려할 때 수익률 방어에는 유리하지만, 목표 수익률 달성에는 시간이 더 걸릴 수 있습니다.'),

            const SizedBox(height: 32),

            // 2. 주요 분석 내용 (텍스트 리스트)
            _buildSectionHeader('📝 주요 분석 포인트'),
            _buildAnalysisPoint('현금 비중 과다', '현재 전체 자산의 40%가 현금으로 보유 중입니다. 일부를 배당형 펀드로 전환하여 기초 수익을 확보하는 것을 추천합니다.'),
            _buildAnalysisPoint('특정 섹터 쏠림', 'IT 기술주 펀드 비중이 70%를 상회합니다. 반도체 업황 변동에 수익률이 크게 흔들릴 위험이 있습니다.'),

            const SizedBox(height: 32),

            // 3. AI의 추천 전략
            _buildSectionHeader('💡 AI 추천 전략'),
            _buildAdviceBox(
                '• 기술주 비중을 15% 줄이고, 인프라 펀드를 추가하세요.\n'
                    '• 매수 시점을 분산하여 변동성을 낮추는 전략이 필요합니다.\n'
                    '• 정기적인 리밸런싱을 통해 자산 비중을 유지하세요.'
            ),

            const SizedBox(height: 40),

            // 하단 닫기 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('확인', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 섹션 제목 위젯
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  // 요약 텍스트 위젯 (마크다운 느낌 강조)
  Widget _buildSummaryText(String text) {
    return Text(
      text.replaceAll('**', ''), // 실제 구현 시에는 RichText로 볼드 처리 가능
      style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
    );
  }

  // 분석 포인트 위젯
  Widget _buildAnalysisPoint(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 18, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(content, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5)),
          ),
        ],
      ),
    );
  }

  // 조언 박스 위젯
  Widget _buildAdviceBox(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        content,
        style: const TextStyle(fontSize: 14, height: 1.8, color: Colors.black87),
      ),
    );
  }
}