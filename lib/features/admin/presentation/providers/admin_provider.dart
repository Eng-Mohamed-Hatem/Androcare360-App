import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/features/admin/domain/entities/audit_log.dart';
import 'package:elajtech/features/admin/domain/repositories/admin_repository.dart';
import 'package:elajtech/features/admin/domain/usecases/toggle_patient_active_status_usecase.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ───────────────────────────── State ─────────────────────────────────────────

/// Represents the current state of the admin panel.
class AdminState {
  const AdminState({
    this.doctors = const [],
    this.patients = const [],
    this.auditLogs = const [],
    this.emrHistory = const [],
    this.isLoading = false,
    this.isActionLoading = false,
    this.error,
    this.successMessage,
  });

  final List<UserModel> doctors;
  final List<UserModel> patients;
  final List<AuditLog> auditLogs;
  final List<Map<String, dynamic>> emrHistory;
  final bool isLoading;

  /// True only during mutations (deactivate, update profile, etc.)
  final bool isActionLoading;

  final String? error;
  final String? successMessage;

  AdminState copyWith({
    List<UserModel>? doctors,
    List<UserModel>? patients,
    List<AuditLog>? auditLogs,
    List<Map<String, dynamic>>? emrHistory,
    bool? isLoading,
    bool? isActionLoading,
    String? error,
    String? successMessage,
    // sentinel to explicitly clear nullable fields
    bool clearError = false,
    bool clearSuccess = false,
  }) => AdminState(
    doctors: doctors ?? this.doctors,
    patients: patients ?? this.patients,
    auditLogs: auditLogs ?? this.auditLogs,
    emrHistory: emrHistory ?? this.emrHistory,
    isLoading: isLoading ?? this.isLoading,
    isActionLoading: isActionLoading ?? this.isActionLoading,
    error: clearError ? null : error ?? this.error,
    successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
  );
}

// ───────────────────────────── Notifier ──────────────────────────────────────

