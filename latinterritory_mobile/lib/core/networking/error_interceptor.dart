import 'package:dio/dio.dart';
import 'package:latinterritory/core/networking/api_exceptions.dart';
import 'package:latinterritory/shared/utils/logger.dart';

/// Maps raw [DioException]s to typed [ApiException]s.
///
/// This keeps error handling consistent across all features.
/// Each feature catches [ApiException] subtypes instead of
/// parsing status codes manually.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _mapException(err);
    AppLogger.error(
      'API Error: ${err.requestOptions.method} ${err.requestOptions.path}',
      error: apiException,
    );
    handler.next(
      err.copyWith(error: apiException),
    );
  }

  ApiException _mapException(DioException err) {
    // Network-level errors (no response from server).
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }

    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    // Extract error message from backend response.
    final message = _extractMessage(data);

    return switch (statusCode) {
      400 => BadRequestException(message: message ?? 'Invalid request.'),
      401 => UnauthorizedException(
          message: message ?? 'Session expired. Please log in again.',
        ),
      403 => ForbiddenException(
          message: message ?? 'Access denied.',
        ),
      404 => NotFoundException(
          message: message ?? 'Resource not found.',
        ),
      429 => RateLimitException(
          message: message ?? 'Too many requests.',
        ),
      final int code when code >= 500 => ServerException(
          message: message ?? 'Server error. Please try again.',
          statusCode: code,
        ),
      _ => UnknownApiException(
          message: message ?? err.message ?? 'Unknown error.',
          statusCode: statusCode,
        ),
    };
  }

  /// Tries to extract `message` or `error` field from response body.
  String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String?;
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }
}
