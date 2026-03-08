/// PatientPackageModel — نموذج بيانات مشتريات باقات المريض (Data Layer)
///
/// يمتد من [PatientPackageEntity] ويضيف منطق تحويل Firestore مع تطبيق R2.
///
/// **English**: Data-layer model extending [PatientPackageEntity]. Provides
/// two factory constructors enforcing R2 (notes isolation):
/// - [fromFirestoreForPatient]: always sets notes = null.
/// - [fromFirestoreForAdmin]: maps notes normally.
///
/// **Spec**: data-model.md §4.1, important-rules.md R2, tasks.md T014.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';

/// Data model for a patient package purchase record.
///
/// **English**
/// Two Firestore factories enforce R2 at the model level:
/// - [fromFirestoreForPatient]: strips `notes` unconditionally.
/// - [fromFirestoreForAdmin]: includes `notes`.
/// Both apply the mandatory 3-guard safety pattern.
///
/// **Arabic**
/// مُنشئان يُطبِّقان R2 على مستوى النموذج:
/// - [fromFirestoreForPatient]: يُزيل `notes` دائمًا.
/// - [fromFirestoreForAdmin]: يُضمِّن `notes`.
/// كلاهما يُطبِّق نمط الثلاثة فحوصات.
class PatientPackageModel extends PatientPackageEntity {
  /// Creates a [PatientPackageModel].
  const PatientPackageModel({
    required super.id,
    required super.patientId,
    required super.packageId,
    required super.clinicId,
    required super.category,
    required super.status,
    required super.purchaseDate,
    required super.expiryDate,
    required super.totalServicesCount,
    required super.usedServicesCount,
    required super.createdAt,
    required super.updatedAt,
    super.servicesUsage,
    super.paymentTransactionId,
    super.notes,
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Private core parser
  // ─────────────────────────────────────────────────────────────────────────

  static PatientPackageModel? _parse(
    DocumentSnapshot snapshot, {
    required bool includeNotes,
  }) {
    if (!snapshot.exists) {
      if (kDebugMode) {
        debugPrint(
          '[PatientPackageModel] Document does not exist: ${snapshot.id}',
        );
      }
      return null;
    }

    final data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) {
      if (kDebugMode) {
        debugPrint(
          '[PatientPackageModel] data() is null for id: ${snapshot.id}',
        );
      }
      return null;
    }

    try {
      final usageRaw = data['servicesUsage'] as List<dynamic>? ?? [];

      return PatientPackageModel(
        id: snapshot.id,
        patientId: data['patientId'] as String? ?? '',
        packageId: data['packageId'] as String? ?? '',
        clinicId: data['clinicId'] as String? ?? '',
        category: PackageCategory.fromString(
          data['category'] as String? ?? '',
        ),
        status: PatientPackageStatus.fromString(
          data['status'] as String? ?? '',
        ),
        purchaseDate:
            (data['purchaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        expiryDate:
            (data['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        totalServicesCount: (data['totalServicesCount'] as num?)?.toInt() ?? 0,
        usedServicesCount: (data['usedServicesCount'] as num?)?.toInt() ?? 0,
        servicesUsage: usageRaw
            .map(
              (e) => ServiceUsageItem.fromMap(e as Map<String, dynamic>),
            )
            .toList(),
        paymentTransactionId: data['paymentTransactionId'] as String?,
        // R2: only include notes when explicitly requested (admin view)
        notes: includeNotes ? data['notes'] as String? : null,
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt:
            (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          '[PatientPackageModel] Parse error for ${snapshot.id}: $e',
        );
        debugPrint(st.toString());
      }
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Public factories — R2 enforcement
  // ─────────────────────────────────────────────────────────────────────────

  /// Creates a patient-facing model — notes is ALWAYS null (R2).
  ///
  /// **Arabic**: مُنشئ المريض — حقل `notes` دائمًا null بغض النظر عما
  /// يحتويه مستند Firestore. يُستخدَم في شاشات المريض فقط.
  static PatientPackageModel? fromFirestoreForPatient(
    DocumentSnapshot snapshot,
  ) => _parse(snapshot, includeNotes: false);

  /// Creates an admin-facing model — notes IS mapped (R2).
  ///
  /// **Arabic**: مُنشئ الأدمن — حقل `notes` مُضمَّن. يُستخدَم في شاشات
  /// الأدمن/الطبيب فقط.
  static PatientPackageModel? fromFirestoreForAdmin(
    DocumentSnapshot snapshot,
  ) => _parse(snapshot, includeNotes: true);

  // ─────────────────────────────────────────────────────────────────────────
  // toFirestore
  // ─────────────────────────────────────────────────────────────────────────

  /// Converts this model to a Firestore-compatible map for a new document.
  ///
  /// تحويل النموذج إلى خريطة Firestore لإنشاء مستند جديد.
  Map<String, dynamic> toFirestore() => {
    'patientId': patientId,
    'packageId': packageId,
    'clinicId': clinicId,
    'category': category.value,
    'status': status.value,
    'purchaseDate': Timestamp.fromDate(purchaseDate),
    'expiryDate': Timestamp.fromDate(expiryDate),
    'totalServicesCount': totalServicesCount,
    'usedServicesCount': usedServicesCount,
    'servicesUsage': servicesUsage.map((u) => u.toMap()).toList(),
    if (paymentTransactionId != null)
      'paymentTransactionId': paymentTransactionId,
    if (notes != null) 'notes': notes,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
