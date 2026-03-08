# Design Document: Video Call UI and VoIP Notification Critical Bugfixes

## Overview

This design document outlines the technical solution for fixing two critical bugs discovered during VoIP testing:

1. **Bug #1 - UI Text Issue**: Doctor sees "جاري الاتصال بالطبيب..." (waiting for doctor) instead of "جاري الاتصال بالمريض..." (waiting for patient)
2. **Bug #2 - VoIP Notification Issue**: Patient device does not receive incoming call notification

### Root Causes

**Bug #1 Root Cause:**
The `AgoraVideoCallScreen` widget displays hardcoded text that assumes the user is always a patient waiting for a doctor. The screen does not differentiate between caller (doctor) and callee (patient) roles.

**Bug #2 Root Cause (Hypothesis):**
Multiple potential causes need investigation:
- FCM token not saved correctly in Firestore users collection
- Cloud Function not sending FCM notification properly
- VoIPCallService not handling incoming notification
- FCM notification payload incorrect or missing required fields
- Patient app not registered for VoIP notifications

### Solution Approach

**For Bug #1:**
- Add role detection logic to determine if current user is doctor or patient
- Display different UI text based on user role
- Use appointment's `doctorId` and `patientId` to determine role

**For Bug #2:**
- Verify FCM token storage in users collection
- Add comprehensive logging to track notification flow
- Verify Cloud Function sends notification correctly
- Verify FCM Service handles notification correctly
- Verify VoIP Service displays incoming call UI

## Architecture

### Component Interaction Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Doctor Device                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  AgoraVideoCallScreen (Doctor View)                      │  │
│  │  - Display: "جاري الاتصال بالمريض..."                    │  │
│  │  - Display: "في انتظار رد [patient name]..."            │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            │                                     │
│                            │ Calls startAgoraCall()              │
│                            ▼                                     │
└─────────────────────────────────────────────────────────────────┘
                             │
                             │
┌─────────────────────────────────────────────────────────────────┐
│                    Cloud Functions (europe-west1)                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  startAgoraCall Function                                  │  │
│  │  1. Generate Agora tokens                                 │  │
│  │  2. Update appointment in Firestore                       │  │
│  │  3. Retrieve patient FCM token                            │  │
│  │  4. Send VoIP notification via FCM                        │  │
│  │  5. Log all events to call_logs                           │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                             │
                             │ FCM Notification
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Patient Device                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  FCM Service (Background Handler)                         │  │
│  │  - Receives FCM notification                              │  │
│  │  - Extracts call data                                     │  │
│  │  - Calls VoIPCallService.showIncomingCall()              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            │                                     │
│                            ▼                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  VoIP Call Service                                        │  │
│  │  - Displays CallKit (iOS) / ConnectionService (Android)   │  │
│  │  - Handles accept/decline actions                         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            │                                     │
│                            │ On Accept                            │
│                            ▼                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  AgoraVideoCallScreen (Patient View)                     │  │
│  │  - Display: "جاري الاتصال بالطبيب..."                    │  │
│  │  - Display: "يرجى الانتظار، سيتم الاتصال بك قريباً"      │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### 1. AgoraVideoCallScreen (Modified)

**File:** `lib/features/patient/consultation/presentation/screens/agora_video_call_screen.dart`

**Current Issues:**
- Hardcoded text: "جاري الاتصال بالطبيب..." (line 289)
- Hardcoded text: "يرجى الانتظار، سيتم الاتصال بك قريباً" (line 301)
- No role detection logic

**Required Changes:**

```dart
class _AgoraVideoCallScreenState extends State<AgoraVideoCallScreen> {
  // ... existing fields ...
  
  // NEW: Add role detection
  late final bool _isDoctor;
  late final String _otherPartyName;
  
  @override
  void initState() {
    super.initState();
    
    // NEW: Determine user role
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _isDoctor = currentUserId == widget.appointment.doctorId;
    _otherPartyName = _isDoctor 
        ? widget.appointment.patientName 
        : widget.appointment.doctorName;
    
    // ... existing initialization ...
  }
  
  // MODIFIED: Update waiting room UI
  Widget _remoteVideo() {
    if (_remoteUid == null) {
      return Container(
        // ... existing decoration ...
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ... existing loading indicator ...
              
              // MODIFIED: Dynamic text based on role
              Text(
                _isDoctor 
                    ? 'جاري الاتصال بالمريض...' 
                    : 'جاري الاتصال بالطبيب...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // MODIFIED: Dynamic sub-message based on role
              Text(
                _isDoctor
                    ? 'في انتظار رد $_otherPartyName...'
                    : 'يرجى الانتظار، سيتم الاتصال بك قريباً',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              
              // ... existing connection status ...
            ],
          ),
        ),
      );
    }
    
    // ... existing remote video view ...
  }
}
```

**Interface:**
- Input: `AppointmentModel` (contains doctorId, patientId, doctorName, patientName)
- Output: UI with role-appropriate text
- Dependencies: `FirebaseAuth` (to get current user ID)

### 2. Cloud Functions - startAgoraCall (Investigation & Fix)

**File:** `functions/index.js`

**Current Implementation Review:**
- Lines 320-340: Retrieves patient FCM token from users collection
- Lines 340-360: Sends VoIP notification via FCM
- Lines 360-380: Logs notification failures

