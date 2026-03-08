# Design Document: VoIP Appointment Not Found Bugfix

## Overview

This design document specifies the technical solution for fixing the "Appointment Not Found" error in the AndroCare360 VoIP system. The bug occurs because the Firebase Admin SDK in Cloud Functions does not consistently apply the `databaseId` configuration to Firestore queries, causing the system to query the default database instead of the 'elajtech' database.

### Problem Statement

When doctors click "Start Video Call", the `startAgoraCall` Cloud Function queries `db.collection('appointments').doc(appointmentId)`, which incorrectly queries the default Firestore database instead of the 'elajtech' database, despite `admin.initializeApp({ databaseId: 'elajtech' })` being called during initialization.

### Solution Approach

Apply explicit database settings to the Firestore instance after initialization to ensure all subsequent queries target the 'elajtech' database. This is a one-line fix that resolves the issue without requiring changes to the Flutter application or database structure.

## Architecture

### Current Architecture (Buggy)

```
┌─────────────────────────────────────────────────────────────┐
│ Cloud Functions (functions/index.js)                        │
│                                                              │
│  admin.initializeApp({ databaseId: 'elajtech' })           │
│  const db = admin.firestore()                               │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ startAgoraCall()                                    │    │
│  │   db.collection('appointments').doc(id)            │    │
│  │   ❌ Queries DEFAULT database (not 'elajtech')     │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ endAgoraCall()                                      │    │
│  │   db.collection('appointments').doc(id)            │    │
│  │   ❌ Queries DEFAULT database (not 'elajtech')     │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ completeAppointment()                               │    │
│  │   db.collection('appointments').doc(id)            │    │
│  │   ❌ Queries DEFAULT database (not 'elajtech')     │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### Fixed Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Cloud Functions (functions/index.js)                        │
│                                                              │
│  admin.initializeApp({ databaseId: 'elajtech' })           │
│  const db = admin.firestore()                               │
│  db.settings({ databaseId: 'elajtech' })  ✅ FIX           │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ startAgoraCall()                                    │    │
│  │   db.collection('appointments').doc(id)            │    │
│  │   ✅ Queries 'elajtech' database                   │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ endAgoraCall()                                      │    │
│  │   db.collection('appointments').doc(id)            │    │
│  │   ✅ Queries 'elajtech' database                   │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ completeAppointment()                               │    │
│  │   db.collection('appointments').doc(id)            │    │
│  │   ✅ Queries 'elajtech' database                   │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### Modified Component: Database Initialization

**File**: `functions/index.js` (Lines 5-10)

**Current Implementation**:
```javascript
admin.initializeApp({
  databaseId: 'elajtech',
});

const db = admin.firestore();
```

**Fixed Implementation**:
```javascript
admin.initializeApp({
  databaseId: 'elajtech',
});

const db = admin.firestore();
// ✅ CRITICAL: Explicitly set database ID to prevent default database fallback
// This ensures ALL Firestore queries target the 'elajtech' database
db.settings({ databaseId: 'elajtech' });
```

### Affected Functions

All three Cloud Functions are affected by this bug, but no changes are required to their logic:

1. **startAgoraCall** (Line 113)
   - Queries: `db.collection('appointments').doc(appointmentId)`
   - Will now correctly query 'elajtech' database

2. **endAgoraCall** (Line 368)
   - Queries: `db.collection('appointments').doc(appointmentId)`
   - Will now correctly query 'elajtech' database

3. **completeAppointment** (Line 413)
   - Queries: `db.collection('appointments').doc(appointmentId)`
   - Will now correctly query 'elajtech' database

4. **logCallEvent** (Line 64)
   - Writes to: `db.collection('call_logs')`
   - Will now correctly write to 'elajtech' database

5. **sendVoIPNotification** (Line 321)
   - Queries: `db.collection('users').doc(patientId)`
   - Will now correctly query 'elajtech' database

### Interface Contracts (Unchanged)

All function signatures and response formats remain unchanged:

**startAgoraCall**:
```typescript
Request: {
  appointmentId: string,
  doctorId: string,
  deviceInfo?: object
}

Response: {
  success: boolean,
  message: string,
  agoraChannelName: string,
  agoraToken: string,
  agoraUid: number
}
```

**endAgoraCall**:
```typescript
Request: {
  appointmentId: string
}

