import 'base_model.dart';

/// Incident Report Create Request
///
/// Matches FastAPI backend IncidentReportCreate schema
class IncidentReportCreate extends BaseModel {
  final String reportType;
  final DateTime? incidentDate;
  final double? incidentLatitude;
  final double? incidentLongitude;
  final String? incidentAddress;
  final String descriptionEncrypted;
  final Map<String, dynamic>? encryptionMetadata;
  final bool isAnonymous;
  final String? reporterAgeRange;
  final String? reporterGender;
  final String followUpPreference;
  final String? contactEmailEncrypted;
  final String? contactPhoneEncrypted;
  final DateTime? clientCreatedAt;
  final String? offlineId;

  const IncidentReportCreate({
    required this.reportType,
    this.incidentDate,
    this.incidentLatitude,
    this.incidentLongitude,
    this.incidentAddress,
    required this.descriptionEncrypted,
    this.encryptionMetadata,
    this.isAnonymous = false,
    this.reporterAgeRange,
    this.reporterGender,
    this.followUpPreference = 'none',
    this.contactEmailEncrypted,
    this.contactPhoneEncrypted,
    this.clientCreatedAt,
    this.offlineId,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'report_type': reportType,
      'description_encrypted': descriptionEncrypted,
      'is_anonymous': isAnonymous,
      'follow_up_preference': followUpPreference,
      'encryption_metadata': encryptionMetadata ?? {},
    };
    if (incidentDate != null)
      data['incident_date'] = incidentDate!.toIso8601String();
    if (incidentLatitude != null) data['incident_latitude'] = incidentLatitude;
    if (incidentLongitude != null)
      data['incident_longitude'] = incidentLongitude;
    if (incidentAddress != null) data['incident_address'] = incidentAddress;
    if (reporterAgeRange != null) data['reporter_age_range'] = reporterAgeRange;
    if (reporterGender != null) data['reporter_gender'] = reporterGender;
    if (contactEmailEncrypted != null)
      data['contact_email_encrypted'] = contactEmailEncrypted;
    if (contactPhoneEncrypted != null)
      data['contact_phone_encrypted'] = contactPhoneEncrypted;
    if (clientCreatedAt != null)
      data['client_created_at'] = clientCreatedAt!.toIso8601String();
    if (offlineId != null) data['offline_id'] = offlineId;
    return data;
  }
}

/// Incident Report Response Model
class IncidentReportResponse extends BaseModel {
  final String id;
  final String reportNumber;
  final String reportType;
  final String status;
  final bool isAnonymous;
  final DateTime? incidentDate;
  final double? incidentLatitude;
  final double? incidentLongitude;
  final Map<String, dynamic>? encryptionMetadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? clientCreatedAt;
  final String? offlineId;

  const IncidentReportResponse({
    required this.id,
    required this.reportNumber,
    required this.reportType,
    required this.status,
    required this.isAnonymous,
    this.incidentDate,
    this.incidentLatitude,
    this.incidentLongitude,
    this.encryptionMetadata,
    required this.createdAt,
    this.updatedAt,
    this.clientCreatedAt,
    this.offlineId,
  });

  factory IncidentReportResponse.fromJson(Map<String, dynamic> json) {
    return IncidentReportResponse(
      id: json['id'] as String,
      reportNumber: json['report_number'] as String,
      reportType: json['report_type'] as String,
      status: json['status'] as String,
      isAnonymous: json['is_anonymous'] as bool,
      incidentDate: json['incident_date'] != null
          ? DateTime.parse(json['incident_date'] as String)
          : null,
      incidentLatitude: json['incident_latitude'] as double?,
      incidentLongitude: json['incident_longitude'] as double?,
      encryptionMetadata: json['encryption_metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      clientCreatedAt: json['client_created_at'] != null
          ? DateTime.parse(json['client_created_at'] as String)
          : null,
      offlineId: json['offline_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_number': reportNumber,
      'report_type': reportType,
      'status': status,
      'is_anonymous': isAnonymous,
      'incident_date': incidentDate?.toIso8601String(),
      'incident_latitude': incidentLatitude,
      'incident_longitude': incidentLongitude,
      'encryption_metadata': encryptionMetadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'client_created_at': clientCreatedAt?.toIso8601String(),
      'offline_id': offlineId,
    };
  }
}

/// Evidence File Response Model
class EvidenceFileResponse extends BaseModel {
  final String id;
  final String reportId;
  final String fileType;
  final String mimeType;
  final int fileSizeBytes;
  final String storagePath;
  final Map<String, dynamic>? encryptionMetadata;
  final String fileHashSha256;
  final bool hasGpsMetadata;
  final String processingStatus;
  final String virusScanStatus;
  final DateTime uploadedAt;
  final String? thumbnailPath;
  final String? offlineId;

  const EvidenceFileResponse({
    required this.id,
    required this.reportId,
    required this.fileType,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.storagePath,
    this.encryptionMetadata,
    required this.fileHashSha256,
    required this.hasGpsMetadata,
    required this.processingStatus,
    required this.virusScanStatus,
    required this.uploadedAt,
    this.thumbnailPath,
    this.offlineId,
  });

  factory EvidenceFileResponse.fromJson(Map<String, dynamic> json) {
    return EvidenceFileResponse(
      id: json['id'] as String,
      reportId: json['report_id'] as String,
      fileType: json['file_type'] as String,
      mimeType: json['mime_type'] as String,
      fileSizeBytes: json['file_size_bytes'] as int,
      storagePath: json['storage_path'] as String,
      encryptionMetadata: json['encryption_metadata'] as Map<String, dynamic>?,
      fileHashSha256: json['file_hash_sha256'] as String,
      hasGpsMetadata: json['has_gps_metadata'] as bool,
      processingStatus: json['processing_status'] as String,
      virusScanStatus: json['virus_scan_status'] as String,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      thumbnailPath: json['thumbnail_path'] as String?,
      offlineId: json['offline_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_id': reportId,
      'file_type': fileType,
      'mime_type': mimeType,
      'file_size_bytes': fileSizeBytes,
      'storage_path': storagePath,
      'encryption_metadata': encryptionMetadata,
      'file_hash_sha256': fileHashSha256,
      'has_gps_metadata': hasGpsMetadata,
      'processing_status': processingStatus,
      'virus_scan_status': virusScanStatus,
      'uploaded_at': uploadedAt.toIso8601String(),
      'thumbnail_path': thumbnailPath,
      'offline_id': offlineId,
    };
  }
}
