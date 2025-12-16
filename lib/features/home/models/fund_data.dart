class FundData {
  const FundData({
    required this.title,
    this.subtitle,
    required this.rankLabel,
    required this.badge,
    this.badge2,
    required this.yieldText,
  });

  final String title;
  final String? subtitle;
  final String rankLabel;
  final String badge;
  final String? badge2;
  final String yieldText;
}

