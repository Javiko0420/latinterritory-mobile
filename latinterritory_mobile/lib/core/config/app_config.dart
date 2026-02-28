import 'package:latinterritory/core/config/env.dart';

/// Centralized application configuration.
///
/// All app-wide settings are accessed through this class.
/// Environment-specific values come from [Env].
class AppConfig {
  AppConfig._();

  /// Backend base URL (no trailing slash).
  static String get baseUrl => Env.baseUrl;

  /// Google OAuth client IDs.
  static String get googleWebClientId => Env.googleWebClientId;
  static String get googleIosClientId => Env.googleIosClientId;

  /// Networking defaults.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  /// Auth token config.
  /// Access token TTL is controlled by the backend (15 min).
  /// We proactively refresh 60 seconds before expected expiry.
  static const Duration tokenRefreshBuffer = Duration(seconds: 60);

  /// Session inactivity timeout — auto logout.
  static const Duration sessionTimeout = Duration(minutes: 30);

  /// Pagination defaults.
  static const int defaultPageSize = 20;

  /// App metadata.
  static const String appName = 'LatinTerritory';
  static const String supportEmail = 'support@latinterritory.com';
}
