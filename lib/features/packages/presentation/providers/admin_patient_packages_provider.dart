import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_document_entity.dart';
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
        ref.read(adminPatientPackagesProvider(patientId).notifier).refresh();
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
        ref.read(adminPatientPackagesProvider(patientId).notifier).refresh();
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
final adminPackageDocumentsProvider =
    StreamProvider.family<List<PackageDocumentEntity>, (String, String)>(
      (ref, args) {
        final patientId = args.$1;
        final patientPackageId = args.$2;

        return getIt<FirebaseFirestore>()
            .collection('patients')
            .doc(patientId)
            .collection('packages')
            .doc(patientPackageId)
            .collection('documents')
            .orderBy('uploadedAt', descending: true)
            .snapshots()
            .map((snapshot) {
              return snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                // In a real implementation we would parse data using PackageDocumentEntity.fromFirestore
                // but since we only have the raw entity, we will instantiate it manually here.
                // Assuming PackageDocumentEntity fromJson or fromFirestore exists, or we map it manually.
                return PackageDocumentEntity(
                  id: doc.id,
                  patientId: patientId,
                  patientPackageId: patientPackageId,
                  packageId: data['packageId'] as String? ?? '',
                  clinicId: data['clinicId'] as String? ?? '',
                  documentType: DocumentType.fromString(
                    data['documentType'] as String? ?? 'OTHER',
                  ),
                  title: data['title'] as String? ?? '',
                  fileUrl: data['fileUrl'] as String? ?? '',
                  uploadedByUserId: data['uploadedByUserId'] as String? ?? '',
                  uploadedByRole: data['uploadedByRole'] as String? ?? '',
                  uploadedAt: data['uploadedAt'] != null
                      ? (data['uploadedAt'] as Timestamp).toDate()
                      : DateTime.now(),
                  serviceId: data['serviceId'] as String?,
                  description: data['description'] as String?,
                );
              }).toList();
            });
      },
    );
