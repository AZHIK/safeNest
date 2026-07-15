import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/message_model.dart';
import '../../core/repositories/messaging_repository.dart';
import '../../core/services/token_storage_service.dart';
import '../../core/utils/encryption_helper.dart';
import 'websocket_chat_service.dart';

class MessagingState {
  final List<ConversationResponse> conversations;
  final bool conversationsLoading;
  final String? error;

  final ConversationResponse? selectedConversation;
  final List<MessageResponse> messages;
  final bool messagesLoading;

  final bool sending;
  final String? typingUserId;

  const MessagingState({
    this.conversations = const [],
    this.conversationsLoading = false,
    this.error,
    this.selectedConversation,
    this.messages = const [],
    this.messagesLoading = false,
    this.sending = false,
    this.typingUserId,
  });

  MessagingState copyWith({
    List<ConversationResponse>? conversations,
    bool? conversationsLoading,
    String? error,
    ConversationResponse? selectedConversation,
    List<MessageResponse>? messages,
    bool? messagesLoading,
    bool? sending,
    String? typingUserId,
    bool clearError = false,
  }) {
    return MessagingState(
      conversations: conversations ?? this.conversations,
      conversationsLoading:
          conversationsLoading ?? this.conversationsLoading,
      error: clearError ? null : error ?? this.error,
      selectedConversation:
          selectedConversation ?? this.selectedConversation,
      messages: messages ?? this.messages,
      messagesLoading: messagesLoading ?? this.messagesLoading,
      sending: sending ?? this.sending,
      typingUserId: typingUserId ?? this.typingUserId,
    );
  }
}

final messagingControllerProvider =
    NotifierProvider<MessagingController, MessagingState>(() {
  return MessagingController();
});

class MessagingController extends Notifier<MessagingState> {
  late MessagingRepository _repo;
  late WebSocketChatService _ws;
  StreamSubscription<WsEvent>? _wsSubscription;
  Timer? _typingDebounce;
  bool _isTyping = false;
  String? _currentUserId;

  @override
  MessagingState build() {
    _repo = ref.watch(messagingRepositoryProvider);
    _ws = ref.watch(wsChatServiceProvider);
    TokenStorageService().getUserId().then((id) => _currentUserId = id);
    _connectWebSocket();
    loadConversations();
    return const MessagingState();
  }

  void _connectWebSocket() {
    _ws.connect().then((_) {
      _wsSubscription?.cancel();
      _wsSubscription = _ws.events.listen(_handleWsEvent);
      if (state.selectedConversation != null) {
        _ws.subscribeToConversation(state.selectedConversation!.id);
      }
    }).catchError((_) {
      Future.delayed(const Duration(seconds: 5), _connectWebSocket);
    });
  }

  void _handleWsEvent(WsEvent event) {
    switch (event.type) {
      case WsEventType.newMessage:
        _handleNewMessage(event.data);
      case WsEventType.typing:
        final userId = event.data['user_id'] as String?;
        final isTyping = event.data['is_typing'] as bool? ?? false;
        state = state.copyWith(typingUserId: isTyping ? userId : null);
      case WsEventType.messageStatus:
        _handleMessageStatus(event.data);
      default:
        break;
    }
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    final conversationId = data['conversation_id'] as String?;
    final messageId = data['message_id'] as String?;
    if (conversationId == null || messageId == null) return;

    if (state.selectedConversation?.id == conversationId) {
      final exists = state.messages.any((m) => m.id == messageId);
      if (exists) return;

      final senderId = data['sender_id'] as String?;
      final msg = MessageResponse(
        id: messageId,
        conversationId: conversationId,
        senderId: senderId,
        senderOperatorId: data['sender_operator_id'] as String?,
        encryptedContent: data['encrypted_content'] as String? ?? '',
        encryptionMetadata: data['encryption_metadata'] as String? ?? '',
        contentType: data['content_type'] as String? ?? 'text',
        status: data['status'] as String? ?? 'sent',
        sentAt: data['sent_at'] != null
            ? DateTime.tryParse(data['sent_at'] as String)
            : null,
        isEdited: false,
        isDeleted: false,
        serverCreatedAt: data['server_created_at'] != null
            ? DateTime.tryParse(data['server_created_at'] as String) ?? DateTime.now()
            : DateTime.now(),
        isMe: senderId != null && senderId == _currentUserId,
      );
      state = state.copyWith(
        messages: [...state.messages, msg],
      );
    }

    loadConversations();
  }

