/// my_packages_provider.dart — مزودو Riverpod لـ «باقاتي» (US2)
///
/// يحتوي هذا الملف على مزودَيْ Riverpod الخاصَّيْن بتبويب «باقاتي»:
/// - [myPackagesProvider]: قائمة كل الباقات المشتراة للمريض الحالي.
/// - [patientPackageDetailProvider]: تفاصيل باقة واحدة + مستنداتها.
///
/// **English**: Riverpod providers for Phase 4 US2 (Patient My Packages tab).
/// - [myPackagesProvider]: AsyncNotifierProvider returning all purchased
///   packages for the current patient, sorted newest-first.
/// - [patientPackageDetailProvider]: family AsyncNotifierProvider for a single
///   package's entity and documents.
///
/// **R4 (Auth Safety)**: Both providers null-check `authProvider.user` and
/// return an empty/error state rather than using `!`.
///
/// **Spec**: tasks.md T046, spec.md §4.2, §8.1.
library;

import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/repositories/package_document_repository.dart';
import 'package:elajtech/features/packages/domain/repositories/patient_package_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/get_patient_package_details_usecase.dart';
import 'package:elajtech/features/packages/domain/usecases/get_patient_packages_usecase.dart';
import 'package:elajtech/features/packages/presentation/providers/packages_provider.dart'
    show purchasePackageProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MyPackagesNotifier
// ─────────────────────────────────────────────────────────────────────────────

/// AsyncNotifier that holds the list of patient package purchases.
///
/// **English**
/// Reads `authProvider` to get `patientId` (never uses `!` — R4).
/// Watches [purchasePackageProvider] and auto-refreshes on a successful
/// purchase so the My Packages tab stays in sync without manual navigation.
///
/// **Arabic**
/// يقرأ `authProvider` بأمان للحصول على `patientId`، ويراقب
/// `purchasePackageProvider` ليُعيد التحميل تلقائيًا بعد كل شراء ناجح.
class MyPackagesNotifier extends AsyncNotifier<List<PatientPackageEntity>> {
  @override
  Future<List<PatientPackageEntity>> build() async {
    // R4: safe null check — never use !
    final user = ref.watch(authProvider).user;
    if (user == null) {
      if (kDebugMode) {
        debugPrint('[MyPackagesNotifier] user is null — returning empty list');
      }
      return [];
    }

    // Auto-refresh when a purchase succeeds
    final purchaseState = ref.watch(purchasePackageProvider).purchaseState;
    if (kDebugMode) {
      debugPrint(
        '[MyPackagesNotifier] build — userId=${user.id} '
        'purchaseState=$purchaseState',
      );
    }

    final repo = getIt<PatientPackageRepository>();
    final useCase = GetPatientPackagesUseCase(repo);

    final result = await useCase(
      patientId: user.id,
      now: DateTime.now(),
    );

    return result.fold(
      (failure) => throw _failureToException(failure),
      (list) => list,
    );
  }

  /// Manually refreshes the packages list.
  ///
  /// يُحدِّث قائمة الباقات يدويًا (مثلاً بعد السحب للتحديث).
  Future<void> refresh() async => ref.invalidateSelf();
}

/// The [AsyncNotifierProvider] for My Packages.
///
/// مزوّد AsyncNotifier لقائمة باقاتي.
final myPackagesProvider =
    AsyncNotifierProvider<MyPackagesNotifier, List<PatientPackageEntity>>(
      MyPackagesNotifier.new,
    );

// ─────────────────────────────────────────────────────────────────────────────
// PatientPackageDetailNotifier
// ─────────────────────────────────────────────────────────────────────────────

/// AsyncNotifier for a single patient package's details + documents.
///
/// **English**
/// Family parameter is `patientPackageId`. Null-checks `authProvider.user`
/// (R4) before fetching. Uses [GetPatientPackageDetailsUseCase] which enforces
/// R2 (notes = null) at the repository level.
///
/// **Arabic**
/// مُعامِل العائلة هو `patientPackageId`. يُراجع المستخدم أولاً (R4).
/// يُفوِّض إلى [GetPatientPackageDetailsUseCase] الذي يُطبِّق R2.
class PatientPackageDetailNotifier
    extends FamilyAsyncNotifier<PatientPackageDetailsResult, String> {
  @override
  Future<PatientPackageDetailsResult> build(String patientPackageId) async {
    // R4: safe null check — never use !
    final user = ref.watch(authProvider).user;
    if (user == null) {
      if (kDebugMode) {
        debugPrint(
          '[PatientPackageDetailNotifier] user is null — cannot load details',
        );
      }
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    if (kDebugMode) {
      debugPrint(
        '[PatientPackageDetailNotifier] build — userId=${user.id} '
        'ppId=$patientPackageId',
      );
    }

    final packageRepo = getIt<PatientPackageRepository>();
    final documentRepo = getIt<PackageDocumentRepository>();
    final useCase = GetPatientPackageDetailsUseCase(
      patientPackageRepository: packageRepo,
      documentRepository: documentRepo,
    );

    final result = await useCase(
      patientId: user.id,
      patientPackageId: patientPackageId,
    );

    return result.fold(
      (failure) => throw _failureToException(failure),
      (details) => details,
    );
  }
}

/// Family provider for a single patient package's details.
///
/// مزوّد العائلة لتفاصيل باقة واحدة.
///
/// **Usage / الاستخدام**:
/// ```dart
/// final detailAsync = ref.watch(
///   patientPackageDetailProvider('pp_001'),
/// );
/// ```
final AsyncNotifierProviderFamily<
  PatientPackageDetailNotifier,
  PatientPackageDetailsResult,
  String
>
patientPackageDetailProvider =
    AsyncNotifierProvider.family<
      PatientPackageDetailNotifier,
      PatientPackageDetailsResult,
      String
    >(
      PatientPackageDetailNotifier.new,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Private helper
// ─────────────────────────────────────────────────────────────────────────────

/// Converts a [Failure] to an [Exception] for AsyncNotifier error state.
///
/// يُحوِّل الفشل إلى استثناء لحالة خطأ AsyncNotifier.
Exception _failureToException(Failure failure) {
  return Exception(
    failure.message.isNotEmpty
        ? failure.message
        : 'حدث خطأ أثناء تحميل الباقات',
  );
}
