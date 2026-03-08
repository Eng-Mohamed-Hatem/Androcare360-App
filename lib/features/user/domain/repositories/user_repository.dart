import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/shared/models/user_model.dart';

abstract class UserRepository {
  Future<Either<Failure, UserModel>> getUser(String userId);
  Future<Either<Failure, List<UserModel>>> getAllPatients();
}
