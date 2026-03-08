// test/widget/features/packages/patient/my_packages_page_test.dart
//
// Widget tests for [MyPackagesPage] — T052.
// Covers: loading spinner, empty state, data list with status/progress, EXPIRED status.

import 'dart:async';

import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/auth/domain/repositories/auth_repository.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/features/packages/presentation/pages/my_packages_page.dart';
import 'package:elajtech/features/packages/presentation/providers/my_packages_provider.dart';
import 'package:elajtech/features/packages/presentation/providers/packages_provider.dart'
    show
        PurchaseNotifierState,
        PurchasePackageNotifier,
        purchasePackageProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/annotations.dart';

// We mock the notifier to control provider state in tests.

@GenerateMocks([MyPackagesNotifier])
void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  final now = DateTime(2026, 3, 7, 12);

  PatientPackageEntity makePackage({
    String id = 'pp_001',
    PatientPackageStatus status = PatientPackageStatus.active,
    int used = 0,
    int total = 3,
    DateTime? expiryDate,
  }) {
    return PatientPackageEntity(
      id: id,
      patientId: 'uid_001',
      packageId: 'pkg_001',
      clinicId: 'andrology',
      category: PackageCategory.chronicDiseases,
      status: status,
      purchaseDate: now.subtract(const Duration(days: 5)),
      expiryDate: expiryDate ?? now.add(const Duration(days: 85)),
      totalServicesCount: total,
      usedServicesCount: used,
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(days: 5)),
    );
  }

  /// Pumps [MyPackagesPage] with full provider overrides.
  Future<void> pumpMyPackages(
    WidgetTester tester, {
    required AsyncValue<List<PatientPackageEntity>> packagesState,
  }) async {
    tester.view.physicalSize = const Size(1440, 2560);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override myPackagesProvider with controlled state
          myPackagesProvider.overrideWith(
            () => _FakeMyPackagesNotifier(packagesState),
          ),
          // Override purchase provider (dependency) with a no-op
          purchasePackageProvider.overrideWith(
            (ref) => _FakePurchasePackageNotifier(),
          ),
          // Override authProvider with logged-in user
          authProvider.overrideWith(
            (ref) => _FakeAuthNotifier(
              AuthState(
                user: _fakeUser(),
                isAuthenticated: true,
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('ar'),
          home: MyPackagesPage(),
        ),
      ),
    );
  }

  // ── T052-a: loading state ─────────────────────────────────────────────────
  testWidgets(
    'T052-a: shows CircularProgressIndicator while loading',
    (tester) async {
      await pumpMyPackages(
        tester,
        packagesState: const AsyncValue.loading(),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  // ── T052-b: empty state ───────────────────────────────────────────────────
  testWidgets(
    'T052-b: shows Arabic empty-state message and CTA when list is empty',
    (tester) async {
      await pumpMyPackages(
        tester,
        packagesState: const AsyncValue.data([]),
      );
      await tester.pump();

      expect(find.text('لم تشترِ أي باقة بعد…'), findsOneWidget);
      expect(find.text('تصفح الباقات'), findsOneWidget);
    },
  );

  // ── T052-c: data with ACTIVE status and progress ─────────────────────────
  testWidgets(
    'T052-c: shows "نشطة" status label and progress "0 / 2" for active package',
    (tester) async {
      final pkg = makePackage(
        id: 'pp_010',
        total: 2,
      );
      await pumpMyPackages(
        tester,
        packagesState: AsyncValue.data([pkg]),
      );
      await tester.pump();

      // Status badge
      expect(
        find.text(PatientPackageStatus.active.arabicLabel),
        findsOneWidget,
      );

      // Progress "0 / 2" — Directionality is LTR so numerals appear
      expect(find.text('0 / 2'), findsOneWidget);
    },
  );

  // ── T052-d: EXPIRED package label ────────────────────────────────────────
  testWidgets(
    'T052-d: shows "منتهية الصلاحية" badge for EXPIRED package',
    (tester) async {
      final pkg = makePackage(
        id: 'pp_exp',
        status: PatientPackageStatus.expired,
        used: 3,
      );
      await pumpMyPackages(
        tester,
        packagesState: AsyncValue.data([pkg]),
      );
      await tester.pump();

      expect(
        find.text(PatientPackageStatus.expired.arabicLabel),
        findsOneWidget,
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Fake notifiers for test isolation
// ─────────────────────────────────────────────────────────────────────────────

/// Fake [MyPackagesNotifier] returning a fixed [AsyncValue].
class _FakeMyPackagesNotifier extends MyPackagesNotifier {
  _FakeMyPackagesNotifier(this._state);
  final AsyncValue<List<PatientPackageEntity>> _state;

  @override
  Future<List<PatientPackageEntity>> build() async {
    return _state.when(
      data: (d) => d,
      loading: () => Completer<List<PatientPackageEntity>>().future,
      error: (e, _) => Future.error(e),
    );
  }
}

/// Fake [PurchasePackageNotifier] (no-op, to satisfy dependency).
class _FakePurchasePackageNotifier extends StateNotifier<PurchaseNotifierState>
    implements PurchasePackageNotifier {
  _FakePurchasePackageNotifier() : super(const PurchaseNotifierState());

  @override
  Future<void> purchase(PackageEntity package) async {}

  @override
  void reset() {}
}

class _FakeAuthRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initialState) : super(_FakeAuthRepo()) {
    state = _initialState;
  }
  final AuthState _initialState;

  @override
  Future<void> startPhoneVerification(String p) async {}
}

UserModel _fakeUser() => UserModel(
  id: 'test_uid',
  email: 'test@example.com',
  userType: UserType.patient,
  fullName: 'Test Patient',
  createdAt: DateTime.now(),
);
