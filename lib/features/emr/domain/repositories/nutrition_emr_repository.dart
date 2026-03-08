import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/shared/models/nutrition_emr_model.dart';

abstract class NutritionEMRRepository {
  Future<Either<Failure, void>> saveEMR(NutritionEMRModel emr);
  Future<Either<Failure, NutritionEMRModel?>> getEMRByAppointmentId(
    String appointmentId,
  );
  Future<Either<Failure, List<NutritionEMRModel>>> getEMRByPatientId(
    String patientId,
  );
}
