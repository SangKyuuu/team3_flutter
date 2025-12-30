import 'api_client.dart';

class FaqItem {
  final String question;
  final String answer;

  const FaqItem({
    required this.question,
    required this.answer,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}

class FaqApi {
  /// FAQ 리스트 조회 (Spring 서버 연동)
  static Future<List<FaqItem>> fetchFaqs() async {
    final response = await ApiClient.dio.get('/faq');
    if (response.statusCode == 200 && response.data is List) {
      final List data = response.data as List;
      return data
          .map((e) => FaqItem.fromJson(e as Map<String, dynamic>))
          .where((e) => e.question.isNotEmpty)
          .toList();
    }
    return [];
  }
}






