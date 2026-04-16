import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_texts.dart';
import 'core/localization/app_localization.dart';
import 'core/router/app_router.dart';

class SafeNestApp extends ConsumerWidget {
  const SafeNestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final lang = ref.watch(localeProvider);

    return MaterialApp.router(
      title: AppTexts.appName(lang),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark as requested
      routerConfig: router,
    );
  }
}
