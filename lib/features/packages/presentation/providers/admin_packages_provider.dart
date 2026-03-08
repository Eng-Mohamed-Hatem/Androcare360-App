import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/features/packages/data/constants/clinic_ids.dart';
import 'package:elajtech/features/packages/data/repositories/clinic_package_repository_impl.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/create_clinic_package_usecase.dart';
import 'package:elajtech/features/packages/domain/usecases/duplicate_package_usecase.dart';
import 'package:elajtech/features/packages/domain/usecases/list_clinic_packages_for_admin_usecase.dart';
import 'package:elajtech/features/packages/domain/usecases/toggle_package_status_usecase.dart';
import 'package:elajtech/features/packages/domain/usecases/update_clinic_package_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Resolves the correct [PackageRepository] instance based on [clinicId].
/// This enforces the Clinic Isolation Rule (R4) by using distinct repositories.
PackageRepository getPackageRepositoryForClinic(String clinicId) {
  switch (clinicId) {
    case ClinicIds.andrology:
      return getIt<AndrologyPackageRepository>();
    case ClinicIds.physiotherapy:
      return getIt<PhysiotherapyPackageRepository>();
    case ClinicIds.internalFamily:
      return getIt<InternalFamilyPackageRepository>();
    case ClinicIds.nutrition:
      return getIt<NutritionPackageRepository>();
    case ClinicIds.chronicDiseases:
      return getIt<ChronicDiseasesPackageRepository>();
    default:
      throw Exception('Unrecognized clinicId: $clinicId');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Selected Clinic State
// ─────────────────────────────────────────────────────────────────────────────

/// Holds the currently selected clinic ID for the admin dashboard.
final adminSelectedClinicProvider = StateProvider<String?>((ref) => null);

// ─────────────────────────────────────────────────────────────────────────────
// Admin Packages List Notifier
// ─────────────────────────────────────────────────────────────────────────────

class AdminPackagesListNotifier extends AsyncNotifier<List<PackageEntity>> {
  @override
  Future<List<PackageEntity>> build() async {
    final clinicId = ref.watch(adminSelectedClinicProvider);
    if (clinicId == null) return [];

    final useCase = getIt<ListClinicPackagesForAdminUseCase>();
    final repo = getPackageRepositoryForClinic(clinicId);

    final params = ListClinicPackagesForAdminParams(
      clinicId: clinicId,
      limit: 100,
    );
    final resultOr = await useCase(repository: repo, params: params);

    return resultOr.fold(
      (failure) => throw Exception(failure.message),
      (list) => list,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Provider for loading the admin package list for the selected clinic.
final adminPackagesListProvider =
    AsyncNotifierProvider<AdminPackagesListNotifier, List<PackageEntity>>(
      AdminPackagesListNotifier.new,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Admin Write Operations Notifier (Create/Edit/Duplicate/Toggle)
// ─────────────────────────────────────────────────────────────────────────────

class AdminPackageWriteNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> createPackage(CreatePackageParams params) async {
    state = const AsyncLoading();
    final repo = getPackageRepositoryForClinic(params.clinicId);
    final useCase = getIt<CreateClinicPackageUseCase>();
    final result = await useCase(repository: repo, params: params);

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (id) {
        state = const AsyncData(null);
        ref.read(adminPackagesListProvider.notifier).refresh();
        return true;
      },
    );
  }

  Future<bool> updatePackage(UpdatePackageParams params) async {
    state = const AsyncLoading();
    final repo = getPackageRepositoryForClinic(params.clinicId);
    final useCase = getIt<UpdateClinicPackageUseCase>();
    final result = await useCase(repository: repo, params: params);

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.read(adminPackagesListProvider.notifier).refresh();
        return true;
      },
    );
  }

  Future<bool> toggleStatus({
    required String clinicId,
    required String packageId,
    required PackageStatus status,
  }) async {
    state = const AsyncLoading();
    final repo = getPackageRepositoryForClinic(clinicId);
    final useCase = getIt<TogglePackageStatusUseCase>();
    final result = await useCase(
      repository: repo,
      clinicId: clinicId,
      packageId: packageId,
      status: status,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.read(adminPackagesListProvider.notifier).refresh();
        return true;
      },
    );
  }

  Future<bool> duplicatePackage({
    required String clinicId,
    required String packageId,
  }) async {
    state = const AsyncLoading();
    final repo = getPackageRepositoryForClinic(clinicId);
    final useCase = getIt<DuplicatePackageUseCase>();
    final result = await useCase(
      repository: repo,
      clinicId: clinicId,
      packageId: packageId,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (newId) {
        state = const AsyncData(null);
        ref.read(adminPackagesListProvider.notifier).refresh();
        return true;
      },
    );
  }
}

/// Provider for creating, editing, duplicating, or toggling package status.
final adminPackageWriteProvider =
    NotifierProvider<AdminPackageWriteNotifier, AsyncValue<void>>(
      AdminPackageWriteNotifier.new,
    );
