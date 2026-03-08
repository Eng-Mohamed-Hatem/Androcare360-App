import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/shared/models/user_model.dart';
// import '../../../../shared/models/doctor_model.dart'; // We might use this later if we switch models

/// Doctor Repository Interface
abstract class DoctorRepository {
  /// Get All Doctors
  Future<Either<Failure, List<UserModel>>> getDoctors();

  /// Get Doctors Stream (for real-time updates)
  Stream<List<UserModel>> getDoctorsStream();

  /// Get Doctor by ID
  Future<Either<Failure, UserModel>> getDoctorById(String id);
}
