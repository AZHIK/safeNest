import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../providers/api_provider.dart';
import '../models/sos_model.dart';
import 'base_repository.dart';

/// SOS Repository
///
/// Handles emergency SOS alerts, location tracking, and status management.
class SOSRepository extends BaseRepository {
  final ApiClient _apiClient;

  SOSRepository(this._apiClient);

  /// Trigger an SOS emergency alert
  Future<SOSResponse> triggerSOS(SOSCreate sosData) async {
    return execute(() async {
      final response = await _apiClient.post(
        ApiConstants.sosTrigger,
        data: sosData.toJson(),
      );
      return SOSResponse.fromJson(response.data as Map<String, dynamic>);
    });
  }

  /// Update location for an active SOS alert
  Future<LocationPingResponse> updateLocation(
    LocationPingCreate locationData,
  ) async {
    return execute(() async {
      final response = await _apiClient.post(
        ApiConstants.sosLocationUpdate,
        data: locationData.toJson(),
      );
      return LocationPingResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  /// Batch upload offline location pings
  Future<List<LocationPingResponse>> batchUpdateLocations(
    String alertId,
    List<LocationPingCreate> locations,
  ) async {
    return execute(() async {
      final response = await _apiClient.post(
        ApiConstants.sosLocationBatch,
        data: {
          'alert_id': alertId,
          'locations': locations.map((l) => l.toJson()).toList(),
        },
      );
      final List<dynamic> data =
          (response.data as Map<String, dynamic>)['locations'] as List<dynamic>;
      return data
          .map((e) => LocationPingResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get status and location history of an SOS alert
  Future<SOSResponse> getSOSStatus(String alertId) async {
    return execute(() async {
      final response = await _apiClient.get(
        '${ApiConstants.sosStatus}/$alertId',
      );
      return SOSResponse.fromJson(response.data as Map<String, dynamic>);
    });
  }

  /// Get active SOS alert for current user
  Future<SOSResponse?> getActiveSOS() async {
    return execute(() async {
      final response = await _apiClient.get(ApiConstants.sosActive);
      if (response.data == null) return null;
      return SOSResponse.fromJson(response.data as Map<String, dynamic>);
    });
  }

  /// Update SOS alert status (resolve or cancel)
  Future<SOSResponse> updateSOSStatus(
    String alertId,
    SOSStatusUpdate statusUpdate,
  ) async {
    return execute(() async {
      final response = await _apiClient.patch(
        '${ApiConstants.sosStatus}/$alertId',
        data: statusUpdate.toJson(),
      );
      return SOSResponse.fromJson(response.data as Map<String, dynamic>);
    });
  }

  /// Get SOS alert history for current user
  Future<List<SOSResponse>> getSOSHistory({int limit = 20}) async {
    return execute(() async {
      final response = await _apiClient.get(
        ApiConstants.sosHistory,
        queryParameters: {'limit': limit},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((e) => SOSResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}

/// Provider for SOSRepository
final sosRepositoryProvider = Provider<SOSRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return SOSRepository(apiClient);
});
