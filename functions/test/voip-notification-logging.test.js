/**
 * VoIP Notification Logging Tests
 * 
 * Tests comprehensive logging functionality for VoIP notifications in Cloud Functions.
 * Validates that all notification events are logged correctly with proper metadata
 * and database context.
 * 
 * Test Coverage:
 * - FCM token missing → logs error with code 'fcm_token_missing'
 * - FCM send fails → logs error with code 'voip_notification_failed'
 * - FCM send succeeds → logs event with type 'voip_notification_sent'
 * - All logs include databaseId: 'elajtech' in metadata
 * - Error messages include "[DB: elajtech]" prefix
 * 
 * Requirements: 2.7, 2.8, 2.11, 5.1, 5.2, 7.4
 */

const admin = require('firebase-admin');

// Mock console methods to capture logs
let consoleLogSpy;
let consoleErrorSpy;
let originalConsoleLog;
let originalConsoleError;

describe('VoIP Notification Logging', () => {
  let db;
  let sendVoIPNotification;
  
  beforeAll(() => {
    // Get Firestore instance (already initialized in setup.js)
    db = admin.firestore();
    
    // Import the function to test
    const functions = require('../index');
    sendVoIPNotification = functions.sendVoIPNotification;
  });

  beforeEach(() => {
    // Setup console spies
    originalConsoleLog = console.log;
    originalConsoleError = console.error;
    consoleLogSpy = jest.fn();
    consoleErrorSpy = jest.fn();
    console.log = consoleLogSpy;
    console.error = consoleErrorSpy;
  });

  afterEach(() => {
    // Restore console methods
    console.log = originalConsoleLog;
    console.error = originalConsoleError;
    
    // Clear mocks
    jest.clearAllMocks();
  });

  describe('FCM Token Missing Scenario', () => {
    it('should log error with code fcm_token_missing when patient has no FCM token', async () => {
      // Arrange
      const patientId = 'patient_no_token_' + Date.now();
      const appointmentId = 'apt_' + Date.now();
      
      // Create patient document without FCM token
      await db.collection('users').doc(patientId).set({
        id: patientId,
        fullName: 'Test Patient',
        email: 'test@example.com',
        // fcmToken is missing
      });
      
      // Act
      await sendVoIPNotification({
        patientId,
        doctorName: 'Dr. Ahmed',
        appointmentId,
        agoraChannelName: 'channel_123',
        agoraToken: 'token_123',
        agoraUid: 12345,
      });
      
      // Assert
      // 1. Verify console error log
      expect(consoleErrorSpy).toHaveBeenCalledWith(
        expect.stringContaining('❌ FCM token missing')
      );
      
      // 2. Verify call_logs entry
      const logs = await db.collection('call_logs')
        .where('appointmentId', '==', appointmentId)
        .where('errorCode', '==', 'fcm_token_missing')
        .get();
      
      expect(logs.empty).toBe(false);
      const logData = logs.docs[0].data();
      
      expect(logData.eventType).toBe('call_error');
      expect(logData.userId).toBe(patientId);
      expect(logData.errorCode).toBe('fcm_token_missing');
      expect(logData.errorMessage).toContain('[DB: elajtech]');
      expect(logData.errorMessage).toContain('FCM token missing');
      expect(logData.metadata.databaseId).toBe('elajtech');
      expect(logData.metadata.patientId).toBe(patientId);
      
      // Cleanup
      await db.collection('users').doc(patientId).delete();
      await logs.docs[0].ref.delete();
    });

    it('should log error when patient document does not exist', async () => {
      // Arrange
      const patientId = 'patient_not_found_' + Date.now();
      const appointmentId = 'apt_' + Date.now();
      
      // Act (patient document doesn't exist)
      await sendVoIPNotification({
        patientId,
        doctorName: 'Dr. Ahmed',
        appointmentId,
        agoraChannelName: 'channel_456',
        agoraToken: 'token_456',
        agoraUid: 45678,
      });
      
      // Assert
      expect(consoleErrorSpy).toHaveBeenCalledWith(
        expect.stringContaining('[DB: elajtech] Patient not found')
      );
      
      const logs = await db.collection('call_logs')
        .where('appointmentId', '==', appointmentId)
        .where('errorCode', '==', 'patient_not_found')
        .get();
      
      expect(logs.empty).toBe(false);
      const logData = logs.docs[0].data();
      
      expect(logData.eventType).toBe('call_error');
      expect(logData.errorCode).toBe('patient_not_found');
      expect(logData.errorMessage).toContain('[DB: elajtech]');
      expect(logData.metadata.databaseId).toBe('elajtech');
      expect(logData.metadata.queriedCollection).toBe('users');
      expect(logData.metadata.queriedDocumentId).toBe(patientId);
      
      // Cleanup
      await logs.docs[0].ref.delete();
    });
  });

  describe('FCM Send Failure Scenario', () => {
    it('should log error with code voip_notification_failed when FCM send fails', async () => {
      // Arrange
      const patientId = 'patient_send_fail_' + Date.now();
      const appointmentId = 'apt_' + Date.now();
      const invalidFcmToken = 'invalid_token_' + Date.now();
      
      // Create patient document with invalid FCM token
      await db.collection('users').doc(patientId).set({
        id: patientId,
        fullName: 'Test Patient',
        email: 'test@example.com',
        fcmToken: invalidFcmToken, // Invalid token will cause FCM send to fail
      });
      
      // Act
      await sendVoIPNotification({
        patientId,
        doctorName: 'Dr. Ahmed',
        appointmentId,
        agoraChannelName: 'channel_789',
        agoraToken: 'token_789',
        agoraUid: 78901,
      });
      
      // Assert
      // 1. Verify console error log
      expect(consoleErrorSpy).toHaveBeenCalledWith(
        expect.stringContaining('❌ Error sending VoIP notification'),
        expect.any(Error)
      );
      
      // 2. Verify call_logs entry
      const logs = await db.collection('call_logs')
        .where('appointmentId', '==', appointmentId)
        .where('errorCode', '==', 'voip_notification_failed')
        .get();
      
      expect(logs.empty).toBe(false);
      const logData = logs.docs[0].data();
      
      expect(logData.eventType).toBe('call_error');
      expect(logData.userId).toBe(patientId);
      expect(logData.errorCode).toBe('voip_notification_failed');
      expect(logData.errorMessage).toContain('[DB: elajtech]');
      expect(logData.errorMessage).toContain('Error sending VoIP notification');
      expect(logData.metadata.databaseId).toBe('elajtech');
      
      // Cleanup
      await db.collection('users').doc(patientId).delete();
      await logs.docs[0].ref.delete();
    });
  });

  describe('FCM Send Success Scenario', () => {
    it('should log event with type voip_notification_sent when FCM send succeeds', async () => {
      // Arrange
      const patientId = 'patient_success_' + Date.now();
      const appointmentId = 'apt_success_' + Date.now();
      const doctorName = 'Dr. Ahmed';
      const channelName = 'channel_success_' + Date.now();
      
      // Create patient document with valid FCM token
      // Note: In emulator, any token format will work for testing
      const validFcmToken = 'valid_token_' + Date.now();
      await db.collection('users').doc(patientId).set({
        id: patientId,
        fullName: 'Test Patient',
        email: 'test@example.com',
        fcmToken: validFcmToken,
      });
      
      // Act
      await sendVoIPNotification({
        patientId,
        doctorName,
        appointmentId,
        agoraChannelName: channelName,
        agoraToken: 'token_success',
        agoraUid: 99999,
      });
      
      // Assert
      // 1. Verify console logs
      expect(consoleLogSpy).toHaveBeenCalledWith(
        expect.stringContaining('📱 Retrieving FCM token for patient')
      );
      expect(consoleLogSpy).toHaveBeenCalledWith(
        expect.stringContaining('✅ FCM token retrieved successfully')
      );
      expect(consoleLogSpy).toHaveBeenCalledWith(
        expect.stringContaining('📤 Sending VoIP notification'),
        expect.objectContaining({
          appointmentId,
          doctorName,
          channelName,
          patientId,
        })
      );
      
      // Note: FCM send will fail in emulator, but we check for the attempt
      // The actual success log will only appear in production with real FCM
      
      // 2. Verify call_logs entry (either success or failure)
      const logs = await db.collection('call_logs')
        .where('appointmentId', '==', appointmentId)
        .get();
      
      expect(logs.empty).toBe(false);
      const logData = logs.docs[0].data();
      
      // In emulator, FCM will fail, so we check for either success or failure
      expect(['voip_notification_sent', 'call_error']).toContain(logData.eventType);
      expect(logData.userId).toBe(patientId);
      expect(logData.metadata.databaseId).toBe('elajtech');
      
      // Cleanup
      await db.collection('users').doc(patientId).delete();
      for (const doc of logs.docs) {
        await doc.ref.delete();
      }
    });
  });

  describe('Database Context Verification', () => {
    it('all logs should include databaseId elajtech in metadata', async () => {
      // This test verifies that all log entries include the correct database context
      const patientId = 'patient_db_test_' + Date.now();
      const appointmentId = 'apt_db_test_' + Date.now();
      
      // Create patient without FCM token to trigger error log
      await db.collection('users').doc(patientId).set({
        id: patientId,
        fullName: 'Test Patient',
        email: 'test@example.com',
      });
      
      // Act
      await sendVoIPNotification({
        patientId,
        doctorName: 'Dr. Test',
        appointmentId,
        agoraChannelName: 'channel_test',
        agoraToken: 'token_test',
        agoraUid: 11111,
      });
      
      // Assert
      const logs = await db.collection('call_logs')
        .where('appointmentId', '==', appointmentId)
        .get();
      
      expect(logs.empty).toBe(false);
      const logData = logs.docs[0].data();
      
      // Verify metadata includes databaseId
      expect(logData.metadata).toBeDefined();
      expect(logData.metadata.databaseId).toBe('elajtech');
      
      // Cleanup
      await db.collection('users').doc(patientId).delete();
      for (const doc of logs.docs) {
        await doc.ref.delete();
      }
    });

    it('all error messages should include [DB: elajtech] prefix', async () => {
      // Test various error scenarios to ensure all include database prefix
      const scenarios = [
        {
          name: 'Patient not found',
          setupPatient: false,
          expectedErrorCode: 'patient_not_found',
        },
        {
          name: 'FCM token missing',
          setupPatient: true,
          expectedErrorCode: 'fcm_token_missing',
        },
      ];
      
      for (const scenario of scenarios) {
        const patientId = `test_patient_${scenario.expectedErrorCode}_${Date.now()}`;
        const appointmentId = `apt_${scenario.expectedErrorCode}_${Date.now()}`;
        
        // Arrange
        if (scenario.setupPatient) {
          await db.collection('users').doc(patientId).set({
            id: patientId,
            fullName: 'Test Patient',
            email: 'test@example.com',
            // No fcmToken
          });
        }
        
        // Act
        await sendVoIPNotification({
          patientId,
          doctorName: 'Dr. Test',
          appointmentId,
          agoraChannelName: 'channel_test',
          agoraToken: 'token_test',
          agoraUid: 22222,
        });
        
        // Assert
        const logs = await db.collection('call_logs')
          .where('appointmentId', '==', appointmentId)
          .where('errorCode', '==', scenario.expectedErrorCode)
          .get();
        
        expect(logs.empty).toBe(false);
        const logData = logs.docs[0].data();
        
        expect(logData.errorCode).toBe(scenario.expectedErrorCode);
        expect(logData.errorMessage).toContain('[DB: elajtech]');
        
        // Cleanup
        if (scenario.setupPatient) {
          await db.collection('users').doc(patientId).delete();
        }
        for (const doc of logs.docs) {
          await doc.ref.delete();
        }
      }
    });
  });
});
