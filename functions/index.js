const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { RtcTokenBuilder, RtcRole } = require('agora-access-token');

// تهيئة Firebase Admin
// Initialize Firebase Admin only if not already initialized (for testing)
if (!admin.apps.length) {
  admin.initializeApp();  // ✅ Remove databaseId parameter
}

const db = admin.firestore();

// ============================================================================
// FIRESTORE INSTANCE TRACKING
// ============================================================================
// Task 1.8: Add Firestore instance tracking
// Purpose: Track Firestore instance creation and usage to diagnose potential
//          multiple instance issues that could cause database misconfiguration
// Reference: Doctor Start Call "Appointment Not Found" Recurrence Bugfix
// Investigation: Hypothesis 4 - Multiple Firestore Instances
// Date: 2026-02-19
// ============================================================================

/**
 * Unique identifier for this Firestore instance
 * Used to track instance creation and verify single instance usage
 * 
 * This ID is generated once at initialization and logged with each query
 * to ensure all operations use the same configured instance.
 */
const DB_INSTANCE_ID = Math.random().toString(36).substring(2, 15);

console.log('🔧 [INSTANCE] ============================================');
console.log('🔧 [INSTANCE] FIRESTORE INSTANCE TRACKING');
console.log('🔧 [INSTANCE] ============================================');
console.log('🔧 [INSTANCE] Firestore instance created');
console.log('🔧 [INSTANCE] Instance ID:', DB_INSTANCE_ID);
console.log('🔧 [INSTANCE] Instance creation timestamp:', new Date().toISOString());
console.log('🔧 [INSTANCE] Instance type:', typeof db);
console.log('🔧 [INSTANCE] Instance constructor:', db.constructor.name);
console.log('🔧 [INSTANCE] ============================================');

// ============================================================================
// VERSION TRACKING & DEPLOYMENT VERIFICATION
// ============================================================================
// These constants enable diagnostic tracking to verify deployed versions
// and confirm that critical fixes are active in production.
//
// Purpose:
// - Track which version of Cloud Functions is deployed
// - Verify database configuration fix is present
// - Enable version verification from Flutter app
// - Facilitate debugging of deployment-related issues
//
// Reference: Doctor Start Call "Appointment Not Found" Recurrence Bugfix
// Task: 1.1 Add version tracking to Cloud Functions
// Date: 2026-02-19
// ============================================================================

const FUNCTIONS_VERSION = '2.2.0-fix';
const DEPLOYED_AT = new Date().toISOString();
const DATABASE_CONFIG_FIX_PRESENT = true;

// Log version information on initialization
console.log('🚀 [INIT] ============================================');
console.log('🚀 [INIT] Cloud Functions Version:', FUNCTIONS_VERSION);
console.log('🚀 [INIT] Deployed At:', DEPLOYED_AT);
console.log('🚀 [INIT] Database Config Fix Present:', DATABASE_CONFIG_FIX_PRESENT);
console.log('🚀 [INIT] ============================================');

// ============================================================================
// UNCONDITIONAL DATABASE CONFIGURATION (FIX FOR HYPOTHESIS 5)
// ============================================================================
// Task 4.3: Unconditional database configuration
// Purpose: Fix "Appointment Not Found" errors by ensuring database configuration
//          is ALWAYS applied, regardless of initial state
// Reference: Doctor Start Call "Appointment Not Found" Recurrence Bugfix
// Root Cause: Conditional logic prevented configuration when db._settings existed
// Date: 2026-02-19
// ============================================================================

console.log('🔧 [DB CONFIG] ============================================');
console.log('🔧 [DB CONFIG] UNCONDITIONAL DATABASE CONFIGURATION');
console.log('🔧 [DB CONFIG] ============================================');

// ============================================================================
// STEP 1: LOG INITIAL STATE BEFORE CONFIGURATION
// ============================================================================
console.log('🔧 [DB CONFIG] STEP 1: Initial State Before Configuration');
console.log('🔧 [DB CONFIG] Initial db._settings exists:', !!db._settings);
console.log('🔧 [DB CONFIG] Initial db._settings value:', JSON.stringify(db._settings, null, 2));
console.log('🔧 [DB CONFIG] Initial databaseId:', db._settings?.databaseId || 'NOT_SET');

// ============================================================================
// STEP 2: APPLY UNCONDITIONAL DATABASE CONFIGURATION
// ============================================================================
// ✅ CRITICAL FIX: Remove conditional check - ALWAYS apply configuration
// Previous approach used conditional logic that failed when db._settings existed
// New approach: ALWAYS apply database configuration, no conditions
//
// Why unconditional?
// - Ensures configuration is applied regardless of initial state
// - Prevents edge cases where condition evaluates incorrectly
// - Makes behavior predictable and debuggable
// - Fixes root cause: conditional logic skipped configuration when
//   db._settings.databaseId existed with value "(default)"
//
// Safety: db.settings() can only be called once. If already configured,
// it will throw an error which we catch and log.
// ============================================================================

console.log('🔧 [DB CONFIG] STEP 2: Applying Unconditional Configuration');
console.log('🔧 [DB CONFIG] Calling db.settings({ databaseId: "elajtech" })...');

try {
  // ✅ UNCONDITIONAL: Apply configuration without any conditional checks
  db.settings({ databaseId: 'elajtech' });
  console.log('✅ [DB CONFIG] db.settings() call completed successfully');
  console.log('✅ [DB CONFIG] Configuration applied unconditionally');
} catch (configError) {
  // If settings already applied, this is expected in some environments
  console.log('⚠️ [DB CONFIG] Settings already applied (expected in some environments)');
  console.log('⚠️ [DB CONFIG] Error type:', configError.constructor.name);
  console.log('⚠️ [DB CONFIG] Error message:', configError.message);

  // This is not necessarily a failure - settings may have been applied earlier
  // We'll verify the final state in the next step
}

// ============================================================================
// STEP 3: LOG FINAL STATE AFTER CONFIGURATION
// ============================================================================
console.log('🔧 [DB CONFIG] STEP 3: Final State After Configuration');
console.log('🔧 [DB CONFIG] Final db._settings exists:', !!db._settings);
console.log('🔧 [DB CONFIG] Final db._settings value:', JSON.stringify(db._settings, null, 2));
console.log('🔧 [DB CONFIG] Final databaseId:', db._settings?.databaseId || 'NOT_SET');

// ============================================================================
// STEP 4: CRITICAL VALIDATION
// ============================================================================
console.log('🔧 [DB CONFIG] STEP 4: Critical Validation');

const finalDatabaseId = db._settings?.databaseId;
const isCorrectDatabase = finalDatabaseId === 'elajtech';

console.log('🔧 [DB CONFIG] Expected databaseId: "elajtech"');
console.log('🔧 [DB CONFIG] Actual databaseId:', finalDatabaseId || 'NOT_SET');
console.log('🔧 [DB CONFIG] Database ID matches expected:', isCorrectDatabase);

