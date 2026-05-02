import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../providers/api_provider.dart';
import '../api/api_constants.dart';
import '../models/report_model.dart';
import 'base_repository.dart';

/// Report Repository
///
/// Handles incident reports and evidence file uploads.
class ReportRepository extends BaseRepository {
  final ApiClient _apiClient;

  ReportRepository(this._apiClient);

  /// Create a new incident report
  Future<IncidentReportResponse> createReport(
    IncidentReportCreate report,
  ) async {
    return execute(() async {
      final response = await _apiClient.post(
        ApiConstants.reportsCreate,
        data: report.toJson(),
      );
      return IncidentReportResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  /// Get current user's incident reports
  Future<List<IncidentReportResponse>> getMyReports({
    int skip = 0,
    int limit = 20,
  }) async {
    return execute(() async {
      final response = await _apiClient.get(
        ApiConstants.reportsMyReports,
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map(
            (e) => IncidentReportResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    });
  }

  /// Get specific report with evidence
  Future<Map<String, dynamic>> getReportDetail(String reportId) async {
    return execute(() async {
      final response = await _apiClient.get(
        '${ApiConstants.reportsDetail}/$reportId',
      );
      return response.data as Map<String, dynamic>;
    });
  }

  /// Upload encrypted evidence file for a report
  ///
  /// [reportId] - UUID of the report
  /// [fileType] - Type: image, audio, video, document
  /// [fileData] - The file bytes
  /// [encryptionMetadata] - JSON string with encryption info
  /// [fileHashSha256] - SHA256 hash of the original file
  Future<EvidenceFileResponse> uploadEvidence({
    required String reportId,
    required String fileType,
    required List<int> fileData,
    required String encryptionMetadata,
    required String fileHashSha256,
    bool hasGpsMetadata = false,
    double? gpsLatitude,
    double? gpsLongitude,
    DateTime? recordedAt,
    String? offlineId,
  }) async {
    return execute(() async {
      // Use Dio directly for multipart form data
      final formData = FormData.fromMap({
        'report_id': reportId,
        'file_type': fileType,
        'encryption_metadata': encryptionMetadata,
        'file_hash_sha256': fileHashSha256,
        'has_gps_metadata': hasGpsMetadata,
        if (gpsLatitude != null) 'gps_latitude': gpsLatitude,
        if (gpsLongitude != null) 'gps_longitude': gpsLongitude,
        if (recordedAt != null) 'recorded_at': recordedAt.toIso8601String(),
        if (offlineId != null) 'offline_id': offlineId,
        'file': MultipartFile.fromBytes(
          fileData,
          filename: 'evidence.$fileType',
        ),
      });

      final response = await _apiClient.post(
        ApiConstants.reportsUploadEvidence,
        data: formData,
      );
      return EvidenceFileResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }
}

/// Provider for ReportRepository
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ReportRepository(apiClient);
});
