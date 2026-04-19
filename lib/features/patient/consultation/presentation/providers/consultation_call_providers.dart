import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/services/voip_call_service.dart';
import 'package:elajtech/features/patient/consultation/data/repositories/consultation_call_repository_impl.dart';
import 'package:elajtech/features/patient/consultation/domain/repositories/consultation_call_repository.dart';
import 'package:elajtech/features/patient/consultation/domain/usecases/check_pending_call_usecase.dart';
import 'package:elajtech/features/patient/consultation/domain/usecases/cleanup_after_call_usecase.dart';
import 'package:elajtech/features/patient/consultation/domain/usecases/update_call_join_state_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConsultationCallState {
  const ConsultationCallState({
    this.pendingCallData,
    this.isCleanupBlocked = false,
    this.isConnecting = false,
  });

  final PendingCallData? pendingCallData;
  final bool isCleanupBlocked;
  final bool isConnecting;

  ConsultationCallState copyWith({
    PendingCallData? pendingCallData,
    bool clearPendingCallData = false,
    bool? isCleanupBlocked,
    bool? isConnecting,
  }) {
    return ConsultationCallState(
      pendingCallData: clearPendingCallData
          ? null
          : (pendingCallData ?? this.pendingCallData),
      isCleanupBlocked: isCleanupBlocked ?? this.isCleanupBlocked,
      isConnecting: isConnecting ?? this.isConnecting,
    );
  }
}

final consultationCallRepositoryProvider = Provider<ConsultationCallRepository>(
  (ref) {
    return ConsultationCallRepositoryImpl(getIt<VoIPCallService>());
  },
);

final checkPendingCallUseCaseProvider = Provider<CheckPendingCallUseCase>((
  ref,
) {
  return CheckPendingCallUseCase(ref.read(consultationCallRepositoryProvider));
});

final cleanupAfterCallUseCaseProvider = Provider<CleanupAfterCallUseCase>((
  ref,
) {
  return CleanupAfterCallUseCase(ref.read(consultationCallRepositoryProvider));
});

final updateCallJoinStateUseCaseProvider = Provider<UpdateCallJoinStateUseCase>(
  (ref) {
    return UpdateCallJoinStateUseCase(
      ref.read(consultationCallRepositoryProvider),
    );
  },
);

class ConsultationCallController extends StateNotifier<ConsultationCallState> {
  ConsultationCallController(
    this._checkPendingCall,
    this._cleanupAfterCall,
    this._updateJoinState,
    this._repository,
  ) : super(
        ConsultationCallState(
          pendingCallData: _repository.pendingCallData,
          isCleanupBlocked: _repository.isCleanupBlocked,
          isConnecting: _repository.isCleanupBlocked,
        ),
      );

  final CheckPendingCallUseCase _checkPendingCall;
  final CleanupAfterCallUseCase _cleanupAfterCall;
  final UpdateCallJoinStateUseCase _updateJoinState;
  final ConsultationCallRepository _repository;

  Future<void> refreshPendingCall() async {
    final pending = await _checkPendingCall();
    state = state.copyWith(
      pendingCallData: pending,
      isCleanupBlocked: _repository.isCleanupBlocked,
      isConnecting: _repository.isCleanupBlocked,
    );
  }

  Future<String?> cleanupOnResume() async {
    final appointmentId = await _cleanupAfterCall();
    state = state.copyWith(
      pendingCallData: _repository.pendingCallData,
      isCleanupBlocked: _repository.isCleanupBlocked,
      isConnecting: _repository.isCleanupBlocked,
    );
    return appointmentId;
  }

  void markJoinStarted() {
    _updateJoinState.markJoinStarted();
    state = state.copyWith(
      isCleanupBlocked: _repository.isCleanupBlocked,
      isConnecting: true,
    );
  }

  void markJoinSucceeded() {
    _updateJoinState.markJoinSucceeded();
    state = state.copyWith(
      isCleanupBlocked: _repository.isCleanupBlocked,
      isConnecting: false,
    );
  }

  void markJoinFailed() {
    _updateJoinState.markJoinFailed();
    state = state.copyWith(
      isCleanupBlocked: _repository.isCleanupBlocked,
      isConnecting: false,
    );
  }

  void markCallEnded() {
    _updateJoinState.markCallEnded();
    state = state.copyWith(
      isCleanupBlocked: _repository.isCleanupBlocked,
      isConnecting: false,
    );
  }
}

final consultationCallControllerProvider =
    StateNotifierProvider<ConsultationCallController, ConsultationCallState>((
      ref,
    ) {
      return ConsultationCallController(
        ref.read(checkPendingCallUseCaseProvider),
        ref.read(cleanupAfterCallUseCaseProvider),
        ref.read(updateCallJoinStateUseCaseProvider),
        ref.read(consultationCallRepositoryProvider),
      );
    });
