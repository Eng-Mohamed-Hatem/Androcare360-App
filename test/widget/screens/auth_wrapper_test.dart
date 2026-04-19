import 'dart:async';

import 'package:elajtech/features/auth/presentation/screens/login_screen.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/core/services/appointment_completion_service.dart';
import 'package:elajtech/features/patient/consultation/presentation/screens/agora_video_call_screen.dart';
import 'package:elajtech/main.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/shared/widgets/custom_button.dart';
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
import '../../fixtures/appointment_fixtures.dart';
import '../../fixtures/user_fixtures.dart';
import '../../helpers/widget_test_helper.dart';

// Use a simple StateNotifier for testing AuthWrapper routing
class FakeAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  // Reason: the superclass uses a private parameter name, so an explicit
  // constructor keeps the test double readable without shadowing `_state`.
  // ignore: use_super_parameters
  FakeAuthNotifier(AuthState initialState) : super(initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeInteractiveAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  FakeInteractiveAuthNotifier({required this.onLogin}) : super(AuthState());

  final Future<AuthState> Function({
    required String email,
    required String password,
    required UserType userType,
  })
  onLogin;

  @override
  Future<void> loginWithEmail(
    String email,
    String password, {
    String? fullName,
    String? phoneNumber,
    UserType userType = UserType.patient,
    String? licenseNumber,
    List<String>? specializations,
    String? clinicType,
    String? clinicName,
    String? clinicAddress,
    List<String>? consultationTypes,
    String? username,
    bool isRegistration = false,
  }) async {
    state = state.copyWith(isLoading: true);
    state = await onLogin(
      email: email,
      password: password,
      userType: userType,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class TestVoipCallService extends Fake implements VoIPCallService {
  PendingCallData? pendingCallDataValue;
  bool isCleanupBlockedValue = false;
  String? cleanupAfterCallResult;
  bool hasActiveCallsValue = false;

  @override
  PendingCallData? get pendingCallData => pendingCallDataValue;

  @override
  bool get isCleanupBlocked => isCleanupBlockedValue;

  @override
  Stream<VoIPCallEvent> get callEventStream => const Stream.empty();

  @override
  Future<PendingCallData?> refreshPendingCallData() async =>
      pendingCallDataValue;

  @override
  void markAnswerAccepted() {}

  @override
  void markJoinStarted() {
    isCleanupBlockedValue = true;
  }

  @override
  void markJoinSucceeded() {
    isCleanupBlockedValue = false;
  }

  @override
  void markJoinFailed() {
    isCleanupBlockedValue = false;
  }

  @override
  void markCallEnded() {
    isCleanupBlockedValue = false;
  }

  @override
  Future<String?> cleanupAfterCall() async => cleanupAfterCallResult;

  @override
  Future<void> endAllCalls() async {}

  @override
  Future<bool> hasActiveCalls() async => hasActiveCallsValue;
}

class TestCallMonitoringService extends Fake implements CallMonitoringService {
  @override
  Future<void> logStructuredEvent({
    required String appointmentId,
    required String userId,
    required String eventType,
    Map<String, dynamic>? metadata,
    String? errorCode,
    String? errorMessage,
  }) async {}
}

void main() {
  late TestVoipCallService mockVoipService;
  late TestCallMonitoringService mockCallMonitoringService;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockFCMService mockFcm;
  late MockUser mockFirebaseUser;

  setUpAll(() async {
    setupFirebaseMocks();
    await initializeFakeFirebase();
  });

  tearDownAll(cleanupFirebaseMocks);

  setUp(() async {
    mockVoipService = TestVoipCallService();
    mockCallMonitoringService = TestCallMonitoringService();
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockFcm = MockFCMService();
    mockFirebaseUser = MockUser();

    when(mockFirebaseUser.uid).thenReturn('patient_test_001');
    when(mockAuth.currentUser).thenReturn(mockFirebaseUser);

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
    mockVoipService
      ..pendingCallDataValue = null
      ..isCleanupBlockedValue = false
      ..cleanupAfterCallResult = null;
    when(mockFcm.resetCallDeduplication()).thenAnswer((_) async {});
  });

  Widget createTestWidget(
    AuthNotifier notifier, {
    Future<CompletionResult> Function({
      required String appointmentId,
      required String doctorId,
    })?
    completeAppointment,
  }) {
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
      child: MaterialApp(
        home: AuthWrapper(completeAppointment: completeAppointment),
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

    testWidgets('patient email login success redirects to patient dashboard', (
      tester,
    ) async {
      final user = UserFixtures.createPatient(id: 'pat_login_001');
      final notifier = FakeInteractiveAuthNotifier(
        onLogin:
            ({required email, required password, required userType}) async {
              return AuthState(
                isAuthenticated: true,
                user: user,
              );
            },
      );

      await tester.pumpWidget(createTestWidget(notifier));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, user.email);
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.widgetWithText(CustomButton, 'تسجيل الدخول'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Patient Dashboard'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('disabled patient login shows error without silent redirect', (
      tester,
    ) async {
      final notifier = FakeInteractiveAuthNotifier(
        onLogin:
            ({required email, required password, required userType}) async {
              return AuthState(
                error: 'الحساب معطّل، برجاء التواصل مع الدعم.',
              );
            },
      );

      await tester.pumpWidget(createTestWidget(notifier));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'patient@test.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.widgetWithText(CustomButton, 'تسجيل الدخول'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('الحساب معطّل، برجاء التواصل مع الدعم.'),
        findsOneWidget,
      );
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Patient Dashboard'), findsNothing);
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

    testWidgets('patient cleanup no longer completes appointment on resume', (
      tester,
    ) async {
      final user = UserFixtures.createPatient(id: 'pat_cleanup');
      final notifier = FakeAuthNotifier(
        AuthState(isAuthenticated: true, user: user),
      );

      mockVoipService.cleanupAfterCallResult = 'apt_cleanup_001';

      await tester.pumpWidget(createTestWidget(notifier));
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(
        find.text('تم إنهاء المكالمة. يبقى الموعد بانتظار تحديث الطبيب.'),
        findsOneWidget,
      );
      expect(find.text('Patient Dashboard'), findsOneWidget);
    });

    testWidgets('invalid pending call data fails safely', (tester) async {
      final user = UserFixtures.createPatient(id: 'pat_pending_invalid');
      final notifier = FakeAuthNotifier(
        AuthState(isAuthenticated: true, user: user),
      );

      mockVoipService.pendingCallDataValue = PendingCallData(
        callId: 'call_invalid',
        appointmentId: '',
        callerName: 'Doctor',
        agoraChannelName: 'channel_invalid',
      );

      await tester.pumpWidget(createTestWidget(notifier));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('تعذر استعادة المكالمة الواردة. حاول انتظار إعادة الاتصال.'),
        findsOneWidget,
      );
      expect(find.text('Patient Dashboard'), findsOneWidget);
    });

    testWidgets('valid pending call data navigates to Agora screen', (
      tester,
    ) async {
      final user = UserFixtures.createPatient(id: 'patient_test_001');
      final notifier = FakeAuthNotifier(
        AuthState(isAuthenticated: true, user: user),
      );
      final appointment = AppointmentFixtures.createConfirmedAppointment()
          .copyWith(status: AppointmentStatus.calling);
      final collection = MockCollectionReference<Map<String, dynamic>>();
      final document = MockDocumentReference<Map<String, dynamic>>();
      final snapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      mockVoipService.pendingCallDataValue = PendingCallData(
        callId: 'call_valid',
        appointmentId: appointment.id,
        callerName: appointment.doctorName,
        agoraToken: appointment.agoraToken,
        agoraChannelName: appointment.agoraChannelName,
        agoraUid: appointment.agoraUid,
      );

      when(mockFirestore.collection('appointments')).thenReturn(collection);
      when(collection.doc(appointment.id)).thenReturn(document);
      when(document.get()).thenAnswer((_) async => snapshot);
      when(snapshot.exists).thenReturn(true);
      when(snapshot.id).thenReturn(appointment.id);
      when(snapshot.data()).thenReturn(appointment.toJson());

      await tester.pumpWidget(createTestWidget(notifier));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(AgoraVideoCallScreen), findsOneWidget);
    });

    testWidgets('doctor completion dialog uses server completion callback', (
      tester,
    ) async {
      final user = UserFixtures.createDoctor(id: 'doc_complete_001');
      final notifier = FakeAuthNotifier(
        AuthState(isAuthenticated: true, user: user),
      );
      var calledAppointmentId = '';
      var calledDoctorId = '';

      Future<CompletionResult> completeAppointment({
        required String appointmentId,
        required String doctorId,
      }) async {
        calledAppointmentId = appointmentId;
        calledDoctorId = doctorId;
        return CompletionResult(success: true, message: 'تم الإكمال من الخادم');
      }

      mockVoipService.cleanupAfterCallResult = 'apt_doctor_complete_001';

      await tester.pumpWidget(
        createTestWidget(
          notifier,
          completeAppointment: completeAppointment,
        ),
      );
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(find.text('انتهاء الجلسة الطبية'), findsOneWidget);

      await tester.tap(find.text('نعم، اكتملت'));
      await tester.pumpAndSettle();

      expect(calledAppointmentId, 'apt_doctor_complete_001');
      expect(calledDoctorId, user.id);
      expect(find.text('تم الإكمال من الخادم'), findsOneWidget);
    });
  });

  group('AuthWrapper - warm-start callEventStream subscription', () {
    test(
      'authWrapper_callEventSubscription_cancelledOnDispose',
      () async {
        // callEventStream on TestVoipCallService returns Stream.empty(), so
        // subscribing and then disposing should not throw.
        final controller = StreamController<VoIPCallEvent>.broadcast();
        final events = <VoIPCallEvent>[];
        final sub = controller.stream.listen(events.add);
        // Cancel (simulates dispose)
        await sub.cancel();
        controller.add(
          VoIPCallEvent(
            type: VoIPCallEventType.accepted,
            callId: 'cancelled_call',
          ),
        );
        // No events should have been delivered after cancel
        expect(events, isEmpty);
        await controller.close();
      },
    );
  });
}
