/// Base Model Interface
///
/// Defines contract for all data models to ensure
/// consistent JSON serialization/deserialization.
abstract class BaseModel {
  /// Const constructor to allow subclasses to be const
  const BaseModel();

  /// Converts model to JSON map
  Map<String, dynamic> toJson();
}

/// JSON Serializable Mixin
///
/// Provides helper methods for JSON parsing
mixin JsonSerializableMixin {
  /// Safely extracts String from JSON
  String? stringFromJson(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    return value.toString();
  }

  /// Safely extracts int from JSON
  int? intFromJson(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Safely extracts DateTime from JSON (handles ISO8601)
  DateTime? dateTimeFromJson(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Safely extracts List<T> from JSON
  List<T>? listFromJson<T>(
    Map<String, dynamic> json,
    String key,
    T Function(dynamic) parser,
  ) {
    final value = json[key];
    if (value == null) return null;
    if (value is! List) return null;
    return value.map(parser).whereType<T>().toList();
  }
}
