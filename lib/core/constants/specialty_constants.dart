import 'package:flutter/foundation.dart';

/// Medical Specialty Constants for Elajtech App
///
/// This class provides:
/// 1. Single Source of Truth for all specialty names
/// 2. Fuzzy Matching Algorithm to handle variations in Firestore data
/// 3. Text Normalization for Arabic text
/// 4. Firestore collection paths for each specialty
///
/// Created: 2026-01-18
/// Purpose: Fix EMR tab visibility issues caused by exact string matching
class SpecialtyConstants {
  SpecialtyConstants._(); // Private constructor to prevent instantiation

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMARY SPECIALTY NAMES (المسميات الرسمية الكاملة)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Nutrition & Obesity Therapy Clinic
  /// Used in Firestore: user.specializations array
  static const String nutritionClinic = 'عيادة السمنة والتغذية العلاجية';

  /// Physiotherapy & Rehabilitation Clinic
  /// Used in Firestore: user.specializations array
  static const String physiotherapyClinic = 'عيادة العلاج الطبيعي والتأهيل';

  /// Internal Medicine & Family Medicine Clinic
  /// Used in Firestore: user.specializations array
  static const String internalMedicineClinic = 'عيادة الباطنة وطب الأسرة';

  /// Andrology, Infertility & Prostate Clinic
  /// Used in Firestore: user.specializations array
  static const String andrologyClinic = 'عيادة الذكورة والعقم والبروستات';

  /// Chronic Diseases Clinic
  /// Used in Firestore: user.specializations array
  static const String chronicDiseasesClinic = 'عيادة الأمراض المزمنة';

  // ═══════════════════════════════════════════════════════════════════════════
  // KEYWORD LISTS FOR FUZZY MATCHING (كلمات مفتاحية للبحث المرن)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Keywords that identify Nutrition/Obesity specialty
  /// Used for contains() matching to handle variations
  static const List<String> nutritionKeywords = [
    'تغذية',
    'سمنة',
    'nutrition',
    'obesity',
    'diet',
  ];

  /// Keywords that identify Physiotherapy specialty
  static const List<String> physiotherapyKeywords = [
    'علاج طبيعي',
    'تأهيل',
    'physiotherapy',
    'rehabilitation',
    'physical therapy',
    'rehab',
  ];

  /// Keywords that identify Internal Medicine specialty
  static const List<String> internalMedicineKeywords = [
    'باطنة',
    'باطنه',
    'طب الأسرة',
    'internal medicine',
    'family medicine',
    'family practice',
    'general medicine',
  ];

