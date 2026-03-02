import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:latinterritory/core/config/app_config.dart';
import 'package:latinterritory/core/constants/api_endpoints.dart';
import 'package:latinterritory/core/storage/secure_storage.dart';
import 'package:latinterritory/shared/utils/logger.dart';

/// Dio interceptor that handles JWT authentication.
///
/// 1. Attaches `Authorization: Bearer <token>` to every request.
/// 2. On 401, attempts token refresh with rotation.
/// 3. On refresh failure, triggers logout via [onForceLogout].
///
/// Uses a separate [Dio] instance for refresh calls to avoid
/// interceptor loops. Retries go through the main [Dio] so the
/// full interceptor chain (including this one) attaches the
/// refreshed token the same way it does for any normal request.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureStorageService storage,
    required Dio mainDio,
    required Dio refreshDio,
    required VoidCallback onForceLogout,
  })  : _storage = storage,
        _mainDio = mainDio,
        _refreshDio = refreshDio,
        _onForceLogout = onForceLogout;

  final SecureStorageService _storage;
  final Dio _mainDio;
  final Dio _refreshDio;
  final VoidCallback _onForceLogout;

  /// Extra key used to mark a request as a post-refresh retry,
  /// preventing infinite 401→refresh→retry loops.
  static const _retryFlag = '_authRetry';

  /// Mutex to prevent multiple simultaneous refresh attempts.
  Completer<bool>? _refreshCompleter;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

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
    final isRetry = err.requestOptions.extra[_retryFlag] == true;

    // Don't handle non-401, auth endpoints, or already-retried requests.
    if (err.response?.statusCode != 401 ||
        _isAuthEndpoint(err.requestOptions.path) ||
        isRetry) {
      return handler.next(err);
    }

    final refreshed = await _attemptRefresh();
    if (!refreshed) {
      _onForceLogout();
      return handler.next(err);
    }

    // Retry through the MAIN Dio so the full interceptor chain
    // (including this onRequest) attaches the fresh token.
    try {
      final original = err.requestOptions;
      final response = await _mainDio.request(
        original.path,
        data: original.data,
        queryParameters: original.queryParameters,
        options: Options(
          method: original.method,
          responseType: original.responseType,
          extra: {_retryFlag: true},
        ),
      );
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
