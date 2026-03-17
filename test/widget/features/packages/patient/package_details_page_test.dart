import 'dart:async';

import 'package:elajtech/core/network/connectivity_provider.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/presentation/pages/package_details_page.dart';
import 'package:elajtech/features/packages/presentation/providers/packages_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockPurchaseNotifier extends StateNotifier<PurchaseNotifierState>
    implements PurchasePackageNotifier {
  // ignore: use_super_parameters, keep explicit parameter name for test readability
  MockPurchaseNotifier(PurchaseNotifierState state) : super(state);

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
    name: 'Package Details',
    shortDescription: 'Short description',
    description: 'Full details here',
    services: const [
      PackageServiceItem(
        serviceId: 's1',
        serviceType: ServiceType.visit,
        displayName: 'Visit',
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
    bool isPurchased = false,
  }) {
    return ProviderScope(
      overrides: [
        packageDetailsProvider((
          clinicId,
          packageId,
        )).overrideWith((ref) => packageFetcher()),
        purchasePackageProvider.overrideWith((ref) => mockNotifier),
        connectivityProvider.overrideWith((ref) => Stream.value(isOnline)),
        isPackagePurchasedProvider(packageId)
            .overrideWith((ref) => isPurchased),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: const PackageDetailsPage(
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
      expect(find.byKey(const Key('buy_button')), findsNothing);
    });

    testWidgets('shows package details and triggers purchase flow', (tester) async {
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

      expect(find.byKey(const Key('buy_button')), findsOneWidget);
      expect(find.byIcon(Icons.local_hospital), findsOneWidget);
      expect(find.textContaining('1500'), findsOneWidget);

      await tester.tap(find.byKey(const Key('buy_button')));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      final confirmButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(FilledButton),
      );
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(mockNotifier.purchaseCalled, isTrue);
      expect(mockNotifier.purchasedPackage?.id, dummyPackage.id);
    });

    testWidgets('disables effective purchase when offline', (tester) async {
      final mockNotifier = MockPurchaseNotifier(const PurchaseNotifierState());

      await tester.pumpWidget(
        createSubject(
          packageFetcher: () async => dummyPackage,
          mockNotifier: mockNotifier,
          isOnline: false,
        ),
      );
      await tester.pumpAndSettle();

      final buyButton = tester.widget<FilledButton>(
        find.byKey(const Key('buy_button')),
      );
      expect(buyButton.onPressed, isNull);

      expect(mockNotifier.purchaseCalled, isFalse);
    });

    testWidgets('shows owned-state action when already purchased', (tester) async {
      final mockNotifier = MockPurchaseNotifier(
        const PurchaseNotifierState(
          purchaseState: PurchaseState.alreadyPurchased,
        ),
      );

      await tester.pumpWidget(
        createSubject(
          packageFetcher: () async => dummyPackage,
          mockNotifier: mockNotifier,
          isPurchased: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('buy_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('buy_button')));
      await tester.pumpAndSettle();

      expect(mockNotifier.purchaseCalled, isFalse);
    });

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
