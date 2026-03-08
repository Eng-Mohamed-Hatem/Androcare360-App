# Doctor Start Call "Appointment Not Found" Recurrence - Bugfix Design

## Overview

This design document provides a comprehensive diagnostic and fix strategy for the recurring "Appointment Not Found" error that occurs when doctors attempt to initiate video calls in the AndroCare360 platform. Despite a previous fix that added explicit database configuration (`db.settings({ databaseId: 'elajtech' })`), the error persists, indicating a more complex root cause.

The design follows a systematic approach:
1. Diagnostic solutions for each of the 5 root cause hypotheses
2. Technical implementation for each identified fix
3. Enhanced logging and monitoring infrastructure
4. Comprehensive testing strategy
5. Safe deployment plan with rollback procedures

## Glossary

- **Bug_Condition (C)**: The condition that triggers the "Appointment Not Found" error when doctors attempt to start video calls
- **Property (P)**: The desired behavior - successful appointment retrieval from the 'elajtech' database and call initiation
- **Preservation**: Existing functionality that must remain unchanged (appointment listing, other Cloud Functions, Flutter app queries)
- **startAgoraCall**: Cloud Function in `functions/index.js` that initiates video calls by generating Agora tokens
- **appointmentId**: Unique identifier for appointments, must match Firestore document ID exactly
- **databaseId**: Firestore database identifier, must be 'elajtech' for all AndroCare360 operations
- **db.settings()**: Firebase Admin SDK method to configure Firestore database targeting
- **call_logs**: Firestore collection storing all call-related events for monitoring and debugging

## Bug Details

### Fault Condition

The bug manifests when a doctor clicks "Start Call" and the `startAgoraCall` Cloud Function fails to retrieve the appointment document from Firestore, despite the appointment existing in the database. The function returns a "not-found" error, preventing call initiation.

**Formal Specification:**
```
FUNCTION isBugCondition(input)
  INPUT: input of type CallInitiationRequest
  OUTPUT: boolean
  
  RETURN (
    input.userRole = 'doctor' AND
    input.action = 'start_call' AND
    input.appointmentId IS NOT NULL AND
    input.appointmentExistsInElajtechDB = true AND
    (
      // Hypothesis 1: Deployment issue
      (deployedFunctionsVersion.hasDatabaseConfigFix = false) OR
      
      // Hypothesis 2: AppointmentId mismatch
      (input.appointmentId ≠ firestoreDocumentId) OR
      
      // Hypothesis 3: Database configuration ineffective
      (actualDatabaseQueried ≠ 'elajtech') OR
      
      // Hypothesis 4: Multiple Firestore instances
      (queryUsesUnconfiguredInstance = true) OR
      
      // Hypothesis 5: Conditional configuration logic
      (databaseConfigurationSkipped = true)
    )
  )
END FUNCTION
```

### Examples

1. **Scenario 1: Deployment Issue**
   - Doctor clicks "Start Call" for appointment `apt_20240216_001`
   - Cloud Function runs old code without database configuration
   - Query targets default database instead of 'elajtech'
   - Result: "Appointment Not Found" error

2. **Scenario 2: AppointmentId Mismatch**
   - Firestore document ID: `apt_20240216_001`
   - Flutter app passes: `appointment_20240216_001` (different format)
   - Cloud Function queries with mismatched ID
   - Result: "Appointment Not Found" error

3. **Scenario 3: Database Configuration Ineffective**
   - `db.settings({ databaseId: 'elajtech' })` is called
   - But conditional logic skips it: `if (!db._settings || !db._settings.databaseId)`
   - Query still targets default database
   - Result: "Appointment Not Found" error

4. **Edge Case: Multiple Firestore Instances**
   - Code creates new Firestore instance: `admin.firestore()`
   - New instance doesn't have database configuration
   - Query uses unconfigured instance
   - Result: "Appointment Not Found" error


## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Appointment listing in Flutter app must continue to display all appointments correctly
- Existing Cloud Functions (`endAgoraCall`, `completeAppointment`) must continue to work
- Flutter app Firestore queries must continue to use `FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'elajtech')`
- Call logs must continue to be written to the 'elajtech' database
- Patient FCM token retrieval must continue to work
- Video call UI must continue to display correctly
- All 664+ existing unit tests must continue to pass

**Scope:**
All inputs that do NOT involve the "Start Call" action should be completely unaffected by this fix. This includes:
- Viewing appointments list
- Completing appointments
- Ending calls
- Creating appointments
- Updating appointment status
- Querying appointments from Flutter app

## Hypothesized Root Cause

Based on the bug analysis and code review, the following are the most likely root causes:

### Hypothesis 1: Deployment Issue

**Description**: The database configuration fix exists in the repository code but was not deployed to production. The deployed Cloud Functions may be running an older version without the fix.

**Evidence**:
- Fix is present in `functions/index.js` lines 40-41
- Error persists despite fix being in codebase
- No verification of deployed version vs repository version

**Likelihood**: Medium (30%)

**Impact if True**: High - Simple redeployment would fix the issue

### Hypothesis 2: AppointmentId Mismatch

**Description**: The `appointment.id` field in the Flutter app does not match the actual Firestore document ID. This could occur if the ID is transformed during serialization/deserialization or if the model uses a different field.

**Evidence**:
- `AppointmentModel.fromJson()` reads `id` from JSON: `id: json['id'] as String`
- No explicit mapping to Firestore document ID
- Flutter app passes `widget.appointment.id` to Cloud Function
- No logging to verify ID consistency

**Likelihood**: High (40%)

**Impact if True**: High - Requires ID mapping fix in Flutter app

### Hypothesis 3: Database Configuration Ineffective

**Description**: The `db.settings({ databaseId: 'elajtech' })` call is present but not effective due to conditional logic that may prevent it from being applied.

**Evidence**:
- Conditional check: `if (!db._settings || !db._settings.databaseId)`
- This condition may evaluate to false if settings already exist
- No runtime verification of actual database being queried

**Likelihood**: High (35%)

**Impact if True**: Medium - Requires unconditional configuration

### Hypothesis 4: Multiple Firestore Instances

**Description**: The code creates multiple Firestore instances, and some queries use an instance without the database configuration.

**Evidence**:
- Single `const db = admin.firestore()` declaration at top of file
- All queries use this instance
- No evidence of multiple instances in current code

**Likelihood**: Low (10%)

**Impact if True**: Low - Current code appears to use single instance

### Hypothesis 5: Conditional Configuration Logic