  void _handleMessageStatus(Map<String, dynamic> data) {
    final messageId = data['message_id'] as String?;
    final status = data['status'] as String?;
    if (messageId == null || status == null) return;

    final updated = state.messages.map((m) {
      if (m.id == messageId) {
        return MessageResponse(
          id: m.id,
          conversationId: m.conversationId,
          senderId: m.senderId,
          encryptedContent: m.encryptedContent,
          encryptionMetadata: m.encryptionMetadata,
          contentType: m.contentType,
          status: status,
          sentAt: m.sentAt,
          deliveredAt: status == 'delivered' ? DateTime.now() : m.deliveredAt,
          isEdited: m.isEdited,
          isDeleted: m.isDeleted,
          serverCreatedAt: m.serverCreatedAt,
          clientCreatedAt: m.clientCreatedAt,
        );
      }
      return m;
    }).toList();
    state = state.copyWith(messages: updated);
  }

  Future<void> loadConversations() async {
    state = state.copyWith(conversationsLoading: true, clearError: true);
    try {
      final conversations = await _repo.getConversations();
      state = state.copyWith(
        conversations: conversations,
        conversationsLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        conversationsLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> selectConversation(ConversationResponse conversation) async {
    if (state.selectedConversation != null) {
      _ws.unsubscribeFromConversation(state.selectedConversation!.id);
    }

    state = state.copyWith(
      selectedConversation: conversation,
      messages: [],
      messagesLoading: true,
      typingUserId: null,
    );

    _ws.subscribeToConversation(conversation.id);

    try {
      final messages = await _repo.getMessages(conversation.id, currentUserId: _currentUserId);
      state = state.copyWith(
        messages: messages.reversed.toList(),
        messagesLoading: false,
      );
      _repo.markAsRead(conversation.id);
    } catch (e) {
      state = state.copyWith(
        messagesLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendMessage(String text) async {
    final conversation = state.selectedConversation;
    if (conversation == null || text.trim().isEmpty) return;

    state = state.copyWith(sending: true);
    try {
      final encrypted = await EncryptionHelperImpl().encrypt(text);
      final message = MessageCreate(
        conversationId: conversation.id,
        encryptedContent: encrypted['encrypted_data'] as String,
        encryptionMetadata: jsonEncode(encrypted['metadata']),
        clientCreatedAt: DateTime.now(),
      );

      final response = await _repo.sendMessage(message, currentUserId: _currentUserId);
      final display = MessageResponse(
        id: response.id,
        conversationId: conversation.id,
        encryptedContent: text,
        encryptionMetadata: '',
        contentType: 'text',
        status: 'sent',
        sentAt: DateTime.now(),
        isEdited: false,
        isDeleted: false,
        serverCreatedAt: DateTime.now(),
        clientCreatedAt: DateTime.now(),
        isMe: true,
      );
      state = state.copyWith(
        messages: [...state.messages, display],
        sending: false,
      );
    } catch (e) {
      state = state.copyWith(sending: false, error: e.toString());
    }
  }

  void sendTypingIndicator(String conversationId, bool isTyping) {
    _ws.sendTypingIndicator(conversationId, isTyping);
  }

  Future<ConversationResponse> createConversation({
    required String title,
    List<String>? participantIds,
    String? supportCenterId,
  }) async {
    final request = ConversationCreate(
      title: title,
      participantIds: participantIds,
      supportCenterId: supportCenterId,
    );
    final conversation = await _repo.createConversation(request);
    await loadConversations();
    selectConversation(conversation);
    return conversation;
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _typingDebounce?.cancel();
    _ws.disconnect();
  }
}
