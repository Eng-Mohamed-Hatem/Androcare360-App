import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/shared/models/device_request_model.dart';

abstract class DeviceRequestRepository {
  Future<Either<Failure, void>> saveDeviceRequest(DeviceRequestModel request);
  Future<Either<Failure, List<DeviceRequestModel>>> getDeviceRequestsForPatient(
    String patientId,
  );
  Future<Either<Failure, List<DeviceRequestModel>>>
  getDeviceRequestsByAppointmentId(String appointmentId);
}
