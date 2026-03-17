import 'package:elajtech/features/doctor/medical_records/data/repositories/physiotherapy_emr_repository.dart';
import 'package:elajtech/features/doctor/medical_records/domain/entities/physiotherapy_emr.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// Provider for PhysiotherapyEMRRepository
final physiotherapyEMRRepositoryProvider = Provider<PhysiotherapyEMRRepository>(
  (ref) => GetIt.I<PhysiotherapyEMRRepository>(),
);

/// State for Physiotherapy EMR form
class PhysiotherapyEMRState {
  const PhysiotherapyEMRState({
    this.emr,
    this.isLoading = false,
    this.error,
    this.isSaved = false,
    this.isViewMode = false,
  });

  final PhysiotherapyEMR? emr;
  final bool isLoading;
  final String? error;
  final bool isSaved;
  final bool isViewMode;

  PhysiotherapyEMRState copyWith({
    PhysiotherapyEMR? emr,
    bool? isLoading,
    String? error,
    bool? isSaved,
    bool? isViewMode,
  }) {
    return PhysiotherapyEMRState(
      emr: emr ?? this.emr,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSaved: isSaved ?? this.isSaved,
      isViewMode: isViewMode ?? this.isViewMode,
    );
  }
}

/// StateNotifier for managing Physiotherapy EMR state
class PhysiotherapyEMRNotifier extends StateNotifier<PhysiotherapyEMRState> {
  PhysiotherapyEMRNotifier(this._repository)
    : super(const PhysiotherapyEMRState());

  final PhysiotherapyEMRRepository _repository;

  /// Update checkbox selection for a specific section
  void updateCheckboxSelection({
    required String section,
    required String key,
    required String value,
    required bool isSelected,
  }) {
    if (state.emr == null) return;

    // Get the current section map
    Map<String, List<String>> sectionMap;
    switch (section) {
      case 'basics':
        sectionMap = Map<String, List<String>>.from(state.emr!.basics);
      case 'painAssessment':
        sectionMap = Map<String, List<String>>.from(state.emr!.painAssessment);
      case 'functionalAssessment':
        sectionMap = Map<String, List<String>>.from(
          state.emr!.functionalAssessment,
        );
      case 'systemsReview':
        sectionMap = Map<String, List<String>>.from(state.emr!.systemsReview);
      case 'rangeOfMotion':
        sectionMap = Map<String, List<String>>.from(state.emr!.rangeOfMotion);
      case 'strengthAssessment':
        sectionMap = Map<String, List<String>>.from(
          state.emr!.strengthAssessment,
        );
      case 'devicesEquipment':
        sectionMap = Map<String, List<String>>.from(
          state.emr!.devicesEquipment,
        );
      case 'treatmentPlan':
        sectionMap = Map<String, List<String>>.from(state.emr!.treatmentPlan);
      default:
        return;
    }

    // Update the selection
    final currentList = List<String>.from(sectionMap[key] ?? <String>[]);
    if (isSelected) {
      if (!currentList.contains(value)) {
        currentList.add(value);
      }
    } else {
      currentList.remove(value);
    }
    sectionMap[key] = currentList;

    // Create updated EMR
    PhysiotherapyEMR updatedEMR;
    switch (section) {
      case 'basics':
        updatedEMR = state.emr!.copyWith(basics: sectionMap);
      case 'painAssessment':
        updatedEMR = state.emr!.copyWith(painAssessment: sectionMap);
      case 'functionalAssessment':
        updatedEMR = state.emr!.copyWith(functionalAssessment: sectionMap);
      case 'systemsReview':
        updatedEMR = state.emr!.copyWith(systemsReview: sectionMap);
      case 'rangeOfMotion':
        updatedEMR = state.emr!.copyWith(rangeOfMotion: sectionMap);
      case 'strengthAssessment':
        updatedEMR = state.emr!.copyWith(strengthAssessment: sectionMap);
      case 'devicesEquipment':
        updatedEMR = state.emr!.copyWith(devicesEquipment: sectionMap);
      case 'treatmentPlan':
        updatedEMR = state.emr!.copyWith(treatmentPlan: sectionMap);
      default:
        return;
    }

    state = state.copyWith(emr: updatedEMR);
  }

  /// Update text field value
  void updateTextField({
    required String field,
    required String value,
  }) {
    if (state.emr == null) return;

    PhysiotherapyEMR updatedEMR;
    switch (field) {
      case 'primaryDiagnosis':
        updatedEMR = state.emr!.copyWith(primaryDiagnosis: value);
      case 'managementPlan':
        updatedEMR = state.emr!.copyWith(managementPlan: value);
      default:
        return;
    }

    state = state.copyWith(emr: updatedEMR);
  }

