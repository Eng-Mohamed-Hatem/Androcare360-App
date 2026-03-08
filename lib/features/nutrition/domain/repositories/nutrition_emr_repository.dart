import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/nutrition/domain/entities/nutrition_emr_entity.dart';

/// Nutrition EMR Repository Interface
///
/// Clean Architecture Domain Layer repository interface for nutrition EMR operations.
/// All implementations must use `databaseId: 'elajtech'` for Firestore operations.
///
/// This interface defines the contract for:
/// - Creating and updating nutrition EMR records
/// - Fetching EMR by appointment or patient
/// - Implementing 24-hour lock mechanism
/// - Managing audit trail
abstract class NutritionEMRRepository {
  /// Create or update a nutrition EMR record
  ///
  /// If[emr.id] exists in Firestore, it updates the record.
  /// Otherwise, it creates a new record.
  ///
  /// **Security:**
  /// - Validates [emr.appointmentId] is not empty
  /// - Checks if record is not locked ([emr.isLocked] == false)
  /// - Verifies 24-hour window hasn't expired
  ///
  /// **Audit Trail:**
  /// - Automatically appends audit log entry
  /// - Logs user ID, timestamp, and action type
  ///
  /// Returns:
  /// - [Right(void)] on success
  /// - [Left(ServerFailure)] if validation fails or Firestore error occurs
  Future<Either<Failure, void>> saveEMR(NutritionEMREntity emr);

  /// Fetch nutrition EMR by appointment ID
  ///
  /// Retrieves the EMR record associated with a specific appointment.
  /// Used when doctor opens the appointment medical record screen.
  ///
  /// **Collection:** nutrition_emrs
  /// **Database:** elajtech
  /// **Query:** `where('appointmentId', isEqualTo: appointmentId).limit(1)`
  ///
  /// Parameters:
  /// - [appointmentId]: The appointment identifier
  ///
  /// Returns:
  /// - [Right(NutritionEMREntity)] if found
  /// - [Right(null)] if no EMR exists for this appointment
  /// - [Left(ServerFailure)] on Firestore error
  Future<Either<Failure, NutritionEMREntity?>> getEMRByAppointmentId(
    String appointmentId,
  );

  /// Fetch all nutrition EMRs for a specific patient
  ///
  /// Retrieves complete history of nutrition EMRs for a patient.
  /// Useful for patient profile screen or medical history review.
  ///
  /// **Collection:** nutrition_emrs
  /// **Database:** elajtech
  /// **Query:** `where('patientId', isEqualTo: patientId).orderBy('createdAt', descending: true)`
  ///
  /// Parameters:
  /// - [patientId]: The patient identifier
  ///
  /// Returns:
  /// - [Right(List<NutritionEMREntity>)] list of EMRs (may be empty)
  /// - [Left(ServerFailure)] on Firestore error
  Future<Either<Failure, List<NutritionEMREntity>>> getEMRsByPatientId(
    String patientId,
  );

  /// Manually lock an EMR record
  ///
  /// Locks the record immediately, preventing any further modifications.
  /// Used in special cases when early locking is required (e.g., administrative closure).
  ///
  /// **Normal Behavior:** Records auto-lock after 24 hours via [lockedUntil] field.
  /// **This Method:** Forces immediate lock regardless of time.
  ///
  /// Parameters:
  /// - [emrId]: The EMR record identifier
  ///
  /// Returns:
  /// - [Right(void)] on success
  /// - [Left(ServerFailure)] on Firestore error
  Future<Either<Failure, void>> lockEMR(String emrId);

  /// Check if appointment's 24-hour edit window has expired
  ///
  /// Determines if the time window for editing has passed based on [createdAt].
  /// Used by UI to show lock indicators and prevent edit attempts.
  ///
  /// **Logic:**
  /// - Fetches EMR by appointment ID
  /// - Compares [DateTime.now()] with [emr.lockedUntil]
  /// - Returns true if current time > lockedUntil
  ///
  /// Parameters:
  /// - [appointmentId]: The appointment identifier
  ///
  /// Returns:
  /// - [Right(true)] if expired or locked
  /// - [Right(false)] if still within edit window
  /// - [Left(ServerFailure)] on error or EMR not found
  Future<Either<Failure, bool>> isAppointmentExpired(String appointmentId);

  /// Stream of EMR changes for real-time  UI updates
  ///
  /// **Optional Implementation**
  /// Provides real-time updates for team collaboration scenarios.
  /// Not required for MVP but useful for multi-user clinics.
  ///
  /// Parameters:
  /// - [emrId]: The EMR record identifier
  ///
  /// Returns:
  /// - [Right(Stream<NutritionEMREntity>)] continuous updates
  /// - [Left(ServerFailure)] if stream fails
  Future<Either<Failure, Stream<NutritionEMREntity>>> watchEMR(String emrId);
}
