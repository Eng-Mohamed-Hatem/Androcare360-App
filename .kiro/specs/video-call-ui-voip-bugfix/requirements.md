# Requirements Document: Video Call UI and VoIP Notification Critical Bugfixes

## Introduction

This document defines the requirements for fixing two critical bugs discovered during VoIP testing (Scenario 1.1 execution on 2026-02-16, 11:36 PM). These bugs block the core video consultation functionality and must be resolved with highest priority before testing can proceed.

**Bug Discovery Context:**
- **Test Scenario**: Scenario 1.1 - Doctor initiates video call to patient
- **Discovery Date**: 2026-02-16, 11:36 PM
- **Impact**: CRITICAL - Blocks core video consultation functionality
- **Evidence**: Screenshot_20260216_230858.jpg showing incorrect UI text

## Glossary

- **Video_Call_Screen**: The UI screen displayed during an active video consultation (AgoraVideoCallScreen)
- **VoIP_System**: The voice-over-IP call system integrating iOS CallKit and Android ConnectionService
- **FCM**: Firebase Cloud Messaging - push notification service
- **Caller**: The user who initiates the video call (typically the doctor)
- **Callee**: The user who receives the incoming call (typically the patient)
- **CallKit**: iOS native framework for displaying incoming call UI
- **ConnectionService**: Android native framework for displaying incoming call UI
- **Agora_Service**: Service managing Agora RTC Engine for video/audio streaming
- **Cloud_Functions**: Firebase Cloud Functions handling call initiation and FCM notifications


## Requirements

### Requirement 1: Differentiate UI Text Based on User Role

**User Story:** As a doctor initiating a video call, I want to see appropriate waiting messages that indicate I'm calling the patient, so that I understand the call status correctly.

#### Acceptance Criteria

1. WHEN a doctor initiates a video call and the patient has not yet joined, THE Video_Call_Screen SHALL display "جاري الاتصال بالمريض..." (Calling patient...)
2. WHEN a doctor initiates a video call and the patient has not yet joined, THE Video_Call_Screen SHALL display "في انتظار رد [patient name]..." (Waiting for [patient name] to answer...)
3. WHEN a patient receives an incoming call and the doctor is already in the channel, THE Video_Call_Screen SHALL display "جاري الاتصال بالطبيب..." (Calling doctor...)
4. WHEN a patient receives an incoming call and the doctor is already in the channel, THE Video_Call_Screen SHALL display "يرجى الانتظار، سيتم الاتصال بك قريباً" (Please wait, you will be called soon)
5. THE Video_Call_Screen SHALL determine user role by checking if the current user is the doctor or patient in the appointment
6. THE Video_Call_Screen SHALL use the appointment's doctorId and patientId fields to determine the current user's role

### Requirement 2: Deliver VoIP Notifications to Patient Device

**User Story:** As a patient, I want to receive an incoming call notification when the doctor initiates a video call, so that I can accept or decline the call.

#### Acceptance Criteria

1. WHEN a doctor calls startAgoraCall Cloud Function, THE Cloud_Functions SHALL retrieve the patient's FCM token from the users collection in the elajtech database
2. WHEN the patient's FCM token is retrieved successfully, THE Cloud_Functions SHALL send a high-priority FCM notification with type 'incoming_call'
3. WHEN the FCM notification is sent, THE notification payload SHALL include appointmentId, doctorName, agoraChannelName, agoraToken, and agoraUid
4. WHEN the patient's device receives the FCM notification, THE FCM_Service SHALL extract the notification data and call VoIPCallService.showIncomingCall()
5. WHEN VoIPCallService.showIncomingCall() is called, THE VoIP_System SHALL display the native incoming call UI (CallKit on iOS, ConnectionService on Android)
6. WHEN the patient accepts the call from the native UI, THE VoIP_System SHALL navigate to the Video_Call_Screen with the appointment data
7. IF the patient's FCM token is missing or null, THE Cloud_Functions SHALL log an error event to call_logs collection with errorCode 'fcm_token_missing'
8. IF the FCM notification fails to send, THE Cloud_Functions SHALL log an error event to call_logs collection with errorCode 'voip_notification_failed'
9. THE Cloud_Functions SHALL explicitly set database configuration using db.settings({ databaseId: 'elajtech' }) after Firestore initialization
10. THE Cloud_Functions SHALL verify all Firestore queries target the 'elajtech' database, not the default database
11. THE error logs SHALL include database context metadata with databaseId field set to 'elajtech'

### Requirement 3: Verify FCM Token Storage

**User Story:** As a system administrator, I want to ensure all users have valid FCM tokens stored in Firestore, so that VoIP notifications can be delivered reliably.

