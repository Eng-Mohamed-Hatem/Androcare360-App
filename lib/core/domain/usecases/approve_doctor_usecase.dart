import 'package:dartz/dartz.dart';
import 'package:elajtech/core/domain/entities/doctor_application_action_result.dart';
import 'package:elajtech/core/error/failures.dart';

/// Approve Doctor Use Case interface
///
/// This use case handles approving pending doctor registrations.
/// It updates the doctor's status to active and approved,
/// sets the approval timestamp, and triggers an email notification.
///
/// **Arabic**: حالة استخدام موافقة الأطباء
/// **English**: Use case for approving doctor registrations
///
/// **Business Rules:**
/// - Only admins can approve doctors (role-based access control)
/// - Approved doctors become visible to patients
/// - Approved doctors can log in and access dashboard
/// - Email notification is sent after approval (non-blocking)
///
/// **Usage Example:**
/// ```dart
/// final useCase = getIt<ApproveDoctorUseCase>();
/// final result = await useCase.call('doctor_123');
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showApprovalSuccess(),
/// );
/// ```
abstract class ApproveDoctorUseCase {
  /// Approves a pending doctor registration.
  ///
  /// Updates the doctor account to active and approved state:
  /// - isApproved: true
  /// - isActive: true
  /// - approvedAt: DateTime.now()
  ///
  /// Also triggers an email notification to the doctor (non-blocking).
  ///
  /// **Parameters:**
  /// - [doctorId]: Firestore document ID of the doctor to approve
  ///
  /// **Returns:** `Either<Failure, Unit>` - Success if approved
  ///
  /// **Failure cases:**
  /// - Doctor not found: Document with given ID doesn't exist
  /// - Server error: Firestore update failed
  Future<Either<Failure, DoctorApplicationActionResult>> call({
    required String doctorId,
    required String adminId,
    required String adminName,
  });
}
