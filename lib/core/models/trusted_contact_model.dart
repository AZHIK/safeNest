import 'base_model.dart';

/// Trusted Contact Response Model
/// 
/// Matches FastAPI backend TrustedContactResponse schema
class TrustedContact extends BaseModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String? relationship;
  final int priority;
  final bool notifySms;
  final bool notifyPush;
  final bool isVerified;
  final DateTime createdAt;

  const TrustedContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.relationship,
    required this.priority,
    required this.notifySms,
    required this.notifyPush,
    required this.isVerified,
    required this.createdAt,
  });

  factory TrustedContact.fromJson(Map<String, dynamic> json) {
    return TrustedContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      relationship: json['relationship'] as String?,
      priority: json['priority'] as int,
      notifySms: json['notify_sms'] as bool,
      notifyPush: json['notify_push'] as bool,
      isVerified: json['is_verified'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'relationship': relationship,
      'priority': priority,
      'notify_sms': notifySms,
      'notify_push': notifyPush,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TrustedContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    int? priority,
    bool? notifySms,
    bool? notifyPush,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return TrustedContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      priority: priority ?? this.priority,
      notifySms: notifySms ?? this.notifySms,
      notifyPush: notifyPush ?? this.notifyPush,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Trusted Contact Create Request
class TrustedContactCreate extends BaseModel {
  final String name;
  final String phoneNumber;
  final String? relationship;
  final int priority;
  final bool notifySms;
  final bool notifyPush;

  const TrustedContactCreate({
    required this.name,
    required this.phoneNumber,
    this.relationship,
    this.priority = 1,
    this.notifySms = true,
    this.notifyPush = true,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone_number': phoneNumber,
      'relationship': relationship,
      'priority': priority,
      'notify_sms': notifySms,
      'notify_push': notifyPush,
    };
  }
}
