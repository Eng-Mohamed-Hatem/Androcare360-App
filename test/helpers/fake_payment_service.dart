/// FakePaymentService — خدمة دفع وهمية للاختبار
///
/// تُنفِّذ هذه الخدمة [PackagePaymentAdapter] وتُستخدَم في الاختبارات
/// بدلاً من [PackagePaymentAdapterImpl].
///
/// **English**: Test helper implementing [PackagePaymentAdapter] with a
/// configurable `shouldSucceed` flag. Used in unit and integration tests via
/// Riverpod `overrideWith` to avoid triggering real payment flows.
///
/// **Riverpod overrideWith pattern** (for integration tests):
/// ```dart
/// final container = ProviderContainer(
///   overrides: [
///     packagePaymentAdapterProvider.overrideWithValue(
///       FakePaymentService(shouldSucceed: true),
///     ),
///   ],
/// );
/// ```
///
/// **Mockito pattern** (for unit tests — recommended for PurchasePackageUseCase):
/// ```dart
/// final mock = MockPackagePaymentAdapter(); // @GenerateMocks([PackagePaymentAdapter])
/// when(mock.initiatePayment(...)).thenAnswer((_) async => Right(PaymentSuccess(...)));
/// ```
///
/// **Arabic**
/// خدمة دفع وهمية للاختبار. تُستخدَم مع Riverpod `overrideWith` في
/// اختبارات التكامل أو مع Mockito في اختبارات الوحدة.
///
/// **Spec**: tasks.md T003b, spec.md §7.14 (R6).
library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/features/packages/data/adapters/package_payment_adapter_impl.dart' show PackagePaymentAdapterImpl;
import 'package:elajtech/features/packages/domain/adapters/package_payment_adapter.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';

/// Fake implementation of [PackagePaymentAdapter] for test use only.
///
/// **English**
/// When [shouldSucceed] is `true` (default), returns a fixed [PaymentSuccess]
/// with transactionId = [fixedTransactionId].
/// When `false`, returns a [PaymentFailure] with an Arabic error message.
///
/// **Arabic**
/// عند [shouldSucceed] = `true` (الافتراضي): يُعيد [PaymentSuccess] بمعرف
/// معاملة ثابت [fixedTransactionId].
/// عند `false`: يُعيد [PaymentFailure] برسالة خطأ عربية.
///
/// **Usage example / مثال الاستخدام**:
/// ```dart
/// // Happy path
/// final fake = FakePaymentService();
/// final result = await fake.initiatePayment(amount: 100, currency: 'EGP', packageRef: 'pkg');
/// expect(result.isRight(), isTrue);
///
/// // Failure path
/// final fakeFail = FakePaymentService(shouldSucceed: false);
/// final failResult = await fakeFail.initiatePayment(amount: 100, currency: 'EGP', packageRef: 'pkg');
/// expect(failResult.isLeft(), isTrue);
/// ```
class FakePaymentService implements PackagePaymentAdapter {
  /// Creates a [FakePaymentService].
  ///
  /// [shouldSucceed]: controls whether the fake returns success or failure.
  /// [fixedTransactionId]: the transaction ID returned on success.
  /// [simulatedDelayMs]: optional delay to simulate network latency.
  FakePaymentService({
    this.shouldSucceed = true,
    this.fixedTransactionId = 'FAKE_TXN_001',
    this.simulatedDelayMs = 0,
  });

  /// Whether this fake should return success (true) or failure (false).
  ///
  /// هل يُعيد الوهمي نجاحًا أم فشلًا؟
  final bool shouldSucceed;

  /// Fixed transaction ID returned in the success result.
  ///
  /// معرف المعاملة الثابت المُعاد عند النجاح.
  final String fixedTransactionId;

  /// Optional simulated network delay in milliseconds.
  ///
  /// تأخير شبكي افتراضي بالميلي ثانية (للاختبارات الواقعية).
  final int simulatedDelayMs;

  @override
  Future<Either<PaymentFailure, PaymentSuccess>> initiatePayment({
    required double amount,
    required String currency,
    required String packageRef,
  }) async {
    if (simulatedDelayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: simulatedDelayMs));
    }

    if (shouldSucceed) {
      return Right(
        PaymentSuccess(
          transactionId: fixedTransactionId,
          amount: amount,
          currency: currency,
        ),
      );
    } else {
      return const Left(
        PaymentFailure('فشلت عملية الدفع. يرجى التحقق من بيانات الدفع.'),
      );
    }
  }
}
