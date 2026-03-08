# Requirements Document: VoIP Appointment Not Found Bugfix

## Introduction

This document specifies the requirements for fixing a critical bug in the AndroCare360 VoIP system where doctors receive an "Appointment Not Found" error when initiating video calls, despite the appointments existing in the Firestore database. The root cause has been identified as incorrect database reference configuration in the Cloud Functions implementation.

## Glossary

- **Cloud_Functions**: Firebase Cloud Functions (v2) deployed in europe-west1 region that handle backend operations
- **Firestore**: Cloud Firestore NoSQL database service
- **Elajtech_Database**: The custom Firestore database with ID 'elajtech' used by AndroCare360
- **Default_Database**: The default Firestore database that is incorrectly queried by the current implementation
- **Admin_SDK**: Firebase Admin SDK for Node.js used in Cloud Functions
- **VoIP_System**: Voice over IP system using flutter_callkit_incoming for native call UI
- **Agora_Token**: JWT token required to join Agora video channels (1-hour expiration)
- **Call_Logs**: Firestore collection that stores call monitoring events
- **Doctor**: Healthcare professional user who initiates video consultations
- **Patient**: User receiving healthcare consultation
- **Appointment**: Scheduled consultation session between doctor and patient

## Requirements

### Requirement 1: Database Reference Correction

**User Story:** As a system administrator, I want Cloud Functions to query the correct Firestore database, so that appointment lookups succeed consistently.

#### Acceptance Criteria

1. WHEN the startAgoraCall function is invoked, THE Cloud_Functions SHALL query the Elajtech_Database for appointment documents
2. WHEN the endAgoraCall function is invoked, THE Cloud_Functions SHALL update appointment documents in the Elajtech_Database
3. WHEN the completeAppointment function is invoked, THE Cloud_Functions SHALL update appointment documents in the Elajtech_Database
4. THE Admin_SDK SHALL be configured with explicit database settings to prevent default database fallback
5. FOR ALL Firestore operations in Cloud Functions, THE database reference SHALL explicitly target the Elajtech_Database

### Requirement 2: Video Call Initiation Success

**User Story:** As a doctor, I want to successfully start video calls by clicking the call button, so that I can conduct patient consultations without errors.

#### Acceptance Criteria

1. WHEN a Doctor clicks the "Start Video Call" button, THE VoIP_System SHALL invoke the startAgoraCall Cloud Function
2. WHEN the startAgoraCall function queries for an appointment, THE function SHALL find the appointment document in the Elajtech_Database
3. WHEN the appointment is found, THE function SHALL generate Agora_Tokens for both doctor and patient
4. WHEN tokens are generated, THE function SHALL return agoraToken, agoraChannelName, and agoraUid to the Doctor
5. WHEN the function completes successfully, THE function SHALL NOT return "Appointment Not Found" errors for existing appointments

### Requirement 3: Patient Notification Delivery

**User Story:** As a patient, I want to receive incoming call notifications when my doctor starts a video call, so that I can join the consultation promptly.

#### Acceptance Criteria

1. WHEN the startAgoraCall function successfully retrieves the appointment, THE function SHALL retrieve the Patient's FCM token from the Elajtech_Database
2. WHEN the FCM token is retrieved, THE function SHALL send a high-priority VoIP notification to the Patient
3. WHEN the notification is sent, THE notification payload SHALL include agoraToken, agoraChannelName, and doctor information
4. WHEN the Patient's device receives the notification, THE VoIP_System SHALL display native incoming call UI (CallKit on iOS, ConnectionService on Android)

### Requirement 4: Call Monitoring and Logging

**User Story:** As a system administrator, I want all call events to be logged correctly, so that I can monitor system health and debug issues.

#### Acceptance Criteria

1. WHEN a Doctor initiates a call, THE Cloud_Functions SHALL log a call_attempt event to the Call_Logs collection in the Elajtech_Database
2. WHEN the appointment is successfully retrieved, THE Cloud_Functions SHALL log a call_started event to the Call_Logs collection
3. WHEN any error occurs during call initiation, THE Cloud_Functions SHALL log a call_error event with error details
4. FOR ALL log entries, THE system SHALL include appointmentId, userId, timestamp, and deviceInfo
5. THE Call_Logs collection SHALL be written to the Elajtech_Database, not the Default_Database

### Requirement 5: Backward Compatibility

**User Story:** As a developer, I want the bugfix to maintain compatibility with existing code, so that no other features are broken by the change.

#### Acceptance Criteria

1. WHEN the database configuration is updated, THE Flutter application code SHALL continue to work without modifications
2. WHEN the Cloud Functions are redeployed, THE existing API contracts SHALL remain unchanged
3. WHEN the fix is deployed, ALL existing unit tests SHALL continue to pass (627+ tests)
4. THE function signatures for startAgoraCall, endAgoraCall, and completeAppointment SHALL remain unchanged
5. THE response formats from all Cloud Functions SHALL remain unchanged

### Requirement 6: Database Configuration Verification

**User Story:** As a developer, I want to verify that database configuration is correct, so that I can prevent similar issues in the future.

#### Acceptance Criteria

1. THE Admin_SDK initialization SHALL explicitly set databaseId to 'elajtech'
2. THE Firestore instance SHALL have explicit database settings applied after initialization
3. WHEN creating collection references, THE code SHALL use the correctly configured Firestore instance
4. THE implementation SHALL follow one of the recommended patterns: explicit settings, explicit database reference, or per-collection specification
5. THE code SHALL include comments documenting the database configuration requirement

### Requirement 7: Testing and Validation

**User Story:** As a quality assurance engineer, I want comprehensive tests for the database configuration, so that I can ensure the bug is fixed and won't regress.

#### Acceptance Criteria

1. THE test suite SHALL include unit tests verifying Cloud Functions query the Elajtech_Database
2. THE test suite SHALL include integration tests for the complete call initiation flow
3. WHEN tests are executed, THE tests SHALL use Firebase Emulator with the Elajtech_Database configured
4. WHEN the fix is deployed, THE manual testing SHALL verify doctor-to-patient call flow succeeds
5. THE verification SHALL include checking Call_Logs collection for successful call_started events

### Requirement 8: Error Handling Improvement

**User Story:** As a developer, I want improved error messages when database issues occur, so that I can diagnose problems more quickly.

#### Acceptance Criteria

1. WHEN an appointment is not found, THE error message SHALL indicate which database was queried
2. WHEN database configuration is incorrect, THE error message SHALL provide guidance on correct configuration
3. WHEN logging errors, THE system SHALL include the database ID in the error context
4. THE error messages SHALL distinguish between "appointment not found in correct database" and "querying wrong database"

## Special Requirements Guidance

### Database Configuration Pattern

The Cloud Functions implementation must use one of these verified patterns:

**Pattern 1 (Recommended)**: Explicit database settings
```javascript
admin.initializeApp({
  databaseId: 'elajtech',
});

const db = admin.firestore();
db.settings({ databaseId: 'elajtech' });
```

**Pattern 2**: Explicit database reference
```javascript
const db = admin.app().firestore('elajtech');
```

**Pattern 3**: Per-collection specification
```javascript
const appointmentRef = admin.firestore()
  .collection('databases/elajtech/documents/appointments')
  .doc(appointmentId);
```

### Critical Testing Requirements

- All changes must maintain the 627+ existing test pass rate
- Integration tests must verify end-to-end call flow
- Manual testing must confirm patient receives VoIP notification
- Call logs must be verified in the correct database

### Deployment Considerations

- Cloud Functions must be redeployed to europe-west1 region
- No changes required to Flutter application
- No database migration required
- Zero downtime deployment possible