**Required Investigation:**
1. Verify FCM token retrieval logic
2. Verify FCM notification payload structure
3. Add detailed logging for debugging

**Required Changes:**

```javascript
async function sendVoIPNotification(data) {
  const { patientId, doctorName, appointmentId, agoraChannelName, agoraToken, agoraUid } = data;

  try {
    // ✅ VERIFY: Retrieve patient FCM token from elajtech database
    console.log(`📱 Retrieving FCM token for patient: ${patientId}`);
    const patientDoc = await db.collection('users').doc(patientId).get();

    if (!patientDoc.exists) {
      console.error(`❌ Patient document not found: ${patientId}`);
      throw new Error(`Patient document not found: ${patientId}`);
    }

    const patientData = patientDoc.data();
    const fcmToken = patientData.fcmToken;

    // ✅ ENHANCED: Log FCM token status
    if (!fcmToken) {
      console.error(`❌ FCM token missing for patient: ${patientId}`);
      await logCallEvent({
        eventType: 'call_error',
        appointmentId: appointmentId,
        userId: patientId,
        errorCode: 'fcm_token_missing',
        errorMessage: 'Patient FCM token is null or undefined',
        metadata: {
          patientId: patientId,
          databaseId: 'elajtech',
          collectionName: 'users',
        },
      });
      throw new Error('Patient FCM token is missing');
    }

    console.log(`✅ FCM token retrieved successfully for patient: ${patientId}`);

    // ✅ VERIFY: Construct FCM notification payload
    const message = {
      token: fcmToken,
      notification: {
        title: `مكالمة واردة من ${doctorName}`,
        body: 'اضغط للرد على الاستشارة',
      },
      data: {
        type: 'incoming_call',
        appointmentId: appointmentId,
        doctorName: doctorName,
        agoraChannelName: agoraChannelName,
        agoraToken: agoraToken,
        agoraUid: agoraUid.toString(),
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'incoming_calls',
          priority: 'max',
          sound: 'default',
        },
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
        payload: {
          aps: {
            'content-available': 1,
            sound: 'default',
          },
        },
      },
    };

    // ✅ ENHANCED: Log notification payload (without token for security)
    console.log('📤 Sending VoIP notification:', {
      appointmentId,
      doctorName,
      agoraChannelName,
      hasToken: !!fcmToken,
    });

    // ✅ VERIFY: Send FCM notification
    const response = await admin.messaging().send(message);
    
    console.log(`✅ VoIP notification sent successfully: ${response}`);

    // ✅ ENHANCED: Log successful notification send
    await logCallEvent({
      eventType: 'voip_notification_sent',
      appointmentId: appointmentId,
      userId: patientId,
      metadata: {
        fcmMessageId: response,
        doctorName: doctorName,
        databaseId: 'elajtech',
      },
    });

  } catch (error) {
    console.error('❌ Error sending VoIP notification:', error);
    
    // ✅ ENHANCED: Log detailed error
    await logCallEvent({
      eventType: 'call_error',
      appointmentId: appointmentId,
      userId: patientId,
      errorCode: 'voip_notification_failed',
      errorMessage: error.message,
      stackTrace: error.stack,
      metadata: {
        errorType: error.code || 'unknown',
        databaseId: 'elajtech',
      },
    });

    throw error;
  }
}
```

### 3. FCM Service (Verification & Enhancement)

**File:** `lib/core/services/fcm_service.dart`

**Required Verification:**
1. Verify FCM token is requested on app startup
2. Verify FCM token is saved to Firestore users collection
3. Verify FCM token refresh is handled
4. Verify background message handler processes incoming_call notifications

**Required Changes:**

```dart
class FCMService {
  // ... existing code ...
  
  /// Initialize FCM and request token
  Future<void> initialize() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      criticalAlert: true, // Essential for VoIP calls
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // ✅ VERIFY: Get FCM token
      final token = await _messaging.getToken();
      
      if (token != null) {
        print('✅ FCM Token received: ${token.substring(0, 20)}...');
        
        // ✅ VERIFY: Save token to Firestore
        await _saveFCMToken(token);
      } else {
        print('❌ FCM Token is null');
      }
    }
    
    // ✅ VERIFY: Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      print('🔄 FCM Token refreshed');
      _saveFCMToken(newToken);
    });
    
    // ... existing message handlers ...
  }
  
  /// Save FCM token to Firestore
  Future<void> _saveFCMToken(String token) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('❌ Cannot save FCM token: User not signed in');
        return;
      }
      
      // ✅ CRITICAL: Use elajtech database
      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'elajtech',
      );
      
      await firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ FCM token saved to Firestore for user: $userId');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }
}
```

### 4. VoIP Call Service (Verification)

**File:** `lib/core/services/voip_call_service.dart`

**Required Verification:**
1. Verify `showIncomingCall()` is called with correct parameters
2. Verify CallKit/ConnectionService displays incoming call UI
3. Verify call acceptance navigates to video call screen

**No code changes required** - this component should work correctly if FCM notification is delivered properly.

## Data Models

### UserModel (Enhanced)

**File:** `lib/shared/models/user_model.dart`