**Description**: The conditional logic in database configuration has edge cases where it doesn't apply the settings.

**Evidence**:
- Code: `if (!db._settings || !db._settings.databaseId) { db.settings({ databaseId: 'elajtech' }); }`
- If `db._settings` exists but `databaseId` is different, condition fails
- If `db._settings.databaseId` is already set (even to wrong value), condition fails

**Likelihood**: Medium (25%)

**Impact if True**: Medium - Requires unconditional configuration or better condition


## Correctness Properties

Property 1: Fault Condition - Appointment Retrieval Success

_For any_ call initiation request where a doctor attempts to start a video call with a valid appointmentId that exists in the 'elajtech' database, the fixed `startAgoraCall` function SHALL successfully retrieve the appointment document, generate Agora tokens, update the appointment with call metadata, and send a VoIP notification to the patient.

**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10**

Property 2: Preservation - Non-Call-Initiation Behavior

_For any_ operation that is NOT a doctor-initiated call start (appointment listing, call ending, appointment completion, appointment creation), the fixed code SHALL produce exactly the same behavior as the original code, preserving all existing functionality for non-call-initiation operations.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10**

## Fix Implementation

### Diagnostic Phase: Identify Root Cause

Before implementing fixes, we must diagnose which hypothesis is correct. The following diagnostic solutions will be implemented:

#### Diagnostic 1: Verify Deployed Functions Version

**Objective**: Determine if the deployed Cloud Functions include the database configuration fix.

**Implementation**:

1. **Add Version Logging to Cloud Functions**
   ```javascript
   // At top of functions/index.js, after imports
   const FUNCTIONS_VERSION = '2.1.0-diagnostic'; // Increment on each deployment
   const DATABASE_CONFIG_FIX_PRESENT = true; // Flag to track fix presence
   
   console.log('🚀 [INIT] Cloud Functions Version:', FUNCTIONS_VERSION);
   console.log('🔧 [INIT] Database Config Fix Present:', DATABASE_CONFIG_FIX_PRESENT);
   ```

2. **Add Version Endpoint**
   ```javascript
   exports.getFunctionsVersion = functions
     .region('europe-west1')
     .https.onCall(async (data, context) => {
       return {
         version: FUNCTIONS_VERSION,
         databaseConfigFixPresent: DATABASE_CONFIG_FIX_PRESENT,
         databaseId: db._settings?.databaseId || 'NOT_SET',
         timestamp: new Date().toISOString(),
       };
     });
   ```

3. **Call from Flutter App on Startup**
   ```dart
   // In main.dart or initialization service
   Future<void> verifyCloudFunctionsVersion() async {
     try {
       final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
       final result = await functions.httpsCallable('getFunctionsVersion').call();
       
       debugPrint('☁️ Cloud Functions Version: ${result.data['version']}');
       debugPrint('☁️ Database Config Fix: ${result.data['databaseConfigFixPresent']}');
       debugPrint('☁️ Database ID: ${result.data['databaseId']}');
       
       if (result.data['databaseId'] != 'elajtech') {
         debugPrint('❌ WARNING: Cloud Functions not using elajtech database!');
       }
     } catch (e) {
       debugPrint('❌ Error verifying Cloud Functions version: $e');
     }
   }
   ```

**Expected Outcome**: If version is old or databaseId is not 'elajtech', Hypothesis 1 is confirmed.

#### Diagnostic 2: Trace AppointmentId Flow

**Objective**: Verify that appointmentId passed from Flutter matches Firestore document ID.

**Implementation**:

1. **Enhanced Logging in Flutter App**
   ```dart
   // In doctor_appointments_screen.dart, before calling startVideoCall
   Future<void> _startVideoCall() async {
     // Get appointment from Firestore to verify ID
     final firestoreDoc = await FirebaseFirestore.instanceFor(
       app: Firebase.app(),
       databaseId: 'elajtech',
     ).collection('appointments').doc(widget.appointment.id).get();
     
     debugPrint('🔍 [ID TRACE] Flutter appointment.id: ${widget.appointment.id}');
     debugPrint('🔍 [ID TRACE] Firestore doc.id: ${firestoreDoc.id}');
     debugPrint('🔍 [ID TRACE] Firestore doc.exists: ${firestoreDoc.exists}');
     debugPrint('🔍 [ID TRACE] IDs match: ${widget.appointment.id == firestoreDoc.id}');
     
     if (widget.appointment.id != firestoreDoc.id) {
       debugPrint('❌ [ID MISMATCH] AppointmentId mismatch detected!');
     }
     
     final result = await VideoConsultationService().startVideoCall(
       appointmentId: widget.appointment.id,
       doctorId: doctorId,
     );
   }
   ```

2. **Enhanced Logging in Cloud Functions**
   ```javascript
   // In startAgoraCall function, before querying Firestore
   console.log('🔍 [ID TRACE] Received appointmentId:', appointmentId);
   console.log('🔍 [ID TRACE] appointmentId type:', typeof appointmentId);
   console.log('🔍 [ID TRACE] appointmentId length:', appointmentId.length);
   
   const appointmentRef = db.collection('appointments').doc(appointmentId);
   console.log('🔍 [ID TRACE] Querying document path:', appointmentRef.path);
   
   const appointmentDoc = await appointmentRef.get();
   console.log('🔍 [ID TRACE] Document exists:', appointmentDoc.exists);
   console.log('🔍 [ID TRACE] Document ID:', appointmentDoc.id);
   
   if (!appointmentDoc.exists) {
     // Query all appointments to find potential matches
     const allAppointments = await db.collection('appointments')
       .where('doctorId', '==', doctorId)
       .limit(10)
       .get();
     
     console.log('🔍 [ID TRACE] Found', allAppointments.size, 'appointments for doctor');
     allAppointments.forEach(doc => {
       console.log('🔍 [ID TRACE] Existing appointment ID:', doc.id);
       console.log('🔍 [ID TRACE] Similarity to requested ID:', 
         doc.id.includes(appointmentId) || appointmentId.includes(doc.id));
     });
   }
   ```

**Expected Outcome**: If IDs don't match or document doesn't exist, Hypothesis 2 is confirmed.


#### Diagnostic 3: Verify Database Configuration at Runtime

**Objective**: Confirm that Firestore queries actually target the 'elajtech' database at runtime.

**Implementation**:

