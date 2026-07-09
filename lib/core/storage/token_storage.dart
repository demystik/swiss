import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  // static const _keyUser = 'user_data';

  //Save Token
  Future<void> saveToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  //Get Access Token
  Future<String?> getAccessToken() async{
    return await _storage.read(key: _keyAccessToken);
  }

  //Get Refresh Token
  Future<String?> getRefreshToken() async{
    return await _storage.read(key: _keyRefreshToken);
  }

  //Delete all tokens
  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
