/// Widget tests for AgoraVideoCallScreen
///
/// Tests video call UI components, control buttons, network status indicators,
/// call timer display functionality, and role-based UI text display.
library;

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/services/voip_call_service.dart';
import 'package:elajtech/features/patient/consultation/domain/repositories/consultation_call_repository.dart';
import 'package:elajtech/features/patient/consultation/presentation/providers/consultation_call_providers.dart';
import 'package:elajtech/features/patient/consultation/presentation/screens/agora_video_call_screen.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../fixtures/appointment_fixtures.dart';
import '../../helpers/widget_test_helper.dart';

/// Fake repository used to avoid real GetIt / VoIPCallService dependency
/// in widget tests that trigger ref.read(consultationCallControllerProvider).
class _FakeConsultationCallRepository implements ConsultationCallRepository {
  @override
  PendingCallData? get pendingCallData => null;

  @override
  bool get isCleanupBlocked => false;

  @override
  Future<PendingCallData?> refreshPendingCall() async => null;

  @override
  Future<String?> cleanupAfterCall() async => null;

  @override
  void markAnswerAccepted() {}

  @override
  void markJoinStarted() {}

  @override
  void markJoinSucceeded() {}

  @override
  void markJoinFailed() {}

  @override
  void markCallEnded() {}
}

