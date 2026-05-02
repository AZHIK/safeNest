import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../providers/api_provider.dart';
import '../models/support_center_model.dart';
import 'base_repository.dart';

/// Support Center Repository
///
/// Handles discovery of nearby support centers and center details.
class SupportCenterRepository extends BaseRepository {
  final ApiClient _apiClient;

  SupportCenterRepository(this._apiClient);

  /// Find support centers near a location
  Future<List<SupportCenterResponse>> findNearby(
    SupportCenterNearbyRequest request,
  ) async {
    return execute(() async {
      final response = await _apiClient.post(
        ApiConstants.supportCentersNearby,
        data: request.toJson(),
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => SupportCenterResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get support center details
  Future<SupportCenterResponse> getCenterDetail(String centerId) async {
    return execute(() async {
      final response = await _apiClient.get(
        '${ApiConstants.supportCentersDetail}/$centerId',
      );
      return SupportCenterResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  /// Get support centers by type
  Future<List<SupportCenterResponse>> getCentersByType(
    String centerType, {
    String? city,
  }) async {
    return execute(() async {
      final queryParams = <String, dynamic>{'city': city};
      queryParams.removeWhere((key, value) => value == null);

      final response = await _apiClient.get(
        '${ApiConstants.supportCentersByType}/$centerType',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => SupportCenterResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get verified support centers
  Future<List<SupportCenterResponse>> getVerifiedCenters({
    int limit = 100,
  }) async {
    return execute(() async {
      final response = await _apiClient.get(
        ApiConstants.supportCentersVerified,
        queryParameters: {'limit': limit},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => SupportCenterResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}

/// Provider for SupportCenterRepository
final supportCenterRepositoryProvider = Provider<SupportCenterRepository>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  return SupportCenterRepository(apiClient);
});
