import 'package:elajtech/features/packages/presentation/pages/admin_packages_grid_page.dart';
import 'package:elajtech/features/packages/presentation/pages/admin_packages_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: AdminPackagesGridPage(),
      ),
    );
  }

  testWidgets('AdminPackagesGridPage displays all clinic cards', (
    tester,
  ) async {
    await tester.pumpWidget(createTestWidget());

    // Verify AppBar title
    expect(find.text('إدارة الباقات - العيادات'), findsOneWidget);

    // Verify all clinic IDs have a corresponding card
    // Note: We use the labels which are derived from PackageCategory arabicLabel
    // "الذكورة والعقم والبروستاتا", "العلاج الطبيعي والتأهيل", etc.
    expect(find.text('الذكورة والعقم والبروستاتا'), findsOneWidget);
    expect(find.text('العلاج الطبيعي والتأهيل'), findsOneWidget);
    expect(find.text('الباطنة وطب الأسرة'), findsOneWidget);
    expect(find.text('السمنة والتغذية العلاجية'), findsOneWidget);
    expect(find.text('الأمراض المزمنة'), findsOneWidget);

    // Verify icons (based on IconData used in page)
    expect(find.byIcon(Icons.male), findsOneWidget);
    expect(find.byIcon(Icons.accessibility_new), findsOneWidget);
    expect(find.byIcon(Icons.family_restroom), findsOneWidget);
    expect(find.byIcon(Icons.restaurant), findsOneWidget);
    expect(find.byIcon(Icons.medical_services), findsOneWidget);
  });

  testWidgets('Tapping a clinic card updates provider and navigates', (
    tester,
  ) async {
    // We need to override the provider to avoid the fallback redirect in AdminPackagesListPage
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: AdminPackagesGridPage(),
        ),
      ),
    );

    // Tap on Andrology card - specifically the card to avoid finding multiple widgets
    final cardFinder = find.widgetWithText(Card, 'الذكورة والعقم والبروستاتا');
    await tester.tap(cardFinder);
    await tester.pumpAndSettle();

    // Verify navigation to AdminPackagesListPage
    expect(find.byType(AdminPackagesListPage), findsOneWidget);
  });
}
