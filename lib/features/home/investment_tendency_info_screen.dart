import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'constants/app_colors.dart';
import '../investment_propensity/investment_propensity_screen.dart';

class InvestmentTendencyInfoScreen extends StatefulWidget {
  const InvestmentTendencyInfoScreen({super.key});

  static void show(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const InvestmentTendencyInfoScreen(),
      ),
    );
  }

  @override
  State<InvestmentTendencyInfoScreen> createState() => _InvestmentTendencyInfoScreenState();
}

class _InvestmentTendencyInfoScreenState extends State<InvestmentTendencyInfoScreen> {
  bool _isDetailsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: Colors.black87,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '투자성향분석 안내',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            // 사용자 투자성향 (맨 위로 이동)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '설유진님의 투자성향은',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '공격투자형이에요',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryColor.withOpacity(0.3),
                    decorationThickness: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 정보 박스
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '투자성향분석일 : 2025-12-10',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '금융취약소비자 여부 : 해당없음',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        // TODO: 금융소비자 불이익사항 화면으로 이동
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '금융소비자 불이익사항',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: Colors.grey.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 투자성향 그래프
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '기대수익',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '위험도',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 5,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 1 || index > 5) return const Text('');
                              final labels = [
                                '안정형\n6등급',
                                '안정 추구형\n5등급',
                                '위험 중립형\n4등급',
                                '적극 투자형\n3등급',
                                '공격 투자형\n2~1등급',
                              ];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  labels[index - 1],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                            reservedSize: 50,
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: 1,
                              color: AppColors.primaryColor.withOpacity(0.2),
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: 2,
                              color: AppColors.primaryColor.withOpacity(0.2),
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 3,
                          barRods: [
                            BarChartRodData(
                              toY: 3,
                              color: AppColors.primaryColor.withOpacity(0.2),
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 4,
                          barRods: [
                            BarChartRodData(
                              toY: 4,
                              color: AppColors.primaryColor.withOpacity(0.2),
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 5,
                          barRods: [
                            BarChartRodData(
                              toY: 5,
                              color: AppColors.primaryColor,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            // 가입가능 상품 섹션
            const Text(
              '가입가능 상품: 1등급(매우높은위험)이하',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '시장평균 수익률보다 높은 수익을 원해요.원금 손실 위험을 적극적으로 수용할 수 있고, 주식·주식형펀드 또는 파생상품 등의 위험 자산에 투자할 의향도 있어요.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  // TODO: 투자성향 유형 더보기 화면으로 이동
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '투자성향 유형 더보기',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 투자성향분석 내용 (접을 수 있는 섹션)
            InkWell(
              onTap: () {
                setState(() {
                  _isDetailsExpanded = !_isDetailsExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '투자성향분석 내용',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Icon(
                      _isDetailsExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
                  if (_isDetailsExpanded) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQuestionItem(
                            '질문 1',
                            '투자, 어디까지 해봤어요?',
                            ['예적금만 해봤어요', '펀드나 주식은 해봤어요', '웬만한 투자는 다 해봤어요 ✌️'],
                          ),
                          const SizedBox(height: 20),
                          _buildQuestionItem(
                            '질문 2',
                            '주식, 펀드에 대해 잘 아시나요?',
                            ['잘 모르겠어요', '매수와 매도를 구분할 수 있어요', '가치주와 성장주를 이해하고 있어요', 'PER과 PBR을 설명할 수 있어요'],
                          ),
                          const SizedBox(height: 20),
                          _buildQuestionItem(
                            '질문 3',
                            '총자산(부동산 제외) 대비 투자상품의 비중은 어떻게 되나요?',
                            ['10% 이하', '10% ~ 25%', '25% ~ 50%', '50% 초과'],
                          ),
                          const SizedBox(height: 20),
                          _buildQuestionItem(
                            '질문 4',
                            '투자를 하려는 이유가 뭐예요?',
                            ['내 자산을 더 늘리고 싶어요', '미래에 필요한 자금을 준비하고 싶어요', '곧 사용할 돈을 짧게 굴리고 싶어요'],
                          ),
                          const SizedBox(height: 20),
                          _buildQuestionItem(
                            '질문 5',
                            '앞으로 수입이 어떻게 될 것 같나요?',
                            ['일정한 수입이 없어요', '비슷하게 유지될 것 같아요', '앞으로 증가할 것 같아요'],
                          ),
                          const SizedBox(height: 20),
                          _buildQuestionItem(
                            '질문 6',
                            '손실이 있다면 어디까지 괜찮아요?',
                            ['손실은 절대 안돼요', '-10%까지는 괜찮아요', '-20%까지는 괜찮아요', '-50%까지는 괜찮아요', '더 큰 손실도 괜찮아요'],
                          ),
                          const SizedBox(height: 20),
                          _buildQuestionItem(
                            '질문 7',
                            '투자하는 돈이 언제 필요한가요?',
                            ['1년 이내', '1년 ~ 2년', '2년 ~ 3년', '3년 이후'],
                          ),
                          const SizedBox(height: 20),
                          _buildQuestionItem(
                            '질문 8',
                            '투자 중 20% 손실이 발생하면 어떻게 하실 건가요?',
                            ['바로 전부 팔아요', '일부만 팔고 지켜볼래요', '기다리면서 상황을 볼래요', '오히려 더 사고 싶어요'],
                          ),
                          const SizedBox(height: 20),
                          _buildQuestionItem(
                            '질문 9',
                            '기대하는 연간 수익률은 얼마인가요?',
                            ['예금 금리 수준 (3~4%)', '예금 금리 + α (5~10%)', '두 자릿수 수익 (10~20%)', '높은 수익 (20% 이상)'],
                          ),
                          const SizedBox(height: 20),
                          _buildQuestionItem(
                            '질문 10',
                            '마지막! 혹시 금융취약 소비자인가요?',
                            ['금융취약 소비자예요', '아니에요'],
                            description: '• 금융감독원 기준에 따라 만 65세 이상, 주부, 은퇴자가 이에 해당합니다.',
                          ),
                        ],
                      ),
                    ),
                  ],
                  ],
                ),
              ),
            ),
          ),
          // 내 성향 다시 알아보기 버튼 (하단 고정)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showReanalysisGuide(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '내 성향 다시 알아보기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReanalysisGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    color: Colors.black87,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      '다시 분석하기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // X 버튼과 균형 맞추기
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 1,
                color: Colors.grey.shade200,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).padding.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // 안내 메시지
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: '※ 투자성향 분석은 '),
                  TextSpan(
                    text: '대면',
                    style: TextStyle(
                      backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  const TextSpan(text: ', '),
                  TextSpan(
                    text: '비대면 통합하여',
                    style: TextStyle(
                      backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: '1일 1회만',
                    style: TextStyle(
                      backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  const TextSpan(text: ' 가능해요.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
                  // 다음 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // 모달 닫기
                        Navigator.of(context).pop(); // 현재 화면 닫기
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => InvestmentPropensityScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '다음',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionItem(String questionNumber, String question, List<String> options, {String? description, String? selectedAnswer}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionNumber,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                question,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Text(
            selectedAnswer ?? options.first, // 선택된 답변이 없으면 첫 번째 옵션 표시 (나중에 실제 선택값으로 교체)
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

