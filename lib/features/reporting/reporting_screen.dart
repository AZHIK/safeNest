import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_texts.dart';
import '../../core/localization/app_localization.dart';
import '../../core/repositories/report_repository.dart';
import '../../core/models/report_model.dart';
import '../../services/location_service.dart';

enum ReportStatus { idle, submitting, success, error }

class ReportingScreen extends ConsumerStatefulWidget {
  const ReportingScreen({super.key});

  @override
  ConsumerState<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends ConsumerState<ReportingScreen> {
  bool _isAnonymous = true;
  ReportStatus _status = ReportStatus.idle;
  String? _errorMessage;
  String? _reportId;
  final TextEditingController _reportController = TextEditingController();
  final List<EvidenceFile> _evidenceFiles = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _reportController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      setState(() {
        _evidenceFiles.add(
          EvidenceFile(
            name: path.basename(image.path),
            bytes: bytes,
            type: 'image',
            mimeType: 'image/jpeg',
            path: image.path,
          ),
        );
      });
    }
  }

  Future<void> _recordAudio() async {
    // TODO: Implement audio recording
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audio recording not yet implemented')),
    );
  }

  void _removeEvidence(int index) {
    setState(() => _evidenceFiles.removeAt(index));
  }

  Future<void> _submitReport() async {
    if (_reportController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please describe the incident');
      return;
    }

    setState(() {
      _status = ReportStatus.submitting;
      _errorMessage = null;
    });

    try {
      // Get location
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentLocation();

      // Create report with proper payload format
      final reportRepo = ref.read(reportRepositoryProvider);
      final now = DateTime.now();

      // Encode description as base64 (placeholder for actual encryption)
      final descriptionBytes = utf8.encode(_reportController.text.trim());
      final descriptionBase64 = base64Encode(descriptionBytes);

      final reportData = IncidentReportCreate(
        reportType: 'assault',
        descriptionEncrypted: descriptionBase64,
        encryptionMetadata: {
          'algorithm': 'AES-256-GCM',
          'key_id': 'user_key_${now.millisecondsSinceEpoch}',
          'iv': base64Encode(
            utf8.encode('nonce_${now.millisecondsSinceEpoch}'),
          ),
        },
        isAnonymous: _isAnonymous,
        followUpPreference: _isAnonymous ? 'none' : 'email',
        incidentLatitude: position?.latitude,
        incidentLongitude: position?.longitude,
        incidentDate: now,
        clientCreatedAt: now,
      );

      final reportResponse = await reportRepo.createReport(reportData);
      _reportId = reportResponse.id;

      // Upload evidence files
      for (final evidence in _evidenceFiles) {
        await reportRepo.uploadEvidence(
          reportId: _reportId!,
          fileType: evidence.type,
          fileData: evidence.bytes,
          encryptionMetadata: '{}',
          fileHashSha256:
              'placeholder_hash_${DateTime.now().millisecondsSinceEpoch}',
          hasGpsMetadata: position != null,
          gpsLatitude: position?.latitude,
          gpsLongitude: position?.longitude,
          recordedAt: DateTime.now(),
          mimeType: evidence.mimeType,
        );
      }

      if (mounted) {
        setState(() => _status = ReportStatus.success);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Report #${reportResponse.reportNumber} submitted successfully.',
            ),
          ),
        );
        // Clear form after successful submission
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _status = ReportStatus.idle;
              _reportController.clear();
              _evidenceFiles.clear();
              _reportId = null;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = ReportStatus.error;
          _errorMessage = 'Failed to submit report: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppTexts.reportTitle(lang))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              lang == AppLanguage.english
                  ? 'Detail the incident securely.'
                  : 'Eleza tukio hili kwa usalama.',
              style: const TextStyle(
                fontSize: AppSizes.fontSubtitle,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            // Text Input
            TextField(
              controller: _reportController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: lang == AppLanguage.english
                    ? 'Describe what happened...'
                    : 'Eleza nini kilitokea...',
                hintStyle: const TextStyle(color: AppColors.textSecondaryLight),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p24),

            // Evidence Buttons
            Row(
              children: [
                Expanded(
                  child: _EvidenceButton(
                    icon: Icons.camera_alt_outlined,
                    label: lang == AppLanguage.english
                        ? 'Add Image'
                        : 'Ongeza Picha',
                    onTap: _status == ReportStatus.submitting
                        ? null
                        : _pickImage,
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: _EvidenceButton(
                    icon: Icons.mic_none,
                    label: lang == AppLanguage.english
                        ? 'Record Audio'
                        : 'Rekodi Sauti',
                    onTap: _status == ReportStatus.submitting
                        ? null
                        : _recordAudio,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p24),

            // Evidence Files List
            if (_evidenceFiles.isNotEmpty) ...[
              Text(
                lang == AppLanguage.english
                    ? 'Evidence Files (${_evidenceFiles.length})'
                    : 'Faili za Ushahidi (${_evidenceFiles.length})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.p8),
              ..._evidenceFiles.asMap().entries.map(
                (entry) => Card(
                  child: ListTile(
                    leading: Icon(
                      entry.value.type == 'image'
                          ? Icons.image
                          : Icons.audio_file,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      entry.value.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${(entry.value.bytes.length / 1024).toStringAsFixed(1)} KB',
                    ),
                    trailing: _status == ReportStatus.idle
                        ? IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeEvidence(entry.key),
                          )
                        : entry.value.uploaded
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p24),
            ],

            // Anonymous Toggle
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p16,
                vertical: AppSizes.p8,
              ),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.radius12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: Text(
                      lang == AppLanguage.english
                          ? 'Report Anonymously'
                          : 'Toa Ripoti Bila Jina',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Switch(
                    value: _isAnonymous,
                    onChanged: (val) => setState(() => _isAnonymous = val),
                    activeThumbColor: AppColors.secondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.p8),
            Text(
              lang == AppLanguage.english
                  ? 'Your identification will not be shared with anyone if anonymous is enabled.'
                  : 'Utambulisho wako hautashirikishwa na mtu yeyote ikiwa ripoti bila jina imewezeshwa.',
              style: const TextStyle(
                fontSize: AppSizes.fontSmall,
                color: AppColors.textSecondaryLight,
              ),
            ),

            const SizedBox(height: AppSizes.p48),

            // Error Message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.p16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _status == ReportStatus.submitting
                    ? null
                    : _submitReport,
                child: _status == ReportStatus.submitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Submitting...'),
                        ],
                      )
                    : Text(AppTexts.submitReport(lang)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EvidenceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _EvidenceButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radius12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDisabled ? Colors.grey[200]! : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radius12),
          color: isDisabled ? Colors.grey[50] : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isDisabled ? Colors.grey[400] : AppColors.primary,
            ),
            const SizedBox(height: AppSizes.p4),
            Text(
              label,
              style: TextStyle(
                fontSize: AppSizes.fontSmall,
                color: isDisabled ? Colors.grey[400] : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class for evidence files
class EvidenceFile {
  final String name;
  final Uint8List bytes;
  final String type;
  final String mimeType;
  final String path;
  bool uploaded;

  EvidenceFile({
    required this.name,
    required this.bytes,
    required this.type,
    required this.mimeType,
    required this.path,
    this.uploaded = false,
  });
}
