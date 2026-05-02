import 'base_model.dart';
import 'user_model.dart';

/// OTP Request Payload
class OtpRequest extends BaseModel {
  final String phoneNumber;
  final String countryCode;

  const OtpRequest({
    required this.phoneNumber,
    this.countryCode = '+1',
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'country_code': countryCode,
    };
  }
}

/// OTP Verification Payload
class OtpVerification extends BaseModel {
  final String phoneNumber;
  final String otpCode;
  final String? countryCode;

  const OtpVerification({
    required this.phoneNumber,
    required this.otpCode,
    this.countryCode,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'phone_number': phoneNumber,
      'otp_code': otpCode,
    };
    if (countryCode != null) data['country_code'] = countryCode;
    return data;
  }
}

/// Anonymous Session Request
class AnonymousSessionRequest extends BaseModel {
  final String? deviceFingerprint;
  final String languagePreference;

  const AnonymousSessionRequest({
    this.deviceFingerprint,
    this.languagePreference = 'en',
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (deviceFingerprint != null) data['device_fingerprint'] = deviceFingerprint;
    data['language_preference'] = languagePreference;
    return data;
  }
}

/// Token Response from FastAPI backend
class TokenResponse extends BaseModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final User user;

  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'user': user.toJson(),
    };
  }
}

/// Anonymous Session Response
class AnonymousSessionResponse extends BaseModel {
  final String sessionToken;
  final User user;
  final DateTime expiresAt;

  const AnonymousSessionResponse({
    required this.sessionToken,
    required this.user,
    required this.expiresAt,
  });

  factory AnonymousSessionResponse.fromJson(Map<String, dynamic> json) {
    return AnonymousSessionResponse(
      sessionToken: json['session_token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'session_token': sessionToken,
      'user': user.toJson(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}

/// Refresh Token Request
class RefreshTokenRequest extends BaseModel {
  final String refreshToken;

  const RefreshTokenRequest({required this.refreshToken});

  @override
  Map<String, dynamic> toJson() {
    return {'refresh_token': refreshToken};
  }
}
