import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token Storage Service
///
/// Singleton service for managing JWT tokens in secure storage.
/// Configured to prevent data persistence after app uninstall on both platforms.
/// Accessible from interceptors and repositories.
class TokenStorageService {
  static final TokenStorageService _instance = TokenStorageService._internal();
  factory TokenStorageService() => _instance;

  late final FlutterSecureStorage _secureStorage;

  TokenStorageService._internal() {
    _secureStorage = FlutterSecureStorage(
      // Android: Use encrypted SharedPreferences that won't survive app reinstall
      // when allowBackup is disabled in AndroidManifest.xml
      aOptions: _getAndroidOptions(),
      // iOS: Keychain data tied to app bundle identifier, deleted on uninstall
      iOptions: _getIOSOptions(),
    );
  }

  AndroidOptions _getAndroidOptions() {
    return const AndroidOptions(encryptedSharedPreferences: true);
  }

  IOSOptions _getIOSOptions() {
    return const IOSOptions(
      // Use default keychain access group tied to app bundle
      // Data will be deleted when app is uninstalled
      accessibility: KeychainAccessibility.first_unlock,
      synchronizable: false, // Don't sync to iCloud
    );
  }

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';
  static const String _sessionCreatedKey = 'session_created';

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
      _secureStorage.write(
        key: _tokenExpiryKey,
        value: expiry.toIso8601String(),
      ),
      if (userId != null) _secureStorage.write(key: _userIdKey, value: userId),
      _secureStorage.write(
        key: _sessionCreatedKey,
        value: DateTime.now().toIso8601String(),
      ),
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

  /// Get session creation time
  Future<DateTime?> getSessionCreated() async {
    final createdStr = await _secureStorage.read(key: _sessionCreatedKey);
    if (createdStr == null) return null;
    return DateTime.tryParse(createdStr);
  }

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _tokenExpiryKey),
      _secureStorage.delete(key: _userIdKey),
      _secureStorage.delete(key: _sessionCreatedKey),
    ]);
  }

  /// Check if user is authenticated (has tokens)
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    if (token == null) return false;
    return !(await isTokenExpired());
  }

  /// Check if session exists (for reinstall detection)
  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Delete all secure storage data (for testing or forced cleanup)
  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }
}