/// StateNotifier managing all admin panel operations.
///
/// Accessed via [adminProvider]. Each method:
/// - Sets [isActionLoading] true before the async call.
/// - Writes either [error] or [successMessage] on completion.
/// - Always resets loading flags even on error.
class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier(this._repo, this._ref, this._togglePatientActiveStatus)
    : super(const AdminState());

  final AdminRepository _repo;
  final Ref _ref;
  final TogglePatientActiveStatusUseCase _togglePatientActiveStatus;

  // ———— helpers ————

  /// Returns the current admin user.
  ///
  /// Throws [StateError] if called without a signed-in admin.
  UserModel get _admin {
    final user = _ref.read(authProvider).user;
    if (user == null || user.userType != UserType.admin) {
      throw StateError('No admin user found');
    }
    return user;
  }

  void _handleResult<T>(
    Either<Failure, T> result, {
    required String successMsg,
    VoidCallback? onSuccess,
  }) {
    result.fold(
      (f) => state = state.copyWith(
        isActionLoading: false,
        isLoading: false,
        error: f.message,
        clearSuccess: true,
      ),
      (_) {
        state = state.copyWith(
          isActionLoading: false,
          isLoading: false,
          successMessage: successMsg,
          clearError: true,
        );
        onSuccess?.call();
      },
    );
  }

  // ———— Load lists ————

  /// Fetches all doctors from Firestore.
  Future<void> loadDoctors() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repo.getAllDoctors();
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (docs) => state = state.copyWith(isLoading: false, doctors: docs),
    );
  }

  /// Fetches all patients from Firestore.
  Future<void> loadPatients() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repo.getAllPatients();
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (patients) =>
          state = state.copyWith(isLoading: false, patients: patients),
    );
  }

  // ———— Doctor management ————

  /// Creates a new doctor account via Cloud Function.
  Future<void> createDoctor({
    required UserModel doctor,
    required String password,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final user = _ref.read(authProvider).user;
    if (user == null || user.userType != UserType.admin) {
      state = state.copyWith(
        isActionLoading: false,
        error: 'انتهت الجلسة، يرجى تسجيل الدخول مجدداً.',
      );
      return;
    }
    final result = await _repo.createDoctor(
      doctor: doctor,
      password: password,
      adminId: user.id,
      adminName: user.fullName,
    );
    _handleResult<Unit>(
      result,
      successMsg: 'تم إنشاء حساب الطبيب بنجاح',
      onSuccess: loadDoctors,
    );
  }

  /// Updates admin-managed doctor profile fields.
  Future<void> updateDoctorProfile({
    required UserModel updatedDoctor,
    required UserModel previousDoctor,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final user = _ref.read(authProvider).user;
    if (user == null || user.userType != UserType.admin) {
      state = state.copyWith(
        isActionLoading: false,
        error: 'انتهت الجلسة، يرجى تسجيل الدخول مجدداً.',
      );
      return;
    }
    final result = await _repo.updateDoctorProfile(
      updatedDoctor: updatedDoctor,
      previousDoctor: previousDoctor,
      adminId: user.id,
      adminName: user.fullName,
    );
    _handleResult<Unit>(
      result,
      successMsg: 'تم تحديث ملف الطبيب بنجاح',
      onSuccess: loadDoctors,
    );
  }

  // ———— Account status ————

  /// Deactivates or reactivates a user account.
  Future<void> setAccountStatus({
    required String targetUserId,
    required bool isActive,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final user = _ref.read(authProvider).user;
    if (user == null || user.userType != UserType.admin) {
      state = state.copyWith(
        isActionLoading: false,
        error: 'انتهت الجلسة، يرجى تسجيل الدخول مجدداً.',
      );
      return;
    }
    final result = await _togglePatientActiveStatus(
      targetUserId: targetUserId,
      isActive: isActive,
      adminId: user.id,
      adminName: user.fullName,
    );
    final action = isActive ? 'تفعيل' : 'تعطيل';
    _handleResult<Unit>(
      result,
      successMsg: 'تم $action الحساب بنجاح',
      // Refresh both lists so the UI badge updates immediately
      onSuccess: () {
        loadDoctors().ignore();
        loadPatients().ignore();
      },
    );
  }

  // ———— EMR ————

  /// Loads all EMR records for a specific patient (admin read-only).
  Future<void> loadPatientEmrHistory(String patientId) async {
    state = state.copyWith(isLoading: true, emrHistory: [], clearError: true);
    final result = await _repo.getPatientEmrHistory(patientId);
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (records) =>
          state = state.copyWith(isLoading: false, emrHistory: records),
    );
  }

  // ———— Messages ————

  /// Clears the current error message.
  void clearError() => state = state.copyWith(clearError: true);

  /// Clears the current success message.
  void clearSuccess() => state = state.copyWith(clearSuccess: true);
}

// ───────────────────────────── Providers ─────────────────────────────────────

/// Provides the [AdminRepository] implementation.
///
/// Override this in tests using [ProviderContainer] to inject a mock:
/// ```dart
/// ProviderContainer(overrides: [
///   adminRepositoryProvider.overrideWithValue(mockAdminRepo),
/// ]);
/// ```
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return getIt<AdminRepository>();
});

/// Provides [TogglePatientActiveStatusUseCase] for account activation toggles.
///
/// Uses [adminRepositoryProvider] so tests that override the repository
/// automatically get a matching use case without requiring GetIt registration.
final togglePatientActiveStatusUseCaseProvider =
    Provider<TogglePatientActiveStatusUseCase>((ref) {
      final repo = ref.watch(adminRepositoryProvider);
      return TogglePatientActiveStatusUseCase(repo);
    });

/// Main admin provider — exposes [AdminNotifier] and [AdminState].
final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  final togglePatientActiveStatus = ref.watch(
    togglePatientActiveStatusUseCaseProvider,
  );
  return AdminNotifier(repo, ref, togglePatientActiveStatus);
});

/// Streams audit logs in real time for display on the audit log screen.
final auditLogsStreamProvider = StreamProvider<List<AuditLog>>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.watchAuditLogs();
});
