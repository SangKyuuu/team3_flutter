import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants/app_colors.dart';
import 'fund_detail_screen.dart';
import '../../data/service/fund_api.dart';

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

  /* ===================== API ===================== */

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
      debugPrint('보유펀드 로딩 오류: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '보유펀드 목록을 불러오는데 실패했습니다.';
        _myFunds = [];
      });
    }
  }

  /* ===================== 계산 ===================== */

  int _calculateTotalAmount() {
    return _myFunds.fold<int>(0, (sum, fund) {
      final invested = (fund['investedAmt'] as num?)?.toInt() ?? 0;
      final pending = (fund['pendingAmount'] as num?)?.toInt() ?? 0;
      return sum + invested + pending;
    });
  }

  int _calculateTotalProfitAmount() {
    return _myFunds.fold<int>(0, (sum, fund) {
      return sum + ((fund['profitAmount'] as num?)?.toInt() ?? 0);
    });
  }

  double _calculateProfitRate() {
    final invested = _myFunds.fold<int>(0, (sum, fund) {
      return sum + ((fund['investedAmt'] as num?)?.toInt() ?? 0);
    });

    if (invested == 0) return 0.0;
    return (_calculateTotalProfitAmount() / invested) * 100;
  }

  /* ===================== 포맷 ===================== */

  String _formatAmount(int amount) {
    return '${NumberFormat('#,###').format(amount)}원';
  }

  String _formatProfitText() {
    final amount = _calculateTotalProfitAmount();
    final rate = _calculateProfitRate();
    return '${_formatAmount(amount).replaceAll('원', '')}(${rate.toStringAsFixed(2)}%)';
  }

  /* ===================== UI ===================== */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '펀드조회/관리',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMyFunds,
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildError()
          : RefreshIndicator(
        onRefresh: _loadMyFunds,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 16),
              _myFunds.isEmpty
                  ? _buildEmpty()
                  : Column(
                children: _myFunds.map(_buildFundItem).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ===================== 하위 위젯 ===================== */

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('오늘의 평가금액', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            _formatAmount(_calculateTotalAmount()),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
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
    );
  }

  Widget _buildFundItem(Map<String, dynamic> fund) {
    final fundCode = fund['fundCode'] ?? '';
    final fundName = fund['fundName'] ?? '';
    final investedAmt = (fund['investedAmt'] as num?)?.toInt() ?? 0;
    final pendingAmount = (fund['pendingAmount'] as num?)?.toInt() ?? 0;
    final profitRate = (fund['profitRate'] as num?)?.toDouble() ?? 0.0;
    final profitAmount = (fund['profitAmount'] as num?)?.toInt() ?? 0;
    final viewStatus = fund['viewStatus'] ?? 'HOLDING';

    final displayAmount =
    viewStatus == 'HOLDING' ? investedAmt : pendingAmount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _FundCard(
        fundName: fundName,
        value: _formatAmount(displayAmount),
        profitAmount: profitAmount,
        profitRate: profitRate,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FundDetailScreen(
                title: fundName,
                fundName: fundName,
                fundCode: fundCode,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: const [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('보유중인 펀드가 없습니다'),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadMyFunds, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}

/* ===================== 펀드 카드 ===================== */

class _FundCard extends StatelessWidget {
  const _FundCard({
    required this.fundName,
    required this.value,
    required this.profitAmount,
    required this.profitRate,
    required this.onTap,
  });

  final String fundName;
  final String value;
  final int profitAmount;
  final double profitRate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isProfit = profitRate >= 0;

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
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormat('#,###').format(profitAmount)}(${profitRate.toStringAsFixed(2)}%)',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                        isProfit ? Colors.redAccent : Colors.blueAccent,
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
