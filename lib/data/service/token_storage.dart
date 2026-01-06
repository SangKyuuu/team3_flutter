import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _key = 'accessToken';

  /// JWT 저장 (로그인 성공 시)
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _key, value: token);
  }

  /// JWT 조회 (자동 로그인 / API 인터셉터)
  static Future<String?> getToken() async {
    return await _storage.read(key: _key);
  }

  /// JWT 삭제 (로그아웃 / 만료 시)
  static Future<void> clearToken() async {
    await _storage.delete(key: _key);
  }
}
