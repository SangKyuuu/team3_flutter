import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../models/electronic_signature.dart';

/// 전자서명 서비스
/// 
/// 학원 프로젝트용 전자서명 생성 및 검증 서비스
/// 
/// 해시 생성 방식:
/// 1. 서명 데이터 조합: userId + productName + amount + timestamp + password
/// 2. SHA256 해시 생성
/// 3. 비밀번호 원문은 저장하지 않음
class SignatureService {
  static final _uuid = Uuid();
  
  /// 전자서명 생성
  /// 
  /// [userId] 사용자 ID
  /// [productName] 가입 상품명
  /// [investmentAmount] 투자 금액
  /// [password] 사용자가 입력한 비밀번호 (해시 생성 후 폐기)
  /// [deviceInfo] 단말 정보 (선택)
  /// 
  /// Returns: 생성된 전자서명 기록
  static ElectronicSignature createSignature({
    required String userId,
    required String productName,
    required int investmentAmount,
    required String password,
    String? deviceInfo,
  }) {
    // 1. 서명 ID 생성 (UUID v4)
    final signatureId = _uuid.v4();
    
    // 2. 서명 일시 (현재 시간)
    final signedAt = DateTime.now();
    
    // 3. 서명 해시 생성
    final signatureHash = _generateSignatureHash(
      userId: userId,
      productName: productName,
      investmentAmount: investmentAmount,
      signedAt: signedAt,
      password: password,
    );
    
    // 4. 전자서명 기록 생성
    final signature = ElectronicSignature(
      signatureId: signatureId,
      userId: userId,
      productName: productName,
      investmentAmount: investmentAmount,
      signedAt: signedAt,
      signatureHash: signatureHash,
      deviceInfo: deviceInfo,
    );
    
    // 디버그 로그 (개발용)
    if (kDebugMode) {
      print('═══════════════════════════════════════════');
      print('  전자서명 생성 완료');
      print('═══════════════════════════════════════════');
      print('  서명 ID: $signatureId');
      print('  해시값: $signatureHash');
      print('  서명일시: ${signedAt.toIso8601String()}');
      print('═══════════════════════════════════════════');
    }
    
    return signature;
  }
  
  /// SHA256 해시 생성
  /// 
  /// 해시 입력 데이터:
  /// "OASIS_SIGN|{userId}|{productName}|{amount}|{timestamp}|{password}"
  /// 
  /// OASIS_SIGN: 솔트 역할의 고정 문자열
  static String _generateSignatureHash({
    required String userId,
    required String productName,
    required int investmentAmount,
    required DateTime signedAt,
    required String password,
  }) {
    // 해시 입력 데이터 조합
    final dataToHash = [
      'OASIS_SIGN',           // 솔트 (고정 문자열)
      userId,                  // 사용자 ID
      productName,             // 상품명
      investmentAmount.toString(), // 투자금액
      signedAt.toIso8601String(),  // 서명일시
      password,                // 비밀번호 (해시 생성 후 폐기)
    ].join('|');
    
    // SHA256 해시 생성
    final bytes = utf8.encode(dataToHash);
    final digest = sha256.convert(bytes);
    
    return digest.toString();
  }
  
  /// 전자서명 검증 (비밀번호 재확인용)
  /// 
  /// 동일한 입력값으로 해시를 재생성하여 기존 해시와 비교
  static bool verifySignature({
    required ElectronicSignature signature,
    required String password,
  }) {
    final regeneratedHash = _generateSignatureHash(
      userId: signature.userId,
      productName: signature.productName,
      investmentAmount: signature.investmentAmount,
      signedAt: signature.signedAt,
      password: password,
    );
    
    return regeneratedHash == signature.signatureHash;
  }
  
  /// 서명 요약 정보 생성 (화면 표시용)
  static String getSignatureSummary(ElectronicSignature signature) {
    final shortHash = signature.signatureHash.substring(0, 16);
    return '''
서명 ID: ${signature.signatureId.substring(0, 8)}...
서명일시: ${_formatDateTime(signature.signedAt)}
서명해시: $shortHash...
''';
  }
  
  static String _formatDateTime(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
           '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}

