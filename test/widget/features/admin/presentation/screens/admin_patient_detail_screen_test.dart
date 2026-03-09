import 'package:elajtech/features/admin/presentation/screens/admin_patient_detail_screen.dart';
import 'package:elajtech/features/admin/presentation/screens/admin_patient_packages_page.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dummyPatient = UserModel(
    id: 'patient_1',
    fullName: 'Ahmed Ali',
    email: 'ahmed@test.com',
    phoneNumber: '123456789',
    userType: UserType.patient,
    isActive: true,
    createdAt: DateTime(2025),
  );

  Widget createSubject({required UserModel patient}) {
    return ProviderScope(
      overrides: [
        // We can override providers here if needed,
        // but for basic UI check the default state is enough
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar')],
        locale: const Locale('ar'),
        home: AdminPatientDetailScreen(patient: patient),
      ),
    );
  }

  group('AdminPatientDetailScreen Widget Tests', () {
    testWidgets('shows patient basic info and status chip', (tester) async {
      await tester.pumpWidget(createSubject(patient: dummyPatient));

      expect(find.text('Ahmed Ali'), findsOneWidget);
      expect(find.text('ahmed@test.com'), findsOneWidget);
      expect(find.text('نشط'), findsOneWidget); // Active status chip
    });

    testWidgets('shows Disable Account button when patient is active', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject(patient: dummyPatient));

      expect(find.text('تعطيل الحساب'), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('shows Enable Account button when patient is inactive', (
      tester,
    ) async {
      final inactivePatient = dummyPatient.copyWith(isActive: false);
      await tester.pumpWidget(createSubject(patient: inactivePatient));

      expect(find.text('تفعيل الحساب'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.text('معطل'), findsOneWidget);
    });

    testWidgets('tapping patient packages tile triggers navigation', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject(patient: dummyPatient));

      // Find the "باقات المريض" tile
      final tileFinder = find.text('باقات المريض');
      expect(tileFinder, findsOneWidget);

      // Tap the tile (InkWell should capture it)
      await tester.tap(tileFinder);
      await tester.pumpAndSettle();

      // Verify that we navigated to AdminPatientPackagesPage
      expect(find.byType(AdminPatientPackagesPage), findsOneWidget);
    });
  });
}
