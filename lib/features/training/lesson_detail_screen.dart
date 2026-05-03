import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localization.dart';
import '../../core/models/training_model.dart';
import '../../core/repositories/training_repository.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  final String? lessonId;

  const LessonDetailScreen({super.key, this.lessonId});

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  late Future<TrainingLessonDetail?> _lessonFuture;

  @override
  void initState() {
    super.initState();
    _lessonFuture = _fetchLesson();
  }

  Future<TrainingLessonDetail?> _fetchLesson() async {
    if (widget.lessonId == null) {
      throw Exception('No lesson ID provided');
    }
    final repo = ref.read(trainingRepositoryProvider);
    return await repo.getLessonDetail(widget.lessonId!);
  }

  String _getDifficultyText(String difficulty) {
    final lang = ref.read(localeProvider);
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppTranslations.get('beginner', lang);
      case 'intermediate':
        return AppTranslations.get('intermediate', lang);
      case 'advanced':
        return lang == AppLanguage.english ? 'Advanced' : 'Mahiri';
      default:
        return difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);

    return Scaffold(
      body: FutureBuilder<TrainingLessonDetail?>(
        future: _lessonFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 200.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: ColoredBox(color: AppColors.primary),
                  ),
                ),
                SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          // Error state
          if (snapshot.hasError || widget.lessonId == null) {
            return CustomScrollView(
              slivers: [
                const SliverAppBar(
                  pinned: true,
                  expandedHeight: 200.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: ColoredBox(color: AppColors.primary),
                  ),
                ),
                SliverFillRemaining(
                  child: Center(
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
                                ? 'Failed to load lesson'
                                : 'Imeshindwa kupakia somo',
                            style: const TextStyle(
                              fontSize: AppSizes.fontSubtitle,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSizes.p24),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _lessonFuture = _fetchLesson();
                              });
                            },
                            child: Text(
                              lang == AppLanguage.english
                                  ? 'Retry'
                                  : 'Jaribu tena',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          final lesson = snapshot.data;

          // No lesson found
          if (lesson == null) {
            return CustomScrollView(
              slivers: [
                const SliverAppBar(
                  pinned: true,
                  expandedHeight: 200.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: ColoredBox(color: AppColors.primary),
                  ),
                ),
                SliverFillRemaining(
                  child: Center(
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
                                ? 'Lesson not found'
                                : 'Somo halikupatikana',
                            style: const TextStyle(
                              fontSize: AppSizes.fontSubtitle,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSizes.p8),
                          Text(
                            lang == AppLanguage.english
                                ? 'This lesson may have been removed or is not available.'
                                : 'Somo hili lenda limeondolewa au halipatikani.',
                            style: TextStyle(
                              fontSize: AppSizes.fontSmall,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSizes.p24),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              lang == AppLanguage.english
                                  ? 'Go Back'
                                  : 'Rudi Nyuma',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Lesson loaded - display content
          final blocks = lesson.contentBlocks ?? [];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 200.0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    lesson.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: const ColoredBox(color: AppColors.primary),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDifficultyText(lesson.difficultyLevel),
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p8),
                      Text(
                        lesson.description ??
                            (lang == AppLanguage.english
                                ? 'Complete this lesson to learn essential skills.'
                                : 'Kamilisha somo hili kujifunza ujuzi muhimu.'),
                        style: const TextStyle(
                          fontSize: AppSizes.fontSubtitle,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p32),

                      // Render content blocks if available
                      if (blocks.isNotEmpty)
                        ...blocks.asMap().entries.map((entry) {
                          final block = entry.value;
                          return _buildContentBlock(
                            entry.key + 1,
                            block.type,
                            block.content,
                            block.metadata,
                          );
                        })
                      else
                        // Fallback content when no blocks
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStep(
                              1,
                              lang == AppLanguage.english
                                  ? 'Introduction'
                                  : 'Utangulizi',
                              lang == AppLanguage.english
                                  ? 'Review the lesson materials carefully.'
                                  : 'Kagua vizuri nyenzo za somo.',
                            ),
                            _buildStep(
                              2,
                              lang == AppLanguage.english
                                  ? 'Practice'
                                  : 'Mazoezi',
                              lang == AppLanguage.english
                                  ? 'Practice the techniques in a safe environment.'
                                  : 'Fanya mazoezi ya mbinu katika mazingira salama.',
                            ),
                            _buildStep(
                              3,
                              lang == AppLanguage.english
                                  ? 'Assessment'
                                  : 'Tathmini',
                              lang == AppLanguage.english
                                  ? 'Complete the assessment to verify understanding.'
                                  : 'Kamilisha tathmini kuthibitifa uelewa.',
                            ),
                          ],
                        ),

                      const SizedBox(height: AppSizes.p48),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                        ),
                        child: Text(
                          lang == AppLanguage.english
                              ? 'Complete Lesson'
                              : 'Kamilisha Somo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStep(int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.p16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.fontSubtitle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBlock(
    int number,
    String type,
    String? content,
    Map<String, dynamic>? metadata,
  ) {
    final lang = ref.read(localeProvider);

    switch (type.toLowerCase()) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.p24),
          child: Text(
            content ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppSizes.fontSubtitle,
            ),
          ),
        );
      case 'text':
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.p16),
          child: Text(
            content ?? '',
            style: const TextStyle(fontSize: AppSizes.fontBody, height: 1.5),
          ),
        );
      case 'step':
        return _buildStep(
          number,
          metadata?['title'] ??
              (lang == AppLanguage.english ? 'Step $number' : 'Hatua $number'),
          content ?? '',
        );
      case 'image':
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.p16),
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(AppSizes.radius8),
            ),
            child: content != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radius8),
                    child: Image.network(
                      content,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.broken_image,
                          color: Colors.grey[400],
                        );
                      },
                    ),
                  )
                : Icon(Icons.image, color: Colors.grey[400]),
          ),
        );
      case 'video':
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.p16),
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(AppSizes.radius8),
            ),
            child: content != null
                ? const Center(child: Icon(Icons.play_circle_outline, size: 64))
                : Icon(Icons.videocam, color: Colors.grey[400]),
          ),
        );
      default:
        return _buildStep(number, content ?? '', '');
    }
  }
}
