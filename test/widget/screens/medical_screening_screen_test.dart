import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/features/patient/home/data/models/medical_screening_model.dart';
import 'package:elajtech/features/patient/home/domain/repositories/medical_screening_repository.dart';
import 'package:elajtech/features/patient/home/presentation/screens/medical_screening_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import '../../mocks/mock_auth_repository.dart';

class _MockAuthNotifier extends AuthNotifier {
  _MockAuthNotifier({UserModel? mockUser})
    : super(MockAuthRepository(currentUser: mockUser));

  void setUser(UserModel user) {
    state = state.copyWith(user: user, isLoading: false);
  }
}

class _MockMedicalScreeningRepository implements MedicalScreeningRepository {
  MedicalScreeningModel? mockModel;

  @override
  Future<Either<Failure, MedicalScreeningModel?>> getMedicalScreening(
    String patientId,
  ) async {
    return Right(mockModel);
  }

  @override
  Future<Either<Failure, Unit>> saveMedicalScreening(
    String patientId,
    MedicalScreeningModel data,
  ) async {
    return const Right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _MockMedicalScreeningRepository mockRepository;
  late UserModel mockUser;

  setUp(() {
    mockRepository = _MockMedicalScreeningRepository();
    GetIt.instance.registerSingleton<MedicalScreeningRepository>(
      mockRepository,
    );

    mockUser = UserModel(
      id: 'patient_123',
      fullName: 'Test Patient',
      email: 'patient@test.com',
      phoneNumber: '+1234567890',
      userType: UserType.patient,
      createdAt: DateTime.now(),
    );
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) {
          return _MockAuthNotifier(mockUser: mockUser)..setUser(mockUser);
        }),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: const MedicalScreeningScreen(),
      ),
    );
  }

  testWidgets(
    'Checkboxes correctly update state and selection is not wiped after a pump',
    (WidgetTester tester) async {
      mockRepository.mockModel = null; // No initial data
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Wait for data to load

      // Verify initial state is unchecked
      final initialCheckbox = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, AppStrings.diabetes),
      );
      expect(initialCheckbox.value, isFalse);

      // Tap checkbox
      await tester.tap(
        find.widgetWithText(CheckboxListTile, AppStrings.diabetes),
      );
      await tester.pump(); // Trigger setState

      // Verify state was updated and wasn't wiped out by build()
      final updatedCheckbox = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, AppStrings.diabetes),
      );
      expect(updatedCheckbox.value, isTrue);
    },
  );

  testWidgets(
    'Save button is rendered inside SafeArea padded container and is tappable',
    (WidgetTester tester) async {
      mockRepository.mockModel = null;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // The save button should be rendered and tappable
      final saveButtonFinder = find.widgetWithText(
        ElevatedButton,
        AppStrings.save,
      );
      expect(saveButtonFinder, findsOneWidget);

      // Check that it's rendered as bottomNavigationBar (which places it inside a SafeArea inherently visually,
      // but in layout terms we check its direct ancestry).
      final safeAreaFinder = find.ancestor(
        of: saveButtonFinder,
        matching: find.byType(SafeArea),
      );
      expect(safeAreaFinder, findsOneWidget);

      // Tap the save button to ensure it doesn't crash
      await tester.tap(saveButtonFinder);
      await tester.pump();
    },
  );

  testWidgets(
    'Saved values appear when reopening the screen in read-only mode',
    (
      WidgetTester tester,
    ) async {
      // arrange
      const savedModel = MedicalScreeningModel(diabetes: true, obesity: true);
      mockRepository.mockModel = savedModel;

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // assert: Verify Section Headers
      expect(find.text(AppStrings.chronicDiseases), findsOneWidget);
      expect(find.text(AppStrings.specializedConditions), findsOneWidget);
      expect(find.text(AppStrings.lifestyleAndHistory), findsOneWidget);

      // assert: Verify Status Chips (Yes/No)
      // Diabetes is true -> should find "Yes"
      final diabetesItem = find.ancestor(
        of: find.text(AppStrings.diabetes),
        matching: find.byType(ListTile),
      );
      expect(
        find.descendant(of: diabetesItem, matching: find.text(AppStrings.yes)),
        findsOneWidget,
      );

      // Hypertension is false (default) -> should find "No"
      final hypertensionItem = find.ancestor(
        of: find.text(AppStrings.hypertension),
        matching: find.byType(ListTile),
      );
      expect(
        find.descendant(
          of: hypertensionItem,
          matching: find.text(AppStrings.no),
        ),
        findsOneWidget,
      );

      // Verify it's NOT using CheckboxListTile in read-only mode
      expect(find.byType(CheckboxListTile), findsNothing);

      // Verify info banner
      expect(find.text(AppStrings.medicalScreeningSavedInfo), findsOneWidget);
      expect(find.text(AppStrings.editData), findsOneWidget);
    },
  );

  testWidgets(
    'Tapping Edit Data enables checkboxes and shows the Save button',
    (
      WidgetTester tester,
    ) async {
      // arrange
      const savedModel = MedicalScreeningModel(diabetes: true);
      mockRepository.mockModel = savedModel;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // initial state: Edit Data button is shown, read-only items are present
      expect(find.text(AppStrings.editData), findsOneWidget);
      expect(find.text(AppStrings.save), findsNothing);
      expect(find.byType(CheckboxListTile), findsNothing);

      // act: tap Edit Data
      await tester.tap(find.text(AppStrings.editData));
      await tester.pumpAndSettle();

      // assert: Save button is shown, checkboxes are enabled
      expect(find.text(AppStrings.editData), findsNothing);
      expect(find.text(AppStrings.save), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsAtLeastNWidgets(1));

      final enabledCheckbox = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, AppStrings.diabetes),
      );
      expect(enabledCheckbox.onChanged, isNotNull);

      // Verify banner is gone in edit mode
      expect(find.text(AppStrings.medicalScreeningSavedInfo), findsNothing);
    },
  );
}
