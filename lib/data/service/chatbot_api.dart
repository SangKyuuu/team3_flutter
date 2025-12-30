import 'api_client.dart';

/// 챗봇 메시지 모델
/// Spring 서버로 전송할 요청 형식:
/// {
///   "message": "사용자 메시지",
///   "conversationId": "대화 세션 ID (선택)"
/// }
/// 
/// Spring 서버에서 받아올 응답 형식:
/// {
///   "reply": "봇 응답",
///   "conversationId": "대화 세션 ID"
/// }
/// 
/// Spring 서버 구현 가이드:
/// 1. 사용자 메시지 수신
/// 2. 펀드 상품 DB에서 관련 정보 검색 (키워드 기반 또는 벡터 검색)
/// 3. 검색된 펀드 정보를 컨텍스트로 준비
/// 4. OpenAI GPT API 호출:
///    - System Prompt: "당신은 펀드 투자 상담 챗봇입니다. 
///                      제공된 펀드 상품 정보를 바탕으로 친절하게 답변하세요.
///                      일상적인 대화도 가능하지만, 펀드 관련 질문에는 정확한 정보를 제공하세요."
///    - User Message: 검색된 펀드 정보 + 사용자 질문
/// 5. GPT 응답을 받아서 반환
class ChatbotApi {
  /// 챗봇에게 메시지 전송 및 응답 받기
  /// 
  /// Spring 서버 처리 흐름:
  /// 1. 사용자 메시지 분석 (펀드 관련 키워드 추출)
  /// 2. 펀드 상품 DB 검색 (상품명, 설명, 수익률 등)
  /// 3. 검색된 펀드 정보를 GPT에 컨텍스트로 전달
  /// 4. GPT가 펀드 정보를 참조하여 답변 생성
  /// 5. 일상 대화는 펀드 정보 없이 일반적으로 응답
  /// 
  /// Spring 서버 요청: POST /chatbot/message
  /// Spring 서버에서 OpenAI API 호출하여 GPT 응답 받아옴
  static Future<String?> sendMessage(String message, {String? conversationId}) async {
    try {
      final response = await ApiClient.dio.post(
        '/chatbot/message',
        data: {
          'message': message,
          if (conversationId != null) 'conversationId': conversationId,
        },
      );

      if (response.statusCode == 200) {
        return response.data['reply'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

