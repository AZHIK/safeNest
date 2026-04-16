import 'package:flutter/foundation.dart';

class Logger {
  Logger._();

  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ [INFO] $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ [WARNING] $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('🔴 [ERROR] $message');
      if (error != null) print('Details: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }
}
