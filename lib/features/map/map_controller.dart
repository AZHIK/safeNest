import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/models/support_center_model.dart';
import '../../core/repositories/support_center_repository.dart';
import '../../services/location_service.dart';
import 'map_screen.dart';

/// Provider for nearby support centers
final nearbyCentersProvider = AsyncNotifierProvider<NearbyCentersNotifier, List<SupportCenterResponse>>(() {
  return NearbyCentersNotifier();
});

class NearbyCentersNotifier extends AsyncNotifier<List<SupportCenterResponse>> {
  @override
  Future<List<SupportCenterResponse>> build() async {
    final filterKey = ref.watch(mapFilterProvider);
    return _fetchCenters(filterKey);
  }

  Future<List<SupportCenterResponse>> _fetchCenters(String filterKey) async {
    final repository = ref.read(supportCenterRepositoryProvider);
    final locationService = ref.read(locationServiceProvider);

    Position? position;
    for (int attempt = 0; attempt < 3; attempt++) {
      position = await locationService.getCurrentLocation();
      if (position != null) break;
      if (attempt < 2) await Future.delayed(const Duration(seconds: 2));
    }

    if (position == null) {
      return [];
    }

    final List<String>? centerTypes = _mapFilterToBackendTypes(filterKey);

    final request = SupportCenterNearbyRequest(
      latitude: position.latitude,
      longitude: position.longitude,
      radiusKm: 10.0,
      centerTypes: centerTypes,
    );

    return repository.findNearby(request);
  }

  List<String>? _mapFilterToBackendTypes(String filterKey) {
    switch (filterKey) {
      case 'filterPolice':
        return ['police'];
      case 'filterHealth':
        return ['hospital'];
      case 'filterLegal':
        return ['legal_aid'];
      case 'filterSupport':
        return ['ngo', 'shelter', 'hotline', 'counseling'];
      case 'filterAll':
      default:
        return null;
    }
  }

  /// Refresh the centers list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchCenters(ref.read(mapFilterProvider)));
  }
}