**Required Fields:**
```dart
@freezed
class UserModel with _$UserModel {
  factory UserModel({
    required String id,
    required String fullName,
    required String email,
    required UserType userType,
    // ... existing fields ...
    
    // ✅ NEW: FCM token fields
    String? fcmToken,
    @JsonKey(name: 'fcmTokenUpdatedAt') DateTime? fcmTokenUpdatedAt,
  }) = _UserModel;
  
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

### AppointmentModel (No Changes)

**File:** `lib/shared/models/appointment_model.dart`

**Existing Fields Used:**
- `doctorId`: Used to determine if current user is doctor
- `patientId`: Used to determine if current user is patient
- `doctorName`: Displayed in patient's waiting screen
- `patientName`: Displayed in doctor's waiting screen

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property Reflection Analysis

After analyzing all acceptance criteria, I identified the following testable properties and performed redundancy elimination:

**Redundancy Analysis:**
- Properties 1.1, 1.3 can be combined into a single "UI text based on role" property
- Properties 1.2, 1.4 can be combined into a single "UI sub-message based on role" property
- Properties 2.1, 2.10 both test database targeting and can be combined
- Properties 3.2, 3.3, 3.6 all test FCM token persistence with correct database and can be combined
- Properties 4.1, 4.2, 4.3, 4.4 all test graceful error handling and can be combined
- Properties 5.1, 5.2, 5.3, 5.4, 5.5 all test logging behavior and can be combined with 5.6, 5.7

### Property 1: Role-Based UI Text Display

*For any* appointment and current user ID, when the Video_Call_Screen is displayed with no remote user present, the main waiting message should be "جاري الاتصال بالمريض..." if currentUserId equals appointment.doctorId, and "جاري الاتصال بالطبيب..." if currentUserId equals appointment.patientId.

**Validates: Requirements 1.1, 1.3, 1.5**

### Property 2: Role-Based UI Sub-Message Display

*For any* appointment and current user ID, when the Video_Call_Screen is displayed with no remote user present, the sub-message should include the patient's name ("في انتظار رد [patientName]...") if the user is the doctor, and should be "يرجى الانتظار، سيتم الاتصال بك قريباً" if the user is the patient.

**Validates: Requirements 1.2, 1.4**

### Property 3: FCM Notification Payload Completeness

*For any* valid startAgoraCall request, when the Cloud Function sends an FCM notification, the notification payload must include all required fields: appointmentId, doctorName, agoraChannelName, agoraToken, agoraUid, with type set to 'incoming_call' and high priority settings for both Android and iOS.

**Validates: Requirements 2.2, 2.3**

### Property 4: Database Targeting Consistency

*For all* Firestore operations in Cloud Functions (reads and writes), the operations must target the 'elajtech' database, never the default database, verified by db.settings({ databaseId: 'elajtech' }) being applied after initialization.

**Validates: Requirements 2.1, 2.9, 2.10**

### Property 5: FCM Token Persistence with Correct Database

*For any* FCM token received or refreshed, when the FCM_Service saves the token, it must write to the users collection in the 'elajtech' database (using FirebaseFirestore.instanceFor with databaseId: 'elajtech'), include both fcmToken and fcmTokenUpdatedAt fields, and use FieldValue.serverTimestamp() for the timestamp.

**Validates: Requirements 3.2, 3.3, 3.6, 3.9**

### Property 6: Graceful VoIP Notification Failure Handling

*For any* VoIP notification failure (missing FCM token or send failure), the Cloud Function must log the error to call_logs with appropriate errorCode ('fcm_token_missing' or 'voip_notification_failed'), must NOT throw an exception, and must return success to the caller indicating the call was initiated successfully.

**Validates: Requirements 4.1, 4.2, 4.3, 4.4**

### Property 7: Timeout and Retry Mechanism

*For any* video call where the remote user does not join, the Video_Call_Screen must display a timeout message after 60 seconds, provide retry and cancel options, allow maximum 3 retry attempts with exponential backoff delays (2s, 4s, 8s), log timeout events to call_logs with eventType 'call_timeout', and re-request Agora tokens from Cloud Functions for each retry.

**Validates: Requirements 4.5, 4.6, 4.8, 4.9, 4.10**

### Property 8: Comprehensive VoIP Event Logging

*For all* VoIP-related events (token retrieval, notification send, notification receipt, call display, user actions), logs must be written to the call_logs collection in the 'elajtech' database, and every log entry must include appointmentId, userId, and timestamp fields.

**Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7**

### Property 9: Error Message Database Context

*For all* error logs written by Cloud Functions, the error message must include the "[DB: elajtech]" prefix, and the metadata must include a databaseId field set to 'elajtech' for debugging purposes.

**Validates: Requirements 2.11, 7.4**

### Property 10: Environment Variable Fallback

*For any* Cloud Function execution, when loading Agora credentials, if process.env.AGORA_APP_ID or process.env.AGORA_APP_CERTIFICATE are undefined, the function must fallback to functions.config().agora.app_id and functions.config().agora.app_certificate for backward compatibility.

**Validates: Requirements 7.1, 7.3**

## Error Handling

### 1. FCM Token Missing

**Scenario:** Patient's FCM token is null or undefined in Firestore.

**Handling:**
- Cloud Function logs error with code `fcm_token_missing`
- Cloud Function does NOT throw exception (call initiation succeeds)
- Doctor's screen shows timeout after 60 seconds
- Error is logged to call_logs for debugging

### 2. FCM Notification Send Failure

**Scenario:** FCM service fails to send notification (network error, invalid token, etc.).

**Handling:**
- Cloud Function catches exception
- Cloud Function logs error with code `voip_notification_failed`
- Cloud Function does NOT throw exception (call initiation succeeds)
- Doctor's screen shows timeout after 60 seconds
- Error is logged to call_logs for debugging

### 3. VoIP Service Platform Error

**Scenario:** CallKit/ConnectionService fails to display incoming call UI.

**Handling:**
- VoIP Service catches `MissingPluginException`
- VoIP Service logs error to call_logs
- VoIP Service falls back to in-app notification
- User can still accept call from notification

### 4. Role Determination Failure

**Scenario:** Current user ID doesn't match doctorId or patientId.

**Handling:**
- Default to patient role (safer assumption)
- Log warning to console
- Display generic waiting message

## Testing Strategy

### Dual Testing Approach

The testing strategy employs both unit tests and property-based tests to ensure comprehensive coverage:

- **Unit tests**: Verify specific examples, edge cases, and error conditions
- **Property tests**: Verify universal properties across all inputs
- Both are complementary and necessary for comprehensive coverage

### Unit Testing Balance

Unit tests are helpful for specific examples and edge cases, but we should avoid writing too many unit tests since property-based tests handle covering lots of inputs. Unit tests should focus on:

- Specific examples that demonstrate correct behavior
- Integration points between components
- Edge cases and error conditions (missing FCM tokens, send failures, platform errors)

Property tests should focus on:

- Universal properties that hold for all inputs
- Comprehensive input coverage through randomization

### Property-Based Testing Configuration

- Minimum 100 iterations per property test (due to randomization)
- Each property test must reference its design document property
- Tag format: **Feature: video-call-ui-voip-bugfix, Property {number}: {property_text}**
- Each correctness property MUST be implemented by a SINGLE property-based test

### Unit Tests

**Test Coverage:**
- Role determination logic (doctor vs patient)
- UI text selection based on role
- FCM token save/update logic
- FCM notification payload construction
- Error handling for missing FCM token
- Error handling for FCM send failure
- Database configuration verification
- Environment variable fallback logic

**Example Unit Tests:**

```dart
// Test role determination
test('AgoraVideoCallScreen determines doctor role correctly', () {
  final appointment = AppointmentModel(
    doctorId: 'doctor_123',
    patientId: 'patient_456',
    patientName: 'أحمد محمد',
    doctorName: 'د. محمد علي',
  );
  
  // Mock current user as doctor
  when(mockAuth.currentUser?.uid).thenReturn('doctor_123');
  
  final screen = AgoraVideoCallScreen(appointment: appointment);
  final state = screen.createState();
  state.initState();
  
  expect(state._isDoctor, true);
  expect(state._otherPartyName, appointment.patientName);
});

