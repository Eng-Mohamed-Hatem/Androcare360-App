/// Base per-clinic package repository — قاعدة مستودع باقات العيادة
///
/// يُقدِّم هذا الملف فئتين:
/// - [BaseClinicPackageRepository]: تطبيق أساسي مشترك للمستودعات الخمسة.
/// - التطبيقات الخمسة المتخصصة تمتد منه ولا تحتاج إلا إلى تعريف [clinicId].
///
/// **English**: Shared base implementation of [PackageRepository] for the five
/// per-clinic implementations. Eliminates code duplication (DRY). Each clinic
/// implementation sets only its own [clinicId] constant.
///
/// **Use of named qualifier**: Since all five implement the same interface, they
/// are NOT registered in GetIt as `PackageRepository`. Instead, each is exposed
/// as its own concrete type. Riverpod providers (not GetIt) select the correct
/// implementation per clinic at runtime.
///
/// **Spec**: plan.md §Per-Clinic Repository Implementations, tasks.md T017–T021.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/data/datasources/firestore_package_datasource.dart';
import 'package:elajtech/features/packages/data/models/package_model.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart';

/// Abstract base for per-clinic [PackageRepository] implementations.
///
/// **English**
/// Concrete subclasses must set [clinicId] and call [super(datasource)].
/// All three [PackageRepository] methods are implemented here and delegate
/// to [FirestorePackageDatasource].
///
/// **Arabic**
/// الفئة الأساسية للمستودعات الخمسة. الفئات الفرعية تُعيِّن [clinicId] فحسب.
/// جميع أساليب [PackageRepository] مُطبَّقة هنا وتُفوِّض إلى [FirestorePackageDatasource].
abstract class BaseClinicPackageRepository implements PackageRepository {
  /// Creates a [BaseClinicPackageRepository] with the datasource.
  ///
  /// يُنشئ المستودع الأساسي مع مصدر البيانات المُحقَن.
  const BaseClinicPackageRepository(this._datasource);

  final FirestorePackageDatasource _datasource;

  /// The clinic ID specific to this implementation.
  /// معرف العيادة الخاص بهذا التطبيق — مُعرَّف في الفئة الفرعية.
  String get clinicId;

