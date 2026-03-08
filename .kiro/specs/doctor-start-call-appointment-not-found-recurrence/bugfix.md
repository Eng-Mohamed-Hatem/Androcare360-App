# Bugfix Requirements Document: Doctor Start Call "Appointment Not Found" Recurrence

## Introduction

This document specifies the requirements for fixing a recurring "Appointment Not Found" error that occurs when doctors attempt to initiate video calls in the AndroCare360 platform. Despite a previous fix (voip-appointment-not-found-bugfix) that added explicit database configuration (`db.settings({ databaseId: 'elajtech' })`), doctors are still experiencing this error.

### Bug Impact

- **Severity**: Critical - Blocks core video consultation functionality
- **Affected Users**: All doctors attempting to start video calls
- **Business Impact**: Prevents doctors from conducting video consultations, directly impacting patient care
- **Frequency**: Reported by multiple doctors, suggesting systematic issue

### Previous Fix Context

On 2026-02-13, a fix was implemented that added `db.settings({ databaseId: 'elajtech' })` to the Cloud Functions initialization code. This fix was intended to ensure all Firestore queries target the 'elajtech' database instead of the default database. The fix is still present in the codebase (functions/index.js, lines 40-41), yet the error persists.

## Bug Analysis

### Current Behavior (Defect)

The following behaviors represent the defective state of the system:

1.1 WHEN a doctor clicks the "Start Call" button in the appointments screen THEN the system displays an "Appointment Not Found" error message

1.2 WHEN the `startAgoraCall` Cloud Function is invoked with a valid appointmentId THEN the function fails to retrieve the appointment document from Firestore

1.3 WHEN the error occurs THEN the patient does not receive a VoIP notification

1.4 WHEN the error occurs THEN no Agora tokens are generated for the video call

1.5 WHEN the error is logged to `call_logs` collection THEN the log entry shows event type 'call_error' with error code 'appointment_not_found'

1.6 WHEN the Flutter app passes `widget.appointment.id` to `startVideoCall` THEN the appointmentId may not match the actual Firestore document ID

1.7 WHEN the Cloud Functions are deployed THEN the database configuration fix may not be active in the deployed version

1.8 WHEN the `startAgoraCall` function queries Firestore THEN it may be querying the wrong database despite the configuration fix

### Expected Behavior (Correct)

The following behaviors represent the correct, desired state of the system:

2.1 WHEN a doctor clicks the "Start Call" button with a valid appointment THEN the system SHALL successfully retrieve the appointment document from the 'elajtech' database

2.2 WHEN the `startAgoraCall` Cloud Function is invoked THEN the function SHALL query the 'elajtech' database using the exact appointmentId provided by the Flutter app

2.3 WHEN the appointment is found THEN the system SHALL generate valid Agora tokens for both doctor and patient

2.4 WHEN tokens are generated THEN the system SHALL update the appointment document with call metadata (agoraChannelName, agoraToken, doctorAgoraToken, callStartedAt)

2.5 WHEN the appointment is updated THEN the system SHALL send a VoIP notification to the patient with the call details

2.6 WHEN the call initiation succeeds THEN the system SHALL log a 'call_started' event to the call_logs collection

2.7 WHEN the Flutter app retrieves an appointment from Firestore THEN the appointment.id field SHALL exactly match the Firestore document ID

2.8 WHEN Cloud Functions are deployed THEN the deployed version SHALL include the database configuration fix (`db.settings({ databaseId: 'elajtech' })`)

2.9 WHEN any Firestore query is executed in Cloud Functions THEN the query SHALL target the 'elajtech' database, not the default database

2.10 WHEN an error occurs during call initiation THEN the error message SHALL include diagnostic information (appointmentId, doctorId, database queried, collection queried)

### Unchanged Behavior (Regression Prevention)

The following behaviors must remain unchanged to prevent regressions:

3.1 WHEN a doctor views the appointments list THEN the system SHALL CONTINUE TO display all scheduled appointments correctly

3.2 WHEN an appointment document is created in Firestore THEN the system SHALL CONTINUE TO use the 'elajtech' database

3.3 WHEN the Flutter app queries appointments THEN the system SHALL CONTINUE TO use `FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'elajtech')`

3.4 WHEN the `endAgoraCall` function is invoked THEN the system SHALL CONTINUE TO update the appointment in the 'elajtech' database

3.5 WHEN the `completeAppointment` function is invoked THEN the system SHALL CONTINUE TO update the appointment status in the 'elajtech' database

3.6 WHEN call logs are written THEN the system SHALL CONTINUE TO write to the 'call_logs' collection in the 'elajtech' database

3.7 WHEN patient FCM tokens are retrieved THEN the system SHALL CONTINUE TO query the 'users' collection in the 'elajtech' database

3.8 WHEN the video call UI is displayed THEN the system SHALL CONTINUE TO show doctor and patient information correctly

3.9 WHEN existing unit tests are run THEN all 664+ tests SHALL CONTINUE TO pass without modifications

3.10 WHEN the Flutter app is built THEN the system SHALL CONTINUE TO compile without errors or deprecated API warnings

## Bug Condition Analysis

### Bug Condition Function

The bug condition identifies inputs that trigger the "Appointment Not Found" error:

```pascal
FUNCTION isBugCondition(X)
  INPUT: X of type CallInitiationRequest
  OUTPUT: boolean
  
  // X contains: appointmentId, doctorId, deployedFunctionsVersion, firestoreDocumentId
  
  // Bug occurs when ANY of these conditions are true:
  RETURN (
    // Condition 1: AppointmentId mismatch
    (X.appointmentId ≠ X.firestoreDocumentId) OR
    
    // Condition 2: Database configuration not applied in deployed version
    (X.deployedFunctionsVersion.hasDatabaseConfigFix = false) OR
    
    // Condition 3: Database configuration applied but not effective
    (X.deployedFunctionsVersion.hasDatabaseConfigFix = true AND 
     X.actualDatabaseQueried ≠ 'elajtech') OR
    
    // Condition 4: Appointment exists in default database but not in elajtech
    (X.appointmentExistsInDefaultDB = true AND 
     X.appointmentExistsInElajtechDB = false)
  )
END FUNCTION
```

