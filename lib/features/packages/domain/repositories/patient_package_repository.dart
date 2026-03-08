/// PatientPackageRepository — واجهة مستودع مشتريات باقات المريض
///
/// تُعرِّف هذه الواجهة عقد الوصول إلى بيانات الباقات المشتراة من قِبَل المرضى.
/// قواعد عزل حقل `notes` (R2) مُطبَّقة على مستوى أسماء الأساليب:
/// الأساليب التي تنتهي بـ `ForPatient` تُعيد دائمًا `notes = null`.
///
/// **English**: Domain-layer repository interface for patient package purchases.
/// R2 (notes isolation) is enforced at the method-naming level — methods
/// suffixed `ForPatient` strip `notes`; methods suffixed `ForAdmin` include it.
///
/// **Spec**: spec.md §7.1, §7.8, §8.3, tasks.md T011.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart' show PackageAlreadyActiveFailure;

/// Abstract repository for patient package purchase records.
///
/// **English**
/// All methods return `Either<Failure, T>`. Two method families exist for R2:
/// - `*ForPatient`: notes always null, for patient app screens.
/// - `*ForAdmin`: notes included, for admin/doctor screens.
///
/// **Arabic**
/// واجهة مجردة لسجلات مشتريات باقات المريض.
/// عائلتا الأساليب تُميِّزان بين الواجهة الخاصة بالمريض (notes = null) R2
/// والخاصة بالأدمن (تشمل notes).
abstract class PatientPackageRepository {
  /// Returns all package purchases for [patientId] — patient-facing.
  ///
  /// **English**: Returns a list with `notes = null` in every entity (R2).
  /// Expected < 20 results per patient — single call, no pagination.
  ///
  /// **Arabic**: يُعيد جميع مشتريات المريض مع `notes = null` دائمًا (R2).
  Future<Either<Failure, List<PatientPackageEntity>>> getPatientPackages({
    required String patientId,
  });

  /// Returns a single patient package — patient-facing. Notes ALWAYS null (R2).
  ///
  /// **Arabic**: يُعيد سجل شراء واحد للمريض. حقل `notes` دائمًا null (R2).
  Future<Either<Failure, PatientPackageEntity>>
  getPatientPackageByIdForPatient({
    required String patientId,
    required String patientPackageId,
  });

  /// Returns a single patient package — admin-facing. Notes INCLUDED (R2).
  ///
  /// **Arabic**: يُعيد سجل شراء واحد للأدمن. حقل `notes` مُضمَّن (R2).
  Future<Either<Failure, PatientPackageEntity>> getPatientPackageByIdForAdmin({
    required String patientId,
    required String patientPackageId,
  });

  /// Checks for any ACTIVE or PENDING record for [packageId] and [patientId].
  ///
  /// **English**: Duplicate-purchase guard (CHK023, spec.md §7.4 step 1).
  /// Returns `Right(null)` if no match. Returns `Right(entity)` if a
  /// conflicting record exists — use case then returns [PackageAlreadyActiveFailure].
  ///
  /// Uses Index 5: `patientId + packageId + status`.
  ///
  /// **Arabic**: فحص الشراء المكرر. يُعيد `Right(null)` إذا لم يوجد تعارض،
  /// أو `Right(entity)` إذا وُجد سجل نشط أو معلَّق لنفس الباقة.
  Future<Either<Failure, PatientPackageEntity?>>
  findActiveOrPendingByPackageId({
    required String patientId,
    required String packageId,
  });

  /// Creates a new patient package purchase record.
  ///
  /// **English**: Called by `PurchasePackageUseCase` after successful payment.
  /// [paymentTransactionId] must be non-null when [status] is ACTIVE.
  /// Returns the new document ID on success.
  ///
  /// **Arabic**: يُنشئ سجل شراء جديد للمريض. معرف المعاملة إلزامي عند الحالة ACTIVE.
  Future<Either<Failure, String>> createPatientPackage({
    required String patientId,
    required String packageId,
    required String clinicId,
    required PatientPackageStatus status,
    required DateTime purchaseDate,
    required DateTime expiryDate,
    required int totalServicesCount,
    required List<String> servicesUsageInit,
    required String paymentTransactionId,
    required String category,
  });

  /// Returns a paginated list of patient packages — admin-facing. Notes INCLUDED.
  ///
  /// **English**: Page size = 20 (CHK049). [lastDocument] is the Firestore
  /// pagination cursor. Includes notes field (R2 — admin only).
  ///
  /// **Arabic**: القائمة المُقسَّمة للأدمن تشمل حقل `notes` (R2).
  Future<Either<Failure, List<PatientPackageEntity>>>
  listPatientPackagesForAdmin({
    required String patientId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  });
}
