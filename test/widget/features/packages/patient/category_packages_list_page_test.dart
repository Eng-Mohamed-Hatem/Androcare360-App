// test/widget/features/packages/patient/category_packages_list_page_test.dart
//
// Widget tests for CategoryPackagesListPage.
// Covers: Loading state, Empty state, Error state (+retry), and Data state (List).

import 'dart:async';

import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/presentation/pages/category_packages_list_page.dart';
import 'package:elajtech/features/packages/presentation/providers/packages_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const clinicId = 'andrology';
  const category = PackageCategory.andrologyInfertilityProstate;
  const pageTitle = 'باقات الذكورة';

  final dummyPackage = PackageEntity(
    id: 'pkg1',
    clinicId: clinicId,
    category: category,
    name: 'باقة الاختبار',
    shortDescription: 'وصف',
    services: const [
      PackageServiceItem(
        serviceId: 's1',
        serviceType: ServiceType.visit,
        displayName: 'كشف',
      ),
    ],
    validityDays: 30,
    price: 100,
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

  Widget createSubject(Future<List<PackageEntity>> Function() fetcher) {
    return ProviderScope(
      overrides: [
        categoryPackagesProvider((
          clinicId: clinicId,
          category: category,
        )).overrideWith((ref) => fetcher()),
      ],
      child: const MaterialApp(
        home: CategoryPackagesListPage(
          clinicId: clinicId,
          category: category,
          pageTitle: pageTitle,
        ),
      ),
    );
  }

  group('CategoryPackagesListPage Widget Tests', () {
    testWidgets('shows loading indicator initially', (tester) async {
      // Returns a future that never completes
      final completer = Completer<List<PackageEntity>>();

      await tester.pumpWidget(createSubject(() => completer.future));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(pageTitle), findsOneWidget);
    });

    testWidgets('shows empty state when data is empty', (tester) async {
      await tester.pumpWidget(createSubject(() async => []));
      await tester.pumpAndSettle();

      expect(
        find.text('لا توجد باقات متاحة في هذا القسم حاليًا'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('shows error state with retry button', (tester) async {
      var fetchCount = 0;
      await tester.pumpWidget(
        createSubject(() async {
          fetchCount++;
          throw Exception('Network Error');
        }),
      );
      await tester.pumpAndSettle();

      expect(find.text('Network Error'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
      expect(fetchCount, 1);

      // Tap retry
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pump();

      // verify ref.invalidate caused a re-fetch
      expect(fetchCount, 2);
    });

    testWidgets('shows list of packages on success', (tester) async {
      await tester.pumpWidget(createSubject(() async => [dummyPackage]));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('packages_list')), findsOneWidget);
      expect(find.text('باقة الاختبار'), findsOneWidget);
      expect(find.text('100 جنيه'), findsOneWidget);
    });
  });
}
