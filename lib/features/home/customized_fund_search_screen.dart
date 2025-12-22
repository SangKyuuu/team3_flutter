import 'package:flutter/material.dart';
import 'constants/app_colors.dart';

class CustomizedFundSearchScreen extends StatefulWidget {
  const CustomizedFundSearchScreen({super.key});

  @override
  State<CustomizedFundSearchScreen> createState() => _CustomizedFundSearchScreenState();
}

class _CustomizedFundSearchScreenState extends State<CustomizedFundSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // 투자지역
  String? _selectedRegion;
  
  // 펀드유형
  Set<String> _selectedFundTypes = {};
  
  // 투자국가
  Set<String> _selectedCountries = {};
  
  // 운용스타일
  Set<String> _selectedOperationStyles = {};
  
  int _productCount = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _selectedRegion = null;
      _selectedFundTypes.clear();
      _selectedCountries.clear();
      _selectedOperationStyles.clear();
      _productCount = 0;
    });
  }

  void _updateProductCount() {
    // TODO: 실제 필터링 로직 구현
    setState(() {
      _productCount = 0; // 임시로 0으로 설정
    });
  }

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
          '맞춤형 펀드검색',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, size: 24),
            color: Colors.black87,
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu, size: 24),
            color: Colors.black87,
            onPressed: () {
              // TODO: 메뉴 열기
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 검색 입력 필드
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: '펀드명, 키워드 입력',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 투자지역
                  _buildSectionTitle('투자지역'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSingleSelectButton('국내', _selectedRegion == '국내', (value) {
                        setState(() {
                          _selectedRegion = value;
                          _updateProductCount();
                        });
                      }),
                      _buildSingleSelectButton('해외', _selectedRegion == '해외', (value) {
                        setState(() {
                          _selectedRegion = value;
                          _updateProductCount();
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // 펀드유형
                  _buildSectionTitle('펀드유형'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '주식(혼합)',
                      '채권',
                      'MMF',
                      '대안',
                      '선진주식(혼합)',
                      '이머징주식(혼합)',
                      '해외채권',
                    ].map((type) => _buildMultiSelectButton(
                      type,
                      _selectedFundTypes.contains(type),
                      (value) {
                        setState(() {
                          if (_selectedFundTypes.contains(value)) {
                            _selectedFundTypes.remove(value);
                          } else {
                            _selectedFundTypes.add(value);
                          }
                          _updateProductCount();
                        });
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 32),
                  // 투자국가
                  Row(
                    children: [
                      _buildSectionTitle('투자국가'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '중복선택가능',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '한국',
                      '글로벌',
                      '이머징',
                      '아시아',
                      '브릭스',
                      '중남미',
                      '선진유럽',
                      '신흥유럽',
                      '미국',
                      '일본',
                      '중국',
                      '인도',
                      '브라질',
                      '러시아',
                      '기타',
                    ].map((country) => _buildMultiSelectButton(
                      country,
                      _selectedCountries.contains(country),
                      (value) {
                        setState(() {
                          if (_selectedCountries.contains(value)) {
                            _selectedCountries.remove(value);
                          } else {
                            _selectedCountries.add(value);
                          }
                          _updateProductCount();
                        });
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 32),
                  // 운용스타일
                  Row(
                    children: [
                      _buildSectionTitle('운용스타일'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '중복선택가능',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '일반주식',
                      '배당주',
                      '중소형주',
                      '인덱스',
                      '자산배분',
                      '섹터/테마',
                      '절대수익/롱숏',
                      '국공채',
                      '회사채',
                      '부동산',
                      '원자재',
                      'ELF/DLF',
                      'ELB/DLB',
                      '하이일드',
                      '뱅크론',
                      '기타',
                    ].map((style) => _buildMultiSelectButton(
                      style,
                      _selectedOperationStyles.contains(style),
                      (value) {
                        setState(() {
                          if (_selectedOperationStyles.contains(value)) {
                            _selectedOperationStyles.remove(value);
                          } else {
                            _selectedOperationStyles.add(value);
                          }
                          _updateProductCount();
                        });
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 100), // 하단 버튼 공간 확보
                ],
              ),
            ),
          ),
          // 하단 버튼
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '초기화',
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
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 필터링된 상품 목록 화면으로 이동
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '$_productCount개 상품 보기',
                      style: const TextStyle(
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
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: () {
              // TODO: 상담 화면으로 이동
            },
            backgroundColor: Colors.grey.shade200,
            child: const Text(
              '상담',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // TODO: 플로팅 버튼 닫기
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSingleSelectButton(String label, bool isSelected, Function(String) onTap) {
    return InkWell(
      onTap: () => onTap(label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectButton(String label, bool isSelected, Function(String) onTap) {
    return InkWell(
      onTap: () => onTap(label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade200 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(
                Icons.check,
                size: 18,
                color: AppColors.primaryColor,
              )
            else
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