if (!isCorrectDatabase) {
  console.error('❌ [CRITICAL] ============================================');
  console.error('❌ [CRITICAL] DATABASE CONFIGURATION FAILED!');
  console.error('❌ [CRITICAL] ============================================');
  console.error('❌ [CRITICAL] Expected databaseId: "elajtech"');
  console.error('❌ [CRITICAL] Actual databaseId:', finalDatabaseId || 'NOT_SET');
  console.error('❌ [CRITICAL] ============================================');
  console.error('❌ [CRITICAL] IMPACT:');
  console.error('❌ [CRITICAL] - All Firestore queries will target WRONG database');
  console.error('❌ [CRITICAL] - "Appointment Not Found" errors will occur');
  console.error('❌ [CRITICAL] - Call logs will be written to wrong database');
  console.error('❌ [CRITICAL] - Patient FCM tokens will not be found');
  console.error('❌ [CRITICAL] ============================================');
  console.error('❌ [CRITICAL] POSSIBLE CAUSES:');
  console.error('❌ [CRITICAL] 1. db.settings() call failed');
  console.error('❌ [CRITICAL] 2. Settings were overridden after configuration');
  console.error('❌ [CRITICAL] 3. Firebase Admin SDK version issue');
  console.error('❌ [CRITICAL] 4. Invalid databaseId value');
  console.error('❌ [CRITICAL] ============================================');

  // ✅ CRITICAL: Throw error to prevent deployment with wrong configuration
  throw new Error(`Database configuration failed: expected 'elajtech', got '${finalDatabaseId || 'NOT_SET'}'`);
} else {
  console.log('✅ [DB CONFIG] ============================================');
  console.log('✅ [DB CONFIG] DATABASE CONFIGURATION SUCCESSFUL');
  console.log('✅ [DB CONFIG] ============================================');
  console.log('✅ [DB CONFIG] Database ID correctly set to: elajtech');
  console.log('✅ [DB CONFIG] All Firestore queries will target correct database');
  console.log('✅ [DB CONFIG] Configuration verification complete');
  console.log('✅ [DB CONFIG] ============================================');
}

console.log('🔧 [DB CONFIG] ============================================');
console.log('🔧 [DB CONFIG] UNCONDITIONAL CONFIGURATION COMPLETE');
console.log('🔧 [DB CONFIG] ============================================');
console.log('🔧 [DB CONFIG] DATABASE CONFIGURATION VERIFICATION COMPLETE');
console.log('🔧 [DB CONFIG] ============================================');

// ============================================================================
// DATABASE VERIFICATION HELPER FUNCTION
// ============================================================================
// Task 1.7: Create database verification helper function
// Purpose: Verify database configuration before each Firestore query
//          to ensure queries target the correct 'elajtech' database
// Reference: Doctor Start Call "Appointment Not Found" Recurrence Bugfix
// Date: 2026-02-19
// ============================================================================

/**
 * Verify Database Configuration Before Query
 * التحقق من تكوين قاعدة البيانات قبل الاستعلام
 * 
 * This function verifies that the Firestore instance is configured to use
 * the 'elajtech' database before executing any query. It logs the current
 * database configuration and returns a boolean indicating correctness.
 * 
 * تتحقق هذه الدالة من أن مثيل Firestore مُكوّن لاستخدام قاعدة بيانات
 * 'elajtech' قبل تنفيذ أي استعلام. تسجل التكوين الحالي وتُرجع قيمة منطقية
 * تشير إلى صحة التكوين.
 * 
 * Purpose:
 * - Prevent "Appointment Not Found" errors caused by wrong database targeting
 * - Provide diagnostic information for debugging database configuration issues
 * - Enable early detection of database misconfiguration
 * - Log database state before critical Firestore operations
 * 
 * Usage:
 * ```javascript
 * // Before any Firestore query
 * if (!verifyDatabaseConfig('startAgoraCall - appointment query')) {
 *   console.error('Database configuration incorrect - aborting query');
 *   throw new Error('Database misconfiguration detected');
 * }
 * 
 * // Proceed with query
 * const appointmentRef = db.collection('appointments').doc(appointmentId);
 * ```
 * 
 * @param {string} operationName - Name of the operation being performed (for logging)
 *                                 اسم العملية التي يتم تنفيذها (للتسجيل)
 * @returns {boolean} - true if database is correctly configured to 'elajtech',
 *                      false otherwise
 *                      صحيح إذا كانت قاعدة البيانات مُكوّنة بشكل صحيح لـ 'elajtech'،
 *                      خطأ خلاف ذلك
 * 
 * @example
 * // Example 1: Verify before appointment query
 * verifyDatabaseConfig('startAgoraCall - appointment query');
 * const appointment = await db.collection('appointments').doc(id).get();
 * 
 * @example
 * // Example 2: Verify before user query
 * verifyDatabaseConfig('sendVoIPNotification - patient query');
 * const patient = await db.collection('users').doc(patientId).get();
 * 
 * @example
 * // Example 3: Verify before call logs write
 * verifyDatabaseConfig('logCallEvent - call_logs write');
 * await db.collection('call_logs').add(logData);
 */
function verifyDatabaseConfig(operationName) {
  // Get current database configuration
  const currentDatabaseId = db._settings?.databaseId;
  const expectedDatabaseId = 'elajtech';
  const isCorrect = currentDatabaseId === expectedDatabaseId;

  // Log verification attempt with instance tracking
  console.log(`🔍 [DB VERIFY] ============================================`);
  console.log(`🔍 [DB VERIFY] Operation: ${operationName}`);
  console.log(`🔍 [DB VERIFY] Instance ID: ${DB_INSTANCE_ID}`);
  console.log(`🔍 [DB VERIFY] Current databaseId: ${currentDatabaseId || 'NOT_SET'}`);
  console.log(`🔍 [DB VERIFY] Expected databaseId: ${expectedDatabaseId}`);
  console.log(`🔍 [DB VERIFY] Configuration correct: ${isCorrect}`);

  // Log detailed state information
  console.log(`🔍 [DB VERIFY] db._settings exists: ${!!db._settings}`);
  console.log(`🔍 [DB VERIFY] databaseId type: ${typeof currentDatabaseId}`);
  console.log(`🔍 [DB VERIFY] databaseId is null: ${currentDatabaseId === null}`);
  console.log(`🔍 [DB VERIFY] databaseId is undefined: ${currentDatabaseId === undefined}`);
  console.log(`🔍 [DB VERIFY] databaseId is empty string: ${currentDatabaseId === ''}`);

  if (!isCorrect) {
    // Log error with detailed diagnostic information
    console.error(`❌ [DB VERIFY] ============================================`);
    console.error(`❌ [DB VERIFY] DATABASE CONFIGURATION ERROR`);
    console.error(`❌ [DB VERIFY] ============================================`);
    console.error(`❌ [DB VERIFY] Operation: ${operationName}`);
    console.error(`❌ [DB VERIFY] Instance ID: ${DB_INSTANCE_ID}`);
    console.error(`❌ [DB VERIFY] Expected: ${expectedDatabaseId}`);
    console.error(`❌ [DB VERIFY] Actual: ${currentDatabaseId || 'NOT_SET'}`);
    console.error(`❌ [DB VERIFY] ============================================`);
    console.error(`❌ [DB VERIFY] IMPACT:`);
    console.error(`❌ [DB VERIFY] - Query will target WRONG database`);
    console.error(`❌ [DB VERIFY] - May result in "Not Found" errors`);
    console.error(`❌ [DB VERIFY] - Data may be read from/written to wrong database`);
    console.error(`❌ [DB VERIFY] ============================================`);
    console.error(`❌ [DB VERIFY] RECOMMENDED ACTIONS:`);
    console.error(`❌ [DB VERIFY] 1. Check database configuration in initialization code`);
    console.error(`❌ [DB VERIFY] 2. Verify db.settings({ databaseId: 'elajtech' }) was called`);
    console.error(`❌ [DB VERIFY] 3. Check for multiple Firestore instances`);
    console.error(`❌ [DB VERIFY] 4. Review Cloud Functions deployment logs`);
    console.error(`❌ [DB VERIFY] ============================================`);
  } else {
    console.log(`✅ [DB VERIFY] Database configuration verified successfully`);
    console.log(`✅ [DB VERIFY] Using instance: ${DB_INSTANCE_ID}`);
  }

  console.log(`🔍 [DB VERIFY] ============================================`);

  return isCorrect;
}

