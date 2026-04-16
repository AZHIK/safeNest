import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localization.dart';

class ChatDetailScreen extends ConsumerWidget {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);

    final List<Map<String, dynamic>> mockMessages = [
      {
        'text': lang == AppLanguage.english
            ? 'Hello, I need some assistance with a report.'
            : 'Habari, ninahitaji msaada na ripoti.',
        'isMe': true,
        'time': '10:25 AM',
      },
      {
        'text': lang == AppLanguage.english
            ? 'Hello! We are here to help. What happened?'
            : 'Habari! Tuko hapa kusaidia. Nini kilitokea?',
        'isMe': false,
        'time': '10:26 AM',
      },
      {
        'text': lang == AppLanguage.english
            ? 'I have some evidence I want to shared anonymously.'
            : 'Nina ushahidi nataka kushiriki bila jina.',
        'isMe': true,
        'time': '10:28 AM',
      },
      {
        'text': lang == AppLanguage.english
            ? 'You can use the secure reporting tool or send them here. This chat is end-to-end encrypted.'
            : 'Unaweza kutumia zana salama ya ripoti au utume hapa. Chati hii imesimbwa kwa njia fiche.',
        'isMe': false,
        'time': '10:30 AM',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.get('officialSupport', lang))),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSizes.p16),
              itemCount: mockMessages.length,
              itemBuilder: (context, index) {
                final msg = mockMessages[index];
                return _ChatBubble(
                  text: msg['text']!,
                  isMe: msg['isMe']!,
                  time: msg['time']!,
                );
              },
            ),
          ),

          // Input Area
          Container(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(AppSizes.radius24),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: AppTranslations.get(
                            'typeMessageHint',
                            lang,
                          ),
                          border: InputBorder.none,
                        ),
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
                      onPressed: () {},
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;

  const _ChatBubble({
    required this.text,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
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
          color: isMe ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: isMe
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
