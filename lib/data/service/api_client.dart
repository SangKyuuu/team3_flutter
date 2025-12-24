import 'package:dio/dio.dart';
import 'token_storage.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080/bnk', // 🔥 서버 주소
      connectTimeout: const Duration(seconds: 15), // 타임아웃 시간 증가
      receiveTimeout: const Duration(seconds: 15), // 타임아웃 시간 증가
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 🔐 JWT 자동 첨부
        final token = await TokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },

      onError: (error, handler) {
        //  401 → 토큰 만료/위조
        if (error.response?.statusCode == 401) {
          // 나중에 자동 로그아웃 처리 가능
        }
        return handler.next(error);
      },
    ),
  );
}
