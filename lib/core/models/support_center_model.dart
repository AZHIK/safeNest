import 'base_model.dart';

/// Support Center Response Model
/// 
/// Matches FastAPI backend SupportCenterResponse schema
class SupportCenterResponse extends BaseModel {
  final String id;
  final String name;
  final String centerType;
  final String? categoryTags;
  final String address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final double latitude;
  final double longitude;
  final double? distanceKm;
  final String? phonePrimary;
  final String? phoneEmergency;
  final String? email;
  final String? website;
  final bool is247;
  final String? operatingHours;
  final String? languagesSupported;
  final bool providesMedical;
  final bool providesLegal;
  final bool providesShelter;
  final bool providesCounseling;
  final bool providesEmergencyResponse;
  final bool providesAnonymousSupport;
  final bool wheelchairAccessible;
  final String? genderSpecific;
  final bool isVerified;
  final double? ratingAverage;
  final int ratingCount;
  final bool isActive;

  const SupportCenterResponse({
    required this.id,
    required this.name,
    required this.centerType,
    this.categoryTags,
    required this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
    this.phonePrimary,
    this.phoneEmergency,
    this.email,
    this.website,
    required this.is247,
    this.operatingHours,
    this.languagesSupported,
    required this.providesMedical,
    required this.providesLegal,
    required this.providesShelter,
    required this.providesCounseling,
    required this.providesEmergencyResponse,
    required this.providesAnonymousSupport,
    required this.wheelchairAccessible,
    this.genderSpecific,
    required this.isVerified,
    this.ratingAverage,
    required this.ratingCount,
    required this.isActive,
  });

  factory SupportCenterResponse.fromJson(Map<String, dynamic> json) {
    return SupportCenterResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      centerType: json['center_type'] as String,
      categoryTags: json['category_tags'] as String?,
      address: json['address'] as String,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postal_code'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distanceKm: json['distance_km'] != null ? (json['distance_km'] as num).toDouble() : null,
      phonePrimary: json['phone_primary'] as String?,
      phoneEmergency: json['phone_emergency'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      is247: json['is_24_7'] as bool,
      operatingHours: json['operating_hours'] as String?,
      languagesSupported: json['languages_supported'] as String?,
      providesMedical: json['provides_medical'] as bool,
      providesLegal: json['provides_legal'] as bool,
      providesShelter: json['provides_shelter'] as bool,
      providesCounseling: json['provides_counseling'] as bool,
      providesEmergencyResponse: json['provides_emergency_response'] as bool,
      providesAnonymousSupport: json['provides_anonymous_support'] as bool,
      wheelchairAccessible: json['wheelchair_accessible'] as bool,
      genderSpecific: json['gender_specific'] as String?,
      isVerified: json['is_verified'] as bool,
      ratingAverage: json['rating_average'] != null
          ? (json['rating_average'] as num).toDouble()
          : null,
      ratingCount: json['rating_count'] as int,
      isActive: json['is_active'] as bool,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'center_type': centerType,
      'category_tags': categoryTags,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'distance_km': distanceKm,
      'phone_primary': phonePrimary,
      'phone_emergency': phoneEmergency,
      'email': email,
      'website': website,
      'is_24_7': is247,
      'operating_hours': operatingHours,
      'languages_supported': languagesSupported,
      'provides_medical': providesMedical,
      'provides_legal': providesLegal,
      'provides_shelter': providesShelter,
      'provides_counseling': providesCounseling,
      'provides_emergency_response': providesEmergencyResponse,
      'provides_anonymous_support': providesAnonymousSupport,
      'wheelchair_accessible': wheelchairAccessible,
      'gender_specific': genderSpecific,
      'is_verified': isVerified,
      'rating_average': ratingAverage,
      'rating_count': ratingCount,
      'is_active': isActive,
    };
  }
}

/// Support Center Nearby Request
class SupportCenterNearbyRequest extends BaseModel {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final List<String>? centerTypes;
  final bool? is247;
  final bool? providesMedical;
  final bool? providesLegal;
  final bool? providesShelter;

  const SupportCenterNearbyRequest({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 10.0,
    this.centerTypes,
    this.is247,
    this.providesMedical,
    this.providesLegal,
    this.providesShelter,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'latitude': latitude,
      'longitude': longitude,
      'radius_km': radiusKm,
    };
    if (centerTypes != null) data['center_types'] = centerTypes;
    if (is247 != null) data['is_24_7'] = is247;
    if (providesMedical != null) data['provides_medical'] = providesMedical;
    if (providesLegal != null) data['provides_legal'] = providesLegal;
    if (providesShelter != null) data['provides_shelter'] = providesShelter;
    return data;
  }
}
