/// packages_provider.dart — مزودو Riverpod لميزة الباقات (Patient Browse & Buy)
///
/// يحتوي هذا الملف على مزودَي FutureProvider وكيان الشراء الخاص بحالة استخدام
/// شراء الباقة. مُصمَّم ليُستخدَم حصريًا في شاشات تصفح وشراء الباقات (US1).
///
/// **English**: Riverpod providers for Phase 3 US1 (Patient Browse & Buy).
/// Providers:
/// - [categoryPackagesProvider]: loads all ACTIVE packages for a clinic/category.
/// - [packageDetailsProvider]: loads a single package by clinicId + packageId.
/// - [purchasePackageProvider]: StateNotifier managing the purchase button state.
///
/// **R4 (Auth Safety)**: Always read `ref.watch(authProvider).user` — NEVER use `!`.
/// **R6 (Payment Adapter)**: Use the domain-layer [PackagePaymentAdapter] only via DI.
///
/// **Spec**: spec.md §US1, tasks.md T033.
library;

import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/packages/data/datasources/firestore_package_datasource.dart';
import 'package:elajtech/features/packages/data/repositories/clinic_package_repository_impl.dart';
import 'package:elajtech/features/packages/domain/adapters/package_payment_adapter.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart'
    show PackageRepository;
import 'package:elajtech/features/packages/domain/repositories/patient_package_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/get_package_details_usecase.dart';
import 'package:elajtech/features/packages/domain/usecases/list_category_packages_usecase.dart';
import 'package:elajtech/features/packages/domain/usecases/purchase_package_usecase.dart';
import 'package:elajtech/features/packages/presentation/providers/my_packages_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Repository helper
// ─────────────────────────────────────────────────────────────────────────────