/**
 * دالة توليد Agora Token
 * Generate Agora RTC token using modern environment variable configuration.
 * 
 * تُستخدم لإنشاء رمز مصادقة آمن ومؤقت لـ Agora RTC
 * Reads credentials from process.env instead of functions.config().
 * 
 * ✅ MODERN CONFIGURATION (Firebase 2026 Standards)
 * =================================================
 * This function uses environment variables from .env file instead of
 * the legacy functions.config() approach. This provides:
 * - Better security (standard .gitignore support)
 * - Easier local development setup
 * - Simpler configuration management
 * - Alignment with Firebase 2026 standards
 * 
 * Configuration:
 * - AGORA_APP_ID: Public identifier for Agora application
 * - AGORA_APP_CERTIFICATE: Secret key for generating secure tokens
 * 
 * These values are read from the .env file in the functions/ directory.
 * See functions/README.md for setup instructions.
 * 
 * @param {string} channelName - اسم القناة (Channel Name)
 * @param {number} uid - معرّف المستخدم الفريد (User ID)
 * @param {string} role - دور المستخدم ('publisher' أو 'subscriber')
 * @param {number} expirationTime - وقت انتهاء الصلاحية بالثواني (افتراضي: 3600)
 * @returns {string} - Agora Token
 * @throws {functions.https.HttpsError} - If environment variables are not configured
 */
function generateAgoraToken(channelName, uid, role = 'publisher', expirationTime = 3600) {
  // ✅ MODERN CONFIGURATION: Read from environment variables
  // قراءة بيانات الاعتماد من متغيرات البيئة
  const appId = process.env.AGORA_APP_ID;
  const appCertificate = process.env.AGORA_APP_CERTIFICATE;

  // ✅ ENHANCED VALIDATION: Track missing variables for detailed error messages
  // التحقق المحسّن: تتبع المتغيرات المفقودة لرسائل خطأ مفصلة
  const missingVars = [];
  if (!appId) {
    missingVars.push('AGORA_APP_ID');
  }
  if (!appCertificate) {
    missingVars.push('AGORA_APP_CERTIFICATE');
  }

  // ✅ ENHANCED ERROR MESSAGE: Include database context and specific missing variables
  // رسالة خطأ محسّنة: تتضمن سياق قاعدة البيانات والمتغيرات المفقودة المحددة
  if (missingVars.length > 0) {
    const errorMessage = `[DB: elajtech] Agora credentials not configured. Missing environment variables: ${missingVars.join(', ')}. ` +
      'Please ensure your .env file contains these variables.';

    // ✅ VALIDATION LOGGING: Log configuration error for debugging
    // تسجيل خطأ التكوين: لتسهيل تتبع الأخطاء
    console.error('❌ Agora Configuration Error:', {
      missingVariables: missingVars,
      databaseId: 'elajtech',
      errorType: 'missing_environment_variables',
      timestamp: new Date().toISOString(),
    });

    throw new functions.https.HttpsError(
      'failed-precondition',
      errorMessage
    );
  }

  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTime;

  // تحديد الدور (Publisher = 1, Subscriber = 2)
  const agoraRole = role === 'publisher' ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;

  // توليد الـ Token
  const token = RtcTokenBuilder.buildTokenWithUid(
    appId,
    appCertificate,
    channelName,
    uid,
    agoraRole,
    privilegeExpiredTs
  );

  return token;
}

/**
 * دالة مساعدة لتسجيل أحداث المكالمات في call_logs
 * 
 * Enhanced with database context for better debugging and monitoring.
 * All logs include database ID and collection information.
 * 
 * @param {Object} logData - بيانات السجل
 * @returns {Promise<void>}
 */
async function logCallEvent(logData) {
  try {
    // ============================================================================
    // DATABASE VERIFICATION BEFORE WRITE
    // ============================================================================
    // Task 1.7: Verify database configuration before call_logs write
    verifyDatabaseConfig('logCallEvent - call_logs write');

    const callLogsRef = db.collection('call_logs');

    // ✅ Enhanced: Add database context to all log entries
    const enhancedLogData = {
      ...logData,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      // Database context for debugging
      metadata: {
        ...(logData.metadata || {}),
        databaseId: 'elajtech', // Explicitly document which database is being used
        collectionName: 'call_logs', // Document the collection name
      },
    };

    // ✅ Enhanced: Include database context in error messages
    if (logData.errorMessage) {
      enhancedLogData.errorMessage = `[DB: elajtech] ${logData.errorMessage}`;
    }

    await callLogsRef.add(enhancedLogData);
    console.log(`✅ Call event logged to elajtech database: ${logData.eventType}`);
  } catch (error) {
    console.error('❌ Error logging call event to elajtech database:', error);
    console.error('❌ Failed log data:', JSON.stringify(logData, null, 2));
    // لا نرمي خطأ هنا لأن الـ logging لا يجب أن يعطل الـ flow الأساسي
  }
}

/**
 * Cloud Function: Get Functions Version
 * دالة للحصول على معلومات إصدار Cloud Functions
 * 
 * Purpose:
 * - Verify which version of Cloud Functions is deployed
 * - Confirm database configuration fix is present
 * - Enable diagnostic verification from Flutter app
 * - Facilitate debugging of deployment-related issues
 * 
 * Returns:
 * - version: Current functions version number
 * - deployedAt: Timestamp when functions were deployed
 * - databaseId: Configured Firestore database ID
 * - hasDatabaseConfigFix: Whether database config fix is present
 * - timestamp: Current server timestamp
 * 
 * Usage from Flutter:
 * ```dart
 * final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
 * final result = await functions.httpsCallable('getFunctionsVersion').call();
 * print('Version: ${result.data['version']}');
 * print('Database ID: ${result.data['databaseId']}');
 * ```
 * 
 * Reference: Doctor Start Call "Appointment Not Found" Recurrence Bugfix
 * Task: 1.2 Create getFunctionsVersion endpoint
 * Date: 2026-02-19
 */
exports.getFunctionsVersion = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    try {
      // Get current database configuration
      const currentDatabaseId = db._settings?.databaseId || 'NOT_SET';

      // Log version check request
      console.log('📋 [VERSION CHECK] Functions version requested', {
        version: FUNCTIONS_VERSION,
        deployedAt: DEPLOYED_AT,
        databaseId: currentDatabaseId,
        instanceId: DB_INSTANCE_ID,
        hasDatabaseConfigFix: DATABASE_CONFIG_FIX_PRESENT,
        requestedBy: context.auth?.uid || 'anonymous',
        timestamp: new Date().toISOString(),
      });

      // Return version information
      return {
        version: FUNCTIONS_VERSION,
        deployedAt: DEPLOYED_AT,
        databaseId: currentDatabaseId,
        instanceId: DB_INSTANCE_ID,
        hasDatabaseConfigFix: DATABASE_CONFIG_FIX_PRESENT,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      console.error('❌ [VERSION CHECK] Error getting functions version:', error);

      // Return error information but don't throw
      // This ensures the endpoint always returns useful data
      return {
        version: FUNCTIONS_VERSION,
        deployedAt: DEPLOYED_AT,
        databaseId: 'ERROR',
        instanceId: DB_INSTANCE_ID,
        hasDatabaseConfigFix: DATABASE_CONFIG_FIX_PRESENT,
        timestamp: new Date().toISOString(),
        error: error.message,
      };
    }
  });

/**
 * Cloud Function: بدء مكالمة Agora
 * 
 * يتم استدعاؤها من الطبيب لبدء المكالمة
 * تقوم بـ:
 * 1. توليد Agora Token للطبيب والمريض
 * 2. تحديث بيانات الموعد في Firestore
 * 3. إرسال VoIP notification للمريض
 */
