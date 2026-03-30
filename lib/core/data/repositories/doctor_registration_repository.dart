/// Doctor registration repository interface
library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';

/// Repository for doctor registration operations.
///
/// This interface defines the contract for doctor registration operations,
/// including creating new doctor accounts with approval state.
///
/// **Arabic**: مستودع بيانات تسجيل الأطباء
/// **English**: Repository interface for doctor registration operations
///
/// **Usage Example:**
/// ```dart
/// final repository = DoctorRegistrationRepository(firestore: firestore);
/// final result = await repository.registerDoctor(
///   fullName: 'Dr. Ahmed',
///   email: 'doctor@example.com',
///   phoneNumber: '+201234567890',
///   specialty: 'عيادة السمنة والتغذية العلاجية',
/// );
/// ```
// ignore: one_member_abstracts, repository contract is kept explicit for DI and testing
abstract interface class DoctorRegistrationRepository {
  /// Registers a new doctor account in Firestore.
  ///
  /// Creates a doctor user with pending approval state
  /// (isActive=false, isApproved=false). Registration fails if
  /// validation rules are not met.
  ///
  /// **Parameters:**
  /// - [fullName]: Doctor's full name
  /// - [email]: Doctor's email address
  /// - [phoneNumber]: Phone number in E.164 format
  /// - [specialty]: Selected specialty from predefined list
  ///
  /// **Returns:** `Either<Failure, String>` - Success with the created doctor ID
  ///
  /// **Failure cases:**
  /// - Server error: Firestore write failed
  /// - Validation error: Invalid specialty or phone number format
  Future<Either<Failure, String>> registerDoctor({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String specialty,
  });
}
