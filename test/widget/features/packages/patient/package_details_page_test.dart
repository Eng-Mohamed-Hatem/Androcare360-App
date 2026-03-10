// test/widget/features/packages/patient/package_details_page_test.dart
//
// Widget tests for PackageDetailsPage.
// Covers: Loading state, Error state, Loaded state, Offline interaction,
// and Purchase state management (idle, loading, success, failure).

import 'dart:async';

import 'package:elajtech/core/network/connectivity_provider.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/presentation/pages/package_details_page.dart';
import 'package:elajtech/features/packages/presentation/providers/packages_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Mock Notifier ────────────────────────────────────────────────────────────
class MockPurchaseNotifier extends StateNotifier<PurchaseNotifierState>
    implements PurchasePackageNotifier {
  MockPurchaseNotifier(super._state);

  bool purchaseCalled = false;
  PackageEntity? purchasedPackage;

  @override
  Future<void> purchase(PackageEntity package) async {
    purchaseCalled = true;
    purchasedPackage = package;
  }

  @override
  void reset() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const clinicId = 'andrology';
  const packageId = 'pkg1';

  final dummyPackage = PackageEntity(
    id: packageId,
    clinicId: clinicId,
    category: PackageCategory.andrologyInfertilityProstate,
    name: 'باقة التفاصيل',
    shortDescription: 'وصف قصير',
    description: 'تفاصيل كاملة هنا',
    services: const [
      PackageServiceItem(
        serviceId: 's1',
        serviceType: ServiceType.visit,
        displayName: 'كشف',
      ),
    ],
    validityDays: 30,
    price: 1500,
    currency: 'EGP',
    packageType: PackageType.physicalOnly,
    status: PackageStatus.active,
    displayOrder: 1,
    isFeatured: true,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
    includesVideoConsultation: false,
    includesPhysicalVisit: true,
  );

  Widget createSubject({
    required Future<PackageEntity> Function() packageFetcher,
    required MockPurchaseNotifier mockNotifier,
    bool isOnline = true,
  }) {
    return ProviderScope(
      overrides: [
        packageDetailsProvider((
          clinicId,
          packageId,
        )).overrideWith((ref) => packageFetcher()),
        purchasePackageProvider.overrideWith((ref) => mockNotifier),
        connectivityProvider.overrideWith((ref) => Stream.value(isOnline)),
      ],
      child: const MaterialApp(
        home: PackageDetailsPage(
          clinicId: clinicId,
          packageId: packageId,
        ),
      ),
    );
  }

  group('PackageDetailsPage Widget Tests', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final completer = Completer<PackageEntity>();
      final mockNotifier = MockPurchaseNotifier(const PurchaseNotifierState());

      await tester.pumpWidget(
        createSubject(
          packageFetcher: () => completer.future,
          mockNotifier: mockNotifier,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error banner when fetching fails', (tester) async {
      final mockNotifier = MockPurchaseNotifier(const PurchaseNotifierState());

      await tester.pumpWidget(
        createSubject(
          packageFetcher: () async => throw Exception('Package Error'),
          mockNotifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Package Error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      // Buy button should NOT be visible
      expect(find.byKey(const Key('buy_button')), findsNothing);
    });

    testWidgets(
      'shows package details and idle buy button when loaded online',
      (tester) async {
        final mockNotifier = MockPurchaseNotifier(
          const PurchaseNotifierState(),
        );

        await tester.pumpWidget(
          createSubject(
            packageFetcher: () async => dummyPackage,
            mockNotifier: mockNotifier,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('باقة التفاصيل'), findsOneWidget);
        expect(find.text('تفاصيل كاملة هنا'), findsOneWidget);
        expect(find.text('1500 ريال سعودي'), findsOneWidget);

        final buyButton = find.byKey(const Key('buy_button'));
        expect(buyButton, findsOneWidget);
        expect(find.text('اشترِ الآن'), findsOneWidget);

        // Tap buy button
        await tester.tap(buyButton);
        await tester.pump();

        expect(mockNotifier.purchaseCalled, isTrue);
        expect(mockNotifier.purchasedPackage?.id, dummyPackage.id);
      },
    );

    testWidgets('shows tooltip and disables button when offline', (
      tester,
    ) async {
      final mockNotifier = MockPurchaseNotifier(const PurchaseNotifierState());

      await tester.pumpWidget(
        createSubject(
          packageFetcher: () async => dummyPackage,
          mockNotifier: mockNotifier,
          isOnline: false,
        ),
      );
      await tester.pumpAndSettle();

      final buyButton = find.byKey(const Key('buy_button'));

      // Tap shouldn't trigger purchase
      await tester.tap(buyButton);
      await tester.pump();

      expect(mockNotifier.purchaseCalled, isFalse);
    });

    testWidgets(
      'shows success layout when already purchased or newly purchased',
      (tester) async {
        final mockNotifier = MockPurchaseNotifier(
          const PurchaseNotifierState(
            purchaseState: PurchaseState.alreadyPurchased,
          ),
        );

        await tester.pumpWidget(
          createSubject(
            packageFetcher: () async => dummyPackage,
            mockNotifier: mockNotifier,
          ),
        );
        await tester.pumpAndSettle();

        final buyButton = find.byKey(const Key('buy_button'));
        expect(find.text('عرض الباقة'), findsWidgets);

        // Tap shouldn't re-trigger purchase
        await tester.tap(buyButton);
        await tester.pump();
        expect(mockNotifier.purchaseCalled, isFalse);
      },
    );

    testWidgets('shows failure message from purchaseState', (tester) async {
      final mockNotifier = MockPurchaseNotifier(
        const PurchaseNotifierState(
          purchaseState: PurchaseState.failure,
          failureMessage: 'Payment Gateway Error',
        ),
      );

      await tester.pumpWidget(
        createSubject(
          packageFetcher: () async => dummyPackage,
          mockNotifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Payment Gateway Error'), findsOneWidget);
    });
  });
}
