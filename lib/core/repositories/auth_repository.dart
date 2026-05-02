import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../providers/api_provider.dart';
import '../api/api_exceptions.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';
import '../models/trusted_contact_model.dart';
import '../services/token_storage_service.dart';
import 'base_repository.dart';

/// Auth Repository
///
/// Handles OTP authentication, token management, and user profile operations.
/// Uses secure storage for token persistence via TokenStorageService.
class AuthRepository extends BaseRepository {
  final ApiClient _apiClient;
  final TokenStorageService _tokenStorage;

  AuthRepository(this._apiClient) : _tokenStorage = TokenStorageService();

  /// Request OTP for phone verification
  Future<Map<String, dynamic>> requestOtp(
    String phoneNumber, {
    String countryCode = '+1',
  }) async {
    return execute(() async {
      final response = await _apiClient.post(
        ApiConstants.requestOtp,
        data: OtpRequest(
          phoneNumber: phoneNumber,
          countryCode: countryCode,
        ).toJson(),
      );
      return response.data as Map<String, dynamic>;
    });
  }

  /// Verify OTP and authenticate user
  Future<TokenResponse> verifyOtp(
    String phoneNumber,
    String otpCode, {
    String? countryCode,
  }) async {
    return execute(() async {
      final response = await _apiClient.post(
        ApiConstants.verifyOtp,
        data: OtpVerification(
          phoneNumber: phoneNumber,
          otpCode: otpCode,
          countryCode: countryCode,
        ).toJson(),
      );
      final tokenResponse = TokenResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _tokenStorage.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
        expiresInSeconds: tokenResponse.expiresIn,
        userId: tokenResponse.user.id,
      );
      return tokenResponse;
    });
  }

  /// Create anonymous session
  Future<AnonymousSessionResponse> createAnonymousSession({
    String? deviceFingerprint,
    String languagePreference = 'en',
  }) async {
    return execute(() async {
      final response = await _apiClient.post(
        ApiConstants.anonymousSession,
        data: AnonymousSessionRequest(
          deviceFingerprint: deviceFingerprint,
          languagePreference: languagePreference,
        ).toJson(),
      );
      final session = AnonymousSessionResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _tokenStorage.saveTokens(
        accessToken: session.sessionToken,
        refreshToken: '', // Anonymous sessions don't have refresh tokens
        expiresInSeconds: 86400, // 24 hours
        userId: session.user.id,
      );
      return session;
    });
  }

  /// Refresh access token
  Future<TokenResponse> refreshAccessToken() async {
    final storedRefreshToken = await _tokenStorage.getRefreshToken();
    if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
      throw const UnauthorizedException();
    }

    return execute(() async {
      final response = await _apiClient.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': storedRefreshToken},
      );
      final tokenResponse = TokenResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _tokenStorage.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
        expiresInSeconds: tokenResponse.expiresIn,
        userId: tokenResponse.user.id,
      );
      return tokenResponse;
    });
  }

  /// Get current user
  Future<User> getCurrentUser() async {
    return execute(() async {
      final response = await _apiClient.get(ApiConstants.currentUser);
      return User.fromJson(response.data as Map<String, dynamic>);
    });
  }

  /// Update user profile
  Future<User> updateProfile(UserProfileUpdate update) async {
    return execute(() async {
      final response = await _apiClient.patch(
        ApiConstants.updateProfile,
        data: update.toJson(),
      );
      return User.fromJson(response.data as Map<String, dynamic>);
    });
  }

  /// Get trusted contacts
  Future<List<TrustedContact>> getTrustedContacts() async {
    return execute(() async {
      final response = await _apiClient.get(ApiConstants.trustedContacts);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => TrustedContact.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// Add trusted contact
  Future<TrustedContact> addTrustedContact(TrustedContactCreate contact) async {
    return execute(() async {
      final response = await _apiClient.post(
        ApiConstants.trustedContacts,
        data: contact.toJson(),
      );
      return TrustedContact.fromJson(response.data as Map<String, dynamic>);
    });
  }

  /// Remove trusted contact
  Future<void> removeTrustedContact(String contactId) async {
    return execute(() async {
      await _apiClient.delete('${ApiConstants.trustedContacts}/$contactId');
    });
  }

  /// Logout - clear tokens and notify backend
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (_) {
      // Ignore backend errors on logout
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  /// Check if authenticated (has valid token)
  Future<bool> isAuthenticated() async {
    final isAuth = await _tokenStorage.isAuthenticated();
    if (!isAuth) {
      // Check if we can refresh
      final storedRefreshToken = await _tokenStorage.getRefreshToken();
      if (storedRefreshToken != null && storedRefreshToken.isNotEmpty) {
        try {
          await refreshAccessToken();
          return true;
        } catch (_) {
          await _tokenStorage.clearTokens();
          return false;
        }
      }
      return false;
    }
    return true;
  }

  /// Get access token from storage
  Future<String?> getAccessToken() async {
    return _tokenStorage.getAccessToken();
  }
}

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRepository(apiClient);
});
