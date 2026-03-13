/// PatientPackageRepositoryImpl — تطبيق مستودع مشتريات باقات المريض
///
/// يُنفِّذ [PatientPackageRepository] ويُفوِّض جميع العمليات إلى
/// [FirestorePackageDatasource] مع تطبيق قاعدة R2 (عزل حقل notes).
///
/// **English**: Data-layer implementation of [PatientPackageRepository] (T022).
/// R2 enforced via [PatientPackageModel] factory selection. All debug logging
/// follows the project logging protocol.
///
/// Annotated `@LazySingleton(as: PatientPackageRepository)`.
///
/// **Spec**: tasks.md T022, plan.md §Patient package repo, important-rules.md R2.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/data/datasources/firestore_package_datasource.dart';
import 'package:elajtech/features/packages/data/models/patient_package_model.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/patient_package_repository.dart';

/// Concrete implementation of [PatientPackageRepository].
///
/// **English**
/// Delegates to [FirestorePackageDatasource] for all Firestore operations.
/// Patient-facing methods use [PatientPackageModel.fromFirestoreForPatient]
/// (notes=null). Admin-facing methods use [PatientPackageModel.fromFirestoreForAdmin]
/// (notes included). This is the sole enforcement point for R2.
///
/// **Arabic**
/// تُستدعى أساليب المريض مع [PatientPackageModel.fromFirestoreForPatient] (R2).
/// تُستدعى أساليب الأدمن مع [PatientPackageModel.fromFirestoreForAdmin] (R2).
@LazySingleton(as: PatientPackageRepository)
class PatientPackageRepositoryImpl implements PatientPackageRepository {
  /// Creates a [PatientPackageRepositoryImpl].
  ///
  /// يُنشئ التطبيق مع مصدر البيانات المُحقَن.
  const PatientPackageRepositoryImpl(this._datasource);

  final FirestorePackageDatasource _datasource;

