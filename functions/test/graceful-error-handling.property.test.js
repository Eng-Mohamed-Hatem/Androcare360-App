/**
 * Property-Based Test: Graceful VoIP Notification Failure Handling
 * 
 * **Property 6: Graceful VoIP Notification Failure Handling**
 * **Validates: Requirements 4.1, 4.2, 4.3, 4.4**
 * 
 * For any VoIP notification failure (missing FCM token or send failure), verify graceful handling:
 * - Function returns success to caller
 * - Error is logged to call_logs with appropriate errorCode
 * - Function does NOT throw exception
 * - Call initiation succeeds despite notification failure
 * 
 * This property test uses fast-check to generate 100 random test cases covering:
 * - Missing FCM tokens
 * - Invalid FCM tokens (send failures)
 * - Missing patient documents
 * - Various error scenarios
 * 
 * The test verifies that the startAgoraCall function handles all notification
 * failures gracefully and always returns success to the doctor, allowing the
 * call to proceed even if the patient cannot be notified.
 */

const { admin, db, createMockContext, functionsTest } = require('./setup');
const fc = require('fast-check');

// Import Cloud Functions
const { startAgoraCall } = require('../index');

// Increase timeout for property-based tests
jest.setTimeout(180000); // 3 minutes

describe('Property 6: Graceful VoIP Notification Failure Handling', () => {
  // No setup needed - setup.js handles Firebase initialization

  /**
   * Property Test: Graceful handling of FCM token missing
   * 
   * For any valid appointment where the patient has no FCM token,
   * the startAgoraCall function should:
   * 1. Return success to the doctor
   * 2. Log error with code 'fcm_token_missing'
   * 3. NOT throw an exception
   */
  it('should handle missing FCM token gracefully (100 iterations)', async () => {
    await fc.assert(
      fc.asyncProperty(
        // Generate random test data
        fc.record({
          appointmentId: fc.uuid().map(s => `apt_missing_${s.replace(/-/g, '')}`),
          doctorId: fc.uuid().map(s => `doc_missing_${s.replace(/-/g, '')}`),
          patientId: fc.uuid().map(s => `pat_missing_${s.replace(/-/g, '')}`),
          doctorName: fc.string({ minLength: 5, maxLength: 50 }).filter(s => s.trim().length > 0 && !s.includes('/')),
          patientName: fc.string({ minLength: 5, maxLength: 50 }).filter(s => s.trim().length > 0 && !s.includes('/')),
        }),
        async (testData) => {
          // Arrange: Create appointment without patient FCM token
          await db.collection('appointments').doc(testData.appointmentId).set({
            id: testData.appointmentId,
            doctorId: testData.doctorId,
            patientId: testData.patientId,
            doctorName: testData.doctorName,
            patientName: testData.patientName,
            status: 'confirmed',
            scheduledAt: admin.firestore.Timestamp.now(),
          });

          // Create patient document WITHOUT FCM token
          await db.collection('users').doc(testData.patientId).set({
            id: testData.patientId,
            fullName: testData.patientName,
            email: `${testData.patientId}@test.com`,
            userType: 'patient',
            // fcmToken is intentionally missing
          });

          // Create doctor document
          await db.collection('users').doc(testData.doctorId).set({
            id: testData.doctorId,
            fullName: testData.doctorName,
            email: `${testData.doctorId}@test.com`,
            userType: 'doctor',
          });

          try {
            // Act: Call startAgoraCall using functionsTest.wrap
            const context = createMockContext(testData.doctorId);
            const result = await functionsTest.wrap(startAgoraCall)({
              appointmentId: testData.appointmentId,
              doctorId: testData.doctorId,
            }, context);

            // Assert: Function returns success
            expect(result).toBeDefined();
            expect(result.success).toBe(true);
            expect(result.agoraChannelName).toBeDefined();
            expect(result.agoraToken).toBeDefined();
            expect(result.agoraUid).toBeDefined();

            // Assert: Error was logged with correct code
            const errorLogs = await db.collection('call_logs')
              .where('appointmentId', '==', testData.appointmentId)
              .where('errorCode', '==', 'fcm_token_missing')
              .get();

            expect(errorLogs.empty).toBe(false);
            const errorLog = errorLogs.docs[0].data();
            expect(errorLog.eventType).toBe('call_error');
            expect(errorLog.userId).toBe(testData.patientId);
            expect(errorLog.errorMessage).toContain('[DB: elajtech]');
            expect(errorLog.metadata.databaseId).toBe('elajtech');

            // Cleanup
            await db.collection('appointments').doc(testData.appointmentId).delete();
            await db.collection('users').doc(testData.patientId).delete();
            await db.collection('users').doc(testData.doctorId).delete();
            for (const doc of errorLogs.docs) {
              await doc.ref.delete();
            }
            
            // Clean up call_logs for this appointment
            const allLogs = await db.collection('call_logs')
              .where('appointmentId', '==', testData.appointmentId)
              .get();
            for (const doc of allLogs.docs) {
              await doc.ref.delete();
            }

          } catch (error) {
            // Cleanup on error
            await db.collection('appointments').doc(testData.appointmentId).delete().catch(() => {});
            await db.collection('users').doc(testData.patientId).delete().catch(() => {});
            await db.collection('users').doc(testData.doctorId).delete().catch(() => {});
            
            // Property violation: Function should NOT throw
            throw new Error(`Property violation: Function threw exception for missing FCM token: ${error.message}`);
          }
        }
      ),
      { numRuns: 100 } // Run 100 iterations
    );
  }, 120000); // 2 minute timeout for 100 iterations

  /**
   * Property Test: Graceful handling of FCM send failure
   * 
   * For any valid appointment where the patient has an invalid FCM token,
   * the startAgoraCall function should:
   * 1. Return success to the doctor
   * 2. Log error with code 'voip_notification_failed'
   * 3. NOT throw an exception
   */
  it('should handle FCM send failure gracefully (100 iterations)', async () => {
    await fc.assert(
      fc.asyncProperty(
        // Generate random test data
        fc.record({
          appointmentId: fc.uuid().map(s => `apt_fail_${s.replace(/-/g, '')}`),
          doctorId: fc.uuid().map(s => `doc_fail_${s.replace(/-/g, '')}`),
          patientId: fc.uuid().map(s => `pat_fail_${s.replace(/-/g, '')}`),
          doctorName: fc.string({ minLength: 5, maxLength: 50 }).filter(s => s.trim().length > 0 && !s.includes('/')),
          patientName: fc.string({ minLength: 5, maxLength: 50 }).filter(s => s.trim().length > 0 && !s.includes('/')),
          invalidToken: fc.uuid().map(s => s.replace(/-/g, '')),
        }),
        async (testData) => {
          // Arrange: Create appointment with patient having invalid FCM token
          await db.collection('appointments').doc(testData.appointmentId).set({
            id: testData.appointmentId,
            doctorId: testData.doctorId,
            patientId: testData.patientId,
            doctorName: testData.doctorName,
            patientName: testData.patientName,
            status: 'confirmed',
            scheduledAt: admin.firestore.Timestamp.now(),
          });

          // Create patient document WITH invalid FCM token
          await db.collection('users').doc(testData.patientId).set({
            id: testData.patientId,
            fullName: testData.patientName,
            email: `${testData.patientId}@test.com`,
            userType: 'patient',
            fcmToken: testData.invalidToken, // Invalid token will cause send to fail
          });

          // Create doctor document
          await db.collection('users').doc(testData.doctorId).set({
            id: testData.doctorId,
            fullName: testData.doctorName,
            email: `${testData.doctorId}@test.com`,
            userType: 'doctor',
          });

          try {
            // Act: Call startAgoraCall using functionsTest.wrap
            const context = createMockContext(testData.doctorId);
            const result = await functionsTest.wrap(startAgoraCall)({
              appointmentId: testData.appointmentId,
              doctorId: testData.doctorId,
            }, context);

            // Assert: Function returns success
            expect(result).toBeDefined();
            expect(result.success).toBe(true);
            expect(result.agoraChannelName).toBeDefined();
            expect(result.agoraToken).toBeDefined();
            expect(result.agoraUid).toBeDefined();

            // Assert: Error was logged with correct code
            const errorLogs = await db.collection('call_logs')
              .where('appointmentId', '==', testData.appointmentId)
              .where('errorCode', '==', 'voip_notification_failed')
              .get();

            expect(errorLogs.empty).toBe(false);
            const errorLog = errorLogs.docs[0].data();
            expect(errorLog.eventType).toBe('call_error');
            expect(errorLog.userId).toBe(testData.patientId);
            expect(errorLog.errorMessage).toContain('[DB: elajtech]');
            expect(errorLog.metadata.databaseId).toBe('elajtech');

            // Cleanup
            await db.collection('appointments').doc(testData.appointmentId).delete();
            await db.collection('users').doc(testData.patientId).delete();
            await db.collection('users').doc(testData.doctorId).delete();
            for (const doc of errorLogs.docs) {
              await doc.ref.delete();
            }
            
            // Clean up call_logs for this appointment
            const allLogs = await db.collection('call_logs')
              .where('appointmentId', '==', testData.appointmentId)
              .get();
            for (const doc of allLogs.docs) {
              await doc.ref.delete();
            }

          } catch (error) {
            // Cleanup on error
            await db.collection('appointments').doc(testData.appointmentId).delete().catch(() => {});
            await db.collection('users').doc(testData.patientId).delete().catch(() => {});
            await db.collection('users').doc(testData.doctorId).delete().catch(() => {});
            
            // Property violation: Function should NOT throw
            throw new Error(`Property violation: Function threw exception for FCM send failure: ${error.message}`);
          }
        }
      ),
      { numRuns: 100 } // Run 100 iterations
    );
  }, 120000); // 2 minute timeout for 100 iterations

  /**
   * Property Test: Graceful handling of patient document not found
   * 
   * For any valid appointment where the patient document doesn't exist,
   * the startAgoraCall function should:
   * 1. Return success to the doctor
   * 2. Log error with code 'patient_not_found'
   * 3. NOT throw an exception
   */
  it('should handle patient not found gracefully (100 iterations)', async () => {
    await fc.assert(
      fc.asyncProperty(
        // Generate random test data
        fc.record({
          appointmentId: fc.uuid().map(s => `apt_notfound_${s.replace(/-/g, '')}`),
          doctorId: fc.uuid().map(s => `doc_notfound_${s.replace(/-/g, '')}`),
          patientId: fc.uuid().map(s => `pat_notfound_${s.replace(/-/g, '')}`),
          doctorName: fc.string({ minLength: 5, maxLength: 50 }).filter(s => s.trim().length > 0 && !s.includes('/')),
          patientName: fc.string({ minLength: 5, maxLength: 50 }).filter(s => s.trim().length > 0 && !s.includes('/')),
        }),
        async (testData) => {
          // Arrange: Create appointment but NO patient document
          await db.collection('appointments').doc(testData.appointmentId).set({
            id: testData.appointmentId,
            doctorId: testData.doctorId,
            patientId: testData.patientId,
            doctorName: testData.doctorName,
            patientName: testData.patientName,
            status: 'confirmed',
            scheduledAt: admin.firestore.Timestamp.now(),
          });

          // Create doctor document
          await db.collection('users').doc(testData.doctorId).set({
            id: testData.doctorId,
            fullName: testData.doctorName,
            email: `${testData.doctorId}@test.com`,
            userType: 'doctor',
          });

          // Patient document is intentionally NOT created

          try {
            // Act: Call startAgoraCall using functionsTest.wrap
            const context = createMockContext(testData.doctorId);
            const result = await functionsTest.wrap(startAgoraCall)({
              appointmentId: testData.appointmentId,
              doctorId: testData.doctorId,
            }, context);

            // Assert: Function returns success
            expect(result).toBeDefined();
            expect(result.success).toBe(true);
            expect(result.agoraChannelName).toBeDefined();
            expect(result.agoraToken).toBeDefined();
            expect(result.agoraUid).toBeDefined();

            // Assert: Error was logged with correct code
            const errorLogs = await db.collection('call_logs')
              .where('appointmentId', '==', testData.appointmentId)
              .where('errorCode', '==', 'patient_not_found')
              .get();

            expect(errorLogs.empty).toBe(false);
            const errorLog = errorLogs.docs[0].data();
            expect(errorLog.eventType).toBe('call_error');
            expect(errorLog.userId).toBe(testData.patientId);
            expect(errorLog.errorMessage).toContain('[DB: elajtech]');
            expect(errorLog.metadata.databaseId).toBe('elajtech');

            // Cleanup
            await db.collection('appointments').doc(testData.appointmentId).delete();
            await db.collection('users').doc(testData.doctorId).delete();
            for (const doc of errorLogs.docs) {
              await doc.ref.delete();
            }
            
            // Clean up call_logs for this appointment
            const allLogs = await db.collection('call_logs')
              .where('appointmentId', '==', testData.appointmentId)
              .get();
            for (const doc of allLogs.docs) {
              await doc.ref.delete();
            }

          } catch (error) {
            // Cleanup on error
            await db.collection('appointments').doc(testData.appointmentId).delete().catch(() => {});
            await db.collection('users').doc(testData.doctorId).delete().catch(() => {});
            
            // Property violation: Function should NOT throw
            throw new Error(`Property violation: Function threw exception for patient not found: ${error.message}`);
          }
        }
      ),
      { numRuns: 100 } // Run 100 iterations
    );
  }, 120000); // 2 minute timeout for 100 iterations
});