// Test FCM token save
test('FCMService saves token to elajtech database', () async {
  final mockFirestore = MockFirebaseFirestore();
  final service = FCMService(firestore: mockFirestore);
  
  await service._saveFCMToken('test_token_123');
  
  verify(mockFirestore.collection('users').doc(any).update({
    'fcmToken': 'test_token_123',
    'fcmTokenUpdatedAt': any,
  })).called(1);
});

// Test database configuration
test('Cloud Functions use elajtech database', () {
  final db = admin.firestore();
  expect(db._settings.databaseId, equals('elajtech'));
});

// Test error handling
test('Cloud Function logs error but does not throw when FCM token missing', () async {
  // Mock patient document without FCM token
  when(mockFirestore.collection('users').doc(any).get())
    .thenAnswer((_) async => MockDocumentSnapshot(data: {}));
  
  // Should not throw
  final result = await startAgoraCall({
    'appointmentId': 'apt_123',
    'doctorId': 'doctor_456',
  });
  
  expect(result['success'], true);
  
  // Verify error was logged
  verify(mockFirestore.collection('call_logs').add(argThat(
    containsPair('errorCode', 'fcm_token_missing')
  ))).called(1);
});
```

### Widget Tests

**Test Coverage:**
- Doctor sees "جاري الاتصال بالمريض..." when no remote user
- Patient sees "جاري الاتصال بالطبيب..." when no remote user
- Patient name appears in doctor's waiting message
- Timeout message appears after 60 seconds
- Retry and cancel buttons appear in timeout dialog

**Example Widget Tests:**

```dart
testWidgets('Doctor sees correct waiting message', (tester) async {
  final appointment = AppointmentModel(
    doctorId: 'doctor_123',
    patientId: 'patient_456',
    patientName: 'أحمد محمد',
    doctorName: 'د. محمد علي',
  );
  
  // Mock current user as doctor
  when(mockAuth.currentUser?.uid).thenReturn('doctor_123');
  
  await tester.pumpWidget(
    MaterialApp(
      home: AgoraVideoCallScreen(appointment: appointment),
    ),
  );
  
  await tester.pump();
  
  expect(find.text('جاري الاتصال بالمريض...'), findsOneWidget);
  expect(find.text('في انتظار رد أحمد محمد...'), findsOneWidget);
});