exports.startAgoraCall = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    try {
      // التحقق من المصادقة
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'يجب تسجيل الدخول لبدء المكالمة'
        );
      }

      const { appointmentId, doctorId, deviceInfo } = data;

      // ============================================================================
      // APPOINTMENTID TRACING - DIAGNOSTIC LOGGING
      // ============================================================================
      // Task 1.5: Implement AppointmentId tracing in Cloud Functions
      // Purpose: Diagnose "Appointment Not Found" errors by tracing appointmentId
      //          from Flutter app through Cloud Functions to Firestore query
      // Reference: Doctor Start Call "Appointment Not Found" Recurrence Bugfix
      // Date: 2026-02-19
      // ============================================================================

      console.log('🔍 [ID TRACE] ============================================');
      console.log('🔍 [ID TRACE] AppointmentId Tracing Started');
      console.log('🔍 [ID TRACE] Instance ID:', DB_INSTANCE_ID);
      console.log('🔍 [ID TRACE] Received appointmentId:', appointmentId);
      console.log('🔍 [ID TRACE] appointmentId type:', typeof appointmentId);
      console.log('🔍 [ID TRACE] appointmentId length:', appointmentId ? appointmentId.length : 'NULL');
      console.log('🔍 [ID TRACE] appointmentId is null:', appointmentId === null);
      console.log('🔍 [ID TRACE] appointmentId is undefined:', appointmentId === undefined);
      console.log('🔍 [ID TRACE] appointmentId is empty string:', appointmentId === '');
      console.log('🔍 [ID TRACE] Received doctorId:', doctorId);
      console.log('🔍 [ID TRACE] Current database ID:', db._settings?.databaseId || 'NOT_SET');
      console.log('🔍 [ID TRACE] ============================================');

      // التحقق من المدخلات
      if (!appointmentId || !doctorId) {
        console.error('❌ [ID TRACE] Validation failed: Missing required parameters');
        console.error('❌ [ID TRACE] appointmentId provided:', !!appointmentId);
        console.error('❌ [ID TRACE] doctorId provided:', !!doctorId);

        throw new functions.https.HttpsError(
          'invalid-argument',
          'appointmentId and doctorId are required'
        );
      }

      // تسجيل محاولة بدء المكالمة
      await logCallEvent({
        eventType: 'call_attempt',
        appointmentId: appointmentId,
        userId: doctorId,
        deviceInfo: deviceInfo || null,
      });

      // ============================================================================
      // FIRESTORE QUERY TRACING
      // ============================================================================
      // Log the exact document path being queried
      console.log('🔍 [ID TRACE] Preparing Firestore query...');
      console.log('🔍 [ID TRACE] Collection: appointments');
      console.log('🔍 [ID TRACE] Document ID: ', appointmentId);

      // ============================================================================
      // DATABASE VERIFICATION BEFORE QUERY
      // ============================================================================
      // Task 1.7: Verify database configuration before critical query
      // This ensures we're querying the correct 'elajtech' database
      verifyDatabaseConfig('startAgoraCall - appointment query');

      // جلب بيانات الموعد
      const appointmentRef = db.collection('appointments').doc(appointmentId);

      console.log('🔍 [ID TRACE] Document path:', appointmentRef.path);
      console.log('🔍 [ID TRACE] Full path: /appointments/' + appointmentId);
      console.log('🔍 [ID TRACE] Executing Firestore query...');

      const appointmentDoc = await appointmentRef.get();

      // ============================================================================
      // QUERY RESULT TRACING
      // ============================================================================
      console.log('🔍 [ID TRACE] Query completed');
      console.log('🔍 [ID TRACE] Document exists:', appointmentDoc.exists);
      console.log('🔍 [ID TRACE] Document ID from result:', appointmentDoc.id);
      console.log('🔍 [ID TRACE] Document has data:', !!appointmentDoc.data());

      if (appointmentDoc.exists) {
        const data = appointmentDoc.data();
        console.log('🔍 [ID TRACE] Document data keys:', Object.keys(data || {}));
        console.log('🔍 [ID TRACE] Document doctorId:', data?.doctorId);
        console.log('🔍 [ID TRACE] Document patientId:', data?.patientId);
        console.log('🔍 [ID TRACE] Document status:', data?.status);
      }

      if (!appointmentDoc.exists) {
        // ============================================================================
        // APPOINTMENT NOT FOUND - ENHANCED DIAGNOSTIC LOGGING
        // ============================================================================
        console.error('❌ [ID TRACE] ============================================');
        console.error('❌ [ID TRACE] APPOINTMENT NOT FOUND - Starting Diagnostics');
        console.error('❌ [ID TRACE] ============================================');
        console.error('❌ [ID TRACE] Requested appointmentId:', appointmentId);
        console.error('❌ [ID TRACE] appointmentId type:', typeof appointmentId);
        console.error('❌ [ID TRACE] appointmentId length:', appointmentId.length);
        console.error('❌ [ID TRACE] Database queried:', db._settings?.databaseId || 'NOT_SET');
        console.error('❌ [ID TRACE] Collection queried: appointments');
        console.error('❌ [ID TRACE] Document path queried:', appointmentRef.path);
        console.error('❌ [ID TRACE] Query timestamp:', new Date().toISOString());

        // ============================================================================
        // QUERY ALL DOCTOR APPOINTMENTS FOR COMPARISON
        // ============================================================================
        console.log('🔍 [ID TRACE] Querying all appointments for doctor:', doctorId);
        console.log('🔍 [ID TRACE] This will help identify ID format mismatches...');

        try {
          const doctorAppointmentsQuery = await db.collection('appointments')
            .where('doctorId', '==', doctorId)
            .limit(10)
            .get();

          console.log('🔍 [ID TRACE] Found', doctorAppointmentsQuery.size, 'appointments for doctor');

          if (doctorAppointmentsQuery.size > 0) {
            console.log('🔍 [ID TRACE] ============================================');
            console.log('🔍 [ID TRACE] EXISTING APPOINTMENT IDs FOR COMPARISON:');
            console.log('🔍 [ID TRACE] ============================================');

            doctorAppointmentsQuery.forEach((doc, index) => {
              const existingId = doc.id;
              const data = doc.data();

              console.log(`🔍 [ID TRACE] Appointment ${index + 1}:`);
              console.log(`🔍 [ID TRACE]   - Document ID: ${existingId}`);
              console.log(`🔍 [ID TRACE]   - ID length: ${existingId.length}`);
              console.log(`🔍 [ID TRACE]   - ID type: ${typeof existingId}`);
              console.log(`🔍 [ID TRACE]   - Patient ID: ${data.patientId}`);
              console.log(`🔍 [ID TRACE]   - Status: ${data.status}`);
              console.log(`🔍 [ID TRACE]   - Created: ${data.createdAt?.toDate?.() || 'N/A'}`);

              // Compare with requested ID
              console.log(`🔍 [ID TRACE]   - Exact match: ${existingId === appointmentId}`);
              console.log(`🔍 [ID TRACE]   - Case-insensitive match: ${existingId.toLowerCase() === appointmentId.toLowerCase()}`);
              console.log(`🔍 [ID TRACE]   - Contains requested ID: ${existingId.includes(appointmentId)}`);
              console.log(`🔍 [ID TRACE]   - Requested ID contains this: ${appointmentId.includes(existingId)}`);

              // Check for common ID format differences
              const trimmedExisting = existingId.trim();
              const trimmedRequested = appointmentId.trim();
              console.log(`🔍 [ID TRACE]   - Match after trim: ${trimmedExisting === trimmedRequested}`);

              // Check for prefix/suffix differences
              if (existingId.startsWith(appointmentId)) {
                console.log(`🔍 [ID TRACE]   - ⚠️ Existing ID starts with requested ID (possible prefix issue)`);
                console.log(`🔍 [ID TRACE]   - Extra suffix: "${existingId.substring(appointmentId.length)}"`);
              }
              if (appointmentId.startsWith(existingId)) {
                console.log(`🔍 [ID TRACE]   - ⚠️ Requested ID starts with existing ID (possible prefix issue)`);
                console.log(`🔍 [ID TRACE]   - Extra prefix: "${appointmentId.substring(existingId.length)}"`);
              }

              console.log(`🔍 [ID TRACE]   ---`);
            });

            console.log('🔍 [ID TRACE] ============================================');
          } else {
            console.error('❌ [ID TRACE] No appointments found for doctor:', doctorId);
            console.error('❌ [ID TRACE] This suggests either:');
            console.error('❌ [ID TRACE]   1. Wrong doctorId provided');
            console.error('❌ [ID TRACE]   2. Appointments in different database');
            console.error('❌ [ID TRACE]   3. No appointments exist for this doctor');
          }
        } catch (queryError) {
          console.error('❌ [ID TRACE] Error querying doctor appointments:', queryError);
          console.error('❌ [ID TRACE] Error message:', queryError.message);
          console.error('❌ [ID TRACE] Error stack:', queryError.stack);
        }

        console.error('❌ [ID TRACE] ============================================');
        console.error('❌ [ID TRACE] DIAGNOSTIC LOGGING COMPLETE');
        console.error('❌ [ID TRACE] ============================================');

        // تسجيل الخطأ مع سياق قاعدة البيانات والمعلومات التشخيصية
        await logCallEvent({
          eventType: 'call_error',
          appointmentId: appointmentId,
          userId: doctorId,
          errorCode: 'appointment_not_found',
          errorMessage: 'الموعد غير موجود في قاعدة البيانات elajtech',
          deviceInfo: deviceInfo || null,
          metadata: {
            instanceId: DB_INSTANCE_ID,
            queriedDatabase: 'elajtech',
            queriedCollection: 'appointments',
            queriedDocumentId: appointmentId,
            appointmentIdType: typeof appointmentId,
            appointmentIdLength: appointmentId.length,
            documentPath: appointmentRef.path,
            queryTimestamp: new Date().toISOString(),
            doctorAppointmentsCount: doctorAppointmentsQuery?.size || 0,
          },
        });

        throw new functions.https.HttpsError(
          'not-found',
          'الموعد غير موجود في قاعدة البيانات'
        );
      }

      console.log('✅ [ID TRACE] Appointment found successfully');
      console.log('✅ [ID TRACE] Proceeding with call initiation...');

      const appointment = appointmentDoc.data();

      // التحقق من أن المستخدم هو الطبيب المسؤول
      if (appointment.doctorId !== doctorId) {
        // تسجيل الخطأ مع سياق قاعدة البيانات
        await logCallEvent({
          eventType: 'call_error',
          appointmentId: appointmentId,
          userId: doctorId,
          errorCode: 'permission_denied',
          errorMessage: 'غير مصرح لك ببدء هذه المكالمة',
          deviceInfo: deviceInfo || null,
          metadata: {
            queriedDatabase: 'elajtech',
            expectedDoctorId: appointment.doctorId,
            providedDoctorId: doctorId,
          },
        });

        throw new functions.https.HttpsError(
          'permission-denied',
          'غير مصرح لك ببدء هذه المكالمة'
        );
      }

      // إنشاء Channel Name فريد
      const channelName = `appointment_${appointmentId}_${Date.now()}`;

      // توليد UIDs فريدة
      const doctorUid = Math.floor(Math.random() * 1000000) + 1;
      const patientUid = Math.floor(Math.random() * 1000000) + 1000001;

      // توليد Tokens (صلاحية ساعة واحدة)
      let doctorToken, patientToken;
      try {
        doctorToken = generateAgoraToken(channelName, doctorUid, 'publisher', 3600);
        patientToken = generateAgoraToken(channelName, patientUid, 'publisher', 3600);
      } catch (tokenError) {
        // تسجيل خطأ توليد Token
        await logCallEvent({
          eventType: 'call_error',
          appointmentId: appointmentId,
          userId: doctorId,
          errorCode: 'token_generation_failed',
          errorMessage: tokenError.message,
          stackTrace: tokenError.stack,
          deviceInfo: deviceInfo || null,
        });

        throw tokenError;
      }

      // تحديث بيانات الموعد في Firestore
      try {
        await appointmentRef.update({
          agoraChannelName: channelName,
          agoraToken: patientToken, // Token for patient
          agoraUid: patientUid,
          doctorAgoraToken: doctorToken, // Token for doctor
          doctorAgoraUid: doctorUid,
          meetingProvider: 'agora',
          callStartedAt: admin.firestore.FieldValue.serverTimestamp(),
          status: 'scheduled',
        });
      } catch (firestoreError) {
        // تسجيل خطأ Firestore update
        await logCallEvent({
          eventType: 'call_error',
          appointmentId: appointmentId,
          userId: doctorId,
          errorCode: 'firestore_update_failed',
          errorMessage: firestoreError.message,
          stackTrace: firestoreError.stack,
          deviceInfo: deviceInfo || null,
        });

        throw firestoreError;
      }

      // إرسال VoIP notification للمريض
      try {
        await sendVoIPNotification({
          patientId: appointment.patientId,
          doctorName: appointment.doctorName,
          appointmentId: appointmentId,
          agoraChannelName: channelName,
          agoraToken: patientToken,
          agoraUid: patientUid,
        });
      } catch (notificationError) {
        // تسجيل فشل إرسال VoIP notification (لا نرمي خطأ)
        await logCallEvent({
          eventType: 'call_error',
          appointmentId: appointmentId,
          userId: doctorId,
          errorCode: 'voip_notification_failed',
          errorMessage: notificationError.message,
          deviceInfo: deviceInfo || null,
        });

        console.warn('⚠️ VoIP notification failed, but call was started', notificationError);
      }

      // تسجيل نجاح بدء المكالمة
      await logCallEvent({
        eventType: 'call_started',
        appointmentId: appointmentId,
        userId: doctorId,
        metadata: {
          channelName: channelName,
          doctorUid: doctorUid,
        },
      });

      console.log(`✅ Agora call started successfully for appointment ${appointmentId}`);

      return {
        success: true,
        message: 'تم بدء المكالمة بنجاح',
        agoraChannelName: channelName,
        agoraToken: doctorToken, // Return doctor's token
        agoraUid: doctorUid,
      };

    } catch (error) {
      console.error('❌ Error starting Agora call:', error);

      // تسجيل الخطأ العام إذا لم يتم تسجيله مسبقاً
      if (data && data.appointmentId && data.doctorId) {
        await logCallEvent({
          eventType: 'call_error',
          appointmentId: data.appointmentId,
          userId: data.doctorId,
          errorCode: 'unknown_error',
          errorMessage: error.message || 'حدث خطأ غير معروف',
          stackTrace: error.stack,
          deviceInfo: data.deviceInfo || null,
        });
      }

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError(
        'internal',
        'حدث خطأ أثناء بدء المكالمة',
        error.message
      );
    }
  });

