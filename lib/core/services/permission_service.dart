import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

/// Service for handling app permissions
class PermissionService {
  /// Check if all required permissions are granted
  Future<Map<Permission, PermissionStatus>> checkAllPermissions() async {
    final statuses = await [
      Permission.location,
      Permission.camera,
      Permission.microphone,
    ].request();

    return statuses;
  }

  /// Request location permission via Geolocator (existing approach)
  Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Request camera permission
  Future<PermissionStatus> requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isDenied) {
      return await Permission.camera.request();
    }
    return status;
  }

  /// Request microphone permission
  Future<PermissionStatus> requestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isDenied) {
      return await Permission.microphone.request();
    }
    return status;
  }

  /// Request all permissions in sequence and return results
  Future<PermissionResult> requestAllPermissions() async {
    // Request location
    final locationPermission = await requestLocationPermission();
    final locationGranted =
        locationPermission == LocationPermission.whileInUse ||
        locationPermission == LocationPermission.always;

    // Request camera
    final cameraStatus = await requestCameraPermission();
    final cameraGranted = cameraStatus.isGranted;

    // Request microphone
    final microphoneStatus = await requestMicrophonePermission();
    final microphoneGranted = microphoneStatus.isGranted;

    return PermissionResult(
      locationGranted: locationGranted,
      cameraGranted: cameraGranted,
      microphoneGranted: microphoneGranted,
      locationPermission: locationPermission,
      cameraStatus: cameraStatus,
      microphoneStatus: microphoneStatus,
    );
  }

  /// Check if any permission is permanently denied
  Future<bool> hasPermanentlyDeniedPermissions() async {
    final location = await Geolocator.checkPermission();
    final camera = await Permission.camera.status;
    final microphone = await Permission.microphone.status;

    return location == LocationPermission.deniedForever ||
        camera.isPermanentlyDenied ||
        microphone.isPermanentlyDenied;
  }

  /// Open app settings
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}

/// Result of permission requests
class PermissionResult {
  final bool locationGranted;
  final bool cameraGranted;
  final bool microphoneGranted;
  final LocationPermission locationPermission;
  final PermissionStatus cameraStatus;
  final PermissionStatus microphoneStatus;

  PermissionResult({
    required this.locationGranted,
    required this.cameraGranted,
    required this.microphoneGranted,
    required this.locationPermission,
    required this.cameraStatus,
    required this.microphoneStatus,
  });

  bool get allGranted => locationGranted && cameraGranted && microphoneGranted;
  bool get anyGranted => locationGranted || cameraGranted || microphoneGranted;

  List<String> get deniedPermissions {
    final denied = <String>[];
    if (!locationGranted) denied.add('Location');
    if (!cameraGranted) denied.add('Camera');
    if (!microphoneGranted) denied.add('Microphone');
    return denied;
  }

  PermissionResult copyWith({
    bool? locationGranted,
    bool? cameraGranted,
    bool? microphoneGranted,
    LocationPermission? locationPermission,
    PermissionStatus? cameraStatus,
    PermissionStatus? microphoneStatus,
  }) {
    return PermissionResult(
      locationGranted: locationGranted ?? this.locationGranted,
      cameraGranted: cameraGranted ?? this.cameraGranted,
      microphoneGranted: microphoneGranted ?? this.microphoneGranted,
      locationPermission: locationPermission ?? this.locationPermission,
      cameraStatus: cameraStatus ?? this.cameraStatus,
      microphoneStatus: microphoneStatus ?? this.microphoneStatus,
    );
  }
}
