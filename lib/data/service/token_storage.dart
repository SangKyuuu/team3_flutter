import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _key = 'accessToken';

  /// JWT 저장
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _key, value: token);
  }

  /// JWT 조회
  static Future<String?> getToken() async {
    return await _storage.read(key: _key);
  }

  /// JWT 삭제 (로그아웃 / 만료 시)
  static Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}