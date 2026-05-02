/// Base API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
  });

  @override
  String toString() => 'ApiException: $message (Code: $code, Status: $statusCode)';
}

/// Network-related errors
class NetworkException extends ApiException {
  const NetworkException({super.message = 'Network connection failed'})
      : super(code: 'NETWORK_ERROR');
}

/// Timeout errors
class TimeoutException extends ApiException {
  const TimeoutException({super.message = 'Request timed out'})
      : super(code: 'TIMEOUT');
}

/// 401 Unauthorized
class UnauthorizedException extends ApiException {
  const UnauthorizedException({super.message = 'Unauthorized access'})
      : super(statusCode: 401, code: 'UNAUTHORIZED');
}

/// 403 Forbidden
class ForbiddenException extends ApiException {
  const ForbiddenException({super.message = 'Access forbidden'})
      : super(statusCode: 403, code: 'FORBIDDEN');
}

/// 404 Not Found
class NotFoundException extends ApiException {
  const NotFoundException({super.message = 'Resource not found'})
      : super(statusCode: 404, code: 'NOT_FOUND');
}

/// 500 Server Error
class ServerException extends ApiException {
  const ServerException({super.message = 'Internal server error'})
      : super(statusCode: 500, code: 'SERVER_ERROR');
}

/// Validation errors (422)
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  const ValidationException({
    super.message = 'Validation failed',
    this.errors,
  }) : super(statusCode: 422, code: 'VALIDATION_ERROR');
}
