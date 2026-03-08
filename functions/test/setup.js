/**
 * Test Setup for AndroCare360 Cloud Functions
 * 
 * This file configures the Firebase Admin SDK and Firebase Emulators
 * for testing Cloud Functions with the 'elajtech' database.
 * 
 * CRITICAL: This setup ensures all Firestore operations target the
 * 'elajtech' database, matching the production configuration.
 */

const admin = require('firebase-admin');
const test = require('firebase-functions-test');

// ============================================================================
// FIREBASE ADMIN INITIALIZATION
// ============================================================================

/**
 * Initialize Firebase Admin SDK for testing
 * 
 * CRITICAL: Must specify databaseId: 'elajtech' to match production
 */
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: 'elajtech-test',
    databaseId: 'elajtech',
  });
}

// ============================================================================
// FIRESTORE EMULATOR CONFIGURATION
// ============================================================================

/**
 * Configure Firestore to use local emulator
 * 
 * CRITICAL: Explicit databaseId setting ensures all queries target
 * the 'elajtech' database, preventing the "Appointment Not Found" bug
 */
const db = admin.firestore();
db.settings({
  host: 'localhost:8080',
  ssl: false,
  databaseId: 'elajtech', // ✅ CRITICAL: Explicit database ID
});

// ============================================================================
// AUTH EMULATOR CONFIGURATION
// ============================================================================

/**
 * Configure Firebase Auth to use local emulator
 */
process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';

// ============================================================================
// ENVIRONMENT VARIABLES
// ============================================================================

/**
 * Set environment variables for emulator mode
 */
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
process.env.FUNCTIONS_EMULATOR = 'true';
process.env.GCLOUD_PROJECT = 'elajtech-test';

/**
 * Mock Agora credentials for testing
 * These are used by the token generation functions
 */
process.env.AGORA_APP_ID = 'test_app_id_12345';
process.env.AGORA_APP_CERTIFICATE = 'test_certificate_67890';

// ============================================================================
// FIREBASE FUNCTIONS TEST INITIALIZATION
// ============================================================================

/**
 * Initialize firebase-functions-test
 * This provides utilities for testing Cloud Functions
 */
const functionsTest = test({
  projectId: 'elajtech-test',
  databaseId: 'elajtech',
}, './service-account-key.json'); // Optional: path to service account key

// ============================================================================
// TEST UTILITIES
// ============================================================================

/**
 * Clear all data from Firestore emulator
 * 
 * This function removes all documents from the test collections
 * to ensure a clean state between tests.
 * 
 * @returns {Promise<void>}
 */
async function clearFirestoreData() {
  const collections = ['appointments', 'users', 'call_logs'];
  
  for (const collectionName of collections) {
    const snapshot = await db.collection(collectionName).get();
    
    if (snapshot.empty) {
      continue;
    }
    
    const batch = db.batch();
    snapshot.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();
  }
}

/**
 * Create a mock authentication context for testing
 * 
 * @param {string} uid - User ID
 * @param {object} claims - Additional claims (optional)
 * @returns {object} Mock context object
 */
function createMockContext(uid, claims = {}) {
  return {
    auth: {
      uid: uid,
      token: {
        ...claims,
      },
    },
  };
}

/**
 * Wait for a specified duration
 * Useful for testing async operations
 * 
 * @param {number} ms - Milliseconds to wait
 * @returns {Promise<void>}
 */
function wait(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// ============================================================================
// JEST LIFECYCLE HOOKS
// ============================================================================

/**
 * Global setup before all tests
 */
beforeAll(async () => {
  console.log('🔧 Setting up test environment...');
  console.log('📊 Firestore Emulator: localhost:8080');
  console.log('🔐 Auth Emulator: localhost:9099');
  console.log('💾 Database ID: elajtech');
  
  // Clear any existing data
  await clearFirestoreData();
  
  console.log('✅ Test environment ready');
});

/**
 * Cleanup after each test
 * Ensures tests don't interfere with each other
 */
afterEach(async () => {
  await clearFirestoreData();
});

/**
 * Global cleanup after all tests
 */
afterAll(async () => {
  console.log('🧹 Cleaning up test environment...');
  
  // Cleanup firebase-functions-test
  functionsTest.cleanup();
  
  // Delete the Firebase app
  await admin.app().delete();
  
  console.log('✅ Test environment cleaned up');
});

// ============================================================================
// EXPORTS
// ============================================================================

module.exports = {
  // Firebase Admin SDK
  admin,
  db,
  
  // Firebase Functions Test
  functionsTest,
  
  // Test Utilities
  clearFirestoreData,
  createMockContext,
  wait,
};
