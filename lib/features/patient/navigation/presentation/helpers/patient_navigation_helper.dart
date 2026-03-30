import 'package:elajtech/features/packages/presentation/pages/my_packages_page.dart';
import 'package:elajtech/features/patient/medical_records/presentation/screens/medical_records_screen.dart';
import 'package:elajtech/features/patient_profile_screen.dart';
import 'package:flutter/material.dart';

class PatientNavigationHelper {
  const PatientNavigationHelper._();

  static Future<void> openProfile(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const PatientProfileScreen(),
      ),
    );
  }

  static Future<void> openMedicalRecords(
    BuildContext context, {
    int initialIndex = 0,
  }) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => MedicalRecordsScreen(initialIndex: initialIndex),
      ),
    );
  }

  static Future<void> openMyPackages(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const MyPackagesPage(),
      ),
    );
  }
}
