// ⚠️ SETUP REQUIRED: This file is a template for golden tests
//
// To use golden tests, you must:
// 1. Add golden_toolkit dependency: flutter pub add golden_toolkit --dev
// 2. Uncomment the code below
// 3. Run: flutter test --update-goldens test/golden/
//
// See test/golden/README.md for complete setup instructions

import 'package:flutter_test/flutter_test.dart';

// Placeholder main function to prevent compilation errors
// Uncomment the code below when golden_toolkit is added
void main() {
  test('golden tests placeholder', () {
    // Golden tests are disabled until golden_toolkit is added
    // See test/golden/README.md for setup instructions
  });
}

/*
import 'package:elajtech/features/patient/consultation/presentation/screens/agora_video_call_screen.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

/// Golden tests for AgoraVideoCallScreen
///
/// These tests capture visual snapshots to detect unintended UI changes
/// after API migrations (e.g., withOpacity → withValues).
///
/// **Running Golden Tests:**
/// ```bash
/// # Generate/update golden files
/// flutter test --update-goldens test/golden/
///
/// # Run golden tests
/// flutter test test/golden/
/// ```
///
/// **When to Update Goldens:**
/// - After intentional UI changes
/// - After migrating deprecated APIs (to verify no visual changes)
/// - When golden tests fail unexpectedly
///
/// **Important:**
/// - Golden tests are platform-specific (run on same OS)
/// - Commit golden files to version control
/// - Review golden diffs carefully before updating
void main() {
  setUpAll(() async {
    // Load fonts for golden tests
    await loadAppFonts();
  });

  group('AgoraVideoCallScreen Golden Tests', () {
    testGoldens('waiting room UI with loading indicator', (WidgetTester tester) async {
      // Arrange
      final appointment = AppointmentModel(
        id: 'test_appointment_1',
        patientId: 'patient_123',
        patientName: 'أحمد محمد',
        patientPhone: '+966500000001',
        doctorId: 'doctor_456',
        doctorName: 'د. سارة أحمد',
        specialization: 'Nutrition',
        appointmentDate: DateTime.now(),
        timeSlot: '10:00 ص',
        type: AppointmentType.video,
        status: AppointmentStatus.confirmed,
        fee: 150.0,
        createdAt: DateTime.now(),
        agoraToken: 'test_token',
        agoraChannelName: 'test_channel',
        agoraUid: 12345,
      );

      // Act
      await tester.pumpWidgetBuilder(
        AgoraVideoCallScreen(appointment: appointment),
        surfaceSize: const Size(375, 667), // iPhone SE size
        wrapper: materialAppWrapper(
          theme: ThemeData.light(),
        ),
      );

      // Assert - Capture golden image
      await screenMatchesGolden(
        tester,
        'agora_video_call_screen_waiting_room',
        customPump: (tester) => tester.pump(const Duration(milliseconds: 100)),
      );
    });

    testGoldens('control buttons with correct opacity', (WidgetTester tester) async {
      // Arrange
      final appointment = AppointmentModel(
        id: 'test_appointment_2',
        patientId: 'patient_123',
        patientName: 'أحمد محمد',
        patientPhone: '+966500000002',
        doctorId: 'doctor_456',
        doctorName: 'د. سارة أحمد',
        specialization: 'Nutrition',
        appointmentDate: DateTime.now(),
        timeSlot: '11:00 ص',
        type: AppointmentType.video,
        status: AppointmentStatus.confirmed,
        fee: 150.0,
        createdAt: DateTime.now(),
        agoraToken: 'test_token',
        agoraChannelName: 'test_channel',
        agoraUid: 12345,
      );

      // Act
      await tester.pumpWidgetBuilder(
        AgoraVideoCallScreen(appointment: appointment),
        surfaceSize: const Size(375, 667),
        wrapper: materialAppWrapper(
          theme: ThemeData.light(),
        ),
      );

      // Wait for UI to settle
      await tester.pumpAndSettle();

      // Assert - Verify control buttons have correct opacity
      // This golden test will catch any visual changes from API migrations
      await screenMatchesGolden(
        tester,
        'agora_video_call_screen_controls',
      );
    });

    testGoldens('appointment info overlay with correct opacity', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appointment = AppointmentModel(
        id: 'test_appointment_3',
        patientId: 'patient_123',
        patientName: 'أحمد محمد علي',
        patientPhone: '+966500000003',
        doctorId: 'doctor_456',
        doctorName: 'د. سارة أحمد محمود',
        specialization: 'Nutrition',
        appointmentDate: DateTime.now(),
        timeSlot: '12:00 م',
        type: AppointmentType.video,
        status: AppointmentStatus.confirmed,
        fee: 150.0,
        createdAt: DateTime.now(),
        agoraToken: 'test_token',
        agoraChannelName: 'test_channel',
        agoraUid: 12345,
      );

      // Act
      await tester.pumpWidgetBuilder(
        AgoraVideoCallScreen(appointment: appointment),
        surfaceSize: const Size(375, 667),
        wrapper: materialAppWrapper(
          theme: ThemeData.light(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Verify appointment info overlay has correct opacity (50% black)
      await screenMatchesGolden(
        tester,
        'agora_video_call_screen_appointment_info',
      );
    });
  });
}
*/
