import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_texts.dart';
import '../../core/localization/app_localization.dart';
import '../../core/localization/language_toggle.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexts.appName(lang)),
        actions: [
          LanguageToggle(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              lang == AppLanguage.english
                  ? 'Welcome, Stay Safe.'
                  : 'Karibu, Baki Salama.',
              style: const TextStyle(
                fontSize: AppSizes.fontHeadline,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.p24),

            // SOS Button (Extremely prominent)
            GestureDetector(
              onTap: () => context.push('/sos'),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radius24),
                  border: Border.all(color: AppColors.error, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.p24),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error,
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p16),
                    Text(
                      lang == AppLanguage.english
                          ? 'EMERGENCY SOS'
                          : 'DHURURA YA SOS',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w900,
                        fontSize: AppSizes.fontTitle,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSizes.p32),

            // Quick Actions Title
            Text(
              lang == AppLanguage.english ? 'Quick Actions' : 'Hatua za Haraka',
              style: const TextStyle(
                fontSize: AppSizes.fontSubtitle,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            // Quick Actions Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSizes.p16,
              crossAxisSpacing: AppSizes.p16,
              childAspectRatio: 1.5,
              children: [
                _ActionCard(
                  icon: Icons.report_problem_outlined,
                  label: AppTexts.reportTitle(lang),
                  onTap: () => context.go('/report'),
                  color: Colors.orange,
                ),
                _ActionCard(
                  icon: Icons.map_outlined,
                  label: lang == AppLanguage.english
                      ? 'Find Support'
                      : 'Tafuta Msaada',
                  onTap: () => context.go('/map'),
                  color: AppColors.secondary,
                ),
                _ActionCard(
                  icon: Icons.people_outline,
                  label: lang == AppLanguage.english
                      ? 'Trusted Contacts'
                      : 'Watu wa Karibu',
                  onTap: () => context.push('/contacts'),
                  color: AppColors.primary,
                ),
                _ActionCard(
                  icon: Icons.library_books,
                  label: AppTexts.trainingTitle(lang),
                  onTap: () => context.go('/training'),
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.p32),

            // Safety Tip Section
            Container(
              padding: const EdgeInsets.all(AppSizes.p16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.radius12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: AppColors.primary),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang == AppLanguage.english
                              ? 'Daily Safety Tip'
                              : 'Ushauri wa Siku',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          lang == AppLanguage.english
                              ? 'Always keep your trusted contacts updated and share your location when traveling late.'
                              : 'Daima weka habari za watu wako wa karibu zikiwa mpya na shiriki eneo lako unaposafiri usiku.',
                          style: const TextStyle(fontSize: AppSizes.fontSmall),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radius12),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radius12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: AppSizes.iconLarge),
            const SizedBox(height: AppSizes.p8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.fontSmall,
                fontWeight: FontWeight.bold,
                color: color.withDarkness(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension ColorDarken on Color {
  Color withDarkness(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
