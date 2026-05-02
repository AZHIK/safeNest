import '../core/models/user_model.dart';
import '../core/models/trusted_contact_model.dart';

/// Authentication Service Interface
///
/// Defines contract for OTP-based authentication matching FastAPI backend.
/// Supports WhatsApp-style OTP, JWT tokens, and anonymous sessions.
abstract class AuthService {
  /// Request OTP for phone verification
  ///
  /// [phoneNumber] - Phone number without country code (10-20 chars)
  /// [countryCode] - Country code with + prefix (e.g., +1, +254)
  /// Returns [OtpRequestResult] with expiration info
  Future<OtpRequestResult> requestOtp(
    String phoneNumber, {
    String countryCode = '+1',
  });

  /// Verify OTP and authenticate user
  ///
  /// [phoneNumber] - Phone number that received OTP
  /// [otpCode] - 4-8 digit OTP code
  /// [countryCode] - Optional country code override
  /// Returns [AuthResult] with tokens and user data
  Future<AuthResult> verifyOtp(
    String phoneNumber,
    String otpCode, {
    String? countryCode,
  });

  /// Create anonymous session for unauthenticated access
  ///
  /// [deviceFingerprint] - Optional device identifier (max 64 chars)
  /// [languagePreference] - Language code (default: 'en')
  /// Returns [AnonymousSessionResult] with session token
  Future<AnonymousSessionResult> continueAnonymously({
    String? deviceFingerprint,
    String languagePreference = 'en',
  });

  /// Refresh access token using refresh token
  ///
  /// [refreshToken] - The refresh token from previous authentication
  /// Returns [TokenRefreshResult] with new tokens
  Future<TokenRefreshResult> refreshToken(String refreshToken);

  /// Get current authenticated user information
  ///
  /// Requires valid access token in storage
  /// Returns [User] model or throws [UnauthorizedException]
  Future<User> getCurrentUser();

  /// Update current user profile
  ///
  /// [update] - Profile update data (nickname, language, emergency message)
  /// Returns updated [User] model
  Future<User> updateProfile(UserProfileUpdate update);

  /// Get user's trusted contacts
  ///
  /// Returns list of [TrustedContact] for emergency notifications
  Future<List<TrustedContact>> getTrustedContacts();

  /// Add a trusted contact
  ///
  /// [contact] - Contact creation data
  /// Returns created [TrustedContact]
  Future<TrustedContact> addTrustedContact(TrustedContactCreate contact);

  /// Remove a trusted contact
  ///
  /// [contactId] - UUID of contact to remove
  /// Returns true if successfully removed
  Future<bool> removeTrustedContact(String contactId);

  /// Logout current user
  ///
  /// Clears tokens from secure storage and notifies backend
  Future<void> logout();

  /// Check if user is currently authenticated
  ///
  /// Validates token existence and expiration locally
  Future<bool> get isAuthenticated;

  /// Get current access token from secure storage
  ///
  /// Returns token string or null if not authenticated
  Future<String?> get accessToken;

  /// Stream of authentication state changes
  ///
  /// Emits true when authenticated, false when logged out
  Stream<bool> get authStateChanges;
}

/// OTP Request Result
class OtpRequestResult {
  final String message;
  final int expiresInSeconds;

  const OtpRequestResult({
    required this.message,
    required this.expiresInSeconds,
  });
}

/// Authentication Result
class AuthResult {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresInSeconds;
  final User user;

  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresInSeconds,
    required this.user,
  });
}

/// Anonymous Session Result
class AnonymousSessionResult {
  final String sessionToken;
  final User user;
  final DateTime expiresAt;

  const AnonymousSessionResult({
    required this.sessionToken,
    required this.user,
    required this.expiresAt,
  });
}

/// Token Refresh Result
class TokenRefreshResult {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresInSeconds;
  final User user;

  const TokenRefreshResult({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresInSeconds,
    required this.user,
  });
}
