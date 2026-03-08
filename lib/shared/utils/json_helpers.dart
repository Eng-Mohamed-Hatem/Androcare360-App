/// JSON parsing helper utilities for handling Firestore data types.
///
/// This file provides utility functions for safely parsing JSON data from
/// Firestore, which may contain Firestore-specific types like Timestamp.
///
/// **Usage Example:**
/// ```dart
/// factory MyModel.fromJson(Map<String, dynamic> json) => MyModel(
///   createdAt: JsonHelpers.parseDateTime(json['createdAt']),
///   updatedAt: JsonHelpers.parseDateTimeOrNull(json['updatedAt']),
/// );
/// ```
class JsonHelpers {
  /// Parses a DateTime from various formats.
  ///
  /// Handles:
  /// - Firestore Timestamp objects (via dynamic toDate() call)
  /// - ISO8601 date strings
  /// - DateTime objects (pass-through)
  ///
  /// This ensures compatibility with data from Firestore (which uses Timestamp)
  /// and JSON APIs (which use ISO8601 strings).
  ///
  /// Parameters:
  /// - [value]: The value to parse (can be Timestamp, String, or DateTime)
  ///
  /// Returns a DateTime object.
  ///
  /// Throws [FormatException] if the value cannot be parsed.
  ///
  /// Example:
  /// ```dart
  /// final date = JsonHelpers.parseDateTime(json['createdAt']);
  /// ```
  static DateTime parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value.runtimeType.toString() == 'Timestamp') {
      // Handle Firestore Timestamp without importing cloud_firestore
      // Timestamp has a toDate() method that returns DateTime
      return (value as dynamic).toDate() as DateTime;
    } else {
      throw FormatException(
        'Cannot parse DateTime from type ${value.runtimeType}. '
        'Expected DateTime, String (ISO8601), or Firestore Timestamp.',
      );
    }
  }

  /// Parses a DateTime from various formats, returning null if the value is null.
  ///
  /// This is a null-safe version of [parseDateTime] that returns null
  /// when the input value is null, making it suitable for optional DateTime fields.
  ///
  /// Parameters:
  /// - [value]: The value to parse (can be null, Timestamp, String, or DateTime)
  ///
  /// Returns a DateTime object or null.
  ///
  /// Throws [FormatException] if the value is not null and cannot be parsed.
  ///
  /// Example:
  /// ```dart
  /// final updatedAt = JsonHelpers.parseDateTimeOrNull(json['updatedAt']);
  /// ```
  static DateTime? parseDateTimeOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    return parseDateTime(value);
  }
}
