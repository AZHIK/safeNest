import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localization.dart';
import '../../core/localization/language_toggle.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.get('settingsTitle', lang))),
      body: ListView(
        children: [
          _buildHeader(AppTranslations.get('preferencesHeader', lang)),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppTranslations.get('languageLabel', lang)),
            subtitle: const LanguageToggle(),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          _buildHeader(AppTranslations.get('securityHeader', lang)),
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline),
            title: Text(AppTranslations.get('appLockLabel', lang)),
            subtitle: Text(AppTranslations.get('appLockSub', lang)),
            value: true,
            activeThumbColor: AppColors.primary,
            onChanged: (val) {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.visibility_off_outlined),
            title: Text(AppTranslations.get('discreetModeLabel', lang)),
            subtitle: Text(AppTranslations.get('discreetModeSub', lang)),
            value: false,
            activeThumbColor: AppColors.primary,
            onChanged: (val) {},
          ),
          _buildHeader(AppTranslations.get('supportHeader', lang)),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(AppTranslations.get('helpCenterLabel', lang)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(AppTranslations.get('privacyPolicyLabel', lang)),
            onTap: () {},
          ),
          const SizedBox(height: AppSizes.p32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            child: TextButton(
              onPressed: () {},
              child: Text(
                AppTranslations.get('logoutButton', lang),
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ),
          const Center(
            child: Text(
              'SafeNest v1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: AppSizes.p32),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.p16,
        AppSizes.p24,
        AppSizes.p16,
        AppSizes.p8,
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.secondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
