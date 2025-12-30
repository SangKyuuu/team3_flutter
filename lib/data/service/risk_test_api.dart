import 'package:team3/data/service/api_client.dart';
import 'package:dio/dio.dart';

/// 투자성향 조사(RISK_TEST_RESULT) 관련 API
/// 
/// TODO: 백엔드 API 구현 후 실제 호출 코드로 교체 필요
class RiskTestApi {
  /// 오늘 해당 사용자가 투자성향 조사를 완료했는지 확인
  /// 
  /// 서버에서 DB의 RISK_TEST_RESULT 테이블을 조회하여
  /// CUST_NO + TEST_DATE(오늘 날짜)로 검사
  /// 
  /// [custNo] 고객 번호 (CUST_NO) - 현재는 사용하지 않음 (서버에서 세션 또는 하드코딩된 값 사용)
  /// [userId] 사용자 ID (USER_ID) - 선택적, 현재는 사용하지 않음
  /// 
  /// Returns:
  /// - `hasCompletedToday`: 오늘 조사 완료 여부 (boolean)
  /// - `latestResult`: 기존 결과가 있으면 반환 (null 가능)
  ///   - `testRunId`: 테스트 실행 ID
  ///   - `totalScore`: 총 점수
  ///   - `riskType`: 투자 성향
  ///   - `testDate`: 테스트 일시
  /// 
  /// API: GET /api/funds/risk-test/check
  /// 
  /// 응답 형식:
  /// {
  ///   "hasCompletedToday": true/false,
  ///   "latestResult": {
  ///     "testRunId": "REQ_20250116_00001",
  ///     "totalScore": 20,
  ///     "riskType": "위험중립형",
  ///     "testDate": "2025-01-16T10:30:00"
  ///   } 또는 null
  /// }
  static Future<Map<String, dynamic>> checkToday({
    required int custNo,
    String? userId,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/api/funds/risk-test/check',
        // queryParameters는 필요 없음 (서버에서 세션 또는 하드코딩된 custNo 사용)
      );

      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        return {
          'hasCompletedToday': data['hasCompletedToday'] ?? false,
          'latestResult': data['latestResult'], // null 가능
        };
      }
      
      return {
        'hasCompletedToday': false,
        'latestResult': null,
      };
    } catch (e) {
      // API 에러 발생 시 조사 가능하도록 false 반환
      print('투자성향 조사 확인 API 에러: $e');
      return {
        'hasCompletedToday': false,
        'latestResult': null,
      };
    }
  }

  /// 투자성향 조사 결과 저장
  /// 
  /// 서버에서 RISK_TEST_RESULT 테이블에 INSERT
  /// 
  /// [totalScore] 총 점수 (TOTAL_SCORE)
  /// [riskType] 투자 성향 (RISK_TYPE)
  /// 
  /// 서버에서 자동 처리:
  /// - TEST_RUN_ID: 시퀀스로 자동 생성
  /// - TEST_DATE: 현재 시간으로 자동 설정
  /// - END_DATE: 유효기간 계산하여 자동 설정
  /// - CUST_NO: 서버에서 세션 또는 하드코딩된 값 사용
  /// 
  /// API: POST /api/funds/risk-test/save
  /// 
  /// 요청 형식:
  /// {
  ///   "totalScore": 20,
  ///   "riskType": "위험중립형"
  /// }
  /// 
  /// 응답 형식:
  /// {
  ///   "success": true,
  ///   "message": "투자성향 조사 결과가 저장되었습니다."
  /// }
  static Future<bool> saveTestResult({
    required int totalScore,
    required String riskType,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/api/funds/risk-test/save',
        data: {
          'totalScore': totalScore,
          'riskType': riskType,
        },
      );

      // 성공 여부 반환
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        return data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      print('투자성향 조사 결과 저장 API 에러: ${e.message}');
      if (e.response != null) {
        print('에러 응답 상태 코드: ${e.response?.statusCode}');
        print('에러 응답 데이터: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('투자성향 조사 결과 저장 예상치 못한 오류: $e');
      rethrow;
    }
  }
}

