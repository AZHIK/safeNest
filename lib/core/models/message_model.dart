import 'base_model.dart';

/// Conversation Response Model
class ConversationResponse extends BaseModel {
  final String id;
  final String conversationType;
  final String? title;
  final bool isEncrypted;
  final String encryptionType;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final List<ConversationParticipant>? participants;

  const ConversationResponse({
    required this.id,
    required this.conversationType,
    this.title,
    required this.isEncrypted,
    required this.encryptionType,
    this.lastMessageAt,
    required this.createdAt,
    this.participants,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      id: json['id'] as String,
      conversationType: json['conversation_type'] as String,
      title: json['title'] as String?,
      isEncrypted: json['is_encrypted'] as bool,
      encryptionType: json['encryption_type'] as String,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((e) => ConversationParticipant.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_type': conversationType,
      'title': title,
      'is_encrypted': isEncrypted,
      'encryption_type': encryptionType,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'participants': participants?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Conversation Participant Model
class ConversationParticipant extends BaseModel {
  final String id;
  final String userId;
  final String role;
  final DateTime joinedAt;
  final DateTime? lastReadAt;

  const ConversationParticipant({
    required this.id,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.lastReadAt,
  });

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) {
    return ConversationParticipant(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      lastReadAt: json['last_read_at'] != null
          ? DateTime.parse(json['last_read_at'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'last_read_at': lastReadAt?.toIso8601String(),
    };
  }
}

/// Conversation Create Request
class ConversationCreate extends BaseModel {
  final String conversationType;
  final List<String>? participantIds;
  final String? title;
  final String? supportCenterId;

  const ConversationCreate({
    this.conversationType = 'direct',
    this.participantIds,
    this.title,
    this.supportCenterId,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'conversation_type': conversationType};
    if (participantIds != null) data['participant_ids'] = participantIds;
    if (title != null) data['title'] = title;
    if (supportCenterId != null) data['support_center_id'] = supportCenterId;
    return data;
  }
}

/// Message Create Request
class MessageCreate extends BaseModel {
  final String conversationId;
  final String encryptedContent;
  final String encryptionMetadata;
  final String contentType;
  final String? replyToMessageId;
  final bool attachmentEncrypted;
  final String? attachmentStoragePath;
  final String? attachmentMetadataEncrypted;
  final DateTime clientCreatedAt;
  final int? offlineSequence;

  const MessageCreate({
    required this.conversationId,
    required this.encryptedContent,
    required this.encryptionMetadata,
    this.contentType = 'text',
    this.replyToMessageId,
    this.attachmentEncrypted = false,
    this.attachmentStoragePath,
    this.attachmentMetadataEncrypted,
    required this.clientCreatedAt,
    this.offlineSequence,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'conversation_id': conversationId,
      'encrypted_content': encryptedContent,
      'encryption_metadata': encryptionMetadata,
      'content_type': contentType,
      'attachment_encrypted': attachmentEncrypted,
      'client_created_at': clientCreatedAt.toIso8601String(),
    };
    if (replyToMessageId != null) data['reply_to_message_id'] = replyToMessageId;
    if (attachmentStoragePath != null) data['attachment_storage_path'] = attachmentStoragePath;
    if (attachmentMetadataEncrypted != null) {
      data['attachment_metadata_encrypted'] = attachmentMetadataEncrypted;
    }
    if (offlineSequence != null) data['offline_sequence'] = offlineSequence;
    return data;
  }
}

/// Message Response Model
class MessageResponse extends BaseModel {
  final String id;
  final String conversationId;
  final String? senderId;
  final String encryptedContent;
  final String encryptionMetadata;
  final String contentType;
  final String status;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final bool isEdited;
  final bool isDeleted;
  final DateTime serverCreatedAt;
  final DateTime? clientCreatedAt;

  const MessageResponse({
    required this.id,
    required this.conversationId,
    this.senderId,
    required this.encryptedContent,
    required this.encryptionMetadata,
    required this.contentType,
    required this.status,
    this.sentAt,
    this.deliveredAt,
    required this.isEdited,
    required this.isDeleted,
    required this.serverCreatedAt,
    this.clientCreatedAt,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String?,
      encryptedContent: json['encrypted_content'] as String,
      encryptionMetadata: json['encryption_metadata'] as String,
      contentType: json['content_type'] as String,
      status: json['status'] as String,
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at'] as String) : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      isEdited: json['is_edited'] as bool,
      isDeleted: json['is_deleted'] as bool,
      serverCreatedAt: DateTime.parse(json['server_created_at'] as String),
      clientCreatedAt: json['client_created_at'] != null
          ? DateTime.parse(json['client_created_at'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'encrypted_content': encryptedContent,
      'encryption_metadata': encryptionMetadata,
      'content_type': contentType,
      'status': status,
      'sent_at': sentAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'is_edited': isEdited,
      'is_deleted': isDeleted,
      'server_created_at': serverCreatedAt.toIso8601String(),
      'client_created_at': clientCreatedAt?.toIso8601String(),
    };
  }
}