1. **Enhanced Database Configuration Logging**
   ```javascript
   // In functions/index.js, replace existing configuration
   const db = admin.firestore();
   
   // Log initial state
   console.log('🔧 [DB CONFIG] Initial db._settings:', JSON.stringify(db._settings, null, 2));
   console.log('🔧 [DB CONFIG] Initial databaseId:', db._settings?.databaseId || 'NOT_SET');
   
   // Apply configuration unconditionally (remove conditional check)
   try {
     db.settings({ databaseId: 'elajtech' });
     console.log('✅ [DB CONFIG] Database settings applied successfully');
   } catch (error) {
     console.error('❌ [DB CONFIG] Error applying database settings:', error);
   }
   
   // Verify configuration was applied
   console.log('🔧 [DB CONFIG] Final db._settings:', JSON.stringify(db._settings, null, 2));
   console.log('🔧 [DB CONFIG] Final databaseId:', db._settings?.databaseId || 'NOT_SET');
   
   if (!db._settings?.databaseId || db._settings.databaseId !== 'elajtech') {
     console.error('❌ [CRITICAL] Firestore database ID configuration FAILED!');
     console.error('❌ [CRITICAL] Expected: elajtech, Got:', db._settings?.databaseId || 'NOT_SET');
   } else {
     console.log('✅ [DB CONFIG] Firestore configured to use elajtech database');
   }
   ```

2. **Add Query-Level Database Verification**
   ```javascript
   // Helper function to verify database before queries
   function verifyDatabaseConfig(operationName) {
     const currentDbId = db._settings?.databaseId;
     console.log(`🔍 [DB VERIFY] ${operationName} - Current databaseId:`, currentDbId);
     
     if (currentDbId !== 'elajtech') {
       console.error(`❌ [DB VERIFY] ${operationName} - WRONG DATABASE!`);
       console.error(`❌ [DB VERIFY] Expected: elajtech, Got: ${currentDbId || 'NOT_SET'}`);
       return false;
     }
     
     console.log(`✅ [DB VERIFY] ${operationName} - Using correct database`);
     return true;
   }
   
   // Use before each Firestore query
   // In startAgoraCall:
   verifyDatabaseConfig('startAgoraCall - appointment query');
   const appointmentRef = db.collection('appointments').doc(appointmentId);
   ```

**Expected Outcome**: If databaseId is not 'elajtech' at runtime, Hypothesis 3 or 5 is confirmed.

#### Diagnostic 4: Audit Firestore Instance Usage

**Objective**: Ensure all Firestore queries use the configured instance.

**Implementation**:

1. **Search for Multiple Instance Creation**
   ```bash
   # Run in functions/ directory
   grep -n "admin.firestore()" index.js
   grep -n "new Firestore" index.js
   grep -n "getFirestore" index.js
   ```

2. **Add Instance Tracking**
   ```javascript
   // At top of functions/index.js
   const db = admin.firestore();
   const DB_INSTANCE_ID = Math.random().toString(36).substring(7);
   
   console.log('🔧 [INSTANCE] Created Firestore instance:', DB_INSTANCE_ID);
   
   // Add to each query
   console.log('🔍 [INSTANCE] Using instance:', DB_INSTANCE_ID);
   ```

**Expected Outcome**: If multiple instances are found, Hypothesis 4 is confirmed.

#### Diagnostic 5: Test Conditional Configuration Logic

**Objective**: Verify that the conditional check doesn't prevent configuration.

**Implementation**:

1. **Log Conditional Evaluation**
   ```javascript
   // Replace existing conditional configuration
   console.log('🔧 [CONDITION] Evaluating configuration condition...');
   console.log('🔧 [CONDITION] db._settings exists:', !!db._settings);
   console.log('🔧 [CONDITION] db._settings.databaseId:', db._settings?.databaseId);
   console.log('🔧 [CONDITION] Condition (!db._settings || !db._settings.databaseId):', 
     !db._settings || !db._settings.databaseId);
   
   if (!db._settings || !db._settings.databaseId) {
     console.log('✅ [CONDITION] Condition TRUE - Applying configuration');
     db.settings({ databaseId: 'elajtech' });
   } else {
     console.log('⚠️ [CONDITION] Condition FALSE - Configuration SKIPPED');
     console.log('⚠️ [CONDITION] Existing databaseId:', db._settings.databaseId);
   }
   ```

2. **Test with Forced Configuration**
   ```javascript
   // Alternative: Always apply configuration (remove conditional)
   console.log('🔧 [CONFIG] Applying database configuration unconditionally');
   db.settings({ databaseId: 'elajtech' });
   ```

**Expected Outcome**: If condition evaluates to false and skips configuration, Hypothesis 5 is confirmed.


### Fix Phase: Implement Solutions

Based on diagnostic results, implement the appropriate fixes:

#### Fix 1: Ensure Deployment (Hypothesis 1)

**Changes Required:**

**File**: `functions/index.js`

**Specific Changes**:
1. Add version constant at top of file
2. Add version endpoint for verification
3. Deploy to production with verification

**Implementation**:
```javascript
// At top of functions/index.js
const FUNCTIONS_VERSION = '2.1.0';
const DEPLOYED_AT = new Date().toISOString();

console.log('🚀 [INIT] Cloud Functions Version:', FUNCTIONS_VERSION);
console.log('🚀 [INIT] Deployed At:', DEPLOYED_AT);

// Add version endpoint
exports.getFunctionsVersion = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    return {
      version: FUNCTIONS_VERSION,
      deployedAt: DEPLOYED_AT,
      databaseId: db._settings?.databaseId || 'NOT_SET',
      hasDatabaseConfigFix: true,
      timestamp: new Date().toISOString(),
    };
  });
```

**Deployment Steps**:
```bash
# 1. Verify local changes
cd functions
npm install
npm run lint

# 2. Deploy to production
firebase deploy --only functions

# 3. Verify deployment
firebase functions:log --only getFunctionsVersion

# 4. Test from Flutter app
# Call getFunctionsVersion and verify version matches
```

#### Fix 2: Ensure AppointmentId Consistency (Hypothesis 2)

**Changes Required:**

**File**: `lib/shared/models/appointment_model.dart`

**Specific Changes**:
1. Add explicit Firestore document ID mapping in `fromJson`
2. Add validation to ensure ID consistency

**Implementation**:
```dart
// Modify fromJson factory constructor
factory AppointmentModel.fromJson(Map<String, dynamic> json, {String? documentId}) {
  // Use documentId if provided, otherwise fall back to json['id']
  final id = documentId ?? json['id'] as String;
  
  // Validate ID consistency
  if (documentId != null && json['id'] != null && documentId != json['id']) {
    debugPrint('⚠️ [ID MISMATCH] Document ID ($documentId) != JSON ID (${json['id']})');
    debugPrint('⚠️ [ID MISMATCH] Using document ID as source of truth');
  }
  
  return AppointmentModel(
    id: id, // Use validated ID
    // ... rest of fields
  );
}
```

