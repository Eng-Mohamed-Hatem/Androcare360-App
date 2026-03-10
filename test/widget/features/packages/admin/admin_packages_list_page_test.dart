import 'dart:async';

import 'package:elajtech/core/constants/currency_constants.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/presentation/pages/admin_packages_list_page.dart';
import 'package:elajtech/features/packages/presentation/providers/admin_packages_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAdminPackagesListNotifier extends AdminPackagesListNotifier {
  MockAdminPackagesListNotifier(this.fetcher);
  final Future<List<PackageEntity>> Function() fetcher;

  @override
  Future<List<PackageEntity>> build() => fetcher();
}

void main() {
  final dummyPackageActive = PackageEntity(
    id: 'pkg1',
    clinicId: 'andrology',
    category: PackageCategory.andrologyInfertilityProstate,
    name: 'باقة نشطة',
    shortDescription: 'وصف',
    services: const [
      PackageServiceItem(
        serviceId: 's1',
        serviceType: ServiceType.visit,
        displayName: 'كشف',
      ),
    ],
    validityDays: 30,
    price: 1500,
    currency: CurrencyConstants.defaultCurrency,
    packageType: PackageType.both,
    status: PackageStatus.active,
    displayOrder: 1,
    isFeatured: true,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
    includesVideoConsultation: true,
    includesPhysicalVisit: true,
  );

  final dummyPackageInactive = PackageEntity(
    id: 'pkg2',
    clinicId: 'andrology',
    category: PackageCategory.andrologyInfertilityProstate,
    name: 'باقة غير نشطة',
    shortDescription: 'وصف',
    services: const [
      PackageServiceItem(
        serviceId: 's1',
        serviceType: ServiceType.visit,
        displayName: 'كشف',
      ),
    ],
    validityDays: 30,
    price: 1500,
    currency: CurrencyConstants.defaultCurrency,
    packageType: PackageType.both,
    status: PackageStatus.inactive,
    displayOrder: 2,
    isFeatured: true,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
    includesVideoConsultation: true,
    includesPhysicalVisit: true,
  );

  Widget createSubject(Future<List<PackageEntity>> Function() fetcher) {
    return ProviderScope(
      overrides: [
        adminSelectedClinicProvider.overrideWith((ref) => 'andrology'),
        adminPackagesListProvider.overrideWith(
          () => MockAdminPackagesListNotifier(fetcher),
        ),
      ],
      child: const MaterialApp(
        home: AdminPackagesListPage(),
      ),
    );
  }

  group('AdminPackagesListPage Widget Tests', () {
    testWidgets('shows loading state initially', (tester) async {
      final completer = Completer<List<PackageEntity>>();
      await tester.pumpWidget(createSubject(() => completer.future));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state', (tester) async {
      await tester.pumpWidget(createSubject(() async => []));
      await tester.pumpAndSettle();

      expect(find.text('لا توجد باقات'), findsOneWidget);
    });

    testWidgets('shows error state', (tester) async {
      await tester.pumpWidget(
        createSubject(() async {
          throw Exception('Test Error');
        }),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Test Error'), findsOneWidget);
    });

    testWidgets(
      'shows list with active and inactive packages in correct tabs',
      (tester) async {
        await tester.pumpWidget(
          createSubject(() async => [dummyPackageActive, dummyPackageInactive]),
        );
        await tester.pumpAndSettle();

        // Default tab is "النشطة" (Active)
        expect(find.text('باقة نشطة'), findsOneWidget);
        expect(
          find.text('باقة غير نشطة'),
          findsNothing,
        ); // not visible in active tab

        // Switch to "غير النشطة / المخفية" tab
        await tester.tap(find.text('غير النشطة / المخفية'));
        await tester.pumpAndSettle();

        expect(find.text('باقة غير نشطة'), findsOneWidget);
        expect(find.text('باقة نشطة'), findsNothing);
      },
    );

    testWidgets('shows actions and can trigger duplicate dialog', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject(() async => [dummyPackageActive]));
      await tester.pumpAndSettle();

      // Find "نسخ" button
      expect(find.text('نسخ'), findsOneWidget);
      await tester.tap(find.text('نسخ'));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('نسخ الباقة'), findsOneWidget);
      expect(find.textContaining('نعم، انسخ'), findsOneWidget);
    });
  });
}
