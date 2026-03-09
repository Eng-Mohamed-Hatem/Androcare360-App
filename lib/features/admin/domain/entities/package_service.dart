/// Represents a service in a patient package.
/// يمثل خدمة في حزمة مريض.
///
/// This entity defines a specific service that can be included in a patient package,
/// with details such as name, description, price, and duration.
/// هذا الكيان يحدد خدمة محددة يمكن أن تدرج في حزمة مريض، مع التفاصيل مثل الاسم، الوصف، السعر، والمدة.
///
/// **Example:**
/// ```dart
/// final service = PackageService(
///   id: 'service_001',
///   serviceName: 'General Consultation',
///   description: '30-minute consultation with a general physician',
///   price: 50.0,
///   durationMinutes: 30,
/// );
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_service.freezed.dart';
part 'package_service.g.dart';

@freezed
abstract class PackageService with _$PackageService {
  /// Creates a new PackageService instance.
  /// ينشئ مثيلاً جديدًا لـ PackageService.
  ///
  /// Parameters:
  /// - [id]: Unique identifier for the service
  /// - [serviceName]: Name of the service (Arabic and English recommended)
  /// - [description]: Detailed description of the service
  /// - [price]: Price of the service in the package's currency
  /// - [durationMinutes]: Duration of the service in minutes
  const factory PackageService({
    required String id,
    required String serviceName,
    required String description,
    required double price,
    required int durationMinutes,
  }) = _PackageService;
  const PackageService._();

  /// Creates a PackageService from JSON map.
  /// ينشئ PackageService من خريطة JSON.
  factory PackageService.fromJson(Map<String, dynamic> json) =>
      _$PackageServiceFromJson(json);

  /// Formats the price to currency string.
  /// تنسيق السعر كسلسلة عملة.
  ///
  /// **Example:**
  /// ```dart
  /// print(service.formatPrice());
  /// // Output: "50.00 EGP"
  /// ```
  String formatPrice() {
    return '${price.toStringAsFixed(2)} EGP';
  }

  /// Formats the duration to human-readable string.
  /// تنسيق المدة كسلسلة قابلة للقراءة.
  ///
  /// **Example:**
  /// ```dart
  /// print(service.formatDuration());
  /// // Output: "30 minutes"
  /// ```
  String formatDuration() {
    if (durationMinutes < 60) {
      return '$durationMinutes minutes';
    } else {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      if (minutes == 0) {
        return '$hours hour${hours > 1 ? 's' : ''}';
      } else {
        return '$hours hour${hours > 1 ? 's' : ''} $minutes minute${minutes > 1 ? 's' : ''}';
      }
    }
  }
}
