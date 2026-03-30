import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/packages/presentation/pages/my_packages_page.dart';
import 'package:elajtech/features/patient/home/presentation/screens/lab_tests_info_screen.dart';
import 'package:elajtech/features/patient/home/presentation/screens/medical_screening_screen.dart';
import 'package:elajtech/features/patient/home/presentation/screens/patient_home_screen.dart';
import 'package:elajtech/features/patient/medical_records/presentation/screens/medical_records_screen.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/mock_auth_repository.dart';

import 'package:elajtech/features/notifications/domain/repositories/notification_repository.dart';
import 'package:elajtech/features/patient/home/data/models/medical_screening_model.dart';
import 'package:elajtech/features/patient/home/domain/repositories/medical_screening_repository.dart';
import 'package:elajtech/shared/models/notification_model.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/shared/providers/registered_doctors_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PatientHomeScreen Widget Tests', () {
    late UserModel mockUser;

    setUp(() async {
      mockUser = UserModel(
        id: 'user_123',
        fullName: 'Test Patient',
        email: 'patient@test.com',
        phoneNumber: '+966500000000',
        userType: UserType.patient,
        createdAt: DateTime.now(),
      );

      await GetIt.instance.reset();
      GetIt.instance.registerSingleton<NotificationRepository>(
        _MockNotificationRepository(),
      );
      GetIt.instance.registerSingleton<MedicalScreeningRepository>(
        _MockMedicalScreeningRepository(),
      );

      SharedPreferences.setMockInitialValues({});
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) {
            return _MockAuthNotifier(mockUser: mockUser)..setUser(mockUser);
          }),
          doctorsListProvider.overrideWithValue(const AsyncValue.data([])),
        ],
        child: const MaterialApp(
          home: PatientHomeScreen(),
        ),
      );
    }

    testWidgets(
      'Tapping My Packages navigates to MyPackagesPage',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final myPackagesCard = find.text('باقاتي');
        expect(myPackagesCard, findsOneWidget);

        await tester.ensureVisible(myPackagesCard);
        await tester.pumpAndSettle();

        await tester.tap(myPackagesCard);
        await tester.pumpAndSettle();

        expect(find.byType(MyPackagesPage), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping Medical Records navigates to MedicalRecordsScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final medicalRecordsCard = find.text(AppStrings.medicalRecords);
        expect(medicalRecordsCard, findsOneWidget);

        await tester.ensureVisible(medicalRecordsCard);
        await tester.pumpAndSettle();

        await tester.tap(medicalRecordsCard);
        await tester.pumpAndSettle();

        expect(find.byType(MedicalRecordsScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping My Lab Tests navigates to MedicalRecordsScreen with initialIndex 2',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find "My Lab Tests" card
        final myLabTestsCard = find.text(AppStrings.myLabTests);
        expect(myLabTestsCard, findsOneWidget);

        // Scroll to the card
        await tester.ensureVisible(myLabTestsCard);
        await tester.pumpAndSettle();

        // Tap on the card
        await tester.tap(myLabTestsCard);
        await tester.pumpAndSettle();

        // Verify navigation to MedicalRecordsScreen
        expect(find.byType(MedicalRecordsScreen), findsOneWidget);
        expect(find.text('السجل الطبي'), findsOneWidget);
      },
    );

    testWidgets('Tapping Lab Tests navigates to LabTestsInfoScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find "Lab Tests Request" card
      final labTestRequestCard = find.text(AppStrings.labTestRequestBtn);
      expect(labTestRequestCard, findsOneWidget);

      // Scroll to the card
      await tester.ensureVisible(labTestRequestCard);
      await tester.pumpAndSettle();

      // Tap on the card
      await tester.tap(labTestRequestCard);
      await tester.pumpAndSettle();

      // Verify navigation to LabTestsInfoScreen
      expect(find.byType(LabTestsInfoScreen), findsOneWidget);
      expect(find.text(AppStrings.labTestsComingSoon), findsOneWidget);
    });

    testWidgets(
      'Tapping Medical Screening navigates to MedicalScreeningScreen',
      (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find "Medical Screening" card
        final medicalScreeningCard = find.text(AppStrings.medicalScreening);
        expect(medicalScreeningCard, findsOneWidget);

        // Scroll to the card
        await tester.ensureVisible(medicalScreeningCard);
        await tester.pumpAndSettle();

        // Tap on the card
        await tester.tap(medicalScreeningCard);
        await tester.pumpAndSettle();

        // Verify navigation to MedicalScreeningScreen
        expect(find.byType(MedicalScreeningScreen), findsOneWidget);
      },
    );
  });
}

class _MockAuthNotifier extends AuthNotifier {
  _MockAuthNotifier({UserModel? mockUser})
    : super(MockAuthRepository(currentUser: mockUser));

  void setUser(UserModel user) {
    state = state.copyWith(user: user, isLoading: false);
  }
}

class _MockNotificationRepository implements NotificationRepository {
  @override
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return Stream.value([]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockMedicalScreeningRepository implements MedicalScreeningRepository {
  @override
  Future<Either<Failure, MedicalScreeningModel?>> getMedicalScreening(
    String patientId,
  ) async {
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
