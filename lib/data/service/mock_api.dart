import 'package:dio/dio.dart';

import 'api_client.dart';

class MockApi {

  // 현재 로그인 기능이 없으므로 테스트용 고정 ID (나중에는 세션/토큰에서 가져옴)
  static const int testCustNo = 22;

  /// 사용자의 모의투자 계좌 존재 여부 확인
  static Future<bool> checkHasAccount() async {
    try {
      // 백엔드 경로: /api/mock/account/check/{custNo}
      final response = await ApiClient.dio.get('/api/mock/account/check/$testCustNo');

      if (response.statusCode == 200) {
        // 백엔드에서 Map<String, Object>로 hasAccount 반환함
        return response.data['hasAccount'] ?? false;
      }
      return false;
    } on DioException catch (e) {
      print('Account Check Error: ${e.message}');
      return false;
    }
  }

  /// 모의투자 계좌 생성 API
  /// 백엔드 DTO: custNo, acctPass, balance 필요
  static Future<bool> createMockAccount(int initialBalance, String password) async {
    try {
      final response = await ApiClient.dio.post(
        '/api/mock/account/create',
        data: {
          'custNo': testCustNo,
          'acctPass': password,
          'balance': initialBalance,
        },
      );
      // 백엔드에서 success 여부를 반환함
      return response.data['success'] ?? false;
    } catch (e) {
      print('Create Account Error: $e');
      return false;
    }
  }

  /// 사용자의 투자 성향 결과 조회
  static Future<String?> getInvestmentType() async {
    try {
      // 백엔드 경로: /api/mock/account/risk-type/{custNo}
      final response = await ApiClient.dio.get('/api/mock/account/risk-type/$testCustNo');
      if (response.statusCode == 200) {
        return response.data['riskType'];
      }
    } catch (e) {
      print('Risk Type Fetch Error: $e');
      return "분석 불가";
    }
    return null;
  }

  /// 모의투자 대시보드 요약 데이터 조회
  static Future<Map<String, dynamic>?> getMockDashboardSummary() async {
    try {
      // 백엔드 경로가 /api/mock/account/summary/{custNo} 인 경우
      final response = await ApiClient.dio.get('/api/mock/account/summary/${testCustNo}');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print('Dashboard Fetch Error: $e');
      return null; // null을 반환하면 UI에서 _hasError가 true가 됩니다.
    }
    return null;
  }

}