void main() {
  // Setup Firebase mocks before all tests
  setUpAll(() async {
    setupFirebaseMocks();
    await initializeFakeFirebase();
  });

  // Cleanup after all tests
  tearDownAll(cleanupFirebaseMocks);

  group('AgoraVideoCallScreen Widget Tests', () {
    late AppointmentModel testAppointment;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      testAppointment = AppointmentFixtures.createConfirmedAppointment(
        channelName: 'test_channel_123',
        agoraToken: 'test_token_abc',
      );

      // Create default mock auth with patient user for all tests
      final mockUser = MockUser(
        uid: 'patient_001',
        email: 'patient@test.com',
        displayName: 'Test Patient',
      );
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    });

    /// Helper to pump the widget
    Future<void> pumpVideoCallScreen(
      WidgetTester tester, {
      required AppointmentModel appointment,
      FirebaseAuth? firebaseAuth,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            consultationCallRepositoryProvider.overrideWithValue(
              _FakeConsultationCallRepository(),
            ),
          ],
          child: MaterialApp(
            theme: ThemeData(useMaterial3: false),
            home: AgoraVideoCallScreen(
              appointment: appointment,
              firebaseAuth: firebaseAuth ?? mockAuth,
            ),
          ),
        ),
      );
      // Use pump() instead of pumpAndSettle() to avoid waiting for
      // Agora initialization which may not complete in test environment
      await tester.pump();
    }

    group('Video Rendering Widgets', () {
      testWidgets('should render video call screen with basic UI elements', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Verify screen renders
        expect(find.byType(AgoraVideoCallScreen), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);

        // Verify black background for video
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, Colors.black);
      });

      testWidgets('should display waiting room UI when no remote user', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Should show waiting message
        expect(find.text('جاري الاتصال بالطبيب...'), findsOneWidget);
        expect(
          find.text('يرجى الانتظار، سيتم الاتصال بك قريباً'),
          findsOneWidget,
        );

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should display local video preview container', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Local video preview should be present (small container)
        final containers = find.byType(Container);
        expect(containers, findsWidgets);

        // Verify local preview has correct styling
        final localPreviewContainers = tester.widgetList<Container>(containers);
        final hasLocalPreview = localPreviewContainers.any((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration) {
            return decoration.borderRadius == BorderRadius.circular(12) &&
                decoration.border != null;
          }
          return false;
        });
        expect(hasLocalPreview, isTrue);
      });

      testWidgets('should show video off icon when camera is disabled', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Initially, video might be off - check for videocam_off icon
        // This icon appears in the local preview when video is disabled
        expect(
          find.byIcon(Icons.videocam_off),
          findsWidgets, // Can appear in preview and control button
        );
      });
    });

    group('Control Buttons', () {
      testWidgets('should display all control buttons', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Verify mute button
        expect(find.byIcon(Icons.mic), findsOneWidget);
        expect(find.text('كتم'), findsOneWidget);

        // Verify video button
        expect(
          find.byIcon(Icons.videocam),
          findsWidgets, // Can appear in multiple places
        );
        expect(find.text('إيقاف الفيديو'), findsOneWidget);

        // Verify switch camera button
        expect(find.byIcon(Icons.flip_camera_ios), findsOneWidget);
        expect(find.text('تبديل الكاميرا'), findsOneWidget);

        // Verify end call button
        expect(find.byIcon(Icons.call_end), findsOneWidget);
        expect(find.text('إنهاء'), findsOneWidget);
      });

      testWidgets('should have functional mute button', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Find mute button by icon
        final muteButton = find.ancestor(
          of: find.byIcon(Icons.mic),
          matching: find.byType(IconButton),
        );

        expect(muteButton, findsOneWidget);

        // Verify button is enabled
        final button = tester.widget<IconButton>(muteButton);
        expect(button.onPressed, isNotNull);
      });

      testWidgets('should have functional video toggle button', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Find video button - look for the control button with videocam icon
        final videoButtons = find.byIcon(Icons.videocam);
        expect(videoButtons, findsWidgets);

        // Find the IconButton ancestor
        final videoButton = find.ancestor(
          of: videoButtons.first,
          matching: find.byType(IconButton),
        );

        if (videoButton.evaluate().isNotEmpty) {
          final button = tester.widget<IconButton>(videoButton);
          expect(button.onPressed, isNotNull);
        }
      });

      testWidgets('should have functional switch camera button', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Find switch camera button
        final switchButton = find.ancestor(
          of: find.byIcon(Icons.flip_camera_ios),
          matching: find.byType(IconButton),
        );

        expect(switchButton, findsOneWidget);

        final button = tester.widget<IconButton>(switchButton);
        expect(button.onPressed, isNotNull);
      });

      testWidgets('should have functional end call button', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Find end call button
        final endButton = find.ancestor(
          of: find.byIcon(Icons.call_end),
          matching: find.byType(IconButton),
        );

        expect(endButton, findsOneWidget);

        final button = tester.widget<IconButton>(endButton);
        expect(button.onPressed, isNotNull);
      });

      testWidgets('should show error color for end call button', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // End call button should have error color
        final endCallIcon = find.byIcon(Icons.call_end);
        expect(endCallIcon, findsOneWidget);

        final icon = tester.widget<Icon>(endCallIcon);
        expect(icon.color, AppColors.error);
      });

      testWidgets('end call button should navigate back when pressed', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Find and tap end call button
        final endButton = find.ancestor(
          of: find.byIcon(Icons.call_end),
          matching: find.byType(IconButton),
        );

        await tester.tap(endButton);
        await tester.pumpAndSettle();

        // Screen should be popped (no longer visible)
        expect(find.byType(AgoraVideoCallScreen), findsNothing);
      });
    });

    group('Network Status Indicators', () {
      testWidgets('should display connection status indicator', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Should show connection status (may appear in multiple places)
        expect(find.text('جاري الاتصال...'), findsWidgets);

        // Status indicator should be visible
        final statusContainers = find.byType(Container);
        expect(statusContainers, findsWidgets);
      });

      testWidgets('should show connection status with colored indicator', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Find containers that might be status indicators
        final containers = tester.widgetList<Container>(find.byType(Container));

        // Look for status indicator with warning color (not yet joined)
        final hasStatusIndicator = containers.any((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration) {
            return decoration.color == AppColors.warning ||
                decoration.color == AppColors.success;
          }
          return false;
        });

        expect(hasStatusIndicator, isTrue);
      });

      testWidgets('should display connection status text in waiting room', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Connection status should be visible in waiting room
        final statusTexts = find.byType(Text);
        expect(statusTexts, findsWidgets);

        // Should contain status information
        expect(find.textContaining('جاري'), findsWidgets);
      });
    });

    group('Call Timer Display', () {
      testWidgets('should display appointment information', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Patient user (uid: 'patient_001') sees the other party's name.
        // The default mockAuth uid doesn't match doctorId, so _isDoctor == false.
        // _appointmentInfo() shows: label ('الطبيب'), doctorName, specialization.
        expect(find.text(testAppointment.doctorName), findsOneWidget);
        expect(find.text(testAppointment.specialization), findsOneWidget);
      });

      testWidgets('should display appointment info with proper styling', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Find appointment info container
        final containers = tester.widgetList<Container>(find.byType(Container));

        // Look for semi-transparent black container (appointment info)
        final hasInfoContainer = containers.any((container) {
          final decoration = container.decoration;
          if (decoration is BoxDecoration) {
            final color = decoration.color;
            return color != null &&
                color.a == 0.5 &&
                color.r == Colors.black.r &&
                color.g == Colors.black.g &&
                color.b == Colors.black.b;
          }
          return false;
        });

        expect(hasInfoContainer, isTrue);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle missing Agora data gracefully', (
        WidgetTester tester,
      ) async {
        // Create appointment without Agora data
        final invalidAppointment =
            AppointmentFixtures.createPendingAppointment();

        // Should throw assertion error due to null Agora data
        // This is expected behavior - the screen requires valid Agora data
        expect(
          () => AgoraVideoCallScreen(appointment: invalidAppointment),
          throwsAssertionError,
        );
      });

      testWidgets('should validate Agora token is not null', (
        WidgetTester tester,
      ) async {
        // Create appointment with null token
        final appointmentWithoutToken = AppointmentModel(
          id: 'test_001',
          patientId: 'patient_001',
          patientName: 'Test Patient',
          patientPhone: '+966500000001',
          doctorId: 'doctor_001',
          doctorName: 'Dr. Test',
          specialization: 'Nutrition',
          appointmentDate: DateTime.now(),
          timeSlot: '10:00 AM',
          type: AppointmentType.video,
          status: AppointmentStatus.confirmed,
          fee: 200,
          createdAt: DateTime.now(),
          agoraChannelName: 'test_channel',
          agoraUid: 12345,
        );

        // Should throw assertion error - token is required
        expect(
          () => AgoraVideoCallScreen(appointment: appointmentWithoutToken),
          throwsAssertionError,
        );
      });

      testWidgets('should validate Agora channel name is not null', (
        WidgetTester tester,
      ) async {
        // Create appointment with null channel name
        final appointmentWithoutChannel = AppointmentModel(
          id: 'test_001',
          patientId: 'patient_001',
          patientName: 'Test Patient',
          patientPhone: '+966500000001',
          doctorId: 'doctor_001',
          doctorName: 'Dr. Test',
          specialization: 'Nutrition',
          appointmentDate: DateTime.now(),
          timeSlot: '10:00 AM',
          type: AppointmentType.video,
          status: AppointmentStatus.confirmed,
          fee: 200,
          createdAt: DateTime.now(),
          agoraToken: 'test_token',
          agoraUid: 12345,
        );

        // Should throw assertion error - channel name is required
        expect(
          () => AgoraVideoCallScreen(appointment: appointmentWithoutChannel),
          throwsAssertionError,
        );
      });

      testWidgets('should validate Agora UID is not null', (
        WidgetTester tester,
      ) async {
        // Create appointment with null UID
        final appointmentWithoutUid = AppointmentModel(
          id: 'test_001',
          patientId: 'patient_001',
          patientName: 'Test Patient',
          patientPhone: '+966500000001',
          doctorId: 'doctor_001',
          doctorName: 'Dr. Test',
          specialization: 'Nutrition',
          appointmentDate: DateTime.now(),
          timeSlot: '10:00 AM',
          type: AppointmentType.video,
          status: AppointmentStatus.confirmed,
          fee: 200,
          createdAt: DateTime.now(),
          agoraToken: 'test_token',
          agoraChannelName: 'test_channel',
        );

        // Should throw assertion error - UID is required
        expect(
          () => AgoraVideoCallScreen(appointment: appointmentWithoutUid),
          throwsAssertionError,
        );
      });
    });

    group('UI Layout', () {
      testWidgets('should use Stack layout for overlaying elements', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Should use Stack for layering video and controls (may have nested Stacks)
        expect(find.byType(Stack), findsWidgets);
      });

      testWidgets('should position controls at bottom of screen', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Find Positioned widgets
        final positioned = find.byType(Positioned);
        expect(positioned, findsWidgets);

        // Controls should be positioned at bottom
        final positionedWidgets = tester.widgetList<Positioned>(positioned);
        final hasBottomControls = positionedWidgets.any(
          (widget) => widget.bottom != null && widget.bottom == 40,
        );

        expect(hasBottomControls, isTrue);
      });

      testWidgets('should position local video preview at top right', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Find Positioned widgets
        final positioned = tester.widgetList<Positioned>(
          find.byType(Positioned),
        );

        // Local preview should be at top right
        final hasTopRightPreview = positioned.any(
          (widget) => widget.top == 40 && widget.right == 16,
        );

        expect(hasTopRightPreview, isTrue);
      });

      testWidgets('should position connection status at top left', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Find Positioned widgets
        final positioned = tester.widgetList<Positioned>(
          find.byType(Positioned),
        );

        // Status should be at top left
        final hasTopLeftStatus = positioned.any(
          (widget) => widget.top == 40 && widget.left == 16,
        );

        expect(hasTopLeftStatus, isTrue);
      });
    });

    group('Button States', () {
      testWidgets('should display mute button with correct initial state', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Initially not muted - should show mic icon
        expect(find.byIcon(Icons.mic), findsOneWidget);
        expect(find.text('كتم'), findsOneWidget);
      });

      testWidgets('should display video button with correct initial state', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Initially video on - should show videocam icon
        expect(find.byIcon(Icons.videocam), findsWidgets);
        expect(find.text('إيقاف الفيديو'), findsOneWidget);
      });

      testWidgets('control buttons should be arranged horizontally', (
        WidgetTester tester,
      ) async {
        await pumpVideoCallScreen(
          tester,
          appointment: testAppointment,
        );

        // Add additional pump to ensure widget tree is fully built
        await tester.pump(const Duration(milliseconds: 100));

        // Find Row widget containing control buttons
        final rows = find.byType(Row);
        expect(rows, findsWidgets);

        // Should have Row with spaceEvenly alignment for controls
        final rowWidgets = tester.widgetList<Row>(rows);
        final hasControlRow = rowWidgets.any(
          (row) => row.mainAxisAlignment == MainAxisAlignment.spaceEvenly,
        );

        expect(hasControlRow, isTrue);
      });
    });

    group('Role Determination Logic', () {
      testWidgets(
        'should determine doctor role correctly when current user is doctor',
        (
          WidgetTester tester,
        ) async {
          // ✅ Create mock user as doctor
          final mockUser = MockUser(
            uid: 'doctor_123',
            email: 'doctor@test.com',
            displayName: 'Test Doctor',
          );
          final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

          // Create appointment with specific doctor and patient IDs
          final appointment = AppointmentFixtures.createConfirmedAppointment(
            doctorId: 'doctor_123',
            patientId: 'patient_456',
            channelName: 'test_channel',
            agoraToken: 'test_token',
          );

          await tester.pumpWidget(
            MaterialApp(
              home: AgoraVideoCallScreen(
                appointment: appointment,
                firebaseAuth: mockAuth, // ✅ Inject mock
              ),
            ),
          );
          await tester.pump();

          // Doctor should see "جاري الاتصال بالمريض..." (Calling patient...)
          expect(find.text('جاري الاتصال بالمريض...'), findsOneWidget);

          // Doctor should see patient name in waiting message
          // Use exact text match to avoid finding it in appointment info
          expect(
            find.text('في انتظار رد ${appointment.patientName}...'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'should show patient name in waiting message for doctor role',
        (
          WidgetTester tester,
        ) async {
          // ✅ Create mock user as doctor
          final mockUser = MockUser(
            uid: 'doctor_123',
            email: 'doctor@test.com',
            displayName: 'Test Doctor',
          );
          final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

          // Create appointment with specific patient name
          final appointment = AppointmentFixtures.createConfirmedAppointment(
            doctorId: 'doctor_123',
            patientId: 'patient_456',
            patientName: 'أحمد محمد',
            channelName: 'test_channel',
            agoraToken: 'test_token',
          );

          await tester.pumpWidget(
            MaterialApp(
              home: AgoraVideoCallScreen(
                appointment: appointment,
                firebaseAuth: mockAuth, // ✅ Inject mock
              ),
            ),
          );
          await tester.pump();

          // Doctor should see "في انتظار رد [patient name]..."
          expect(find.text('في انتظار رد أحمد محمد...'), findsOneWidget);
        },
      );

      testWidgets(
        'should determine patient role correctly when current user is patient',
        (
          WidgetTester tester,
        ) async {
          // ✅ Create mock user as patient
          final mockUser = MockUser(
            uid: 'patient_456',
            email: 'patient@test.com',
            displayName: 'Test Patient',
          );
          final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

          // Create appointment with specific doctor and patient IDs
          final appointment = AppointmentFixtures.createConfirmedAppointment(
            doctorId: 'doctor_123',
            patientId: 'patient_456',
            channelName: 'test_channel',
            agoraToken: 'test_token',
          );

          await tester.pumpWidget(
            MaterialApp(
              home: AgoraVideoCallScreen(
                appointment: appointment,
                firebaseAuth: mockAuth, // ✅ Inject mock
              ),
            ),
          );
          await tester.pump();

          // Patient should see "جاري الاتصال بالطبيب..." (Calling doctor...)
          expect(find.text('جاري الاتصال بالطبيب...'), findsOneWidget);

          // Patient should see "يرجى الانتظار، سيتم الاتصال بك قريباً"
          expect(
            find.text('يرجى الانتظار، سيتم الاتصال بك قريباً'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'should default to patient role when current user is neither doctor nor patient',
        (
          WidgetTester tester,
        ) async {
          // ✅ Create mock user with different ID
          final mockUser = MockUser(
            uid: 'other_user_789',
            email: 'other@test.com',
            displayName: 'Other User',
          );
          final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

          // Create appointment with specific doctor and patient IDs
          final appointment = AppointmentFixtures.createConfirmedAppointment(
            doctorId: 'doctor_123',
            patientId: 'patient_456',
            channelName: 'test_channel',
            agoraToken: 'test_token',
          );

          await tester.pumpWidget(
            MaterialApp(
              home: AgoraVideoCallScreen(
                appointment: appointment,
                firebaseAuth: mockAuth, // ✅ Inject mock
              ),
            ),
          );
          await tester.pump();

          // Should default to patient role and show "جاري الاتصال بالطبيب..."
          expect(find.text('جاري الاتصال بالطبيب...'), findsOneWidget);

          // Should show patient waiting message
          expect(
            find.text('يرجى الانتظار، سيتم الاتصال بك قريباً'),
            findsOneWidget,
          );
        },
      );
    });
  });
}
