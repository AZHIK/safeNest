import 'package:dio/dio.dart';
import '../api/api_exceptions.dart';

/// Base Repository with common error handling
/// 
/// All data repositories should extend this class.
/// Provides consistent error mapping and loading state helpers.
abstract class BaseRepository {
  
  /// Executes API call with standardized error handling
  /// 
  /// [apiCall] - The async API function to execute
  /// Returns [T] on success, throws [ApiException] on failure
  Future<T> execute<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      // Error already mapped by interceptor
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: e.message ?? 'Request failed');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
  
  /// Executes API call with local fallback
  /// 
  /// [apiCall] - The primary API function
  /// [localFallback] - Fallback to local storage if API fails
  Future<T> executeWithFallback<T>({
    required Future<T> Function() apiCall,
    required Future<T> Function() localFallback,
  }) async {
    try {
      return await apiCall();
    } on ApiException {
      // Try local fallback on any API error
      return await localFallback();
    }
  }
}
