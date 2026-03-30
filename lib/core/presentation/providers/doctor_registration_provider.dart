import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elajtech/core/domain/usecases/register_doctor_usecase.dart';
import 'package:elajtech/core/di/injection_container.dart';

/// Notifier for doctor registration
class DoctorRegistrationNotifier
    extends StateNotifier<DoctorRegistrationState> {
  DoctorRegistrationNotifier(this._registerDoctorUseCase)
    : super(const DoctorRegistrationState());
  final RegisterDoctorUseCase _registerDoctorUseCase;

  Future<void> registerDoctor({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String specialty,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await _registerDoctorUseCase(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      specialty: specialty,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
        );
      },
    );
  }
}

/// State for doctor registration
class DoctorRegistrationState {
  const DoctorRegistrationState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  DoctorRegistrationState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return DoctorRegistrationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  String toString() =>
      'DoctorRegistrationState(isLoading: $isLoading, error: $error, isSuccess: $isSuccess)';
}

/// Provider wrapper for doctor registration state
///
/// **Arabic**: مزود حالة تسجيل الأطباء
/// **English**: Provider for doctor registration state management
final AutoDisposeStateNotifierProvider<
  DoctorRegistrationNotifier,
  DoctorRegistrationState
>
doctorRegistrationProvider =
    StateNotifierProvider.autoDispose<
      DoctorRegistrationNotifier,
      DoctorRegistrationState
    >((ref) {
      return DoctorRegistrationNotifier(
        ref.watch(registerDoctorUseCaseProvider),
      );
    });

final registerDoctorUseCaseProvider = Provider<RegisterDoctorUseCase>((ref) {
  return getIt<RegisterDoctorUseCase>();
});
