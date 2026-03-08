import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/shared/models/radiology_request_model.dart';

abstract class RadiologyRequestRepository {
  Future<Either<Failure, void>> saveRadiologyRequest(
    RadiologyRequestModel request,
  );
  Future<Either<Failure, List<RadiologyRequestModel>>>
  getRadiologyRequestsForPatient(String patientId);
  Future<Either<Failure, List<RadiologyRequestModel>>>
  getRadiologyRequestsByAppointmentId(String appointmentId);
}
