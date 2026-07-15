import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localization.dart';
import 'messaging_controller.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);
    final state = ref.watch(messagingControllerProvider);
    final controller = ref.read(messagingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.get('messagesTitle', lang))),
      body: state.conversationsLoading
          ? const Center(child: CircularProgressIndicator())
          : state.conversations.isEmpty
              ? Center(
                  child: Text(
                    lang == AppLanguage.english
                        ? 'No conversations yet'
                        : 'Hakuna mazungumzo bado',
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => controller.loadConversations(),
                  child: ListView.separated(
                    itemCount: state.conversations.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey[200]),
                    itemBuilder: (context, index) {
                      final conv = state.conversations[index];
                      final title = conv.title ??
                          '${conv.conversationType} ${conv.id.substring(0, 8)}';
                      final lastMsg = conv.lastMessageAt != null
                          ? _formatTime(conv.lastMessageAt!)
                          : '';
                      final participantCount =
                          conv.participants?.length ?? 0;

                      return ListTile(
                        onTap: () {
                          controller.selectConversation(conv);
                          context.push('/messages/${conv.id}');
                        },
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.p16,
                          vertical: AppSizes.p8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            title[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          participantCount > 0
                              ? '$participantCount participants'
                              : conv.conversationType,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: AppSizes.fontSmall,
                          ),
                        ),
                        trailing: lastMsg.isNotEmpty
                            ? Text(
                                lastMsg,
                                style: const TextStyle(
                                  fontSize: AppSizes.fontSmall,
                                  color: Colors.grey,
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.month}/${dt.day}';
  }
}
