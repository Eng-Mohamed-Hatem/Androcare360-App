import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/shared/models/internal_medicine_emr_model.dart';

/// Internal Medicine EMR Repository Interface
abstract class InternalMedicineEMRRepository {
  /// Save an Internal Medicine EMR record
  Future<Either<Failure, void>> saveEMR(InternalMedicineEMRModel emr);

  /// Get Internal Medicine EMR by appointment ID
  Future<Either<Failure, InternalMedicineEMRModel?>> getEMRByAppointmentId(
    String appointmentId,
  );

  /// Get all Internal Medicine EMRs for a patient
  Future<Either<Failure, List<InternalMedicineEMRModel>>> getEMRByPatientId(
    String patientId,
  );
}
