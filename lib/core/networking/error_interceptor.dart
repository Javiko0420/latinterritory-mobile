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
      _ when statusCode != null && statusCode >= 500 => ServerException(
          message: message ?? 'Server error. Please try again.',
          statusCode: statusCode,
        ),
      _ => UnknownApiException(
          message: message ?? err.message ?? 'Unknown error.',
          statusCode: statusCode,
        ),
    };
  }

  /// Extracts a user-friendly message from the backend error body.
  ///
  /// Handles every shape the API returns without ever throwing:
  /// - `{ "error": "text" }`
  /// - `{ "message": "text" }`
  /// - `{ "error": { "message": "text" } }`
  /// - `{ "error": [ { path, message }, ... ] }`  ← Zod `error.issues`
  /// - `{ "error": "text", "details": [ { field, message } ] }`
  /// - a bare `[ { path, message } ]` list
  ///
  /// Uses type checks instead of casts, so a non-string `error` (e.g. the raw
  /// Zod issues array) never crashes the interceptor and masks the real cause
  /// behind a generic "Network error".
  String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data.isNotEmpty ? data : null;
    if (data is List) return _messagesFromIssues(data);
    if (data is! Map) return null;

    // Base message: prefer `message`, then `error` (string or nested object).
    String? base;
    final rawMessage = data['message'];
    if (rawMessage is String && rawMessage.isNotEmpty) {
      base = rawMessage;
    }
    final rawError = data['error'];
    if (base == null) {
      if (rawError is String && rawError.isNotEmpty) {
        base = rawError;
      } else if (rawError is Map && rawError['message'] is String) {
        base = rawError['message'] as String;
      }
    }

    // Validation issues can arrive under `error` (this API) or `details`.
    final issues = rawError is List ? rawError : data['details'];
    if (issues is List) {
      final detailText = _messagesFromIssues(issues);
      if (detailText != null) {
        return base != null ? '$base: $detailText' : detailText;
      }
    }

    return base;
  }

  /// Joins up to two validation issue messages, prefixing the field name when
  /// it can be derived from `path` (Zod) or `field`.
  String? _messagesFromIssues(List<dynamic> issues) {
    final messages = <String>[];
    for (final issue in issues) {
      if (issue is! Map) continue;
      final msg = issue['message'];
      if (msg is! String || msg.isEmpty) continue;

      String? field;
      final path = issue['path'];
      if (path is List && path.isNotEmpty) {
        field = path.last?.toString();
      } else if (issue['field'] is String) {
        field = issue['field'] as String;
      }

      messages.add(field != null && field.isNotEmpty ? '$field: $msg' : msg);
    }
    if (messages.isEmpty) return null;
    return messages.take(2).join(' · ');
  }
}