testWidgets('Patient sees correct waiting message', (tester) async {
  final appointment = AppointmentModel(
    doctorId: 'doctor_123',
    patientId: 'patient_456',
    patientName: 'أحمد محمد',
    doctorName: 'د. محمد علي',
  );
  
  // Mock current user as patient
  when(mockAuth.currentUser?.uid).thenReturn('patient_456');
  
  await tester.pumpWidget(
    MaterialApp(
      home: AgoraVideoCallScreen(appointment: appointment),
    ),
  );
  
  await tester.pump();
  
  expect(find.text('جاري الاتصال بالطبيب...'), findsOneWidget);
  expect(find.text('يرجى الانتظار، سيتم الاتصال بك قريباً'), findsOneWidget);
});

testWidgets('Timeout dialog appears after 60 seconds', (tester) async {
  // Use fake async to control time
  await tester.runAsync(() async {
    final appointment = AppointmentModel(/* ... */);
    
    await tester.pumpWidget(
      MaterialApp(
        home: AgoraVideoCallScreen(appointment: appointment),
      ),
    );
    
    // Fast-forward 60 seconds
    await tester.pump(Duration(seconds: 60));
    
    // Verify timeout dialog appears
    expect(find.text('لم يرد المريض على المكالمة'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    expect(find.text('إلغاء'), findsOneWidget);
  });
});
```

### Integration Tests

**Test Coverage:**
- End-to-end VoIP notification flow (doctor initiates → patient receives)
- FCM token storage on sign-in
- FCM token refresh handling
- Call acceptance navigation
- Error logging to call_logs collection
- Database isolation verification

**Example Integration Tests:**

```dart
testWidgets('VoIP notification end-to-end flow', (tester) async {
  // 1. Sign in as patient
  await authService.signIn('patient@test.com', 'password');
  
  // 2. Verify FCM token saved
  final patientDoc = await firestore
      .collection('users')
      .doc(patientId)
      .get();
  expect(patientDoc.data()?['fcmToken'], isNotNull);
  
  // 3. Doctor initiates call
  final result = await functions
      .httpsCallable('startAgoraCall')
      .call({
        'appointmentId': appointmentId,
        'doctorId': doctorId,
      });
  
  // 4. Wait for FCM notification
  await tester.pumpAndSettle(Duration(seconds: 2));
  
  // 5. Verify incoming call UI appears
  expect(find.text('مكالمة واردة من د. أحمد'), findsOneWidget);
  
  // 6. Accept call
  await tester.tap(find.text('قبول'));
  await tester.pumpAndSettle();
  
  // 7. Verify navigation to video call screen
  expect(find.byType(AgoraVideoCallScreen), findsOneWidget);
});

testWidgets('Database isolation verification', (tester) async {
  // Verify elajtech database is used
  final db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech',
  );
  
  // Write test document
  await db.collection('test').doc('test_doc').set({'test': true});
  
  // Verify it exists in elajtech database
  final doc = await db.collection('test').doc('test_doc').get();
  expect(doc.exists, true);
  
  // Verify it does NOT exist in default database
  final defaultDb = FirebaseFirestore.instance;
  final defaultDoc = await defaultDb.collection('test').doc('test_doc').get();
  expect(defaultDoc.exists, false);
  
  // Cleanup
  await db.collection('test').doc('test_doc').delete();
});
```

### Property-Based Tests

**Configuration:**
- Minimum 100 iterations per property test
- Use `fast_check` or similar library for Dart
- Each test must reference the design property it validates

**Property Test 1: Role-Based UI Text Display**

```dart
test('Property 1: UI text displays correctly based on user role', () {
  fc.assert(
    fc.property(
      fc.record({
        'doctorId': fc.string(),
        'patientId': fc.string(),
        'currentUserId': fc.string(),
        'doctorName': fc.string(),
        'patientName': fc.string(),
      }),
      (data) {
        final appointment = AppointmentModel(
          doctorId: data['doctorId'],
          patientId: data['patientId'],
          doctorName: data['doctorName'],
          patientName: data['patientName'],
        );
        
        when(mockAuth.currentUser?.uid).thenReturn(data['currentUserId']);
        
        final screen = AgoraVideoCallScreen(appointment: appointment);
        final state = screen.createState();
        state.initState();
        
        // Property: UI text matches user role
        final isDoctor = data['currentUserId'] == data['doctorId'];
        
        expect(state._isDoctor, equals(isDoctor));
      },
    ),
    numRuns: 100,
  );
}, tags: ['Feature: video-call-ui-voip-bugfix, Property 1: Role-based UI text display']);
```

**Property Test 2: Role-Based UI Sub-Message Display**

```dart
test('Property 2: UI sub-message displays correctly based on user role', () {
  fc.assert(
    fc.property(
      fc.record({
        'doctorId': fc.string(),
        'patientId': fc.string(),
        'currentUserId': fc.string(),
        'patientName': fc.string(),
      }),
      (data) {
        final appointment = AppointmentModel(
          doctorId: data['doctorId'],
          patientId: data['patientId'],
          patientName: data['patientName'],
        );
        
        when(mockAuth.currentUser?.uid).thenReturn(data['currentUserId']);
        
        final screen = AgoraVideoCallScreen(appointment: appointment);
        final state = screen.createState();
        state.initState();
        
        // Property: Sub-message includes patient name for doctor
        final isDoctor = data['currentUserId'] == data['doctorId'];
        
        if (isDoctor) {
          expect(state._otherPartyName, equals(data['patientName']));
        }
      },
    ),
    numRuns: 100,
  );
}, tags: ['Feature: video-call-ui-voip-bugfix, Property 2: Role-based UI sub-message display']);
```

**Property Test 3: FCM Notification Payload Completeness**

```dart
test('Property 3: FCM notification payload includes all required fields', () async {
  fc.assert(
    fc.asyncProperty(
      fc.record({
        'appointmentId': fc.string(),
        'patientId': fc.string(),
        'doctorName': fc.string(),
        'agoraChannelName': fc.string(),
        'agoraToken': fc.string(),
        'agoraUid': fc.integer(),
      }),
      async (data) {
        // Mock FCM send
        final capturedPayload = <String, dynamic>{};
        when(mockMessaging.send(any)).thenAnswer((invocation) {
          capturedPayload.addAll(invocation.positionalArguments[0]);
          return Future.value('message_id');
        });
        
        await sendVoIPNotification(data);
        
        // Property: Payload must include all required fields
        expect(capturedPayload['data']['appointmentId'], equals(data['appointmentId']));
        expect(capturedPayload['data']['doctorName'], equals(data['doctorName']));
        expect(capturedPayload['data']['agoraChannelName'], equals(data['agoraChannelName']));
        expect(capturedPayload['data']['agoraToken'], equals(data['agoraToken']));
        expect(capturedPayload['data']['agoraUid'], equals(data['agoraUid'].toString()));
        expect(capturedPayload['data']['type'], equals('incoming_call'));
        expect(capturedPayload['android']['priority'], equals('high'));
        expect(capturedPayload['apns']['headers']['apns-priority'], equals('10'));
      },
    ),
    numRuns: 100,
  );
}, tags: ['Feature: video-call-ui-voip-bugfix, Property 3: FCM notification payload completeness']);
```

**Property Test 4: Database Targeting Consistency**

```dart
test('Property 4: All Firestore operations target elajtech database', () {
  fc.assert(
    fc.property(
      fc.record({
        'collectionName': fc.constantFrom('users', 'appointments', 'call_logs'),
        'documentId': fc.string(),
      }),
      (data) {
        final db = admin.firestore();
        
        // Property: Database ID must be 'elajtech'
        expect(db._settings.databaseId, equals('elajtech'));
        
        // Verify collection references use correct database
        final collection = db.collection(data['collectionName']);
        expect(collection._firestore._settings.databaseId, equals('elajtech'));
      },
    ),
    numRuns: 100,
  );
}, tags: ['Feature: video-call-ui-voip-bugfix, Property 4: Database targeting consistency']);
```

**Property Test 5: FCM Token Persistence with Correct Database**

```dart
test('Property 5: FCM token saved to elajtech database with timestamp', () async {
  fc.assert(
    fc.asyncProperty(
      fc.record({
        'userId': fc.string(),
        'fcmToken': fc.string(),
      }),
      async (data) {
        final mockFirestore = MockFirebaseFirestore();
        final service = FCMService(firestore: mockFirestore);
        
        await service._saveFCMToken(data['fcmToken']);
        
        // Property: Token saved with correct database, fields, and timestamp
        final captured = verify(
          mockFirestore.collection('users').doc(data['userId']).update(captureAny)
        ).captured.single;
        
        expect(captured['fcmToken'], equals(data['fcmToken']));
        expect(captured['fcmTokenUpdatedAt'], isA<FieldValue>());
        expect(mockFirestore._databaseId, equals('elajtech'));
      },
    ),
    numRuns: 100,
  );
}, tags: ['Feature: video-call-ui-voip-bugfix, Property 5: FCM token persistence with correct database']);
```

**Property Test 6: Graceful VoIP Notification Failure Handling**

```dart
test('Property 6: VoIP notification failures handled gracefully', () async {
  fc.assert(
    fc.asyncProperty(
      fc.record({
        'appointmentId': fc.string(),
        'doctorId': fc.string(),
        'failureType': fc.constantFrom('missing_token', 'send_failure'),
      }),
      async (data) {
        // Mock failure scenario
        if (data['failureType'] == 'missing_token') {
          when(mockFirestore.collection('users').doc(any).get())
            .thenAnswer((_) async => MockDocumentSnapshot(data: {}));
        } else {
          when(mockMessaging.send(any)).thenThrow(Exception('Send failed'));
        }
        
        // Property: Function does not throw, returns success, logs error
        final result = await startAgoraCall({
          'appointmentId': data['appointmentId'],
          'doctorId': data['doctorId'],
        });
        
        expect(result['success'], true);
        
        // Verify error logged
        final expectedErrorCode = data['failureType'] == 'missing_token'
            ? 'fcm_token_missing'
            : 'voip_notification_failed';
        
        verify(mockFirestore.collection('call_logs').add(argThat(
          containsPair('errorCode', expectedErrorCode)
        ))).called(1);
      },
    ),
    numRuns: 100,
  );
}, tags: ['Feature: video-call-ui-voip-bugfix, Property 6: Graceful VoIP notification failure handling']);
```

**Property Test 7: Timeout and Retry Mechanism**

```dart
test('Property 7: Timeout triggers after 60s with retry mechanism', () async {
  fc.assert(
    fc.asyncProperty(
      fc.record({
        'appointmentId': fc.string(),
        'retryCount': fc.integer(min: 0, max: 3),
      }),
      async (data) {
        final screen = AgoraVideoCallScreen(appointment: mockAppointment);
        final state = screen.createState();
        
        // Fast-forward time
        await tester.pump(Duration(seconds: 60));
        
        // Property: Timeout dialog appears
        expect(find.text('لم يرد المريض على المكالمة'), findsOneWidget);
        
        // Test retry with exponential backoff
        for (int i = 0; i < data['retryCount'] && i < 3; i++) {
          await tester.tap(find.text('إعادة المحاولة'));
          
          final expectedDelay = Duration(seconds: 2 << i); // 2s, 4s, 8s
          await tester.pump(expectedDelay);
          
          // Verify Cloud Function called again
          verify(mockFunctions.httpsCallable('startAgoraCall').call(any)).called(1);
        }
        
        // Verify timeout logged
        verify(mockFirestore.collection('call_logs').add(argThat(
          containsPair('eventType', 'call_timeout')
        ))).called(greaterThan(0));
      },
    ),
    numRuns: 100,
  );
}, tags: ['Feature: video-call-ui-voip-bugfix, Property 7: Timeout and retry mechanism']);
```

**Property Test 8: Comprehensive VoIP Event Logging**

```dart
test('Property 8: All VoIP events logged with required fields', () async {
  fc.assert(
    fc.asyncProperty(
      fc.record({
        'eventType': fc.constantFrom(
          'call_attempt', 'call_started', 'voip_notification_sent',
          'call_error', 'call_timeout'
        ),
        'appointmentId': fc.string(),
        'userId': fc.string(),
      }),
      async (data) {
        await logCallEvent({
          'eventType': data['eventType'],
          'appointmentId': data['appointmentId'],
          'userId': data['userId'],
        });
        
        // Property: Log entry includes all required fields and uses elajtech database
        final captured = verify(
          mockFirestore.collection('call_logs').add(captureAny)
        ).captured.single;
        
        expect(captured['eventType'], equals(data['eventType']));
        expect(captured['appointmentId'], equals(data['appointmentId']));
        expect(captured['userId'], equals(data['userId']));
        expect(captured['timestamp'], isNotNull);
        expect(mockFirestore._databaseId, equals('elajtech'));
      },
    ),
    numRuns: 100,
  );
}, tags: ['Feature: video-call-ui-voip-bugfix, Property 8: Comprehensive VoIP event logging']);
```

**Property Test 9: Error Message Database Context**

```dart
test('Property 9: Error messages include database context', () async {
  fc.assert(
    fc.asyncProperty(
      fc.record({
        'errorMessage': fc.string(),
        'appointmentId': fc.string(),
      }),
      async (data) {
        // Trigger an error
        when(mockFirestore.collection('appointments').doc(any).get())
          .thenThrow(Exception(data['errorMessage']));
        
        try {
          await startAgoraCall({
            'appointmentId': data['appointmentId'],
            'doctorId': 'doctor_123',
          });
        } catch (e) {
          // Property: Error message includes [DB: elajtech] prefix
          expect(e.toString(), contains('[DB: elajtech]'));
        }
        
        // Verify error log includes database context in metadata
        final captured = verify(
          mockFirestore.collection('call_logs').add(captureAny)
        ).captured.single;
        
        expect(captured['metadata']['databaseId'], equals('elajtech'));
      },
    ),
    numRuns: 100,
  );
}, tags: ['Feature: video-call-ui-voip-bugfix, Property 9: Error message database context']);
```

**Property Test 10: Environment Variable Fallback**

```dart
test('Property 10: Environment variables fallback to functions.config()', () {
  fc.assert(
    fc.property(
      fc.record({
        'hasEnvVars': fc.boolean(),
        'appId': fc.string(),
        'appCertificate': fc.string(),
      }),
      (data) {
        if (data['hasEnvVars']) {
          process.env.AGORA_APP_ID = data['appId'];
          process.env.AGORA_APP_CERTIFICATE = data['appCertificate'];
        } else {
          delete process.env.AGORA_APP_ID;
          delete process.env.AGORA_APP_CERTIFICATE;
          
          // Mock functions.config()
          when(functions.config().agora.app_id).thenReturn(data['appId']);
          when(functions.config().agora.app_certificate).thenReturn(data['appCertificate']);
        }
        
        // Property: Credentials loaded from env or fallback to config
        const credentials = loadAgoraCredentials();
        
        expect(credentials.appId, equals(data['appId']));
        expect(credentials.appCertificate, equals(data['appCertificate']));
      },
    ),
    numRuns: 100,
  );
}, tags: ['Feature: video-call-ui-voip-bugfix, Property 10: Environment variable fallback']);
```

### Manual Testing Checklist

**Bug #1 - UI Text:**
- [ ] Sign in as doctor
- [ ] Initiate video call
- [ ] Verify screen shows "جاري الاتصال بالمريض..."
- [ ] Verify screen shows "في انتظار رد [patient name]..."
- [ ] Sign in as patient
- [ ] Receive incoming call
- [ ] Verify screen shows "جاري الاتصال بالطبيب..."
- [ ] Verify screen shows "يرجى الانتظار، سيتم الاتصال بك قريباً"

**Bug #2 - VoIP Notification:**
- [ ] Sign in as patient
- [ ] Verify FCM token saved in Firestore (check Firebase Console)
- [ ] Close app completely (terminated state)
- [ ] Doctor initiates call
- [ ] Verify incoming call UI appears on patient device
- [ ] Verify CallKit (iOS) or ConnectionService (Android) displays
- [ ] Accept call
- [ ] Verify navigation to video call screen
- [ ] Test with app in foreground
- [ ] Test with app in background
- [ ] Test with app terminated

**Database Configuration:**
- [ ] Verify Cloud Functions logs show database ID in all messages
- [ ] Verify call_logs collection exists in elajtech database
- [ ] Verify users collection FCM tokens in elajtech database
- [ ] Verify no data written to default database

**Error Handling:**
- [ ] Test with patient missing FCM token
- [ ] Verify error logged but call still initiated
- [ ] Test with FCM send failure
- [ ] Verify error logged but call still initiated
- [ ] Test timeout scenario (patient doesn't answer)
- [ ] Verify timeout dialog appears after 60 seconds
- [ ] Test retry mechanism (up to 3 attempts)

### Test Persistence Rule

⚠️ **CRITICAL**: All existing 664+ tests MUST pass after implementing these bugfixes. No breaking changes allowed.

**Verification Steps:**
1. Run full test suite before starting: `flutter test`
2. Run full test suite after each phase: `flutter test`
3. Verify test count remains at 664+ (or increases with new tests)
4. Any test failures must be fixed immediately before proceeding

## Deployment Plan

### Phase 1: Bug #1 Fix (UI Text)

**Priority:** HIGH  
**Estimated Time:** 2 hours  
**Risk:** LOW

**Steps:**
1. Modify `AgoraVideoCallScreen` to add role detection
2. Update UI text based on role
3. Write unit tests for role determination
4. Write widget tests for UI text
5. Manual testing on both doctor and patient devices
6. Deploy to staging
7. QA verification
8. Deploy to production

### Phase 2: Bug #2 Investigation & Fix (VoIP Notification)

**Priority:** CRITICAL  
**Estimated Time:** 4-6 hours  
**Risk:** MEDIUM

**Steps:**
1. Add comprehensive logging to Cloud Functions
2. Add comprehensive logging to FCM Service
3. Verify FCM token storage on sign-in
4. Test FCM notification delivery in all app states
5. Fix identified issues
6. Write integration tests
7. Manual testing on both iOS and Android
8. Deploy to staging
9. QA verification
10. Deploy to production

### Rollback Plan

If issues are discovered after deployment:
1. Revert to previous version via Firebase Hosting
2. Investigate logs in call_logs collection
3. Fix issues in development environment
4. Re-test thoroughly
5. Re-deploy

## Monitoring and Observability

### Metrics to Track

1. **VoIP Notification Success Rate:**
   - Query call_logs for `voip_notification_sent` vs `voip_notification_failed`
   - Target: > 95% success rate

2. **FCM Token Coverage:**
   - Query users collection for documents with non-null fcmToken
   - Target: > 98% of active users

3. **Call Initiation Success Rate:**
   - Query call_logs for `call_started` vs `call_error`
   - Target: > 99% success rate

4. **Patient Join Rate:**
   - Track how many patients join within 60 seconds of call initiation
   - Target: > 90% join rate

### Logging Strategy

**Cloud Functions Logs:**
- Log FCM token retrieval (success/failure)
- Log FCM notification send (success/failure)
- Log all errors with detailed context
- Include database ID in all log messages

**Client-Side Logs:**
- Log FCM token save/update
- Log FCM notification receipt
- Log VoIP call display
- Log call acceptance/decline
- All logs written to call_logs collection

### Alerting

**Critical Alerts:**
- VoIP notification success rate drops below 90%
- FCM token coverage drops below 95%
- Call initiation success rate drops below 95%

**Warning Alerts:**
- Patient join rate drops below 80%
- Increase in `fcm_token_missing` errors
- Increase in `voip_notification_failed` errors

## Security Considerations

### FCM Token Security

- FCM tokens are sensitive and should not be logged in plain text
- Tokens should only be accessible to authenticated users
- Firestore security rules should prevent unauthorized access to fcmToken field

### Database Access

- All Firestore operations must use `databaseId: 'elajtech'`
- Never use `FirebaseFirestore.instance` (uses default database)
- Verify database ID in all new code

### User Privacy

- Do not log patient/doctor names in plain text
- Use user IDs instead of names in logs
- Ensure HIPAA compliance for all medical data

## Performance Considerations

### UI Rendering

- Role determination happens once in `initState()` (not in `build()`)
- No performance impact from role detection logic
- UI text changes are minimal and don't affect rendering performance

### FCM Notification Delivery

- FCM notifications are delivered within 1-2 seconds typically
- High-priority notifications bypass battery optimization
- Network latency may affect delivery time

### Database Queries

- FCM token retrieval is a single document read (fast)
- Call logs are write-only (no read performance impact)
- Consider batching log writes if volume increases

## Future Enhancements

### 1. Retry Mechanism for Failed Notifications

If VoIP notification fails, automatically retry after 5 seconds.

### 2. Fallback to In-App Notification

If VoIP notification fails, send regular FCM notification as fallback.

### 3. Call Quality Monitoring

Track video/audio quality metrics during calls.

### 4. Analytics Dashboard

Build admin dashboard to visualize VoIP notification success rates and call metrics.

### 5. Automated Testing

Implement automated end-to-end tests for VoIP notification flow.
