import 'package:elajtech/features/medical_records/presentation/screens/appointment_medical_record_screen.dart';
import 'package:elajtech/features/packages/presentation/pages/my_packages_page.dart';
import 'package:elajtech/features/patient/appointments/presentation/screens/patient_appointments_screen.dart';
import 'package:elajtech/features/patient/education/presentation/screens/sexual_health_education_screen.dart';
import 'package:elajtech/features/patient/medical_records/presentation/screens/medical_records_screen.dart';
import 'package:elajtech/features/patient/self_assessment/presentation/screens/self_assessment_list_screen.dart';
import 'package:elajtech/features/patient_profile_screen.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
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

  static Future<void> openSelfAssessment(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const SelfAssessmentListScreen(),
      ),
    );
  }

  static Future<void> openAppointments(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const PatientAppointmentsScreen(),
      ),
    );
  }

  static Future<void> openSexualHealthEducation(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const SexualHealthEducationHubScreen(),
      ),
    );
  }

  /// Navigate to [AppointmentMedicalRecordScreen] for a completed appointment.
  /// الانتقال إلى شاشة [AppointmentMedicalRecordScreen] لموعد مكتمل.
  ///
  /// Call this only after confirming the EMR exists; otherwise show a SnackBar
  /// instead of calling this method (see data-model.md §5).
  /// يجب استدعاء هذه الدالة فقط بعد التأكد من وجود السجل الطبي، وإلا يجب عرض
  /// SnackBar بدلاً من الانتقال (راجع data-model.md §5).
  static Future<void> openAppointmentMedicalRecord(
    BuildContext context, {
    required AppointmentModel appointment,
    required String patientName,
  }) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AppointmentMedicalRecordScreen(
          appointment: appointment,
          patientName: patientName,
        ),
      ),
    );
  }
}