/**
 * دالة إرسال VoIP Notification للمريض
 * 
 * ترسل إشعار VoIP عبر FCM لتنبيه المريض بمكالمة واردة
 * 
 * Enhanced with comprehensive logging for debugging and monitoring.
 * All logs include database context and detailed metadata.
 */
async function sendVoIPNotification(data) {
  const { patientId, doctorName, appointmentId, agoraChannelName, agoraToken, agoraUid } = data;

  try {
    // ✅ LOG: FCM token retrieval attempt
    console.log(`📱 Retrieving FCM token for patient: ${patientId}`);

    // ============================================================================
    // DATABASE VERIFICATION BEFORE QUERY
    // ============================================================================
    // Task 1.7: Verify database configuration before patient query
    verifyDatabaseConfig('sendVoIPNotification - patient query');

    // جلب FCM token للمريض
    const patientDoc = await db.collection('users').doc(patientId).get();

    if (!patientDoc.exists) {
      const errorMessage = `[DB: elajtech] Patient not found: ${patientId}`;
      console.error(`❌ ${errorMessage}`);

      // ✅ LOG: Patient not found error
      await logCallEvent({
        eventType: 'call_error',
        appointmentId: appointmentId,
        userId: patientId,
        errorCode: 'patient_not_found',
        errorMessage: errorMessage,
        metadata: {
          databaseId: 'elajtech',
          queriedCollection: 'users',
          queriedDocumentId: patientId,
        },
      });

      return;
    }

    const patient = patientDoc.data();
    const fcmToken = patient.fcmToken;

    if (!fcmToken) {
      const errorMessage = `[DB: elajtech] FCM token missing for patient: ${patientId}`;
      console.error(`❌ FCM token missing`);

      // ✅ LOG: FCM token missing error with specific error code
      await logCallEvent({
        eventType: 'call_error',
        appointmentId: appointmentId,
        userId: patientId,
        errorCode: 'fcm_token_missing',
        errorMessage: errorMessage,
        metadata: {
          databaseId: 'elajtech',
          patientId: patientId,
          hasPatientDocument: true,
          fcmTokenField: 'null or undefined',
        },
      });

      return;
    }

    // ✅ LOG: FCM token retrieved successfully
    console.log(`✅ FCM token retrieved successfully`);

    // إعداد رسالة FCM بصيغة VoIP مع دعم CallKit
    const message = {
      token: fcmToken,
      // ✅ إضافة notification object لإظهار الإشعار
      notification: {
        title: `مكالمة واردة من ${doctorName}`,
        body: 'اضغط للرد على الاستشارة',
      },
      data: {
        type: 'incoming_call',
        appointmentId: appointmentId,
        doctorName: doctorName,
        patientId: patientId,
        agoraChannelName: agoraChannelName,
        agoraToken: agoraToken,
        agoraUid: String(agoraUid),
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'incoming_calls',
          priority: 'max',
          sound: 'default',
          tag: appointmentId,
        },
      },
      // ✅ إضافة APNS configuration لـ iOS
      apns: {
        headers: {
          'apns-priority': '10', // أعلى أولوية
        },
        payload: {
          aps: {
            'content-available': 1, // ✅ إيقاظ التطبيق في الخلفية
            sound: 'default',
          },
        },
      },
    };

    // ✅ LOG: FCM notification send attempt
    console.log(`📤 Sending VoIP notification`, {
      appointmentId: appointmentId,
      doctorName: doctorName,
      channelName: agoraChannelName,
      patientId: patientId,
    });

    // إرسال الإشعار
    const response = await admin.messaging().send(message);

    // ✅ LOG: FCM notification sent successfully
    console.log(`✅ VoIP notification sent successfully: ${response}`);

    // ✅ LOG: Successful notification send event
    await logCallEvent({
      eventType: 'voip_notification_sent',
      appointmentId: appointmentId,
      userId: patientId,
      metadata: {
        databaseId: 'elajtech',
        fcmMessageId: response,
        doctorName: doctorName,
        agoraChannelName: agoraChannelName,
        notificationSentAt: new Date().toISOString(),
      },
    });

  } catch (error) {
    const errorMessage = `[DB: elajtech] Error sending VoIP notification: ${error.message}`;
    console.error(`❌ Error sending VoIP notification:`, error);

    // ✅ LOG: VoIP notification send failure
    await logCallEvent({
      eventType: 'call_error',
      appointmentId: appointmentId,
      userId: patientId,
      errorCode: 'voip_notification_failed',
      errorMessage: errorMessage,
      stackTrace: error.stack,
      metadata: {
        databaseId: 'elajtech',
        errorType: error.code || 'unknown',
        doctorName: doctorName,
        agoraChannelName: agoraChannelName,
      },
    });

    // لا نرمي خطأ هنا لأن المكالمة نفسها نجحت
  }
}

