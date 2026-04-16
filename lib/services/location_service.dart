import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../core/database/app_database.dart';
import '../core/providers/database_provider.dart';
import 'dart:math' show cos, sqrt, asin;

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService(ref.watch(dbProvider));
});

abstract class BaseLocationService {
  Future<List<SupportCenterEntry>> getNearbySupportCenters();
  Future<Position?> getCurrentLocation();
}

class LocationService implements BaseLocationService {
  final AppDatabase _db;

  LocationService(this._db);

  @override
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  @override
  Future<List<SupportCenterEntry>> getNearbySupportCenters() async {
    final position = await getCurrentLocation();
    final centers = await _db.select(_db.supportCenters).get();

    if (position == null) return centers;

    // Haversine sorting
    centers.sort((a, b) {
      final distA = _calculateDistance(
        position.latitude,
        position.longitude,
        a.latitude,
        a.longitude,
      );
      final distB = _calculateDistance(
        position.latitude,
        position.longitude,
        b.latitude,
        b.longitude,
      );
      return distA.compareTo(distB);
    });

    return centers;
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    var p = 0.017453292519943295;
    var c = cos;
    var a =
        0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
