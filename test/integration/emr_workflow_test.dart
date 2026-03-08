/// Integration test for EMR (Electronic Medical Records) workflow
///
/// Tests the complete EMR workflow including creation, validation,
/// persistence, and retrieval for different specializations.
///
/// Note: These tests require Firebase emulator to be running.
/// Run: firebase emulators:start
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/firebase_emulator_helper.dart';
import '../fixtures/user_fixtures.dart';
import '../fixtures/appointment_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    'EMR Workflow Integration Test',
    () {
      setUp(() async {
        // Setup Firebase emulator
        await FirebaseEmulatorHelper.setupEmulator();

        // Clear any existing data
        await FirebaseEmulatorHelper.clearFirestore();

        // Seed test data
        await FirebaseEmulatorHelper.seedTestData();
      });

      tearDown(() async {
        // Cleanup after each test
        await FirebaseEmulatorHelper.cleanup();
      });

      testWidgets(
        'complete nutrition EMR workflow from creation to retrieval',
        (WidgetTester tester) async {
          // ═══════════════════════════════════════════════════════════════════
          // ARRANGE - Setup test data
          // ═══════════════════════════════════════════════════════════════════

          final doctor = UserFixtures.createDoctor();
          final patient = UserFixtures.createPatient();
          final appointment = AppointmentFixtures.createConfirmedAppointment(
            doctorId: doctor.id,
            patientId: patient.id,
          );

          // Verify users and appointment exist
          final doctorExists = await FirebaseEmulatorHelper.documentExists(
            collection: 'users',
            docId: doctor.id,
          );
          expect(doctorExists, isTrue, reason: 'Doctor should exist');

          final patientExists = await FirebaseEmulatorHelper.documentExists(
            collection: 'users',
            docId: patient.id,
          );
          expect(patientExists, isTrue, reason: 'Patient should exist');

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Doctor opens patient EMR
          // ═══════════════════════════════════════════════════════════════════

          // Check if patient has existing EMRs
          final existingEMRs = await _getPatientEMRs(
            patientId: patient.id,
            specialization: 'nutrition',
          );

          // Initially should be empty
          expect(
            existingEMRs.length,
            equals(0),
            reason: 'Patient should have no existing nutrition EMRs',
          );

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Doctor fills form fields
          // ═══════════════════════════════════════════════════════════════════

          const emrId = 'nutrition_emr_test_001';
          final emrData = {
            'id': emrId,
            'patientId': patient.id,
            'nutritionistId': doctor.id,
            'nutritionistName': doctor.fullName,
            'appointmentId': appointment.id,
            'visitDate': Timestamp.now(),
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
            'isLocked': false,
            'isFirstVisit': true,

            // Anthropometric Measurements
            'weightMeasured': true,
            'heightMeasured': true,
            'bmiCalculated': true,
            'waistCircumferenceMeasured': true,
            'weightChangeDocumented': true,
            'heightValue': 170.0,
            'weightValue': 75.0,
            'waistCircumferenceValue': 85.0,
            'hipCircumferenceValue': 95.0,

            // Patient and Visit Basics
            'isIdentityVerified': true,
            'isConsentObtained': true,
            'isReasonForVisitDocumented': true,
            'isDiagnosisReviewed': true,

            // Comprehensive Checklist
            'isWeightMeasured': true,
            'isHeightMeasured': true,
            'isBMICalculated': true,
            'isWaistCircumferenceMeasured': true,
            'isRecentWeightChangeDocumented': true,

            // Dietary Intake Assessment
            'is24HourRecallCompleted': true,
          };

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Validate data
          // ═══════════════════════════════════════════════════════════════════

          // Validate required fields
          expect(emrData['patientId'], isNotNull);
          expect(emrData['nutritionistId'], isNotNull);
          expect(emrData['appointmentId'], isNotNull);

          // Validate anthropometric measurements
          expect(emrData['heightValue'], greaterThan(0));
          expect(emrData['weightValue'], greaterThan(0));

          // Calculate BMI for validation
          final height = emrData['heightValue']! as double;
          final weight = emrData['weightValue']! as double;
          final bmi = weight / ((height / 100) * (height / 100));
          expect(bmi, greaterThan(0));
          expect(bmi, lessThan(100)); // Sanity check

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Save EMR to Firestore
          // ═══════════════════════════════════════════════════════════════════

          await _saveNutritionEMR(emrId: emrId, emrData: emrData);

          // Wait for EMR to be saved
          final emrSaved = await FirebaseEmulatorHelper.waitForDocument(
            collection: 'nutrition_emrs',
            docId: emrId,
            timeout: const Duration(seconds: 5),
          );
          expect(emrSaved, isTrue, reason: 'EMR should be saved');

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Retrieve EMR
          // ═══════════════════════════════════════════════════════════════════

          final savedEMR = await FirebaseEmulatorHelper.getDocument(
            collection: 'nutrition_emrs',
            docId: emrId,
          );
          expect(savedEMR, isNotNull);
          expect(savedEMR!['patientId'], equals(patient.id));
          expect(savedEMR['nutritionistId'], equals(doctor.id));
          expect(savedEMR['appointmentId'], equals(appointment.id));

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Verify all data persisted correctly
          // ═══════════════════════════════════════════════════════════════════

          // Verify anthropometric measurements
          expect(savedEMR['heightValue'], equals(170.0));
          expect(savedEMR['weightValue'], equals(75.0));
          expect(savedEMR['waistCircumferenceValue'], equals(85.0));
          expect(savedEMR['hipCircumferenceValue'], equals(95.0));

          // Verify checkboxes
          expect(savedEMR['weightMeasured'], isTrue);
          expect(savedEMR['heightMeasured'], isTrue);
          expect(savedEMR['bmiCalculated'], isTrue);
          expect(savedEMR['isIdentityVerified'], isTrue);
          expect(savedEMR['isConsentObtained'], isTrue);

          // Verify timestamps
          expect(savedEMR['createdAt'], isNotNull);
          expect(savedEMR['updatedAt'], isNotNull);
          expect(savedEMR['visitDate'], isNotNull);

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Retrieve patient's EMR history
          // ═══════════════════════════════════════════════════════════════════

          final patientEMRs = await _getPatientEMRs(
            patientId: patient.id,
            specialization: 'nutrition',
          );
          expect(
            patientEMRs.length,
            greaterThanOrEqualTo(1),
            reason: 'Patient should have at least one nutrition EMR',
          );

          final emrInHistory = patientEMRs.any((emr) => emr['id'] == emrId);
          expect(
            emrInHistory,
            isTrue,
            reason: 'Saved EMR should be in patient history',
          );
        },
      );

      testWidgets(
        'complete physiotherapy EMR workflow from creation to retrieval',
        (WidgetTester tester) async {
          // ═══════════════════════════════════════════════════════════════════
          // ARRANGE
          // ═══════════════════════════════════════════════════════════════════

          final doctor = UserFixtures.createPhysiotherapyDoctor();
          final patient = UserFixtures.createPatient();
          final appointment =
              AppointmentFixtures.createPhysiotherapyAppointment(
                doctorId: doctor.id,
                patientId: patient.id,
              );

          // ═══════════════════════════════════════════════════════════════════
          // ACT - Create physiotherapy EMR
          // ═══════════════════════════════════════════════════════════════════

          const emrId = 'physio_emr_test_001';
          final emrData = {
            'id': emrId,
            'patientId': patient.id,
            'doctorId': doctor.id,
            'doctorName': doctor.fullName,
            'appointmentId': appointment.id,
            'createdAt': Timestamp.now(),

            // Patient Basics
            'patientBasics': {
              'age': ['35'],
              'gender': ['Male'],
              'occupation': ['Software Engineer'],
            },

            // History
            'history': {
              'chiefComplaint': ['Lower back pain'],
              'duration': ['3 months'],
              'previousTreatment': ['Pain medication'],
            },

            // Physical Examination
            'physicalExamination': {
              'posture': ['Forward head posture'],
              'gait': ['Normal'],
              'rangeOfMotion': ['Limited lumbar flexion'],
            },

            // Assessment
            'assessment': {
              'diagnosis': ['Chronic lower back pain'],
              'functionalLimitations': ['Difficulty sitting for long periods'],
            },

            // Plan
            'plan': {
              'treatment': ['Manual therapy', 'Exercise therapy'],
              'frequency': ['3 times per week'],
              'duration': ['6 weeks'],
            },

            'primaryDiagnosis': 'Chronic mechanical lower back pain',
            'managementPlan':
                'Manual therapy combined with core strengthening exercises',
          };

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Validate and save
          // ═══════════════════════════════════════════════════════════════════

          // Validate required fields
          expect(emrData['patientId'], isNotNull);
          expect(emrData['doctorId'], isNotNull);
          expect(emrData['primaryDiagnosis'], isNotNull);

          await _savePhysiotherapyEMR(emrId: emrId, emrData: emrData);

          // Wait for EMR to be saved
          final emrSaved = await FirebaseEmulatorHelper.waitForDocument(
            collection: 'physiotherapy_emrs',
            docId: emrId,
            timeout: const Duration(seconds: 5),
          );
          expect(emrSaved, isTrue, reason: 'Physiotherapy EMR should be saved');

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Retrieve and verify
          // ═══════════════════════════════════════════════════════════════════

          final savedEMR = await FirebaseEmulatorHelper.getDocument(
            collection: 'physiotherapy_emrs',
            docId: emrId,
          );
          expect(savedEMR, isNotNull);
          expect(savedEMR!['patientId'], equals(patient.id));
          expect(savedEMR['doctorId'], equals(doctor.id));
          expect(
            savedEMR['primaryDiagnosis'],
            equals('Chronic mechanical lower back pain'),
          );

          // Verify nested data structures
          expect(savedEMR['patientBasics'], isNotNull);
          expect(savedEMR['history'], isNotNull);
          expect(savedEMR['physicalExamination'], isNotNull);
          expect(savedEMR['assessment'], isNotNull);
          expect(savedEMR['plan'], isNotNull);
        },
      );

      testWidgets(
        'EMR workflow handles update operations',
        (WidgetTester tester) async {
          // ═══════════════════════════════════════════════════════════════════
          // ARRANGE
          // ═══════════════════════════════════════════════════════════════════

          final doctor = UserFixtures.createDoctor();
          final patient = UserFixtures.createPatient();
          final appointment = AppointmentFixtures.createConfirmedAppointment(
            doctorId: doctor.id,
            patientId: patient.id,
          );

          // Create initial EMR
          const emrId = 'nutrition_emr_update_test_001';
          final initialData = {
            'id': emrId,
            'patientId': patient.id,
            'nutritionistId': doctor.id,
            'nutritionistName': doctor.fullName,
            'appointmentId': appointment.id,
            'visitDate': Timestamp.now(),
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
            'isLocked': false,
            'heightValue': 170.0,
            'weightValue': 75.0,
            'weightMeasured': true,
            'heightMeasured': true,
          };

          await _saveNutritionEMR(emrId: emrId, emrData: initialData);

          // ═══════════════════════════════════════════════════════════════════
          // ACT - Update EMR with new measurements
          // ═══════════════════════════════════════════════════════════════════

          await _updateNutritionEMR(
            emrId: emrId,
            updates: {
              'weightValue': 73.0, // Weight decreased
              'waistCircumferenceValue': 82.0,
              'waistCircumferenceMeasured': true,
              'updatedAt': Timestamp.now(),
            },
          );

          // ═══════════════════════════════════════════════════════════════════
          // ASSERT
          // ═══════════════════════════════════════════════════════════════════

          final updatedEMR = await FirebaseEmulatorHelper.getDocument(
            collection: 'nutrition_emrs',
            docId: emrId,
          );
          expect(updatedEMR, isNotNull);
          expect(updatedEMR!['weightValue'], equals(73.0));
          expect(updatedEMR['waistCircumferenceValue'], equals(82.0));
          expect(updatedEMR['waistCircumferenceMeasured'], isTrue);

          // Verify original data still intact
          expect(updatedEMR['heightValue'], equals(170.0));
          expect(updatedEMR['patientId'], equals(patient.id));
        },
      );

      testWidgets(
        'EMR workflow handles locked EMR restrictions',
        (WidgetTester tester) async {
          // ═══════════════════════════════════════════════════════════════════
          // ARRANGE
          // ═══════════════════════════════════════════════════════════════════

          final doctor = UserFixtures.createDoctor();
          final patient = UserFixtures.createPatient();
          final appointment = AppointmentFixtures.createConfirmedAppointment(
            doctorId: doctor.id,
            patientId: patient.id,
          );

          // Create locked EMR
          const emrId = 'nutrition_emr_locked_test_001';
          final lockedData = {
            'id': emrId,
            'patientId': patient.id,
            'nutritionistId': doctor.id,
            'nutritionistName': doctor.fullName,
            'appointmentId': appointment.id,
            'visitDate': Timestamp.now(),
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
            'isLocked': true,
            'lockedUntil': Timestamp.fromDate(
              DateTime.now().add(const Duration(hours: 24)),
            ),
            'heightValue': 170.0,
            'weightValue': 75.0,
          };

          await _saveNutritionEMR(emrId: emrId, emrData: lockedData);

          // ═══════════════════════════════════════════════════════════════════
          // ACT & ASSERT - Verify EMR is locked
          // ═══════════════════════════════════════════════════════════════════

          final savedEMR = await FirebaseEmulatorHelper.getDocument(
            collection: 'nutrition_emrs',
            docId: emrId,
          );
          expect(savedEMR, isNotNull);
          expect(savedEMR!['isLocked'], isTrue);
          expect(savedEMR['lockedUntil'], isNotNull);

          // In a real application, the UI would prevent editing
          // and the repository would reject update attempts
          final lockedUntil = (savedEMR['lockedUntil'] as Timestamp).toDate();
          final isStillLocked = DateTime.now().isBefore(lockedUntil);
          expect(isStillLocked, isTrue, reason: 'EMR should still be locked');
        },
      );

      testWidgets(
        'EMR workflow retrieves multiple EMRs for patient',
        (WidgetTester tester) async {
          // ═══════════════════════════════════════════════════════════════════
          // ARRANGE - Create multiple EMRs for same patient
          // ═══════════════════════════════════════════════════════════════════

          final doctor = UserFixtures.createDoctor();
          final patient = UserFixtures.createPatient();

          // Create 3 EMRs for the patient
          for (var i = 1; i <= 3; i++) {
            final emrId = 'nutrition_emr_multi_test_00$i';
            final emrData = {
              'id': emrId,
              'patientId': patient.id,
              'nutritionistId': doctor.id,
              'nutritionistName': doctor.fullName,
              'appointmentId': 'apt_test_00$i',
              'visitDate': Timestamp.fromDate(
                DateTime.now().subtract(Duration(days: i * 7)),
              ),
              'createdAt': Timestamp.now(),
              'updatedAt': Timestamp.now(),
              'isLocked': false,
              'heightValue': 170.0,
              'weightValue': 75.0 - i, // Decreasing weight over time
            };

            await _saveNutritionEMR(emrId: emrId, emrData: emrData);
          }

          // ═══════════════════════════════════════════════════════════════════
          // ACT - Retrieve all EMRs for patient
          // ═══════════════════════════════════════════════════════════════════

          final patientEMRs = await _getPatientEMRs(
            patientId: patient.id,
            specialization: 'nutrition',
          );

          // ═══════════════════════════════════════════════════════════════════
          // ASSERT
          // ═══════════════════════════════════════════════════════════════════

          expect(
            patientEMRs.length,
            equals(3),
            reason: 'Patient should have 3 nutrition EMRs',
          );

          // Verify all EMRs belong to the patient
          for (final emr in patientEMRs) {
            expect(emr['patientId'], equals(patient.id));
          }

          // Verify EMRs are ordered by visit date (most recent first)
          // This assumes the query orders by visitDate descending
          if (patientEMRs.length >= 2) {
            final firstVisit = (patientEMRs[0]['visitDate'] as Timestamp)
                .toDate();
            final secondVisit = (patientEMRs[1]['visitDate'] as Timestamp)
                .toDate();
            expect(
              firstVisit.isAfter(secondVisit) ||
                  firstVisit.isAtSameMomentAs(secondVisit),
              isTrue,
              reason: 'EMRs should be ordered by visit date',
            );
          }
        },
      );
    },
    skip:
        'Integration tests require Firebase Emulator. Run manually with: firebase emulators:start',
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

