import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token Storage Service
/// 
/// Singleton service for managing JWT tokens in secure storage.
/// Accessible from interceptors and repositories.
class TokenStorageService {
  static final TokenStorageService _instance = TokenStorageService._internal();
  factory TokenStorageService() => _instance;
  TokenStorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';

  /// Save tokens after successful authentication
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresInSeconds,
    String? userId,
  }) async {
    final expiry = DateTime.now().add(Duration(seconds: expiresInSeconds));
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
      _secureStorage.write(key: _tokenExpiryKey, value: expiry.toIso8601String()),
      if (userId != null) _secureStorage.write(key: _userIdKey, value: userId),
    ]);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  /// Get token expiry
  Future<DateTime?> getTokenExpiry() async {
    final expiryStr = await _secureStorage.read(key: _tokenExpiryKey);
    if (expiryStr == null) return null;
    return DateTime.tryParse(expiryStr);
  }

  /// Check if token is expired
  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  /// Get stored user ID
  Future<String?> getUserId() async {
    return _secureStorage.read(key: _userIdKey);
  }

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _tokenExpiryKey),
      _secureStorage.delete(key: _userIdKey),
    ]);
  }

  /// Check if user is authenticated (has tokens)
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    if (token == null) return false;
    return !(await isTokenExpired());
  }
}
