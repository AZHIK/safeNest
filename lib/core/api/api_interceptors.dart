import 'package:dio/dio.dart';
import 'api_exceptions.dart';
import '../services/token_storage_service.dart';

/// Request Interceptor - Adds auth tokens and common headers
class AuthInterceptor extends Interceptor {
  final TokenStorageService _tokenStorage = TokenStorageService();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Retrieve token from secure storage
    final token = await _tokenStorage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    handler.next(options);
  }
}

/// Error Interceptor - Converts Dio errors to ApiExceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioError(err);
    handler.reject(exception);
  }

  DioException _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return DioException(
          requestOptions: error.requestOptions,
          error: const TimeoutException(),
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return DioException(
          requestOptions: error.requestOptions,
          error: const NetworkException(),
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Request failed';

        switch (statusCode) {
          case 400:
            return DioException(
              requestOptions: error.requestOptions,
              error: ApiException(
                message: message,
                statusCode: statusCode,
                code: 'BAD_REQUEST',
              ),
            );
          case 401:
            return DioException(
              requestOptions: error.requestOptions,
              error: const UnauthorizedException(),
            );
          case 403:
            return DioException(
              requestOptions: error.requestOptions,
              error: const ForbiddenException(),
            );
          case 404:
            return DioException(
              requestOptions: error.requestOptions,
              error: const NotFoundException(),
            );
          case 422:
            return DioException(
              requestOptions: error.requestOptions,
              error: ValidationException(
                message: message,
                errors: error.response?.data?['errors'],
              ),
            );
          case 500:
          case 502:
          case 503:
            return DioException(
              requestOptions: error.requestOptions,
              error: const ServerException(),
            );
          default:
            return DioException(
              requestOptions: error.requestOptions,
              error: ApiException(message: message, statusCode: statusCode),
            );
        }

      default:
        return DioException(
          requestOptions: error.requestOptions,
          error: ApiException(message: error.message ?? 'Unknown error'),
        );
    }
  }
}

/// Logging Interceptor - For debug builds
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: Use Logger instead of print in production
    // ignore: avoid_print
    print('REQUEST: ${options.method} ${options.uri}');
    // ignore: avoid_print
    print('HEADERS: ${options.headers}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('ERROR: ${err.type} ${err.message}');
    handler.next(err);
  }
}
