/// PackageDocumentRepositoryImpl — تطبيق مستودع مستندات الباقة
///
/// يُنفِّذ [PackageDocumentRepository] ويُفوِّض العمليات إلى كلٍّ من
/// [FirestorePackageDatasource] و[FirebaseStoragePackageDatasource] (R5).
///
/// **English**: Data-layer implementation of [PackageDocumentRepository] (T023).
/// Injects two separate datasources per R5 (SRP):
/// - [FirestorePackageDatasource] for metadata CRUD.
/// - [FirebaseStoragePackageDatasource] for file upload.
///
/// Annotated `@LazySingleton(as: PackageDocumentRepository)`.
///
/// **Spec**: tasks.md T023, plan.md §PackageDocumentRepositoryImpl (R5).
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/data/datasources/firebase_storage_package_datasource.dart';
import 'package:elajtech/features/packages/data/datasources/firestore_package_datasource.dart';
import 'package:elajtech/features/packages/data/models/package_document_model.dart';
import 'package:elajtech/features/packages/domain/entities/package_document_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_document_repository.dart';
import 'package:uuid/uuid.dart';

/// Concrete implementation of [PackageDocumentRepository].
///
/// **English**
/// Combines [FirestorePackageDatasource] (metadata) and
/// [FirebaseStoragePackageDatasource] (file operations) per R5.
/// [uploadDocument] follows the 2-step pattern:
/// 1. Upload file → get download URL.
/// 2. Create Firestore metadata record.
///
/// **Arabic**
/// يجمع مصدرَي البيانات: Firestore للبيانات الواصفة، وStorage للملفات (R5).
/// [uploadDocument] يُنفِّذ الرفع أولًا ثم ينشئ سجل Firestore.
@LazySingleton(as: PackageDocumentRepository)
class PackageDocumentRepositoryImpl implements PackageDocumentRepository {
  /// Creates a [PackageDocumentRepositoryImpl] with both injected datasources.
  ///
  /// يُنشئ التطبيق مع مصدرَي البيانات المُحقَنَيْن.
  const PackageDocumentRepositoryImpl(
    this._firestoreDatasource,
    this._storageDatasource,
  );

  final FirestorePackageDatasource _firestoreDatasource;
  final FirebaseStoragePackageDatasource _storageDatasource;

  final _uuid = const Uuid();

  @override
  Stream<List<PackageDocumentEntity>> streamDocumentsByPatientPackage({
    required String patientId,
    required String patientPackageId,
  }) {
    return _firestoreDatasource
        .streamDocumentsByPatientPackage(
          patientId: patientId,
          patientPackageId: patientPackageId,
        )
        .map(
          (snapshot) => snapshot.docs
              .map(PackageDocumentModel.fromFirestore)
              .whereType<PackageDocumentModel>()
              .toList(),
        );
  }

  @override
  Future<Either<Failure, List<PackageDocumentEntity>>>
  getDocumentsByPatientPackage({
    required String patientId,
    required String patientPackageId,
  }) async {
    try {
      final snapshot = await _firestoreDatasource
          .fetchDocumentsByPatientPackage(
            patientId: patientId,
            patientPackageId: patientPackageId,
          );

      final docs = snapshot.docs
          .map(PackageDocumentModel.fromFirestore)
          .whereType<PackageDocumentModel>()
          .toList();

      if (kDebugMode) {
        debugPrint(
          '[PackageDocumentRepositoryImpl] getDocumentsByPatientPackage '
          'patientId=$patientId ppId=$patientPackageId found=${docs.length}',
        );
      }

      return Right(docs);
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          '[PackageDocumentRepositoryImpl] getDocuments error: $e',
        );
        debugPrint(st.toString());
      }
      return Left(NetworkFailure(e.message ?? 'خطأ في الشبكة'));
    } on Exception catch (e, st) {
      if (kDebugMode) {
        debugPrint('[PackageDocumentRepositoryImpl] Unexpected: $e');
        debugPrint(st.toString());
      }
      return const Left(NetworkFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, PackageDocumentEntity>> uploadDocument({
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
    // Generate stable document ID for the Storage path
    final documentId = _uuid.v4();
    final filename = localFilePath.split(RegExp(r'[/\\]')).last;

    if (kDebugMode) {
      debugPrint(
        '[PackageDocumentRepositoryImpl] uploadDocument '
        'patientId=$patientId ppId=$patientPackageId '
        'clinicId=$clinicId type=${documentType.value} docId=$documentId '
        'userId=$uploadedByUserId',
      );
    }

    // Step 1: Upload file to Storage
    final uploadResult = await _storageDatasource.uploadDocument(
      localFilePath: localFilePath,
      clinicId: clinicId,
      patientId: patientId,
      patientPackageId: patientPackageId,
      documentId: documentId,
      filename: filename,
    );

    return uploadResult.fold(
      // Upload failed — propagate UploadFailure
      (failure) {
        if (kDebugMode) {
          debugPrint(
            '[PackageDocumentRepositoryImpl] Storage upload failed: ${failure.message}',
          );
        }
        return Left(failure);
      },
      // Step 2: Create Firestore metadata record
      (downloadUrl) async {
        try {
          final now = DateTime.now();
          final docData = PackageDocumentModel(
            id: documentId,
            patientId: patientId,
            patientPackageId: patientPackageId,
            packageId: packageId,
            clinicId: clinicId,
            documentType: documentType,
            title: title,
            description: description,
            fileUrl: downloadUrl,
            serviceId: serviceId,
            uploadedByUserId: uploadedByUserId,
            uploadedByRole: uploadedByRole,
            uploadedAt: now,
          ).toFirestore();

          final ref = await _firestoreDatasource.createDocumentRecord(
            patientId: patientId,
            patientPackageId: patientPackageId,
            documentId: documentId,
            data: docData,
          );

          if (kDebugMode) {
            debugPrint(
              '[PackageDocumentRepositoryImpl] Firestore record created: ${ref.id}',
            );
          }

          return Right(
            PackageDocumentModel(
              id: ref.id,
              patientId: patientId,
              patientPackageId: patientPackageId,
              packageId: packageId,
              clinicId: clinicId,
              documentType: documentType,
              title: title,
              description: description,
              fileUrl: downloadUrl,
              serviceId: serviceId,
              uploadedByUserId: uploadedByUserId,
              uploadedByRole: uploadedByRole,
              uploadedAt: now,
            ),
          );
        } on FirebaseException catch (e, st) {
          if (kDebugMode) {
            debugPrint(
              '[PackageDocumentRepositoryImpl] Firestore create error: $e',
            );
            debugPrint(st.toString());
          }
          return Left(NetworkFailure(e.message ?? 'خطأ في الشبكة'));
        } on Exception catch (e, st) {
          if (kDebugMode) {
            debugPrint('[PackageDocumentRepositoryImpl] Unexpected: $e');
            debugPrint(st.toString());
          }
          return const Left(NetworkFailure('حدث خطأ غير متوقع'));
        }
      },
    );
  }
}
