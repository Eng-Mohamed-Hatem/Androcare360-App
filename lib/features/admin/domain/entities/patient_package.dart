import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/features/admin/domain/entities/package_document.dart';
import 'package:elajtech/features/admin/domain/entities/package_service.dart';
import 'package:elajtech/features/admin/domain/entities/package_service_usage.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_package.freezed.dart';
part 'patient_package.g.dart';

@freezed
abstract class PatientPackage with _$PatientPackage {
  /// Creates a new PatientPackage instance.
  /// ينشئ مثيلاً جديدًا لـ PatientPackage.
  ///
  /// Parameters:
  /// - [id]: Unique identifier for the package
  /// - [patientId]: ID of the patient who owns this package
  /// - [packageType]: Type of the package (e.g., 'nutrition', 'physiotherapy')
  /// - [services]: List of available services in this package
  /// - [servicesUsage]: List of services that have been used
  /// - [usedServicesCount]: Number of services that have been used
  /// - [notes]: Optional notes about this package (admin/doctor only, hidden from patient)
  /// - [documents]: List of documents uploaded to this package
  /// - [createdAt]: Timestamp when the package was created
  /// - [updatedAt]: Timestamp when the package was last updated
  /// - [isActive]: Whether the package is active and usable
  const factory PatientPackage({
    required String id,
    required String patientId,
    required String packageType,
    required List<PackageService> services,
    required List<PackageServiceUsage> servicesUsage,
    required int usedServicesCount,
    required List<PackageDocument> documents,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isActive,
    String? notes,
  }) = _PatientPackage;
  const PatientPackage._();

  /// Creates a PatientPackage from JSON map.
  /// ينشئ PatientPackage من خريطة JSON.
  factory PatientPackage.fromJson(Map<String, dynamic> json) =>
      _$PatientPackageFromJson(json);

  /// Creates a PatientPackage from Firestore document snapshot.
  /// ينشئ PatientPackage من لقطة مستند Firestore.
  ///
  /// **Critical:**
  /// - Must validate snapshot.exists before calling
  /// - Must validate snapshot.data() != null before calling
  /// - Must handle exceptions with try-catch
  ///
  /// **Example:**
  /// ```dart
  /// factory PatientPackage.fromFirestore(DocumentSnapshot snapshot) {
  ///   if (!snapshot.exists || snapshot.data() == null) {
  ///     throw Exception('Document does not exist or has no data');
  ///   }
  ///   try {
  ///     final data = snapshot.data() as Map<String, dynamic>;
  ///     return PatientPackage.fromJson(data);
  ///   } catch (e, stackTrace) {
  ///     debugPrint('Error parsing PatientPackage: $e');
  ///     debugPrint('StackTrace: $stackTrace');
  ///     rethrow;
  ///   }
  /// }
  /// ```
  factory PatientPackage.fromFirestore(DocumentSnapshot snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      throw Exception('Document does not exist or has no data');
    }

    try {
      final data = snapshot.data()! as Map<String, dynamic>;
      return PatientPackage.fromJson(data);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error parsing PatientPackage from Firestore: $e');
        debugPrint('StackTrace: $stackTrace');
      }
      rethrow;
    }
  }
}