**File**: Repository files that query appointments

**Specific Changes**:
1. Pass Firestore document ID to `fromJson`
2. Add logging to verify ID consistency

**Implementation**:
```dart
// In appointment repository implementations
Future<List<AppointmentModel>> getAppointments() async {
  final snapshot = await _firestore
    .collection('appointments')
    .where('doctorId', isEqualTo: doctorId)
    .get();
  
  return snapshot.docs.map((doc) {
    // Pass document ID explicitly
    final appointment = AppointmentModel.fromJson(
      doc.data(),
      documentId: doc.id, // Ensure ID matches Firestore document ID
    );
    
    // Verify consistency
    if (kDebugMode) {
      debugPrint('📄 [APPOINTMENT] Firestore doc.id: ${doc.id}');
      debugPrint('📄 [APPOINTMENT] Model id: ${appointment.id}');
      assert(doc.id == appointment.id, 'AppointmentId mismatch!');
    }
    
    return appointment;
  }).toList();
}
```

#### Fix 3: Unconditional Database Configuration (Hypothesis 3 & 5)

**Changes Required:**

**File**: `functions/index.js`

**Specific Changes**:
1. Remove conditional check for database configuration
2. Apply configuration unconditionally
3. Add comprehensive verification logging

**Implementation**:
```javascript
const db = admin.firestore();

// ✅ UNCONDITIONAL DATABASE CONFIGURATION
// ===========================================
// Previous approach used conditional logic that could fail in edge cases.
// New approach: ALWAYS apply database configuration, no conditions.
//
// Why unconditional?
// - Ensures configuration is applied regardless of initial state
// - Prevents edge cases where condition evaluates incorrectly
// - Makes behavior predictable and debuggable
//
// Safety: db.settings() can only be called once. If already configured,
// it will throw an error which we catch and log.

console.log('🔧 [DB CONFIG] Applying database configuration...');
console.log('🔧 [DB CONFIG] Initial state:', {
  hasSettings: !!db._settings,
  databaseId: db._settings?.databaseId || 'NOT_SET',
});

try {
  // Apply configuration unconditionally
  db.settings({ databaseId: 'elajtech' });
  console.log('✅ [DB CONFIG] Database configuration applied successfully');
} catch (error) {
  // If settings already applied, this is expected in some environments
  console.log('⚠️ [DB CONFIG] Settings already applied (expected in some environments)');
  console.log('⚠️ [DB CONFIG] Error:', error.message);
}

// Verify final configuration
const finalDatabaseId = db._settings?.databaseId;
console.log('🔧 [DB CONFIG] Final state:', {
  hasSettings: !!db._settings,
  databaseId: finalDatabaseId || 'NOT_SET',
});

// Critical validation
if (finalDatabaseId !== 'elajtech') {
  console.error('❌ [CRITICAL] Database configuration FAILED!');
  console.error('❌ [CRITICAL] Expected: elajtech, Got:', finalDatabaseId || 'NOT_SET');
  console.error('❌ [CRITICAL] All Firestore queries will target WRONG database!');
  
  // Throw error to prevent function deployment with wrong configuration
  throw new Error(`Database configuration failed: expected 'elajtech', got '${finalDatabaseId || 'NOT_SET'}'`);
} else {
  console.log('✅ [DB CONFIG] Verified: All queries will target elajtech database');
}
```

#### Fix 4: Prevent Multiple Firestore Instances (Hypothesis 4)

**Changes Required:**

**File**: `functions/index.js`

**Specific Changes**:
1. Ensure single Firestore instance is used throughout
2. Add safeguards against accidental instance creation
3. Export configured instance for testing

**Implementation**:
```javascript
// At top of file, after admin initialization
const db = admin.firestore();

// Apply database configuration
db.settings({ databaseId: 'elajtech' });

// ✅ PREVENT MULTIPLE INSTANCES
// ===========================================
// Freeze the db instance to prevent accidental reassignment
Object.freeze(db);

// Add helper to prevent direct admin.firestore() calls
const originalFirestore = admin.firestore;
admin.firestore = function() {
  console.warn('⚠️ [WARNING] Direct admin.firestore() call detected!');
  console.warn('⚠️ [WARNING] Use the configured db instance instead');
  console.trace('⚠️ [WARNING] Call stack:');
  return db; // Return configured instance
};

console.log('✅ [INSTANCE] Single Firestore instance configured and protected');
```


### Enhanced Logging and Monitoring

To prevent future occurrences and enable rapid diagnosis, implement comprehensive logging:

#### Logging Enhancement 1: Call Initiation Tracking

**Implementation**:
```javascript
// In startAgoraCall function, add comprehensive logging
exports.startAgoraCall = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    const requestId = Math.random().toString(36).substring(7);
    const startTime = Date.now();
    
    console.log(`🎬 [${requestId}] Call initiation started`);
    console.log(`🎬 [${requestId}] Request data:`, JSON.stringify({
      appointmentId: data.appointmentId,
      doctorId: data.doctorId,
      hasDeviceInfo: !!data.deviceInfo,
    }));
    console.log(`🎬 [${requestId}] Database config:`, {
      databaseId: db._settings?.databaseId || 'NOT_SET',
      instanceId: DB_INSTANCE_ID,
    });
    
    try {
      // ... existing code ...
      
      // Before Firestore query
      console.log(`🔍 [${requestId}] Querying appointment:`, {
        collection: 'appointments',
        documentId: appointmentId,
        databaseId: db._settings?.databaseId,
      });
      
      const appointmentRef = db.collection('appointments').doc(appointmentId);
      const appointmentDoc = await appointmentRef.get();
      
      console.log(`🔍 [${requestId}] Query result:`, {
        exists: appointmentDoc.exists,
        documentId: appointmentDoc.id,
        hasData: !!appointmentDoc.data(),
      });
      
      if (!appointmentDoc.exists) {
        // Enhanced error logging
        console.error(`❌ [${requestId}] Appointment not found - Diagnostic info:`);
        console.error(`❌ [${requestId}] - Requested ID: ${appointmentId}`);
        console.error(`❌ [${requestId}] - Database queried: ${db._settings?.databaseId}`);
        console.error(`❌ [${requestId}] - Collection: appointments`);
        console.error(`❌ [${requestId}] - Query path: ${appointmentRef.path}`);
        
        // Query similar appointments for debugging
        const similarAppointments = await db.collection('appointments')
          .where('doctorId', '==', doctorId)
          .limit(5)
          .get();
        
        console.error(`❌ [${requestId}] - Found ${similarAppointments.size} appointments for doctor`);
        similarAppointments.forEach(doc => {
          console.error(`❌ [${requestId}] - Existing appointment: ${doc.id}`);
        });
        
        // Log to call_logs with enhanced metadata
        await logCallEvent({
          eventType: 'call_error',
          appointmentId: appointmentId,
          userId: doctorId,
          errorCode: 'appointment_not_found',
          errorMessage: `[DB: ${db._settings?.databaseId}] Appointment not found`,
          metadata: {
            requestId: requestId,
            databaseId: db._settings?.databaseId || 'NOT_SET',
            queriedCollection: 'appointments',
            queriedDocumentId: appointmentId,
            queriedPath: appointmentRef.path,
            similarAppointmentsCount: similarAppointments.size,
            functionsVersion: FUNCTIONS_VERSION,
          },
        });
        
        throw new functions.https.HttpsError(
          'not-found',
          `[DB: ${db._settings?.databaseId}] الموعد غير موجود في قاعدة البيانات`
        );
      }
      
      // Success logging
      const duration = Date.now() - startTime;
      console.log(`✅ [${requestId}] Call initiated successfully in ${duration}ms`);
      
      return result;
      
    } catch (error) {
      const duration = Date.now() - startTime;
      console.error(`❌ [${requestId}] Call initiation failed after ${duration}ms:`, error);
      throw error;
    }
  });
```

