import 'package:elajtech/core/services/voip_call_service.dart';

abstract class ConsultationCallRepository {
  PendingCallData? get pendingCallData;

  bool get isCleanupBlocked;

  Future<PendingCallData?> refreshPendingCall();

  Future<String?> cleanupAfterCall();

  void markAnswerAccepted();

  void markJoinStarted();

  void markJoinSucceeded();

  void markJoinFailed();

  void markCallEnded();
}