/**
 * Cloud Function: إنهاء المكالمة
 * 
 * تُستدعى عند إنهاء أي طرف للمكالمة
 */
exports.endAgoraCall = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'يجب تسجيل الدخول');
      }

      const { appointmentId } = data;

      if (!appointmentId) {
        throw new functions.https.HttpsError('invalid-argument', 'appointmentId is required');
      }

      // ============================================================================
      // DATABASE VERIFICATION BEFORE QUERY
      // ============================================================================
      // Task 1.7: Verify database configuration before appointment update
      verifyDatabaseConfig('endAgoraCall - appointment update');

      // تحديث وقت انتهاء المكالمة فقط
      // ✅ لا نحدث الحالة إلى 'completed' هنا
      // ✅ الحالة تبقى 'on_call' حتى يضغط الطبيب على زر "إكمال الموعد"
      await db.collection('appointments').doc(appointmentId).update({
        callEndedAt: admin.firestore.FieldValue.serverTimestamp(),
        // ❌ تم إزالة: status: 'completed',
      });

      console.log(`✅ Call ended for appointment ${appointmentId}`);

      return {
        success: true,
        message: 'تم إنهاء المكالمة',
      };

    } catch (error) {
      console.error('❌ Error ending call:', error);
      throw new functions.https.HttpsError('internal', 'حدث خطأ أثناء إنهاء المكالمة');
    }
  });

/**
 * Cloud Function: إكمال الموعد يدوياً
 * 
 * يتم استدعاؤها من الطبيب عند الضغط على زر "إكمال الموعد"
 * تقوم بـ:
 * 1. التحقق من أن المستخدم هو الطبيب المسؤول
 * 2. تحديث حالة الموعد إلى 'completed'
 * 3. تسجيل وقت الإكمال
 */
exports.completeAppointment = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    try {
      // التحقق من المصادقة
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'يجب تسجيل الدخول لإكمال الموعد'
        );
      }

      const { appointmentId, doctorId } = data;

      // التحقق من المدخلات
      if (!appointmentId || !doctorId) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'appointmentId and doctorId are required'
        );
      }

      // ============================================================================
      // DATABASE VERIFICATION BEFORE QUERY
      // ============================================================================
      // Task 1.7: Verify database configuration before appointment query
      verifyDatabaseConfig('completeAppointment - appointment query');

      // جلب بيانات الموعد
      const appointmentRef = db.collection('appointments').doc(appointmentId);
      const appointmentDoc = await appointmentRef.get();

      if (!appointmentDoc.exists) {
        // ✅ Enhanced: Log error with database context
        await logCallEvent({
          eventType: 'call_error',
          appointmentId: appointmentId,
          userId: doctorId,
          errorCode: 'appointment_not_found_on_complete',
          errorMessage: 'الموعد غير موجود في قاعدة البيانات elajtech عند محاولة الإكمال',
          metadata: {
            queriedDatabase: 'elajtech',
            queriedCollection: 'appointments',
            queriedDocumentId: appointmentId,
            operation: 'completeAppointment',
          },
        });

        throw new functions.https.HttpsError(
          'not-found',
          'الموعد غير موجود في قاعدة البيانات'
        );
      }

      const appointment = appointmentDoc.data();

      // التحقق من أن المستخدم هو الطبيب المسؤول
      if (appointment.doctorId !== doctorId) {
        // ✅ Enhanced: Log error with database context
        await logCallEvent({
          eventType: 'call_error',
          appointmentId: appointmentId,
          userId: doctorId,
          errorCode: 'permission_denied_on_complete',
          errorMessage: 'غير مصرح لك بإكمال هذا الموعد',
          metadata: {
            queriedDatabase: 'elajtech',
            expectedDoctorId: appointment.doctorId,
            providedDoctorId: doctorId,
            operation: 'completeAppointment',
          },
        });

        throw new functions.https.HttpsError(
          'permission-denied',
          'غير مصرح لك بإكمال هذا الموعد'
        );
      }

      // تحديث حالة الموعد إلى completed
      await appointmentRef.update({
        status: 'completed',
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`✅ Appointment ${appointmentId} marked as completed by doctor ${doctorId}`);

      return {
        success: true,
        message: 'تم إكمال الموعد بنجاح',
      };

    } catch (error) {
      console.error('❌ Error completing appointment:', error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError(
        'internal',
        'حدث خطأ أثناء إكمال الموعد',
        error.message
      );
    }
  });

