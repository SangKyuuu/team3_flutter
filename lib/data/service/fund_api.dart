import 'package:team3/data/service/api_client.dart';

/// 펀드 관련 API
/// 
/// TODO: 백엔드 API 구현 후 실제 호출 코드로 교체 필요
class FundApi {
  /// 펀드 상세 정보 조회
  /// 
  /// API: GET /api/fund/{fundCode}/detail
  /// 
  /// [fundCode] 펀드 코드
  /// 
  /// Returns: 펀드 상세 정보
  /// 
  /// 예상 응답 형식:
  /// {
  ///   "fundCode": "FUND001",
  ///   "title": "펀드명",
  ///   "subtitle": "부제목",
  ///   "badge": "위험도",
  ///   "yieldText": "수익률",
  ///   "description": "펀드 설명",
  ///   "documents": [
  ///     {
  ///       "title": "핵심상품설명서",
  ///       "type": "core",
  ///       "pdfUrl": "https://..."
  ///     },
  ///     ...
  ///   ],
  ///   ...
  /// }
  static Future<Map<String, dynamic>> getFundDetail(String fundCode) async {
    // TODO: 백엔드 API 구현 후 아래 주석 해제하고 실제 호출
    /*
    try {
      final response = await ApiClient.dio.get(
        '/api/fund/$fundCode/detail', // TODO: 실제 엔드포인트 경로 확인
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('펀드 상세 정보 조회 API 에러: $e');
      rethrow;
    }
    */
    
    // 임시: 빈 맵 반환 (실제 조회는 하지 않음)
    print('펀드 상세 정보 조회 (임시): fundCode=$fundCode');
    return {};
  }
}

