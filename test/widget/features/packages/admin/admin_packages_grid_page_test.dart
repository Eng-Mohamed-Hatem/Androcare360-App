import 'package:elajtech/features/packages/presentation/pages/admin_packages_grid_page.dart';
import 'package:elajtech/features/packages/presentation/pages/admin_packages_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: const AdminPackagesGridPage(),
      ),
    );
  }

  testWidgets('AdminPackagesGridPage displays all clinic cards', (
    tester,
  ) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(Card), findsAtLeastNWidgets(4));

    expect(find.byIcon(Icons.male), findsOneWidget);
    expect(find.byIcon(Icons.accessibility_new), findsOneWidget);
    expect(find.byIcon(Icons.family_restroom), findsOneWidget);
    expect(find.byIcon(Icons.restaurant), findsOneWidget);
  });

  testWidgets('Tapping a clinic card updates provider and navigates', (
    tester,
  ) async {
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: const AdminPackagesGridPage(),
        ),
      ),
    );

    await tester.tap(find.byType(Card).first);
    await tester.pumpAndSettle();

    expect(find.byType(AdminPackagesListPage), findsOneWidget);
  });
}
