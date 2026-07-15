import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localization.dart';
import '../../core/models/message_model.dart';
import '../../core/repositories/messaging_repository.dart';
import '../../core/utils/encryption_helper.dart';
import 'messaging_controller.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatDetailScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureConversationLoaded();
    });
  }

  Future<void> _ensureConversationLoaded() async {
    if (_initialized) return;
    _initialized = true;

    final state = ref.read(messagingControllerProvider);
    if (state.selectedConversation?.id == widget.conversationId) return;

    final conv = state.conversations
        .where((c) => c.id == widget.conversationId)
        .firstOrNull;

    if (conv != null) {
      ref.read(messagingControllerProvider.notifier).selectConversation(conv);
    } else {
      try {
        final repo = ref.read(messagingRepositoryProvider);
        final conversation = await repo.getConversation(widget.conversationId);
        if (mounted) {
          ref
              .read(messagingControllerProvider.notifier)
              .selectConversation(conversation);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load conversation: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final state = ref.watch(messagingControllerProvider);
    final controller = ref.read(messagingControllerProvider.notifier);
    final conv = state.selectedConversation;

    final title = conv?.title ??
        (conv != null
            ? '${conv.conversationType} ${conv.id.substring(0, 8)}'
            : '');

    if (conv == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Conversation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (state.typingUserId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  lang == AppLanguage.english ? 'typing...' : 'anaandika...',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messagesLoading
                ? const Center(child: CircularProgressIndicator())
                : state.messages.isEmpty
                    ? Center(
                        child: Text(
                          lang == AppLanguage.english
                              ? 'No messages yet. Start a conversation!'
                              : 'Hakuna ujumbe bado. Anza mazungumzo!',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppSizes.p16),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final msg = state.messages[index];
                          final isMe = msg.isFromMe;
                          return _DecryptedBubble(
                            encryptedContent: msg.encryptedContent,
                            encryptionMetadata: msg.encryptionMetadata,
                            isMe: isMe,
                            time: _formatTime(msg.serverCreatedAt),
                            status: msg.status,
                          );
                        },
                      ),
          ),
          _buildInputBar(lang, controller, state, conv),
        ],
      ),
    );
  }

  Widget _buildInputBar(
    AppLanguage lang,
    MessagingController controller,
    MessagingState state,
    ConversationResponse? conv,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add, color: AppColors.primary),
            ),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius:
                      BorderRadius.circular(AppSizes.radius24),
                ),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: AppTranslations.get(
                        'typeMessageHint', lang),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    if (conv != null) {
                      controller.sendTypingIndicator(
                        conv.id,
                        val.trim().isNotEmpty,
                      );
                    }
                  },
                  onSubmitted: (_) => _handleSend(controller),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.p8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: state.sending
                    ? null
                    : () => _handleSend(controller),
                icon: state.sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend(MessagingController controller) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    controller.sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _DecryptedBubble extends ConsumerStatefulWidget {
  final String encryptedContent;
  final String encryptionMetadata;
  final bool isMe;
  final String time;
  final String status;

  const _DecryptedBubble({
    required this.encryptedContent,
    required this.encryptionMetadata,
    required this.isMe,
    required this.time,
    this.status = 'sent',
  });

  @override
  ConsumerState<_DecryptedBubble> createState() => _DecryptedBubbleState();
}

class _DecryptedBubbleState extends ConsumerState<_DecryptedBubble> {
  String _displayText = '';
  bool _decrypting = true;

  @override
  void initState() {
    super.initState();
    _decrypt();
  }

  @override
  void didUpdateWidget(_DecryptedBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.encryptedContent != widget.encryptedContent) {
      _decrypt();
    }
  }

  Future<void> _decrypt() async {
    if (widget.encryptedContent.isEmpty || widget.encryptionMetadata.isEmpty) {
      setState(() {
        _displayText = widget.encryptedContent;
        _decrypting = false;
      });
      return;
    }
    try {
      final metadata = jsonDecode(widget.encryptionMetadata);
      final plaintext = await EncryptionHelperImpl().decrypt(
        widget.encryptedContent,
        metadata as Map<String, dynamic>,
      );
      if (mounted) {
        setState(() {
          _displayText = plaintext;
          _decrypting = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _displayText = widget.encryptedContent;
          _decrypting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = _decrypting ? '...' : _displayText;
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSizes.p4),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: AppSizes.p12,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: widget.isMe ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(widget.isMe ? 16 : 0),
            bottomRight: Radius.circular(widget.isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: widget.isMe ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.time,
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.isMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.grey[600],
                  ),
                ),
                if (widget.isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    widget.status == 'sent'
                        ? Icons.check
                        : widget.status == 'delivered'
                            ? Icons.done_all
                            : widget.status == 'read'
                                ? Icons.done_all
                                : Icons.access_time,
                    size: 12,
                    color: widget.status == 'read'
                        ? Colors.blue[300]
                        : widget.isMe
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.grey[600],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
