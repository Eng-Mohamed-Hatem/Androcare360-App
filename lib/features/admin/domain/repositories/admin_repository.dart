import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/admin/domain/entities/audit_log.dart';
import 'package:elajtech/shared/models/user_model.dart';

/// Abstract repository interface for all admin-only operations.
///
/// This repository is the single point of truth for admin actions.
/// All implementations MUST:
/// - Write to the `audit_logs` Firestore collection after every mutation.
/// - Use the `elajtech` Firestore database (via injected [FirebaseFirestore]).
/// - Return [Either<Failure, T>] — never throw directly to the caller.
///
/// **Dependency Injection:**
/// ```dart
/// final adminRepo = getIt<AdminRepository>();
/// ```
abstract class AdminRepository {
  // ───────────────────────────── Doctors ────────────────────────────────────

  /// Returns all users with `userType == 'doctor'` from Firestore.
  Future<Either<Failure, List<UserModel>>> getAllDoctors();

  /// Returns all users with `userType == 'patient'` from Firestore.
  Future<Either<Failure, List<UserModel>>> getAllPatients();

  /// Creates a new doctor account in Firebase Auth + Firestore and logs
  /// the action to `audit_logs`.
  ///
  /// [adminId] and [adminName] are the acting admin's credentials used
  /// for the audit log entry.
  Future<Either<Failure, Unit>> createDoctor({
    required UserModel doctor,
    required String password,
    required String adminId,
    required String adminName,
  });

  /// Updates admin-managed doctor profile fields in Firestore and writes
  /// a field-level diff to `audit_logs`.
  ///
  /// [updatedDoctor] should contain all final field values.
  /// [previousDoctor] is used to compute the diff for the audit log.
  Future<Either<Failure, Unit>> updateDoctorProfile({
    required UserModel updatedDoctor,
    required UserModel previousDoctor,
    required String adminId,
    required String adminName,
  });

  // ───────────────────────────── Account Status ──────────────────────────────

  /// Activates or deactivates a user account.
  ///
  /// This call:
  /// 1. Invokes the `setAccountStatus` Cloud Function (europe-west1 region)
  ///    which disables/enables the Firebase Auth account.
  /// 2. Updates `isActive` on the Firestore `users` document.
  /// 3. Writes to `audit_logs`.
  ///
  /// The Cloud Function must be called because only Firebase Admin SDK
  /// (server-side) can disable Auth accounts.
  Future<Either<Failure, Unit>> setAccountStatus({
    required String targetUserId,
    required bool isActive,
    required String adminId,
    required String adminName,
  });

  // ───────────────────────────── EMR ────────────────────────────────────────

  /// Retrieves all EMR records across all collections for a given patient.
  ///
  /// Returns a list of maps with a `collection` key (e.g. 'prescriptions')
  /// and a `data` key containing the document data.
  ///
  /// Admin has read-only access; this method never writes.
  Future<Either<Failure, List<Map<String, dynamic>>>> getPatientEmrHistory(
    String patientId,
  );

  // ───────────────────────────── Audit ──────────────────────────────────────

  /// Real-time stream of all audit log entries, ordered by timestamp desc.
  Stream<List<AuditLog>> watchAuditLogs();
}
