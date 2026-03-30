import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/core/models/paginated_result.dart';
import 'package:elajtech/shared/models/prescription_model.dart';

/// Prescription Repository Interface
abstract class PrescriptionRepository {
  /// Save Prescription
  Future<Either<Failure, Unit>> savePrescription(
    PrescriptionModel prescription,
  );

  /// Get Prescriptions for Patient
  Future<Either<Failure, List<PrescriptionModel>>> getPrescriptionsForPatient(
    String patientId,
  );

  Future<Either<Failure, PaginatedResult<PrescriptionModel>>>
  getPrescriptionsForPatientPage(
    String patientId, {
    int limit = 10,
  });

  /// Get Prescriptions for Doctor
  Future<Either<Failure, List<PrescriptionModel>>> getPrescriptionsByDoctor(
    String doctorId,
  );

  /// Get Prescriptions by Appointment ID
  Future<Either<Failure, List<PrescriptionModel>>>
  getPrescriptionsByAppointmentId(String appointmentId);
}
