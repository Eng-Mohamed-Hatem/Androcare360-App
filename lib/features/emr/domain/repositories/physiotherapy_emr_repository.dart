import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/shared/models/physiotherapy_emr_model.dart';

/// Physiotherapy EMR Repository Interface
abstract class PhysiotherapyEMRRepository {
  /// Save a Physiotherapy EMR record
  Future<Either<Failure, void>> saveEMR(PhysiotherapyEMRModel emr);

  /// Get Physiotherapy EMR by appointment ID
  Future<Either<Failure, PhysiotherapyEMRModel?>> getEMRByAppointmentId(
    String appointmentId,
  );

  /// Get all Physiotherapy EMRs for a patient
  Future<Either<Failure, List<PhysiotherapyEMRModel>>> getEMRByPatientId(
    String patientId,
  );
}
