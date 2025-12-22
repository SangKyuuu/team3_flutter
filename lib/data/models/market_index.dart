class MarketIndex {
  final String name;
  final String value;
  final String change;
  final bool isUp;

  MarketIndex({
    required this.name,
    required this.value,
    required this.change,
    required this.isUp,
  });
}

// 더미 데이터 (나중에 실제 API 연동 가능)
final List<MarketIndex> mockIndices = [
  MarketIndex(name: 'KOSPI', value: '2,560.12', change: '+0.45%', isUp: true),
  MarketIndex(name: 'KOSDAQ', value: '842.50', change: '-1.20%', isUp: false),
  MarketIndex(name: 'S&P 500', value: '5,123.34', change: '+0.88%', isUp: true),
  MarketIndex(name: 'NASDAQ', value: '16,234.50', change: '+1.15%', isUp: true),
  MarketIndex(name: 'USD/KRW', value: '1,342.00', change: '-0.30%', isUp: false),
];