Response: {
  success: boolean,
  message: string
}
```

**completeAppointment**:
```typescript
Request: {
  appointmentId: string,
  doctorId: string
}

Response: {
  success: boolean,
  message: string
}
```

## Data Models

No changes to data models. All Firestore document structures remain unchanged:

### Appointment Document
```typescript
{
  id: string,
  doctorId: string,
  patientId: string,
  doctorName: string,
  status: 'scheduled' | 'on_call' | 'completed',
  agoraChannelName?: string,
  agoraToken?: string,
  agoraUid?: number,
  doctorAgoraToken?: string,
  doctorAgoraUid?: number,
  meetingProvider?: 'agora',
  callStartedAt?: Timestamp,
  callEndedAt?: Timestamp,
  completedAt?: Timestamp
}
```

### Call Log Document
```typescript
{
  id: string,
  eventType: 'call_attempt' | 'call_started' | 'call_error' | 'call_ended',
  appointmentId: string,
  userId: string,
  timestamp: Timestamp,
  errorCode?: string,
  errorMessage?: string,
  stackTrace?: string,
  deviceInfo?: object,
  metadata?: object
}
```

### User Document
```typescript
{
  id: string,
  fcmToken?: string,
  // ... other fields
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Database Configuration Consistency

*For any* Firestore operation in Cloud Functions, the operation should target the 'elajtech' database, not the default database.

**Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5**

### Property 2: Appointment Retrieval Success

*For any* existing appointment in the 'elajtech' database, when startAgoraCall is invoked with that appointmentId, the function should successfully retrieve the appointment document.

**Validates: Requirements 2.2, 2.5**

### Property 3: Token Generation Success

*For any* valid appointment retrieved from the database, the function should successfully generate Agora tokens for both doctor and patient without errors.

**Validates: Requirements 2.3, 2.4**

### Property 4: Notification Delivery

*For any* patient with a valid FCM token, when startAgoraCall completes successfully, the patient should receive a VoIP notification with correct call data.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4**

### Property 5: Call Logging Consistency

*For any* call event (attempt, started, error, ended), the event should be logged to the 'call_logs' collection in the 'elajtech' database with complete metadata.

**Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5**

### Property 6: Backward Compatibility

*For any* existing Flutter application code that calls Cloud Functions, the code should continue to work without modifications after the fix is deployed.

**Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5**

### Property 7: Error Message Clarity

*For any* database-related error, the error message should clearly indicate which database was queried and provide guidance for correct configuration.

**Validates: Requirements 8.1, 8.2, 8.3, 8.4**

## Error Handling

### Current Error Handling (Preserved)

The existing error handling logic is comprehensive and will be preserved:

1. **Authentication Errors**: Checked via `context.auth`
2. **Input Validation**: Validates required parameters
3. **Permission Checks**: Verifies doctorId matches appointment
4. **Not Found Errors**: Throws when appointment doesn't exist
5. **Token Generation Errors**: Catches and logs Agora token failures
6. **Firestore Update Errors**: Catches and logs database write failures
7. **Notification Errors**: Logs but doesn't fail the call

### Enhanced Error Messages

After the fix, error messages will be more accurate:

**Before Fix**:
```javascript
throw new functions.https.HttpsError(
  'not-found',
  'الموعد غير موجود'
);
// Misleading: appointment exists in 'elajtech' but not in default database
```

**After Fix**:
```javascript
throw new functions.https.HttpsError(
  'not-found',
  'الموعد غير موجود'
);
// Accurate: appointment truly doesn't exist in 'elajtech' database
```

### Error Logging Enhancement

Add database context to error logs:

```javascript
await logCallEvent({
  eventType: 'call_error',
  appointmentId: appointmentId,
  userId: doctorId,
  errorCode: 'appointment_not_found',
  errorMessage: 'الموعد غير موجود في قاعدة البيانات elajtech',
  metadata: {
    databaseId: 'elajtech',
    queriedCollection: 'appointments',
  },
  deviceInfo: deviceInfo || null,
});
```

## Testing Strategy

### Unit Tests

**Test File**: `functions/test/index.test.js` (to be created)

1. **Test Database Configuration**
   - Verify `db.settings()` is called with correct databaseId
   - Verify Firestore instance targets 'elajtech' database
   - Mock Firestore and verify collection references

2. **Test startAgoraCall Function**
   - Mock appointment document in 'elajtech' database
   - Verify function retrieves appointment successfully
   - Verify tokens are generated correctly
   - Verify appointment is updated with call data
   - Verify call logs are written to 'elajtech' database

3. **Test endAgoraCall Function**
   - Mock appointment document
   - Verify callEndedAt timestamp is set
   - Verify update targets 'elajtech' database

4. **Test completeAppointment Function**
   - Mock appointment document
   - Verify status is updated to 'completed'
   - Verify completedAt timestamp is set
   - Verify update targets 'elajtech' database

### Integration Tests

**Test File**: `functions/test/integration.test.js` (to be created)

1. **End-to-End Call Flow**
   - Create test appointment in Firebase Emulator ('elajtech' database)
   - Call startAgoraCall with test appointmentId
   - Verify appointment is retrieved from 'elajtech' database
   - Verify tokens are generated
   - Verify appointment is updated
   - Verify call logs are created in 'elajtech' database
   - Call endAgoraCall
   - Verify callEndedAt is set
   - Call completeAppointment
   - Verify status is 'completed'

2. **Database Isolation Test**
   - Create appointment in default database
   - Create different appointment in 'elajtech' database
   - Call startAgoraCall with 'elajtech' appointmentId
   - Verify function retrieves from 'elajtech', not default
   - Verify no cross-database contamination

### Firebase Emulator Configuration

**File**: `functions/test/setup.js` (to be created)

```javascript
const admin = require('firebase-admin');

// Initialize Firebase Admin for testing
admin.initializeApp({
  projectId: 'elajtech-test',
  databaseId: 'elajtech',
});

// Connect to Firestore Emulator
const db = admin.firestore();
db.settings({
  host: 'localhost:8080',
  ssl: false,
  databaseId: 'elajtech',
});

// Connect to Auth Emulator
process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';

// Connect to Functions Emulator
process.env.FUNCTIONS_EMULATOR = 'true';
```

### Manual Testing Checklist

1. **Deploy Cloud Functions**
   ```bash
   cd functions
   firebase deploy --only functions
   ```

2. **Test Doctor Call Initiation**
   - Login as doctor in Flutter app
   - Navigate to appointment details
   - Click "Start Video Call" button
   - Verify no "Appointment Not Found" error
   - Verify Agora channel is joined successfully

3. **Test Patient Notification**
   - Verify patient receives VoIP notification
   - Verify notification displays doctor name
   - Verify patient can accept call
   - Verify patient joins Agora channel

4. **Test Call Logging**
   - Check Firestore 'call_logs' collection in 'elajtech' database
   - Verify 'call_attempt' event is logged
   - Verify 'call_started' event is logged
   - Verify events include correct appointmentId and userId

5. **Test Call Completion**
   - End call from either doctor or patient side
   - Verify callEndedAt timestamp is set
   - Doctor clicks "Complete Appointment"
   - Verify status changes to 'completed'
   - Verify completedAt timestamp is set

### Test Coverage Requirements

- **Unit Tests**: 100% coverage of modified code (database initialization)
- **Integration Tests**: Cover all three Cloud Functions
- **Manual Tests**: Full doctor-to-patient call flow
- **Regression Tests**: All 627+ existing tests must pass

### Property-Based Testing

**Test Configuration**: Minimum 100 iterations per property test

**Property Test 1: Database Configuration**
```javascript
// Feature: voip-appointment-not-found-bugfix, Property 1: Database Configuration Consistency
test('database configuration targets elajtech for all operations', () => {
  // Generate random collection names
  const collections = ['appointments', 'users', 'call_logs'];
  
  for (let i = 0; i < 100; i++) {
    const collection = collections[Math.floor(Math.random() * collections.length)];
    const ref = db.collection(collection);
    
    // Verify collection reference targets 'elajtech' database
    expect(ref._settings.databaseId).toBe('elajtech');
  }
});
```

**Property Test 2: Appointment Retrieval**
```javascript
// Feature: voip-appointment-not-found-bugfix, Property 2: Appointment Retrieval Success
test('startAgoraCall retrieves existing appointments from elajtech', async () => {
  for (let i = 0; i < 100; i++) {
    // Generate random appointment
    const appointmentId = `test_apt_${i}`;
    const doctorId = `doctor_${i}`;
    const patientId = `patient_${i}`;
    
    // Create appointment in 'elajtech' database
    await db.collection('appointments').doc(appointmentId).set({
      doctorId,
      patientId,
      doctorName: `Doctor ${i}`,
      status: 'scheduled',
    });
    
    // Call startAgoraCall
    const result = await startAgoraCall({
      appointmentId,
      doctorId,
    }, { auth: { uid: doctorId } });
    
    // Verify success
    expect(result.success).toBe(true);
    expect(result.agoraChannelName).toBeDefined();
    expect(result.agoraToken).toBeDefined();
  }
});
```

## Deployment Plan

### Pre-Deployment Checklist

- [ ] Code changes reviewed and approved
- [ ] Unit tests written and passing
- [ ] Integration tests written and passing
- [ ] Manual testing completed successfully
- [ ] All 627+ existing tests passing
- [ ] Documentation updated

### Deployment Steps

1. **Backup Current Functions**
   ```bash
   # Download current function code
   firebase functions:config:get > functions/.runtimeconfig.json.backup
   ```

2. **Deploy to Staging (if available)**
   ```bash
   firebase use elajtech-staging
   cd functions
   npm install
   firebase deploy --only functions
   ```

3. **Test in Staging**
   - Run full manual test suite
   - Verify call logs in staging database
   - Verify no errors in Cloud Functions logs

4. **Deploy to Production**
   ```bash
   firebase use elajtech
   cd functions
   npm install
   firebase deploy --only functions
   ```

5. **Monitor Deployment**
   ```bash
   # Watch real-time logs
   firebase functions:log --only startAgoraCall
   ```

6. **Verify Production**
   - Test doctor call initiation
   - Check call_logs collection
   - Monitor error rates in Firebase Console

### Rollback Plan

If issues are detected after deployment:

1. **Immediate Rollback**
   ```bash
   # Revert to previous version
   firebase functions:delete startAgoraCall
   firebase functions:delete endAgoraCall
   firebase functions:delete completeAppointment
   
   # Redeploy from backup
   git checkout <previous-commit>
   firebase deploy --only functions
   ```

2. **Verify Rollback**
   - Test call initiation
   - Check error logs
   - Notify team of rollback

### Post-Deployment Monitoring

Monitor these metrics for 24 hours after deployment:

1. **Error Rate**: Should decrease to near zero for "Appointment Not Found" errors
2. **Call Success Rate**: Should increase to >95%
3. **Call Logs**: Verify 'call_started' events are being logged
4. **User Reports**: Monitor support tickets for call-related issues

## Documentation Updates

### Files to Update

1. **API_DOCUMENTATION.md**
   - Add note about database configuration fix
   - Update troubleshooting section

2. **CHANGELOG.md**
   - Add entry for bugfix release
   - Document the database configuration issue and fix

3. **functions/README.md** (to be created)
   - Document database configuration requirement
   - Add setup instructions for new developers
   - Include testing instructions

### Code Comments

Add comprehensive comments to the fixed code:

```javascript
// ✅ CRITICAL DATABASE CONFIGURATION
// The Firebase Admin SDK requires explicit database settings to ensure
// all Firestore queries target the 'elajtech' database instead of the
// default database. Without this line, queries will fail with
// "Appointment Not Found" errors even when appointments exist.
//
// This is a known issue with the Admin SDK where the databaseId in
// initializeApp() doesn't always propagate to Firestore operations.
//
// Reference: https://github.com/firebase/firebase-admin-node/issues/...
db.settings({ databaseId: 'elajtech' });
```

## Risk Assessment

### Low Risk

- **Code Change**: Single line addition, no logic changes
- **Backward Compatibility**: No breaking changes to API contracts
- **Testing**: Comprehensive test coverage ensures correctness
- **Rollback**: Simple and fast if issues arise

### Mitigation Strategies

1. **Gradual Rollout**: Deploy to staging first, then production
2. **Monitoring**: Real-time log monitoring during deployment
3. **Quick Rollback**: Prepared rollback procedure
4. **Communication**: Notify team before deployment

## Future Enhancements

1. **Automated Database Configuration Validation**
   - Add startup check to verify database configuration
   - Log warning if default database is being used

2. **Enhanced Error Messages**
   - Include database ID in all error messages
   - Add troubleshooting links to error responses

3. **Database Configuration Utility**
   - Create helper function for database initialization
   - Centralize database configuration logic

4. **Monitoring Dashboard**
   - Track database query patterns
   - Alert on default database usage
   - Monitor call success rates by database
