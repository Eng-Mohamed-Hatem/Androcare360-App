/// PackageEntity — كيان باقة العيادة
///
/// يمثل هذا الكيان تعريف باقة طبية تابعة لعيادة متخصصة، كما هي مخزنة في
/// `clinics/{clinicId}/packages/{packageId}` في Firestore.
///
/// **English**: Domain entity for a clinic package definition. Pure Dart — no
/// Firebase or Flutter imports. Immutable. All display text (name, descriptions,
/// service names) is stored in Arabic per data-model.md §3.1.
///
/// **Spec**: data-model.md §3.1, spec.md §7.9, §8.1.
library;

import 'package:meta/meta.dart';

import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PackageStatus enum
// ─────────────────────────────────────────────────────────────────────────────

/// Lifecycle status of a clinic package definition.
///
/// **Arabic** حالة دورة حياة تعريف الباقة.
enum PackageStatus {
  /// Visible and purchasable by patients — مرئية وقابلة للشراء.
  active('ACTIVE'),

  /// Paused — not purchasable, hidden from patients — موقوفة.
  inactive('INACTIVE'),

  /// Hidden from patient UI but retained in records — مخفية عن المريض.
  hidden('HIDDEN')
  ;

  const PackageStatus(this.value);

  /// Firestore-stored string value.
  final String value;

