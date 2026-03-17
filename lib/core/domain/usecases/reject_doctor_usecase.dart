import 'package:dartz/dartz.dart';
import 'package:elajtech/core/domain/entities/doctor_application_action_result.dart';
import 'package:elajtech/core/error/failures.dart';

/// Reject Doctor Use Case interface
///
/// This use case handles rejecting pending doctor registrations.
/// It permanently deletes the doctor's user document and all
/// related registration data. Rejected doctors must register again
/// as new users.
///
/// **Arabic**: حالة استخدام رفض الأطباء
/// **English**: Use case for rejecting doctor registrations
///
/// **Business Rules:**
/// - Only admins can reject doctors (role-based access control)
/// - Rejected doctors are permanently deleted from Firestore
/// - Rejected doctors cannot log in or access the system
/// - Rejected doctors must register again as new users
///
/// **Usage Example:**
/// ```dart
/// final useCase = getIt<RejectDoctorUseCase>();
/// final result = await useCase.call('doctor_123');
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showRejectionSuccess(),
/// );
/// ```
abstract class RejectDoctorUseCase {
  /// Rejects a pending doctor registration.
  ///
  /// Permanently deletes the doctor's user document and all
  /// related registration data. Rejected doctors must register
  /// again as new users.
  ///
  /// **Parameters:**
  /// - [doctorId]: Firestore document ID of the doctor to reject
  ///
  /// **Returns:** `Either<Failure, Unit>` - Success if rejected
  ///
  /// **Failure cases:**
  /// - Doctor not found: Document with given ID doesn't exist
  /// - Server error: Firestore deletion failed
  Future<Either<Failure, DoctorApplicationActionResult>> call({
    required String doctorId,
    required String adminId,
    required String adminName,
  });
}
