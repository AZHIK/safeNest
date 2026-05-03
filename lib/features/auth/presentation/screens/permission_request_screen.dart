import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/permission_service.dart';

class PermissionRequestScreen extends StatefulWidget {
  const PermissionRequestScreen({super.key});

  @override
  State<PermissionRequestScreen> createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen> {
  final PermissionService _permissionService = PermissionService();
  bool _isRequesting = false;
  PermissionResult? _result;

  Future<void> _requestPermissions() async {
    setState(() => _isRequesting = true);

    final result = await _permissionService.requestAllPermissions();

    setState(() {
      _result = result;
      _isRequesting = false;
    });

    if (result.allGranted && mounted) {
      // All permissions granted, proceed to home
      context.go('/home');
    }
  }

  void _continueToHome() {
    context.go('/home');
  }

  Future<void> _requestLocation() async {
    final status = await _permissionService.requestLocationPermission();
    final granted =
        status == LocationPermission.whileInUse ||
        status == LocationPermission.always;
    setState(() {
      _result =
          _result?.copyWith(locationGranted: granted) ??
          PermissionResult(
            locationGranted: granted,
            cameraGranted: false,
            microphoneGranted: false,
            locationPermission: status,
            cameraStatus: PermissionStatus.denied,
            microphoneStatus: PermissionStatus.denied,
          );
    });
  }

  Future<void> _requestCamera() async {
    final status = await _permissionService.requestCameraPermission();
    setState(() {
      _result =
          _result?.copyWith(cameraGranted: status.isGranted) ??
          PermissionResult(
            locationGranted: false,
            cameraGranted: status.isGranted,
            microphoneGranted: false,
            locationPermission: LocationPermission.denied,
            cameraStatus: status,
            microphoneStatus: PermissionStatus.denied,
          );
    });
  }

  Future<void> _requestMicrophone() async {
    final status = await _permissionService.requestMicrophonePermission();
    setState(() {
      _result =
          _result?.copyWith(microphoneGranted: status.isGranted) ??
          PermissionResult(
            locationGranted: false,
            cameraGranted: false,
            microphoneGranted: status.isGranted,
            locationPermission: LocationPermission.denied,
            cameraStatus: PermissionStatus.denied,
            microphoneStatus: status,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Icon(
                  Icons.security,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'App Permissions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'SafeNest needs the following permissions to keep you safe during emergencies:',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildPermissionCard(
                  icon: Icons.location_on,
                  title: 'Location',
                  description: 'Share your location during SOS alerts',
                  granted: _result?.locationGranted ?? false,
                  onTap: _requestLocation,
                ),
                const SizedBox(height: 16),
                _buildPermissionCard(
                  icon: Icons.camera_alt,
                  title: 'Camera',
                  description: 'Capture evidence and photos for reports',
                  granted: _result?.cameraGranted ?? false,
                  onTap: _requestCamera,
                ),
                const SizedBox(height: 16),
                _buildPermissionCard(
                  icon: Icons.mic,
                  title: 'Microphone',
                  description: 'Record audio evidence during emergencies',
                  granted: _result?.microphoneGranted ?? false,
                  onTap: _requestMicrophone,
                ),
                const SizedBox(height: 24),
                if (_result != null && !_result!.allGranted)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Some permissions were denied. You can grant them later in app settings.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.orange),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isRequesting ? null : _requestPermissions,
                    icon: _isRequesting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(
                      _result == null
                          ? 'Grant Permissions'
                          : _result!.allGranted
                          ? 'Continue'
                          : 'Try Again',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _continueToHome,
                  child: const Text('Skip for Now'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool granted,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: granted ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: granted
                ? Colors.green.withOpacity(0.1)
                : Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(
              granted ? Icons.check : icon,
              color: granted ? Colors.green : Theme.of(context).primaryColor,
            ),
          ),
          title: Text(title),
          subtitle: Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: granted
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.touch_app, color: Colors.grey),
        ),
      ),
    );
  }
}
