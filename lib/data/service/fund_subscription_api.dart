import 'package:team3/data/service/api_client.dart';
import 'package:dio/dio.dart';

/// 펀드 가입 관련 API
/// 
/// 백엔드 API: POST /api/funds/subscribe
class FundSubscriptionApi {
  /// 펀드 가입 (거래 내역 생성)
  /// 
  /// [fundCode] 펀드 코드
  /// [tradeAmount] 투자 금액
  /// [investmentType] "한 번만 투자하기" 또는 "매일, 매주, 매월 투자하기"
  /// [cycleType] "매일", "매주", "매월" (자동이체인 경우만)
  /// [weeklyDay] "월요일", "화요일" 등 (매주인 경우만)
  /// [monthlyDay] 1~31 (매월인 경우만)
  /// 
  /// Returns: 가입 결과
  /// {
  ///   "success": true,
  ///   "orderId": 123456789012345,
  ///   "message": "펀드 가입이 완료되었습니다."
  /// }
  static Future<Map<String, dynamic>> subscribe({
    required String fundCode,
    required int tradeAmount,
    required String investmentType,
    String? cycleType,
    String? weeklyDay,
    int? monthlyDay,
  }) async {
    try {
      // 요일 변환 (매주인 경우만)
      int? weekday;
      if (weeklyDay != null && cycleType == "매주") {
        weekday = _convertWeekdayToNumber(weeklyDay);
      }
      
      final requestData = {
        'fundCode': fundCode,
        'amount': tradeAmount,
        'investmentType': investmentType,
        if (cycleType != null) 'cycleType': cycleType,
        if (weekday != null) 'weekday': weekday,
        if (monthlyDay != null) 'dayOfMonth': monthlyDay,
        // custNo, acctNo는 백엔드에서 하드코딩 사용하므로 전달하지 않음
      };
      
      print('펀드 가입 API 요청 데이터: $requestData');
      
      final response = await ApiClient.dio.post(
        '/api/funds/subscribe',
        data: requestData,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('펀드 가입 API 에러: $e');
      if (e is DioException && e.response != null) {
        print('에러 응답 상태 코드: ${e.response?.statusCode}');
        print('에러 응답 데이터: ${e.response?.data}');
      }
      rethrow;
    }
  }
  
  /// 요일 문자열을 숫자로 변환 (월요일=1, 화요일=2, ..., 일요일=7)
  static int _convertWeekdayToNumber(String weekday) {
    const weekdayMap = {
      '월요일': 1,
      '화요일': 2,
      '수요일': 3,
      '목요일': 4,
      '금요일': 5,
      '토요일': 6,
      '일요일': 7,
    };
    return weekdayMap[weekday] ?? 1;
  }
}