#### Logging Enhancement 2: Database Query Interceptor

**Implementation**:
```javascript
// Add query interceptor for debugging
function createQueryInterceptor(db) {
  const originalCollection = db.collection.bind(db);
  
  db.collection = function(collectionPath) {
    console.log(`🔍 [QUERY] Collection access: ${collectionPath}`);
    console.log(`🔍 [QUERY] Database: ${db._settings?.databaseId || 'NOT_SET'}`);
    
    const collectionRef = originalCollection(collectionPath);
    
    // Intercept doc() calls
    const originalDoc = collectionRef.doc.bind(collectionRef);
    collectionRef.doc = function(documentId) {
      console.log(`🔍 [QUERY] Document access: ${collectionPath}/${documentId}`);
      return originalDoc(documentId);
    };
    
    return collectionRef;
  };
  
  return db;
}

// Apply interceptor in debug mode
if (process.env.FUNCTIONS_EMULATOR === 'true' || process.env.DEBUG_QUERIES === 'true') {
  createQueryInterceptor(db);
  console.log('🔍 [DEBUG] Query interceptor enabled');
}
```

#### Logging Enhancement 3: Monitoring Dashboard Data

**Implementation**:
```javascript
// Add monitoring metrics collection
async function recordCallMetrics(data) {
  try {
    await db.collection('call_metrics').add({
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      date: new Date().toISOString().split('T')[0], // YYYY-MM-DD
      hour: new Date().getHours(),
      ...data,
    });
  } catch (error) {
    console.error('❌ Error recording metrics:', error);
  }
}

// Use in startAgoraCall
await recordCallMetrics({
  eventType: 'call_attempt',
  appointmentId: appointmentId,
  doctorId: doctorId,
  success: true,
  databaseId: db._settings?.databaseId,
  functionsVersion: FUNCTIONS_VERSION,
});
```


## Testing Strategy

### Validation Approach

The testing strategy follows a three-phase approach:
1. **Exploratory Phase**: Surface counterexamples on unfixed code to confirm root cause
2. **Fix Validation Phase**: Verify fixes resolve the issue
3. **Preservation Phase**: Ensure existing functionality remains unchanged

### Exploratory Fault Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing fixes. Confirm or refute each root cause hypothesis.

**Test Plan**: Create diagnostic tests that run against the current (unfixed) code to identify which hypothesis is correct.

**Test Cases**:

1. **Deployment Verification Test** (Hypothesis 1)
   ```dart
   test('verify deployed functions version includes database config fix', () async {
     final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
     final result = await functions.httpsCallable('getFunctionsVersion').call();
     
     expect(result.data['hasDatabaseConfigFix'], true);
     expect(result.data['databaseId'], 'elajtech');
     
     // If this fails, Hypothesis 1 is confirmed
   });
   ```

2. **AppointmentId Consistency Test** (Hypothesis 2)
   ```dart
   test('verify appointmentId matches Firestore document ID', () async {
     // Create test appointment
     final testAppointmentId = 'test_apt_${DateTime.now().millisecondsSinceEpoch}';
     
     await firestore.collection('appointments').doc(testAppointmentId).set({
       'id': testAppointmentId,
       'doctorId': 'test_doctor',
       'patientId': 'test_patient',
       // ... other fields
     });
     
     // Retrieve via repository
     final appointment = await appointmentRepository.getAppointment(testAppointmentId);
     
     // Verify IDs match
     expect(appointment.id, testAppointmentId);
     
     // Verify can be queried from Cloud Functions
     final doc = await firestore.collection('appointments').doc(appointment.id).get();
     expect(doc.exists, true);
     
     // If this fails, Hypothesis 2 is confirmed
   });
   ```

3. **Database Configuration Runtime Test** (Hypothesis 3 & 5)
   ```javascript
   // In functions test file
   describe('Database Configuration', () => {
     it('should configure elajtech database at initialization', () => {
       const db = admin.firestore();
       
       expect(db._settings).toBeDefined();
       expect(db._settings.databaseId).toBe('elajtech');
       
       // If this fails, Hypothesis 3 or 5 is confirmed
     });
     
     it('should query elajtech database for appointments', async () => {
       const testAppointmentId = 'test_apt_123';
       
       // Create appointment in elajtech database
       await db.collection('appointments').doc(testAppointmentId).set({
         doctorId: 'test_doctor',
         patientId: 'test_patient',
       });
       
       // Query should find it
       const doc = await db.collection('appointments').doc(testAppointmentId).get();
       expect(doc.exists).toBe(true);
       
       // If this fails, database configuration is ineffective
     });
   });
   ```

4. **Multiple Instance Detection Test** (Hypothesis 4)
   ```javascript
   describe('Firestore Instance Management', () => {
     it('should use single configured instance', () => {
       const db1 = admin.firestore();
       const db2 = admin.firestore();
       
       // Should return same instance
       expect(db1).toBe(db2);
       expect(db1._settings.databaseId).toBe('elajtech');
       expect(db2._settings.databaseId).toBe('elajtech');
       
       // If this fails, Hypothesis 4 is confirmed
     });
   });
   ```