/// Saves a nutrition EMR to Firestore
Future<void> _saveNutritionEMR({
  required String emrId,
  required Map<String, dynamic> emrData,
}) async {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech',
  );

  await firestore.collection('nutrition_emrs').doc(emrId).set(emrData);
}

/// Updates a nutrition EMR in Firestore
Future<void> _updateNutritionEMR({
  required String emrId,
  required Map<String, dynamic> updates,
}) async {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech',
  );

  await firestore.collection('nutrition_emrs').doc(emrId).update(updates);
}

/// Saves a physiotherapy EMR to Firestore
Future<void> _savePhysiotherapyEMR({
  required String emrId,
  required Map<String, dynamic> emrData,
}) async {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech',
  );

  await firestore.collection('physiotherapy_emrs').doc(emrId).set(emrData);
}

/// Gets all EMRs for a patient by specialization
Future<List<Map<String, dynamic>>> _getPatientEMRs({
  required String patientId,
  required String specialization,
}) async {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech',
  );

  final collectionName = '${specialization}_emrs';

  final snapshot = await firestore
      .collection(collectionName)
      .where('patientId', isEqualTo: patientId)
      .orderBy('visitDate', descending: true)
      .get();

  return snapshot.docs.map((doc) => doc.data()).toList();
}
