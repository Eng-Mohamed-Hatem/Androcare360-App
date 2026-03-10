/// PackagePaymentAdapter — واجهة مُحوِّل الدفع (Domain Layer)
///
/// هذه الواجهة هي الحد الفاصل بين طبقة المجال وأي بوابة دفع خارجية.
/// يعتمد عليها [PurchasePackageUseCase] دون أي معرفة بالتطبيق الفعلي.
///
/// **English**
/// Domain-layer adapter interface (R6 — Clean Architecture payment boundary).
/// `PurchasePackageUseCase` depends **only** on this abstract class.
/// The concrete implementation lives in the Data layer
/// (`PackagePaymentAdapterImpl`), keeping the Domain layer free of any
/// payment-SDK dependencies.
///
/// This file also defines the value types [PaymentSuccess] used by both
/// layers.
///
/// **Arabic**
/// واجهة طبقة المجال لبوابة الدفع (R6). لا تحتوي على أي اعتمادية على
/// حزمة دفع خارجية. واجهة مجردة تمامًا — التطبيق الفعلي في طبقة البيانات.
///
/// **Spec**: spec.md §7.14, plan.md §Payment adapter layering (R6).
library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/usecases/purchase_package_usecase.dart'
    show PurchasePackageUseCase;

// ─────────────────────────────────────────────────────────────────────────────
// PaymentSuccess value type
// ─────────────────────────────────────────────────────────────────────────────

/// Result value returned by a successful payment call.
///
/// **English**
/// Immutable value object. [transactionId] is the gateway-issued identifier
/// that `PurchasePackageUseCase` stores in `paymentTransactionId` of the
/// created patient-package document.
///
/// **Arabic**
/// كائن قيمة ثابت لنتيجة الدفع الناجحة. [transactionId] هو المعرف الصادر
/// من بوابة الدفع ويُخزَّن داخل سجل الشراء.
///
/// **Example / مثال**:
/// ```dart
/// const success = PaymentSuccess(
///   transactionId: 'TXN_20260307_0001',
///   amount: 499.0,
///   currency: 'SAR',
/// );
/// ```
class PaymentSuccess {
  /// Creates a [PaymentSuccess].
  const PaymentSuccess({
    required this.transactionId,
    required this.amount,
    required this.currency,
  });

  /// Gateway-issued transaction identifier — معرف المعاملة من بوابة الدفع.
  /// Stored in `paymentTransactionId` of the patient-package Firestore document.
  final String transactionId;

  /// Amount charged — المبلغ المدفوع.
  final double amount;

  /// Currency code (e.g. 'SAR') — رمز العملة.
  final String currency;

  @override
  String toString() =>
      'PaymentSuccess(txn: $transactionId, amount: $amount $currency)';
}

// ─────────────────────────────────────────────────────────────────────────────
// PackagePaymentAdapter
// ─────────────────────────────────────────────────────────────────────────────

/// Abstract adapter interface for initiating a package payment.
///
/// **English**
/// Domain-layer contract. Implemented in the Data layer by
/// `PackagePaymentAdapterImpl` (and by `FakePaymentService` in tests).
/// Use cases depend **only** on this type — never on the Data implementation.
///
/// The method returns:
/// - `Right(PaymentSuccess)` with a valid [PaymentSuccess.transactionId] on
///   success.
/// - `Left(PaymentFailure)` with an Arabic error message on failure.
///
/// **Arabic**
/// واجهة مجردة لبادئ عملية الدفع. يعتمد عليها [PurchasePackageUseCase] فقط.
/// التطبيق الفعلي في طبقة البيانات أو في خدمة الاختبار الوهمية.
///
/// **Usage example (in PurchasePackageUseCase) / مثال الاستخدام**:
/// ```dart
/// final result = await _paymentAdapter.initiatePayment(
///   amount: packageEntity.price,
///   currency: packageEntity.currency,
///   packageRef: packageEntity.id,
/// );
/// result.fold(
///   (failure) => Left(failure),
///   (success) async {
///     // create patient package with success.transactionId
///   },
/// );
/// ```
abstract class PackagePaymentAdapter {
  /// Initiates a payment for a clinic package.
  ///
  /// **Parameters**:
  /// - [amount]: Total amount to charge — المبلغ الإجمالي للمطالبة.
  /// - [currency]: Currency code (e.g. 'SAR') — رمز العملة.
  /// - [packageRef]: Package ID used as payment descriptor — معرف الباقة.
  ///
  /// **Returns**:
  /// - `Right(PaymentSuccess)` when the gateway confirms the charge.
  /// - `Left(PaymentFailure)` for any payment error (declined, timeout, etc.).
  ///
  /// يبدأ عملية الدفع ويُعيد إما نجاحًا مع معرف المعاملة أو فشلًا مكتوبًا.
  Future<Either<PaymentFailure, PaymentSuccess>> initiatePayment({
    required double amount,
    required String currency,
    required String packageRef,
  });
}
