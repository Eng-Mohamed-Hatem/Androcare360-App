import 'package:dartz/dartz.dart';
import 'package:elajtech/core/data/repositories/admin_approval_repository.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/domain/entities/pending_doctor_list_item.dart';
import 'package:elajtech/core/domain/usecases/approve_doctor_usecase.dart';
import 'package:elajtech/core/domain/usecases/reject_doctor_usecase.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// مزود إدارة مراجعة واعتماد الأطباء المعلقين للمسؤول.
///
/// Admin approval state manager for pending doctor review actions.
///
/// This provider loads pending doctors, validates that the current user is an
/// admin before performing approve/reject actions, and exposes loading/error
/// state for the admin approval screen.
///
/// **Usage Example:**
/// ```dart
/// final state = ref.watch(adminApprovalProvider);
/// await ref.read(adminApprovalProvider.notifier).loadPendingDoctors();
/// ```
class AdminApprovalNotifier extends StateNotifier<AdminApprovalState> {
  AdminApprovalNotifier(
    this._ref,
    this._repository,
    this._approveDoctorUseCase,
    this._rejectDoctorUseCase,
  ) : super(const AdminApprovalState());

  final Ref _ref;
  final AdminApprovalRepository _repository;
  final ApproveDoctorUseCase _approveDoctorUseCase;
  final RejectDoctorUseCase _rejectDoctorUseCase;

  UserModel? get _currentUser => _ref.read(authProvider).user;

  bool _ensureAdminAccess() {
    final user = _currentUser;
    final isAllowed = user != null && user.userType == UserType.admin;

    if (!isAllowed) {
      state = state.copyWith(
        isLoading: false,
        isActionLoading: false,
        error: 'غير مصرح لك بالوصول إلى مراجعات الأطباء.',
        clearSuccess: true,
      );
    }

    return isAllowed;
  }

  Future<void> loadPendingDoctors() async {
    if (!_ensureAdminAccess()) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _repository.getPendingDoctors();
    _handleDoctorsResult(result);
  }

  Future<bool> approveDoctor(PendingDoctorListItem doctor) async {
    if (!_ensureAdminAccess()) {
      return false;
    }

    if (kDebugMode) {
      final admin = _currentUser;
      debugPrint(
        '[AdminApprovalNotifier] approveDoctor adminId=${admin?.id} '
        'doctorId=${doctor.doctorId}',
      );
    }

    final admin = _currentUser;
    if (admin == null) {
      return false;
    }

    state = state.copyWith(
      isActionLoading: true,
      activeDoctorId: doctor.doctorId,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _approveDoctorUseCase(
      doctorId: doctor.doctorId,
      adminId: admin.id,
      adminName: admin.fullName,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
          isActionLoading: false,
          activeDoctorId: null,
          error: failure.message,
          clearSuccess: true,
        );
        return false;
      },
      (actionResult) {
        final updatedDoctors = actionResult.shouldRemoveFromPending
            ? state.pendingDoctors
                  .where((item) => item.doctorId != doctor.doctorId)
                  .toList(growable: false)
            : state.pendingDoctors;

        state = state.copyWith(
          pendingDoctors: updatedDoctors,
          isActionLoading: false,
          activeDoctorId: null,
          successMessage: actionResult.message,
          clearError: true,
        );
        return actionResult.isSuccess;
      },
    );
  }

  Future<bool> rejectDoctor(PendingDoctorListItem doctor) async {
    if (!_ensureAdminAccess()) {
      return false;
    }

    if (kDebugMode) {
      final admin = _currentUser;
      debugPrint(
        '[AdminApprovalNotifier] rejectDoctor adminId=${admin?.id} '
        'doctorId=${doctor.doctorId}',
      );
    }

    final admin = _currentUser;
    if (admin == null) {
      return false;
    }

    state = state.copyWith(
      isActionLoading: true,
      activeDoctorId: doctor.doctorId,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _rejectDoctorUseCase(
      doctorId: doctor.doctorId,
      adminId: admin.id,
      adminName: admin.fullName,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
          isActionLoading: false,
          activeDoctorId: null,
          error: failure.message,
          clearSuccess: true,
        );
        return false;
      },
      (actionResult) {
        final updatedDoctors = actionResult.shouldRemoveFromPending
            ? state.pendingDoctors
                  .where((item) => item.doctorId != doctor.doctorId)
                  .toList(growable: false)
            : state.pendingDoctors;

        state = state.copyWith(
          pendingDoctors: updatedDoctors,
          isActionLoading: false,
          activeDoctorId: null,
          successMessage: actionResult.message,
          clearError: true,
        );
        return actionResult.isSuccess;
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  void _handleDoctorsResult(
    Either<Failure, List<PendingDoctorListItem>> result,
  ) {
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          clearSuccess: true,
        );
      },
      (doctors) {
        state = state.copyWith(
          pendingDoctors: doctors,
          isLoading: false,
          clearError: true,
        );
      },
    );
  }
}

/// حالة شاشة مراجعة الأطباء المعلقين.
///
/// State holder for pending-doctor review UI.
class AdminApprovalState {
  const AdminApprovalState({
    this.pendingDoctors = const <PendingDoctorListItem>[],
    this.isLoading = false,
    this.isActionLoading = false,
    this.activeDoctorId,
    this.error,
    this.successMessage,
  });
  static const Object _sentinel = Object();

  final List<PendingDoctorListItem> pendingDoctors;
  final bool isLoading;
  final bool isActionLoading;
  final String? activeDoctorId;
  final String? error;
  final String? successMessage;

  AdminApprovalState copyWith({
    List<PendingDoctorListItem>? pendingDoctors,
    bool? isLoading,
    bool? isActionLoading,
    Object? activeDoctorId = _sentinel,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminApprovalState(
      pendingDoctors: pendingDoctors ?? this.pendingDoctors,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      activeDoctorId: identical(activeDoctorId, _sentinel)
          ? this.activeDoctorId
          : activeDoctorId as String?,
      error: clearError ? null : error ?? this.error,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}

final adminApprovalRepositoryProvider = Provider<AdminApprovalRepository>((
  ref,
) {
  return getIt<AdminApprovalRepository>();
});

final approveDoctorUseCaseProvider = Provider<ApproveDoctorUseCase>((ref) {
  return getIt<ApproveDoctorUseCase>();
});

final rejectDoctorUseCaseProvider = Provider<RejectDoctorUseCase>((ref) {
  return getIt<RejectDoctorUseCase>();
});

/// مزود Riverpod لإدارة مراجعة الأطباء من قبل المسؤول.
///
/// Riverpod provider for admin approval state and actions.
final AutoDisposeStateNotifierProvider<
  AdminApprovalNotifier,
  AdminApprovalState
>
adminApprovalProvider =
    StateNotifierProvider.autoDispose<
      AdminApprovalNotifier,
      AdminApprovalState
    >(
      (ref) {
        return AdminApprovalNotifier(
          ref,
          ref.watch(adminApprovalRepositoryProvider),
          ref.watch(approveDoctorUseCaseProvider),
          ref.watch(rejectDoctorUseCaseProvider),
        );
      },
    );
