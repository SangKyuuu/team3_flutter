import 'package:team3/data/service/api_client.dart';

class AuthApi {
  static Future<String> login(String userId, String password) async {
    final response = await ApiClient.dio.post(
      '/api/auth/login',
      data: {
        'userId': userId,
        'password': password,
      },
    );

    return response.data['accessToken'];
  }

  static Future<void> me() async {
    await ApiClient.dio.get('/api/auth/me');
  }
}