  /// Initialize EMR with empty data
  void initializeEMR({
    required String id,
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String appointmentId,
    required DateTime visitDate,
  }) {
    final emr = PhysiotherapyEMR(
      id: id,
      patientId: patientId,
      doctorId: doctorId,
      doctorName: doctorName,
      appointmentId: appointmentId,
      visitDate: visitDate,
      createdAt: DateTime.now(),
      basics: <String, List<String>>{},
      painAssessment: <String, List<String>>{},
      functionalAssessment: <String, List<String>>{},
      systemsReview: <String, List<String>>{},
      rangeOfMotion: <String, List<String>>{},
      strengthAssessment: <String, List<String>>{},
      devicesEquipment: <String, List<String>>{},
      treatmentPlan: <String, List<String>>{},
    );

    state = state.copyWith(emr: emr);
  }

  /// Load existing EMR by appointment ID
  Future<void> loadEMRByAppointment(String appointmentId) async {
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('📥 [PhysioEMRProvider] Loading EMR by Appointment');
      debugPrint('   Appointment ID: $appointmentId');
      debugPrint('═══════════════════════════════════════');
    }

    state = state.copyWith(isLoading: true);

    final result = await _repository.getPhysiotherapyEMRByVisit(appointmentId);

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('❌ [PhysioEMRProvider] Load failed: ${failure.message}');
        }
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (emr) {
        if (kDebugMode) {
          if (emr != null) {
            debugPrint('✅ [PhysioEMRProvider] EMR loaded successfully');
            debugPrint('   EMR ID: ${emr.id}');
            debugPrint('   Visit Date: ${emr.visitDate}');
            debugPrint('   Basics: ${emr.basics}');
            debugPrint('   Pain Assessment: ${emr.painAssessment}');
            debugPrint('   Functional Assessment: ${emr.functionalAssessment}');
          } else {
            debugPrint(
              'ℹ️ [PhysioEMRProvider] No EMR found for this appointment',
            );
          }
        }
        state = state.copyWith(
          isLoading: false,
          emr: emr,
        );
      },
    );
  }

  /// Save EMR (create or update)
  Future<void> saveEMR() async {
    if (state.emr == null) {
      state = state.copyWith(error: 'No EMR data to save');
      return;
    }

    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('💾 [PhysioEMRProvider] Starting Save Operation');
      debugPrint('   User ID: ${state.emr?.doctorId}');
      debugPrint('   Patient ID: ${state.emr?.patientId}');
      debugPrint('   Appointment ID: ${state.emr?.appointmentId}');
      debugPrint('   Basics: ${state.emr?.basics}');
      debugPrint('   Pain Assessment: ${state.emr?.painAssessment}');
      debugPrint(
        '   Functional Assessment: ${state.emr?.functionalAssessment}',
      );
      debugPrint('═══════════════════════════════════════');
    }

    state = state.copyWith(isLoading: true);

    // Try to create (will fail if exists, then update)
    final result = await _repository.createPhysiotherapyEMR(state.emr!);

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('❌ [PhysioEMRProvider] Save failed: ${failure.message}');
        }
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (_) {
        if (kDebugMode) {
          debugPrint('✅ [PhysioEMRProvider] Saved successfully');
          debugPrint('   Switching to View Mode...');
        }
        state = state.copyWith(
          isLoading: false,
          isSaved: true,
          isViewMode: true, // Activate view mode after successful save
        );
      },
    );
  }

  /// Reset state
  void reset() {
    state = const PhysiotherapyEMRState();
  }

  /// Set view mode (Edit Mode vs View Mode)
  ///
  /// When value is true, displays read-only summary
  /// When value is false, displays full edit form
  void setViewMode({required bool value}) {
    if (kDebugMode) {
      debugPrint('[PhysioEMRProvider] setViewMode: $value');
    }
    state = state.copyWith(isViewMode: value);
  }
}

/// Provider for PhysiotherapyEMRNotifier
final physiotherapyEMRNotifierProvider =
    StateNotifierProvider<PhysiotherapyEMRNotifier, PhysiotherapyEMRState>(
      (ref) {
        final repository = ref.watch(physiotherapyEMRRepositoryProvider);
        return PhysiotherapyEMRNotifier(repository);
      },
    );
