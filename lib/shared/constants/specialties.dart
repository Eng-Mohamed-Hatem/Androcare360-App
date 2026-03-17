/// Specialties for doctor registration approval flow
library;

import 'package:elajtech/shared/constants/clinic_types.dart';

/// Defines the allowed medical specialties for doctors in the system.
///
/// **Arabic**: قائمة التخصصات الطبية المسموح بها للدكاء
/// **English**: Allowed medical specialties for doctor registration
///
/// These specialties are enforced during doctor registration.
/// Doctors must select exactly one specialty from this list.
///
/// **Usage Example:**
/// ```dart
/// // Get all specialties as a list
/// final allSpecialties = Specialties.arabicLabels;
///
/// // Check if a specialty is allowed
/// final isAllowed = Specialties.allowedValues.contains('عيادة السمنة والتغذية العلاجية');
/// ```
class Specialties {
  /// Arabic labels for the five approved medical specialties.
  ///
  /// **Values:**
  /// - عيادة الذكورة والعقم والبروستات (Andrology, Infertility & Prostate)
  /// - عيادة الأمراض المزمنة (Chronic Diseases)
  /// - عيادة السمنة والتغذية العلاجية (Obesity & Therapeutic Nutrition)
  /// - عيادة العلاج الطبيعي والتأهيل (Physiotherapy & Rehabilitation)
  /// - عيادة الباطنة وطب الأسرة (Internal Medicine & Family Medicine)
  ///
  /// This list is used for dropdown/radio button selection in the
  /// doctor registration UI and for validation in the backend.
  static final List<String> arabicLabels = [
    ClinicTypes.arabicLabels[ClinicTypes.andrologyInfertilityProstate]!,
    ClinicTypes.arabicLabels[ClinicTypes.chronicDiseases]!,
    ClinicTypes.arabicLabels[ClinicTypes.obesityTherapeuticNutrition]!,
    ClinicTypes.arabicLabels[ClinicTypes.physicalTherapyRehabilitation]!,
    ClinicTypes.arabicLabels[ClinicTypes.internalMedicineFamilyPractice]!,
  ];

  /// Set of allowed specialty values for validation.
  ///
  /// This set is used in backend validation to ensure doctors
  /// can only select from the predefined list.
  static final Set<String> allowedValues = arabicLabels.toSet();

  /// Validates if a specialty is in the allowed values list.
  ///
  /// Returns `true` if the specialty matches one of the predefined
  /// Arabic specialty labels, otherwise `false`.
  ///
  /// **Parameters:**
  /// - [specialty]: Specialty string to validate (nullable)
  ///
  /// **Returns:** `bool` - true if valid, false if invalid
  ///
  /// **Example:**
  /// ```dart
  /// Specialties.isValid('عيادة السمنة والتغذية العلاجية'); // true
  /// Specialties.isValid('عيادة غير موجودة'); // false
  /// Specialties.isValid(null); // false
  /// Specialties.isValid(''); // false
  /// ```
  static bool isValid(String? specialty) {
    if (specialty == null || specialty.isEmpty) {
      return false;
    }
    return allowedValues.contains(specialty);
  }
}