#### Acceptance Criteria

1. WHEN a user signs in to the app, THE FCM_Service SHALL request an FCM token from Firebase Messaging
2. WHEN an FCM token is received, THE FCM_Service SHALL save the token to the user's document in the users collection (field: fcmToken)
3. WHEN the FCM token is refreshed, THE FCM_Service SHALL update the user's document with the new token
4. THE users collection document SHALL include an fcmToken field of type string
5. THE users collection document SHALL include an fcmTokenUpdatedAt field of type timestamp
6. WHEN saving the FCM token, THE FCM_Service SHALL use the elajtech database ID
7. THE FCM_Service SHALL use FirebaseFirestore.instanceFor with databaseId 'elajtech' when updating user documents
8. THE FCM_Service SHALL NEVER use FirebaseFirestore.instance directly
9. THE fcmToken update operation SHALL use FieldValue.serverTimestamp() for accurate timestamps

### Requirement 4: Handle VoIP Notification Failures Gracefully

**User Story:** As a doctor, I want to be notified if the patient cannot be reached via VoIP notification, so that I can take alternative action.

#### Acceptance Criteria

1. WHEN the Cloud_Functions fails to retrieve the patient's FCM token, THE Cloud_Functions SHALL log the error but SHALL NOT throw an exception
2. WHEN the Cloud_Functions fails to send the FCM notification, THE Cloud_Functions SHALL log the error but SHALL NOT throw an exception
3. WHEN a VoIP notification failure occurs, THE Cloud_Functions SHALL return success to the doctor (call was initiated successfully)
4. WHEN a VoIP notification failure occurs, THE Cloud_Functions SHALL log a call_error event with detailed error information
5. THE doctor's Video_Call_Screen SHALL display a timeout message if the patient does not join within 60 seconds
6. WHEN the timeout occurs, THE Video_Call_Screen SHALL provide an option to retry or cancel the call
7. THE Video_Call_Screen SHALL implement a 60-second timeout counter starting from call initiation
8. THE Video_Call_Screen SHALL allow maximum 3 retry attempts with exponential backoff (2s, 4s, 8s delays)
9. THE Video_Call_Screen SHALL log timeout events to call_logs collection with eventType 'call_timeout'
10. THE retry mechanism SHALL re-request Agora tokens from Cloud Functions for each retry attempt

### Requirement 5: Log All VoIP Notification Events

**User Story:** As a system administrator, I want comprehensive logging of all VoIP notification events, so that I can debug delivery issues.

#### Acceptance Criteria

1. WHEN the Cloud_Functions retrieves the patient's FCM token, THE Cloud_Functions SHALL log the token retrieval status (success or failure)
2. WHEN the Cloud_Functions sends an FCM notification, THE Cloud_Functions SHALL log the notification payload and send status
3. WHEN the patient's device receives an FCM notification, THE FCM_Service SHALL log the notification receipt with timestamp
4. WHEN VoIPCallService.showIncomingCall() is called, THE VoIP_System SHALL log the call display event
5. WHEN the patient accepts or declines the call, THE VoIP_System SHALL log the user action
6. ALL VoIP-related logs SHALL include the appointmentId, userId, and timestamp
7. ALL VoIP-related logs SHALL be written to the call_logs collection in the elajtech database

### Requirement 6: Test VoIP Notification Delivery End-to-End

**User Story:** As a QA engineer, I want to verify that VoIP notifications are delivered correctly in all scenarios, so that I can ensure the system works reliably.

#### Acceptance Criteria

1. WHEN testing VoIP notifications, THE test SHALL verify that the patient's FCM token exists in Firestore
2. WHEN testing VoIP notifications, THE test SHALL verify that the Cloud Function sends the FCM notification successfully
3. WHEN testing VoIP notifications, THE test SHALL verify that the patient's device receives the notification
4. WHEN testing VoIP notifications, THE test SHALL verify that the native call UI appears on the patient's device
5. WHEN testing VoIP notifications, THE test SHALL verify that accepting the call navigates to the Video_Call_Screen
6. THE test SHALL cover both iOS (CallKit) and Android (ConnectionService) platforms
7. THE test SHALL cover scenarios where the app is in foreground, background, and terminated states
8. THE test SHALL verify that Cloud Functions use databaseId 'elajtech' for all Firestore operations
9. THE test SHALL verify that FCM tokens are retrieved from the correct database by querying users collection with databaseId 'elajtech'
10. THE test SHALL cover token refresh scenarios when fcmToken expires
11. THE test SHALL verify logging of all VoIP events to call_logs collection in elajtech database
12. THE test SHALL verify database isolation by attempting to query default database and confirming failure

