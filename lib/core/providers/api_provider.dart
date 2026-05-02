import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

/// Provider for the API client instance
///
/// Access via: `ref.read(apiClientProvider)`
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provider for the Dio instance if needed directly
///
/// Access via: `ref.read(dioProvider)`
final dioProvider = Provider((ref) {
  return ref.read(apiClientProvider).dio;
});
