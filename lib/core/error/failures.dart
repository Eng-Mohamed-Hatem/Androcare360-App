import 'package:equatable/equatable.dart';

/// Abstract Failure Class
abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

/// Server Failure
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Cache Failure
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Auth Failure
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
