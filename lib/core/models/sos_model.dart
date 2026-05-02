import 'base_model.dart';

/// SOS Alert Create Request
///
/// Matches FastAPI backend SOSCreate schema
class SOSCreate extends BaseModel {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final int? batteryLevel;
  final String? networkType;
  final String alertType;
  final String? message;
  final String? triggeredByDeviceId;
  final DateTime? clientCreatedAt;
  final String? offlineId;

  const SOSCreate({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    this.batteryLevel,
    this.networkType,
    this.alertType = 'manual',
    this.message,
    this.triggeredByDeviceId,
    this.clientCreatedAt,
    this.offlineId,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'latitude': latitude,
      'longitude': longitude,
      'alert_type': alertType,
    };
    if (accuracy != null) data['accuracy'] = accuracy;
    if (altitude != null) data['altitude'] = altitude;
    if (speed != null) data['speed'] = speed;
    if (heading != null) data['heading'] = heading;
    if (batteryLevel != null) data['battery_level'] = batteryLevel;
    if (networkType != null) data['network_type'] = networkType;
    if (message != null) data['message'] = message;
    if (triggeredByDeviceId != null)
      data['triggered_by_device_id'] = triggeredByDeviceId;
    if (clientCreatedAt != null)
      data['client_created_at'] = clientCreatedAt!.toIso8601String();
    if (offlineId != null) data['offline_id'] = offlineId;
    return data;
  }
}

/// SOS Alert Response Model
///
/// Matches FastAPI backend SOSResponse schema
class SOSResponse extends BaseModel {
  final String id;
  final String userId;
  final String status;
  final String alertType;
  final String severity;
  final double initialLatitude;
  final double initialLongitude;
  final double? initialAccuracy;
  final String? initialAddress;
  final String? message;
  final int contactsNotified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? clientCreatedAt;
  final String? offlineId;

  const SOSResponse({
    required this.id,
    required this.userId,
    required this.status,
    required this.alertType,
    required this.severity,
    required this.initialLatitude,
    required this.initialLongitude,
    this.initialAccuracy,
    this.initialAddress,
    this.message,
    required this.contactsNotified,
    required this.createdAt,
    this.updatedAt,
    this.clientCreatedAt,
    this.offlineId,
  });

  factory SOSResponse.fromJson(Map<String, dynamic> json) {
    return SOSResponse(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      alertType: json['alert_type'] as String,
      severity: json['severity'] as String,
      initialLatitude: json['initial_latitude'] as double,
      initialLongitude: json['initial_longitude'] as double,
      initialAccuracy: json['initial_accuracy'] as double?,
      initialAddress: json['initial_address'] as String?,
      message: json['message'] as String?,
      contactsNotified: json['contacts_notified'] as int,
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
      'user_id': userId,
      'status': status,
      'alert_type': alertType,
      'severity': severity,
      'initial_latitude': initialLatitude,
      'initial_longitude': initialLongitude,
      'initial_accuracy': initialAccuracy,
      'initial_address': initialAddress,
      'message': message,
      'contacts_notified': contactsNotified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'client_created_at': clientCreatedAt?.toIso8601String(),
      'offline_id': offlineId,
    };
  }
}

/// Location Ping Create Request
class LocationPingCreate extends BaseModel {
  final String? alertId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final int? batteryLevel;
  final String? networkType;
  final int? signalStrength;
  final DateTime recordedAt;
  final int? offlineSequence;

  const LocationPingCreate({
    this.alertId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    this.batteryLevel,
    this.networkType,
    this.signalStrength,
    required this.recordedAt,
    this.offlineSequence,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'latitude': latitude,
      'longitude': longitude,
      'recorded_at': recordedAt.toIso8601String(),
    };
    if (alertId != null) data['alert_id'] = alertId;
    if (accuracy != null) data['accuracy'] = accuracy;
    if (altitude != null) data['altitude'] = altitude;
    if (speed != null) data['speed'] = speed;
    if (heading != null) data['heading'] = heading;
    if (batteryLevel != null) data['battery_level'] = batteryLevel;
    if (networkType != null) data['network_type'] = networkType;
    if (signalStrength != null) data['signal_strength'] = signalStrength;
    if (offlineSequence != null) data['offline_sequence'] = offlineSequence;
    return data;
  }
}

/// Location Ping Response Model
class LocationPingResponse extends BaseModel {
  final String id;
  final String alertId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime recordedAt;
  final DateTime receivedAt;

  const LocationPingResponse({
    required this.id,
    required this.alertId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.recordedAt,
    required this.receivedAt,
  });

  factory LocationPingResponse.fromJson(Map<String, dynamic> json) {
    return LocationPingResponse(
      id: json['id'] as String,
      alertId: json['alert_id'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      accuracy: json['accuracy'] as double?,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      receivedAt: DateTime.parse(json['received_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alert_id': alertId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'recorded_at': recordedAt.toIso8601String(),
      'received_at': receivedAt.toIso8601String(),
    };
  }
}

/// SOS Status Update Request
class SOSStatusUpdate extends BaseModel {
  final String status;
  final String? resolutionNotes;

  const SOSStatusUpdate({required this.status, this.resolutionNotes});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'status': status};
    if (resolutionNotes != null) data['resolution_notes'] = resolutionNotes;
    return data;
  }
}
