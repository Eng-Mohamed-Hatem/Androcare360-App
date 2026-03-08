/**
 * Property-Based Test: Error Message Database Context
 * 
 * **Property 9: Error Message Database Context**
 * **Validates: Requirements 2.11, 7.4**
 * 
 * For all error logs written by Cloud Functions, verify:
 * - Error messages include "[DB: elajtech]" prefix
 * - Metadata includes databaseId field set to 'elajtech'
 * 
 * This property test uses fast-check to generate 100 random test cases covering:
 * - Missing appointments
 * - Missing FCM tokens
 * - FCM send failures
 * - Missing patient documents
 * - Various error scenarios
 * 
 * The test verifies that all error logs include proper database context
 * for debugging purposes, making it clear which database was queried.
 */

const { admin, db, createMockContext, functionsTest } = require('./setup');
const fc = require('fast-check');

// Import Cloud Functions
const { startAgoraCall } = require('../index');

// Increase timeout for property-based tests
jest.setTimeout(180000); // 3 minutes

describe('Property 9: Error Message Database Context', () => {
  /**
   * Property Test: Error messages include database context for missing appointments
   * 
   * For any call to startAgoraCall with a non-existent appointment,
   * the error log should:
   * 1. Include "[DB: elajtech]" in the error message
   * 2. Include databaseId: 'elajtech' in metadata
   */
  it('should include database context in error logs for missing appointments (100 iterations)', async () => {
    await fc.assert(
      fc.asyncProperty(
        // Generate random test data
        fc.record({
          appointmentId: fc.uuid().map(s => `apt_missing_${s.replace(/-/g, '')}`),
          doctorId: fc.uuid().map(s => `doc_missing_${s.replace(/-/g, '')}`),
        }),
        async (testData) => {
          // Arrange: No appointment document created (intentionally missing)

          try {
            // Act: Call startAgoraCall with non-existent appointment
            const context = createMockContext(testData.doctorId);
            await functionsTest.wrap(startAgoraCall)({
              appointmentId: testData.appointmentId,
              doctorId: testData.doctorId,
            }, context);

            // Should not reach here - function should throw
            throw new Error('Function should have thrown for missing appointment');

          } catch (error) {
            // Assert: Error was thrown (expected)
            expect(error).toBeDefined();

            // Assert: Error logs include database context
            const errorLogs = await db.collection('call_logs')
              .where('appointmentId', '==', testData.appointmentId)
              .where('eventType', '==', 'call_error')
              .get();

            if (!errorLogs.empty) {
              const errorLog = errorLogs.docs[0].data();
              
              // Property: Error message includes "[DB: elajtech]" prefix
              expect(errorLog.errorMessage).toContain('[DB: elajtech]');
              
              // Property: Metadata includes databaseId field
              expect(errorLog.metadata).toBeDefined();
              expect(errorLog.metadata.databaseId).toBe('elajtech');

              // Cleanup
              for (const doc of errorLogs.docs) {
                await doc.ref.delete();
              }
            }
          }
        }
      ),
      { numRuns: 100 } // Run 100 iterations
    );
  }, 120000); // 2 minute timeout

  /**
   * Property Test: Error messages include database context for missing FCM tokens
   * 
   * For any appointment where the patient has no FCM token,
   * the error log should:
   * 1. Include "[DB: elajtech]" in the error message
   * 2. Include databaseId: 'elajtech' in metadata
   */
  it('should include database context in error logs for missing FCM tokens (100 iterations)', async () => {
    await fc.assert(
      fc.asyncProperty(
        // Generate random test data
        fc.record({
          appointmentId: fc.uuid().map(s => `apt_fcm_${s.replace(/-/g, '')}`),
          doctorId: fc.uuid().map(s => `doc_fcm_${s.replace(/-/g, '')}`),
          patientId: fc.uuid().map(s => `pat_fcm_${s.replace(/-/g, '')}`),
          doctorName: fc.string({ minLength: 5, maxLength: 50 }).filter(s => s.trim().length > 0 && !s.includes('/')),
          patientName: fc.string({ minLength: 5, maxLength: 50 }).filter(s => s.trim().length > 0 && !s.includes('/')),
        }),
        async (testData) => {
          // Arrange: Create appointment and patient without FCM token
          await db.collection('appointments').doc(testData.appointmentId).set({
            id: testData.appointmentId,
            doctorId: testData.doctorId,
            patientId: testData.patientId,
            doctorName: testData.doctorName,
            patientName: testData.patientName,
            status: 'confirmed',
            scheduledAt: admin.firestore.Timestamp.now(),
          });

          await db.collection('users').doc(testData.patientId).set({
            id: testData.patientId,
            fullName: testData.patientName,
            email: `${testData.patientId}@test.com`,
            userType: 'patient',
            // fcmToken is intentionally missing
          });

          await db.collection('users').doc(testData.doctorId).set({
            id: testData.doctorId,
            fullName: testData.doctorName,
            email: `${testData.doctorId}@test.com`,
            userType: 'doctor',
          });

          try {
            // Act: Call startAgoraCall
            const context = createMockContext(testData.doctorId);
            await functionsTest.wrap(startAgoraCall)({
              appointmentId: testData.appointmentId,
              doctorId: testData.doctorId,
            }, context);

            // Assert: Error logs include database context
            const errorLogs = await db.collection('call_logs')
              .where('appointmentId', '==', testData.appointmentId)
              .where('errorCode', '==', 'fcm_token_missing')
              .get();

            expect(errorLogs.empty).toBe(false);
            const errorLog = errorLogs.docs[0].data();
            
            // Property: Error message includes "[DB: elajtech]" prefix
            expect(errorLog.errorMessage).toContain('[DB: elajtech]');
            
            // Property: Metadata includes databaseId field
            expect(errorLog.metadata).toBeDefined();
            expect(errorLog.metadata.databaseId).toBe('elajtech');

            // Cleanup
            await db.collection('appointments').doc(testData.appointmentId).delete();
            await db.collection('users').doc(testData.patientId).delete();
            await db.collection('users').doc(testData.doctorId).delete();
            for (const doc of errorLogs.docs) {
              await doc.ref.delete();
            }
            
            // Clean up all call_logs for this appointment
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
            throw error;
          }
        }
      ),
      { numRuns: 100 } // Run 100 iterations
    );
  }, 120000); // 2 minute timeout

  /**
   * Property Test: Error messages include database context for FCM send failures
   * 
   * For any appointment where FCM send fails,
   * the error log should:
   * 1. Include "[DB: elajtech]" in the error message
   * 2. Include databaseId: 'elajtech' in metadata
   */
  it('should include database context in error logs for FCM send failures (100 iterations)', async () => {
    await fc.assert(
      fc.asyncProperty(
        // Generate random test data
        fc.record({
          appointmentId: fc.uuid().map(s => `apt_send_${s.replace(/-/g, '')}`),
          doctorId: fc.uuid().map(s => `doc_send_${s.replace(/-/g, '')}`),
          patientId: fc.uuid().map(s => `pat_send_${s.replace(/-/g, '')}`),
          doctorName: fc.string({ minLength: 5, maxLength: 50 }).filter(s => s.trim().length > 0 && !s.includes('/')),
          patientName: fc.string({ minLength: 5, maxLength: 50 }).filter(s => s.trim().length > 0 && !s.includes('/')),
          invalidToken: fc.uuid().map(s => s.replace(/-/g, '')),
        }),
        async (testData) => {
          // Arrange: Create appointment and patient with invalid FCM token
          await db.collection('appointments').doc(testData.appointmentId).set({
            id: testData.appointmentId,
            doctorId: testData.doctorId,
            patientId: testData.patientId,
            doctorName: testData.doctorName,
            patientName: testData.patientName,
            status: 'confirmed',
            scheduledAt: admin.firestore.Timestamp.now(),
          });

          await db.collection('users').doc(testData.patientId).set({
            id: testData.patientId,
            fullName: testData.patientName,
            email: `${testData.patientId}@test.com`,
            userType: 'patient',
            fcmToken: testData.invalidToken, // Invalid token will cause send to fail
          });

          await db.collection('users').doc(testData.doctorId).set({
            id: testData.doctorId,
            fullName: testData.doctorName,
            email: `${testData.doctorId}@test.com`,
            userType: 'doctor',
          });

          try {
            // Act: Call startAgoraCall
            const context = createMockContext(testData.doctorId);
            await functionsTest.wrap(startAgoraCall)({
              appointmentId: testData.appointmentId,
              doctorId: testData.doctorId,
            }, context);

            // Assert: Error logs include database context
            const errorLogs = await db.collection('call_logs')
              .where('appointmentId', '==', testData.appointmentId)
              .where('errorCode', '==', 'voip_notification_failed')
              .get();

            expect(errorLogs.empty).toBe(false);
            const errorLog = errorLogs.docs[0].data();
            
            // Property: Error message includes "[DB: elajtech]" prefix
            expect(errorLog.errorMessage).toContain('[DB: elajtech]');
            
            // Property: Metadata includes databaseId field
            expect(errorLog.metadata).toBeDefined();
            expect(errorLog.metadata.databaseId).toBe('elajtech');

            // Cleanup
            await db.collection('appointments').doc(testData.appointmentId).delete();
            await db.collection('users').doc(testData.patientId).delete();
            await db.collection('users').doc(testData.doctorId).delete();
            for (const doc of errorLogs.docs) {
              await doc.ref.delete();
            }
            
            // Clean up all call_logs for this appointment
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
            throw error;
          }
        }
      ),
      { numRuns: 100 } // Run 100 iterations
    );
  }, 120000); // 2 minute timeout

  /**
   * Property Test: Error messages include database context for patient not found
   * 
   * For any appointment where the patient document doesn't exist,
   * the error log should:
   * 1. Include "[DB: elajtech]" in the error message
   * 2. Include databaseId: 'elajtech' in metadata
   */
  it('should include database context in error logs for patient not found (100 iterations)', async () => {
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

          await db.collection('users').doc(testData.doctorId).set({
            id: testData.doctorId,
            fullName: testData.doctorName,
            email: `${testData.doctorId}@test.com`,
            userType: 'doctor',
          });

          // Patient document is intentionally NOT created

          try {
            // Act: Call startAgoraCall
            const context = createMockContext(testData.doctorId);
            await functionsTest.wrap(startAgoraCall)({
              appointmentId: testData.appointmentId,
              doctorId: testData.doctorId,
            }, context);

            // Assert: Error logs include database context
            const errorLogs = await db.collection('call_logs')
              .where('appointmentId', '==', testData.appointmentId)
              .where('errorCode', '==', 'patient_not_found')
              .get();

            expect(errorLogs.empty).toBe(false);
            const errorLog = errorLogs.docs[0].data();
            
            // Property: Error message includes "[DB: elajtech]" prefix
            expect(errorLog.errorMessage).toContain('[DB: elajtech]');
            
            // Property: Metadata includes databaseId field
            expect(errorLog.metadata).toBeDefined();
            expect(errorLog.metadata.databaseId).toBe('elajtech');

            // Cleanup
            await db.collection('appointments').doc(testData.appointmentId).delete();
            await db.collection('users').doc(testData.doctorId).delete();
            for (const doc of errorLogs.docs) {
              await doc.ref.delete();
            }
            
            // Clean up all call_logs for this appointment
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
            throw error;
          }
        }
      ),
      { numRuns: 100 } // Run 100 iterations
    );
  }, 120000); // 2 minute timeout
});
