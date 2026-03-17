/// PackagePaymentAdapterImpl — تطبيق مُحوِّل الدفع (Data Layer / Stub)
///
/// هذا التطبيق عبارة عن stub مؤقت للمرحلة الثانية.
/// التكامل الحقيقي مع بوابة الدفع مُقرَّر للمرحلة الخامسة.
///
/// **English**: Data-layer stub implementation of `PackagePaymentAdapter` (R6).
/// Phase 2 stub — throws `UnimplementedError` with a clear message so that
/// any accidental call during testing fails visibly rather than silently.
///
/// The real payment gateway integration is deferred to Phase 5.
/// Use `FakePaymentService` (in `test/helpers/`) for all test scenarios.
///
/// **Annotated**: `@LazySingleton(as: PackagePaymentAdapter)` — this is the
/// binding that tells GetIt which concrete class to use when
/// `PackagePaymentAdapter` is requested.
///
/// **Spec**: plan.md §Payment adapter layering (R6), tasks.md T003b.
library;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:elajtech/features/packages/domain/adapters/package_payment_adapter.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';

/// Phase-2 stub implementation of `PackagePaymentAdapter`.
///
/// **English**
/// Throws `UnimplementedError` on `initiatePayment` with a descriptive message.
/// Replace this class body in Phase 5 with the real payment SDK call.
/// Tests should use `FakePaymentService` via Riverpod `overrideWith` instead
/// of this class.
///
/// **Arabic**
/// تطبيق stub للمرحلة الثانية. يُلقي `UnimplementedError` عند الاستدعاء.
/// يُستبدَل في المرحلة الخامسة بالتكامل الحقيقي مع بوابة الدفع.
@LazySingleton(as: PackagePaymentAdapter)
class PackagePaymentAdapterImpl implements PackagePaymentAdapter {
  /// Creates a `PackagePaymentAdapterImpl`.
  const PackagePaymentAdapterImpl();

  /// ⚠️ STUB — throws `UnimplementedError`. Real integration pending Phase 5.
  ///
  /// ⚠️ STUB — يُلقي `UnimplementedError`. التكامل الحقيقي في المرحلة الخامسة.
  @override
  Future<Either<PaymentFailure, PaymentSuccess>> initiatePayment({
    required double amount,
    required String currency,
    required String packageRef,
  }) async {
    throw UnimplementedError(
      'PackagePaymentAdapterImpl.initiatePayment is not yet implemented. '
      'Real payment gateway integration is scheduled for Phase 5. '
      'Use FakePaymentService via Riverpod overrideWith in tests.',
    );
  }
}
