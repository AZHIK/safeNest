import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localization.dart';

class LessonListScreen extends ConsumerWidget {
  const LessonListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);

    final List<Map<String, String>> lessons = [
      {
        'title': AppTranslations.get('lessonStrikes', lang),
        'duration': '10 min',
        'difficulty': AppTranslations.get('beginner', lang),
      },
      {
        'title': AppTranslations.get('lessonHolds', lang),
        'duration': '15 min',
        'difficulty': AppTranslations.get('intermediate', lang),
      },
      {
        'title': AppTranslations.get('lessonEnv', lang),
        'duration': '8 min',
        'difficulty': AppTranslations.get('beginner', lang),
      },
      {
        'title': AppTranslations.get('lessonDeescalation', lang),
        'duration': '12 min',
        'difficulty': AppTranslations.get('beginner', lang),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.get('lessonsTitle', lang))),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.p12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius12),
            ),
            child: ListTile(
              onTap: () => context.push('/training/lesson-detail'),
              contentPadding: const EdgeInsets.all(AppSizes.p12),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(AppSizes.radius8),
                ),
                child: const Icon(
                  Icons.play_circle_outline,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                lesson['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    lesson['duration']!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.bar_chart, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    lesson['difficulty']!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            ),
          );
        },
      ),
    );
  }
}
