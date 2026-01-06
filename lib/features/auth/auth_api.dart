import 'package:team3/data/service/api_client.dart';

class AuthApi {
  /// 회원가입
  static Future<void> signup(Map<String, dynamic> data) async {
    await ApiClient.dio.post(
      '/api/auth/signup',
      data: data,
    );
  }
}
