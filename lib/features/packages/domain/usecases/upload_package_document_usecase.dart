import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/notifications/domain/repositories/notification_repository.dart';
import 'dart:io';

import 'package:elajtech/features/packages/domain/entities/package_document_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_document_repository.dart';
import 'package:elajtech/shared/models/notification_model.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

/// UploadPackageDocumentUseCase
///
/// **English**: Uploads a medical document to a patient package and sends a notification.
/// Delegates upload to [PackageDocumentRepository] which handles storage and Firestore.
/// After successful upload, it sends a best-effort FCM notification via [NotificationRepository].
@lazySingleton
class UploadPackageDocumentUseCase {
  UploadPackageDocumentUseCase(
    this._documentRepository,
    this._notificationRepository,
  );
  final PackageDocumentRepository _documentRepository;
  final NotificationRepository _notificationRepository;
  final _uuid = const Uuid();

  Future<Either<Failure, PackageDocumentEntity>> call({
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
    // 1. Validate file extension
    final lowercasePath = localFilePath.toLowerCase();
    if (!lowercasePath.endsWith('.pdf') &&
        !lowercasePath.endsWith('.jpg') &&
        !lowercasePath.endsWith('.jpeg') &&
        !lowercasePath.endsWith('.png')) {
      return const Left(
        UploadFailure('Unsupported file type. Allowed: pdf, jpg, jpeg, png.'),
      );
    }

    // 2. Validate file size (<= 20 MB)
    try {
      final file = File(localFilePath);
      if (file.existsSync()) {
        final fileSize = file.lengthSync();
        final sizeInMb = fileSize / (1024 * 1024);
        if (sizeInMb > 20) {
          return const Left(
            UploadFailure('File size exceeds the 20 MB limit.'),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[UploadPackageDocumentUseCase] File length check failed: $e',
        );
      }
    }

    // 3. Delegate upload to repository (which uses the datasources)
    final result = await _documentRepository.uploadDocument(
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

    // If successful, send best-effort FCM notification
    result.fold(
      (failure) {
        // Do nothing on failure
      },
      (document) async {
        try {
          final notification = NotificationModel(
            id: _uuid.v4(),
            userId: patientId,
            title: 'تم رفع مستند جديد',
            body: 'تم رفع مستند جديد بعنوان "$title" كجزء من باقتك.',
            type: NotificationType.general,
            createdAt: DateTime.now(),
            data: {
              'patientPackageId': patientPackageId,
              'documentId': document.id,
            },
          );

          final notifResult = await _notificationRepository.saveNotification(
            notification,
          );

          if (kDebugMode) {
            notifResult.fold(
              (f) => debugPrint(
                '[UploadPackageDocumentUseCase] Best-effort notification failed: ${f.message}',
              ),
              (_) => debugPrint(
                '[UploadPackageDocumentUseCase] Best-effort notification saved successfully.',
              ),
            );
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '[UploadPackageDocumentUseCase] Unexpected error sending notification: $e',
            );
          }
        }
      },
    );

    return result;
  }
}
