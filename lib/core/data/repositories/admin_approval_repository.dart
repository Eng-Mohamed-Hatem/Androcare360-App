/// Admin approval repository interface
library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/domain/entities/doctor_application_action_result.dart';
import 'package:elajtech/core/domain/entities/pending_doctor_list_item.dart';
import 'package:elajtech/core/error/failures.dart';

/// Repository for admin approval operations.
///
/// This interface defines the contract for admin operations related to
/// doctor registration approval, including approving, rejecting, and
/// retrieving pending doctors.
///
/// **Arabic**: مستودع عمليات موافقة الأطباء
/// **English**: Repository interface for admin approval operations
///
/// **Usage Example:**
/// ```dart
/// final repository = AdminApprovalRepository(firestore: firestore);
///
/// // Get pending doctors for admin review
/// final pendingDoctors = await repository.getPendingDoctors();
///
/// // Approve a doctor
/// await repository.approveDoctor('doctor_123');
///
/// // Reject a doctor
/// await repository.rejectDoctor('doctor_123');
/// ```
abstract class AdminApprovalRepository {
  /// Gets all pending doctors awaiting admin approval.
  ///
  /// Returns doctors where:
  /// - userType = 'doctor'
  /// - isApproved = false
  ///
  /// **Returns:** `Either<Failure, List<PendingDoctorListItem>>`
  Future<Either<Failure, List<PendingDoctorListItem>>> getPendingDoctors();

  /// Approves a pending doctor registration.
  ///
  /// Sets the doctor account to active and approved state:
  /// - isApproved = true
  /// - isActive = true
  /// - approvedAt = DateTime.now()
  ///
  /// **Parameters:**
  /// - [doctorId]: Firestore document ID of the doctor to approve
  ///
  /// **Returns:** `Either<Failure, Unit>` - Success if approved
  ///
  /// **Failure cases:**
  /// - Doctor not found: Document with given ID doesn't exist
  /// - Server error: Firestore update failed
  Future<Either<Failure, DoctorApplicationActionResult>> approveDoctor({
    required String doctorId,
    required String adminId,
    required String adminName,
  });

  /// Rejects a pending doctor registration.
  ///
  /// Deletes the doctor's user document and all related registration data.
  /// Rejected doctors must register again as new users.
  ///
  /// **Parameters:**
  /// - [doctorId]: Firestore document ID of the doctor to reject
  ///
  /// **Returns:** `Either<Failure, Unit>` - Success if rejected
  ///
  /// **Failure cases:**
  /// - Doctor not found: Document with given ID doesn't exist
  /// - Server error: Firestore deletion failed
  Future<Either<Failure, DoctorApplicationActionResult>> rejectDoctor({
    required String doctorId,
    required String adminId,
    required String adminName,
  });
}
