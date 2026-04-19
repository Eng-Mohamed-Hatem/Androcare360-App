import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/integration_test_config.dart';

void main() {
  const runAgoraMissedRejoinIntegration = bool.fromEnvironment(
    'RUN_AGORA_MISSED_REJOIN_INTEGRATION_TESTS',
  );

  if (!runAgoraMissedRejoinIntegration) {
    group('Agora Missed Call Rejoin Integration Test', () {
      test(
        'skipped unless RUN_AGORA_MISSED_REJOIN_INTEGRATION_TESTS=true',
        () {},
        skip:
            'Requires device/emulator, Firebase emulators, and callable function integration setup',
      );
    });
    return;
  }

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Agora Missed Call Rejoin Integration Test', () {
    late FirebaseFirestore firestore;
    late FirebaseFunctions functions;

    late String doctorUid;
    late String patientUid;
    late String appointmentId;

    setUpAll(() async {
      await IntegrationTestConfig.connectToEmulators();
      final running = await IntegrationTestConfig.verifyEmulatorsRunning();
      if (!running) {
        throw StateError(
          'Firebase Emulators not running. Start them with: firebase emulators:start',
        );
      }

      firestore = IntegrationTestConfig.getFirestore();
      functions = IntegrationTestConfig.getFunctions();
    });

    setUp(() async {
      await IntegrationTestConfig.clearFirestoreData();
      await IntegrationTestConfig.signOutAllUsers();

      doctorUid = 'doctor-rejoin-${DateTime.now().millisecondsSinceEpoch}';
      patientUid = 'patient-rejoin-${DateTime.now().millisecondsSinceEpoch}';

      await IntegrationTestConfig.createTestDocument(
        collection: 'users',
        documentId: doctorUid,
        data: {
          'id': doctorUid,
          'fullName': 'Dr Rejoin',
          'email': 'doctor-rejoin@test.com',
          'userType': 'doctor',
          'fcmToken': 'doctor_rejoin_fcm',
        },
      );
      await IntegrationTestConfig.createTestDocument(
        collection: 'users',
        documentId: patientUid,
        data: {
          'id': patientUid,
          'fullName': 'Patient Rejoin',
          'email': 'patient-rejoin@test.com',
          'userType': 'patient',
          'fcmToken': 'patient_rejoin_fcm',
        },
      );

      appointmentId =
          'apt_missed_rejoin_${DateTime.now().millisecondsSinceEpoch}';
      await IntegrationTestConfig.createTestDocument(
        collection: 'appointments',
        documentId: appointmentId,
        data: {
          'id': appointmentId,
          'doctorId': doctorUid,
          'patientId': patientUid,
          'doctorName': 'Dr Rejoin',
          'patientName': 'Patient Rejoin',
          'patientPhone': '+201000000000',
          'specialization': 'Nutrition',
          'type': 'video',
          'timeSlot': '10:00 AM',
          'fee': 200,
          'appointmentDate': Timestamp.fromDate(DateTime.utc(2026, 4)),
          'createdAt': Timestamp.fromDate(DateTime.utc(2026, 3, 31)),
          'status': 'scheduled',
        },
      );
    });

    tearDownAll(() async {
      await IntegrationTestConfig.cleanup();
    });

    testWidgets('doctor starts call, patient misses, then rejoins', (
      tester,
    ) async {
      final startResult = await functions
          .httpsCallable('startAgoraCallForTest')
          .call<Map<String, dynamic>>({
            'appointmentId': appointmentId,
            'doctorId': doctorUid,
          });
      expect(startResult.data['success'], isTrue);

      final missedResult = await functions
          .httpsCallable('handleMissedCallForTest')
          .call<Map<String, dynamic>>({
            'appointmentId': appointmentId,
            'patientId': patientUid,
          });
      expect(missedResult.data['success'], isTrue);

      var appointmentDoc = await firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
      var appointmentData = appointmentDoc.data();
      expect(appointmentData?['status'], 'missed');
      expect(appointmentData?['callSessionActive'], isTrue);

      final rejoinResult = await functions
          .httpsCallable('patientJoinCallForTest')
          .call<Map<String, dynamic>>({
            'appointmentId': appointmentId,
            'patientId': patientUid,
          });
      expect(rejoinResult.data['success'], isTrue);
      expect(rejoinResult.data['channelName'], isNotEmpty);
      expect(rejoinResult.data['agoraToken'], isNotEmpty);

      appointmentDoc = await firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
      appointmentData = appointmentDoc.data();
      expect(appointmentData?['status'], 'in_progress');

      final endResult = await functions
          .httpsCallable('endAgoraCallForTest')
          .call<Map<String, dynamic>>({'appointmentId': appointmentId});
      expect(endResult.data['success'], isTrue);

      final confirmResult = await functions
          .httpsCallable('confirmAppointmentCompletionForTest')
          .call<Map<String, dynamic>>({
            'appointmentId': appointmentId,
            'doctorId': doctorUid,
            'completed': true,
          });
      expect(confirmResult.data['success'], isTrue);

      appointmentDoc = await firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
      appointmentData = appointmentDoc.data();
      expect(appointmentData?['status'], 'completed');
    });
  });
}
