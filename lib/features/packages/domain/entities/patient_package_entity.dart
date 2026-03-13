/// PatientPackageEntity — كيان مشتريات باقات المريض
///
/// يمثل هذا الكيان عملية شراء باقة من قِبَل مريض، كما هي مخزنة في
/// `patients/{patientId}/packages/{patientPackageId}` في Firestore.
///
/// **English**: Domain entity for a patient's package purchase record.
/// Pure Dart — no Firebase or Flutter imports. Immutable.
///
/// ⚠️ **R2 (Application-layer notes isolation)**: The `notes` field is included
/// in this entity but must be `null` in any result returned to patient-facing
/// screens. Enforcement is at the **repository / model layer**, not Firestore
/// rules. Admin-facing methods populate `notes`; patient-facing methods set it
/// to null unconditionally.
///
/// ⚠️ **R3 (Atomicity)**: All writes to `servicesUsage` and `usedServicesCount`
/// must use Firestore Transactions to prevent lost updates.
///
/// **Spec**: data-model.md §4.1, spec.md §7.4, §7.5, §7.8.
library;

import 'package:meta/meta.dart';

import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/domain/usecases/purchase_package_usecase.dart'
    show PurchasePackageUseCase;

// ─────────────────────────────────────────────────────────────────────────────
// PatientPackageStatus enum
// ─────────────────────────────────────────────────────────────────────────────

/// Lifecycle status of a patient package purchase record.
///
/// **Arabic** حالة سجل شراء الباقة من قِبَل المريض.
enum PatientPackageStatus {
  /// Awaiting activation / payment — في انتظار التفعيل / الدفع.
  pending('PENDING'),

  /// Active — all services available — نشطة.
  active('ACTIVE'),

  /// All services consumed — مكتملة.
  completed('COMPLETED'),

  /// Validity period has elapsed — منتهية الصلاحية.
  expired('EXPIRED')
  ;

  const PatientPackageStatus(this.value);

  /// Firestore-stored string value.
  final String value;

  /// Arabic UI label — التسمية العربية للواجهة.
  String get arabicLabel => switch (this) {
    PatientPackageStatus.pending => 'في انتظار التفعيل',
    PatientPackageStatus.active => 'نشطة',
    PatientPackageStatus.completed => 'مكتملة',
    PatientPackageStatus.expired => 'منتهية الصلاحية',
  };

