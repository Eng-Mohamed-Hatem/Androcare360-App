/// Pending doctor list item entity for admin approval screen
library;

import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/shared/constants/clinic_types.dart';

/// Represents a doctor in the admin approval list UI.
///
/// This is a simplified view model containing only the fields
/// needed for displaying pending doctors to administrators.
/// It maps to a Doctor/UserModel entity but only includes the
/// fields relevant for the admin approval list.
///
/// **Arabic**: عنصر موافقة الإعجاء للمراجعة
/// **English**: Pending doctor list item for admin approval screen
///
/// **Usage Example:**
/// ```dart
/// final pendingDoctor = PendingDoctorListItem(
///   doctorId: 'doctor_123',
///   fullName: 'Dr. Sarah Ahmed',
///   phoneNumber: '+966500000001',
///   specialty: 'عيادة الأمراض المزمنة',
///   createdAt: DateTime.parse('2026-03-14T10:30:00'),
///   email: 'doctor@example.com',
/// );
/// ```
class PendingDoctorListItem {
  /// Creates a PendingDoctorListItem instance.
  ///
  /// This constructor requires all required fields.
  PendingDoctorListItem({
    required this.doctorId,
    required this.fullName,
    required this.phoneNumber,
    required this.specialty,
    required this.createdAt,
    required this.email,
  });

  /// Creates a PendingDoctorListItem from a UserModel.
  ///
  /// This factory constructor maps the UserModel entity fields
  /// to the simplified PendingDoctorListItem view model.
  ///
  /// **Parameters:**
  /// - [user]: UserModel instance containing doctor data
  ///
  /// **Returns:** PendingDoctorListItem instance
  ///
  /// **Example:**
  /// ```dart
  /// final user = UserModel(...);
  /// final listItem = PendingDoctorListItem.fromUserModel(user);
  /// ```
  factory PendingDoctorListItem.fromUserModel(UserModel user) {
    return PendingDoctorListItem(
      doctorId: user.id,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber ?? '',
      specialty:
          user.specialty ??
          (user.clinicType != null
              ? ClinicTypes.arabicLabel(user.clinicType!)
              : ''),
      createdAt: user.createdAt,
      email: user.email,
    );
  }

  /// Firestore document ID of the doctor
  final String doctorId;

  /// Doctor's full name for display
  final String fullName;

  /// Phone number in E.164 format for display
  final String phoneNumber;

  /// Selected specialty (Arabic label) for display
  final String specialty;

  /// Registration timestamp for display and sorting
  final DateTime createdAt;

  /// Doctor's email address (for potential contact)
  final String email;
}
