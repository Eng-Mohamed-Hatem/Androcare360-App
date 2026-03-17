/// Clinic IDs Constants — ثوابت معرفات العيادات
///
/// This file records the authoritative `clinicId` values that will be used as
/// Firestore document IDs under `clinics/{clinicId}` in the `elajtech` database.
///
/// ⚠️ **T005 STATUS — VERIFIED ✅ (2026-03-07)**: The `clinics` collection was
/// created in the `elajtech` Firestore database with all 5 documents confirmed:
/// `andrology`, `physiotherapy`, `internal_family`, `nutrition`,
/// `chronic_diseases`. IDs match the constants below exactly.
///
/// **Required pre-release action**:
/// Open Firebase Console → Firestore → elajtech database → "Start collection"
/// and create the `clinics` collection with one document per clinic listed
/// below. Each document must contain at minimum:
/// ```text
/// clinics/andrology
///   name: "عيادة الذكوره والعقم والبروستاتة"
///   isActive: true
///
/// clinics/physiotherapy
///   name: "عيادة العلاج الطبيعي"
///   isActive: true
///
/// clinics/internal_family
///   name: "الطب الداخلي والأسرة"
///   isActive: true
///
/// clinics/nutrition
///   name: "عيادة التغذية والسمنة"
///   isActive: true
///
/// clinics/chronic_diseases
///   name: "عيادة الأمراض المزمنة"
///   isActive: true
/// ```
///
/// **ID conventions**: IDs are aligned with the existing Firestore collection
/// naming pattern (`nutrition_emrs` → `nutrition`, `physiotherapy_emrs` →
/// `physiotherapy`) observed in the live database.
///
/// ⚠️ If a clinic is renamed or a new clinic is added, update both:
/// 1. This file ([ClinicIds])
/// 2. The Firestore `clinics` collection document IDs
///
/// --- Arabic ---
/// مجموعة `clinics` غير موجودة بعد في قاعدة بيانات `elajtech`. يجب إنشاؤها
/// يدويًا عبر Firebase Console قبل النشر. استخدم هذه الثوابت في جميع مستودعات
/// البيانات وفي [ClinicAccessResolver].
library;

import 'package:elajtech/core/auth/clinic_access_resolver.dart'
    show ClinicAccessResolver;

/// Namespace class grouping all clinic identifier constants.
///
/// فئة تجمع ثوابت معرفات العيادات.
///
/// **English** — Use these constants everywhere a `clinicId` string is required.
/// Never hard-code a clinic ID inline.
///
/// **Arabic** — استخدم هذه الثوابت دائمًا، ولا تكتب معرّف العيادة مباشرةً.
abstract final class ClinicIds {
  ClinicIds._(); // prevents instantiation

  /// Andrology clinic — عيادة الذكوره والعقم والبروستاتة
  ///
  /// Firestore path (verified ✅): `clinics/andrology`
  /// Firestore `name`: "عيادة الذكوره والعقم والبروستاتة"
  static const String andrology = 'andrology';

  /// Physiotherapy clinic — عيادة العلاج الطبيعي
  ///
  /// Aligned with existing `physiotherapy_emrs` collection naming convention.
  /// Firestore path (to be created): `clinics/physiotherapy`
  static const String physiotherapy = 'physiotherapy';

  /// Internal medicine & family clinic — الطب الداخلي والأسرة
  ///
  /// Firestore path (to be created): `clinics/internal_family`
  static const String internalFamily = 'internal_family';

  /// Nutrition & obesity clinic — عيادة التغذية والسمنة
  ///
  /// Aligned with existing `nutrition_emrs` collection naming convention
  /// (not `obesity_nutrition`).
  /// Firestore path (to be created): `clinics/nutrition`
  static const String nutrition = 'nutrition';

  /// Chronic diseases clinic — عيادة الأمراض المزمنة
  ///
  /// Firestore path (to be created): `clinics/chronic_diseases`
  static const String chronicDiseases = 'chronic_diseases';

  /// All clinic IDs as an unmodifiable list.
  ///
  /// Used by [ClinicAccessResolver] for `ADMIN_GLOBAL` role (full access).
  /// قائمة بجميع معرفات العيادات — تُستخدم للمسؤول العام.
  static const List<String> all = [
    andrology,
    physiotherapy,
    internalFamily,
    nutrition,
    chronicDiseases,
  ];
}
