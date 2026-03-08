/// PurchasePackageUseCase — حالة استخدام شراء الباقة
///
/// تُنفِّذ هذه الحالة تدفق شراء الباقة الكامل:
/// ١. فحص الشراء المكرر عبر [PatientPackageRepository.findActiveOrPendingByPackageId].
/// ٢. طلب الدفع عبر [PackagePaymentAdapter.initiatePayment] (واجهة طبقة المجال — R6).
/// ٣. عند نجاح الدفع: إنشاء سجل شراء في Firestore مع جميع الحقول الإلزامية.
/// ٤. عند الفشل: إعادة فشل مكتوب دون أي كتابة في Firestore.
///
/// **English**:
/// Full purchase flow: duplicate check → payment → Firestore write on success.
/// Uses the domain-layer [PackagePaymentAdapter] interface only (R6 — Clean
/// Architecture boundary). Never imports Data-layer classes directly.
///
/// **Spec**: spec.md §7.4, §7.5, tasks.md T032.
library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/adapters/package_payment_adapter.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/patient_package_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/get_package_details_usecase.dart'
    show GetPackageDetailsUseCase;

// ─────────────────────────────────────────────────────────────────────────────
// Purchase input params
// ─────────────────────────────────────────────────────────────────────────────

/// Parameters required by [PurchasePackageUseCase].
///
/// **English**: Bundles all fields needed to initiate a package purchase.
/// [package] must already be loaded (from [GetPackageDetailsUseCase]).
/// [patientId] is the authenticated user's UID — never null.
///
/// **Arabic**: تجمع جميع البيانات اللازمة لبدء عملية الشراء.
/// [package] محمَّل مسبقًا. [patientId] هو UID المريض — لا يكون فارغًا أبدًا.
class PurchasePackageParams {
  /// Creates [PurchasePackageParams].
  const PurchasePackageParams({
    required this.patientId,
    required this.package,
  });

  /// Authenticated patient UID — UID المريض المُصادَق عليه.
  final String patientId;

  /// The package being purchased — الباقة المراد شراؤها.
  final PackageEntity package;
}

// ─────────────────────────────────────────────────────────────────────────────
// PurchasePackageUseCase
// ─────────────────────────────────────────────────────────────────────────────

/// Use case: purchase a clinic package for the authenticated patient.
///
/// **English**
/// Step-by-step:
/// 1. Call [PatientPackageRepository.findActiveOrPendingByPackageId] →
///    return [PackageAlreadyActiveFailure] if an ACTIVE or PENDING record
///    already exists (CHK023 duplicate guard).
/// 2. Call [PackagePaymentAdapter.initiatePayment] — domain interface (R6).
/// 3. On [PaymentSuccess]: call [PatientPackageRepository.createPatientPackage]
///    with non-null [paymentTransactionId], computed [expiryDate], initialized
///    [servicesUsage] list, `usedServicesCount=0`, `status=ACTIVE`.
/// 4. On [PaymentFailure] or any other failure: return typed failure, no write.
///
/// **Arabic**
/// خطوات التنفيذ:
/// ١. فحص التكرار — إذا وُجد سجل ACTIVE أو PENDING يُعاد [PackageAlreadyActiveFailure].
/// ٢. طلب الدفع عبر واجهة المجال.
/// ٣. عند النجاح: إنشاء سجل شراء مع كل الحقول الإلزامية.
/// ٤. عند الفشل: يُعاد فشل مكتوب دون أي كتابة في Firestore.
///
/// **Usage / الاستخدام**:
/// ```dart
/// final result = await purchaseUseCase(PurchasePackageParams(
///   patientId: user.id,
///   package: loadedPackage,
/// ));
/// result.fold(
///   (failure) => /* show error */,
///   (patientPackageId) => /* show success */,
/// );
/// ```
class PurchasePackageUseCase {
  /// Creates the use case with injected domain-layer dependencies.
  ///
  /// يُنشئ حالة الاستخدام مع الاعتماديات المُحقَنة من طبقة المجال.
  const PurchasePackageUseCase({
    required PatientPackageRepository patientPackageRepository,
    required PackagePaymentAdapter paymentAdapter,
  }) : _patientPackageRepo = patientPackageRepository,
       _paymentAdapter = paymentAdapter;

  final PatientPackageRepository _patientPackageRepo;
  final PackagePaymentAdapter _paymentAdapter;

  /// Executes the purchase flow.
  ///
  /// **Parameters**:
  /// - [params]: Bundle of patientId + loaded PackageEntity.
  ///
  /// **Returns**:
  /// - `Right(String)` — the new patientPackageId on success.
  /// - `Left(PackageAlreadyActiveFailure)` if ACTIVE/PENDING record found.
  /// - `Left(PaymentFailure)` if the payment gateway declines.
  /// - `Left(Failure)` for network or Firestore errors.
  ///
  /// يُعيد معرف سجل الشراء الجديد عند النجاح، أو فشلاً مكتوبًا عند الخطأ.
  Future<Either<Failure, String>> call(PurchasePackageParams params) async {
    final patientId = params.patientId;
    final package = params.package;

    // ── Step 1: Duplicate-purchase guard (CHK023) ─────────────────────────────
    final duplicateResult = await _patientPackageRepo
        .findActiveOrPendingByPackageId(
          patientId: patientId,
          packageId: package.id,
        );

    // If Firestore query itself failed, propagate the error
    if (duplicateResult.isLeft()) {
      return duplicateResult.fold(
        Left.new,
        (_) => throw StateError('unreachable'),
      );
    }

    final existingRecord = duplicateResult.getOrElse(() => null);
    if (existingRecord != null) {
      // ACTIVE or PENDING record found — block duplicate purchase
      return const Left(PackageAlreadyActiveFailure());
    }

    // ── Step 2: Initiate payment ─────────────────────────────────────────────
    final paymentResult = await _paymentAdapter.initiatePayment(
      amount: package.price,
      currency: package.currency,
      packageRef: package.id,
    );

    if (paymentResult.isLeft()) {
      return paymentResult.fold(
        Left.new,
        (_) => throw StateError('unreachable'),
      );
    }

    final paymentSuccess = paymentResult.getOrElse(
      () => throw StateError('unreachable'),
    );

    // ── Step 3: Create patient package record ─────────────────────────────────
    final now = DateTime.now();
    final expiryDate = now.add(Duration(days: package.validityDays));

    // Initialize servicesUsage with usedCount=0 for each service
    final servicesUsageInit = package.services.map((s) => s.serviceId).toList();

    final createResult = await _patientPackageRepo.createPatientPackage(
      patientId: patientId,
      packageId: package.id,
      clinicId: package.clinicId,
      status: PatientPackageStatus.active,
      purchaseDate: now,
      expiryDate: expiryDate,
      totalServicesCount: package.services.length,
      servicesUsageInit: servicesUsageInit,
      paymentTransactionId: paymentSuccess.transactionId,
      category: package.category.value,
    );

    return createResult;
  }
}
