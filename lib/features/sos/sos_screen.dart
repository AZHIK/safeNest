import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_texts.dart';
import '../../core/localization/app_localization.dart';
import '../../core/repositories/sos_repository.dart';
import '../../core/models/sos_model.dart';
import '../../services/location_service.dart';

enum SosStatus { idle, sending, sent }

class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen> {
  SosStatus _status = SosStatus.idle;
  String? _errorMessage;
  SOSResponse? _sosResponse;

  void _triggerSos() async {
    setState(() {
      _status = SosStatus.sending;
      _errorMessage = null;
    });

    try {
      // Get current location
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentLocation();

      if (position == null) {
        setState(() {
          _status = SosStatus.idle;
          _errorMessage =
              'Could not get location. Please enable location services.';
        });
        return;
      }

      // Send SOS to backend
      final sosRepo = ref.read(sosRepositoryProvider);
      final sosData = SOSCreate(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        alertType: 'manual',
        message: 'Emergency SOS triggered',
        clientCreatedAt: DateTime.now(),
      );

      final response = await sosRepo.triggerSOS(sosData);

      if (mounted) {
        setState(() {
          _status = SosStatus.sent;
          _sosResponse = response;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = SosStatus.idle;
          _errorMessage = 'Failed to send SOS: ${e.toString()}';
        });
      }
    }
  }

  void _cancelSos() async {
    if (_sosResponse == null) return;

    try {
      final sosRepo = ref.read(sosRepositoryProvider);
      await sosRepo.updateSOSStatus(
        _sosResponse!.id,
        SOSStatusUpdate(status: 'cancelled'),
      );

      if (mounted) {
        setState(() => _status = SosStatus.idle);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSent = _status == SosStatus.sent;
    final lang = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: isSent ? AppColors.success : AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isSent ? Colors.white : AppColors.textPrimaryDark,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIcon(isSent),
                    const SizedBox(height: AppSizes.p32),
                    Text(
                      _getTitle(lang),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppSizes.fontHeadline,
                        fontWeight: FontWeight.bold,
                        color: isSent
                            ? Colors.white
                            : AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p16),
                    Text(
                      _getSubtitle(lang),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppSizes.fontSubtitle,
                        color: isSent
                            ? Colors.white.withValues(alpha: 0.9)
                            : AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p48),
                    if (_status == SosStatus.idle) ...[
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.p16),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: AppSizes.fontSmall,
                            ),
                          ),
                        ),
                      _SosButton(onPressed: _triggerSos),
                    ] else if (_status == SosStatus.sending)
                      const CircularProgressIndicator(color: AppColors.error)
                    else if (_status == SosStatus.sent)
                      ElevatedButton.icon(
                        onPressed: _cancelSos,
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancel SOS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.p24,
                            vertical: AppSizes.p12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _LocationIndicator(isSent: isSent, alertId: _sosResponse?.id),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(bool isSent) {
    if (isSent) {
      return const Icon(
        Icons.check_circle_outline,
        size: 120,
        color: Colors.white,
      );
    }
    return Container(
      padding: const EdgeInsets.all(AppSizes.p24),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _status == SosStatus.sending ? Icons.wifi_tethering : Icons.security,
        size: 80,
        color: AppColors.error,
      ),
    );
  }

  String _getTitle(AppLanguage lang) {
    switch (_status) {
      case SosStatus.idle:
        return AppTexts.sosTitle(lang);
      case SosStatus.sending:
        return AppTranslations.get('sendingAlert', lang);
      case SosStatus.sent:
        return AppTexts.sosActive(lang);
    }
  }

  String _getSubtitle(AppLanguage lang) {
    switch (_status) {
      case SosStatus.idle:
        return AppTranslations.get('sosSubtitleIdle', lang);
      case SosStatus.sending:
        return AppTranslations.get('sosSubtitleSending', lang);
      case SosStatus.sent:
        return AppTexts.sosInstruction(lang);
    }
  }
}

class _SosButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SosButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.error,
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.4),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.power_settings_new, color: Colors.white, size: 48),
              SizedBox(height: AppSizes.p8),
              Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: AppSizes.fontDisplay,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationIndicator extends ConsumerWidget {
  final bool isSent;
  final String? alertId;
  const _LocationIndicator({required this.isSent, this.alertId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);
    return Container(
      padding: const EdgeInsets.all(AppSizes.p24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on,
            color: isSent ? Colors.white : AppColors.secondary,
            size: AppSizes.iconSmall,
          ),
          const SizedBox(width: AppSizes.p8),
          Text(
            AppTranslations.get('liveTracking', lang),
            style: TextStyle(
              fontSize: AppSizes.fontSmall,
              fontWeight: FontWeight.w500,
              color: isSent ? Colors.white : AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
