import 'base_model.dart';

/// User Response Model
/// 
/// Matches FastAPI backend UserResponse schema
class User extends BaseModel {
  final String id;
  final String? phoneNumber;
  final String? countryCode;
  final bool isAnonymous;
  final bool isVerified;
  final String languagePreference;
  final String status;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final String? nickname;
  final String? emergencyMessageTemplate;

  const User({
    required this.id,
    this.phoneNumber,
    this.countryCode,
    required this.isAnonymous,
    required this.isVerified,
    required this.languagePreference,
    required this.status,
    this.lastLoginAt,
    required this.createdAt,
    this.nickname,
    this.emergencyMessageTemplate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String?,
      countryCode: json['country_code'] as String?,
      isAnonymous: json['is_anonymous'] as bool,
      isVerified: json['is_verified'] as bool,
      languagePreference: json['language_preference'] as String? ?? 'en',
      status: json['status'] as String,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      nickname: json['nickname'] as String?,
      emergencyMessageTemplate: json['emergency_message_template'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'is_anonymous': isAnonymous,
      'is_verified': isVerified,
      'language_preference': languagePreference,
      'status': status,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'nickname': nickname,
      'emergency_message_template': emergencyMessageTemplate,
    };
  }

  User copyWith({
    String? id,
    String? phoneNumber,
    String? countryCode,
    bool? isAnonymous,
    bool? isVerified,
    String? languagePreference,
    String? status,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    String? nickname,
    String? emergencyMessageTemplate,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isVerified: isVerified ?? this.isVerified,
      languagePreference: languagePreference ?? this.languagePreference,
      status: status ?? this.status,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      nickname: nickname ?? this.nickname,
      emergencyMessageTemplate: emergencyMessageTemplate ?? this.emergencyMessageTemplate,
    );
  }
}

/// User Profile Update Request
/// 
/// Matches FastAPI backend profile update schema
class UserProfileUpdate extends BaseModel {
  final String? nickname;
  final String? languagePreference;
  final String? emergencyMessageTemplate;

  const UserProfileUpdate({
    this.nickname,
    this.languagePreference,
    this.emergencyMessageTemplate,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (nickname != null) data['nickname'] = nickname;
    if (languagePreference != null) data['language_preference'] = languagePreference;
    if (emergencyMessageTemplate != null) {
      data['emergency_message_template'] = emergencyMessageTemplate;
    }
    return data;
  }
}
