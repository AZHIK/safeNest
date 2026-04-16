import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import 'app_localization.dart';

class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(localeProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {
            ref.read(localeProvider.notifier).setLanguage(AppLanguage.english);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Switched to English'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          style: TextButton.styleFrom(
            backgroundColor: currentLanguage == AppLanguage.english
                ? AppColors.primary.withValues(alpha: 0.2)
                : null,
            minimumSize: const Size(40, 30),
            padding: EdgeInsets.zero,
          ),
          child: const Text(
            'EN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const Text('|', style: TextStyle(color: Colors.grey, fontSize: 12)),
        TextButton(
          onPressed: () {
            ref.read(localeProvider.notifier).setLanguage(AppLanguage.swahili);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Switched to Swahili'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          style: TextButton.styleFrom(
            backgroundColor: currentLanguage == AppLanguage.swahili
                ? AppColors.primary.withValues(alpha: 0.2)
                : null,
            minimumSize: const Size(40, 30),
            padding: EdgeInsets.zero,
          ),
          child: const Text(
            'SW',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