**Expected Counterexamples**:
- Hypothesis 1: `getFunctionsVersion` returns old version or wrong databaseId
- Hypothesis 2: AppointmentId from Flutter doesn't match Firestore document ID
- Hypothesis 3: Database configuration not applied at runtime
- Hypothesis 4: Multiple Firestore instances with different configurations
- Hypothesis 5: Conditional logic prevents configuration from being applied

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed function produces the expected behavior.

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition(input) DO
  result := startAgoraCall_fixed(input)
  ASSERT expectedBehavior(result)
END FOR
```

**Test Cases**:

1. **Call Initiation Success Test**
   ```dart
   test('startAgoraCall succeeds with valid appointmentId', () async {
     // Create test appointment
     final appointment = await createTestAppointment();
     
     // Attempt to start call
     final result = await VideoConsultationService().startVideoCall(
       appointmentId: appointment.id,
       doctorId: appointment.doctorId,
     );
     
     // Verify success
     expect(result.success, true);
     expect(result.agoraToken, isNotNull);
     expect(result.agoraChannelName, isNotNull);
     expect(result.agoraUid, isNotNull);
   });
   ```

2. **Database Query Verification Test**
   ```javascript
   describe('startAgoraCall - Fixed', () => {
     it('should query elajtech database for appointment', async () => {
       const testAppointmentId = 'test_apt_456';
       
       // Create appointment in elajtech database
       await db.collection('appointments').doc(testAppointmentId).set({
         doctorId: 'test_doctor',
         patientId: 'test_patient',
         doctorName: 'Dr. Test',
         patientName: 'Test Patient',
       });
       
       // Call startAgoraCall
       const result = await startAgoraCall({
         appointmentId: testAppointmentId,
         doctorId: 'test_doctor',
       }, { auth: { uid: 'test_doctor' } });
       
       // Verify success
       expect(result.success).toBe(true);
       expect(result.agoraToken).toBeDefined();
     });
   });
   ```

3. **AppointmentId Consistency Test**
   ```dart
   test('appointmentId from Flutter matches Cloud Functions query', () async {
     final appointment = await createTestAppointment();
     
     // Verify Flutter can retrieve it
     final flutterAppointment = await appointmentRepository.getAppointment(appointment.id);
     expect(flutterAppointment.id, appointment.id);
     
     // Verify Cloud Functions can retrieve it
     final result = await VideoConsultationService().startVideoCall(
       appointmentId: flutterAppointment.id,
       doctorId: flutterAppointment.doctorId,
     );
     
     expect(result.success, true);
   });
   ```


### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL input WHERE NOT isBugCondition(input) DO
  ASSERT startAgoraCall_original(input) = startAgoraCall_fixed(input)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all non-buggy inputs

**Test Plan**: Verify that existing functionality continues to work after fixes are applied.

**Test Cases**:

1. **Appointment Listing Preservation**
   ```dart
   test('appointment listing continues to work after fix', () async {
     // Create multiple test appointments
     final appointments = await createMultipleTestAppointments(count: 10);
     
     // Retrieve via repository
     final retrieved = await appointmentRepository.getDoctorAppointments(doctorId);
     
     // Verify all appointments retrieved
     expect(retrieved.length, appointments.length);
     
     // Verify IDs match
     for (final appointment in appointments) {
       expect(retrieved.any((a) => a.id == appointment.id), true);
     }
   });
   ```

2. **Other Cloud Functions Preservation**
   ```javascript
   describe('Other Cloud Functions - Preservation', () => {
     it('endAgoraCall continues to work', async () => {
       const testAppointmentId = 'test_apt_789';
       
       // Create appointment
       await db.collection('appointments').doc(testAppointmentId).set({
         doctorId: 'test_doctor',
         callStartedAt: admin.firestore.FieldValue.serverTimestamp(),
       });
       
       // End call
       const result = await endAgoraCall({
         appointmentId: testAppointmentId,
       }, { auth: { uid: 'test_doctor' } });
       
       expect(result.success).toBe(true);
       
       // Verify callEndedAt was set
       const doc = await db.collection('appointments').doc(testAppointmentId).get();
       expect(doc.data().callEndedAt).toBeDefined();
     });
     
     it('completeAppointment continues to work', async () => {
       const testAppointmentId = 'test_apt_101';
       
       // Create appointment
       await db.collection('appointments').doc(testAppointmentId).set({
         doctorId: 'test_doctor',
         status: 'scheduled',
       });
       
       // Complete appointment
       const result = await completeAppointment({
         appointmentId: testAppointmentId,
         doctorId: 'test_doctor',
       }, { auth: { uid: 'test_doctor' } });
       
       expect(result.success).toBe(true);
       
       // Verify status changed
       const doc = await db.collection('appointments').doc(testAppointmentId).get();
       expect(doc.data().status).toBe('completed');
     });
   });
   ```

3. **Flutter App Queries Preservation**
   ```dart
   test('Flutter Firestore queries continue to work', () async {
     final firestore = FirebaseFirestore.instanceFor(
       app: Firebase.app(),
       databaseId: 'elajtech',
     );
     
     // Create test appointment
     final testAppointmentId = 'test_apt_202';
     await firestore.collection('appointments').doc(testAppointmentId).set({
       'id': testAppointmentId,
       'doctorId': 'test_doctor',
       'patientId': 'test_patient',
       'status': 'scheduled',
     });
     
     // Query via Flutter
     final doc = await firestore.collection('appointments').doc(testAppointmentId).get();
     
     expect(doc.exists, true);
     expect(doc.data()!['id'], testAppointmentId);
   });
   ```

4. **Call Logs Preservation**
   ```javascript
   describe('Call Logs - Preservation', () => {
     it('call logs continue to be written to elajtech database', async () => {
       await logCallEvent({
         eventType: 'test_event',
         appointmentId: 'test_apt_303',
         userId: 'test_user',
       });
       
       // Verify log was written
       const logs = await db.collection('call_logs')
         .where('appointmentId', '==', 'test_apt_303')
         .limit(1)
         .get();
       
       expect(logs.size).toBe(1);
       expect(logs.docs[0].data().eventType).toBe('test_event');
     });
   });
   ```

5. **Existing Tests Preservation**
   ```bash
   # Run all existing tests to ensure no regressions
   flutter test
   
   # Verify all 664+ tests still pass
   # Expected: 0 failures
   ```

### Unit Tests

- Test database configuration is applied correctly at initialization
- Test appointmentId consistency between Flutter and Cloud Functions
- Test Firestore queries target correct database
- Test error handling for invalid appointmentIds
- Test logging captures diagnostic information
- Test version endpoint returns correct information

### Property-Based Tests

- Generate random appointmentIds and verify they can be queried consistently
- Generate random appointment data and verify it can be created and retrieved
- Generate random doctor/patient combinations and verify call initiation works
- Test that all non-call-initiation operations continue to work across many scenarios

### Integration Tests

- Test full call flow: create appointment → start call → end call → complete appointment
- Test call flow with real Firestore database (emulator)
- Test error scenarios: invalid appointmentId, missing appointment, wrong doctor
- Test concurrent call initiations
- Test call initiation after deployment


## Deployment Plan

### Pre-Deployment Checklist

- [ ] All diagnostic tests pass and identify root cause
- [ ] Appropriate fixes implemented based on diagnostic results
- [ ] All unit tests pass (664+ tests)
- [ ] Integration tests pass
- [ ] Code review completed
- [ ] Documentation updated (CHANGELOG.md, API_DOCUMENTATION.md)
- [ ] Rollback plan prepared
- [ ] Monitoring dashboard ready
- [ ] Stakeholders notified of deployment window

### Deployment Strategy

**Approach**: Phased deployment with verification at each stage

#### Phase 1: Diagnostic Deployment (Day 1)

**Objective**: Deploy diagnostic code to identify root cause in production

**Steps**:
1. Deploy diagnostic version of Cloud Functions
   ```bash
   cd functions
   firebase deploy --only functions
   ```

2. Monitor logs for diagnostic output
   ```bash
   firebase functions:log --only startAgoraCall
   ```

3. Request doctors to attempt call initiation
4. Analyze logs to confirm root cause hypothesis
5. Document findings

**Success Criteria**:
- Diagnostic logs captured successfully
- Root cause hypothesis confirmed or refuted
- No impact on existing functionality

**Rollback Trigger**:
- Diagnostic code causes errors
- Existing functionality breaks

#### Phase 2: Fix Deployment (Day 2-3)

**Objective**: Deploy fixes based on confirmed root cause

**Steps**:
1. Implement fixes based on diagnostic results
2. Run all tests locally
   ```bash
   flutter test
   cd functions && npm test
   ```

3. Deploy to staging environment (if available)
4. Test in staging:
   - Create test appointment
   - Attempt call initiation
   - Verify success
   - Check logs

5. Deploy to production
   ```bash
   firebase deploy --only functions
   ```

6. Verify deployment
   ```bash
   # Check functions version
   firebase functions:log --only getFunctionsVersion
   
   # Monitor startAgoraCall logs
   firebase functions:log --only startAgoraCall
   ```

7. Request doctors to test call initiation
8. Monitor error rates in call_logs collection

**Success Criteria**:
- Call initiation success rate ≥95%
- No "Appointment Not Found" errors in logs
- All existing tests pass
- Doctors report successful call initiations

**Rollback Trigger**:
- Call initiation success rate <80%
- New errors introduced
- Existing functionality breaks
- Critical bugs reported

#### Phase 3: Monitoring and Validation (Day 4-7)

**Objective**: Monitor production for 48-72 hours to ensure stability

**Steps**:
1. Monitor call_logs collection for errors
   ```javascript
   // Query error logs
   db.collection('call_logs')
     .where('eventType', '==', 'call_error')
     .where('timestamp', '>=', deploymentTimestamp)
     .orderBy('timestamp', 'desc')
     .limit(100)
   ```

2. Track success metrics:
   - Call initiation success rate
   - Average call initiation time
   - Error rate by error code
   - Affected doctors/appointments

3. Collect doctor feedback
4. Review Cloud Functions logs daily
5. Generate deployment report

**Success Criteria**:
- Call initiation success rate ≥95% for 48 hours
- Error rate <5% of total call attempts
- No critical bugs reported
- Positive doctor feedback

**Rollback Trigger**:
- Success rate drops below 80%
- Critical bugs discovered
- Data integrity issues

### Rollback Procedure

If rollback is needed:

1. **Immediate Rollback** (< 5 minutes)
   ```bash
   # Revert to previous Cloud Functions version
   firebase functions:rollback startAgoraCall
   ```

2. **Verify Rollback**
   ```bash
   # Check functions version
   firebase functions:log --only getFunctionsVersion
   
   # Verify old version is active
   ```

3. **Notify Stakeholders**
   - Inform development team
   - Notify doctors of temporary issue
   - Update status page

4. **Post-Rollback Analysis**
   - Review logs to identify rollback cause
   - Document issues encountered
   - Plan corrective actions
   - Schedule new deployment

### Post-Deployment Monitoring

**Metrics to Track**:

1. **Call Initiation Success Rate**
   ```javascript
   // Query call_logs for success rate
   const totalAttempts = await db.collection('call_logs')
     .where('eventType', '==', 'call_attempt')
     .where('timestamp', '>=', deploymentTimestamp)
     .count()
     .get();
   
   const successfulCalls = await db.collection('call_logs')
     .where('eventType', '==', 'call_started')
     .where('timestamp', '>=', deploymentTimestamp)
     .count()
     .get();
   
   const successRate = (successfulCalls / totalAttempts) * 100;
   ```

2. **Error Distribution**
   ```javascript
   // Query error types
   const errors = await db.collection('call_logs')
     .where('eventType', '==', 'call_error')
     .where('timestamp', '>=', deploymentTimestamp)
     .get();
   
   const errorCounts = {};
   errors.forEach(doc => {
     const errorCode = doc.data().errorCode;
     errorCounts[errorCode] = (errorCounts[errorCode] || 0) + 1;
   });
   ```

3. **Performance Metrics**
   - Average call initiation time
   - Cloud Functions execution time
   - Firestore query latency

4. **User Impact**
   - Number of affected doctors
   - Number of affected appointments
   - User-reported issues

**Monitoring Dashboard**:

Create a monitoring dashboard to track:
- Real-time call initiation success rate
- Error rate trends
- Most common error codes
- Affected users
- Performance metrics

**Alert Thresholds**:
- Success rate drops below 90%: Warning
- Success rate drops below 80%: Critical
- Error rate exceeds 10%: Warning
- Error rate exceeds 20%: Critical
- New error code appears: Warning

### Communication Plan

**Before Deployment**:
- Notify development team of deployment schedule
- Inform doctors of potential brief service interruption
- Prepare status page update

**During Deployment**:
- Post status update: "Maintenance in progress"
- Monitor team chat for issues
- Be ready for immediate rollback

**After Deployment**:
- Post status update: "Deployment complete"
- Send summary email to stakeholders
- Request doctor feedback
- Schedule follow-up review meeting

**If Issues Occur**:
- Immediate notification to development team
- Status page update with issue description
- Regular updates every 30 minutes
- Post-mortem after resolution


## Risk Assessment

### High-Risk Areas

1. **Database Configuration Changes**
   - **Risk**: Incorrect configuration could cause all Firestore queries to fail
   - **Mitigation**: Comprehensive testing in staging, immediate rollback capability
   - **Detection**: Monitor error rates, verify database configuration at startup

2. **AppointmentId Format Changes**
   - **Risk**: Changing ID format could break existing appointments
   - **Mitigation**: Backward compatibility, gradual migration if needed
   - **Detection**: Test with existing appointments, verify ID consistency

3. **Cloud Functions Deployment**
   - **Risk**: Deployment could fail or introduce new errors
   - **Mitigation**: Phased deployment, rollback plan, staging environment testing
   - **Detection**: Deployment verification, version endpoint, log monitoring

4. **Breaking Existing Functionality**
   - **Risk**: Fixes could inadvertently break other features
   - **Mitigation**: Comprehensive test suite, preservation testing
   - **Detection**: Run all 664+ tests, monitor error logs

### Medium-Risk Areas

1. **Logging Overhead**
   - **Risk**: Excessive logging could impact performance
   - **Mitigation**: Use conditional logging, optimize log statements
   - **Detection**: Monitor Cloud Functions execution time

2. **Conditional Logic Changes**
   - **Risk**: Removing conditional checks could cause issues in edge cases
   - **Mitigation**: Thorough testing of edge cases, error handling
   - **Detection**: Unit tests, integration tests

3. **Multiple Deployments**
   - **Risk**: Multiple deployments could cause confusion or inconsistency
   - **Mitigation**: Clear versioning, deployment tracking
   - **Detection**: Version endpoint, deployment logs

### Low-Risk Areas

1. **Documentation Updates**
   - **Risk**: Minimal - documentation changes don't affect functionality
   - **Mitigation**: Review for accuracy
   - **Detection**: Manual review

2. **Test Additions**
   - **Risk**: Minimal - new tests don't affect production code
   - **Mitigation**: Ensure tests are correct and don't have side effects
   - **Detection**: Test execution, code review

## Success Metrics

### Primary Metrics

1. **Call Initiation Success Rate**: ≥95%
   - Measured over 48-hour period post-deployment
   - Calculated from call_logs collection

2. **"Appointment Not Found" Error Rate**: <5%
   - Measured as percentage of total call attempts
   - Should approach 0% for valid appointments

3. **Database Query Verification**: 100%
   - All Firestore queries target 'elajtech' database
   - Verified through logging and monitoring

### Secondary Metrics

1. **AppointmentId Consistency**: 100%
   - All appointmentIds from Flutter match Firestore document IDs
   - Verified through logging and testing

2. **Deployment Verification**: 100%
   - Deployed version matches repository version
   - Database configuration present and active

3. **Test Pass Rate**: 100%
   - All 664+ existing tests continue to pass
   - No regressions introduced

4. **User Satisfaction**: Positive feedback from doctors
   - No complaints about call initiation failures
   - Successful call initiations reported

### Monitoring Period

- **Initial**: 48 hours of intensive monitoring
- **Extended**: 7 days of regular monitoring
- **Long-term**: Ongoing monitoring via dashboard

### Acceptance Criteria

The bugfix is considered successful when ALL of the following are met:

1. ✅ Call initiation success rate ≥95% for 48 consecutive hours
2. ✅ "Appointment Not Found" error rate <5% of total attempts
3. ✅ Database configuration verified in production (databaseId = 'elajtech')
4. ✅ AppointmentId consistency verified (Flutter IDs match Firestore IDs)
5. ✅ All 664+ existing tests pass without modifications
6. ✅ No critical bugs reported by doctors
7. ✅ No regressions in existing functionality
8. ✅ Deployment verified (correct version active in production)

## Appendix

### A. Diagnostic Queries

**Query 1: Recent Call Errors**
```javascript
db.collection('call_logs')
  .where('eventType', '==', 'call_error')
  .where('errorCode', '==', 'appointment_not_found')
  .orderBy('timestamp', 'desc')
  .limit(50)
  .get()