  /// Parses a Firestore string into a [PatientPackageStatus].
  ///
  /// تحويل نص Firestore إلى [PatientPackageStatus].
  static PatientPackageStatus fromString(String raw) {
    return PatientPackageStatus.values.firstWhere(
      (s) => s.value == raw.toUpperCase(),
      orElse: () => PatientPackageStatus.pending,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PatientPackageEntity
// ─────────────────────────────────────────────────────────────────────────────

/// Domain entity representing a patient's package purchase.
///
/// **English**
/// Immutable pure-Dart class. Fields map 1-to-1 to data-model.md §4.1.
/// [notes] is deliberately nullable so it can be stripped to null for
/// patient-facing API calls without a separate DTO (R2).
/// [paymentTransactionId] is mandatory (non-null) when [status] is
/// [PatientPackageStatus.active] — enforced in [PurchasePackageUseCase].
///
/// **Arabic**
/// كيان ثابت يمثل عملية شراء باقة من قِبَل مريض.
/// حقل [notes] قابل للقيمة الفارغة — يُعاد بـ`null` لشاشات المريض (R2).
/// حقل [paymentTransactionId] إلزامي عند الحالة ACTIVE.
///
/// **Usage / الاستخدام**:
/// ```dart
/// final entity = PatientPackageEntity(
///   id: 'pp_001',
///   patientId: 'uid_123',
///   packageId: 'pkg_001',
///   clinicId: ClinicIds.andrology,
///   status: PatientPackageStatus.active,
///   paymentTransactionId: 'TXN_20260307_0001',
///   // ...
/// );
/// ```
@immutable
class PatientPackageEntity {
  /// Creates a [PatientPackageEntity].
  ///
  /// For patient-facing screens, always use [PatientPackageEntity.forPatient]
  /// to ensure [notes] is stripped.
  const PatientPackageEntity({
    required this.id,
    required this.patientId,
    required this.packageId,
    required this.packageName,
    required this.clinicId,
    required this.category,
    required this.status,
    required this.purchaseDate,
    required this.expiryDate,
    required this.totalServicesCount,
    required this.usedServicesCount,
    required this.createdAt,
    required this.updatedAt,
    this.isTestPurchase = false,
    this.servicesUsage = const [],
    this.packageServices = const [],
    this.paymentTransactionId,
    this.notes,
    this.description = '',
    this.shortDescription = '',
    this.validityDays = 0,
  });

  /// Creates a patient-facing variant where [notes] is always null (R2).
  ///
  /// إنشاء نسخة للمريض حيث حقل [notes] دائمًا null (R2).
  factory PatientPackageEntity.fromFirestoreForPatient({
    required String id,
    required String patientId,
    required String packageId,
    required String packageName,
    required String clinicId,
    required PackageCategory category,
    required PatientPackageStatus status,
    required DateTime purchaseDate,
    required DateTime expiryDate,
    required int totalServicesCount,
    required int usedServicesCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isTestPurchase = false,
    List<ServiceUsageItem> servicesUsage = const [],
    List<PackageServiceItem> packageServices = const [],
    String? paymentTransactionId,
    String description = '',
    String shortDescription = '',
    int validityDays = 0,
  }) {
    return PatientPackageEntity(
      id: id,
      patientId: patientId,
      packageId: packageId,
      packageName: packageName,
      clinicId: clinicId,
      category: category,
      status: status,
      purchaseDate: purchaseDate,
      expiryDate: expiryDate,
      totalServicesCount: totalServicesCount,
      usedServicesCount: usedServicesCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isTestPurchase: isTestPurchase,
      servicesUsage: servicesUsage,
      packageServices: packageServices,
      paymentTransactionId: paymentTransactionId,
      description: description,
      shortDescription: shortDescription,
      validityDays: validityDays,
    );
  }

  // ── Identity ───────────────────────────────────────────────────────────────

  /// Patient-package document ID — معرف مستند الشراء.
  final String id;

  /// Patient UID (denormalized) — معرف المريض.
  final String patientId;

  /// Source clinic package ID — معرف الباقة من `clinics/.../packages`.
  final String packageId;

  /// Owning clinic — معرف العيادة.
  final String clinicId;

  /// The name of the package purchased.
  /// **English**: Normalized name from the original package entity.
  /// **Arabic**: اسم الباقة التي تم شراؤها.
  final String packageName;

  // ── Classification ─────────────────────────────────────────────────────────

  /// Package category (copied from package at purchase time) — الفئة.
  final PackageCategory category;

  /// Current lifecycle status — الحالة الحالية.
  final PatientPackageStatus status;

  // ── Dates ──────────────────────────────────────────────────────────────────

  /// Purchase date — تاريخ الشراء.
  final DateTime purchaseDate;

  /// Expiry date = purchaseDate + validityDays — تاريخ انتهاء الصلاحية.
  final DateTime expiryDate;

  // ── Progress ───────────────────────────────────────────────────────────────

  /// Total services in this package — إجمالي الخدمات.
  final int totalServicesCount;

  /// Consumed services count — الخدمات المستهلكة.
  final int usedServicesCount;

  /// Per-service usage breakdown — تتبع استخدام كل خدمة.
  /// ⚠️ Writes require Firestore Transaction (R3).
  final List<ServiceUsageItem> servicesUsage;

  /// Full list of service definitions included in this package at purchase time.
  /// **English**: Preserves names and max quantities historically.
  /// **Arabic**: قائمة كاملة بتعريفات الخدمات المضمنة في هذه الباقة وقت الشراء.
  final List<PackageServiceItem> packageServices;

  // ── Testing ────────────────────────────────────────────────────────────────

  /// Whether this is a simulated test purchase (stub) — هل هذا شراء تجريبي.
  /// Defaults to `false`.
  final bool isTestPurchase;

  // ── Payment ────────────────────────────────────────────────────────────────

  /// Payment gateway transaction ID — mandatory when status = ACTIVE.
  /// معرف معاملة الدفع — إلزامي عند الحالة ACTIVE.
  final String? paymentTransactionId;

  // ── Admin-only ─────────────────────────────────────────────────────────────

  /// Internal admin/doctor notes — ملاحظات داخلية للأدمن/الطبيب فقط.
  /// ⚠️ R2: Must be null for all patient-facing entity instances.
  final String? notes;

  /// Full package description snapped at purchase time.
  /// **Arabic**: وصف الباقة الكامل كما كان وقت الشراء.
  /// **Usage**: `Text(entity.description)`
  final String description;

  /// Short package summary snapped at purchase time.
  /// **Arabic**: ملخص الباقة القصير كما كان وقت الشراء.
  final String shortDescription;

  /// Number of days this package remains valid from [purchaseDate].
  /// **Arabic**: عدد أيام صلاحية الباقة من تاريخ الشراء.
  final int validityDays;

  // ── Audit ──────────────────────────────────────────────────────────────────

  /// Creation timestamp — تاريخ الإنشاء.
  final DateTime createdAt;

  /// Last update timestamp — تاريخ آخر تعديل.
  final DateTime updatedAt;

  /// Computed progress fraction (0.0 – 1.0).
  ///
  /// نسبة التقدم المحسوبة من 0 إلى 1.
  double get progressFraction =>
      totalServicesCount == 0 ? 0.0 : usedServicesCount / totalServicesCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatientPackageEntity &&
          other.id == id &&
          other.patientId == patientId);

  @override
  int get hashCode => Object.hash(id, patientId);

  @override
  String toString() =>
      'PatientPackageEntity(id: $id, patientId: $patientId, '
      'packageId: $packageId, packageName: $packageName, status: ${status.value})';
}
