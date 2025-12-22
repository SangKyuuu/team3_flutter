class MockAccount {
  final String? mockAcctNo;
  final int custNo;
  final double balance;
  final double? totalAsset;
  final String? statusCode;

  MockAccount({
    this.mockAcctNo,
    required this.custNo,
    required this.balance,
    this.totalAsset,
    this.statusCode,
  });

  // JSON -> 객체 변환
  factory MockAccount.fromJson(Map<String, dynamic> json) {
    return MockAccount(
      mockAcctNo: json['mockAcctNo'],
      custNo: json['custNo'],
      balance: (json['balance'] as num).toDouble(),
      totalAsset: json['totalAsset'] != null ? (json['totalAsset'] as num).toDouble() : null,
      statusCode: json['statusCode'],
    );
  }
}