```

**Query 2: Success Rate by Hour**
```javascript
// Group by hour and calculate success rate
const metrics = await db.collection('call_metrics')
  .where('date', '==', '2024-02-16')
  .orderBy('hour')
  .get();

const hourlyStats = {};
metrics.forEach(doc => {
  const data = doc.data();
  const hour = data.hour;
  if (!hourlyStats[hour]) {
    hourlyStats[hour] = { attempts: 0, successes: 0 };
  }
  hourlyStats[hour].attempts++;
  if (data.success) hourlyStats[hour].successes++;
});
```

**Query 3: Affected Appointments**
```javascript
db.collection('call_logs')
  .where('eventType', '==', 'call_error')
  .where('errorCode', '==', 'appointment_not_found')
  .where('timestamp', '>=', startDate)
  .get()
  .then(snapshot => {
    const appointmentIds = new Set();
    snapshot.forEach(doc => {
      appointmentIds.add(doc.data().appointmentId);
    });
    return Array.from(appointmentIds);
  })
```

### B. Useful Commands

**Deploy Cloud Functions**
```bash
cd functions
firebase deploy --only functions
```

**View Real-Time Logs**
```bash
firebase functions:log --only startAgoraCall
```

**Rollback to Previous Version**
```bash
firebase functions:rollback startAgoraCall
```

**Test Cloud Functions Locally**
```bash
cd functions
npm test
```

**Run Flutter Tests**
```bash
flutter test
flutter test --coverage
```

### C. Contact Information

**Development Team**:
- Lead Developer: [Contact Info]
- Backend Engineer: [Contact Info]
- QA Engineer: [Contact Info]

**Escalation Path**:
1. Development Team Lead
2. Technical Manager
3. CTO

**Emergency Contact**: [Emergency Contact Info]

---

**Document Version**: 1.0.0  
**Last Updated**: 2024-02-16  
**Author**: AndroCare360 Development Team  
**Status**: Ready for Implementation

