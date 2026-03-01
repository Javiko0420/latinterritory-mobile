/// Base exception for all API-related errors.
sealed class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// 400 - Bad request / validation error.
class BadRequestException extends ApiException {
  const BadRequestException({required super.message, super.statusCode = 400});
}

/// 401 - Authentication failed.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Session expired. Please log in again.',
    super.statusCode = 401,
  });
}

/// 403 - Forbidden / insufficient permissions.
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.statusCode = 403,
  });
}

/// 404 - Resource not found.
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
  });
}

/// 429 - Rate limited.
class RateLimitException extends ApiException {
  const RateLimitException({
    super.message = 'Too many requests. Please try again later.',
    super.statusCode = 429,
  });
}

/// 500+ - Server error.
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Something went wrong on our end. Please try again.',
    super.statusCode = 500,
  });
}

/// No internet or timeout.
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
    super.statusCode,
  });
}

/// Catch-all for unexpected errors.
class UnknownApiException extends ApiException {
  const UnknownApiException({
    super.message = 'An unexpected error occurred.',
    super.statusCode,
  });
}
