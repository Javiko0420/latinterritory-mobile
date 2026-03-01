import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:latinterritory/core/config/app_config.dart';
import 'package:latinterritory/core/constants/api_endpoints.dart';
import 'package:latinterritory/core/storage/secure_storage.dart';

/// Dio interceptor that handles JWT authentication.
///
/// 1. Attaches `Authorization: Bearer <token>` to every request.
/// 2. On 401, attempts token refresh with rotation.
/// 3. On refresh failure, triggers logout via [onForceLogout].
///
/// Uses a separate [Dio] instance for refresh calls to avoid
/// interceptor loops.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureStorageService storage,
    required Dio refreshDio,
    required VoidCallback onForceLogout,
  })  : _storage = storage,
        _refreshDio = refreshDio,
        _onForceLogout = onForceLogout;

  final SecureStorageService _storage;
  final Dio _refreshDio;
  final VoidCallback _onForceLogout;

  /// Mutex to prevent multiple simultaneous refresh attempts.
  Completer<bool>? _refreshCompleter;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for public endpoints.
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    // Proactively refresh if token is about to expire.
    final isExpired = await _storage.isTokenExpired(
      buffer: AppConfig.tokenRefreshBuffer,
    );
    if (isExpired) {
      await _attemptRefresh();
    }

    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only handle 401 for non-auth endpoints.
    if (err.response?.statusCode != 401 ||
        _isAuthEndpoint(err.requestOptions.path)) {
      return handler.next(err);
    }

    // Attempt refresh.
    final refreshed = await _attemptRefresh();
    if (!refreshed) {
      _onForceLogout();
      return handler.next(err);
    }

    // Retry the original request with the new token.
    try {
      final token = await _storage.getAccessToken();
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $token';
      final response = await _refreshDio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  /// Attempts to refresh the access token.
  ///
  /// Uses a [Completer] as mutex so concurrent 401s only
  /// trigger one refresh call.
  Future<bool> _attemptRefresh() async {
    // If a refresh is already in progress, wait for it.
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        _refreshCompleter!.complete(false);
        return false;
      }

      final response = await _refreshDio.post(
        ApiEndpoints.mobileRefresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _storage.saveTokens(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
        );
        _refreshCompleter!.complete(true);
        return true;
      }

      _refreshCompleter!.complete(false);
      return false;
    } catch (_) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Endpoints that don't require auth headers.
  bool _isPublicEndpoint(String path) {
    return path == ApiEndpoints.mobileLogin ||
        path == ApiEndpoints.mobileRefresh ||
        path == ApiEndpoints.mobileGoogle ||
        path == ApiEndpoints.register ||
        path == ApiEndpoints.forgotPassword ||
        path == ApiEndpoints.resetPassword ||
        path == ApiEndpoints.weather ||
        path == ApiEndpoints.exchangeRates ||
        path == ApiEndpoints.foundersCount;
  }

  /// Auth endpoints — don't retry on 401.
  bool _isAuthEndpoint(String path) {
    return path == ApiEndpoints.mobileLogin ||
        path == ApiEndpoints.mobileRefresh ||
        path == ApiEndpoints.mobileGoogle;
  }
}
