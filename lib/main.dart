import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/utils/logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services, local DB, etc. here
  Logger.info('Starting SafeNest App Initialization...');

  runApp(const ProviderScope(child: SafeNestApp()));
}