### Requirement 7: Configure Environment Variables for Cloud Functions

**User Story:** As a system administrator, I want Cloud Functions to securely use environment variables for Agora credentials, so that sensitive credentials are not exposed in code.

#### Acceptance Criteria

1. THE Cloud_Functions SHALL load Agora credentials from `.env` file using process.env.AGORA_APP_ID and process.env.AGORA_APP_CERTIFICATE
2. THE `.env` file SHALL be created from `.env.example` template during setup
3. IF `.env` variables are missing, THE Cloud_Functions SHALL fallback to legacy functions.config() for backward compatibility
4. THE error logs SHALL include "[DB: elajtech]" prefix in all error messages for debugging
5. THE Cloud_Functions SHALL validate environment variables on startup and throw descriptive errors if missing
6. THE `.env` file SHALL be excluded from version control via .gitignore
7. THE production deployment SHALL use Firebase Functions Secrets (firebase functions:secrets:set) instead of .env files

#### Implementation Notes

**Local Development:**
```bash
cd functions
cp .env.example .env
# Edit .env and add credentials
npm test -- env-config.test.js
```

**Production Deployment:**
```bash
firebase functions:secrets:set AGORA_APP_ID
firebase functions:secrets:set AGORA_APP_CERTIFICATE
```

**Reference:** See `functions/README.md` for complete environment configuration documentation.

### Requirement 8: Documentation Updates

**User Story:** As a developer, I want comprehensive documentation updates for these bugfixes, so that future developers understand the changes and can troubleshoot issues.

#### Acceptance Criteria

1. THE API_DOCUMENTATION.md SHALL include a new troubleshooting section for VoIP notification delivery issues
2. THE CHANGELOG.md SHALL document these bugfixes under version [Unreleased] with detailed description
3. THE README.md VoIP Call System section SHALL be updated to include FCM token verification steps
4. THE functions/README.md SHALL include VoIP notification debugging procedures

### Requirement 9: Secure FCM Token Handling

**User Story:** As a security engineer, I want FCM tokens to be handled securely throughout their lifecycle, so that unauthorized access to notifications is prevented.

#### Acceptance Criteria

1. THE FCM tokens SHALL be validated for authenticity before sending notifications
2. THE FCM tokens SHALL have expiration validation logic
3. THE Cloud_Functions SHALL revoke invalid or expired tokens and request refresh
4. THE system SHALL revoke tokens on user sign-out and remove from Firestore
5. THE FCM token transmission SHALL occur only over HTTPS connections
6. THE Cloud_Functions SHALL implement rate limiting for FCM notification requests (max 10 per user per minute)

### Requirement 10: Verify Database Configuration

**User Story:** As a developer, I want to verify that all Firestore operations target the correct elajtech database, so that data is read from and written to the correct location.

#### Acceptance Criteria

1. THE Cloud Functions SHALL include a database configuration verification test that runs on deployment
2. THE test SHALL query the appointments collection and verify the databaseId is 'elajtech'
3. THE test SHALL attempt to query the default database and confirm it fails with appropriate error
4. THE Cloud Functions logs SHALL include database context in all error messages: "[DB: elajtech]"
5. THE integration tests SHALL verify db.settings({ databaseId: 'elajtech' }) is applied after admin.initializeApp()

#### Test Example

```javascript
// In functions/test/database-config.test.js
describe('Database Configuration', () => {
  test('should use elajtech database for all queries', async () => {
    const db = admin.firestore();
    const settings = db._settings;
    expect(settings.databaseId).toBe('elajtech');
  });
  
  test('should include database context in error logs', async () => {
    try {
      await startAgoraCall({ appointmentId: 'invalid' });
    } catch (error) {
      expect(error.message).toContain('[DB: elajtech]');
    }
  });
});
```

## Critical Project Rules

⚠️ **CRITICAL: Test Persistence Rule**

All existing 664+ tests MUST pass after implementing these bugfixes. No breaking changes allowed. This is a non-negotiable requirement enforced by the Test Persistence Rule.

**Verification Steps:**
1. Run full test suite before starting: `flutter test`
2. Run full test suite after each phase: `flutter test`
3. Verify test count remains at 664+ (or increases with new tests)
4. Any test failures must be fixed immediately before proceeding

**Historical Context:**
- Previous database configuration issue (2026-02-13) caused "Appointment Not Found" errors
- Root cause: Firebase Admin SDK wasn't consistently applying databaseId configuration
- Fix: Explicit `db.settings({ databaseId: 'elajtech' })` after Firestore initialization
- Reference: See CHANGELOG.md for complete details