  /// Keywords that identify Andrology specialty
  static const List<String> andrologyKeywords = [
    'ذكورة',
    'ذكوره',
    'عقم',
    'بروستات',
    'andrology',
    'infertility',
    'prostate',
    'male health',
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT NORMALIZATION UTILITIES (خوارزميات تطبيع النصوص)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Normalize Arabic text for comparison
  ///
  /// Performs the following operations:
  /// 1. Trim leading/trailing whitespace
  /// 2. Replace multiple spaces with single space
  /// 3. Remove "ال" prefix (Arabic definite article)
  /// 4. Normalize taa marbouta variations (ة/ه)
  /// 5. Convert to lowercase
  ///
  /// Example:
  /// ```dart
  /// _normalizeArabicText('  عيادة  السمنة  ') // Returns: 'عيادة سمنة'
  /// _normalizeArabicText('الباطن ه') // Returns: 'باطنة'
  /// ```
  static String _normalizeArabicText(String text) {
    return text
        .trim() // Remove leading/trailing whitespace
        .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces with single
        .replaceAll('ال', '') // Remove "ال" prefix
        .replaceAll('ه ', 'ة ') // Normalize taa marbouta before space
        .replaceAll(' ه', ' ة') // Normalize taa marbouta after space
        .replaceAll(RegExp(r'ه$'), 'ة') // Normalize taa marbouta at end
        .toLowerCase(); // Convert to lowercase
  }

  /// Check if a specialty string matches any keywords in the provided list
  ///
  /// Uses fuzzy matching with text normalization to handle:
  /// - Extra whitespace
  /// - Missing "عيادة" prefix
  /// - Typos and variations
  /// - English translations
  ///
  /// Returns true if ANY keyword is found in the specialty string
  static bool _matchesAnyKeyword(String specialty, List<String> keywords) {
    final normalized = _normalizeArabicText(specialty);

    return keywords.any((keyword) {
      final normalizedKeyword = _normalizeArabicText(keyword);
      return normalized.contains(normalizedKeyword);
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SPECIALTY DETECTION METHODS (دوال اكتشاف التخصص)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if user has Nutrition specialty
  ///
  /// Handles variations and typos in database:
  /// - ✅ "عيادة السمنة والتغذية العلاجية" (exact)
  /// - ✅ "تغذية وسمنة" (keywords only)
  /// - ✅ "عيادة  السمنة" (extra spaces)
  /// - ✅ "Nutrition Clinic" (English)
  ///
  /// Returns false if specializations is null or empty
  static bool isNutritionDoctor(List<String>? specializations) {
    if (specializations == null || specializations.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [Specialty] Null or empty specializations');
      }
      return false;
    }

    return specializations.any((spec) {
      // First, try exact match (fastest - O(1))
      if (spec == nutritionClinic) {
        if (kDebugMode) {
          debugPrint('✅ [Specialty] Exact match for Nutrition: $spec');
        }
        return true;
      }

      // Then, try fuzzy match with keywords
      final matches = _matchesAnyKeyword(spec, nutritionKeywords);
      if (matches && kDebugMode) {
        debugPrint('✅ [Specialty] Fuzzy match for Nutrition: $spec');
      }
      return matches;
    });
  }

  /// Check if user has Physiotherapy specialty
  ///
  /// Handles variations and typos in database:
  /// - ✅ "عيادة العلاج الطبيعي والتأهيل" (exact)
  /// - ✅ "علاج طبيعي" (keywords only)
  /// - ✅ "Physiotherapy Clinic" (English)
  ///
  /// Returns false if specializations is null or empty
  static bool isPhysiotherapyDoctor(List<String>? specializations) {
    if (specializations == null || specializations.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [Specialty] Null or empty specializations');
      }
      return false;
    }

    return specializations.any((spec) {
      // First, try exact match (fastest)
      if (spec == physiotherapyClinic) {
        if (kDebugMode) {
          debugPrint('✅ [Specialty] Exact match for Physiotherapy: $spec');
        }
        return true;
      }

      // Then, try fuzzy match with keywords
      final matches = _matchesAnyKeyword(spec, physiotherapyKeywords);
      if (matches && kDebugMode) {
        debugPrint('✅ [Specialty] Fuzzy match for Physiotherapy: $spec');
      }
      return matches;
    });
  }

  /// Check if user has Internal Medicine specialty
  ///
  /// Handles variations and typos in database:
  /// - ✅ "عيادة الباطنة وطب الأسرة" (exact)
  /// - ✅ "الباطنة" (keywords only)
  /// - ✅ "طب الأسرة" (Arabic)
  /// - ✅ "Internal Medicine" (English)
  ///
  /// Returns false if specializations is null or empty
  static bool isInternalMedicineDoctor(List<String>? specializations) {
    if (specializations == null || specializations.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [Specialty] Null or empty specializations');
      }
      return false;
    }

    return specializations.any((spec) {
      // First, try exact match (fastest)
      if (spec == internalMedicineClinic) {
        if (kDebugMode) {
          debugPrint('✅ [Specialty] Exact match for Internal Medicine: $spec');
        }
        return true;
      }

      // Then, try fuzzy match with keywords
      final matches = _matchesAnyKeyword(spec, internalMedicineKeywords);
      if (matches && kDebugMode) {
        debugPrint('✅ [Specialty] Fuzzy match for Internal Medicine: $spec');
      }
      return matches;
    });
  }

  /// Check if user has Andrology specialty
  ///
  /// Handles variations and typos in database:
  /// - ✅ "عيادة الذكورة والعقم والبروستات" (exact)
  /// - ✅ "ذكورة" (keywords only)
  /// - ✅ "Andrology Clinic" (English)
  ///
  /// Returns false if specializations is null or empty
  static bool isAndrologyDoctor(List<String>? specializations) {
    if (specializations == null || specializations.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [Specialty] Null or empty specializations');
      }
      return false;
    }

    return specializations.any((spec) {
      // First, try exact match (fastest)
      if (spec == andrologyClinic) {
        if (kDebugMode) {
          debugPrint('✅ [Specialty] Exact match for Andrology: $spec');
        }
        return true;
      }

      // Then, try fuzzy match with keywords
      final matches = _matchesAnyKeyword(spec, andrologyKeywords);
      if (matches && kDebugMode) {
        debugPrint('✅ [Specialty] Fuzzy match for Andrology: $spec');
      }
      return matches;
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIRESTORE COLLECTION PATHS (مسارات مجموعات Firestore)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Firestore collection for Nutrition EMRs
  /// Database: elajtech
  static const String nutritionEmrCollection = 'nutrition_emrs';

  /// Firestore collection for Physiotherapy EMRs
  /// Database: elajtech
  static const String physiotherapyEmrCollection = 'physiotherapy_emrs';

  /// Firestore collection for Internal Medicine EMRs
  /// Database: elajtech
  static const String internalMedicineEmrCollection = 'emr_records';

  /// Firestore collection for Andrology EMRs (default EMR)
  /// Database: elajtech
  static const String andrologyEmrCollection = 'emr_records';
}
