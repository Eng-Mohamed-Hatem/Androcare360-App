import 'package:elajtech/core/presentation/providers/doctor_registration_provider.dart';
import 'package:elajtech/core/presentation/screens/doctor_registration_screen.dart';
import 'package:elajtech/shared/constants/clinic_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDoctorRegistrationNotifier
    extends StateNotifier<DoctorRegistrationState>
    implements DoctorRegistrationNotifier {
  _FakeDoctorRegistrationNotifier() : super(const DoctorRegistrationState());

  @override
  Future<void> registerDoctor({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String specialty,
  }) async {
    state = const DoctorRegistrationState(isSuccess: true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  Widget buildWidget() {
    return ProviderScope(
      overrides: [
        doctorRegistrationProvider.overrideWith(
          (ref) => _FakeDoctorRegistrationNotifier(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: const DoctorRegistrationScreen(),
      ),
    );
  }

  group('DoctorRegistrationScreen - Clinic Type Selector', () {
    testWidgets('supports single-select from predefined clinic types', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());

      final dropdownFinder = find.byKey(
        const Key('doctor_registration_specialty_dropdown'),
      );
      expect(dropdownFinder, findsOneWidget);

      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      for (final clinicType in ClinicTypes.values) {
        expect(find.text(ClinicTypes.arabicLabel(clinicType)), findsWidgets);
      }

      final firstClinicType = ClinicTypes.arabicLabel(
        ClinicTypes.values.first,
      );
      final secondClinicType = ClinicTypes.arabicLabel(ClinicTypes.values[1]);

      await tester.tap(find.text(firstClinicType).last);
      await tester.pumpAndSettle();

      expect(find.text(firstClinicType), findsOneWidget);

      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.text(secondClinicType).last);
      await tester.pumpAndSettle();

      expect(find.text(secondClinicType), findsOneWidget);
      expect(find.text(firstClinicType), findsNothing);
    });
  });

  group('DoctorRegistrationScreen - Phone Validation', () {
    Future<void> fillRequiredFields(WidgetTester tester) async {
      await tester.enterText(
        find.byKey(const Key('doctor_registration_full_name_field')),
        'Dr Test',
      );
      await tester.enterText(
        find.byKey(const Key('doctor_registration_email_field')),
        'doctor@example.com',
      );

      final dropdownFinder = find.byKey(
        const Key('doctor_registration_specialty_dropdown'),
      );
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(ClinicTypes.arabicLabel(ClinicTypes.values.first)).last,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows E.164 validation error for invalid phone', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());
      await fillRequiredFields(tester);

      await tester.enterText(
        find.byKey(const Key('doctor_registration_phone_field')),
        '01234567890',
      );

      await tester.tap(
        find.byKey(const Key('doctor_registration_submit_button')),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Please enter a valid international phone number (e.g., +201234567890)',
        ),
        findsOneWidget,
      );
    });

    testWidgets('accepts valid E.164 phone number', (tester) async {
      await tester.pumpWidget(buildWidget());
      await fillRequiredFields(tester);

      await tester.enterText(
        find.byKey(const Key('doctor_registration_phone_field')),
        '+201234567890',
      );

      await tester.tap(
        find.byKey(const Key('doctor_registration_submit_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Registration successful'), findsOneWidget);
      expect(
        find.text('Your account is pending admin approval'),
        findsOneWidget,
      );
    });
  });
}