  @override
  Future<Either<Failure, List<PatientPackageEntity>>> getPatientPackages({
    required String patientId,
  }) async {
    try {
      final snapshot = await _datasource.fetchPatientPackages(
        patientId: patientId,
      );

      // R2: patient view — notes always null
      final packages = snapshot.docs
          .map(PatientPackageModel.fromFirestoreForPatient)
          .whereType<PatientPackageModel>()
          .toList();

      if (kDebugMode) {
        debugPrint(
          '[PatientPackageRepositoryImpl] getPatientPackages '
          'patientId=$patientId found=${packages.length}',
        );
      }

      return Right(packages);
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          '[PatientPackageRepositoryImpl] getPatientPackages error: $e',
        );
        debugPrint(st.toString());
      }
      return Left(NetworkFailure(e.message ?? 'خطأ في الشبكة'));
    } on Exception catch (e, st) {
      if (kDebugMode) {
        debugPrint('[PatientPackageRepositoryImpl] Unexpected: $e');
        debugPrint(st.toString());
      }
      return const Left(NetworkFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, PatientPackageEntity>>
  getPatientPackageByIdForPatient({
    required String patientId,
    required String patientPackageId,
  }) async {
    try {
      final doc = await _datasource.fetchPatientPackageByIdRaw(
        patientId: patientId,
        patientPackageId: patientPackageId,
      );

      // R2: patient view — notes always null
      final model = PatientPackageModel.fromFirestoreForPatient(doc);
      if (model == null) {
        return const Left(
          PackageNotFoundFailure('سجل الشراء غير موجود.'),
        );
      }
      return Right(model);
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          '[PatientPackageRepositoryImpl] getByIdForPatient error: $e',
        );
        debugPrint(st.toString());
      }
      return Left(NetworkFailure(e.message ?? 'خطأ في الشبكة'));
    } on Exception catch (e, st) {
      if (kDebugMode) {
        debugPrint('[PatientPackageRepositoryImpl] Unexpected: $e');
        debugPrint(st.toString());
      }
      return const Left(NetworkFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, PatientPackageEntity>> getPatientPackageByIdForAdmin({
    required String patientId,
    required String patientPackageId,
  }) async {
    try {
      final doc = await _datasource.fetchPatientPackageByIdRaw(
        patientId: patientId,
        patientPackageId: patientPackageId,
      );

      // R2: admin view — notes included
      final model = PatientPackageModel.fromFirestoreForAdmin(doc);
      if (model == null) {
        return const Left(
          PackageNotFoundFailure('سجل الشراء غير موجود.'),
        );
      }
      return Right(model);
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        debugPrint('[PatientPackageRepositoryImpl] getByIdForAdmin error: $e');
        debugPrint(st.toString());
      }
      return Left(NetworkFailure(e.message ?? 'خطأ في الشبكة'));
    } on Exception catch (e, st) {
      if (kDebugMode) {
        debugPrint('[PatientPackageRepositoryImpl] Unexpected: $e');
        debugPrint(st.toString());
      }
      return const Left(NetworkFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, PatientPackageEntity?>>
  findActiveOrPendingByPackageId({
    required String patientId,
    required String packageId,
  }) async {
    try {
      final snapshot = await _datasource.findActiveOrPendingByPackageId(
        patientId: patientId,
        packageId: packageId,
      );

      if (snapshot.docs.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[PatientPackageRepositoryImpl] findActiveOrPending: no conflict '
            'patientId=$patientId pkgId=$packageId',
          );
        }
        return const Right(null);
      }

      // R2: patient view (admin doesn't need this guard)
      final model = PatientPackageModel.fromFirestoreForPatient(
        snapshot.docs.first,
      );

      if (kDebugMode) {
        debugPrint(
          '[PatientPackageRepositoryImpl] findActiveOrPending: CONFLICT found '
          'patientId=$patientId pkgId=$packageId status=${model?.status.value}',
        );
      }

      return Right(model);
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          '[PatientPackageRepositoryImpl] findActiveOrPending error: $e',
        );
        debugPrint(st.toString());
      }
      return Left(NetworkFailure(e.message ?? 'خطأ في الشبكة'));
    } on Exception catch (e, st) {
      if (kDebugMode) {
        debugPrint('[PatientPackageRepositoryImpl] Unexpected: $e');
        debugPrint(st.toString());
      }
      return const Left(NetworkFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, String>> createPatientPackage({
    required String patientId,
    required String packageId,
    required String packageName,
    required String clinicId,
    required PatientPackageStatus status,
    required DateTime purchaseDate,
    required DateTime expiryDate,
    required int totalServicesCount,
    required List<String> servicesUsageInit,
    required List<PackageServiceItem> packageServices,
    required String paymentTransactionId,
    required String category,
    required bool isTestPurchase,
    required String description,
    required String shortDescription,
    required int validityDays,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[PatientPackageRepositoryImpl] createPatientPackage '
          'patientId=$patientId pkgId=$packageId clinicId=$clinicId '
          'isTest=$isTestPurchase txn=$paymentTransactionId',
        );
      }

      final data = <String, dynamic>{
        'patientId': patientId,
        'packageId': packageId,
        'packageName': packageName, // FIX: Persistent package name
        'clinicId': clinicId,
        'category': category,
        'status': status.value,
        'purchaseDate': Timestamp.fromDate(purchaseDate),
        'expiryDate': Timestamp.fromDate(expiryDate),
        'totalServicesCount': totalServicesCount,
        'usedServicesCount': 0,
        'isTestPurchase': isTestPurchase,
        'servicesUsage': servicesUsageInit
            .map((id) => {'serviceId': id, 'usedCount': 0})
            .toList(),
        'packageServices': packageServices.map((s) => s.toMap()).toList(),
        'paymentTransactionId': paymentTransactionId,
        'description': description,
        'shortDescription': shortDescription,
        'validityDays': validityDays,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docId = await _datasource.createPatientPackage(
        patientId: patientId,
        data: data,
      );

      if (kDebugMode) {
        debugPrint(
          '[PatientPackageRepositoryImpl] createPatientPackage OK docId=$docId',
        );
      }

      return Right(docId);
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          '[PatientPackageRepositoryImpl] createPatientPackage error: $e',
        );
        debugPrint(st.toString());
      }
      return Left(NetworkFailure(e.message ?? 'خطأ في الشبكة'));
    } on Exception catch (e, st) {
      if (kDebugMode) {
        debugPrint('[PatientPackageRepositoryImpl] Unexpected: $e');
        debugPrint(st.toString());
      }
      return const Left(NetworkFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, List<PatientPackageEntity>>>
  listPatientPackagesForAdmin({
    required String patientId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _datasource.fetchPatientPackagesForAdmin(
        patientId: patientId,
        lastDocument: lastDocument,
        limit: limit,
      );

      // R2: admin view — notes included
      final packages = snapshot.docs
          .map(PatientPackageModel.fromFirestoreForAdmin)
          .whereType<PatientPackageModel>()
          .toList();

      if (kDebugMode) {
        debugPrint(
          '[PatientPackageRepositoryImpl] listPatientPackagesForAdmin '
          'patientId=$patientId found=${packages.length}',
        );
      }

      return Right(packages);
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        debugPrint('[PatientPackageRepositoryImpl] listForAdmin error: $e');
        debugPrint(st.toString());
      }
      return Left(NetworkFailure(e.message ?? 'خطأ في الشبكة'));
    } on Exception catch (e, st) {
      if (kDebugMode) {
        debugPrint('[PatientPackageRepositoryImpl] Unexpected: $e');
        debugPrint(st.toString());
      }
      return const Left(NetworkFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, void>> updateNotes({
    required String patientId,
    required String patientPackageId,
    required String notes,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[PatientPackageRepositoryImpl] updateNotes '
          'patientId=$patientId ppId=$patientPackageId',
        );
      }
      await _datasource.updatePatientPackageNotes(
        patientId: patientId,
        patientPackageId: patientPackageId,
        notes: notes,
      );
      return const Right(null);
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        debugPrint('[PatientPackageRepositoryImpl] updateNotes error: $e');
        debugPrint(st.toString());
      }
      return Left(NetworkFailure(e.message ?? 'خطأ في الشبكة'));
    } on Exception catch (e, st) {
      if (kDebugMode) {
        debugPrint('[PatientPackageRepositoryImpl] Unexpected: $e');
        debugPrint(st.toString());
      }
      return const Left(NetworkFailure('حدث خطأ غير متوقع'));
    }
  }
}