/**
 * Cloud Function: تفعيل/تعطيل حساب مستخدم
 * 
 * يتم استدعاؤها من الأدمن لتغيير حالة الحساب (نشط/معطل)
 * تقوم بـ:
 * 1. التحقق من صلاحيات الأدمن
 * 2. تحديث حالة الحساب في Firebase Auth (disabled)
 * 3. تحديث حقل isActive في Firestore
 * 4. تسجيل العملية في audit_logs
 */
exports.setAccountStatus = functions
  .region('europe-west1')
  .runWith({ enforceAppCheck: false })
  .https.onCall(async (data, context) => {
    // 1. التحقق من المصادقة
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'يجب تسجيل الدخول لتنفيذ هذا الإجراء'
      );
    }

    const { targetUserId, isActive, adminName } = data;
    const adminId = context.auth.uid;

    // 2. التحقق من المدخلات
    if (!targetUserId || isActive === undefined) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'معرف المستخدم وحالة الحساب مطلوبان'
      );
    }

    try {
      // 3. التحقق من أن القائم بالعملية هو أدمن
      const adminDoc = await db.collection('users').doc(adminId).get();
      if (!adminDoc.exists || adminDoc.data().userType !== 'admin') {
        throw new functions.https.HttpsError(
          'permission-denied',
          'غير مصرح لك بتنفيذ هذا الإجراء'
        );
      }

      console.log(`🔐 Admin ${adminId} is changing status for ${targetUserId} to isActive=${isActive}`);

      // 4. تحديث Firebase Auth (تعطيل/تمكين الحساب)
      // Note: Firebase Auth uses 'disabled', which is the opposite of 'isActive'
      await admin.auth().updateUser(targetUserId, {
        disabled: !isActive
      });
      console.log(`✅ Firebase Auth updated for ${targetUserId}`);

      // 5. تحديث Firestore
      await db.collection('users').doc(targetUserId).update({
        isActive: isActive,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      console.log(`✅ Firestore updated for ${targetUserId}`);

      // 6. تسجيل العملية في سجل التدقيق (audit_logs)
      await db.collection('audit_logs').add({
        adminId: adminId,
        adminName: adminName || adminDoc.data().fullName || 'Admin',
        action: isActive ? 'enable_account' : 'disable_account',
        targetId: targetUserId,
        targetType: 'user',
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        metadata: {
          isActive: isActive,
          targetUid: targetUserId
        }
      });
      console.log(`✅ Audit log written for ${targetUserId}`);

      return {
        success: true,
        message: isActive ? 'تم تفعيل الحساب بنجاح' : 'تم تعطيل الحساب بنجاح'
      };

    } catch (error) {
      console.error('❌ Error in setAccountStatus:', error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError(
        'internal',
        'حدث خطأ أثناء تحديث حالة الحساب: ' + error.message
      );
    }
  });

/**
 * ✅ مساعد للتحقق مما إذا كان المستدعي مسؤولاً (Admin)
 */
async function checkIsAdmin(context) {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'يجب تسجيل الدخول');
  }
  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  if (!userDoc.exists || userDoc.data().userType !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'ليس لديك صلاحية مسؤول (Admin)');
  }
}

// ============================================
// 🩺 Cloud Function: Create Doctor Account
// يتم استدعاؤها من لوحة الإدارة لإنشاء حساب طبيب جديد
// ============================================
exports.createDoctorAccount = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    console.log('🩺 createDoctorAccount called');
    await checkIsAdmin(context);

    const {
      email,
      password,
      fullName,
      phoneNumber,
      licenseNumber,
      specializations,
      workingHours,
      biography,
      yearsOfExperience,
      consultationFee,
      consultationTypes,
      clinicName,
      clinicAddress,
      profileImage
    } = data;

    if (!email || !password || !fullName) {
      throw new functions.https.HttpsError('invalid-argument', 'البريد وكلمة المرور والاسم مطلوبة');
    }

    try {
      // 1. إنشاء حساب في Firebase Auth
      const userRecord = await admin.auth().createUser({
        email,
        password,
        displayName: fullName,
        phoneNumber: phoneNumber || undefined,
      });

      // 2. إنشاء مستند المستخدم في Firestore (قاعدة بيانات elajtech)
      await db.collection('users').doc(userRecord.uid).set({
        id: userRecord.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber || '',
        userType: 'doctor',
        isActive: true,
        licenseNumber: licenseNumber || '',
        specializations: specializations || [],
        workingHours: workingHours || {},
        biography: biography || '',
        yearsOfExperience: yearsOfExperience || 0,
        consultationFee: consultationFee || 0,
        consultationTypes: consultationTypes || [],
        clinicName: clinicName || '',
        clinicAddress: clinicAddress || '',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        profileImage: profileImage || '', // Saved from the provided URL
      });

      console.log(`✅ Doctor account created: ${userRecord.uid}`);
      return { uid: userRecord.uid };

    } catch (error) {
      console.error('❌ Error creating doctor account:', error);
      if (error.code === 'auth/email-already-exists') {
        throw new functions.https.HttpsError('already-exists', 'هذا البريد الإلكتروني مسجل مسبقاً');
      }
      throw new functions.https.HttpsError('internal', error.message);
    }
  });

// ============================================
// EXPORTS FOR TESTING
// ============================================

/**
 * Cloud Function: التحقق من مواعيد الطبيب لمنع التضارب
 * 
 * يتم استدعاؤها من المريض (أو الطبيب) للتحقق من وجود تضارب في المواعيد
 * الغرض: تجاوز قيود تصاريح Firestore التي تمنع المرضى من قراءة مواعيد الأطباء بالكامل
 * 
 * @param {string} doctorId - معرف الطبيب
 * @param {number} startTimeMs - وقت بداية النطاق (ميللي ثانية)
 * @param {number} endTimeMs - وقت نهاية النطاق (ميللي ثانية)
 * @returns {Object} - قائمة بالمواعيد المتعارضة { appointments: [] }
 */
exports.checkDoctorAppointments = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    try {
      // التحقق من المصادقة
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'يجب تسجيل الدخول للتحقق من المواعيد'
        );
      }

      const { doctorId, startTimeMs, endTimeMs } = data;

      if (!doctorId || !startTimeMs || !endTimeMs) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'doctorId, startTimeMs, and endTimeMs are required'
        );
      }

      console.log(`🔍 [CONFLICT CHECK] Checking appointments for doctor: ${doctorId}`);
      console.log(`🔍 [CONFLICT CHECK] Range: ${new Date(startTimeMs).toISOString()} - ${new Date(endTimeMs).toISOString()}`);

      // التحقق من قاعدة البيانات
      verifyDatabaseConfig('checkDoctorAppointments');

      const activeStatuses = ['pending', 'confirmed', 'scheduled', 'completed'];

      // ✅ Fix: the previous syntax was wrong (await on db.collection(...) without executing a query properly)
      const querySnapshot = await db.collection('appointments')
        .where('doctorId', '==', doctorId)
        .where('status', 'in', activeStatuses)
        .where('appointmentTimestamp', '>=', admin.firestore.Timestamp.fromMillis(startTimeMs))
        .where('appointmentTimestamp', '<=', admin.firestore.Timestamp.fromMillis(endTimeMs))
        .get();

      console.log(`✅ [CONFLICT CHECK] Found ${querySnapshot.size} appointments for doctor`);

      const appointments = [];
      querySnapshot.forEach(doc => {
        const apptData = doc.data();
        // إرجاع الحد الأدنى من البيانات اللازم للتحقق من التضارب للحفاظ على الخصوصية
        appointments.push({
          id: doc.id,
          doctorId: apptData.doctorId,
          patientId: apptData.patientId,
          status: apptData.status,
          timeSlot: apptData.timeSlot,
          appointmentTimestamp: apptData.appointmentTimestamp.toMillis(),
          type: apptData.type, // Could be undefined for old records, but that's fine
          doctorName: apptData.doctorName,
        });
      });

      return { appointments };
    } catch (error) {
      console.error('❌ [CONFLICT CHECK] Error checking doctor appointments:', error);
      throw new functions.https.HttpsError('internal', error.message);
    }
  });

