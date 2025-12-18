import 'api_client.dart';

class MockApi {
  /// 사용자의 모의투자 계좌 존재 여부 확인
  static Future<bool> checkHasAccount() async {
    try {
      // 서버의 계좌 조회 엔드포인트 호출 (예: /mock/account/status)
      final response = await ApiClient.dio.get('/mock/account/status');

      if (response.statusCode == 200) {
        // 서버에서 'hasAccount': true/false 식으로 응답을 준다고 가정
        return response.data['hasAccount'] ?? false;
      }
      return false;
    } catch (e) {
      // 계좌가 없는 경우 404 에러가 발생할 수 있으므로 false 반환
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