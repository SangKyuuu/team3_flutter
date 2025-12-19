import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fl_chart/fl_chart.dart';
import 'constants/app_colors.dart';
import 'withdrawal_screen.dart';

class FundDetailScreen extends StatefulWidget {
  const FundDetailScreen({
    super.key,
    required this.title,
    required this.fundName,
  });

  final String title;
  final String fundName;

  @override
  State<FundDetailScreen> createState() => _FundDetailScreenState();
}

class _FundDetailScreenState extends State<FundDetailScreen> {
  int _selectedPeriod = 0;
  final List<String> _periods = ['1개월', '3개월', '6개월', '1년', '전체'];

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 첫 번째 카드: 제목, 가치, 기간 선택, 차트
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 펀드명
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.fundName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // 현재 가치
                        const Text(
                          '1,000원',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '0원(0.00%)',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // 기간 선택 버튼들
                        Row(
                          children: List.generate(_periods.length, (index) {
                            final isSelected = _selectedPeriod == index;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index < _periods.length - 1 ? 8 : 0,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedPeriod = index;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFF8F9FB)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _periods[index],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isSelected
                                            ? Colors.black87
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),
                        // 차트 영역
                        Container(
                          height: 280,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: _FundChart(fundName: widget.fundName),
                        ),
                        const SizedBox(height: 20),
                        // 투자규칙 설정하기
                        InkWell(
                          onTap: () {
                            // 투자규칙 설정하기 로직
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/calendar-days.png',
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.calendar_today,
                                      color: AppColors.primaryColor,
                                      size: 24,
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    '투자규칙 설정하기',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 두 번째 카드: 거래 내역
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1회차 거래 내역
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            children: [
                              const Text(
                                '12.10',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  '1회차',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const Text(
                                '1,000원',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 펀드 투자 시작 메시지
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            children: [
                              const Text(
                                '12.10',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  '펀드 투자를 시작했어요!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
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
            ),
          ),
          // 하단 고정 버튼 영역
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: SafeArea(
              child: Row(
                children: [
                         Expanded(
                           child: OutlinedButton(
                             onPressed: () {
                               WithdrawalScreen.show(context);
                             },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '출금하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 투자하기 로직
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '투자하기',
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
          ),
        ],
      ),
    );
  }
}

class _FundChart extends StatefulWidget {
  const _FundChart({required this.fundName});

  final String fundName;

  @override
  State<_FundChart> createState() => _FundChartState();
}

class _FundChartState extends State<_FundChart> {
  FlSpot? _touchedSpot;
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    // 펀드명에 따라 다른 데이터 사용
    // 미국단기채공모주는 상승세, 그 외는 하락세
    final bool isUsIpo = widget.fundName.contains('미국단기채공모주');
    
    final List<double> dataPoints = isUsIpo
        ? // 상승 추세 데이터 (빨간색)
          [45, 48, 50, 52, 55, 58, 62, 65, 68, 70, 72, 75, 78, 82, 85]
        : // 하락 추세 데이터 (파란색)
          [100, 98, 102, 105, 100, 85, 75, 70, 72, 68, 65, 60, 55, 50, 45];

    final double startValue = dataPoints.first;
    final double endValue = dataPoints.last;
    final bool isRising = endValue > startValue;
    final Color lineColor = isRising ? Colors.red : const Color(0xFF4FC3F7);

    // fl_chart용 데이터 포인트 생성
    final spots = dataPoints.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    // 데이터 범위 계산
    final minValue = dataPoints.reduce((a, b) => a < b ? a : b);
    final maxValue = dataPoints.reduce((a, b) => a > b ? a : b);
    final baseline = (minValue + maxValue) / 2;

    // 날짜 생성 (예시: 2025.12.16부터 시작)
    final baseDate = DateTime(2025, 12, 16);
    String getDateString(int index) {
      final date = baseDate.add(Duration(days: index));
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    }

    // 퍼센트 계산 (기준점 대비 수익률)
    String getPercentage(int index) {
      if (index < 0 || index >= dataPoints.length) return '0.00%';
      final currentValue = dataPoints[index];
      final baseValue = dataPoints[0];
      final change = ((currentValue - baseValue) / baseValue) * 100;
      
      if (change == 0) {
        return '0.00%';
      } else if (change > 0) {
        return '+${change.toStringAsFixed(2)}%';
      } else {
        return '${change.toStringAsFixed(2)}%';
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: false,
          ),
          titlesData: FlTitlesData(
            show: false,
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minX: 0,
          maxX: (dataPoints.length - 1).toDouble(),
          minY: minValue * 0.9,
          maxY: maxValue * 1.1,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: lineColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: baseline,
                color: Colors.grey.shade300,
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
            ],
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            touchSpotThreshold: 50,
            getTouchedSpotIndicator: (LineChartBarData barData, List<int> indicators) {
              return indicators.map((int index) {
                return TouchedSpotIndicatorData(
                  // 세로 가이드 라인 (상단부터 하단까지)
                  FlLine(
                    color: Colors.grey.shade400,
                    strokeWidth: 1,
                    dashArray: null,
                  ),
                  // 선택된 포인트 마커 (터치한 순간에만 표시)
                  FlDotData(
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color: lineColor,
                        strokeWidth: 3,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                if (touchedSpots.isEmpty) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _touchedSpot = null;
                        _touchedIndex = null;
                      });
                    }
                  });
                  return [];
                }
                final spot = touchedSpots[0];
                final index = spot.x.toInt();
                if (index < 0 || index >= dataPoints.length) {
                  return [];
                }
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _touchedSpot = FlSpot(spot.x, spot.y);
                      _touchedIndex = index;
                    });
                  }
                });
                return [
                  LineTooltipItem(
                    '${getDateString(index)}\n${getPercentage(index)}',
                    TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ];
              },
              tooltipRoundedRadius: 8,
              tooltipMargin: 8,
              // 자동 위치 보정: 화면 바깥으로 나가면 반대 방향으로 배치
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipColor: (touchedSpot) => Colors.white.withValues(alpha: 0.8),
            ),
            handleBuiltInTouches: true,
            // 드래그 시 실시간 업데이트
            longPressDuration: const Duration(milliseconds: 0),
          ),
          clipData: FlClipData.all(),
        ),
      ),
    );
  }
}

