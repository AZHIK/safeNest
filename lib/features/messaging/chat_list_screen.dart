import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localization.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);

    final List<Map<String, String>> mockChats = [
      {
        'nameKey': 'officialSupport',
        'lastMsg': lang == AppLanguage.english
            ? 'We have received your report.'
            : 'Tumepokea ripoti yako.',
        'time': '10:30 AM',
        'unread': '1',
      },
      {
        'name': 'Safe House Alpha',
        'lastMsg': lang == AppLanguage.english
            ? 'Are you safe now?'
            : 'Uko salama sasa?',
        'time': lang == AppLanguage.english ? 'Yesterday' : 'Jana',
        'unread': '0',
      },
      {
        'name': 'Legal Consultant',
        'lastMsg': lang == AppLanguage.english
            ? 'Please review the documents I sent.'
            : 'Tafadhali kagua nyaraka nilizotuma.',
        'time': 'Mon',
        'unread': '0',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.get('messagesTitle', lang))),
      body: ListView.separated(
        itemCount: mockChats.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey[200]),
        itemBuilder: (context, index) {
          final chat = mockChats[index];
          final hasUnread = chat['unread'] != '0';
          final name = chat['nameKey'] != null
              ? AppTranslations.get(chat['nameKey']!, lang)
              : chat['name']!;

          return ListTile(
            onTap: () => context.push('/messages/detail'),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p16,
              vertical: AppSizes.p8,
            ),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                name[0],
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              name,
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              chat['lastMsg']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: hasUnread
                    ? AppColors.textPrimaryLight
                    : AppColors.textSecondaryLight,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat['time']!,
                  style: const TextStyle(
                    fontSize: AppSizes.fontSmall,
                    color: Colors.grey,
                  ),
                ),
                if (hasUnread) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      chat['unread']!,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
