import 'package:elajtech/features/patient/consultation/domain/repositories/consultation_call_repository.dart';

class UpdateCallJoinStateUseCase {
  UpdateCallJoinStateUseCase(this._repository);

  final ConsultationCallRepository _repository;

  void markAnswerAccepted() => _repository.markAnswerAccepted();

  void markJoinStarted() => _repository.markJoinStarted();

  void markJoinSucceeded() => _repository.markJoinSucceeded();

  void markJoinFailed() => _repository.markJoinFailed();

  void markCallEnded() => _repository.markCallEnded();
}
