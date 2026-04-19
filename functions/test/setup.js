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
const net = require('net');
const test = require('firebase-functions-test');

const PROJECT_ID = 'elajtech-test';
const DATABASE_ID = 'elajtech';
const FIRESTORE_EMULATOR_HOST = 'localhost:8080';
const AUTH_EMULATOR_HOST = 'localhost:9099';

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
    projectId: PROJECT_ID,
    databaseId: DATABASE_ID,
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
  host: FIRESTORE_EMULATOR_HOST,
  ssl: false,
  databaseId: DATABASE_ID, // ✅ CRITICAL: Explicit database ID
});

// ============================================================================
// AUTH EMULATOR CONFIGURATION
// ============================================================================

/**
 * Configure Firebase Auth to use local emulator
 */
process.env.FIREBASE_AUTH_EMULATOR_HOST = AUTH_EMULATOR_HOST;

// ============================================================================
// ENVIRONMENT VARIABLES
// ============================================================================

/**
 * Set environment variables for emulator mode
 */
process.env.FIRESTORE_EMULATOR_HOST = FIRESTORE_EMULATOR_HOST;
process.env.FUNCTIONS_EMULATOR = 'true';
process.env.GCLOUD_PROJECT = PROJECT_ID;

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
  projectId: PROJECT_ID,
  databaseId: DATABASE_ID,
}, './service-account-key.json'); // Optional: path to service account key

let emulatorSetupComplete = false;

// ============================================================================
// TEST UTILITIES
// ============================================================================

jest.setTimeout(30000);

function isPortOpen(host, port, timeoutMs = 1000) {
  return new Promise((resolve) => {
    const socket = new net.Socket();
    let settled = false;

    const finish = (result) => {
      if (settled) {
        return;
      }
      settled = true;
      socket.destroy();
      resolve(result);
    };

    socket.setTimeout(timeoutMs);
    socket.once('connect', () => finish(true));
    socket.once('timeout', () => finish(false));
    socket.once('error', () => finish(false));
    socket.connect(port, host);
  });
}

async function ensureEmulatorsAvailable() {
  const [firestoreReady, authReady] = await Promise.all([
    isPortOpen('127.0.0.1', 8080),
    isPortOpen('127.0.0.1', 9099),
  ]);

  if (!firestoreReady || !authReady) {
    const missing = [];
    if (!firestoreReady) {
      missing.push('Firestore emulator on localhost:8080');
    }
    if (!authReady) {
      missing.push('Auth emulator on localhost:9099');
    }

    throw new Error(
      `Firebase emulators are not running: ${missing.join(', ')}. ` +
      'Start them before running `npm run test:emulator`.'
    );
  }
}

async function flushFirestoreEmulator() {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 10000);

  try {
    const response = await fetch(
      `http://${FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/${PROJECT_ID}/databases/${DATABASE_ID}/documents`,
      {
        method: 'DELETE',
        signal: controller.signal,
      }
    );

    if (!response.ok) {
      throw new Error(`Flush failed with status ${response.status}`);
    }
  } finally {
    clearTimeout(timeout);
  }
}

/**
 * Clear all data from Firestore emulator
 * 
 * This function removes all documents from the test collections
 * to ensure a clean state between tests.
 * 
 * @returns {Promise<void>}
 */
async function clearFirestoreData() {
  try {
    await flushFirestoreEmulator();
    return;
  } catch (error) {
    throw new Error(
      'Failed to clear Firestore emulator state. ' +
      `Expected reachable emulator at ${FIRESTORE_EMULATOR_HOST} for database ${DATABASE_ID}. ` +
      `Original error: ${error.message}`
    );
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
  console.log(`📊 Firestore Emulator: ${FIRESTORE_EMULATOR_HOST}`);
  console.log(`🔐 Auth Emulator: ${AUTH_EMULATOR_HOST}`);
  console.log(`💾 Database ID: ${DATABASE_ID}`);

  await ensureEmulatorsAvailable();
  
  // Clear any existing data
  await clearFirestoreData();
  emulatorSetupComplete = true;
  
  console.log('✅ Test environment ready');
});

/**
 * Cleanup after each test
 * Ensures tests don't interfere with each other
 */
afterEach(async () => {
  if (!emulatorSetupComplete) {
    return;
  }
  await clearFirestoreData();
});

/**
 * Global cleanup after all tests
 */
afterAll(async () => {
  console.log('🧹 Cleaning up test environment...');
  
  // Cleanup firebase-functions-test
  functionsTest.cleanup();
  
  // Delete the Firebase app if still available
  if (emulatorSetupComplete && admin.apps.length > 0) {
    await admin.app().delete();
  }
  
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
