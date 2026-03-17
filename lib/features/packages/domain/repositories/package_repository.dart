/// PackageRepository — واجهة مستودع باقات العيادة
///
/// تُعرِّف هذه الواجهة عقد الوصول إلى بيانات الباقات لكل عيادة.
/// كل تطبيق عيادة ينفذ هذه الواجهة باستخدام `clinicId` الخاص بها.
///
/// **English**: Domain-layer repository interface for clinic package definitions.
/// Each per-clinic implementation is bound to a specific `clinicId` and
/// delegates to `FirestorePackageDatasource`. Use cases depend only on this
/// abstract type — never on a concrete implementation.
///
/// **Spec**: spec.md §8.1, §8.2, plan.md §Domain Repository Interfaces.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart'
    show ClinicUnavailableFailure, PackageNotFoundFailure;

/// Abstract repository for reading and writing clinic package definitions.
///
/// **English**
/// All methods return `Either<Failure, T>` from dartz. Methods follow naming
/// conventions: `list*` returns lists, `get*` returns a single entity.
///
/// - `listCategoryPackages`: Patient-facing — only `ACTIVE` packages.
/// - `listClinicPackagesForAdmin`: Admin-facing — all statuses, paginated.
/// - `getPackageById`: Single package lookup for details screen.
///
/// **Arabic**
/// واجهة مجردة لقراءة وكتابة تعريفات باقات العيادة.
/// جميع الأساليب تُعيد `Either<Failure, T>`.
abstract class PackageRepository {
  /// Returns all ACTIVE packages for [clinicId] within [category].
  ///
  /// **English**: Ordered by `displayOrder` ASC. Featured packages appear
  /// first (spec.md §9.3). Max 50 documents per call (Index 1).
  ///
  /// **Arabic**: يُعيد الباقات النشطة فقط لفئة معينة، مرتبةً حسب الترتيب
  /// مع ظهور المميزة أولًا.
  ///
  /// Uses Index 1: `clinicId + category + status + displayOrder`.
  Future<Either<Failure, List<PackageEntity>>> listCategoryPackages({
    required String clinicId,
    required PackageCategory category,
  });

  /// Returns a paginated list of ALL packages for [clinicId] (admin view).
  ///
  /// **English**: Page size = 20 (CHK049). [lastDocument] is the Firestore
  /// cursor for the next page. Includes all statuses (ACTIVE, INACTIVE,
  /// HIDDEN). Uses Index 1.
  ///
  /// **Arabic**: قائمة مُقسَّمة للأدمن تشمل جميع الحالات. حجم الصفحة 20.
  Future<Either<Failure, List<PackageEntity>>> listClinicPackagesForAdmin({
    required String clinicId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  });

  /// Returns a single package by [clinicId] and [packageId].
  ///
  /// **English**: Returns [PackageNotFoundFailure] if the document does not
  /// exist. Returns [ClinicUnavailableFailure] if the clinic itself is
  /// unavailable (spec.md §7.9).
  ///
  /// **Arabic**: يُعيد باقة واحدة. يُعيد [PackageNotFoundFailure] إذا لم
  /// تُوجد الباقة أو [ClinicUnavailableFailure] إذا كانت العيادة غير متاحة.
  Future<Either<Failure, PackageEntity>> getPackageById({
    required String clinicId,
    required String packageId,
  });

  /// Creates a new clinic package.
  ///
  /// **English**: Returns the new document ID.
  ///
  /// **Arabic**: يُنشئ باقة جديدة ويُعيد مُعرّفها.
  Future<Either<Failure, String>> createPackage(PackageEntity package);

  /// Updates an existing clinic package.
  ///
  /// **English**: Returns [Unit] on success.
  ///
  /// **Arabic**: يُحدّث بيانات باقة موجودة.
  Future<Either<Failure, Unit>> updatePackage(PackageEntity package);

  /// Updates the status of an existing clinic package.
  ///
  /// **English**: Returns [Unit] on success.
  ///
  /// **Arabic**: يحدّث حالة الباقة فقط.
  Future<Either<Failure, Unit>> updatePackageStatus({
    required String clinicId,
    required String packageId,
    required PackageStatus status,
  });
}