/**
 * دالة تسجيل أحداث الإشعارات
 */
async function logNotificationEvent(data) {
  const { appointmentId, userId, eventType, status, errorMessage, metadata } = data;

  try {
    verifyDatabaseConfig('logNotificationEvent');

    await db.collection('notification_logs').add({
      appointmentId,
      userId,
      eventType,
      status,
      errorMessage: errorMessage || null,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      metadata: {
        databaseId: 'elajtech',
        ...metadata,
      },
    });
  } catch (error) {
    console.error('❌ Error logging notification event:', error);
  }
}

/**
 * Cloud Function: إشعار فوري للطبيب عند حجز موعد
 */
exports.onAppointmentCreated = functions
  .region('europe-west1')
  .firestore.database('elajtech').document('appointments/{appointmentId}')
  .onCreate(async (snapshot, context) => {
    const appointmentId = context.params.appointmentId;
    const appointment = snapshot.data();

    console.log(`📅 New appointment created: ${appointmentId}`);

    try {
      verifyDatabaseConfig('onAppointmentCreated');

      const doctorId = appointment.doctorId;
      const doctorDoc = await db.collection('users').doc(doctorId).get();

      if (!doctorDoc.exists) {
        console.error(`❌ Doctor not found: ${doctorId}`);
        return;
      }

      const doctor = doctorDoc.data();
      const fcmToken = doctor.fcmToken;

      if (!fcmToken) {
        console.warn(`⚠️ FCM token missing for doctor: ${doctorId}`);
        await logNotificationEvent({
          appointmentId: appointmentId,
          userId: doctorId,
          eventType: 'appointment_booked_doctor',
          status: 'failed',
          errorMessage: 'FCM token missing',
        });
        return;
      }

      const message = {
        token: fcmToken,
        notification: {
          title: 'موعد جديد محجوز',
          body: `قام المريض ${appointment.patientName} بحجز موعد معك بتاريخ ${appointment.timeSlot}`,
        },
        data: {
          type: 'appointment_booked_doctor',
          appointmentId: appointmentId,
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'main_channel',
            priority: 'max',
          },
        },
      };

      const response = await admin.messaging().send(message);
      console.log(`✅ Immediate booking notification sent to doctor: ${response}`);

      await logNotificationEvent({
        appointmentId: appointmentId,
        userId: doctorId,
        eventType: 'appointment_booked_doctor',
        status: 'success',
        metadata: { fcmMessageId: response },
      });

    } catch (error) {
      console.error('❌ Error in onAppointmentCreated:', error);
    }
  });

/**
 * Cloud Function: تذكير بالمواعيد (كل 5 دقائق)
 */
exports.checkAppointmentReminders = functions
  .region('europe-west1')
  .pubsub.schedule('every 5 minutes')
  .onRun(async (context) => {
    console.log('⏰ Running checkAppointmentReminders scheduler...');

    try {
      verifyDatabaseConfig('checkAppointmentReminders');

      const now = new Date();
      // نافذة زمنية بين 29 و 31 دقيقة من الآن
      const startTime = new Date(now.getTime() + 29 * 60000);
      const endTime = new Date(now.getTime() + 31 * 60000);

      const appointmentsSnapshot = await db.collection('appointments')
        .where('status', 'in', ['confirmed', 'scheduled'])
        .where('appointmentTimestamp', '>=', admin.firestore.Timestamp.fromDate(startTime))
        .where('appointmentTimestamp', '<=', admin.firestore.Timestamp.fromDate(endTime))
        .get();

      console.log(`🔍 Found ${appointmentsSnapshot.size} appointments in the 30-min window`);

      const tasks = [];
      appointmentsSnapshot.forEach(doc => {
        tasks.push(handleAppointmentReminder(doc));
      });

      await Promise.all(tasks);
      console.log('✅ Appointment reminders processing complete');

    } catch (error) {
      console.error('❌ Error in checkAppointmentReminders:', error);
    }
  });

/**
 * مساعد للتعامل مع تذكير موعد محدد
 */
async function handleAppointmentReminder(doc) {
  const appointmentId = doc.id;
  const appointment = doc.data();

  const doctorTask = (async () => {
    if (appointment.doctorReminderSent) return;

    try {
      const doctorDoc = await db.collection('users').doc(appointment.doctorId).get();
      if (doctorDoc.exists && doctorDoc.data().fcmToken) {
        const message = {
          token: doctorDoc.data().fcmToken,
          notification: {
            title: 'تذكير بالموعد',
            body: `لديك موعد مع ${appointment.patientName} بعد 30 دقيقة`,
          },
          data: {
            type: 'appointment_reminder_doctor',
            appointmentId: appointmentId,
          },
        };
        const response = await admin.messaging().send(message);
        await doc.ref.update({ doctorReminderSent: true });
        await logNotificationEvent({
          appointmentId,
          userId: appointment.doctorId,
          eventType: 'appointment_reminder_doctor',
          status: 'success',
          metadata: { fcmMessageId: response },
        });
      }
    } catch (e) {
      console.error(`❌ Error sending doctor reminder for ${appointmentId}:`, e);
    }
  })();

  const patientTask = (async () => {
    if (appointment.patientReminderSent) return;

    try {
      const patientDoc = await db.collection('users').doc(appointment.patientId).get();
      if (patientDoc.exists && patientDoc.data().fcmToken) {
        const message = {
          token: patientDoc.data().fcmToken,
          notification: {
            title: 'تذكير بالموعد',
            body: `موعدك مع د. ${appointment.doctorName} غداً بعد 30 دقيقة`,
          },
          data: {
            type: 'appointment_reminder_patient',
            appointmentId: appointmentId,
          },
        };
        const response = await admin.messaging().send(message);
        await doc.ref.update({ patientReminderSent: true });
        await logNotificationEvent({
          appointmentId,
          userId: appointment.patientId,
          eventType: 'appointment_reminder_patient',
          status: 'success',
          metadata: { fcmMessageId: response },
        });
      }
    } catch (e) {
      console.error(`❌ Error sending patient reminder for ${appointmentId}:`, e);
    }
  })();

  await Promise.all([doctorTask, patientTask]);
}

/**
 * Export functions for testing purposes
 * Only available in test/emulator environment
 * 
 * These exports allow unit tests to directly test utility functions
 * like generateAgoraToken without going through the Cloud Functions layer.
 * 
 * Security: Only exported when NODE_ENV is 'test' or FUNCTIONS_EMULATOR is 'true'
 */
if (process.env.NODE_ENV === 'test' || process.env.FUNCTIONS_EMULATOR === 'true') {
  module.exports = {
    // Utility functions for unit testing
    generateAgoraToken,
    logCallEvent,
    sendVoIPNotification,
    logNotificationEvent,
    handleAppointmentReminder,

    // Cloud Functions for integration testing
    startAgoraCall: exports.startAgoraCall,
    endAgoraCall: exports.endAgoraCall,
    completeAppointment: exports.completeAppointment,
    getFunctionsVersion: exports.getFunctionsVersion,
    checkDoctorAppointments: exports.checkDoctorAppointments,
    onAppointmentCreated: exports.onAppointmentCreated,
    checkAppointmentReminders: exports.checkAppointmentReminders,
  };
}

