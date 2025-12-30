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
              fundCode: fundData.fundCode,  // fundCode 유지
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

  /// 보유펀드 목록 조회
  ///
  /// API: GET /api/funds/my
  /// Spring API에서 현재 로그인한 사용자의 보유펀드 목록을 조회합니다.
  static Future<List<Map<String, dynamic>>> getMyFunds() async {
    try {
      final response = await ApiClient.dio.get(
        '/api/funds/my',
      );

      if (response.statusCode != 200) {
        print('보유펀드 목록 조회 실패: 상태코드 ${response.statusCode}');
        return [];
      }

      // 응답이 List인 경우
      if (response.data is List) {
        return (response.data as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      // 응답이 Map이고 data 필드에 List가 있는 경우
      if (response.data is Map) {
        final responseData = response.data as Map;
        final data = responseData['data'];
        
        if (data is List) {
          return data
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        }
      }

      print('예상치 못한 JSON 형식: ${response.data.runtimeType}');
      print('응답 데이터: ${response.data}');
      return [];
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        print('보유펀드 목록 조회 타임아웃');
      } else if (e.type == DioExceptionType.connectionError) {
        print('보유펀드 목록 조회 연결 오류');
      } else {
        print(
          '보유펀드 목록 조회 오류: ${e.message} (상태코드: ${e.response?.statusCode})',
        );
        if (e.response?.data != null) {
          print('에러 응답 데이터: ${e.response?.data}');
        }
      }
      rethrow;
    } catch (e, stackTrace) {
      print('보유펀드 목록 조회 예상치 못한 오류: $e');
      print('스택 트레이스: $stackTrace');
      rethrow;
    }
  }

  /// 보유펀드 상세 정보 조회
  ///
  /// API: GET /api/funds/my/{fundCode}/detail
  /// Spring API에서 현재 로그인한 사용자의 특정 보유펀드 상세 정보를 조회합니다.
  static Future<Map<String, dynamic>> getMyFundDetail(String fundCode) async {
    try {
      final response = await ApiClient.dio.get(
        '/api/funds/my/$fundCode/detail',
      );

      if (response.statusCode != 200) {
        print('보유펀드 상세 조회 실패: 상태코드 ${response.statusCode}');
        return {};
      }

      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }

      return {};
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 404) {
        print('보유펀드 상세 조회: API가 아직 구현되지 않았습니다 (404)');
        return {}; // 404는 빈 데이터 반환
      }
      print('보유펀드 상세 조회 오류: ${e.message} (상태코드: $statusCode)');
      return {}; // 에러 발생 시 빈 데이터 반환
    } catch (e) {
      print('보유펀드 상세 조회 예상치 못한 오류: $e');
      return {}; // 에러 발생 시 빈 데이터 반환
    }
  }

  /// 보유펀드 수익률 히스토리 조회
  ///
  /// API: GET /api/funds/my/{fundCode}/profit-history?period={period}
  /// period: '1M', '3M', '6M', '1Y', 'ALL'
  static Future<List<Map<String, dynamic>>> getMyFundProfitHistory(
    String fundCode,
    String period,
  ) async {
    try {
      final response = await ApiClient.dio.get(
        '/api/funds/my/$fundCode/profit-history',
        queryParameters: {'period': period},
      );

      if (response.statusCode != 200) {
        print('수익률 히스토리 조회 실패: 상태코드 ${response.statusCode}');
        return [];
      }

      if (response.data is List) {
        return (response.data as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      if (response.data is Map) {
        final responseData = response.data as Map;
        final data = responseData['data'];
        
        if (data is List) {
          return data
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 404) {
        print('수익률 히스토리 조회: API가 아직 구현되지 않았습니다 (404)');
        return []; // 404는 빈 리스트 반환
      }
      print('수익률 히스토리 조회 오류: ${e.message} (상태코드: $statusCode)');
      return [];
    } catch (e) {
      print('수익률 히스토리 조회 예상치 못한 오류: $e');
      return [];
    }
  }

  /// 보유펀드 거래 내역 조회
  ///
  /// API: GET /api/funds/my/{fundCode}/transactions
  static Future<List<Map<String, dynamic>>> getMyFundTransactions(
    String fundCode,
  ) async {
    try {
      final response = await ApiClient.dio.get(
        '/api/funds/my/$fundCode/transactions',
      );

      if (response.statusCode != 200) {
        print('거래 내역 조회 실패: 상태코드 ${response.statusCode}');
        return [];
      }

      if (response.data is List) {
        return (response.data as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      if (response.data is Map) {
        final responseData = response.data as Map;
        final data = responseData['data'];
        
        if (data is List) {
          return data
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 404) {
        print('거래 내역 조회: API가 아직 구현되지 않았습니다 (404)');
        return []; // 404는 빈 리스트 반환
      }
      print('거래 내역 조회 오류: ${e.message} (상태코드: $statusCode)');
      return [];
    } catch (e) {
      print('거래 내역 조회 예상치 못한 오류: $e');
      return [];
    }
  }
}
