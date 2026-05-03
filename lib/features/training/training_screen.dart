import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_texts.dart';
import '../../core/localization/app_localization.dart';
import '../../core/models/training_model.dart';
import '../../core/repositories/training_repository.dart';

class TrainingScreen extends ConsumerStatefulWidget {
  const TrainingScreen({super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen> {
  late Future<List<TrainingCategoryResponse>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _fetchCategories();
  }

  Future<List<TrainingCategoryResponse>> _fetchCategories() async {
    final repo = ref.read(trainingRepositoryProvider);
    return await repo.getCategories();
  }

  IconData _getIconForCategory(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'fitness_center':
      case 'self_defense':
        return Icons.fitness_center;
      case 'visibility':
      case 'awareness':
        return Icons.visibility;
      case 'gavel':
      case 'legal':
        return Icons.gavel;
      case 'emergency':
        return Icons.emergency;
      case 'security':
        return Icons.security;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.school;
    }
  }

  Color _getColorForCategory(String? colorCode) {
    if (colorCode == null) return AppColors.primary;
    try {
      return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppTexts.trainingTitle(lang))),
      body: FutureBuilder<List<TrainingCategoryResponse>>(
        future: _categoriesFuture,
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
                          ? 'Failed to load training materials'
                          : 'Imeshindwa kupakia mafunzo',
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
                          _categoriesFuture = _fetchCategories();
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

          final categories = snapshot.data ?? [];

          // Empty state - no training materials
          if (categories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: AppSizes.p16),
                    Text(
                      lang == AppLanguage.english
                          ? 'No training materials available'
                          : 'Hakuna mafunzo yaliyopatikana',
                      style: const TextStyle(
                        fontSize: AppSizes.fontSubtitle,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      lang == AppLanguage.english
                          ? 'Training materials will appear here once they are added to the database.'
                          : 'Mafunzo yataonekana hapa baada ya kuwekwa kwenye hifadhidata.',
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
                          _categoriesFuture = _fetchCategories();
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

          // Data loaded - show categories
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.p24),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final color = _getColorForCategory(cat.colorCode);
              final icon = _getIconForCategory(cat.iconName);

              return Container(
                margin: const EdgeInsets.only(bottom: AppSizes.p16),
                child: InkWell(
                  onTap: () =>
                      context.push('/training/lessons?categoryId=${cat.id}'),
                  borderRadius: BorderRadius.circular(AppSizes.radius16),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.p24),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppSizes.radius16),
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSizes.p12),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radius12,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: AppSizes.iconLarge,
                          ),
                        ),
                        const SizedBox(width: AppSizes.p24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.fontSubtitle,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cat.description ??
                                    (lang == AppLanguage.english
                                        ? '${cat.lessonCount} lessons available'
                                        : 'Masomo ${cat.lessonCount} yaliyopatikana'),
                                style: const TextStyle(
                                  fontSize: AppSizes.fontSmall,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
