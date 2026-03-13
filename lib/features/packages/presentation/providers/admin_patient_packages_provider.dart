import 'dart:async';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_document_entity.dart';
import 'package:elajtech/features/packages/domain/repositories/package_document_repository.dart';
import 'package:elajtech/features/packages/domain/repositories/patient_package_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/get_patient_packages_for_admin_usecase.dart';
import 'package:elajtech/features/packages/domain/usecases/upload_package_document_usecase.dart';
import 'package:elajtech/features/packages/domain/usecases/update_package_service_usage_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Admin Patient Packages List Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Manages the list of packages purchased by a specific patient.
/// Used in the Admin Patient Packages screen.
class AdminPatientPackagesNotifier
    extends FamilyAsyncNotifier<List<PatientPackageEntity>, String> {
  @override
  Future<List<PatientPackageEntity>> build(String arg) async {
    final useCase = getIt<GetPatientPackagesForAdminUseCase>();
    final resultOr = await useCase(patientId: arg);

    return resultOr.fold(
      (failure) => throw Exception(failure.message),
      (packages) => packages,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Provider for loading the list of packages for a specific patient.
/// The parameter is the `patientId`.
final adminPatientPackagesProvider =
    AsyncNotifierProviderFamily<
      AdminPatientPackagesNotifier,
      List<PatientPackageEntity>,
      String
    >(
      AdminPatientPackagesNotifier.new,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Admin Patient Package Write Operations Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Manages write operations for a patient package from the admin dashboard.
/// Supports uploading documents and updating service usage.
class AdminPatientPackageWriteNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Uploads a document and associates it with a package (and optionally a service).
  Future<bool> uploadDocument({
    required String localFilePath,
    required String patientId,
    required String patientPackageId,
    required String packageId,
    required String clinicId,
    required DocumentType documentType,
    required String title,
    required String uploadedByUserId,
    required String uploadedByRole,
    String? serviceId,
    String? description,
  }) async {
    state = const AsyncLoading();
    final useCase = getIt<UploadPackageDocumentUseCase>();
    final result = await useCase(
      localFilePath: localFilePath,
      patientId: patientId,
      patientPackageId: patientPackageId,
      packageId: packageId,
      clinicId: clinicId,
      documentType: documentType,
      title: title,
      serviceId: serviceId,
      description: description,
      uploadedByUserId: uploadedByUserId,
      uploadedByRole: uploadedByRole,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        // Refresh the patient's packages list or document list if needed
        unawaited(
          ref.read(adminPatientPackagesProvider(patientId).notifier).refresh(),
        );
        return true;
      },
    );
  }

  /// Updates the usage count for a specific service in a patient's package.
  Future<bool> updateServiceUsage({
    required String patientId,
    required String patientPackageId,
    required String serviceId,
  }) async {
    state = const AsyncLoading();
    final useCase = getIt<UpdatePackageServiceUsageUseCase>();
    final result = await useCase(
      patientId: patientId,
      patientPackageId: patientPackageId,
      serviceId: serviceId,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        // Refresh the list to show updated progress
        unawaited(
          ref.read(adminPatientPackagesProvider(patientId).notifier).refresh(),
        );
        return true;
      },
    );
  }

  /// Updates the admin notes for a specific patient package.
  Future<bool> updateNotes({
    required String patientId,
    required String patientPackageId,
    required String notes,
  }) async {
    state = const AsyncLoading();
    final repo = getIt<PatientPackageRepository>();
    final result = await repo.updateNotes(
      patientId: patientId,
      patientPackageId: patientPackageId,
      notes: notes,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        // Refresh the list to reflect new notes
        unawaited(
          ref.read(adminPatientPackagesProvider(patientId).notifier).refresh(),
        );
        return true;
      },
    );
  }
}

/// Provider for write operations on a patient package.
final adminPatientPackageWriteProvider =
    NotifierProvider<AdminPatientPackageWriteNotifier, AsyncValue<void>>(
      AdminPatientPackageWriteNotifier.new,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Admin Package Documents Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Stream of documents for a specific patient package.
/// The parameter is a tuple: `(patientId, patientPackageId)`.
final StreamProviderFamily<List<PackageDocumentEntity>, (String, String)>
adminPackageDocumentsProvider =
    StreamProvider.family<List<PackageDocumentEntity>, (String, String)>(
      (ref, args) {
        final patientId = args.$1;
        final patientPackageId = args.$2;
        final repo = getIt<PackageDocumentRepository>();
        return repo.streamDocumentsByPatientPackage(
          patientId: patientId,
          patientPackageId: patientPackageId,
        );
      },
    );
