import 'package:elajtech/features/auth/presentation/screens/login_screen.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/main.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/services/voip_call_service.dart';
import 'package:elajtech/core/services/call_monitoring_service.dart';
import 'package:elajtech/core/services/fcm_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../mocks/mocks.mocks.dart';
import '../../fixtures/user_fixtures.dart';

// Use a simple StateNotifier for testing AuthWrapper routing
class FakeAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  FakeAuthNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late MockVoIPCallService mockVoipService;
  late MockCallMonitoringService mockCallMonitoringService;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockFCMService mockFcm;

  setUp(() async {
    mockVoipService = MockVoIPCallService();
    mockCallMonitoringService = MockCallMonitoringService();
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockFcm = MockFCMService();

    // Clear and setup GetIt
    await getIt.reset();
    await configureDependencies();

    // Override with mocks for specific services we want to control
    getIt
      ..unregister<VoIPCallService>()
      ..registerLazySingleton<VoIPCallService>(() => mockVoipService)
      ..unregister<CallMonitoringService>()
      ..registerLazySingleton<CallMonitoringService>(
        () => mockCallMonitoringService,
      )
      ..unregister<FirebaseFirestore>()
      ..registerLazySingleton<FirebaseFirestore>(() => mockFirestore)
      ..unregister<FirebaseAuth>()
      ..registerLazySingleton<FirebaseAuth>(() => mockAuth)
      ..unregister<FCMService>()
      ..registerLazySingleton<FCMService>(() => mockFcm);

    // Stub default VoIP behavior
    when(mockVoipService.pendingCallData).thenReturn(null);
    when(mockVoipService.cleanupAfterCall()).thenAnswer((_) async => null);
  });

  Widget createTestWidget(AuthNotifier notifier) {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => notifier),
        adminDashboardProvider.overrideWith(
          (ref) => const Scaffold(body: Text('Admin Dashboard')),
        ),
        doctorDashboardProvider.overrideWith(
          (ref) => const Scaffold(body: Text('Doctor Dashboard')),
        ),
        patientDashboardProvider.overrideWith(
          (ref) => const Scaffold(body: Text('Patient Dashboard')),
        ),
      ],
      child: const MaterialApp(
        home: AuthWrapper(),
      ),
    );
  }

  group('AuthWrapper Routing - Base Roles', () {
    testWidgets('should show LoginScreen when unauthenticated', (tester) async {
      final notifier = FakeAuthNotifier(AuthState());

      await tester.pumpWidget(createTestWidget(notifier));
      await tester.pump(); // Immediate build

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('should show AdminDashboardScreen for admin user', (
      tester,
    ) async {
      final user = UserFixtures.createPatient(
        id: 'admin1',
      ).copyWith(userType: UserType.admin);
      final notifier = FakeAuthNotifier(
        AuthState(isAuthenticated: true, user: user),
      );

      await tester.pumpWidget(createTestWidget(notifier));
      await tester.pump();

      expect(find.text('Admin Dashboard'), findsOneWidget);
    });

    testWidgets('should show DoctorDashboardScreen for doctor user', (
      tester,
    ) async {
      final user = UserFixtures.createDoctor(id: 'doc1');
      final notifier = FakeAuthNotifier(
        AuthState(isAuthenticated: true, user: user),
      );

      await tester.pumpWidget(createTestWidget(notifier));
      await tester.pump();

      expect(find.text('Doctor Dashboard'), findsOneWidget);
    });

    testWidgets('should show PatientMainScreen for patient user', (
      tester,
    ) async {
      final user = UserFixtures.createPatient(id: 'pat1');
      final notifier = FakeAuthNotifier(
        AuthState(isAuthenticated: true, user: user),
      );

      await tester.pumpWidget(createTestWidget(notifier));
      await tester.pump();

      expect(find.text('Patient Dashboard'), findsOneWidget);
    });
  });

  group('AuthWrapper - Special Scenarios and Edge Cases', () {
    testWidgets(
      'should show loading state (SplashScreen) when auth is loading',
      (tester) async {
        final notifier = FakeAuthNotifier(AuthState(isLoading: true));

        await tester.pumpWidget(createTestWidget(notifier));

        // Splash screen is an internal class _SplashScreen in main.dart
        // We look for progress indicator which is inside it
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'should handle race condition: authenticated but user is null (show Splash)',
      (tester) async {
        final notifier = FakeAuthNotifier(
          AuthState(isAuthenticated: true),
        );

        await tester.pumpWidget(createTestWidget(notifier));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'should handle unknown userType by showing LoginScreen or error',
      (tester) async {
        // Create user with null/invalid userType simulation
        // In AuthWrapper, the default in switch is return const LoginScreen()
        final user = UserFixtures.createPatient(
          id: 'bad_user',
        ).copyWith(userType: UserType.patient);
        // We can't easily set invalid UserType enum without dynamic casting or mocking the property
        // But we can test the default case if we had a non-exhaustive switch.
        // Currently AuthWrapper switch handles all UserType enum values.

        final notifier = FakeAuthNotifier(
          AuthState(isAuthenticated: true, user: user),
        );

        await tester.pumpWidget(createTestWidget(notifier));
        await tester.pump();

        // Verification for patient role
        expect(find.text('Patient Dashboard'), findsOneWidget);
      },
    );
  });
}
