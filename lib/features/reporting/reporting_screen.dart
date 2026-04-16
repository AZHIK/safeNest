import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_texts.dart';
import '../../core/localization/app_localization.dart';

class ReportingScreen extends ConsumerStatefulWidget {
  const ReportingScreen({super.key});

  @override
  ConsumerState<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends ConsumerState<ReportingScreen> {
  bool _isAnonymous = true;
  final TextEditingController _reportController = TextEditingController();

  @override
  void dispose() {
    _reportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppTexts.reportTitle(lang))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              lang == AppLanguage.english
                  ? 'Detail the incident securely.'
                  : 'Eleza tukio hili kwa usalama.',
              style: const TextStyle(
                fontSize: AppSizes.fontSubtitle,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            // Text Input
            TextField(
              controller: _reportController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: lang == AppLanguage.english
                    ? 'Describe what happened...'
                    : 'Eleza nini kilitokea...',
                hintStyle: const TextStyle(color: AppColors.textSecondaryLight),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p24),

            // Evidence Buttons
            Row(
              children: [
                Expanded(
                  child: _EvidenceButton(
                    icon: Icons.camera_alt_outlined,
                    label: lang == AppLanguage.english
                        ? 'Add Image'
                        : 'Ongeza Picha',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: _EvidenceButton(
                    icon: Icons.mic_none,
                    label: lang == AppLanguage.english
                        ? 'Record Audio'
                        : 'Rekodi Sauti',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p24),

            // Anonymous Toggle
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p16,
                vertical: AppSizes.p8,
              ),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.radius12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: Text(
                      lang == AppLanguage.english
                          ? 'Report Anonymously'
                          : 'Toa Ripoti Bila Jina',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Switch(
                    value: _isAnonymous,
                    onChanged: (val) => setState(() => _isAnonymous = val),
                    activeThumbColor: AppColors.secondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.p8),
            Text(
              lang == AppLanguage.english
                  ? 'Your identification will not be shared with anyone if anonymous is enabled.'
                  : 'Utambulisho wako hautashirikishwa na mtu yeyote ikiwa ripoti bila jina imewezeshwa.',
              style: const TextStyle(
                fontSize: AppSizes.fontSmall,
                color: AppColors.textSecondaryLight,
              ),
            ),

            const SizedBox(height: AppSizes.p48),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      lang == AppLanguage.english
                          ? 'Report submitted securely.'
                          : 'Ripoti imetumwa kwa usalama.',
                    ),
                  ),
                );
              },
              child: Text(AppTexts.submitReport(lang)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EvidenceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _EvidenceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radius12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(AppSizes.radius12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: AppSizes.p4),
            Text(label, style: const TextStyle(fontSize: AppSizes.fontSmall)),
          ],
        ),
      ),
    );
  }
}