/// Returns the correct per-clinic [PackageRepository] implementation for [clinicId].
///
/// **English**: Selects the concrete per-clinic implementation at runtime.
/// Per-clinic repos are NOT registered in GetIt; Riverpod selects them here.
///
/// **Arabic**: يُعيد تطبيق المستودع المناسب حسب معرف العيادة.
/// المستودعات الخمسة ليست مُسجَّلة في GetIt — يختارها Riverpod هنا.
BaseClinicPackageRepository _repoForClinic(String clinicId) {
  final ds = getIt<FirestorePackageDatasource>();
  return switch (clinicId) {
    'andrology' => AndrologyPackageRepository(ds),
    'physiotherapy' => PhysiotherapyPackageRepository(ds),
    'internal_family' => InternalFamilyPackageRepository(ds),
    'nutrition' => NutritionPackageRepository(ds),
    'chronic_diseases' => ChronicDiseasesPackageRepository(ds),
    _ => AndrologyPackageRepository(ds), // safe fallback
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// categoryPackagesProvider
// ─────────────────────────────────────────────────────────────────────────────

/// Provider family: async list of ACTIVE packages for a given clinic / category.
///
/// **English**
/// Takes `(clinicId, category)` as a record parameter and fetches packages
/// from [ListCategoryPackagesUseCase]. Returns sorted list (featured first).
///
/// **Arabic**
/// مزوّد عائلة يُعيد قائمة الباقات النشطة لعيادة وفئة محددتَيْن.
///
/// **Usage / الاستخدام**:
/// ```dart
/// final packagesAsync = ref.watch(
///   categoryPackagesProvider((clinicId: 'andrology', category: PackageCategory.andrologyInfertilityProstate)),
/// );
/// ```
final FutureProviderFamily<
  List<PackageEntity>,
  ({PackageCategory category, String clinicId})
>
categoryPackagesProvider =
    FutureProvider.family<
      List<PackageEntity>,
      ({String clinicId, PackageCategory category})
    >((ref, params) async {
      final repo = _repoForClinic(params.clinicId);
      final useCase = ListCategoryPackagesUseCase(repo);

      final result = await useCase(
        clinicId: params.clinicId,
        category: params.category,
      );

      return result.fold(
        (failure) => throw _failureToException(failure),
        (packages) => packages,
      );
    });

// ─────────────────────────────────────────────────────────────────────────────
// packageDetailsProvider
// ─────────────────────────────────────────────────────────────────────────────

/// Provider family: async single package details.
///
/// **English**: Returns a [PackageEntity] for `(clinicId, packageId)`.
/// Throws typed exception on [ClinicUnavailableFailure] or [PackageNotFoundFailure].
///
/// **Arabic**: يُحمِّل تفاصيل باقة واحدة بمعرِّفَي العيادة والباقة.
///
/// **Usage / الاستخدام**:
/// ```dart
/// final detailAsync = ref.watch(
///   packageDetailsProvider(('andrology', 'pkg_001')),
/// );
/// ```
final FutureProviderFamily<PackageEntity, (String, String)>
packageDetailsProvider =
    FutureProvider.family<PackageEntity, (String clinicId, String packageId)>((
      ref,
      params,
    ) async {
      final (clinicId, packageId) = params;
      final repo = _repoForClinic(clinicId);
      final useCase = GetPackageDetailsUseCase(repo);

      final result = await useCase(clinicId: clinicId, packageId: packageId);

      return result.fold(
        (failure) => throw _failureToException(failure),
        (pkg) => pkg,
      );
    });

// ─────────────────────────────────────────────────────────────────────────────
// PurchaseState
// ─────────────────────────────────────────────────────────────────────────────

/// The possible states of the purchase button on the Package Details page.
///
/// **Arabic**: حالات زر الشراء في شاشة تفاصيل الباقة.
enum PurchaseState {
  /// Idle — button shows "اشترِ الآن".
  idle,

  /// Loading — button disabled, spinner shown.
  loading,

  /// Successful purchase — button shows "عرض الباقة".
  success,

  /// Package already active / pending — button shows "عرض الباقة".
  alreadyPurchased,

  /// Payment or other failure.
  failure,
}

// ─────────────────────────────────────────────────────────────────────────────
// PurchaseNotifierState
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable state holding [PurchaseState] and an optional failure message.
///
/// **Arabic**: حالة عملية الشراء مع رسالة الخطأ الاختيارية.
class PurchaseNotifierState {
  /// Creates a [PurchaseNotifierState].
  const PurchaseNotifierState({
    this.purchaseState = PurchaseState.idle,
    this.failureMessage,
    this.purchasedPatientPackageId,
  });

  /// Current UI state of the purchase button.
  final PurchaseState purchaseState;

  /// Arabic failure message shown to the user on error.
  final String? failureMessage;

  /// The new patient-package ID on success — to navigate to My Packages.
  final String? purchasedPatientPackageId;

  /// Creates a copy with updated fields.
  PurchaseNotifierState copyWith({
    PurchaseState? purchaseState,
    String? failureMessage,
    bool clearFailure = false,
    String? purchasedPatientPackageId,
  }) => PurchaseNotifierState(
    purchaseState: purchaseState ?? this.purchaseState,
    failureMessage: clearFailure
        ? null
        : (failureMessage ?? this.failureMessage),
    purchasedPatientPackageId:
        purchasedPatientPackageId ?? this.purchasedPatientPackageId,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PurchasePackageNotifier
// ─────────────────────────────────────────────────────────────────────────────

/// StateNotifier managing the package purchase button state.
///
/// **English**
/// Reads `authProvider` to get the patient UID (never `!`).
/// Delegates purchase logic to [PurchasePackageUseCase].
///
/// **Arabic**
/// يُدير حالة زر شراء الباقة. يقرأ [authProvider] لمعرفة UID المريض
/// ولا يستخدم عامل التحقق `!` أبدًا (R4).
///
/// **Usage**:
/// ```dart
/// final state = ref.watch(purchasePackageProvider);
/// ref.read(purchasePackageProvider.notifier).purchase(package);
/// ```
class PurchasePackageNotifier extends StateNotifier<PurchaseNotifierState> {
  /// Creates the notifier with a Riverpod [Ref] for reading other providers.
  PurchasePackageNotifier(this._ref) : super(const PurchaseNotifierState());

  final Ref _ref;

  /// Executes the full purchase flow for [package].
  ///
  /// Updates internal state throughout, which the UI reacts to.
  /// Reads `authProvider.user` safely — returns early if user is null (R4).
  ///
  /// **Arabic**: ينفِّذ عملية الشراء الكاملة ويُحدِّث الحالة.
  Future<void> purchase(PackageEntity package) async {
    // R4 Auth Safety: safe null check — never use !
    final user = _ref.read(authProvider).user;
    if (user == null) {
      if (kDebugMode) {
        debugPrint(
          '[PurchasePackageNotifier] user is null — aborting purchase',
        );
      }
      state = state.copyWith(
        purchaseState: PurchaseState.failure,
        failureMessage: 'يجب تسجيل الدخول أولاً',
      );
      return;
    }

    // Begin loading
    state = state.copyWith(
      purchaseState: PurchaseState.loading,
      clearFailure: true,
    );

    final patientPackageRepo = getIt<PatientPackageRepository>();
    final paymentAdapter = getIt<PackagePaymentAdapter>();
    final useCase = PurchasePackageUseCase(
      patientPackageRepository: patientPackageRepo,
      paymentAdapter: paymentAdapter,
    );

    if (kDebugMode) {
      debugPrint(
        '[PurchasePackageNotifier] purchase userId=${user.id} '
        'pkgId=${package.id} clinicId=${package.clinicId}',
      );
    }

    final result = await useCase(
      PurchasePackageParams(
        patientId: user.id,
        package: package,
        isTestPurchase: true, // Simulation bypass — replace with false when payment gateway (R6) is integrated
      ),
    );

    result.fold(
      (failure) {
        if (failure is PackageAlreadyActiveFailure) {
          state = state.copyWith(
            purchaseState: PurchaseState.alreadyPurchased,
            clearFailure: true,
          );
        } else {
          state = state.copyWith(
            purchaseState: PurchaseState.failure,
            failureMessage: _failureMessage(failure),
          );
        }
      },
      (patientPackageId) {
        if (kDebugMode) {
          debugPrint(
            '[PurchasePackageNotifier] purchase OK ppId=$patientPackageId',
          );
        }
        state = state.copyWith(
          purchaseState: PurchaseState.success,
          purchasedPatientPackageId: patientPackageId,
          clearFailure: true,
        );
      },
    );
  }

  /// Resets purchase state to idle.
  ///
  /// يُعيد حالة الشراء إلى الوضع الابتدائي.
  void reset() => state = const PurchaseNotifierState();
}

/// The [StateNotifierProvider] exposing [PurchasePackageNotifier].
///
/// مزوّد StateNotifier لعملية شراء الباقة.
final AutoDisposeStateNotifierProvider<
  PurchasePackageNotifier,
  PurchaseNotifierState
>
purchasePackageProvider =
    StateNotifierProvider.autoDispose<
      PurchasePackageNotifier,
      PurchaseNotifierState
    >(
      PurchasePackageNotifier.new,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Private helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Converts a [Failure] to an [Exception] for FutureProvider error state.
Exception _failureToException(Failure failure) {
  if (failure is ClinicUnavailableFailure) {
    return Exception('العيادة غير متاحة حاليًا');
  }
  if (failure is PackageNotFoundFailure) {
    return Exception('الباقة غير موجودة');
  }
  if (failure is NetworkFailure) {
    return Exception('خطأ في الاتصال — تحقق من الإنترنت وأعد المحاولة');
  }
  return Exception(failure.message);
}

/// Converts a [Failure] to an Arabic user-facing message.
///
/// يُحوِّل الفشل إلى رسالة عربية للمستخدم.
String _failureMessage(Failure failure) {
  if (failure is PackageAlreadyActiveFailure) {
    return 'لديك باقة نشطة بالفعل من هذا النوع';
  }
  if (failure is PaymentFailure) {
    return 'فشل الدفع — تحقق من بياناتك وأعد المحاولة';
  }
  if (failure is NetworkFailure) {
    return 'خطأ في الاتصال — تحقق من الإنترنت وأعد المحاولة';
  }
  if (failure is ClinicUnavailableFailure) {
    return 'العيادة غير متاحة حاليًا';
  }
  return failure.message.isNotEmpty ? failure.message : 'حدث خطأ غير متوقع';
}

/// Provider to check if the current patient already owns a specific package.
/// Used for purchase button state persistence.
final ProviderFamily<bool, String>
isPackagePurchasedProvider = Provider.family<bool, String>((
  ref,
  packageId,
) {
  final authState = ref.watch(authProvider);
  final user = authState.user;
  if (user == null) return false;

  // Uses the global myPackagesProvider defined in my_packages_provider.dart
  // Note: MyPackagesNotifier already watches authProvider internally to get the patientId.
  final myPackagesAsync = ref.watch(myPackagesProvider);

  return myPackagesAsync.when(
    data: (List<PatientPackageEntity> packages) =>
        packages.any((p) => p.packageId == packageId),
    loading: () => false,
    error: (Object e, StackTrace st) {
      if (kDebugMode) {
        debugPrint('[isPackagePurchasedProvider] Error checking purchase: $e');
      }
      return false;
    },
  );
});
