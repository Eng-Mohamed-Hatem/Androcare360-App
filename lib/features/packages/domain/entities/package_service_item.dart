/// Package Service Items — كيانات عناصر خدمات الباقة
///
/// يحتوي هذا الملف على كيانَيْن بسيطَيْن غير قابلَيْن للتعديل:
/// - [PackageServiceItem]: يمثل خدمة واحدة داخل تعريف الباقة.
/// - [ServiceUsageItem]: يمثل تتبُّع استخدام خدمة من قِبَل مريض.
///
/// كلاهما يُستخدَم كحقل مضمَّن (embedded array) داخل
/// [PackageEntity] و[PatientPackageEntity] على التوالي.
///
/// **Spec**: data-model.md §3.1 (`services`), §4.1 (`servicesUsage`).
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart' show PackageEntity;
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart' show PatientPackageEntity;

// ─────────────────────────────────────────────────────────────────────────────
// Package Service Item
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a single service inside a clinic package definition.
///
/// **English**
/// Immutable value object. Stored as elements of `PackageEntity.services`.
/// The [serviceType] determines which icon is shown in the UI.
/// The [quantity] indicates how many times this service is included in the
/// package (e.g. 5 physiotherapy sessions).
///
/// **Arabic**
/// كائن ثابت يمثل خدمةً واحدة داخل تعريف الباقة السريرية.
/// يُستخدَم [serviceType] لاختيار أيقونة الخدمة في الواجهة.
/// يُحدد [quantity] عدد المرات المسموح بها من هذه الخدمة.
///
/// **Example / مثال**:
/// ```dart
/// const item = PackageServiceItem(
///   serviceId: 'semen_analysis',
///   serviceType: ServiceType.lab,
///   displayName: 'تحليل السائل المنوي',
///   quantity: 1,
/// );
/// ```
class PackageServiceItem {
  /// Creates a [PackageServiceItem].
  ///
  /// [quantity] defaults to 1 if not provided.
  const PackageServiceItem({
    required this.serviceId,
    required this.serviceType,
    required this.displayName,
    this.quantity = 1,
  });

  /// Constructs a [PackageServiceItem] from a Firestore map.
  ///
  /// إنشاء الكائن من خريطة Firestore.
  factory PackageServiceItem.fromMap(Map<String, dynamic> map) {
    return PackageServiceItem(
      serviceId: map['serviceId'] as String? ?? '',
      serviceType: ServiceType.fromString(map['serviceType'] as String? ?? ''),
      displayName: map['displayName'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  /// Internal service identifier — لا يظهر للمريض مباشرةً.
  final String serviceId;

  /// Service category used for icon selection — نوع الخدمة للأيقونة.
  final ServiceType serviceType;

  /// Arabic display name shown to patients and doctors — الاسم العربي للمريض.
  final String displayName;

  /// Number of times this service is included in the package — عدد حصص الخدمة.
  final int quantity;

  /// Converts this item to a Firestore-compatible map.
  ///
  /// تحويل الكائن إلى خريطة قابلة للحفظ في Firestore.
  Map<String, dynamic> toMap() => {
    'serviceId': serviceId,
    'serviceType': serviceType.value,
    'displayName': displayName,
    'quantity': quantity,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PackageServiceItem && other.serviceId == serviceId);

  @override
  int get hashCode => serviceId.hashCode;

  @override
  String toString() =>
      'PackageServiceItem(serviceId: $serviceId, type: ${serviceType.value}, '
      'displayName: $displayName, qty: $quantity)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Service Usage Item
// ─────────────────────────────────────────────────────────────────────────────

/// Tracks actual usage of a single service within a patient package purchase.
///
/// **English**
/// Each element of [PatientPackageEntity.servicesUsage] is a [ServiceUsageItem].
/// Compare [usedCount] against [PackageServiceItem.quantity] to compute
/// remaining uses. All writes to this object must use Firestore Transactions
/// (R3 — atomicity requirement).
///
/// **Arabic**
/// كل عنصر في حقل `servicesUsage` في علامة الشراء يكون من هذا النوع.
/// قارِن [usedCount] بـ `PackageServiceItem.quantity` لحساب المتبقي.
/// ⚠️ يجب أن تتم جميع الكتابات داخل Firestore Transaction (R3).
class ServiceUsageItem {
  /// Creates a [ServiceUsageItem].
  const ServiceUsageItem({
    required this.serviceId,
    required this.usedCount,
    this.lastUsedAt,
  });

  /// Constructs a [ServiceUsageItem] from a Firestore map.
  ///
  /// إنشاء الكائن من خريطة Firestore.
  factory ServiceUsageItem.fromMap(Map<String, dynamic> map) {
    final lastUsedRaw = map['lastUsedAt'];
    return ServiceUsageItem(
      serviceId: map['serviceId'] as String? ?? '',
      usedCount: (map['usedCount'] as num?)?.toInt() ?? 0,
      lastUsedAt: lastUsedRaw is Timestamp ? lastUsedRaw.toDate() : null,
    );
  }

  /// Matches [PackageServiceItem.serviceId] — معرف الخدمة المرتبطة.
  final String serviceId;

  /// Number of times this service has actually been used — عدد مرات الاستخدام الفعلي.
  final int usedCount;

  /// Timestamp of the last usage — وقت آخر استخدام (اختياري).
  final DateTime? lastUsedAt;

  /// Converts this item to a Firestore-compatible map.
  ///
  /// تحويل الكائن إلى خريطة قابلة للحفظ في Firestore.
  Map<String, dynamic> toMap() => {
    'serviceId': serviceId,
    'usedCount': usedCount,
    if (lastUsedAt != null) 'lastUsedAt': Timestamp.fromDate(lastUsedAt!),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceUsageItem && other.serviceId == serviceId);

  @override
  int get hashCode => serviceId.hashCode;

  @override
  String toString() =>
      'ServiceUsageItem(serviceId: $serviceId, used: $usedCount)';
}

// ─────────────────────────────────────────────────────────────────────────────
// ServiceType enum
// ─────────────────────────────────────────────────────────────────────────────

/// Enum representing the category or modality of a package service.
///
/// **English** Used to drive icon selection and filtering in UI.
/// **Arabic** يُستخدَم لاختيار الأيقونة والفلترة في الواجهة.
enum ServiceType {
  /// Laboratory test — تحليل معملي
  lab('LAB'),

  /// Imaging / radiology — أشعة
  imaging('IMAGING'),

  /// Physical clinic visit — زيارة حضورية
  visit('VISIT'),

  /// Therapy session — جلسة علاجية
  session('SESSION'),

  /// Any other service type — أخرى
  other('OTHER')
  ;

  const ServiceType(this.value);

  /// The Firestore-stored string representation.
  final String value;

  /// Parses a Firestore string into a [ServiceType].
  ///
  /// تحويل نص Firestore إلى [ServiceType].
  /// Returns [other] as a safe fallback for unknown values.
  static ServiceType fromString(String raw) {
    return ServiceType.values.firstWhere(
      (t) => t.value == raw.toUpperCase(),
      orElse: () => ServiceType.other,
    );
  }
}
