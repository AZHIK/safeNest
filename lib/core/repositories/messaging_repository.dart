import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../providers/api_provider.dart';
import '../models/message_model.dart';
import 'base_repository.dart';

/// Messaging Repository
///
/// Handles conversations and messages via HTTP.
/// WebSocket functionality for real-time messaging to be implemented separately.
class MessagingRepository extends BaseRepository {
  final ApiClient _apiClient;

  MessagingRepository(this._apiClient);

  /// Create a new conversation
  Future<ConversationResponse> createConversation(
    ConversationCreate request,
  ) async {
    return execute(() async {
      final response = await _apiClient.post(
        ApiConstants.messagesConversations,
        data: request.toJson(),
      );
      return ConversationResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  /// Get user's conversations
  Future<List<ConversationResponse>> getConversations({
    int skip = 0,
    int limit = 20,
  }) async {
    return execute(() async {
      final response = await _apiClient.get(
        ApiConstants.messagesConversations,
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => ConversationResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get specific conversation
  Future<ConversationResponse> getConversation(String conversationId) async {
    return execute(() async {
      final response = await _apiClient.get(
        '${ApiConstants.messagesConversations}/$conversationId',
      );
      return ConversationResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  /// Join a conversation
  Future<void> joinConversation(String conversationId) async {
    return execute(() async {
      await _apiClient.post(
        '${ApiConstants.messagesConversations}/$conversationId/join',
      );
    });
  }

  /// Leave a conversation
  Future<void> leaveConversation(String conversationId) async {
    return execute(() async {
      await _apiClient.post(
        '${ApiConstants.messagesConversations}/$conversationId/leave',
      );
    });
  }

  /// Get messages in a conversation
  Future<List<MessageResponse>> getMessages(
    String conversationId, {
    int skip = 0,
    int limit = 50,
  }) async {
    return execute(() async {
      final response = await _apiClient.get(
        '${ApiConstants.messagesConversations}/$conversationId/messages',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => MessageResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// Send a message to a conversation
  Future<MessageResponse> sendMessage(MessageCreate message) async {
    return execute(() async {
      final response = await _apiClient.post(
        ApiConstants.messagesSend,
        data: message.toJson(),
      );
      return MessageResponse.fromJson(response.data as Map<String, dynamic>);
    });
  }

  /// Mark all messages in conversation as read
  Future<void> markAsRead(String conversationId) async {
    return execute(() async {
      await _apiClient.post(
        '${ApiConstants.messagesConversations}/$conversationId/read',
      );
    });
  }
}

/// Provider for MessagingRepository
final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return MessagingRepository(apiClient);
});
