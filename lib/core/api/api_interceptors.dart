import 'package:dio/dio.dart';
import 'api_exceptions.dart';
import '../services/token_storage_service.dart';
import '../repositories/auth_repository.dart';
import 'api_client.dart';

/// Request Interceptor - Adds auth tokens and common headers
/// Handles automatic token refresh on 401 errors with request queuing
class AuthInterceptor extends QueuedInterceptorsWrapper {
  final TokenStorageService _tokenStorage = TokenStorageService();
  bool _isRefreshing = false;
  final List<_RequestQueueItem> _requestQueue = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for refresh and logout endpoints to prevent circular calls
    final skipAuth =
        options.path.contains('/auth/refresh') ||
        options.path.contains('/auth/logout') ||
        options.path.contains('/auth/request-otp') ||
        options.path.contains('/auth/verify-otp') ||
        options.path.contains('/auth/anonymous');

    if (!skipAuth) {
      final token = await _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized with automatic token refresh
    if (err.response?.statusCode == 401 &&
        !_isRefreshing &&
        !err.requestOptions.path.contains('/auth/refresh') &&
        !err.requestOptions.path.contains('/auth/logout')) {
      _isRefreshing = true;

      try {
        // Attempt to refresh the token
        final apiClient = ApiClient();
        final authRepository = AuthRepository(apiClient);
        await authRepository.refreshAccessToken();

        _isRefreshing = false;

        // Retry all queued requests with new token
        final newToken = await _tokenStorage.getAccessToken();
        for (final item in _requestQueue) {
          item.handler.resolve(
            await _retryRequest(item.requestOptions, newToken),
          );
        }
        _requestQueue.clear();

        // Retry the failed request
        handler.resolve(await _retryRequest(err.requestOptions, newToken));
        return;
      } catch (refreshError) {
        _isRefreshing = false;
        _requestQueue.clear();

        // Refresh failed - clear tokens and reject
        await _tokenStorage.clearTokens();
        handler.reject(err);
        return;
      }
    }

    // If already refreshing, queue the request
    if (_isRefreshing && err.response?.statusCode == 401) {
      _requestQueue.add(_RequestQueueItem(err.requestOptions, handler));
      return;
    }

    handler.next(err);
  }

  Future<Response> _retryRequest(
    RequestOptions requestOptions,
    String? newToken,
  ) async {
    final headers = Map<String, dynamic>.from(requestOptions.headers);

    if (newToken != null && newToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $newToken';
    }

    final options = Options(method: requestOptions.method, headers: headers);

    return Dio().request(
      requestOptions.uri.toString(),
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}

class _RequestQueueItem {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  _RequestQueueItem(this.requestOptions, this.handler);
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
