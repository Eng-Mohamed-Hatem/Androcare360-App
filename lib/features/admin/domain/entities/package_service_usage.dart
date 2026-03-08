/// Tracks usage of a specific service in a patient package.
/// يتبع استخدام خدمة معينة في حزمة مريض.
///
/// This entity records when a service from a patient package is used,
/// including the timestamp and any notes about the usage.
/// هذا الكيان يسجل عندما يتم استخدام خدمة من حزمة مريض، بما في ذلك الطابع الزمني وأي ملاحظات حول الاستخدام.
///
/// **Example:**
/// ```dart
/// final usage = PackageServiceUsage(
///   serviceId: 'service_001',
///   usedAt: DateTime.now(),
///   note: 'First consultation completed',
/// );
/// ```
import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_service_usage.freezed.dart';
part 'package_service_usage.g.dart';

@freezed
abstract class PackageServiceUsage with _$PackageServiceUsage {
  const PackageServiceUsage._();

  /// Creates a new PackageServiceUsage instance.
  /// ينشئ مثيلاً جديدًا لـ PackageServiceUsage.
  ///
  /// Parameters:
  /// - [serviceId]: Unique identifier of the service that was used
  /// - [usedAt]: Timestamp when the service was used
  /// - [note]: Optional note about this usage
  const factory PackageServiceUsage({
    required String serviceId,
    required DateTime usedAt,
    String? note,
  }) = _PackageServiceUsage;

  /// Creates a PackageServiceUsage from JSON map.
  /// ينشئ PackageServiceUsage من خريطة JSON.
  factory PackageServiceUsage.fromJson(Map<String, dynamic> json) =>
      _$PackageServiceUsageFromJson(json);

  /// Formats the usage time to human-readable string.
  /// تنسيق وقت الاستخدام كسلسلة قابلة للقراءة.
  ///
  /// **Example:**
  /// ```dart
  /// print(usage.formatUsedAt());
  /// // Output: "2026-03-08 at 14:30"
  /// ```
  String formatUsedAt() {
    return '${usedAt.year}-${usedAt.month.toString().padLeft(2, '0')}-${usedAt.day.toString().padLeft(2, '0')} at ${usedAt.hour.toString().padLeft(2, '0')}:${usedAt.minute.toString().padLeft(2, '0')}';
  }

  /// Gets the age of this usage entry.
  /// يحصل على عمر هذا إدخال الاستخدام.
  ///
  /// **Example:**
  /// ```dart
  /// final age = usage.getAgeInHours();
  /// print('Used ${age} hours ago');
  /// ```
  Duration getAgeInHours() {
    return DateTime.now().difference(usedAt);
  }

  /// Gets the age of this usage entry in minutes.
  /// يحصل على عمر هذا إدخال الاستخدام بالدقائق.
  ///
  /// **Example:**
  /// ```dart
  /// final ageInMinutes = usage.getAgeInMinutes();
  /// print('Used ${ageInMinutes} minutes ago');
  /// ```
  int getAgeInMinutes() {
    return getAgeInHours().inMinutes;
  }
}
