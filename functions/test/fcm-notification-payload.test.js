/**
 * Property-Based Test: FCM Notification Payload Completeness
 * 
 * **Feature**: video-call-ui-voip-bugfix
 * **Property 3**: FCM Notification Payload Completeness
 * **Validates**: Requirements 2.2, 2.3
 * 
 * This test verifies that for any valid startAgoraCall request, the FCM
 * notification payload includes all required fields with correct values.
 * 
 * Test Configuration:
 * - 100 iterations using property-based testing
 * - Verifies: appointmentId, doctorName, agoraChannelName, agoraToken, agoraUid
 * - Verifies: type='incoming_call', android.priority='high', apns.headers['apns-priority']='10'
 * - Mocks admin.messaging().send() and verifies payload structure
 * 
 * Requirements Coverage:
 * - Requirement 2.2: FCM notification payload includes all required fields
 * - Requirement 2.3: High-priority settings for Android and iOS
 */

const { describe, test, expect, beforeEach, afterEach } = require('@jest/globals');
const fc = require('fast-check');
const admin = require('firebase-admin');
const { db, clearFirestoreData } = require('./setup');
const { sendVoIPNotification } = require('../index');

describe('Property 3: FCM Notification Payload Completeness', () => {
  let messagingSendSpy;
  let capturedPayloads = [];

  beforeEach(async () => {
    await clearFirestoreData();
    capturedPayloads = [];

    // Mock admin.messaging().send() to capture payloads
    messagingSendSpy = jest.spyOn(admin.messaging(), 'send').mockImplementation((message) => {
      capturedPayloads.push(message);
      return Promise.resolve('mock_message_id_' + Date.now());
    });
  });

  afterEach(() => {
    messagingSendSpy.mockRestore();
  });

  /**
   * Property Test: FCM notification payload includes all required fields
   * 
   * For any valid VoIP notification data, the FCM payload must include:
   * - All Agora fields (channelName, token, uid)
   * - Appointment and doctor information
   * - Correct notification type ('incoming_call')
   * - High-priority settings for both Android and iOS
   * - All Agora fields converted to strings
   */
  test('Property 3: FCM notification payload includes all required fields (100 iterations)', async () => {
    await fc.assert(
      fc.asyncProperty(
        // Generate random test data with valid Firestore document IDs
        fc.record({
          appointmentId: fc.uuid(),
          patientId: fc.uuid(),
          doctorName: fc.string({ minLength: 5, maxLength: 20 }),
          agoraChannelName: fc.uuid(),
          agoraToken: fc.uuid(),
          agoraUid: fc.integer({ min: 1, max: 999999 }),
          fcmToken: fc.uuid(),
        }),
        async (data) => {
          // Setup: Create patient document with FCM token
          await db.collection('users').doc(data.patientId).set({
            fcmToken: data.fcmToken,
            fcmTokenUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          // Clear captured payloads before test
          capturedPayloads = [];

          // Act: Send VoIP notification
          await sendVoIPNotification({
            patientId: data.patientId,
            doctorName: data.doctorName,
            appointmentId: data.appointmentId,
            agoraChannelName: data.agoraChannelName,
            agoraToken: data.agoraToken,
            agoraUid: data.agoraUid,
          });

          // Assert: Verify payload was captured
          expect(capturedPayloads.length).toBe(1);
          const payload = capturedPayloads[0];

          // Property 1: Payload includes FCM token
          expect(payload.token).toBe(data.fcmToken);

          // Property 2: Notification object exists with title and body
          expect(payload.notification).toBeDefined();
          expect(payload.notification.title).toContain(data.doctorName);
          expect(payload.notification.body).toBeDefined();

          // Property 3: Data object includes all required fields
          expect(payload.data).toBeDefined();
          expect(payload.data.type).toBe('incoming_call');
          expect(payload.data.appointmentId).toBe(data.appointmentId);
          expect(payload.data.doctorName).toBe(data.doctorName);
          expect(payload.data.patientId).toBe(data.patientId);
          expect(payload.data.agoraChannelName).toBe(data.agoraChannelName);
          expect(payload.data.agoraToken).toBe(data.agoraToken);

          // Property 4: Agora UID is converted to string
          expect(payload.data.agoraUid).toBe(String(data.agoraUid));
          expect(typeof payload.data.agoraUid).toBe('string');

          // Property 5: Android configuration with high priority
          expect(payload.android).toBeDefined();
          expect(payload.android.priority).toBe('high');
          expect(payload.android.notification).toBeDefined();
          expect(payload.android.notification.channelId).toBe('incoming_calls');
          expect(payload.android.notification.priority).toBe('max');
          expect(payload.android.notification.sound).toBe('default');

          // Property 6: APNS configuration with highest priority
          expect(payload.apns).toBeDefined();
          expect(payload.apns.headers).toBeDefined();
          expect(payload.apns.headers['apns-priority']).toBe('10');
          expect(payload.apns.payload).toBeDefined();
          expect(payload.apns.payload.aps).toBeDefined();
          expect(payload.apns.payload.aps['content-available']).toBe(1);
          expect(payload.apns.payload.aps.sound).toBe('default');
        }
      ),
      {
        numRuns: 100, // Run 100 iterations as specified
        verbose: true, // Show detailed output on failure
      }
    );
  }, 60000); // 60 second timeout for 100 iterations

  /**
   * Unit Test: Verify specific example payload structure
   * 
   * This test complements the property test by verifying a specific
   * example with known values.
   */
  test('Unit test: Specific example with known values', async () => {
    const testData = {
      appointmentId: 'apt_test_12345',
      patientId: 'patient_test_67890',
      doctorName: 'د. أحمد محمد',
      agoraChannelName: 'channel_apt_test_12345_1234567890',
      agoraToken: 'test_token_abc123def456',
      agoraUid: 12345,
      fcmToken: 'test_fcm_token_xyz789',
    };

    // Setup: Create patient document
    await db.collection('users').doc(testData.patientId).set({
      fcmToken: testData.fcmToken,
      fcmTokenUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    capturedPayloads = [];

    // Act: Send VoIP notification
    await sendVoIPNotification({
      patientId: testData.patientId,
      doctorName: testData.doctorName,
      appointmentId: testData.appointmentId,
      agoraChannelName: testData.agoraChannelName,
      agoraToken: testData.agoraToken,
      agoraUid: testData.agoraUid,
    });

    // Assert: Verify payload structure
    expect(capturedPayloads.length).toBe(1);
    const payload = capturedPayloads[0];

    expect(payload).toMatchObject({
      token: testData.fcmToken,
      notification: {
        title: expect.stringContaining(testData.doctorName),
        body: expect.any(String),
      },
      data: {
        type: 'incoming_call',
        appointmentId: testData.appointmentId,
        doctorName: testData.doctorName,
        patientId: testData.patientId,
        agoraChannelName: testData.agoraChannelName,
        agoraToken: testData.agoraToken,
        agoraUid: '12345', // Converted to string
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'incoming_calls',
          priority: 'max',
          sound: 'default',
          tag: testData.appointmentId,
        },
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
        payload: {
          aps: {
            'content-available': 1,
            sound: 'default',
          },
        },
      },
    });
  });

  /**
   * Edge Case Test: Missing FCM token
   * 
   * Verifies that the function handles missing FCM tokens gracefully
   * without throwing an exception.
   */
  test('Edge case: Missing FCM token does not throw exception', async () => {
    const testData = {
      appointmentId: 'apt_test_missing_token',
      patientId: 'patient_test_no_token',
      doctorName: 'د. محمد علي',
      agoraChannelName: 'channel_test',
      agoraToken: 'test_token',
      agoraUid: 54321,
    };

    // Setup: Create patient document WITHOUT FCM token
    await db.collection('users').doc(testData.patientId).set({
      fullName: 'Test Patient',
      // fcmToken is intentionally missing
    });

    capturedPayloads = [];

    // Act: Send VoIP notification (should not throw)
    await expect(
      sendVoIPNotification({
        patientId: testData.patientId,
        doctorName: testData.doctorName,
        appointmentId: testData.appointmentId,
        agoraChannelName: testData.agoraChannelName,
        agoraToken: testData.agoraToken,
        agoraUid: testData.agoraUid,
      })
    ).resolves.not.toThrow();

    // Assert: No payload should be sent
    expect(capturedPayloads.length).toBe(0);

    // Verify error was logged to call_logs
    const callLogs = await db.collection('call_logs')
      .where('appointmentId', '==', testData.appointmentId)
      .where('errorCode', '==', 'fcm_token_missing')
      .get();

    expect(callLogs.empty).toBe(false);
    expect(callLogs.docs[0].data().errorMessage).toContain('[DB: elajtech]');
  });

  /**
   * Edge Case Test: Patient document not found
   * 
   * Verifies that the function handles missing patient documents gracefully.
   */
  test('Edge case: Patient document not found does not throw exception', async () => {
    const testData = {
      appointmentId: 'apt_test_no_patient',
      patientId: 'patient_test_nonexistent',
      doctorName: 'د. سارة أحمد',
      agoraChannelName: 'channel_test',
      agoraToken: 'test_token',
      agoraUid: 99999,
    };

    // No patient document created

    capturedPayloads = [];

    // Act: Send VoIP notification (should not throw)
    await expect(
      sendVoIPNotification({
        patientId: testData.patientId,
        doctorName: testData.doctorName,
        appointmentId: testData.appointmentId,
        agoraChannelName: testData.agoraChannelName,
        agoraToken: testData.agoraToken,
        agoraUid: testData.agoraUid,
      })
    ).resolves.not.toThrow();

    // Assert: No payload should be sent
    expect(capturedPayloads.length).toBe(0);

    // Verify error was logged to call_logs
    const callLogs = await db.collection('call_logs')
      .where('appointmentId', '==', testData.appointmentId)
      .where('errorCode', '==', 'patient_not_found')
      .get();

    expect(callLogs.empty).toBe(false);
  });

  /**
   * Property Test: All Agora fields are strings in payload
   * 
   * Verifies that numeric Agora fields are properly converted to strings
   * for FCM data payload compatibility.
   */
  test('Property: All Agora fields are strings in FCM data payload', async () => {
    await fc.assert(
      fc.asyncProperty(
        fc.record({
          appointmentId: fc.uuid(),
          patientId: fc.uuid(),
          doctorName: fc.string({ minLength: 5 }),
          agoraChannelName: fc.uuid(),
          agoraToken: fc.uuid(),
          agoraUid: fc.integer({ min: 1, max: 999999 }), // Numeric input
          fcmToken: fc.uuid(),
        }),
        async (data) => {
          // Setup
          await db.collection('users').doc(data.patientId).set({
            fcmToken: data.fcmToken,
          });

          capturedPayloads = [];

          // Act
          await sendVoIPNotification({
            patientId: data.patientId,
            doctorName: data.doctorName,
            appointmentId: data.appointmentId,
            agoraChannelName: data.agoraChannelName,
            agoraToken: data.agoraToken,
            agoraUid: data.agoraUid,
          });

          // Assert: agoraUid must be a string
          const payload = capturedPayloads[0];
          expect(typeof payload.data.agoraUid).toBe('string');
          expect(payload.data.agoraUid).toBe(String(data.agoraUid));
        }
      ),
      { numRuns: 20 } // Reduced from 50 to 20 for faster execution
    );
  }, 30000); // 30 second timeout
});
