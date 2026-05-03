import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localization.dart';
import '../../core/models/training_model.dart';
import '../../core/repositories/training_repository.dart';

class LessonListScreen extends ConsumerStatefulWidget {
  final String? categoryId;

  const LessonListScreen({super.key, this.categoryId});

  @override
  ConsumerState<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends ConsumerState<LessonListScreen> {
  late Future<List<TrainingLessonResponse>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    _lessonsFuture = _fetchLessons();
  }

  Future<List<TrainingLessonResponse>> _fetchLessons() async {
    final repo = ref.read(trainingRepositoryProvider);
    return await repo.getLessons(categoryId: widget.categoryId);
  }

  String _formatDuration(int minutes) {
    return '$minutes min';
  }

  String _getDifficultyText(String? difficulty) {
    final lang = ref.read(localeProvider);
    switch (difficulty?.toLowerCase()) {
      case 'beginner':
        return AppTranslations.get('beginner', lang);
      case 'intermediate':
        return AppTranslations.get('intermediate', lang);
      case 'advanced':
        return lang == AppLanguage.english ? 'Advanced' : 'Mahiri';
      default:
        return AppTranslations.get('beginner', lang);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.get('lessonsTitle', lang))),
      body: FutureBuilder<List<TrainingLessonResponse>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: AppSizes.p16),
                    Text(
                      lang == AppLanguage.english
                          ? 'Failed to load lessons'
                          : 'Imeshindwa kupakia masomo',
                      style: const TextStyle(
                        fontSize: AppSizes.fontSubtitle,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      snapshot.error.toString(),
                      style: TextStyle(
                        fontSize: AppSizes.fontSmall,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.p24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _lessonsFuture = _fetchLessons();
                        });
                      },
                      child: Text(
                        lang == AppLanguage.english ? 'Retry' : 'Jaribu tena',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final lessons = snapshot.data ?? [];

          // Empty state
          if (lessons.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: AppSizes.p16),
                    Text(
                      lang == AppLanguage.english
                          ? 'No lessons available'
                          : 'Hakuna masomo yaliyopatikana',
                      style: const TextStyle(
                        fontSize: AppSizes.fontSubtitle,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      lang == AppLanguage.english
                          ? 'Lessons will appear here once they are added to the database.'
                          : 'Masomo yataonekana hapa baada ya kuwekwa kwenye hifadhidata.',
                      style: TextStyle(
                        fontSize: AppSizes.fontSmall,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.p24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _lessonsFuture = _fetchLessons();
                        });
                      },
                      child: Text(
                        lang == AppLanguage.english
                            ? 'Refresh'
                            : 'Onyesha upya',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Data loaded
          return ListView.builder(
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
                  onTap: () =>
                      context.push('/training/lesson-detail?id=${lesson.id}'),
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
                    lesson.title,
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
                        _formatDuration(lesson.durationMinutes ?? 0),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.bar_chart, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _getDifficultyText(lesson.difficultyLevel),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
