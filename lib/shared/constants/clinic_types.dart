/// Canonical clinic-type definitions for doctor registration.
library;

/// Provides the allowed doctor clinic types, their database values, and their
/// display labels.
class ClinicTypes {
  ClinicTypes._();

  static const String andrologyInfertilityProstate =
      'andrology_infertility_prostate';
  static const String chronicDiseases = 'chronic_diseases';
  static const String obesityTherapeuticNutrition =
      'obesity_therapeutic_nutrition';
  static const String physicalTherapyRehabilitation =
      'physical_therapy_rehabilitation';
  static const String internalMedicineFamilyPractice =
      'internal_medicine_family_practice';

  static const Map<String, String> englishLabels = {
    andrologyInfertilityProstate: 'Andrology, Infertility & Prostate Clinic',
    chronicDiseases: 'Chronic Diseases Clinic',
    obesityTherapeuticNutrition: 'Obesity & Therapeutic Nutrition Clinic',
    physicalTherapyRehabilitation: 'Physical Therapy & Rehabilitation Clinic',
    internalMedicineFamilyPractice:
        'Internal Medicine & Family Practice Clinic',
  };

  static const Map<String, String> arabicLabels = {
    andrologyInfertilityProstate: 'عيادة الذكورة والعقم والبروستات',
    chronicDiseases: 'عيادة الأمراض المزمنة',
    obesityTherapeuticNutrition: 'عيادة السمنة والتغذية العلاجية',
    physicalTherapyRehabilitation: 'عيادة العلاج الطبيعي والتأهيل',
    internalMedicineFamilyPractice: 'عيادة الباطنة وطب الأسرة',
  };

  static const List<String> values = [
    andrologyInfertilityProstate,
    chronicDiseases,
    obesityTherapeuticNutrition,
    physicalTherapyRehabilitation,
    internalMedicineFamilyPractice,
  ];

  static bool isValid(String? clinicType) =>
      clinicType != null && values.contains(clinicType.trim());

  static String englishLabel(String clinicType) =>
      englishLabels[clinicType] ?? englishLabels.values.first;

  static String arabicLabel(String clinicType) =>
      arabicLabels[clinicType] ?? arabicLabels.values.first;

  static String? fromArabicLabel(String? label) {
    if (label == null) {
      return null;
    }

    final normalized = label.trim();
    for (final entry in arabicLabels.entries) {
      if (entry.value == normalized) {
        return entry.key;
      }
    }
    return null;
  }
}