  @override
  Future<Either<Failure, List<PackageEntity>>> listCategoryPackages({
    required String clinicId,
    required PackageCategory category,
  }) async {
    try {
      final snapshot = await _datasource.fetchCategoryPackages(
        clinicId: clinicId,
        category: category.value,
      );

      final packages = snapshot.docs
          .map(PackageModel.fromFirestore)
          .whereType<PackageModel>()
          .toList();

      if (kDebugMode) {
        debugPrint(
          '[$runtimeType] listCategoryPackages '
          'clinicId=$clinicId category=${category.value} '
          'found=${packages.length}',
        );
      }

      return Right(packages);
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        debugPrint('[$runtimeType] listCategoryPackages error: $e');
        debugPrint(st.toString());
      }
      return Left(NetworkFailure(e.message ?? 'خطأ في الشبكة'));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[$runtimeType] Unexpected error: $e');
        debugPrint(st.toString());
      }
      return const Left(NetworkFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, List<PackageEntity>>> listClinicPackagesForAdmin({
    required String clinicId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _datasource.fetchClinicPackagesForAdmin(
        clinicId: clinicId,
        lastDocument: lastDocument,
        limit: limit,
      );

      final packages = snapshot.docs
          .map(PackageModel.fromFirestore)
          .whereType<PackageModel>()
          .toList();

      if (kDebugMode) {
        debugPrint(
          '[$runtimeType] listClinicPackagesForAdmin '
          'clinicId=$clinicId found=${packages.length}',
        );
      }

      return Right(packages);
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        debugPrint('[$runtimeType] listClinicPackagesForAdmin error: $e');
        debugPrint(st.toString());
      }
      return Left(NetworkFailure(e.message ?? 'خطأ في الشبكة'));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[$runtimeType] Unexpected error: $e');
        debugPrint(st.toString());
      }
      return const Left(NetworkFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, PackageEntity>> getPackageById({
    required String clinicId,
    required String packageId,
  }) async {
    try {
      final doc = await _datasource.fetchPackageById(
        clinicId: clinicId,
        packageId: packageId,
      );

      final model = PackageModel.fromFirestore(doc);
      if (model == null) {
        if (kDebugMode) {
          debugPrint(
            '[$runtimeType] getPackageById: not found '
            'clinicId=$clinicId pkgId=$packageId',
          );
        }
        return const Left(
          PackageNotFoundFailure('الباقة المطلوبة غير موجودة.'),
        );
      }

      if (kDebugMode) {
        debugPrint(
          '[$runtimeType] getPackageById: found name=${model.name}',
        );
      }

      return Right(model);
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        debugPrint('[$runtimeType] getPackageById Firebase error: $e');
        debugPrint(st.toString());
      }
      return Left(NetworkFailure(e.message ?? 'خطأ في الشبكة'));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[$runtimeType] getPackageById Unexpected: $e');
        debugPrint(st.toString());
      }
      return const Left(NetworkFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, String>> createPackage(PackageEntity package) async {
    try {
      final model = PackageModel(
        id: package.id,
        clinicId: clinicId, // Enforce clinic scope
        category: package.category,
        name: package.name,
        shortDescription: package.shortDescription,
        description: package.description,
        services: package.services,
        validityDays: package.validityDays,
        termsAndConditions: package.termsAndConditions,
        price: package.price,
        currency: package.currency,
        discountPercentage: package.discountPercentage,
        packageType: package.packageType,
        status: package.status,
        displayOrder: package.displayOrder,
        isFeatured: package.isFeatured,
        createdAt: package.createdAt,
        updatedAt: package.updatedAt,
        includesVideoConsultation: package.includesVideoConsultation,
        includesPhysicalVisit: package.includesPhysicalVisit,
      );

      final id = await _datasource.createClinicPackage(
        clinicId: clinicId,
        packageId: package.id,
        data: model.toFirestore(),
      );

      if (kDebugMode) {
        debugPrint(
          '[$runtimeType] createPackage SUCCESS: '
          'clinicId=$clinicId packageId=$id name=${package.name}',
        );
      }

      return Right(id);
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        debugPrint('[$runtimeType] createPackage Firebase error: $e');
        debugPrint(st.toString());
      }
      return Left(NetworkFailure(e.message ?? 'خطأ في الشبكة'));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[$runtimeType] createPackage Unexpected: $e');
        debugPrint(st.toString());
      }
      return const Left(NetworkFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePackage(PackageEntity package) async {
    try {
      final model = PackageModel(
        id: package.id,
        clinicId: clinicId, // Enforce clinic scope
        category: package.category,
        name: package.name,
        shortDescription: package.shortDescription,
        description: package.description,
        services: package.services,
        validityDays: package.validityDays,
        termsAndConditions: package.termsAndConditions,
        price: package.price,
        currency: package.currency,
        discountPercentage: package.discountPercentage,
        packageType: package.packageType,
        status: package.status,
        displayOrder: package.displayOrder,
        isFeatured: package.isFeatured,
        createdAt: package.createdAt,
        updatedAt: package.updatedAt,
        includesVideoConsultation: package.includesVideoConsultation,
        includesPhysicalVisit: package.includesPhysicalVisit,
      );

      await _datasource.updateClinicPackage(
        clinicId: clinicId,
        packageId: package.id,
        data: model.toFirestore(),
      );

      if (kDebugMode) {
        debugPrint(
          '[$runtimeType] updatePackage SUCCESS: '
          'clinicId=$clinicId packageId=${package.id}',
        );
      }

      return const Right(unit);
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        debugPrint('[$runtimeType] updatePackage Firebase error: $e');
        debugPrint(st.toString());
      }
      return Left(NetworkFailure(e.message ?? 'خطأ في الشبكة'));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[$runtimeType] updatePackage Unexpected: $e');
        debugPrint(st.toString());
      }
      return const Left(NetworkFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePackageStatus({
    required String clinicId,
    required String packageId,
    required PackageStatus status,
  }) async {
    try {
      await _datasource.updateClinicPackage(
        clinicId: clinicId,
        packageId: packageId,
        data: {
          'status': status.value,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      return const Right(unit);
    } on FirebaseException catch (e, st) {
      if (kDebugMode) {
        debugPrint('[$runtimeType] updatePackageStatus Firebase error: $e');
        debugPrint(st.toString());
      }
      return Left(NetworkFailure(e.message ?? 'خطأ في الشبكة'));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[$runtimeType] updatePackageStatus Unexpected: $e');
        debugPrint(st.toString());
      }
      return const Left(NetworkFailure('حدث خطأ غير متوقع'));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-Clinic Implementations
// ─────────────────────────────────────────────────────────────────────────────

/// Andrology clinic package repository — مستودع باقات عيادة الأندروجين
///
/// clinicId = `ClinicIds.andrology` ('andrology').
/// Spec: tasks.md T017.
@lazySingleton
class AndrologyPackageRepository extends BaseClinicPackageRepository {
  /// Creates an [AndrologyPackageRepository].
  const AndrologyPackageRepository(super.datasource);

  @override
  String get clinicId => 'andrology';
}

/// Physiotherapy clinic package repository — مستودع باقات عيادة العلاج الطبيعي
///
/// clinicId = `ClinicIds.physiotherapy` ('physiotherapy').
/// Spec: tasks.md T018.
@lazySingleton
class PhysiotherapyPackageRepository extends BaseClinicPackageRepository {
  /// Creates a [PhysiotherapyPackageRepository].
  const PhysiotherapyPackageRepository(super.datasource);

  @override
  String get clinicId => 'physiotherapy';
}

/// Internal / Family medicine clinic package repository
/// مستودع باقات عيادة الطب الداخلي والأسرة
///
/// clinicId = `ClinicIds.internalFamily` ('internal_family').
/// Spec: tasks.md T019.
@lazySingleton
class InternalFamilyPackageRepository extends BaseClinicPackageRepository {
  /// Creates an [InternalFamilyPackageRepository].
  const InternalFamilyPackageRepository(super.datasource);

  @override
  String get clinicId => 'internal_family';
}

/// Nutrition clinic package repository — مستودع باقات عيادة التغذية والسمنة
///
/// clinicId = `ClinicIds.nutrition` ('nutrition').
/// Spec: tasks.md T020.
@lazySingleton
class NutritionPackageRepository extends BaseClinicPackageRepository {
  /// Creates a [NutritionPackageRepository].
  const NutritionPackageRepository(super.datasource);

  @override
  String get clinicId => 'nutrition';
}

/// Chronic diseases clinic package repository — مستودع باقات عيادة الأمراض المزمنة
///
/// clinicId = `ClinicIds.chronicDiseases` ('chronic_diseases').
/// Spec: tasks.md T021.
@lazySingleton
class ChronicDiseasesPackageRepository extends BaseClinicPackageRepository {
  /// Creates a [ChronicDiseasesPackageRepository].
  const ChronicDiseasesPackageRepository(super.datasource);

  @override
  String get clinicId => 'chronic_diseases';
}
