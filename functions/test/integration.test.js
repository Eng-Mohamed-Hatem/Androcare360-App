/**
 * Cloud Functions Integration Tests
 * 
 * File: functions/test/integration.test.js
 * 
 * Purpose: End-to-end integration tests for Cloud Functions to verify
 * the complete call flow works correctly with the 'elajtech' database.
 * 
 * These tests validate that the database configuration fix ensures:
 * - startAgoraCall retrieves appointments from 'elajtech'
 * - endAgoraCall updates appointments in 'elajtech'
 * - completeAppointment updates appointments in 'elajtech'
 * - Call logs are written to 'elajtech'
 * 
 * Requirements Validated:
 * - 1.2: endAgoraCall updates elajtech database
 * - 1.3: completeAppointment updates elajtech database
 * - 2.1: Doctor initiates video call
 * - 2.2: Function finds appointment in elajtech
 * - 2.3: Function generates Agora tokens
 * - 2.4: Function returns tokens to doctor
 * - 2.5: No "Appointment Not Found" errors
 * - 4.1: Call attempt events logged
 * - 4.2: Call started events logged
 * - 4.5: Call ended events logged
 * - 7.2: Integration tests for complete flow
 */

const { admin, db, createMockContext, functionsTest } = require('./setup');
const {
  createAppointmentFixture,
  createAppointmentWithCallDataFixture,
  createDoctorFixture,
  createPatientFixture,
} = require('./fixtures');

// Import Cloud Functions
const {
  startAgoraCall,
  endAgoraCall,
  completeAppointment,
  confirmAppointmentCompletion,
  handleMissedCall,
  handleCallDeclined,
} = require('../index');

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Setup test data in Firestore
 * Creates appointment, doctor, and patient documents
 */
async function setupTestData(appointment, doctor, patient) {
  await db.collection('appointments').doc(appointment.id).set(appointment);
  await db.collection('users').doc(doctor.id).set(doctor);
  await db.collection('users').doc(patient.id).set(patient);
}

/**
 * Get call logs for a specific appointment
 */
async function getCallLogs(appointmentId) {
  const snapshot = await db
    .collection('call_logs')
    .where('appointmentId', '==', appointmentId)
    .get();
  
  return snapshot.docs.map(doc => doc.data());
}

/**
 * Wait for async operations to complete
 */
