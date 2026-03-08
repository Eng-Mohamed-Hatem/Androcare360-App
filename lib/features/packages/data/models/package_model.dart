/// PackageModel — نموذج بيانات باقة العيادة (Data Layer)
///
/// يمتد هذا النموذج من [PackageEntity] ويضيف منطق تحويل Firestore.
///
/// **English**: Data-layer model extending [PackageEntity]. Adds
/// `fromFirestore(snapshot)` with strict safety checks (snapshot.exists,
/// data != null, try-catch + debugPrint(stackTrace)) and `toFirestore()`.
/// `includesVideoConsultation` and `includesPhysicalVisit` are always
/// recomputed from `packageType` on write — never stored independently.
///
/// **Spec**: data-model.md §3.1, important-rules.md (Firestore Data Mapping
/// Safety), tasks.md T013.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart' show PackageNotFoundFailure;
import 'package:flutter/foundation.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';

/// Data model for a clinic package definition.
///
/// **English**
/// Extends [PackageEntity] with Firestore serialization. The [fromFirestore]
/// factory performs the mandatory safety checks:
/// 1. `snapshot.exists` guard
/// 2. `snapshot.data() != null` guard
/// 3. `try-catch` with `debugPrint(stackTrace.toString())`
///
/// **Arabic**
/// نموذج بيانات يمتد من [PackageEntity]. يُطبِّق فحوصات الأمان الإلزامية
/// في `fromFirestore` ويُعيد قيمة افتراضية آمنة عند الخطأ.
class PackageModel extends PackageEntity {
  /// Creates a [PackageModel] by delegating to [PackageEntity].
  const PackageModel({
    required super.id,
    required super.clinicId,
    required super.category,
    required super.name,
    required super.shortDescription,
    required super.services,
    required super.validityDays,
    required super.price,
    required super.currency,
    required super.packageType,
    required super.status,
    required super.displayOrder,
    required super.isFeatured,
    required super.createdAt,
    required super.updatedAt,
    required super.includesVideoConsultation,
    required super.includesPhysicalVisit,
    super.description,
    super.termsAndConditions,
    super.discountPercentage,
  });

  /// Creates a [PackageModel] from a Firestore [DocumentSnapshot].
  ///
  /// **English**: Performs existence and null safety checks before parsing.
  /// Returns `null` on guard failures or parse errors — callers should map
  /// `null` to [PackageNotFoundFailure].
  ///
  /// **Arabic**: يُطبِّق فحص `exists` و`data != null` قبل التحليل.
  /// يُعيد `null` عند الفشل — المُستدعي يُحوِّله إلى [PackageNotFoundFailure].
  static PackageModel? fromFirestore(DocumentSnapshot snapshot) {
    // ── Guard 1: document must exist ─────────────────────────────────────────
    if (!snapshot.exists) {
      if (kDebugMode) {
        debugPrint(
          '[PackageModel.fromFirestore] Document does not exist: ${snapshot.id}',
        );
      }
      return null;
    }

    // ── Guard 2: data must be non-null ────────────────────────────────────────
    final data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) {
      if (kDebugMode) {
        debugPrint(
          '[PackageModel.fromFirestore] data() is null for id: ${snapshot.id}',
        );
      }
      return null;
    }

    // ── Guard 3: parse inside try-catch ───────────────────────────────────────
    try {
      final packageType = PackageType.fromString(
        data['packageType'] as String? ?? '',
      );

      final servicesRaw = data['services'] as List<dynamic>? ?? [];

      return PackageModel(
        id: snapshot.id,
        clinicId: data['clinicId'] as String? ?? '',
        category: PackageCategory.fromString(
          data['category'] as String? ?? '',
        ),
        name: data['name'] as String? ?? '',
        shortDescription: data['shortDescription'] as String? ?? '',
        description: data['description'] as String?,
        termsAndConditions: data['termsAndConditions'] as String?,
        services: servicesRaw
            .map((e) => PackageServiceItem.fromMap(e as Map<String, dynamic>))
            .toList(),
        validityDays: (data['validityDays'] as num?)?.toInt() ?? 0,
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
        currency: data['currency'] as String? ?? 'EGP',
        discountPercentage: (data['discountPercentage'] as num?)?.toDouble(),
        packageType: packageType,
        // ⬇ Derived from packageType — never read from Firestore independently
        includesVideoConsultation: packageType.includesVideo,
        includesPhysicalVisit: packageType.includesPhysical,
        status: PackageStatus.fromString(data['status'] as String? ?? ''),
        displayOrder: (data['displayOrder'] as num?)?.toInt() ?? 0,
        isFeatured: data['isFeatured'] as bool? ?? false,
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt:
            (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          '[PackageModel.fromFirestore] Parse error for ${snapshot.id}: $e',
        );
        debugPrint(st.toString());
      }
      return null;
    }
  }

  /// Converts this model to a Firestore-compatible map.
  ///
  /// **Note**: `includesVideoConsultation` and `includesPhysicalVisit` are
  /// always recomputed from [packageType] here — never trusted from a field.
  ///
  /// **ملاحظة**: الحقلان المشتقان يُعاد حسابهما دائمًا من [packageType].
  Map<String, dynamic> toFirestore() => {
    'id': id,
    'clinicId': clinicId,
    'category': category.value,
    'name': name,
    'shortDescription': shortDescription,
    if (description != null) 'description': description,
    if (termsAndConditions != null) 'termsAndConditions': termsAndConditions,
    'services': services.map((s) => s.toMap()).toList(),
    'validityDays': validityDays,
    'price': price,
    'currency': currency,
    if (discountPercentage != null) 'discountPercentage': discountPercentage,
    'packageType': packageType.value,
    // Derived — recomputed on every write (CHK014, CHK067)
    'includesVideoConsultation': packageType.includesVideo,
    'includesPhysicalVisit': packageType.includesPhysical,
    'status': status.value,
    'displayOrder': displayOrder,
    'isFeatured': isFeatured,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