  /// Parses a Firestore string into a [PackageStatus].
  ///
  /// تحويل نص Firestore إلى [PackageStatus].
  static PackageStatus fromString(String raw) {
    return PackageStatus.values.firstWhere(
      (s) => s.value == raw.toUpperCase(),
      orElse: () => PackageStatus.inactive,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PackageType enum
// ─────────────────────────────────────────────────────────────────────────────

/// Authoritative source-of-truth for package modality (R — CHK014, CHK067).
///
/// `includesVideoConsultation` and `includesPhysicalVisit` in models are
/// **derived** from this field and must never be written independently.
///
/// **Arabic** الحقل الأساسي لنوع الباقة. الحقلان المشتقان لا يُكتبان باستقلالية.
enum PackageType {
  /// Video consultations only — استشارات فيديو فقط
  videoOnly('VIDEO_ONLY'),

  /// Physical clinic visits only — زيارات حضورية فقط
  physicalOnly('PHYSICAL_ONLY'),

  /// Both video and physical — فيديو وحضوري
  both('BOTH'),

  /// Lab tests and imaging only — تحاليل وأشعة فقط
  investigationsOnly('INVESTIGATIONS_ONLY')
  ;

  const PackageType(this.value);

  /// Firestore-stored string value.
  final String value;

  /// Whether this type includes video consultations.
  ///
  /// هل تشمل هذا النوع استشارات الفيديو؟
  bool get includesVideo => this == videoOnly || this == both;

  /// Whether this type includes physical clinic visits.
  ///
  /// هل تشمل هذا النوع الزيارات الحضورية؟
  bool get includesPhysical => this == physicalOnly || this == both;

  /// Parses a Firestore string into a [PackageType].
  ///
  /// تحويل نص Firestore إلى [PackageType].
  static PackageType fromString(String raw) {
    return PackageType.values.firstWhere(
      (t) => t.value == raw.toUpperCase(),
      orElse: () => PackageType.investigationsOnly,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PackageCategory enum
// ─────────────────────────────────────────────────────────────────────────────

/// Patient-facing category of a clinic package.
///
/// Maps to the `category` field in Firestore. Arabic UI labels are defined here
/// for consistent use across all layers.
///
/// **Arabic** فئة الباقة من منظور المريض — يحتوي على التسميات العربية للواجهة.
enum PackageCategory {
  /// Andrology, infertility & prostate — الذكورة والعقم والبروستاتا
  andrologyInfertilityProstate(
    'ANDROLOGY_INFERTILITY_PROSTATE',
    'باقات الذكورة والعقم والبروستاتا',
  ),

  /// Physiotherapy & rehabilitation — العلاج الطبيعي والتأهيل
  physiotherapyRehabilitation(
    'PHYSIOTHERAPY_REHABILITATION',
    'باقات العلاج الطبيعي والتأهيل',
  ),

  /// Internal & family medicine — الباطنة وطب الأسرة
  internalFamilyMedicine(
    'INTERNAL_FAMILY_MEDICINE',
    'باقات الباطنة وطب الأسرة',
  ),

  /// Obesity & therapeutic nutrition — السمنة والتغذية العلاجية
  obesityTherapeuticNutrition(
    'OBESITY_THERAPEUTIC_NUTRITION',
    'باقات السمنة والتغذية العلاجية',
  ),

  /// Chronic diseases — الأمراض المزمنة
  chronicDiseases(
    'CHRONIC_DISEASES',
    'باقات الأمراض المزمنة',
  )
  ;

  const PackageCategory(this.value, this.arabicLabel);

  /// Firestore-stored string value.
  final String value;

  /// Arabic UI label shown to patients — التسمية العربية للمريض.
  final String arabicLabel;

  /// Parses a Firestore string into a [PackageCategory].
  ///
  /// تحويل نص Firestore إلى [PackageCategory].
  static PackageCategory fromString(String raw) {
    return PackageCategory.values.firstWhere(
      (c) => c.value == raw.toUpperCase(),
      orElse: () => PackageCategory.chronicDiseases,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PackageEntity
// ─────────────────────────────────────────────────────────────────────────────

/// Domain entity representing a clinic package definition.
///
/// **English**
/// Immutable pure-Dart class. Every field maps 1-to-1 to data-model.md §3.1.
/// `includesVideoConsultation` and `includesPhysicalVisit` are stored only
/// for legacy querying; they are always **derived** from [packageType] on
/// every Create/Update write (never written independently — CHK014, CHK067).
///
/// **Arabic**
/// كيان مجال بسيط وثابت يمثل تعريف باقة العيادة. لا يحتوي على أي اعتمادية على
/// Flutter أو Firebase. حقلا `includesVideoConsultation` و`includesPhysicalVisit`
/// مشتقان من [packageType] دائمًا.
///
/// **Usage / الاستخدام**:
/// ```dart
/// final entity = PackageEntity(
///   id: 'pkg_001',
///   clinicId: ClinicIds.andrology,
///   category: PackageCategory.andrologyInfertilityProstate,
///   name: 'باقة الخصوبة الأساسية',
///   // ...
/// );
/// ```
@immutable
class PackageEntity {
  /// Creates a [PackageEntity].
  ///
  /// [includesVideoConsultation] and [includesPhysicalVisit] should always
  /// be derived from [packageType] — use the named constructor [PackageEntity.fromType]
  /// to guarantee derivation.
  const PackageEntity({
    required this.id,
    required this.clinicId,
    required this.category,
    required this.name,
    required this.shortDescription,
    required this.services,
    required this.validityDays,
    required this.price,
    required this.currency,
    required this.packageType,
    required this.status,
    required this.displayOrder,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
    required this.includesVideoConsultation,
    required this.includesPhysicalVisit,
    this.description,
    this.termsAndConditions,
    this.discountPercentage,
  });

  /// Factory constructor that derives [includesVideoConsultation] and
  /// [includesPhysicalVisit] from [type], ensuring they are never inconsistent.
  ///
  /// المُنشئ المفضَّل — يشتق الحقلَيْن تلقائيًا من [type].
  factory PackageEntity.fromType({
    required String id,
    required String clinicId,
    required PackageCategory category,
    required String name,
    required String shortDescription,
    required List<PackageServiceItem> services,
    required int validityDays,
    required double price,
    required String currency,
    required PackageType type,
    required PackageStatus status,
    required int displayOrder,
    required bool isFeatured,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? description,
    String? termsAndConditions,
    double? discountPercentage,
  }) {
    return PackageEntity(
      id: id,
      clinicId: clinicId,
      category: category,
      name: name,
      shortDescription: shortDescription,
      services: services,
      validityDays: validityDays,
      price: price,
      currency: currency,
      packageType: type,
      status: status,
      displayOrder: displayOrder,
      isFeatured: isFeatured,
      createdAt: createdAt,
      updatedAt: updatedAt,
      description: description,
      termsAndConditions: termsAndConditions,
      discountPercentage: discountPercentage,
      includesVideoConsultation: type.includesVideo,
      includesPhysicalVisit: type.includesPhysical,
    );
  }

  // ── Identity ───────────────────────────────────────────────────────────────

  /// Document ID — معرف المستند.
  final String id;

  /// Owning clinic ID (e.g. `ClinicIds.andrology`) — معرف العيادة المالكة.
  final String clinicId;

  // ── Classification ─────────────────────────────────────────────────────────

  /// Patient-facing category — فئة الباقة.
  final PackageCategory category;

  /// Package type — نوع الباقة (مصدر الحقيقة / authoritative).
  final PackageType packageType;

  /// Derived: true if [packageType] is VIDEO_ONLY or BOTH.
  /// مشتق من [packageType] — صحيح إذا الباقة تشمل استشارات الفيديو.
  final bool includesVideoConsultation;

  /// Derived: true if [packageType] is PHYSICAL_ONLY or BOTH.
  /// مشتق من [packageType] — صحيح إذا الباقة تشمل الزيارات الحضورية.
  final bool includesPhysicalVisit;

  // ── Content ────────────────────────────────────────────────────────────────

  /// Package name in Arabic — اسم الباقة بالعربية.
  final String name;

  /// Short marketing description in Arabic — وصف مختصر بالعربية.
  final String shortDescription;

  /// Long detailed description in Arabic — وصف تفصيلي بالعربية (اختياري).
  final String? description;

  /// Terms and conditions in Arabic — الشروط والأحكام (اختياري).
  final String? termsAndConditions;

  /// List of services included — قائمة الخدمات المشمولة.
  final List<PackageServiceItem> services;

  // ── Pricing ────────────────────────────────────────────────────────────────

  /// Total price — السعر الإجمالي.
  final double price;

  /// Currency code (e.g. EGP) — رمز العملة.
  final String currency;

  /// Optional discount percentage — نسبة الخصم (اختيارية).
  final double? discountPercentage;

  // ── Validity ───────────────────────────────────────────────────────────────

  /// Package validity in days — مدة الصلاحية بعد الشراء بالأيام.
  final int validityDays;

  // ── Presentation ───────────────────────────────────────────────────────────

  /// Lifecycle status — حالة الباقة.
  final PackageStatus status;

  /// Display sort order — ترتيب العرض.
  final int displayOrder;

  /// Whether this package should be highlighted — هل تُبرز هذه الباقة؟
  final bool isFeatured;

  // ── Audit ──────────────────────────────────────────────────────────────────

  /// Creation timestamp — تاريخ الإنشاء.
  final DateTime createdAt;

  /// Last update timestamp — تاريخ آخر تعديل.
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PackageEntity && other.id == id && other.clinicId == clinicId);

  @override
  int get hashCode => Object.hash(id, clinicId);

  @override
  String toString() =>
      'PackageEntity(id: $id, clinicId: $clinicId, name: $name, '
      'status: ${status.value})';
}
