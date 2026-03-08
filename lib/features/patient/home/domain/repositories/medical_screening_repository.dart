import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/patient/home/data/models/medical_screening_model.dart';

/// Repository interface for Medical Screening operations
abstract class MedicalScreeningRepository {
  /// Fetch the current patient's medical screening data.
  /// Returns [MedicalScreeningModel] if found, null if not found, or [Failure].
  Future<Either<Failure, MedicalScreeningModel?>> getMedicalScreening(
    String patientId,
  );

  /// Save or update the patient's medical screening data.
  Future<Either<Failure, Unit>> saveMedicalScreening(
    String patientId,
    MedicalScreeningModel data,
  );
}
