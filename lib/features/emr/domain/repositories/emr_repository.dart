import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/shared/models/emr_model.dart';

/// EMR (Electronic Medical Record) Repository Interface
abstract class EMRRepository {
  /// Save EMR Record
  Future<Either<Failure, Unit>> saveEMR(EMRModel emr);

  /// Get EMR by Appointment ID
  Future<Either<Failure, EMRModel?>> getEMRByAppointmentId(
    String appointmentId,
  );
}
