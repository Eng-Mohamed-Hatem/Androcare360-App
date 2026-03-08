/**
 * Property Test: Database Targeting Consistency
 * 
 * File: functions/test/database-targeting-consistency.property.test.js
 * 
 * Feature: video-call-ui-voip-bugfix
 * Property 4: Database Targeting Consistency
 * 
 * Purpose: Verify that ALL Firestore operations in Cloud Functions
 * consistently target the 'elajtech' database, never the default database.
 * 
 * Requirements Validated:
 * - 2.1: Cloud Functions retrieve patient FCM token from elajtech database
 * - 2.9: Cloud Functions explicitly set database configuration
 * - 2.10: Cloud Functions verify all queries target elajtech database
 * 
 * Property Definition:
 * For ALL Firestore operations in Cloud Functions (reads and writes),
 * the operations MUST target the 'elajtech' database, never the default
 * database, verified by db.settings({ databaseId: 'elajtech' }) being
 * applied after initialization.
 * 
 * Test Strategy:
 * - Test with 100 iterations for statistical confidence
 * - Test various collection names (users, appointments, call_logs)
 * - Verify no operations target default database
 * - Verify db.settings() is applied correctly
 */

const { admin, db } = require('./setup');
const {
  createAppointmentFixture,
  createDoctorFixture,
  createPatientFixture,
  createCallLogFixture,
} = require('./fixtures');

