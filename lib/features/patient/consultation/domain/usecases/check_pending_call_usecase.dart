import 'package:elajtech/core/services/voip_call_service.dart';
import 'package:elajtech/features/patient/consultation/domain/repositories/consultation_call_repository.dart';

class CheckPendingCallUseCase {
  CheckPendingCallUseCase(this._repository);

  final ConsultationCallRepository _repository;

  Future<PendingCallData?> call() => _repository.refreshPendingCall();
}
