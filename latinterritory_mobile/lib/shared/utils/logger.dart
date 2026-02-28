import 'package:flutter/foundation.dart';

/// Simple app-level logger.
///
/// Wraps [debugPrint] so logs only show in debug mode.
/// Can be extended later with a proper logging package
/// (e.g., logger, talker) if needed.
class AppLogger {
  AppLogger._();

  static void debug(String message) {
    if (kDebugMode) debugPrint('[DEBUG] $message');
  }

  static void info(String message) {
    if (kDebugMode) debugPrint('[INFO] $message');
  }

  static void warning(String message) {
    if (kDebugMode) debugPrint('[WARN] $message');
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('  → $error');
      if (stackTrace != null) debugPrint('  → $stackTrace');
    }
  }
}
