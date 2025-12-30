import 'api_client.dart';

/// 카테고리 모델
/// Spring 서버에서 받아올 데이터 형식:
/// {
///   "categoryId": 1,
///   "categoryType": "INQUIRY",
///   "nameKo": "계좌개설",
///   "parentId": null,
///   "sort": 1,
///   "active": "Y"
/// }
class CategoryItem {
  final int categoryId;
  final String categoryType;
  final String nameKo;
  final int? parentId;
  final int sort;
  final String active;

  const CategoryItem({
    required this.categoryId,
    required this.categoryType,
    required this.nameKo,
    this.parentId,
    required this.sort,
    required this.active,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      categoryId: json['categoryId'] ?? 0,
      categoryType: json['categoryType'] ?? '',
      nameKo: json['nameKo'] ?? '',
      parentId: json['parentId'],
      sort: json['sort'] ?? 0,
      active: json['active'] ?? 'Y',
    );
  }
}

class CategoryApi {
  /// 문의 분류 카테고리 조회
  /// Spring 서버 요청: GET /category/inquiry
  /// Spring 서버 응답: List<CategoryItem> (JSON 배열, active='Y'만 필터링된 상태)
  static Future<List<CategoryItem>> fetchInquiryCategories() async {
    try {
      final response = await ApiClient.dio.get('/category/inquiry');
      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data as List;
        return data
            .map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
            .where((e) => e.active == 'Y')
            .toList();
      }
      return [];
    } catch (e) {
      // 에러 발생 시 기본 카테고리 반환 (개발용)
      return [
        const CategoryItem(
          categoryId: 1,
          categoryType: 'INQUIRY',
          nameKo: '계좌개설',
          sort: 1,
          active: 'Y',
        ),
        const CategoryItem(
          categoryId: 2,
          categoryType: 'INQUIRY',
          nameKo: '이용',
          sort: 2,
          active: 'Y',
        ),
        const CategoryItem(
          categoryId: 3,
          categoryType: 'INQUIRY',
          nameKo: '해지',
          sort: 3,
          active: 'Y',
        ),
        const CategoryItem(
          categoryId: 4,
          categoryType: 'INQUIRY',
          nameKo: '기타',
          sort: 4,
          active: 'Y',
        ),
      ];
    }
  }
}
