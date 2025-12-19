import 'package:dio/dio.dart';

import 'api_client.dart';

class MockApi {
  /// 사용자의 모의투자 계좌 존재 여부 확인
  static Future<bool> checkHasAccount() async {
    try {
      final response = await ApiClient.dio.get('/mock/account/status');
      if (response.statusCode == 200) {
        return response.data['hasAccount'] ?? false;
      }
      return false;
    } on DioException catch (e) {
      // 네트워크 타임아웃이나 서버 500 에러 등 처리
      print('Account Check Error: ${e.message}');
      rethrow; // 호출부(UI)에서 에러를 처리할 수 있게 던짐
    } catch (e) {
      print('Unexpected Error: $e');
      return false;
    }
  }

  /// 모의투자 계좌 생성 API
  static Future<bool> createMockAccount(int initialBalance) async {
    try {
      final response = await ApiClient.dio.post(
        '/mock/account',
        data: {'balance': initialBalance},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 사용자의 투자 성향 결과 조회
  static Future<String?> getInvestmentType() async {
    try {
      final response = await ApiClient.dio.get('/risk-test/result');
      if (response.statusCode == 200) {
        return response.data['riskType']; // 예: '적극투자형'
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// 모의투자 대시보드 요약 데이터 조회
  static Future<Map<String, dynamic>?> getMockDashboardSummary() async {
    try {
      final response = await ApiClient.dio.get('/mock/dashboard/summary');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}