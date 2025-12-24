import 'package:team3/data/service/api_client.dart';

/// 투자성향 조사(RISK_TEST_RESULT) 관련 API
/// 
/// TODO: 백엔드 API 구현 후 실제 호출 코드로 교체 필요
class RiskTestApi {
  /// 오늘 해당 사용자가 투자성향 조사를 완료했는지 확인
  /// 
  /// 서버에서 DB의 RISK_TEST_RESULT 테이블을 조회하여
  /// CUST_NO + TEST_DATE(오늘 날짜)로 검사
  /// 
  /// [custNo] 고객 번호 (CUST_NO)
  /// [userId] 사용자 ID (USER_ID) - 선택적
  /// 
  /// Returns:
  /// - `hasCompletedToday`: 오늘 조사 완료 여부 (boolean)
  /// - `latestResult`: 기존 결과가 있으면 반환 (null 가능)
  ///   - `testRunId`: 테스트 실행 ID
  ///   - `totalScore`: 총 점수
  ///   - `riskType`: 투자 성향
  ///   - `testDate`: 테스트 일시
  /// 
  /// TODO: 백엔드 API 엔드포인트 확인 후 구현
  /// 예상 API: GET /api/risk-test/check-today?custNo={custNo}&userId={userId}
  /// 
  /// 예상 응답 형식:
  /// {
  ///   "hasCompletedToday": true/false,
  ///   "latestResult": {
  ///     "testRunId": "TEST_001",
  ///     "totalScore": 20,
  ///     "riskType": "위험중립형",
  ///     "testDate": "2025-01-16T10:30:00"
  ///   } 또는 null
  /// }
  static Future<Map<String, dynamic>> checkToday({
    required int custNo,
    String? userId,
  }) async {
    // TODO: 백엔드 API 구현 후 아래 주석 해제하고 실제 호출
    /*
    try {
      final response = await ApiClient.dio.get(
        '/api/risk-test/check-today', // TODO: 실제 엔드포인트 경로 확인
        queryParameters: {
          'custNo': custNo,
          if (userId != null) 'userId': userId,
        },
      );

      return {
        'hasCompletedToday': response.data['hasCompletedToday'] ?? false,
        'latestResult': response.data['latestResult'], // null 가능
      };
    } catch (e) {
      // API 에러 발생 시 조사 가능하도록 false 반환
      print('투자성향 조사 확인 API 에러: $e');
      return {
        'hasCompletedToday': false,
        'latestResult': null,
      };
    }
    */
    
    // 임시: 항상 조사 가능하도록 false 반환
    return {
      'hasCompletedToday': false,
      'latestResult': null,
    };
  }

  /// 투자성향 조사 결과 저장
  /// 
  /// 서버에서 RISK_TEST_RESULT 테이블에 INSERT
  /// 
  /// [custNo] 고객 번호 (CUST_NO)
  /// [userId] 사용자 ID (USER_ID) - 선택적
  /// [totalScore] 총 점수 (TOTAL_SCORE)
  /// [riskType] 투자 성향 (RISK_TYPE)
  /// 
  /// 서버에서 자동 처리:
  /// - TEST_RUN_ID: 시퀀스로 자동 생성
  /// - TEST_DATE: 현재 시간으로 자동 설정
  /// - END_DATE: 유효기간 계산하여 자동 설정
  /// 
  /// Returns 저장된 테스트 실행 ID (TEST_RUN_ID)
  /// 
  /// TODO: 백엔드 API 엔드포인트 확인 후 구현
  /// 예상 API: POST /api/risk-test/save
  /// 
  /// 예상 요청 형식:
  /// {
  ///   "custNo": 1,
  ///   "userId": "user001" (선택적),
  ///   "totalScore": 20,
  ///   "riskType": "위험중립형"
  /// }
  /// 
  /// 예상 응답 형식:
  /// {
  ///   "testRunId": "TEST_001"
  /// }
  static Future<String> saveTestResult({
    required int custNo,
    String? userId,
    required int totalScore,
    required String riskType,
  }) async {
    // TODO: 백엔드 API 구현 후 아래 주석 해제하고 실제 호출
    /*
    try {
      final response = await ApiClient.dio.post(
        '/api/risk-test/save', // TODO: 실제 엔드포인트 경로 확인
        data: {
          'custNo': custNo,
          if (userId != null) 'userId': userId,
          'totalScore': totalScore,
          'riskType': riskType,
        },
      );

      // 서버에서 TEST_RUN_ID를 반환
      return response.data['testRunId'] ?? '';
    } catch (e) {
      print('투자성향 조사 결과 저장 API 에러: $e');
      rethrow;
    }
    */
    
    // 임시: 성공으로 처리 (실제 저장은 하지 않음)
    print('투자성향 조사 결과 저장 (임시): custNo=$custNo, totalScore=$totalScore, riskType=$riskType');
    return 'TEMP_TEST_RUN_ID';
  }
}

