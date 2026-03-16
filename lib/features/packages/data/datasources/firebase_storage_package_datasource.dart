/// FirebaseStoragePackageDatasource — مصدر بيانات Storage للباقات (Data Layer)
///
/// يُنفِّذ عمليات رفع وتحميل الملفات في Firebase Storage فقط.
/// **لا يحتوي على أي منطق Firestore** — ذلك مفصول في [FirestorePackageDatasource].
///
/// **English**: Data-layer Storage datasource (R5 — SRP). Handles only
/// Firebase Storage upload/download for package-linked documents.
/// Storage path pattern: `packageDocuments/{clinicId}/{patientId}/
/// {patientPackageId}/{documentId}/{filename}`
///
/// File validation rules:
/// - Max size: 20 MB
/// - Allowed types: pdf, jpg, jpeg, png
///
/// **Spec**: tasks.md T016b, plan.md §Datasource split (R5).
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:elajtech/features/packages/data/datasources/firestore_package_datasource.dart'
    show FirestorePackageDatasource;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';

/// Firebase Storage-only datasource for package document uploads.
///
/// **English**
/// Annotated `@lazySingleton`. Injected `FirebaseStorage` is the project's
/// default bucket.
///
/// Single public method [uploadDocument] validates the file, uploads it to
/// Storage, and returns the download URL on success.
///
/// **Arabic**
/// مصدر بيانات Storage حصرًا. يُحقَن تلقائيًا عبر GetIt.
/// الأسلوب الوحيد [uploadDocument] يتحقق من الملف ويرفعه ويُعيد رابط التحميل.
@lazySingleton
class FirebaseStoragePackageDatasource {
  /// Creates a [FirebaseStoragePackageDatasource] with the injected Storage.
  ///
  /// يُنشئ مصدر البيانات مع نسخة Firebase Storage المُحقَنة.
  FirebaseStoragePackageDatasource(this._storage);

  final FirebaseStorage _storage;

  /// Maximum allowed file size: 20 MB.
  /// الحجم الأقصى للملف: 20 ميجابايت.
  static const int _maxFileSizeBytes = 20 * 1024 * 1024;

  /// Allowed file extensions. الامتدادات المسموح بها.
  static const Set<String> _allowedExtensions = {'pdf', 'jpg', 'jpeg', 'png'};

  /// Uploads a document file to Firebase Storage and returns the download URL.
  ///
  /// **English**
  /// Storage path: `packageDocuments/{clinicId}/{patientId}/
  /// {patientPackageId}/{documentId}/{filename}`
  ///
  /// Validation steps:
  /// 1. File must exist at [localFilePath].
  /// 2. File size must be ≤ 20 MB.
  /// 3. File extension must be in {pdf, jpg, jpeg, png}.
  ///
  /// Returns:
  /// - `Right(downloadUrl)` on success.
  /// - `Left(UploadFailure)` on validation failure or Storage error.
  ///
  /// **Arabic**
  /// يرفع الملف إلى Firebase Storage ويُعيد رابط التحميل.
  /// خطوات التحقق: وجود الملف، الحجم ≤ 20 MB، الامتداد مسموح به.
  ///
  /// **Usage / الاستخدام**:
  /// ```dart
  /// final result = await datasource.uploadDocument(
  ///   localFilePath: '/storage/emulated/0/Download/result.pdf',
  ///   clinicId: ClinicIds.andrology,
  ///   patientId: 'uid_123',
  ///   patientPackageId: 'pp_001',
  ///   documentId: 'doc_uuid',
  ///   filename: 'result.pdf',
  /// );
  /// ```
  Future<Either<UploadFailure, String>> uploadDocument({
    required String localFilePath,
    required String clinicId,
    required String patientId,
    required String patientPackageId,
    required String documentId,
    required String filename,
  }) async {
    try {
      final file = File(localFilePath);

      // ── Validation 1: file must exist ─────────────────────────────────────
      if (!file.existsSync()) {
        const msg = 'الملف المُختار غير موجود، يرجى اختياره مجددًا.';
        if (kDebugMode) {
          debugPrint('[StorageDatasource] File not found: $localFilePath');
        }
        return const Left(UploadFailure(msg));
      }

      // ── Validation 2: size ≤ 20 MB ────────────────────────────────────────
      final sizeBytes = file.lengthSync();
      if (sizeBytes > _maxFileSizeBytes) {
        const msg = 'حجم الملف يتجاوز الحد المسموح به (20 ميجابايت).';
        if (kDebugMode) {
          debugPrint(
            '[StorageDatasource] File too large: $sizeBytes bytes',
          );
        }
        return const Left(UploadFailure(msg));
      }

      // ── Validation 3: extension must be allowed ────────────────────────────
      final ext = filename.split('.').last.toLowerCase();
      if (!_allowedExtensions.contains(ext)) {
        const msg = 'نوع الملف غير مسموح به. الأنواع المقبولة: PDF، JPG، PNG.';
        if (kDebugMode) {
          debugPrint('[StorageDatasource] Unsupported extension: $ext');
        }
        return const Left(UploadFailure(msg));
      }

      // ── Upload ─────────────────────────────────────────────────────────────
      final storagePath =
          'packageDocuments/$clinicId/$patientId/$patientPackageId/$documentId/$filename';

      if (kDebugMode) {
        debugPrint('[StorageDatasource] Uploading to: $storagePath');
      }

      final ref = _storage.ref(storagePath);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      if (kDebugMode) {
        debugPrint(
          '[StorageDatasource] Upload complete. URL: $downloadUrl',
        );
      }

      return Right(downloadUrl);
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          '[StorageDatasource] Firebase error: ${e.code} ${e.message}',
        );
        debugPrint(st.toString());
      }
      return Left(
        UploadFailure('فشل رفع الملف: ${e.message ?? e.code}'),
      );
    } on Exception catch (e, st) {
      if (kDebugMode) {
        debugPrint('[StorageDatasource] Unexpected error: $e');
        debugPrint(st.toString());
      }
      return const Left(UploadFailure('فشل رفع الملف. يرجى المحاولة مجددًا.'));
    }
  }

  /// Returns the download URL for an already-uploaded file.
  ///
  /// **Arabic**: يُعيد رابط التحميل لملف مُرفوع مسبقًا.
  Future<Either<UploadFailure, String>> getDownloadUrl({
    required String storagePath,
  }) async {
    try {
      final url = await _storage.ref(storagePath).getDownloadURL();
      return Right(url);
    } on FirebaseException catch (e) {
      return Left(
        UploadFailure('لا يمكن تحميل الملف: ${e.message ?? e.code}'),
      );
    }
  }
}
