import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latinterritory/core/config/app_config.dart';
import 'package:latinterritory/core/networking/auth_interceptor.dart';
import 'package:latinterritory/core/networking/error_interceptor.dart';
import 'package:latinterritory/core/storage/secure_storage.dart';

/// Creates and configures the [Dio] HTTP client.
///
/// Two instances:
/// - [createApiClient]: Main client with auth + error interceptors.
/// - [_createRefreshDio]: Bare client used only for token refresh
///   (avoids interceptor loops).
class ApiClient {
  ApiClient._();

  /// Creates the main API client with all interceptors.
  static Dio createApiClient({
    required SecureStorageService storage,
    required VoidCallback onForceLogout,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Refresh client — no interceptors to avoid loops.
    final refreshDio = _createRefreshDio();

    // Order matters: auth first, then error mapping.
    dio.interceptors.addAll([
      AuthInterceptor(
        storage: storage,
        refreshDio: refreshDio,
        onForceLogout: onForceLogout,
      ),
      ErrorInterceptor(),
      if (kDebugMode) _createLogInterceptor(),
    ]);

    return dio;
  }

  /// Bare Dio for refresh-only requests.
  static Dio _createRefreshDio() {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Pretty log interceptor for debug builds.
  static LogInterceptor _createLogInterceptor() {
    return LogInterceptor(
      request: true,
      requestHeader: false,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => debugPrint('[API] $obj'),
    );
  }
}
