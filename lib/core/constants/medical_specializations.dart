import 'package:elajtech/core/constants/specialty_constants.dart';
import 'package:flutter/material.dart';

/// Medical Specializations Hierarchy & Icons
///
/// Uses SpecialtyConstants for consistent naming across the app
class MedicalSpecializations {
  // Use constants from SpecialtyConstants for consistency
  static const String andrologyClinic = SpecialtyConstants.andrologyClinic;
  static const String otherClinics = 'تخصصات أخرى';

  // Sub-specialties Hierarchy
  static const Map<String, List<String>> hierarchy = {
    andrologyClinic: [
      'طب الذكورة',
      'تأخر الإنجاب والعقم لدى الرجال',
      'صحة البروستات',
      'الأمراض الجنسية المعدية',
    ],
    otherClinics: [
      SpecialtyConstants.chronicDiseasesClinic,
      SpecialtyConstants.nutritionClinic,
      SpecialtyConstants.physiotherapyClinic,
      SpecialtyConstants.internalMedicineClinic,
    ],
  };

  // Icons Mapping (using SpecialtyConstants for Other Clinics)
  static const Map<String, IconData> icons = {
    // Main Categories
    andrologyClinic: Icons.male,
    otherClinics: Icons.medical_services,

    // Andrology Sub-specialties
    'طب الذكورة': Icons.health_and_safety,
    'تأخر الإنجاب والعقم لدى الرجال': Icons.child_friendly,
    'صحة البروستات': Icons.opacity,
    'الأمراض الجنسية المعدية': Icons.coronavirus,

    // Other Specialties (using SpecialtyConstants for consistency)
    SpecialtyConstants.chronicDiseasesClinic: Icons.monitor_heart,
    SpecialtyConstants.nutritionClinic: Icons.restaurant_menu,
    SpecialtyConstants.physiotherapyClinic: Icons.accessibility_new,
    SpecialtyConstants.internalMedicineClinic: Icons.family_restroom,
  };

  // Colors Mapping (Optional for distinct look)
  static const Map<String, Color> colors = {
    andrologyClinic: Color(0xFF1E88E5), // Blue
    otherClinics: Color(0xFF43A047), // Green
  };

  static IconData getIcon(String name) {
    return icons[name] ?? Icons.local_hospital;
  }

  // List of all main categories
  static List<String> get mainCategories => hierarchy.keys.toList();

  // Get sub-specialties for a category
  static List<String> getSubSpecialties(String category) {
    return hierarchy[category] ?? [];
  }
}
