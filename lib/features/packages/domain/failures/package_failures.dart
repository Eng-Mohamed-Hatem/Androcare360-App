// dart:core imports are implicit
import 'package:dartz/dartz.dart' show Either;
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/usecases/purchase_package_usecase.dart'
    show PurchasePackageUseCase;
import 'package:elajtech/features/packages/domain/usecases/update_clinic_package_usecase.dart'
    show UpdateClinicPackageUseCase;
import 'package:elajtech/features/packages/domain/usecases/upload_package_document_usecase.dart'
    show UploadPackageDocumentUseCase;

/// Package-specific failure types for the Clinic Packages Full Flow feature.
///
/// All failures extend the shared [Failure] base class from
/// `lib/core/error/failures.dart` and carry an Arabic user-facing [message].
///
/// Usage in use cases:
/// ```dart
/// return Left(const PackageAlreadyActiveFailure());
/// ```
///
/// --- English ---
/// These typed failures are returned by domain use cases via [Either].
/// No raw exceptions should escape the domain layer.
///
/// --- Arabic ---
/// هذه الأنواع المحددة من الإخفاقات تُعاد من حالات الاستخدام عبر [Either].
/// لا يجب أن تتجاوز الاستثناءات الخام طبقة المجال.

// ─────────────────────────────────────────────────────────────────────────────
// Purchase failures
// ─────────────────────────────────────────────────────────────────────────────

/// Returned by [PurchasePackageUseCase] when the patient already has an ACTIVE
/// or PENDING record for the requested packageId.
///
/// يُعاد هذا الإخفاق عند وجود سجل شراء نشط أو معلق لنفس الباقة.
class PackageAlreadyActiveFailure extends Failure {
  /// Creates a [PackageAlreadyActiveFailure] with a default Arabic message.
  const PackageAlreadyActiveFailure([
    super.message = 'لديك بالفعل باقة نشطة أو في انتظار التفعيل لهذا الخيار.',
  ]);
}

/// Returned when the payment gateway rejects or declines the payment.
///
/// يُعاد عند رفض بوابة الدفع للعملية.
class PaymentFailure extends Failure {
  /// Creates a [PaymentFailure] with a default Arabic message.
  const PaymentFailure([
    super.message = 'تعذر إتمام عملية الدفع، برجاء المحاولة مرة أخرى.',
  ]);
}

/// Returned when a network request fails or times out.
///
/// يُعاد عند انقطاع الاتصال أو انتهاء مهلة الطلب.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure] with a default Arabic message.
  const NetworkFailure([
    super.message =
        'لا يوجد اتصال بالإنترنت، برجاء التحقق من الاتصال والمحاولة مرة أخرى.',
  ]);
}

/// Returned when a clinic package document does not exist in Firestore.
///
/// يُعاد عند عدم العثور على الباقة المطلوبة.
class PackageNotFoundFailure extends Failure {
  /// Creates a [PackageNotFoundFailure] with a default Arabic message.
  const PackageNotFoundFailure([
    super.message = 'لم يتم العثور على الباقة المطلوبة.',
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Clinic / availability failures
// ─────────────────────────────────────────────────────────────────────────────

/// Returned when the parent clinic of a package is deactivated or deleted.
///
/// يُعاد عند تعطيل أو حذف العيادة المالكة للباقة.
class ClinicUnavailableFailure extends Failure {
  /// Creates a [ClinicUnavailableFailure] with a default Arabic message.
  const ClinicUnavailableFailure([
    super.message =
        'هذه الباقة غير متاحة حاليًا. يرجى التواصل مع العيادة للمزيد من المعلومات.',
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Optimistic-concurrency failures  (R1)
// ─────────────────────────────────────────────────────────────────────────────

/// Returned by [UpdateClinicPackageUseCase] when:
/// - the [loadedAt] timestamp is null (immediate guard — no Firestore read), OR
/// - the document's `updatedAt` in Firestore differs from [loadedAt].
///
/// يُعاد عند اكتشاف تعارض في التحديث المتزامن أو عند غياب [loadedAt].
class StaleDataFailure extends Failure {
  /// Creates a [StaleDataFailure] with a default Arabic message.
  const StaleDataFailure([
    super.message =
        'تم تعديل هذه الباقة من قِبل مستخدم آخر. الرجاء إعادة تحميل النموذج للاستمرار.',
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Upload failures
// ─────────────────────────────────────────────────────────────────────────────

/// Returned by [UploadPackageDocumentUseCase] when a document upload fails,
/// the file exceeds 20 MB, or the file type is not in {pdf, jpg, jpeg, png}.
///
/// يُعاد عند فشل رفع المستند أو تجاوز الحجم المسموح أو نوع الملف غير مدعوم.
class UploadFailure extends Failure {
  /// Creates an [UploadFailure] with a default Arabic message.
  const UploadFailure([
    super.message =
        'تعذر رفع الملف. تأكد أن الملف بصيغة PDF أو صورة ولا يتجاوز 20 ميجابايت.',
  ]);
}
