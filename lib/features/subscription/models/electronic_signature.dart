/// 전자서명 기록 모델
/// 
/// 학원 프로젝트용 전자서명 구조
/// - 비밀번호 원문은 저장하지 않음
/// - 해시값은 전자서명 증적 용도로만 사용
class ElectronicSignature {
  /// 서명 고유 ID (UUID)
  final String signatureId;
  
  /// 사용자 ID
  final String userId;
  
  /// 가입 상품명
  final String productName;
  
  /// 투자 금액
  final int investmentAmount;
  
  /// 서명 일시 (ISO 8601 형식)
  final DateTime signedAt;
  
  /// 전자서명 해시값
  /// SHA256(userId + productName + amount + timestamp + password)
  final String signatureHash;
  
  /// 단말 정보 (선택)
  final String? deviceInfo;

  ElectronicSignature({
    required this.signatureId,
    required this.userId,
    required this.productName,
    required this.investmentAmount,
    required this.signedAt,
    required this.signatureHash,
    this.deviceInfo,
  });

  /// JSON 변환 (서버 전송 또는 로컬 저장용)
  Map<String, dynamic> toJson() {
    return {
      'signatureId': signatureId,
      'userId': userId,
      'productName': productName,
      'investmentAmount': investmentAmount,
      'signedAt': signedAt.toIso8601String(),
      'signatureHash': signatureHash,
      'deviceInfo': deviceInfo,
    };
  }

  /// JSON으로부터 생성
  factory ElectronicSignature.fromJson(Map<String, dynamic> json) {
    return ElectronicSignature(
      signatureId: json['signatureId'],
      userId: json['userId'],
      productName: json['productName'],
      investmentAmount: json['investmentAmount'],
      signedAt: DateTime.parse(json['signedAt']),
      signatureHash: json['signatureHash'],
      deviceInfo: json['deviceInfo'],
    );
  }

  @override
  String toString() {
    return '''
══════════════════════════════════════════════════
         전자서명 기록 (Electronic Signature)
══════════════════════════════════════════════════
  서명 ID    : $signatureId
  사용자 ID  : $userId
  상품명     : $productName
  투자금액   : $investmentAmount 원
  서명일시   : ${signedAt.toIso8601String()}
  서명해시   : $signatureHash
  단말정보   : ${deviceInfo ?? 'N/A'}
══════════════════════════════════════════════════
''';
  }
}

