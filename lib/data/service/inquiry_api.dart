import 'api_client.dart';

/// 문의 내역 모델
/// Spring 서버에서 받아올 데이터 형식:
/// {
///   "csId": 1,
///   "categoryId": 1,
///   "categoryName": "계좌개설",
///   "title": "계좌 개설 문의",
///   "question": "계좌 개설 방법을 알고 싶습니다",
///   "answer": null,
///   "status": "답변대기",
///   "userId": "user123",
///   "createdAt": "2024-01-15T10:30:00",
///   "answeredAt": null
/// }
class InquiryItem {
  final int csId;
  final int categoryId;
  final String categoryName;
  final String? title;
  final String question;
  final String? answer;
  final String? status;
  final String? userId;
  final DateTime createdAt;
  final DateTime? answeredAt;

  const InquiryItem({
    required this.csId,
    required this.categoryId,
    required this.categoryName,
    this.title,
    required this.question,
    this.answer,
    this.status,
    this.userId,
    required this.createdAt,
    this.answeredAt,
  });

  factory InquiryItem.fromJson(Map<String, dynamic> json) {
    return InquiryItem(
      csId: json['csId'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      title: json['title'],
      question: json['question'] ?? '',
      answer: json['answer'],
      status: json['status'] ?? '답변대기',
      userId: json['userId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      answeredAt: json['answeredAt'] != null
          ? DateTime.parse(json['answeredAt'])
          : null,
    );
  }

  String get statusText {
    return status ?? '답변대기';
  }

  bool get isAnswered {
    return status == '답변완료' || answer != null;
  }
}

class InquiryApi {
  /// 내 문의 내역 조회
  /// Spring 서버 요청: GET /inquiry/my
  /// Spring 서버 응답: List<InquiryItem> (JSON 배열)
  static Future<List<InquiryItem>> fetchMyInquiries() async {
    try {
      final response = await ApiClient.dio.get('/inquiry/my');
      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data as List;
        return data
            .map((e) => InquiryItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 문의 등록
  /// Spring 서버 요청: POST /inquiry
  /// 요청 Body: { "categoryId": 1, "title": "...", "question": "..." }
  /// Spring 서버 응답: 성공 시 200 또는 201
  static Future<bool> submitInquiry({
    required int categoryId,
    String? title,
    required String question,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/inquiry',
        data: {
          'categoryId': categoryId,
          'title': title,
          'question': question,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