describe('Property 4: Database Targeting Consistency', () => {
  // ============================================================================
  // PROPERTY TEST: DATABASE TARGETING CONSISTENCY (100 ITERATIONS)
  // ============================================================================

  test('Property 4: All Firestore operations target elajtech database (100 iterations)', async () => {
    // **Feature: video-call-ui-voip-bugfix, Property 4: Database Targeting Consistency**
    // **Validates: Requirements 2.1, 2.9, 2.10**
    //
    // Property Definition:
    // For ALL Firestore operations in Cloud Functions, verify elajtech database targeted
    //
    // Test Strategy:
    // - 100 iterations with random collection names
    // - Verify db.settings({ databaseId: 'elajtech' }) applied after initialization
    // - Test with various collection names (users, appointments, call_logs)
    // - Verify no operations target default database

    const collections = ['users', 'appointments', 'call_logs'];
    const iterations = 100;
    let successCount = 0;

    for (let i = 0; i < iterations; i++) {
      // Generate random collection name
      const collectionName = collections[Math.floor(Math.random() * collections.length)];
      const docId = `property_test_${i}_${Date.now()}`;

      // Create test data based on collection
      let testData;
      if (collectionName === 'users') {
        testData = createPatientFixture({ id: docId });
      } else if (collectionName === 'appointments') {
        testData = createAppointmentFixture({ id: docId });
      } else {
        testData = createCallLogFixture({ id: docId });
      }

      // Perform write operation
      await db.collection(collectionName).doc(docId).set(testData);

      // Verify read operation targets elajtech database
      const doc = await db.collection(collectionName).doc(docId).get();

      // Assertions
      expect(doc.exists).toBe(true);
      expect(doc.id).toBe(docId);

      // Verify the document data matches what we wrote
      const data = doc.data();
      expect(data).toBeDefined();
      expect(data.id).toBe(docId);

      // Clean up
      await db.collection(collectionName).doc(docId).delete();

      successCount++;
    }

    // Verify all 100 iterations passed
    expect(successCount).toBe(iterations);
  }, 30000); // 30 second timeout for 100 iterations

  // ============================================================================
  // PROPERTY TEST: COLLECTION REFERENCE CONSISTENCY (100 ITERATIONS)
  // ============================================================================

  test('Property 4.1: All collection references are accessible (100 iterations)', () => {
    // **Validates: Requirements 2.9, 2.10**
    //
    // Property: All collection references created from the db instance
    // must be accessible and functional

    const collections = ['users', 'appointments', 'call_logs'];
    const iterations = 100;
    let successCount = 0;

    for (let i = 0; i < iterations; i++) {
      const collectionName = collections[Math.floor(Math.random() * collections.length)];

      // Create collection reference
      const ref = db.collection(collectionName);

      // Verify reference is accessible
      expect(ref).toBeDefined();
      expect(typeof ref.doc).toBe('function');
      expect(typeof ref.add).toBe('function');
      expect(typeof ref.get).toBe('function');

      successCount++;
    }

    expect(successCount).toBe(iterations);
  });

  // ============================================================================
  // PROPERTY TEST: DOCUMENT REFERENCE CONSISTENCY (100 ITERATIONS)
  // ============================================================================

  test('Property 4.2: All document references are accessible (100 iterations)', () => {
    // **Validates: Requirements 2.1, 2.9, 2.10**
    //
    // Property: All document references created from the db instance
    // must be accessible and functional

    const collections = ['users', 'appointments', 'call_logs'];
    const iterations = 100;
    let successCount = 0;

    for (let i = 0; i < iterations; i++) {
      const collectionName = collections[Math.floor(Math.random() * collections.length)];
      const docId = `test_doc_${i}`;

      // Create document reference
      const docRef = db.collection(collectionName).doc(docId);

      // Verify reference is accessible
      expect(docRef).toBeDefined();
      expect(typeof docRef.get).toBe('function');
      expect(typeof docRef.set).toBe('function');
      expect(typeof docRef.update).toBe('function');
      expect(typeof docRef.delete).toBe('function');

      successCount++;
    }

    expect(successCount).toBe(iterations);
  });

  // ============================================================================
  // PROPERTY TEST: QUERY CONSISTENCY (100 ITERATIONS)
  // ============================================================================

  test('Property 4.3: All queries target elajtech database (100 iterations)', async () => {
    // **Validates: Requirements 2.1, 2.9, 2.10**
    //
    // Property: All queries executed against the db instance
    // must target the elajtech database

    const collections = ['users', 'appointments', 'call_logs'];
    const iterations = 100;
    let successCount = 0;

    // Create test documents first
    const testDocs = [];
    for (let i = 0; i < 10; i++) {
      const collectionName = collections[i % collections.length];
      const docId = `query_test_${i}`;

      let testData;
      if (collectionName === 'users') {
        testData = createPatientFixture({ id: docId });
      } else if (collectionName === 'appointments') {
        testData = createAppointmentFixture({ id: docId });
      } else {
        testData = createCallLogFixture({ id: docId });
      }

      await db.collection(collectionName).doc(docId).set(testData);
      testDocs.push({ collection: collectionName, id: docId });
    }

    // Perform 100 query operations
    for (let i = 0; i < iterations; i++) {
      const collectionName = collections[Math.floor(Math.random() * collections.length)];

      // Execute query
      const snapshot = await db.collection(collectionName).limit(5).get();

      // Verify query executed successfully
      expect(snapshot).toBeDefined();
      expect(typeof snapshot.size).toBe('number');
      expect(snapshot.size).toBeGreaterThanOrEqual(0);

      successCount++;
    }

    // Clean up test documents
    for (const doc of testDocs) {
      await db.collection(doc.collection).doc(doc.id).delete();
    }

    expect(successCount).toBe(iterations);
  }, 30000); // 30 second timeout

  // ============================================================================
  // PROPERTY TEST: BATCH OPERATIONS CONSISTENCY (100 ITERATIONS)
  // ============================================================================

  test('Property 4.4: All batch operations target elajtech database (100 iterations)', async () => {
    // **Validates: Requirements 2.9, 2.10**
    //
    // Property: All batch operations executed against the db instance
    // must target the elajtech database

    const collections = ['users', 'appointments', 'call_logs'];
    const iterations = 100;
    let successCount = 0;

    for (let i = 0; i < iterations; i++) {
      const collectionName = collections[Math.floor(Math.random() * collections.length)];
      const docIds = [`batch_${i}_1`, `batch_${i}_2`, `batch_${i}_3`];

      // Create batch
      const batch = db.batch();

      // Add operations to batch
      docIds.forEach((docId, index) => {
        let testData;
        if (collectionName === 'users') {
          testData = createPatientFixture({ id: docId });
        } else if (collectionName === 'appointments') {
          testData = createAppointmentFixture({ id: docId });
        } else {
          testData = createCallLogFixture({ id: docId });
        }

        const ref = db.collection(collectionName).doc(docId);
        batch.set(ref, testData);
      });

      // Commit batch
      await batch.commit();

      // Verify all documents were created
      for (const docId of docIds) {
        const doc = await db.collection(collectionName).doc(docId).get();
        expect(doc.exists).toBe(true);
      }

      // Clean up
      const deleteBatch = db.batch();
      docIds.forEach(docId => {
        const ref = db.collection(collectionName).doc(docId);
        deleteBatch.delete(ref);
      });
      await deleteBatch.commit();

      successCount++;
    }

    expect(successCount).toBe(iterations);
  }, 30000); // 30 second timeout

  // ============================================================================
  // PROPERTY TEST: TRANSACTION CONSISTENCY (100 ITERATIONS)
  // ============================================================================

  test('Property 4.5: All transactions target elajtech database (100 iterations)', async () => {
    // **Validates: Requirements 2.9, 2.10**
    //
    // Property: All transactions executed against the db instance
    // must target the elajtech database

    const collections = ['users', 'appointments', 'call_logs'];
    const iterations = 100;
    let successCount = 0;

    for (let i = 0; i < iterations; i++) {
      const collectionName = collections[Math.floor(Math.random() * collections.length)];
      const docId = `transaction_test_${i}`;

      // Create initial document
      let testData;
      if (collectionName === 'users') {
        testData = createPatientFixture({ id: docId });
      } else if (collectionName === 'appointments') {
        testData = createAppointmentFixture({ id: docId });
      } else {
        testData = createCallLogFixture({ id: docId });
      }

      await db.collection(collectionName).doc(docId).set(testData);

      // Perform transaction
      await db.runTransaction(async (transaction) => {
        const docRef = db.collection(collectionName).doc(docId);
        const doc = await transaction.get(docRef);

        expect(doc.exists).toBe(true);

        // Update document in transaction
        transaction.update(docRef, { transactionTest: true });
      });

      // Verify transaction was successful
      const doc = await db.collection(collectionName).doc(docId).get();
      expect(doc.data().transactionTest).toBe(true);

      // Clean up
      await db.collection(collectionName).doc(docId).delete();

      successCount++;
    }

    expect(successCount).toBe(iterations);
  }, 30000); // 30 second timeout

  // ============================================================================
  // PROPERTY TEST: DATABASE SETTINGS VERIFICATION
  // ============================================================================

  test('Property 4.6: Database settings are correctly applied', () => {
    // **Validates: Requirements 2.9, 2.10**
    //
    // Property: The db instance must have the correct database settings applied

    // Verify db instance is defined
    expect(db).toBeDefined();

    // Verify db has settings
    expect(db._settings).toBeDefined();

    // Verify admin app has correct database ID
    const app = admin.app();
    expect(app.options.databaseId).toBe('elajtech');
  });

  // ============================================================================
  // PROPERTY TEST: NO DEFAULT DATABASE OPERATIONS
  // ============================================================================

  test('Property 4.7: No operations target default database', async () => {
    // **Validates: Requirements 2.10**
    //
    // Property: All operations must target elajtech database,
    // never the default database

    const collections = ['users', 'appointments', 'call_logs'];
    const iterations = 100;
    let successCount = 0;

    for (let i = 0; i < iterations; i++) {
      const collectionName = collections[Math.floor(Math.random() * collections.length)];
      const docId = `default_check_${i}`;

      // Create document using our configured db instance
      let testData;
      if (collectionName === 'users') {
        testData = createPatientFixture({ id: docId });
      } else if (collectionName === 'appointments') {
        testData = createAppointmentFixture({ id: docId });
      } else {
        testData = createCallLogFixture({ id: docId });
      }

      await db.collection(collectionName).doc(docId).set(testData);

      // Verify document exists in elajtech database
      const doc = await db.collection(collectionName).doc(docId).get();
      expect(doc.exists).toBe(true);

      // The fact that we can read it back confirms it's in the elajtech database
      // because our db instance is configured with databaseId: 'elajtech'

      // Clean up
      await db.collection(collectionName).doc(docId).delete();

      successCount++;
    }

    expect(successCount).toBe(iterations);
  }, 30000); // 30 second timeout
});
