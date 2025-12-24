import 'package:dio/dio.dart';
import 'package:team3/data/service/api_client.dart';
import 'package:team3/features/home/models/fund_data.dart';

class FundApi {
  /// 카테고리별 펀드 목록 조회
  /// category: 'sales' (판매량 best), 'yield' (수익률 best)
  static Future<List<FundData>> getFundsByCategory(String category) async {
    try {
      final response = await ApiClient.dio.get(
        '/api/funds/category/$category',
      );

      if (response.statusCode == 200) {
        // JSON 응답 형식에 따라 안전하게 파싱
        List<dynamic> data;
        
        if (response.data is List) {
          // 응답이 배열로 직접 오는 경우: [{...}, {...}]
          data = response.data as List<dynamic>;
        } else if (response.data is Map) {
          final responseData = response.data as Map<String, dynamic>;
          if (responseData['data'] != null && responseData['data'] is List) {
            // 응답이 객체로 오고 data 필드에 배열이 있는 경우: {"data": [{...}, {...}]}
            data = responseData['data'] as List<dynamic>;
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
          try {
            if (json is Map<String, dynamic>) {
              final fundData = FundData.fromJson(json);
              // 스프링 데이터에 순위 정보가 없으면 인덱스 기반으로 생성
              if (fundData.rankLabel.isEmpty && index < 10) {
                // rankLabel이 비어있으면 인덱스 기반 순위 생성 (최대 10개)
                // const가 아닌 일반 생성자 사용
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
            } else {
              print('JSON 항목이 Map이 아님: ${json.runtimeType}');
              return null;
            }
          } catch (e) {
            print('FundData 파싱 오류: $e, JSON: $json');
            return null;
          }
        }).whereType<FundData>().toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        print('펀드 목록 조회 타임아웃: 서버 응답이 너무 느립니다. (카테고리: $category)');
      } else if (e.type == DioExceptionType.connectionError) {
        print('펀드 목록 조회 연결 오류: 서버에 연결할 수 없습니다. (카테고리: $category)');
      } else {
        print('펀드 목록 조회 오류: ${e.message} (카테고리: $category, 상태코드: ${e.response?.statusCode})');
      }
      return [];
    } catch (e, stackTrace) {
      print('펀드 목록 조회 예상치 못한 오류: $e');
      print('스택 트레이스: $stackTrace');
      return [];
    }
  }
}