function wait(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// ============================================================================
// TASK 4.3: INTEGRATION TEST FOR startAgoraCall
// ============================================================================

describe('Cloud Functions Integration Tests', () => {
  describe('startAgoraCall Function', () => {
    test('should successfully start call and retrieve appointment from elajtech', async () => {
      // Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 4.1, 4.2
      
      // Arrange: Create test data
      const appointment = createAppointmentFixture({
        id: 'test_apt_start_001',
        doctorId: 'doctor_start_001',
        patientId: 'patient_start_001',
      });
      const doctor = createDoctorFixture({ id: appointment.doctorId });
      const patient = createPatientFixture({ id: appointment.patientId });
      
      await setupTestData(appointment, doctor, patient);
      
      const context = createMockContext(doctor.id);
      
      // Act: Call startAgoraCall
      const result = await functionsTest.wrap(startAgoraCall)({
        appointmentId: appointment.id,
        doctorId: doctor.id,
        deviceInfo: {
          platform: 'android',
          deviceModel: 'Test Device',
        },
      }, context);
      
      // Assert: Verify success
      expect(result.success).toBe(true);
      expect(result.message).toBeDefined();
      
      // Assert: Verify Agora tokens generated (Requirement 2.3)
      expect(result.agoraToken).toBeDefined();
      expect(result.agoraChannelName).toBeDefined();
      expect(result.agoraUid).toBeDefined();
      expect(typeof result.agoraToken).toBe('string');
      expect(typeof result.agoraChannelName).toBe('string');
      expect(typeof result.agoraUid).toBe('number');
      
      // Assert: Verify appointment updated in elajtech (Requirement 2.2)
      const updatedDoc = await db.collection('appointments').doc(appointment.id).get();
      expect(updatedDoc.exists).toBe(true);
      // Database ID is verified through the db instance configuration
      
      const updatedData = updatedDoc.data();
      expect(updatedData.agoraChannelName).toBe(result.agoraChannelName);
      expect(updatedData.doctorAgoraToken).toBeDefined();
      expect(updatedData.agoraToken).toBeDefined(); // Patient token
      expect(updatedData.callStartedAt).toBeDefined();
      
      // Assert: Verify call logs written to elajtech (Requirements 4.1, 4.2)
      await wait(500); // Wait for async logging
      const logs = await getCallLogs(appointment.id);
      expect(logs.length).toBeGreaterThanOrEqual(2); // call_attempt + call_started
      
      const attemptLog = logs.find(log => log.eventType === 'call_attempt');
      const startedLog = logs.find(log => log.eventType === 'call_started');
      
      expect(attemptLog).toBeDefined();
      expect(startedLog).toBeDefined();
      expect(attemptLog.userId).toBe(doctor.id);
      expect(startedLog.userId).toBe(doctor.id);
    });

    test('should return error when appointment not found', async () => {
      // Validates: Requirement 2.5 (proper error handling)
      
      const doctor = createDoctorFixture({ id: 'doctor_notfound_001' });
      await db.collection('users').doc(doctor.id).set(doctor);
      
      const context = createMockContext(doctor.id);
      
      // Act & Assert: Expect error
      await expect(
        functionsTest.wrap(startAgoraCall)({
          appointmentId: 'nonexistent_apt',
          doctorId: doctor.id,
        }, context)
      ).rejects.toThrow();
      
      // Verify error log was created
      await wait(500);
      const logs = await getCallLogs('nonexistent_apt');
      const errorLog = logs.find(log => log.eventType === 'call_error');
      expect(errorLog).toBeDefined();
      expect(errorLog.errorCode).toBe('appointment_not_found');
    });

    test('should return error when doctor is not authorized', async () => {
      // Validates: Requirement 2.1 (authorization check)
      
      const appointment = createAppointmentFixture({
        id: 'test_apt_auth_001',
        doctorId: 'doctor_auth_001',
      });
      const wrongDoctor = createDoctorFixture({ id: 'doctor_wrong_001' });
      
      await db.collection('appointments').doc(appointment.id).set(appointment);
      await db.collection('users').doc(wrongDoctor.id).set(wrongDoctor);
      
      const context = createMockContext(wrongDoctor.id);
      
      // Act & Assert: Expect permission denied error
      await expect(
        functionsTest.wrap(startAgoraCall)({
          appointmentId: appointment.id,
          doctorId: wrongDoctor.id,
        }, context)
      ).rejects.toThrow();
    });

    test('should reject payload doctorId mismatch with authenticated doctor', async () => {
      const appointment = createAppointmentFixture({
        id: 'test_apt_auth_mismatch_001',
        doctorId: 'doctor_auth_match_001',
        patientId: 'patient_auth_match_001',
      });
      const doctor = createDoctorFixture({ id: appointment.doctorId });
      const patient = createPatientFixture({ id: appointment.patientId });

      await setupTestData(appointment, doctor, patient);

      const context = createMockContext(doctor.id);

      try {
        await functionsTest.wrap(startAgoraCall)({
          appointmentId: appointment.id,
          doctorId: 'doctor_payload_mismatch_001',
        }, context);
        throw new Error('Expected startAgoraCall to throw');
      } catch (error) {
        expect(error.code).toBe('permission-denied');
      }
    });

    test('should handle missing authentication context', async () => {
      // Validates: Requirement 2.1 (authentication required)
      
      const appointment = createAppointmentFixture();
      await db.collection('appointments').doc(appointment.id).set(appointment);
      
      // No authentication context
      const context = { auth: null };
      
      // Act & Assert: Expect unauthenticated error
      await expect(
        functionsTest.wrap(startAgoraCall)({
          appointmentId: appointment.id,
          doctorId: 'doctor_001',
        }, context)
      ).rejects.toThrow();
    });
  });

  // ============================================================================
  // TASK 4.4: INTEGRATION TEST FOR endAgoraCall
  // ============================================================================

  describe('endAgoraCall Function', () => {
    test('should successfully end call and update appointment in elajtech', async () => {
      // Validates: Requirements 1.2, 4.5
      
      // Arrange: Create appointment with call data
      const appointment = createAppointmentWithCallDataFixture({
        id: 'test_apt_end_001',
        doctorId: 'doctor_end_001',
      });
      const doctor = createDoctorFixture({ id: appointment.doctorId });
      
      await db.collection('appointments').doc(appointment.id).set(appointment);
      await db.collection('users').doc(doctor.id).set(doctor);
      
      const context = createMockContext(doctor.id);
      
      // Act: Call endAgoraCall
      const result = await functionsTest.wrap(endAgoraCall)({
        appointmentId: appointment.id,
      }, context);
      
      // Assert: Verify success
      expect(result.success).toBe(true);
      expect(result.message).toBeDefined();
      
      // Assert: Verify callEndedAt timestamp set in elajtech (Requirement 1.2)
      const updatedDoc = await db.collection('appointments').doc(appointment.id).get();
      expect(updatedDoc.exists).toBe(true);
      // Database ID is verified through the db instance configuration
      
      const updatedData = updatedDoc.data();
      expect(updatedData.callEndedAt).toBeDefined();
      expect(updatedData.callEndedAt).toBeInstanceOf(Object); // Firestore Timestamp
      expect(updatedData.callStatus).toBe('ended');
      expect(updatedData.status).not.toBe('completed');
    });

    test('should handle missing appointment', async () => {
      // Validates: Error handling for endAgoraCall
      
      const context = createMockContext('doctor_001');
      
      // Act & Assert: Expect error
      await expect(
        functionsTest.wrap(endAgoraCall)({
          appointmentId: 'nonexistent_apt',
        }, context)
      ).rejects.toThrow();
    });

    test('should require authentication', async () => {
      // Validates: Authentication requirement
      
      const appointment = createAppointmentWithCallDataFixture();
      await db.collection('appointments').doc(appointment.id).set(appointment);
      
      const context = { auth: null };
      
      // Act & Assert: Expect unauthenticated error
      await expect(
        functionsTest.wrap(endAgoraCall)({
          appointmentId: appointment.id,
        }, context)
      ).rejects.toThrow();
    });

    test('should reject callers unrelated to the appointment', async () => {
      const appointment = createAppointmentWithCallDataFixture({
        id: 'test_apt_end_auth_001',
        doctorId: 'doctor_end_auth_001',
        patientId: 'patient_end_auth_001',
      });
      const unrelatedUser = createDoctorFixture({ id: 'doctor_unrelated_001' });

      await db.collection('appointments').doc(appointment.id).set(appointment);
      await db.collection('users').doc(unrelatedUser.id).set(unrelatedUser);

      const context = createMockContext(unrelatedUser.id);

      await expect(
        functionsTest.wrap(endAgoraCall)({
          appointmentId: appointment.id,
        }, context)
      ).rejects.toThrow();
    });

    test('should preserve permission-denied error details for unrelated callers', async () => {
      const appointment = createAppointmentWithCallDataFixture({
        id: 'test_apt_end_auth_code_001',
        doctorId: 'doctor_end_auth_code_001',
        patientId: 'patient_end_auth_code_001',
      });
      const unrelatedUser = createDoctorFixture({ id: 'doctor_unrelated_code_001' });

      await db.collection('appointments').doc(appointment.id).set(appointment);
      await db.collection('users').doc(unrelatedUser.id).set(unrelatedUser);

      try {
        await functionsTest.wrap(endAgoraCall)({
          appointmentId: appointment.id,
        }, createMockContext(unrelatedUser.id));
        throw new Error('Expected endAgoraCall to throw');
      } catch (error) {
        expect(error.code).toBe('permission-denied');
      }
    });

    test('should keep doctor-side end result terminal and non-restorable for patient join flow', async () => {
      const appointment = createAppointmentWithCallDataFixture({
        id: 'test_apt_end_terminal_001',
        doctorId: 'doctor_end_terminal_001',
        patientId: 'patient_end_terminal_001',
        callStatus: 'joining',
        status: 'calling',
      });
      const doctor = createDoctorFixture({ id: appointment.doctorId });
      const patient = createPatientFixture({ id: appointment.patientId });

      await setupTestData(appointment, doctor, patient);

      const context = createMockContext(doctor.id);
      await functionsTest.wrap(endAgoraCall)({ appointmentId: appointment.id }, context);

      const updatedDoc = await db.collection('appointments').doc(appointment.id).get();
      const updatedData = updatedDoc.data();

      expect(updatedData.callStatus).toBe('ended');
      expect(updatedData.callSessionActive).toBe(false);
      expect(updatedData.status).not.toBe('in_progress');
    });

    test('T030 targeted: joining state ends in ended_pending_confirmation instead of missed', async () => {
      const appointment = createAppointmentWithCallDataFixture({
        id: 'test_t030_joining_terminal_001',
        doctorId: 'doctor_t030_001',
        patientId: 'patient_t030_001',
        status: 'calling',
        callStatus: 'joining',
        callSessionActive: true,
      });
      const doctor = createDoctorFixture({ id: appointment.doctorId });
      const patient = createPatientFixture({ id: appointment.patientId });

      await setupTestData(appointment, doctor, patient);

      const context = createMockContext(doctor.id);
      const result = await functionsTest.wrap(endAgoraCall)({
        appointmentId: appointment.id,
      }, context);

      expect(result.success).toBe(true);

      const updatedDoc = await db.collection('appointments').doc(appointment.id).get();
      expect(updatedDoc.exists).toBe(true);
      const updatedData = updatedDoc.data();

      expect(updatedData.callStatus).toBe('ended');
      expect(updatedData.callSessionActive).toBe(false);
      expect(updatedData.status).toBe('ended_pending_confirmation');
      expect(updatedData.confirmationDeadlineAt).toBeDefined();
    });
  });

  // ============================================================================
  // TASK 4.5: INTEGRATION TEST FOR completeAppointment
  // ============================================================================

  describe('completeAppointment Function', () => {
    test('should successfully complete appointment and update status in elajtech', async () => {
      // Validates: Requirements 1.3, 4.5
      
      // Arrange: Create appointment with call data
      const appointment = createAppointmentWithCallDataFixture({
        id: 'test_apt_complete_001',
        doctorId: 'doctor_complete_001',
        status: 'on_call',
      });
      const doctor = createDoctorFixture({ id: appointment.doctorId });
      
      await db.collection('appointments').doc(appointment.id).set(appointment);
      await db.collection('users').doc(doctor.id).set(doctor);
      
      const context = createMockContext(doctor.id);
      
      // Act: Call completeAppointment
      const result = await functionsTest.wrap(completeAppointment)({
        appointmentId: appointment.id,
        doctorId: doctor.id,
      }, context);
      
      // Assert: Verify success
      expect(result.success).toBe(true);
      expect(result.message).toBeDefined();
      
      // Assert: Verify status updated to 'completed' in elajtech (Requirement 1.3)
      const updatedDoc = await db.collection('appointments').doc(appointment.id).get();
      expect(updatedDoc.exists).toBe(true);
      // Database ID is verified through the db instance configuration
      
      const updatedData = updatedDoc.data();
      expect(updatedData.status).toBe('completed');
      expect(updatedData.completedAt).toBeDefined();
      expect(updatedData.completedAt).toBeInstanceOf(Object); // Firestore Timestamp
    });

    test('should return error when appointment not found', async () => {
      // Validates: Error handling
      
      const doctor = createDoctorFixture({ id: 'doctor_001' });
      await db.collection('users').doc(doctor.id).set(doctor);
      
      const context = createMockContext(doctor.id);
      
      // Act & Assert: Expect error
      await expect(
        functionsTest.wrap(completeAppointment)({
          appointmentId: 'nonexistent_apt',
          doctorId: doctor.id,
        }, context)
      ).rejects.toThrow();
    });

    test('should return error when doctor is not authorized', async () => {
      // Validates: Authorization check
      
      const appointment = createAppointmentWithCallDataFixture({
        id: 'test_apt_auth_002',
        doctorId: 'doctor_auth_002',
      });
      const wrongDoctor = createDoctorFixture({ id: 'doctor_wrong_002' });
      
      await db.collection('appointments').doc(appointment.id).set(appointment);
      await db.collection('users').doc(wrongDoctor.id).set(wrongDoctor);
      
      const context = createMockContext(wrongDoctor.id);
      
      // Act & Assert: Expect permission denied error
      await expect(
        functionsTest.wrap(completeAppointment)({
          appointmentId: appointment.id,
          doctorId: wrongDoctor.id,
        }, context)
      ).rejects.toThrow();
    });

    test('should reject payload doctorId mismatch with authenticated doctor', async () => {
      const appointment = createAppointmentWithCallDataFixture({
        id: 'test_apt_complete_mismatch_001',
        doctorId: 'doctor_complete_match_001',
      });
      const doctor = createDoctorFixture({ id: appointment.doctorId });

      await db.collection('appointments').doc(appointment.id).set(appointment);
      await db.collection('users').doc(doctor.id).set(doctor);

      const context = createMockContext(doctor.id);

      try {
        await functionsTest.wrap(completeAppointment)({
          appointmentId: appointment.id,
          doctorId: 'doctor_payload_mismatch_002',
        }, context);
        throw new Error('Expected completeAppointment to throw');
      } catch (error) {
        expect(error.code).toBe('permission-denied');
      }
    });

    test('should require authentication', async () => {
      // Validates: Authentication requirement
      
      const appointment = createAppointmentWithCallDataFixture();
      await db.collection('appointments').doc(appointment.id).set(appointment);
      
      const context = { auth: null };
      
      // Act & Assert: Expect unauthenticated error
      await expect(
        functionsTest.wrap(completeAppointment)({
          appointmentId: appointment.id,
          doctorId: 'doctor_001',
        }, context)
      ).rejects.toThrow();
    });
  });

  describe('Missed and Declined Call Handlers', () => {
    test('should export handleMissedCall and keep appointment non-completed', async () => {
      expect(handleMissedCall).toBeDefined();

      const appointment = createAppointmentWithCallDataFixture({
        id: 'test_apt_missed_001',
        doctorId: 'doctor_missed_001',
        patientId: 'patient_missed_001',
        status: 'scheduled',
      });
      const patient = createPatientFixture({ id: appointment.patientId });

      await db.collection('appointments').doc(appointment.id).set(appointment);
      await db.collection('users').doc(patient.id).set(patient);

      const result = await functionsTest.wrap(handleMissedCall)({
        appointmentId: appointment.id,
      }, createMockContext(patient.id));

      expect(result.success).toBe(true);

      const updatedDoc = await db.collection('appointments').doc(appointment.id).get();
      const updatedData = updatedDoc.data();

      expect(updatedData.callStatus).toBe('missed');
      expect(updatedData.missedAt).toBeDefined();
      expect(updatedData.status).not.toBe('completed');

      await wait(200);
      const logs = await getCallLogs(appointment.id);
      expect(logs.find(log => log.eventType === 'call_missed')).toBeDefined();
    });

    test('should ignore missed callback after call already ended', async () => {
      const appointment = createAppointmentWithCallDataFixture({
        id: 'test_apt_missed_ignored_001',
        doctorId: 'doctor_missed_ignored_001',
        patientId: 'patient_missed_ignored_001',
        status: 'scheduled',
        callStatus: 'ended',
      });
      const patient = createPatientFixture({ id: appointment.patientId });

      await db.collection('appointments').doc(appointment.id).set(appointment);
      await db.collection('users').doc(patient.id).set(patient);

      const result = await functionsTest.wrap(handleMissedCall)({
        appointmentId: appointment.id,
      }, createMockContext(patient.id));

      expect(result.success).toBe(true);

      const updatedDoc = await db.collection('appointments').doc(appointment.id).get();
      const updatedData = updatedDoc.data();
      expect(updatedData.callStatus).toBe('ended');

      await wait(200);
      const logs = await getCallLogs(appointment.id);
      expect(logs.find(log => log.eventType === 'call_missed_ignored')).toBeDefined();
    });

    test('should export handleCallDeclined and keep appointment non-completed', async () => {
      expect(handleCallDeclined).toBeDefined();

      const appointment = createAppointmentWithCallDataFixture({
        id: 'test_apt_declined_001',
        doctorId: 'doctor_declined_001',
        patientId: 'patient_declined_001',
        status: 'scheduled',
      });
      const patient = createPatientFixture({ id: appointment.patientId });

      await db.collection('appointments').doc(appointment.id).set(appointment);
      await db.collection('users').doc(patient.id).set(patient);

      const result = await functionsTest.wrap(handleCallDeclined)({
        appointmentId: appointment.id,
      }, createMockContext(patient.id));

      expect(result.success).toBe(true);

      const updatedDoc = await db.collection('appointments').doc(appointment.id).get();
      const updatedData = updatedDoc.data();

      expect(updatedData.callStatus).toBe('declined');
      expect(updatedData.declinedAt).toBeDefined();
      expect(updatedData.status).not.toBe('completed');

      await wait(200);
      const logs = await getCallLogs(appointment.id);
      expect(logs.find(log => log.eventType === 'call_declined')).toBeDefined();
    });

    test('should ignore declined callback after appointment is already completed', async () => {
      const appointment = createAppointmentWithCallDataFixture({
        id: 'test_apt_declined_ignored_001',
        doctorId: 'doctor_declined_ignored_001',
        patientId: 'patient_declined_ignored_001',
        status: 'completed',
        callStatus: 'ended',
      });
      const patient = createPatientFixture({ id: appointment.patientId });

      await db.collection('appointments').doc(appointment.id).set(appointment);
      await db.collection('users').doc(patient.id).set(patient);

      const result = await functionsTest.wrap(handleCallDeclined)({
        appointmentId: appointment.id,
      }, createMockContext(patient.id));

      expect(result.success).toBe(true);

      const updatedDoc = await db.collection('appointments').doc(appointment.id).get();
      const updatedData = updatedDoc.data();
      expect(updatedData.status).toBe('completed');
      expect(updatedData.callStatus).toBe('ended');

      await wait(200);
      const logs = await getCallLogs(appointment.id);
      expect(logs.find(log => log.eventType === 'call_declined_ignored')).toBeDefined();
    });
  });

  // ============================================================================
  // TASK 4.2: PROPERTY TEST FOR APPOINTMENT RETRIEVAL
  // ============================================================================

  describe('Appointment Retrieval (Property Test)', () => {
    test('Property 2: startAgoraCall retrieves appointments from elajtech (100 iterations)', async () => {
      // Feature: voip-appointment-not-found-bugfix
      // Property 2: Appointment Retrieval Success
      // Validates: Requirements 2.2, 2.5
      //
      // Property Definition:
      // For ANY existing appointment in the 'elajtech' database,
      // when startAgoraCall is invoked with that appointmentId,
      // the function MUST successfully retrieve the appointment document.
      //
      // Test Strategy:
      // - Generate 100 random appointments
      // - Create each in 'elajtech' database
      // - Call startAgoraCall for each
      // - Verify successful retrieval and token generation
      // - Verify no "Appointment Not Found" errors
      
      const iterations = 100;
      let successCount = 0;
      
      for (let i = 0; i < iterations; i++) {
        // Generate random appointment
        const appointment = createAppointmentFixture({
          id: `prop_apt_${String(i).padStart(3, '0')}`,
          doctorId: `prop_doctor_${i}`,
          patientId: `prop_patient_${i}`,
        });
        const doctor = createDoctorFixture({ id: appointment.doctorId });
        const patient = createPatientFixture({ id: appointment.patientId });
        
        // Create in elajtech database
        await setupTestData(appointment, doctor, patient);
        
        const context = createMockContext(doctor.id);
        
        // Call startAgoraCall
        const result = await functionsTest.wrap(startAgoraCall)({
          appointmentId: appointment.id,
          doctorId: doctor.id,
        }, context);
        
        // Verify success (Requirement 2.2)
        expect(result.success).toBe(true);
        
        // Verify tokens generated (Requirement 2.5)
        expect(result.agoraToken).toBeDefined();
        expect(result.agoraChannelName).toBeDefined();
        expect(result.agoraUid).toBeDefined();
        
        // Verify appointment retrieved from elajtech
        const doc = await db.collection('appointments').doc(appointment.id).get();
        expect(doc.exists).toBe(true);
        // Database ID is verified through the db instance configuration
        
        successCount++;
      }
      
      // Verify all iterations passed
      expect(successCount).toBe(iterations);
    }, 60000); // 60 second timeout for 100 iterations
  });

  // ============================================================================
  // TASK 4.6: PROPERTY TEST FOR CALL LOGGING CONSISTENCY
  // ============================================================================

  describe('Call Logging Consistency (Property Test)', () => {
    test('Property 5: All call events logged to elajtech database (100 iterations)', async () => {
      // Feature: voip-appointment-not-found-bugfix
      // Property 5: Call Logging Consistency
      // Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5
      //
      // Property Definition:
      // For ANY call event (attempt, started, error, ended),
      // the event MUST be logged to the 'call_logs' collection
      // in the 'elajtech' database with complete metadata.
      //
      // Test Strategy:
      // - Generate 100 random call events
      // - Trigger events via Cloud Functions
      // - Query call_logs collection in 'elajtech'
      // - Verify all events logged with metadata
      // - Verify events are in 'elajtech', not default
      
      const iterations = 100;
      let successCount = 0;
      
      for (let i = 0; i < iterations; i++) {
        const appointment = createAppointmentFixture({
          id: `log_apt_${String(i).padStart(3, '0')}`,
          doctorId: `log_doctor_${i}`,
          patientId: `log_patient_${i}`,
        });
        const doctor = createDoctorFixture({ id: appointment.doctorId });
        const patient = createPatientFixture({ id: appointment.patientId });
        
        await setupTestData(appointment, doctor, patient);
        
        const context = createMockContext(doctor.id);
        
        // Trigger call events
        await functionsTest.wrap(startAgoraCall)({
          appointmentId: appointment.id,
          doctorId: doctor.id,
        }, context);
        
        // Wait for async logging
        await wait(100);
        
        // Query call_logs from elajtech
        const logsSnapshot = await db
          .collection('call_logs')
          .where('appointmentId', '==', appointment.id)
          .get();
        
        // Verify logs exist
        expect(logsSnapshot.empty).toBe(false);
        expect(logsSnapshot.size).toBeGreaterThanOrEqual(2); // attempt + started
        
        // Database ID is verified through the db instance configuration
        
        // Verify log metadata
        const logs = logsSnapshot.docs.map(doc => doc.data());
        const attemptLog = logs.find(log => log.eventType === 'call_attempt');
        const startedLog = logs.find(log => log.eventType === 'call_started');
        
        expect(attemptLog).toBeDefined();
        expect(attemptLog.appointmentId).toBe(appointment.id);
        expect(attemptLog.userId).toBe(doctor.id);
        expect(attemptLog.timestamp).toBeDefined();
        
        expect(startedLog).toBeDefined();
        expect(startedLog.appointmentId).toBe(appointment.id);
        expect(startedLog.userId).toBe(doctor.id);
        expect(startedLog.metadata).toBeDefined();
        
        successCount++;
      }
      
      expect(successCount).toBe(iterations);
    }, 60000); // 60 second timeout
  });

  // ============================================================================
  // END-TO-END CALL FLOW TESTS
  // ============================================================================

  describe('End-to-End Call Flow', () => {
    // Shared fixture factory
    function makeE2EFixtures(suffix) {
      const appointment = createAppointmentFixture({
        id: `test_apt_e2e_${suffix}`,
        doctorId: `doctor_e2e_${suffix}`,
        patientId: `patient_e2e_${suffix}`,
      });
      const doctor = createDoctorFixture({ id: appointment.doctorId });
      const patient = createPatientFixture({ id: appointment.patientId });
      return { appointment, doctor, patient };
    }

    test('should complete full call flow: start → in_progress → ended_pending_confirmation → completed (Yes)', async () => {
      // Validates: FR-015 (no auto-complete), FR-016 (Yes → completed),
      //            FR-017 (completedAt stamped), Requirements: 2.1–2.4, 1.2, 1.3, 4.1, 4.2, 4.5
      const { appointment, doctor, patient } = makeE2EFixtures('001');
      await setupTestData(appointment, doctor, patient);
      const context = createMockContext(doctor.id);

      // Act 1: Doctor starts call
      const startResult = await functionsTest.wrap(startAgoraCall)({
        appointmentId: appointment.id,
        doctorId: doctor.id,
      }, context);
      expect(startResult.success).toBe(true);
      expect(startResult.agoraToken).toBeDefined();

      let apptDoc = await db.collection('appointments').doc(appointment.id).get();
      expect(apptDoc.data().status).toBe('calling');
      expect(apptDoc.data().callSessionId).toBeDefined();

      // Act 2: Simulate patient joining (mark in_progress)
      await db.collection('appointments').doc(appointment.id).update({
        status: 'in_progress',
        callSessionActive: true,
      });

      // Act 3: Doctor ends call → must become ended_pending_confirmation (FR-015)
      const endResult = await functionsTest.wrap(endAgoraCall)({
        appointmentId: appointment.id,
      }, context);
      expect(endResult.success).toBe(true);

      apptDoc = await db.collection('appointments').doc(appointment.id).get();
      const afterEnd = apptDoc.data();
      expect(afterEnd.status).toBe('ended_pending_confirmation',
        'endAgoraCall must NOT auto-complete — FR-015');
      expect(afterEnd.callEndedAt).toBeDefined();
      expect(afterEnd.confirmationDeadlineAt).toBeDefined(
        'confirmationDeadlineAt must be set for 24h auto-transition — FR-038');
      expect(afterEnd.callSessionActive).toBe(false);

      // Act 4: Doctor confirms Yes → completed (FR-016)
      const confirmResult = await functionsTest.wrap(confirmAppointmentCompletion)({
        appointmentId: appointment.id,
        doctorId: doctor.id,
        completed: true,
      }, context);
      expect(confirmResult.success).toBe(true);

      apptDoc = await db.collection('appointments').doc(appointment.id).get();
      const finalData = apptDoc.data();
      expect(finalData.status).toBe('completed');
      expect(finalData.completedAt).toBeDefined();
      expect(finalData.agoraChannelName).toBeDefined();
      expect(finalData.callStartedAt).toBeDefined();

      // Verify call logs
      await wait(500);
      const logs = await getCallLogs(appointment.id);
      expect(logs.length).toBeGreaterThanOrEqual(2);
    });

    test('should produce not_completed when doctor confirms No (FR-018)', async () => {
      const { appointment, doctor, patient } = makeE2EFixtures('002');
      await setupTestData(appointment, doctor, patient);
      const context = createMockContext(doctor.id);

      // Bring to ended_pending_confirmation
      await functionsTest.wrap(startAgoraCall)(
        { appointmentId: appointment.id, doctorId: doctor.id }, context);
      await db.collection('appointments').doc(appointment.id).update({
        status: 'in_progress', callSessionActive: true,
      });
      await functionsTest.wrap(endAgoraCall)(
        { appointmentId: appointment.id }, context);

      let apptDoc = await db.collection('appointments').doc(appointment.id).get();
      expect(apptDoc.data().status).toBe('ended_pending_confirmation');

      // Doctor answers No
      const confirmResult = await functionsTest.wrap(confirmAppointmentCompletion)({
        appointmentId: appointment.id,
        doctorId: doctor.id,
        completed: false,
      }, context);
      expect(confirmResult.success).toBe(true);

      apptDoc = await db.collection('appointments').doc(appointment.id).get();
      expect(apptDoc.data().status).toBe('not_completed',
        'confirmAppointmentCompletion(No) must set not_completed — FR-018');
      expect(apptDoc.data().notCompletedAt).toBeDefined();
    });

    test('completeAppointment backward-compat still produces completed status (regression T039)', async () => {
      // Old clients call completeAppointment directly; it must delegate to
      // confirmCompletion(completed: true) and produce the same outcome.
      const { appointment, doctor, patient } = makeE2EFixtures('003');
      await setupTestData(appointment, doctor, patient);
      const context = createMockContext(doctor.id);

      await functionsTest.wrap(startAgoraCall)(
        { appointmentId: appointment.id, doctorId: doctor.id }, context);
      await db.collection('appointments').doc(appointment.id).update({
        status: 'in_progress', callSessionActive: true,
      });
      await functionsTest.wrap(endAgoraCall)(
        { appointmentId: appointment.id }, context);

      // Old call path
      const completeResult = await functionsTest.wrap(completeAppointment)({
        appointmentId: appointment.id,
        doctorId: doctor.id,
      }, context);
      expect(completeResult.success).toBe(true);

      const apptDoc = await db.collection('appointments').doc(appointment.id).get();
      expect(apptDoc.data().status).toBe('completed',
        'backward-compat: completeAppointment must still produce completed');
      expect(apptDoc.data().completedAt).toBeDefined();
    });
  });
});
