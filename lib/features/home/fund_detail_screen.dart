import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'constants/app_colors.dart';
import '../../data/service/fund_api.dart';
import 'withdrawal_screen.dart';
import 'investment_screen.dart';

class FundDetailScreen extends StatefulWidget {
  const FundDetailScreen({
    super.key,
    required this.title,
    required this.fundName,
    this.fundCode,
  });

  final String title;
  final String fundName;
  final String? fundCode;


  @override
  State<FundDetailScreen> createState() => _FundDetailScreenState();
}

class _FundDetailScreenState extends State<FundDetailScreen> {
  int _selectedPeriod = 0;
  final List<String> _periods = ['1개월', '3개월', '6개월', '1년', '전체'];
  
  // API 데이터
  Map<String, dynamic>? _fundDetail;
  List<Map<String, dynamic>> _profitHistory = [];
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.fundCode != null && widget.fundCode!.isNotEmpty) {
      _loadFundDetail();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = '펀드 코드가 없습니다.';
      });
    }
  }

  Future<void> _loadFundDetail() async {
    if (widget.fundCode == null || widget.fundCode!.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 병렬로 데이터 로드
      final results = await Future.wait([
        FundApi.getMyFundDetail(widget.fundCode!),
        FundApi.getMyFundProfitHistory(widget.fundCode!, _getPeriodParam()),
        FundApi.getMyFundTransactions(widget.fundCode!),
      ]);

      setState(() {
        _fundDetail = results[0] as Map<String, dynamic>?;
        _profitHistory = results[1] as List<Map<String, dynamic>>;
        _transactions = results[2] as List<Map<String, dynamic>>;
        _isLoading = false;
        // API가 아직 구현되지 않았을 수 있으므로 에러 메시지 초기화
        _errorMessage = null;
      });
    } catch (e) {
      print('펀드 상세 로딩 오류: $e');
      setState(() {
        _isLoading = false;
        // API가 아직 구현되지 않았을 수 있으므로 빈 데이터로 처리
        _fundDetail = {};
        _profitHistory = [];
        _transactions = [];
        _errorMessage = null; // 에러 메시지 표시하지 않음
      });
    }
  }

  String _getPeriodParam() {
    switch (_selectedPeriod) {
      case 0: return '1M';
      case 1: return '3M';
      case 2: return '6M';
      case 3: return '1Y';
      case 4: return 'ALL';
      default: return 'ALL';
    }
  }

  void _onPeriodChanged(int index) {
    setState(() {
      _selectedPeriod = index;
    });
    _loadProfitHistory();
  }

  Future<void> _loadProfitHistory() async {
    if (widget.fundCode == null || widget.fundCode!.isEmpty) return;

    try {
      final history = await FundApi.getMyFundProfitHistory(
        widget.fundCode!,
        _getPeriodParam(),
      );
      setState(() {
        _profitHistory = history;
      });
    } catch (e) {
      print('수익률 히스토리 로딩 오류: $e');
    }
  }

  String _formatAmount(int? amount) {
    if (amount == null) return '0원';
    final formatter = NumberFormat('#,###');
    return '${formatter.format(amount)}원';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatProfitText() {
    // 대문자 필드명도 지원
    final profitAmountRaw = _fundDetail?['profitAmount'] ?? _fundDetail?['PROFITAMOUNT'];
    final profitRateRaw = _fundDetail?['profitRate'] ?? _fundDetail?['PROFITRATE'];
    
    // 과학적 표기법도 처리하도록 toDouble()로 변환 후 round()
    final profitAmount = (profitAmountRaw as num?)?.toDouble()?.round() ?? 0;
    final profitRate = (profitRateRaw as num?)?.toDouble() ?? 0.0;
    
    final amountText = _formatAmount(profitAmount);
    final rateText = '${profitRate.toStringAsFixed(2)}%';
    
    final amountWithoutWon = amountText.replaceAll('원', '');
    return '$amountWithoutWon($rateText)';
  }

  Color _getProfitColor() {
    final profitRateRaw = _fundDetail?['profitRate'] ?? _fundDetail?['PROFITRATE'];
    final profitRate = (profitRateRaw as num?)?.toDouble() ?? 0.0;
    return profitRate >= 0 ? Colors.redAccent : Colors.blueAccent;
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
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
                                  Text(
                                    (_fundDetail?['fundName'] ?? _fundDetail?['FUNDNAME']) as String? ?? widget.fundName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // 현재 가치 (투자 원금 + 평가손익)
                                  Text(
                                    _formatAmount(
                                      (((_fundDetail?['investedAmt'] ?? _fundDetail?['INVESTEDAMT']) as num?)?.toInt() ?? 0) +
                                      (((_fundDetail?['profitAmount'] ?? _fundDetail?['PROFITAMOUNT']) as num?)?.toDouble()?.round() ?? 0)
                                    ),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // 평가손익
                                  Text(
                                    _formatProfitText(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: _getProfitColor(),
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
                                            onTap: () => _onPeriodChanged(index),
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
                                    child: _FundChart(
                                      fundCode: widget.fundCode ?? '',
                                      profitHistory: _profitHistory,
                                    ),
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
                      children: _transactions.isEmpty
                          ? [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  '거래 내역이 없습니다.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ]
                          : _transactions.map((transaction) {
                              // 대문자 필드명도 지원
                              final date = _formatDate(
                                transaction['tradeDate'] as String? ?? 
                                transaction['date'] as String? ?? 
                                transaction['TRADEDATE'] as String? ?? 
                                transaction['DATE'] as String?
                              );
                              final amountRaw = transaction['amount'] ?? transaction['AMOUNT'] ?? transaction['tradeAmount'] ?? transaction['TRADEAMOUNT'];
                              final amount = (amountRaw as num?)?.toInt() ?? 0;
                              final orderNo = transaction['orderNo'] ?? transaction['ORDERNO'] ?? transaction['orderSeq'] ?? transaction['ORDERSEQ'];
                              
                              // 디버깅용 로그
                              print('거래 내역: $transaction');
                              print('금액: $amountRaw -> $amount');
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  children: [
                                    Text(
                                      date,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        '${orderNo}회차',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _formatAmount(amount),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
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
                        InvestmentScreen.show(context);
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
  const _FundChart({
    required this.fundCode,
    required this.profitHistory,
  });

  final String fundCode;
  final List<Map<String, dynamic>> profitHistory;

  @override
  State<_FundChart> createState() => _FundChartState();
}

class _FundChartState extends State<_FundChart> {
  FlSpot? _touchedSpot;
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.profitHistory.isEmpty) {
      return const Center(
        child: Text('수익률 데이터가 없습니다'),
      );
    }

    // API 데이터를 그래프 포인트로 변환
    final dataPoints = widget.profitHistory.map((item) {
      return (item['profitRate'] as num?)?.toDouble() ?? 0.0;
    }).toList();

    // 첫 번째 값을 기준으로 상대 수익률 계산
    final baseValue = dataPoints.isNotEmpty ? dataPoints.first : 0.0;
    final spots = dataPoints.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      // 기준점 대비 변화율
      final relativeValue = baseValue == 0 ? 0.0 : (value - baseValue).toDouble();
      return FlSpot(index.toDouble(), relativeValue);
    }).toList();

    final minValue = spots.isEmpty ? 0.0 : spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxValue = spots.isEmpty ? 0.0 : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final isRising = spots.isNotEmpty && spots.last.y > spots.first.y;
    final Color lineColor = isRising ? Colors.red : const Color(0xFF4FC3F7);

    String getDateString(int index) {
      if (index < 0 || index >= widget.profitHistory.length) return '';
      final dateStr = widget.profitHistory[index]['date'] as String? ?? '';
      try {
        final date = DateTime.parse(dateStr);
        return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
      } catch (e) {
        return dateStr.replaceAll('-', '.');
      }
    }

    String getPercentage(int index) {
      if (index < 0 || index >= dataPoints.length) return '0.00%';
      final currentValue = dataPoints[index];
      return '${currentValue.toStringAsFixed(2)}%';
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
          maxX: (spots.length - 1).toDouble(),
          minY: minValue * 1.1,
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
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    lineColor.withOpacity(0.15),
                    lineColor.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 0,
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

