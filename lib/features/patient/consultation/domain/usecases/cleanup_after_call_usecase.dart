import 'package:elajtech/features/patient/consultation/domain/repositories/consultation_call_repository.dart';

class CleanupAfterCallUseCase {
  CleanupAfterCallUseCase(this._repository);

  final ConsultationCallRepository _repository;

  Future<String?> call() => _repository.cleanupAfterCall();
}
