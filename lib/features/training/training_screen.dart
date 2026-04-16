import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_texts.dart';
import '../../core/localization/app_localization.dart';

class TrainingScreen extends ConsumerWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);

    final List<Map<String, dynamic>> categories = [
      {
        'title': AppTexts.selfDefense(lang),
        'icon': Icons.fitness_center,
        'color': Colors.red,
        'desc': lang == AppLanguage.english
            ? 'Practical physical safety techniques.'
            : 'Mbinu za vitendo za usalama wa kimwili.',
      },
      {
        'title': AppTexts.awareness(lang),
        'icon': Icons.visibility,
        'color': AppColors.primary,
        'desc': lang == AppLanguage.english
            ? 'Recognizing and avoiding danger.'
            : 'Kutambua na kuepuka hatari.',
      },
      {
        'title': AppTexts.legalInfo(lang),
        'icon': Icons.gavel,
        'color': Colors.orange,
        'desc': lang == AppLanguage.english
            ? 'Understanding your rights and law.'
            : 'Kuelewa haki zako na sheria.',
      },
      {
        'title': AppTranslations.get('emergencyActions', lang),
        'icon': Icons.emergency,
        'color': Colors.teal,
        'desc': AppTranslations.get('crisesDesc', lang),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: Text(AppTexts.trainingTitle(lang))),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.p16),
            child: InkWell(
              onTap: () => context.push('/training/lessons'),
              borderRadius: BorderRadius.circular(AppSizes.radius16),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.p24),
                decoration: BoxDecoration(
                  color: (cat['color'] as Color).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppSizes.radius16),
                  border: Border.all(
                    color: (cat['color'] as Color).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.p12),
                      decoration: BoxDecoration(
                        color: cat['color'],
                        borderRadius: BorderRadius.circular(AppSizes.radius12),
                      ),
                      child: Icon(
                        cat['icon'],
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
                            cat['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppSizes.fontSubtitle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat['desc'],
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
      ),
    );
  }
}
