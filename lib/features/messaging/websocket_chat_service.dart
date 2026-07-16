import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/api/api_constants.dart';
import '../../core/services/token_storage_service.dart';

enum WsEventType {
  subscribed,
  newMessage,
  typing,
  messageStatus,
  pong,
  error,
}

class WsEvent {
  final WsEventType type;
  final Map<String, dynamic> data;
  WsEvent({required this.type, required this.data});
}

class WebSocketChatService {
  WebSocketChannel? _channel;
  final TokenStorageService _tokenStorage = TokenStorageService();
  final _eventController = StreamController<WsEvent>.broadcast();
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  int _maxReconnectAttempts = 10;
  bool _disposed = false;
  Timer? _reconnectTimer;

  Stream<WsEvent> get events => _eventController.stream;
  bool get isConnected => _channel != null;

  Future<void> connect() async {
    if (_channel != null || _disposed) return;
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) return;

    final wsUrl = ApiConstants.baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://') +
        ApiConstants.messagesWs +
        '?token=$token';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      await _channel!.ready;

      _reconnectAttempts = 0;
      _startHeartbeat();

      _channel!.stream.listen(
        (raw) {
          final message = jsonDecode(raw as String) as Map<String, dynamic>;
          _handleMessage(message);
        },
        onError: (error) {
          _eventController.add(WsEvent(
            type: WsEventType.error,
            data: {'message': error.toString()},
          ));
        },
        onDone: () {
          _stopHeartbeat();
          _channel = null;
          _scheduleReconnect();
        },
      );
    } catch (e) {
      _channel = null;
      _scheduleReconnect();
      rethrow;
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) return;
    if (_reconnectTimer?.isActive ?? false) return;

    _reconnectAttempts++;
    // Exponential backoff with jitter
    final baseDelay = min(1000 * pow(2, _reconnectAttempts - 1).toInt(), 30000);
    final jitter = Random().nextInt(1000);
    final delay = baseDelay + jitter;

    _reconnectTimer = Timer(Duration(milliseconds: delay), () {
      _channel = null;
      connect();
    });
  }

  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type'] as String?;
    final data = message['data'] as Map<String, dynamic>? ?? message;

    switch (type) {
      case 'subscribed':
        _eventController.add(WsEvent(
          type: WsEventType.subscribed,
          data: data,
        ));
      case 'new_message':
        _eventController.add(WsEvent(
          type: WsEventType.newMessage,
          data: data,
        ));
      case 'typing':
        _eventController.add(WsEvent(
          type: WsEventType.typing,
          data: data,
        ));
      case 'message_status':
        _eventController.add(WsEvent(
          type: WsEventType.messageStatus,
          data: data,
        ));
      case 'pong':
        _eventController.add(WsEvent(
          type: WsEventType.pong,
          data: data,
        ));
      case 'error':
        _eventController.add(WsEvent(
          type: WsEventType.error,
          data: data,
        ));
    }
  }

  void subscribeToConversation(String conversationId) {
    _sendMessage('subscribe_conversation', {
      'conversation_id': conversationId,
    });
  }

  void unsubscribeFromConversation(String conversationId) {
    _sendMessage('unsubscribe_conversation', {
      'conversation_id': conversationId,
    });
  }

  void sendTypingIndicator(String conversationId, bool isTyping) {
    _sendMessage('typing', {
      'conversation_id': conversationId,
      'is_typing': isTyping,
    });
  }

  void sendMessageStatus(String conversationId, String messageId, String status) {
    _sendMessage('message_status', {
      'conversation_id': conversationId,
      'message_id': messageId,
      'status': status,
    });
  }

  void _sendMessage(String type, Map<String, dynamic> data) {
    if (_channel == null) return;
    try {
      _channel!.sink.add(jsonEncode({
        'type': type,
        'data': data,
      }));
    } catch (_) {}
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendMessage('ping', {'timestamp': DateTime.now().toIso8601String()});
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> disconnect() async {
    _disposed = true;
    _reconnectTimer?.cancel();
    _stopHeartbeat();
    await _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _eventController.close();
  }
}

final wsChatServiceProvider = Provider<WebSocketChatService>((ref) {
  return WebSocketChatService();
});
