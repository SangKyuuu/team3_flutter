import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants/app_colors.dart';
import 'fund_detail_screen.dart';
import '../../data/service/fund_api.dart';


class FundManagementScreen extends StatelessWidget {
  const FundManagementScreen({
    super.key,
  });

class FundManagementScreen extends StatefulWidget {
  const FundManagementScreen({super.key});


  @override
  State<FundManagementScreen> createState() => _FundManagementScreenState();
}

class _FundManagementScreenState extends State<FundManagementScreen> {
  List<Map<String, dynamic>> _myFunds = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMyFunds();
  }

  Future<void> _loadMyFunds() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final funds = await FundApi.getMyFunds();
      setState(() {
        _myFunds = funds;
        _isLoading = false;
      });
    } catch (e) {
      print('보유펀드 로딩 오류: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '보유펀드 목록을 불러오는데 실패했습니다.';
        _myFunds = [];
      });
    }
  }

  /// 평가금액 계산 (보유 원금 + 신청중 금액)
  int _calculateTotalAmount() {
    int total = 0;
    for (var fund in _myFunds) {
      final investedAmt = (fund['investedAmt'] as num?)?.toInt() ?? 0;
      final pendingAmount = (fund['pendingAmount'] as num?)?.toInt() ?? 0;
      total += investedAmt + pendingAmount;
    }
    return total;
  }

  /// 평가손익 금액 계산
  int _calculateTotalProfitAmount() {
    int total = 0;
    for (var fund in _myFunds) {
      final profitAmount = (fund['profitAmount'] as num?)?.toInt() ?? 0;
      total += profitAmount;
    }
    return total;
  }

  /// 수익률 계산
  double _calculateProfitRate() {
    final totalAmount = _calculateTotalAmount();
    if (totalAmount == 0) return 0.0;
    
    final totalInvested = _myFunds.fold<int>(0, (sum, fund) {
      final investedAmt = (fund['investedAmt'] as num?)?.toInt() ?? 0;
      return sum + investedAmt;
    });
    
    if (totalInvested == 0) return 0.0;
    
    final profitAmount = _calculateTotalProfitAmount();
    return (profitAmount / totalInvested) * 100;
  }

  /// 평가손익 텍스트 포맷팅 (금액(퍼센트))
  String _formatProfitText() {
    final profitAmount = _calculateTotalProfitAmount();
    final profitRate = _calculateProfitRate();
    
    if (profitAmount == 0 && profitRate == 0) {
      return '0원(0.00%)';
    }
    
    final amountText = _formatAmount(profitAmount);
    final rateText = '${profitRate.toStringAsFixed(2)}%';
    
    // 금액에서 "원" 제거하고 (퍼센트) 추가
    final amountWithoutWon = amountText.replaceAll('원', '');
    return '$amountWithoutWon($rateText)';
  }

  /// 금액 포맷팅
  String _formatAmount(int amount) {
    // 천 단위 구분자(쉼표) 추가하여 숫자로 표시
    final formatter = NumberFormat('#,###');
    return '${formatter.format(amount)}원';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '펀드조회/관리',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadMyFunds,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 오늘의 평가금액
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '오늘의 평가금액',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '2,000원',
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 한국 대표 주식 펀드 카드
            _FundCard(
              flagIcon: '🇰🇷',
              title: '한국 대표 주식에 투자하기',
              fundName: '교보악사파워인덱스증권자투자신탁1호(주식)Ce',
              value: '1,000원',
              change: '0원(0.00%)',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FundDetailScreen(
                      title: '한국 대표 주식에 투자하기',
                      fundName: '교보악사파워인덱스증권자투자신탁1호(주식)Ce',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // 미국 공모주 펀드 카드
            _FundCard(
              flagIcon: '🇺🇸',
              title: '미국 공모주 쉽게 투자하기',
              fundName: '우리미국단기채공모주증권자투자신탁1호UH(채권혼)Ce',
              value: '1,000원',
              change: '0원(0.00%)',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FundDetailScreen(
                      title: '미국 공모주 쉽게 투자하기',
                      fundName: '우리미국단기채공모주증권자투자신탁1호UH(채권혼)Ce',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMyFunds,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMyFunds,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 오늘의 평가금액
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '오늘의 평가금액',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatAmount(_calculateTotalAmount()),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatProfitText(),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: _calculateProfitRate() >= 0
                                      ? Colors.redAccent
                                      : Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 보유펀드 목록
                        if (_myFunds.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '보유중인 펀드가 없습니다',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ..._myFunds.map((fund) {
                            final fundCode = fund['fundCode'] as String? ?? '';
                            final fundName = fund['fundName'] as String? ?? '';
                            final viewStatus = fund['viewStatus'] as String? ?? '';
                            final investedAmt = (fund['investedAmt'] as num?)?.toInt() ?? 0;
                            final pendingAmount = (fund['pendingAmount'] as num?)?.toInt() ?? 0;
                            final profitRate = (fund['profitRate'] as num?)?.toDouble() ?? 0.0;
                            final profitAmount = (fund['profitAmount'] as num?)?.toInt();

                            // 보유중이면 보유금액, 신청중이면 신청금액 표시
                            final displayAmount = viewStatus == 'HOLDING' ? investedAmt : pendingAmount;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _FundCard(
                                fundCode: fundCode,
                                fundName: fundName,
                                value: _formatAmount(displayAmount),
                                profitAmount: profitAmount,
                                profitRate: profitRate,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => FundDetailScreen(
                                        title: fundName,
                                        fundName: fundName,
                                        fundCode: fundCode,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _FundCard extends StatelessWidget {
  const _FundCard({
    required this.fundCode,
    required this.fundName,
    required this.value,
    this.profitAmount,
    this.profitRate,
    required this.onTap,
  });

  final String fundCode;
  final String fundName;
  final String value;
  final int? profitAmount;
  final double? profitRate;
  final VoidCallback onTap;

  String _formatProfitAmount(int? amount) {
    final amountValue = amount ?? 0;
    final formatter = NumberFormat('#,###');
    return formatter.format(amountValue);
  }

  String _formatProfitText() {
    final amount = profitAmount ?? 0;
    final rate = profitRate ?? 0.0;
    
    final amountText = _formatProfitAmount(amount);
    final rateText = '${rate.toStringAsFixed(2)}%';
    
    return '$amountText($rateText)';
  }

  @override
  Widget build(BuildContext context) {
    final profitText = _formatProfitText();
    final isProfit = (profitRate ?? 0) >= 0;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fundName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profitText,
                      style: TextStyle(
                        fontSize: 16,
                        color: isProfit ? Colors.redAccent : Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

