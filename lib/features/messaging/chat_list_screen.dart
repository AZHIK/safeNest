import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localization.dart';
import '../../core/repositories/support_center_repository.dart';
import '../../core/models/support_center_model.dart';
import '../../services/location_service.dart';
import 'messaging_controller.dart';

IconData _iconForCenterType(String type) {
  switch (type) {
    case 'police':
      return Icons.local_police;
    case 'hospital':
      return Icons.local_hospital;
    case 'legal_aid':
      return Icons.gavel;
    case 'ngo':
    case 'shelter':
    case 'hotline':
    case 'counseling':
      return Icons.home_work;
    default:
      return Icons.location_on;
  }
}

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);
    final state = ref.watch(messagingControllerProvider);
    final controller = ref.read(messagingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.get('messagesTitle', lang))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStartChatSheet(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat_outlined, color: Colors.white),
      ),
      body: state.conversationsLoading
          ? const Center(child: CircularProgressIndicator())
          : state.conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: AppSizes.p16),
                      Text(
                        lang == AppLanguage.english
                            ? 'No conversations yet'
                            : 'Hakuna mazungumzo bado',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p24),
                      ElevatedButton.icon(
                        onPressed: () => _showStartChatSheet(context, ref),
                        icon: const Icon(Icons.message_outlined),
                        label: Text(
                          AppTranslations.get('messagingSupport', lang),
                        ),
                      ),
                    ],
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

  void _showStartChatSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radius16),
        ),
      ),
      builder: (_) => _SupportCenterSheet(
        onStartChat: (center) async {
          try {
            final controller =
                ref.read(messagingControllerProvider.notifier);
            final conversation = await controller.createConversation(
              title: center.name,
              supportCenterId: center.id,
            );
            if (context.mounted) {
              Navigator.of(context).pop();
              context.push('/messages/${conversation.id}');
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${AppTranslations.get('failedStartChat', ref.read(localeProvider))}: $e',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
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

class _SupportCenterSheet extends ConsumerStatefulWidget {
  final Future<void> Function(SupportCenterResponse center) onStartChat;

  const _SupportCenterSheet({required this.onStartChat});

  @override
  ConsumerState<_SupportCenterSheet> createState() =>
      _SupportCenterSheetState();
}

class _SupportCenterSheetState extends ConsumerState<_SupportCenterSheet> {
  List<SupportCenterResponse>? _centers;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCenters();
  }

  Future<void> _loadCenters() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(supportCenterRepositoryProvider);
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentLocation();

      List<SupportCenterResponse> centers;
      if (position != null) {
        final request = SupportCenterNearbyRequest(
          latitude: position.latitude,
          longitude: position.longitude,
          radiusKm: 50.0,
        );
        centers = await repo.findNearby(request);
      } else {
        centers = await repo.getVerifiedCenters();
      }
      if (mounted) setState(() { _centers = centers; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSizes.p16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                AppTranslations.get('selectCenter', lang),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.p16),
              if (_loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppTranslations.get('failedStartChat', lang)),
                        const SizedBox(height: AppSizes.p16),
                        ElevatedButton(
                          onPressed: _loadCenters,
                          child: Text(AppTranslations.get('retry', lang)),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_centers!.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      AppTranslations.get('noCentersFound', lang),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: _centers!.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: Colors.grey[200]),
                    itemBuilder: (context, index) {
                      final center = _centers![index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(
                            _iconForCenterType(center.centerType),
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          center.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          center.centerType
                              .replaceAll('_', ' ')
                              .toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: AppSizes.fontSmall,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondaryLight,
                        ),
                        onTap: () {
                          widget.onStartChat(center);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
