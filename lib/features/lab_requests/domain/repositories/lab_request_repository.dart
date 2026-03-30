import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/core/models/paginated_result.dart';
import 'package:elajtech/shared/models/lab_request_model.dart';

abstract class LabRequestRepository {
  Future<Either<Failure, void>> saveLabRequest(LabRequestModel request);
  Future<Either<Failure, List<LabRequestModel>>> getLabRequestsForPatient(
    String patientId,
  );
  Future<Either<Failure, PaginatedResult<LabRequestModel>>>
  getLabRequestsForPatientPage(
    String patientId, {
    int limit = 10,
  });
  Future<Either<Failure, List<LabRequestModel>>> getLabRequestsByAppointmentId(
    String appointmentId,
  );
}
