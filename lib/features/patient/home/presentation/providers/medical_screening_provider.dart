import 'package:elajtech/features/patient/home/data/models/medical_screening_model.dart';
import 'package:elajtech/features/patient/home/domain/repositories/medical_screening_repository.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

class MedicalScreeningState {
  const MedicalScreeningState({
    this.isLoading = false,
    this.model,
    this.isEditMode = true,
    this.error,
    this.isSuccess = false,
  });
  final bool isLoading;
  final MedicalScreeningModel? model;
  final bool isEditMode;
  final Failure? error;
  final bool isSuccess;

  MedicalScreeningState copyWith({
    bool? isLoading,
    MedicalScreeningModel? model,
    bool? isEditMode,
    Failure? error,
    bool? isSuccess,
  }) {
    return MedicalScreeningState(
      isLoading: isLoading ?? this.isLoading,
      model: model ?? this.model,
      isEditMode: isEditMode ?? this.isEditMode,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class MedicalScreeningNotifier extends StateNotifier<MedicalScreeningState> {
  MedicalScreeningNotifier(this._repository)
    : super(const MedicalScreeningState());
  final MedicalScreeningRepository _repository;

  Future<void> loadData(String patientId) async {
    state = state.copyWith(isLoading: true, isSuccess: false);

    final result = await _repository.getMedicalScreening(patientId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
        );
      },
      (data) {
        if (data != null) {
          state = state.copyWith(
            isLoading: false,
            model: data,
            isEditMode: false,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            model: const MedicalScreeningModel(),
            isEditMode: true,
          );
        }
      },
    );
  }

  Future<void> saveData(String patientId, MedicalScreeningModel data) async {
    state = state.copyWith(isLoading: true, isSuccess: false);

    final result = await _repository.saveMedicalScreening(patientId, data);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
        );
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          model: data,
          isEditMode: false,
          isSuccess: true,
        );
      },
    );
  }

  void toggleEditMode() {
    state = state.copyWith(
      isEditMode: !state.isEditMode,
      isSuccess: false,
    );
  }
}

final AutoDisposeStateNotifierProvider<
  MedicalScreeningNotifier,
  MedicalScreeningState
>
medicalScreeningProvider =
    StateNotifierProvider.autoDispose<
      MedicalScreeningNotifier,
      MedicalScreeningState
    >((ref) {
      return MedicalScreeningNotifier(GetIt.I<MedicalScreeningRepository>());
    });
