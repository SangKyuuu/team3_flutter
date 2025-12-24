import 'package:dio/dio.dart';
import 'package:team3/data/service/api_client.dart';
import 'package:team3/features/home/models/fund_data.dart';

/// 펀드 관련 API
class FundApi {
  /// 펀드 상세 정보 조회
  ///
  /// API: GET /api/fund/{fundCode}/detail
  static Future<Map<String, dynamic>> getFundDetail(String fundCode) async {
    try {
      final response = await ApiClient.dio.get(
        '/api/fund/$fundCode/detail',
      );

      // 상세는 보통 Map으로 옴
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }

      // 예외 케이스 대비
      return {};
    } on DioException catch (e) {
      print('펀드 상세 정보 조회 API 에러: ${e.message} (상태코드: ${e.response?.statusCode})');
      rethrow;
    } catch (e) {
      print('펀드 상세 정보 조회 예상치 못한 오류: $e');
      rethrow;
    }
  }

  /// 카테고리별 펀드 목록 조회
  /// category: 'sales' (판매량 best), 'yield' (수익률 best)
  ///
  /// API: GET /api/funds/category/{category}
  static Future<List<FundData>> getFundsByCategory(String category) async {
    try {
      final response = await ApiClient.dio.get(
        '/api/funds/category/$category',
      );

      if (response.statusCode != 200) return [];

      // 응답이 List거나, Map 안에 List가 있거나 둘 다 대응
      List<dynamic> data;

      if (response.data is List) {
        data = response.data as List<dynamic>;
      } else if (response.data is Map) {
        final responseData = response.data as Map;
        final inner = responseData['data'];
        if (inner is List) {
          data = inner;
        } else {
          print('예상치 못한 JSON 형식: data 필드가 없거나 List가 아님');
          print('응답 데이터: $responseData');
          return [];
        }
      } else {
        print('예상치 못한 JSON 형식: ${response.data.runtimeType}');
        print('응답 데이터: ${response.data}');
        return [];
      }

      return data.asMap().entries.map((entry) {
        final index = entry.key;
        final json = entry.value;

        if (json is! Map<String, dynamic>) {
          print('JSON 항목이 Map이 아님: ${json.runtimeType}');
          return null;
        }

        try {
          final fundData = FundData.fromJson(json);

          // 순위 없으면 인덱스로 생성(최대 10개 정도만)
          if (fundData.rankLabel.isEmpty && index < 10) {
            return FundData(
              title: fundData.title,
              subtitle: fundData.subtitle,
              rankLabel: '${index + 1}위',
              badge: fundData.badge,
              badge2: fundData.badge2,
              yieldText: fundData.yieldText,
            );
          }

          return fundData;
        } catch (e) {
          print('FundData 파싱 오류: $e, JSON: $json');
          return null;
        }
      }).whereType<FundData>().toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        print('펀드 목록 조회 타임아웃 (카테고리: $category)');
      } else if (e.type == DioExceptionType.connectionError) {
        print('펀드 목록 조회 연결 오류 (카테고리: $category)');
      } else {
        print(
          '펀드 목록 조회 오류: ${e.message} (카테고리: $category, 상태코드: ${e.response?.statusCode})',
        );
      }
      return [];
    } catch (e, stackTrace) {
      print('펀드 목록 조회 예상치 못한 오류: $e');
      print('스택 트레이스: $stackTrace');
      return [];
    }
  }
}
