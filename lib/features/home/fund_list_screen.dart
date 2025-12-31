import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'models/fund_data.dart';
import 'widgets/fund_card.dart';
import 'widgets/category_tabs.dart';
import '../../data/service/fund_api.dart';

class FundListScreen extends StatefulWidget {
  final String categoryTitle;
  final List<FundData> funds; // 메인 화면에서 전달받은 초기 데이터

  const FundListScreen({
    super.key,
    required this.categoryTitle,
    required this.funds,
  });

  @override
  State<FundListScreen> createState() => _FundListScreenState();
}

class _FundListScreenState extends State<FundListScreen> {
  static const List<String> _categories = [
    '판매량 best',
    '수익률 best',
  ];

  // 카테고리와 API 카테고리 매핑
  static const Map<String, String> _categoryToApi = {
    '판매량 best': 'sales',
    '수익률 best': 'yield',
  };

  late int _selectedCategoryIndex;
  List<FundData> _funds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 초기 선택된 카테고리 인덱스 찾기
    // '신상품'이 전달되면 기본값으로 처리
    final categoryTitle = widget.categoryTitle == '신상품' 
        ? '판매량 best' 
        : widget.categoryTitle;
    _selectedCategoryIndex = _categories.indexOf(categoryTitle);
    if (_selectedCategoryIndex == -1) {
      _selectedCategoryIndex = 0; // 기본값
    }
    
    // 초기 데이터는 메인 화면에서 전달받은 데이터 사용
    List<FundData> initialFunds = widget.funds;
    
    // 수익률 best인 경우 수익률 기준으로 정렬
    if (categoryTitle == '수익률 best' && initialFunds.isNotEmpty) {
      initialFunds = _sortByYield(initialFunds);
    }
    
    _funds = initialFunds;
    
    // 초기 데이터가 비어있으면 API 호출
    if (_funds.isEmpty) {
      _loadFunds();
    }
  }

  /// 수익률 기준으로 펀드 목록 정렬 (내림차순)
  List<FundData> _sortByYield(List<FundData> funds) {
    final sorted = List<FundData>.from(funds)..sort((a, b) {
      // yieldText에서 숫자 추출 (예: "5.25%" -> 5.25)
      double getYieldValue(String yieldText) {
        if (yieldText == '—' || yieldText.isEmpty) {
          return -999.0; // 가장 낮은 값으로 처리
        }
        // "%" 제거하고 숫자 추출
        final cleaned = yieldText.replaceAll('%', '').trim();
        return double.tryParse(cleaned) ?? -999.0;
      }
      
      final yieldA = getYieldValue(a.yieldText);
      final yieldB = getYieldValue(b.yieldText);
      
      // 내림차순 정렬 (높은 수익률이 먼저)
      return yieldB.compareTo(yieldA);
    });
    
    // 정렬 후 순위 라벨 업데이트
    return sorted.asMap().entries.map((entry) {
      final index = entry.key;
      final fund = entry.value;
      return FundData(
        title: fund.title,
        subtitle: fund.subtitle,
        rankLabel: '${index + 1}위',
        badge: fund.badge,
        badge2: fund.badge2,
        yieldText: fund.yieldText,
        fundCode: fund.fundCode,
      );
    }).toList();
  }

  /// 카테고리별 펀드 목록을 API에서 가져오기
  Future<void> _loadFunds() async {
    setState(() => _isLoading = true);
    
    try {
      final selectedCategory = _categories[_selectedCategoryIndex];
      final apiCategory = _categoryToApi[selectedCategory] ?? 'sales';
      
      final funds = await FundApi.getFundsByCategory(apiCategory);
      
      // 수익률 best인 경우 수익률 기준으로 내림차순 정렬
      List<FundData> sortedFunds = funds;
      if (selectedCategory == '수익률 best') {
        sortedFunds = _sortByYield(funds);
      }
      
      setState(() {
        _funds = sortedFunds;
        _isLoading = false;
      });
    } catch (e) {
      print('펀드 목록 로딩 오류: $e');
      setState(() {
        _isLoading = false;
        // 에러 발생 시 빈 리스트로 설정
        _funds = [];
      });
    }
  }

  void _onCategoryTap(int index) {
    if (_selectedCategoryIndex != index) {
      setState(() {
        _selectedCategoryIndex = index;
      });
      // 카테고리 변경 시 API 호출
      _loadFunds();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showRank = true; // 모든 카테고리가 순위를 표시

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '펀드 목록',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 카테고리 탭
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: CategoryTabs(
              categories: _categories,
              selectedIndex: _selectedCategoryIndex,
              onTap: _onCategoryTap,
            ),
          ),
          // 펀드 목록
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _funds.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text('펀드 목록이 없습니다.'),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _funds.length,
                        itemBuilder: (context, index) {
                          final fund = _funds[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: FundCard(
                              title: fund.title,
                              subtitle: fund.subtitle,
                              rankLabel: showRank ? fund.rankLabel : '',
                              badge: fund.badge,
                              badge2: fund.badge2,
                              yieldText: fund.yieldText,
                              fundCode: fund.fundCode,  // fundCode 전달
                              showDetailedView: true, // 더보기 화면에서는 상세 뷰 표시
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