### Property Specification: Fix Checking

The property defines correct behavior for buggy inputs (inputs that currently trigger the error):

```pascal
// Property: Fix Checking - Appointment Retrieval Success
FOR ALL X WHERE isBugCondition(X) DO
  result ← startAgoraCall'(X)
  
  ASSERT (
    // Fix 1: AppointmentId must match Firestore document ID
    (X.appointmentId = X.firestoreDocumentId) AND
    
    // Fix 2: Database configuration must be deployed and active
    (X.deployedFunctionsVersion.hasDatabaseConfigFix = true) AND
    
    // Fix 3: Queries must target elajtech database
    (X.actualDatabaseQueried = 'elajtech') AND
    
    // Fix 4: Appointment must exist in elajtech database
    (X.appointmentExistsInElajtechDB = true) AND
    
    // Fix 5: Call initiation succeeds
    (result.success = true) AND
    (result.agoraToken ≠ null) AND
    (result.agoraChannelName ≠ null) AND
    
    // Fix 6: No "Appointment Not Found" error
    (result.error ≠ 'appointment_not_found')
  )
END FOR
```

### Preservation Goal

Ensure that for all non-buggy inputs (successful call initiations), the fixed code behaves identically to the original:

```pascal
// Property: Preservation Checking
FOR ALL X WHERE NOT isBugCondition(X) DO
  // F = original function, F' = fixed function
  ASSERT startAgoraCall(X) = startAgoraCall'(X)
END FOR
```

This ensures that appointments that currently work correctly continue to work after the fix is applied.

## Root Cause Hypotheses

Based on the bug analysis, the following are potential root causes:

### Hypothesis 1: Deployment Issue
The database configuration fix exists in the codebase but was not deployed to production. The deployed Cloud Functions may be running an older version without the fix.

**Validation**: Check Firebase Functions deployment history and compare deployed code with repository code.

### Hypothesis 2: AppointmentId Mismatch
The `appointment.id` field in the Flutter app does not match the actual Firestore document ID. This could occur if:
- The appointment model uses a different field for the ID
- The ID is transformed during serialization/deserialization
- The UI displays a different ID than what's stored in Firestore

**Validation**: Log both `widget.appointment.id` and the actual Firestore document ID, compare them.

### Hypothesis 3: Database Configuration Ineffective
The `db.settings({ databaseId: 'elajtech' })` call is present but not effective due to:
- Timing issue (called too late in initialization)
- Overridden by subsequent configuration
- Firebase Admin SDK version issue

**Validation**: Add logging to verify which database is actually being queried at runtime.

### Hypothesis 4: Multiple Firestore Instances
The code creates multiple Firestore instances, and some queries use an instance without the database configuration.

**Validation**: Search for all `admin.firestore()` calls and verify they all use the configured instance.

### Hypothesis 5: Conditional Configuration Logic
The database configuration has conditional logic (`if (!db._settings || !db._settings.databaseId)`) that may prevent it from being applied in certain scenarios.

**Validation**: Review the conditional logic and test in production environment.

## Investigation Requirements

To identify the root cause, the following investigations are required:

### Investigation 1: Verify Deployed Functions Version
- Check Firebase Console for last deployment timestamp
- Compare deployed functions code with repository code
- Verify the database configuration fix is present in deployed version

### Investigation 2: Trace AppointmentId Flow
- Add debug logging in Flutter app to log `widget.appointment.id`
- Add debug logging in Cloud Functions to log received `appointmentId`
- Query Firestore directly to verify document ID format
- Compare all three values to identify mismatches

### Investigation 3: Verify Database Configuration at Runtime
- Add logging in Cloud Functions to log `db._settings.databaseId` before each query
- Add logging to show which database is actually being queried
- Check Cloud Functions logs for these diagnostic messages

### Investigation 4: Review Recent Call Logs
- Query `call_logs` collection for recent 'call_error' events
- Extract appointmentId values from error logs
- Manually verify if these appointments exist in Firestore
- Check which database (default vs elajtech) contains these appointments

### Investigation 5: Test in Staging Environment
- Deploy current code to staging environment
- Attempt to start a video call
- Monitor logs in real-time
- Verify database queries target 'elajtech'

## Success Criteria

The bug is considered fixed when ALL of the following criteria are met:

1. **Call Initiation Success Rate**: ≥95% of doctor-initiated calls succeed without "Appointment Not Found" errors
2. **Database Query Verification**: 100% of Firestore queries in Cloud Functions target the 'elajtech' database
3. **AppointmentId Consistency**: 100% of appointmentIds passed from Flutter match Firestore document IDs
4. **Deployment Verification**: Deployed Cloud Functions version includes all fixes
5. **Error Log Reduction**: 'call_error' events with 'appointment_not_found' reduced to <5% of total call attempts
6. **Regression Prevention**: All 664+ existing tests continue to pass
7. **User Validation**: Doctors can successfully initiate video calls without errors for 48 hours post-deployment

## Constraints

- **No Breaking Changes**: The fix must not break existing functionality or API contracts
- **Backward Compatibility**: Flutter app must continue to work with fixed Cloud Functions
- **Zero Downtime**: Deployment must not cause service interruption
- **Test Coverage**: All fixes must be covered by automated tests
- **Documentation**: All changes must be documented in code comments and CHANGELOG.md
