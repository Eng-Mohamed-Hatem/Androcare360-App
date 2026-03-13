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
    name: '???? ????',
    shortDescription: '???',
    services: const [
      PackageServiceItem(
        serviceId: 's1',
        serviceType: ServiceType.visit,
        displayName: '???',
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
    name: '???? ??? ????',
    shortDescription: '???',
    services: const [
      PackageServiceItem(
        serviceId: 's1',
        serviceType: ServiceType.visit,
        displayName: '???',
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

      expect(find.text('?? ???? ?????'), findsOneWidget);
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

        expect(find.text('???? ????'), findsOneWidget);
        expect(find.text('???? ??? ????'), findsNothing);

        await tester.tap(find.text('??? ?????? / ???????'));
        await tester.pumpAndSettle();

        expect(find.text('???? ??? ????'), findsOneWidget);
        expect(find.text('???? ????'), findsNothing);
      },
    );

    testWidgets('shows actions and can trigger duplicate dialog', (tester) async {
      await tester.pumpWidget(createSubject(() async => [dummyPackageActive]));
      await tester.pumpAndSettle();

      expect(find.text('???'), findsOneWidget);
      await tester.tap(find.text('???'));
      await tester.pumpAndSettle();

      expect(find.text('??? ??????'), findsOneWidget);
      expect(find.textContaining('???? ????'), findsOneWidget);
    });

    testWidgets('keeps bottom-safe padding for package list', (tester) async {
      await tester.pumpWidget(createSubject(() async => [dummyPackageActive]));
      await tester.pumpAndSettle();

      final listView = tester.widget<ListView>(find.byType(ListView).first);
      expect(listView.padding, const EdgeInsets.fromLTRB(16, 16, 16, 120));
    });
  });
}
