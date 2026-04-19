import 'package:elajtech/core/services/voip_call_service.dart';
import 'package:elajtech/features/patient/consultation/domain/repositories/consultation_call_repository.dart';

class ConsultationCallRepositoryImpl implements ConsultationCallRepository {
  ConsultationCallRepositoryImpl(this._voipCallService);

  final VoIPCallService _voipCallService;

  @override
  PendingCallData? get pendingCallData => _voipCallService.pendingCallData;

  @override
  bool get isCleanupBlocked => _voipCallService.isCleanupBlocked;

  @override
  Future<PendingCallData?> refreshPendingCall() =>
      _voipCallService.refreshPendingCallData();

  @override
  Future<String?> cleanupAfterCall() => _voipCallService.cleanupAfterCall();

  @override
  void markAnswerAccepted() => _voipCallService.markAnswerAccepted();

  @override
  void markJoinStarted() => _voipCallService.markJoinStarted();

  @override
  void markJoinSucceeded() => _voipCallService.markJoinSucceeded();

  @override
  void markJoinFailed() => _voipCallService.markJoinFailed();

  @override
  void markCallEnded() => _voipCallService.markCallEnded();
}
