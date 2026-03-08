import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/shared/models/lab_request_model.dart';

abstract class LabRequestRepository {
  Future<Either<Failure, void>> saveLabRequest(LabRequestModel request);
  Future<Either<Failure, List<LabRequestModel>>> getLabRequestsForPatient(
    String patientId,
  );
  Future<Either<Failure, List<LabRequestModel>>> getLabRequestsByAppointmentId(
    String appointmentId,
  );
}
