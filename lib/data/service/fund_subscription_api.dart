import 'package:team3/data/service/api_client.dart';

/// 펀드 가입 관련 API
/// 
/// USER_FUND_TRANSACTION 테이블 구조에 맞춘 API
/// 
/// TODO: 백엔드 API 구현 후 실제 호출 코드로 교체 필요
class FundSubscriptionApi {
  /// 펀드 가입 (거래 내역 생성)
  /// 
  /// API: POST /api/fund/subscribe
  /// 
  /// USER_FUND_TRANSACTION 테이블에 INSERT
  /// 
  /// [acctNo] 계좌 번호 (ACCT_NO) - VARCHAR2(30)
  /// [fundCode] 펀드 코드 (FUND_CODE) - VARCHAR2(20)
  /// [tradeType] 거래 유형 (TRADE_TYPE) - VARCHAR2(10) - 예: "가입", "매수"
  /// [tradeAmount] 거래 금액 (TRADE_AMOUNT) - NUMBER(20,0)
  /// [investmentSchedule] 투자 주기 ("매일", "매주", "매월", "한 번만") - 자동이체 스케줄용
  /// [weeklyDay] 주간 투자 요일 (매주인 경우, 예: "월요일") - 자동이체 스케줄용
  /// [monthlyDay] 월간 투자 일자 (매월인 경우, 예: 15) - 자동이체 스케줄용
  /// [signatureId] 전자서명 ID - 전자서명 정보 저장용
  /// [signatureHash] 전자서명 해시 - 전자서명 정보 저장용
  /// 
  /// 서버에서 자동 처리:
  /// - TRX_ID: 시퀀스로 자동 생성 (NUMBER(15,0))
  /// - TRADE_DATE: 현재 시간으로 자동 설정 (거래 발생일)
  /// - SETTLE_DATE: 결제 완료일 계산하여 자동 설정
  /// - TRADE_UNIT: 거래 금액 / NAV로 계산하여 자동 설정 (NUMBER(18,0))
  /// - APPLY_NAV: 현재 NAV 조회하여 자동 설정 (NUMBER(10,4))
  /// 
  /// Returns: 가입 결과
  /// 
  /// 예상 응답 형식:
  /// {
  ///   "success": true,
  ///   "trxId": 123456789012345,  // TRX_ID
  ///   "tradeDate": "2025-01-16T10:30:00",
  ///   "settleDate": "2025-01-17T00:00:00",
  ///   "tradeUnit": 100.5,  // 계산된 좌수
  ///   "applyNav": 9950.25,  // 적용된 NAV
  ///   "message": "가입이 완료되었습니다."
  /// }
  static Future<Map<String, dynamic>> subscribe({
    required String acctNo,
    required String fundCode,
    required String tradeType,  // "가입", "매수" 등
    required int tradeAmount,
    required String investmentSchedule,  // 자동이체 스케줄용
    String? weeklyDay,
    int? monthlyDay,
    required String signatureId,
    required String signatureHash,
  }) async {
    // TODO: 백엔드 API 구현 후 아래 주석 해제하고 실제 호출
    /*
    try {
      final response = await ApiClient.dio.post(
        '/api/fund/subscribe', // TODO: 실제 엔드포인트 경로 확인
        data: {
          'acctNo': acctNo,  // ACCT_NO
          'fundCode': fundCode,  // FUND_CODE
          'tradeType': tradeType,  // TRADE_TYPE
          'tradeAmount': tradeAmount,  // TRADE_AMOUNT
          'investmentSchedule': investmentSchedule,  // 자동이체 스케줄 정보
          if (weeklyDay != null) 'weeklyDay': weeklyDay,
          if (monthlyDay != null) 'monthlyDay': monthlyDay,
          'signatureId': signatureId,  // 전자서명 정보
          'signatureHash': signatureHash,  // 전자서명 정보
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('펀드 가입 API 에러: $e');
      rethrow;
    }
    */
    
    // 임시: 성공으로 처리 (실제 가입은 하지 않음)
    print('펀드 가입 (임시): acctNo=$acctNo, fundCode=$fundCode, tradeAmount=$tradeAmount, tradeType=$tradeType');
    return {
      'success': true,
      'trxId': 0,  // 임시 값
      'tradeDate': DateTime.now().toIso8601String(),
      'settleDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'tradeUnit': 0.0,  // 임시 값
      'applyNav': 0.0,  // 임시 값
      'message': '가입이 완료되었습니다.',
    };
  }
}

