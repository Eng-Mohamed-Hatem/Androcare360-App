\# 🏥 AndroCare360 - Project Overview

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10.4-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Cloud-FFCA28?logo=firebase)
![Test Coverage](https://img.shields.io/badge/Coverage-70%25+-success)
![License](https://img.shields.io/badge/License-Proprietary-red)

\## 📋 Table of Contents

\- \[Introduction](#-introduction)

\- \[System Architecture](#-system-architecture)

\- \[Testing](#-testing)

\- \[Core Modules](#-core-modules)

\- \[Security Protocols](#-security-protocols)

\- \[Technical Features](#-technical-features)

\- \[Data Flow](#-data-flow)

\- \[Testing \& QA Plan](#-testing--qa-plan)

\- \[Documentation](#-documentation)

\- \[Team Onboarding](#-team-onboarding)



---



\## 🎯 Introduction



\*\*AndroCare360\*\* is a comprehensive medical consultation platform built with Flutter and Firebase, designed to connect patients with healthcare professionals through secure video consultations. The platform provides a complete telemedicine solution with real-time video calls, appointment management, electronic medical records (EMR), and integrated monitoring systems.



\### Key Highlights

\- \*\*Real-time Video Consultations\*\* using Agora.io RTC Engine

\- \*\*VoIP Call System\*\* with iOS CallKit and Android ConnectionService

\- \*\*Comprehensive EMR\*\* for multiple specialties (Nutrition, Physiotherapy, General Medicine)

\- \*\*Secure Authentication\*\* with Firebase Auth

\- \*\*Cloud-Based Architecture\*\* leveraging Firebase ecosystem

\- \*\*Multi-Platform Support\*\* (Android \& iOS)



---



\## 🏗️ System Architecture



\### High-Level Architecture



The system follows a \*\*Clean Architecture\*\* pattern with clear separation of concerns:



```

lib/

├── core/                    # Shared infrastructure

│   ├── services/           # Platform services (21 services)

│   ├── models/             # Data models

│   ├── constants/          # App-wide constants

│   └── di/                 # Dependency injection

├── features/               # Feature modules (16 features)

│   ├── auth/              # Authentication

│   ├── appointments/      # Appointment management

│   ├── doctor/            # Doctor-specific features

│   ├── patient/           # Patient-specific features

│   ├── emr/               # Electronic Medical Records

│   └── ...

└── shared/                # Shared UI components

```



\### Technology Stack



| Layer | Technology | Purpose |

|-------|-----------|---------|

| \*\*Frontend\*\* | Flutter 3.x (Dart 3.10.4) | Cross-platform mobile app |

| \*\*State Management\*\* | Riverpod 2.5.1 | Reactive state management |

| \*\*Backend\*\* | Firebase (Cloud Firestore, Functions v2) | Serverless backend |

| \*\*Database\*\* | Cloud Firestore (`elajtech` database) | NoSQL document database |

| \*\*Authentication\*\* | Firebase Auth | User authentication |

| \*\*Storage\*\* | Firebase Storage | File storage (images, PDFs) |

| \*\*Messaging\*\* | Firebase Cloud Messaging (FCM) | Push notifications |

| \*\*Video Engine\*\* | Agora RTC Engine 6.3.2 | Real-time video/audio |

| \*\*VoIP\*\* | flutter\_callkit\_incoming 2.0.4 | Native call UI |

| \*\*DI Container\*\* | get\_it + injectable | Dependency injection |



\### Firebase Configuration



```yaml

Project ID: elajtech

Region: europe-west1

Database: elajtech (custom Firestore database)

Functions Runtime: Node.js (Cloud Functions v2)

```



\### Key Firebase Services



1\. \*\*Cloud Firestore Collections\*\*:

&nbsp;  - `users` - User profiles (doctors \& patients)

&nbsp;  - `appointments` - Appointment records

&nbsp;  - `call\_logs` - Video call monitoring logs

&nbsp;  - `emr\_records` - Electronic medical records

&nbsp;  - `prescriptions`, `lab\_requests`, `radiology\_requests` - Medical documents



2\. \*\*Cloud Functions\*\* (3 main functions):

&nbsp;  - `startAgoraCall` - Initiates video call with token generation

&nbsp;  - `endAgoraCall` - Ends video call session

&nbsp;  - `completeAppointment` - Marks appointment as completed



3\. \*\*Firebase Storage Structure\*\*:

&nbsp;  - `/prescriptions/{userId}/{fileId}`

&nbsp;  - `/lab\_results/{userId}/{fileId}`

&nbsp;  - `/radiology\_images/{userId}/{fileId}`

&nbsp;  - `/profile\_pictures/{userId}/{fileId}`



---



\## 🧪 Testing

AndroCare360 maintains a comprehensive test suite with 700+ passing tests and 70%+ code coverage to ensure reliability and stability.

\### Recent Quality Improvements

**Deprecated API Migration (Task 18 - Completed 2026-02-16):**
- ✅ Eliminated 100% of deprecated API warnings from source code (6 → 0)
- ✅ Migrated to Flutter 3.27+ current APIs
- ✅ Zero breaking changes - all 700 tests passing
- ✅ Prevention mechanisms implemented (pre-commit hooks, CI/CD, golden tests)
- **APIs Migrated**: `Color.withOpacity()` → `Color.withValues(alpha:)`, `Radio` → `RadioGroup`
- **Reference**: `TASK_18_COMPLETION_REPORT.md`, `DEPRECATED_API_PREVENTION_STRATEGY.md`

\### Test Infrastructure

\#### Test Organization

```
test/
├── unit/                    # Unit tests for business logic
│   ├── services/           # Service layer tests
│   ├── repositories/       # Repository tests
│   ├── providers/          # State management tests
│   └── models/             # Data model tests
├── widget/                 # Widget tests for UI components
│   ├── screens/           # Screen-level tests
│   └── widgets/           # Component tests
└── integration/            # End-to-end integration tests (31 tests - manual execution)
    └── README.md          # Integration test execution guide
```

\#### Coverage Requirements

| Component | Minimum Coverage | Current Status |
|-----------|-----------------|----------------|
| Core Services | 80% | ✅ Achieved |
| Repositories | 80% | ✅ Achieved |
| Critical Flows | 100% | ✅ Achieved |
| Overall Project | 70% | ✅ Achieved |

\### Test Status

\#### Automated Tests
- ✅ **700 tests passing**
- ⏭️ **31 tests skipped** (integration tests - require manual execution)
- ❌ **0 tests failing**

\#### Integration Tests (Manual Execution)
- ⏭️ **8 Firebase Emulator tests** - Require `firebase emulators:start`
- ⏭️ **23 Notification tests** - Require real device/emulator
- 📖 **See** `test/integration/README.md` for execution guide

\### Running Tests

\#### Run All Automated Tests
```bash
# Execute full test suite (700 tests)
flutter test

# Run with verbose output
flutter test --reporter expanded
```

\#### Generate Coverage Report
```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
# Windows
start coverage/html/index.html

# macOS
open coverage/html/index.html

# Linux
xdg-open coverage/html/index.html
```

\#### Run Specific Test Files
```bash
# Run single test file
flutter test test/unit/services/agora_service_test.dart

# Run tests matching pattern
flutter test --name "AgoraService"
```

\### Test Standards

\#### Test Naming Convention
```dart
// Pattern: methodName_stateUnderTest_expectedBehavior
test('signIn_withValidCredentials_returnsUser', () { ... });
test('signIn_withInvalidCredentials_returnsFailure', () { ... });
test('joinChannel_withExpiredToken_throwsException', () { ... });
```

\#### Critical Testing Rules

1. **Test Persistence Rule**:
   - All 627+ existing tests MUST pass
   - No breaking changes allowed
   - New features require corresponding unit tests

2. **Platform Mocking Rule**:
   - Use MethodChannel mocks for native-dependent services
   - Handle `MissingPluginException` in tests
   - Ensures CI stability across all environments

3. **Coverage Requirements**:
   - New code must maintain or improve coverage
   - Critical paths require 100% coverage
   - Test both happy paths and edge cases

\### Firebase Emulator Setup

For local testing with Firebase services:

```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize emulators (first time only)
firebase init emulators

# Start emulators
firebase emulators:start

# In another terminal, run tests
flutter test
```

\#### Emulator Configuration

```json
// firebase.json
{
  "emulators": {
    "firestore": {
      "port": 8080
    },
    "auth": {
      "port": 9099
    },
    "functions": {
      "port": 5001
    }
  }
}
```

\#### Connect Tests to Emulators

```dart
// In test setup
void main() {
  setUpAll(() async {
    // Connect to Firestore emulator
    FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'elajtech',
    ).useFirestoreEmulator('localhost', 8080);
    
    // Connect to Auth emulator
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    
    // Connect to Functions emulator
    FirebaseFunctions.instanceFor(region: 'europe-west1')
      .useFunctionsEmulator('localhost', 5001);
  });
}
```

\### Key Test Suites

\#### 1. Authentication Tests
- User sign-in/sign-out flows
- Token refresh handling
- Permission validation
- Role-based access control

\#### 2. Video Call Tests
- Agora token generation
- Channel join/leave operations
- Connection state handling
- Error recovery mechanisms

\#### 3. Repository Tests
- CRUD operations for all entities
- Error handling with `Either<Failure, T>`
- Firestore transaction handling
- Data validation

\#### 4. EMR Tests
- Medical record creation/updates
- 24-hour edit window enforcement
- Specialty-specific validations
- Clinic isolation verification

\### Continuous Integration

Tests run automatically on:
- Pull request creation
- Commits to main branch
- Pre-deployment checks

\#### CI Pipeline
```yaml
# Example GitHub Actions workflow
name: Test Suite
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter test --reporter expanded
```

---

\## 🔧 Core Modules



\### 1. Video Engine (Agora Integration)



\*\*File\*\*: \[`lib/core/services/agora\_service.dart`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/core/services/agora\_service.dart)



\#### Responsibilities

\- Initialize Agora RTC Engine with App ID

\- Join/leave video channels with secure tokens

\- Control audio/video (mute, unmute, switch camera)

\- Handle remote user events (join, leave)

\- Monitor connection state and errors

\- Integrate with Call Monitoring Service



\#### Key Features

\- \*\*Singleton Pattern\*\* for global access

\- \*\*Event Stream\*\* for UI updates

\- \*\*Automatic Permission Handling\*\* (camera, microphone)

\- \*\*Connection Failure Detection\*\* with automatic logging

\- \*\*Media Device Error Tracking\*\* (camera/microphone failures)



\#### Token Security

```dart

// Tokens are generated server-side via Cloud Functions

// Client receives:

// - agoraToken: JWT token with 1-hour expiration

// - agoraChannelName: Unique channel identifier

// - agoraUid: User ID within the channel

```



\#### Configuration

```dart

VideoEncoderConfiguration(

&nbsp; dimensions: VideoDimensions(width: 640, height: 480),

&nbsp; frameRate: 15,

&nbsp; bitrate: 0, // Auto-adjust

&nbsp; orientationMode: OrientationMode.orientationModeAdaptive,

)

```



---



\### 2. VoIP Call System



\*\*File\*\*: \[`lib/core/services/voip\_call\_service.dart`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/core/services/voip\_call\_service.dart)



\#### Platform Integration



| Platform | Technology | Features |

|----------|-----------|----------|

| \*\*iOS\*\* | CallKit | Native incoming call UI, lock screen display, system integration |

| \*\*Android\*\* | ConnectionService | Full-screen incoming call, notification channel, system ringtone |



\#### Call Flow



```mermaid

sequenceDiagram

&nbsp;   participant D as Doctor

&nbsp;   participant CF as Cloud Functions

&nbsp;   participant FCM as Firebase Messaging

&nbsp;   participant P as Patient Device

&nbsp;   participant CK as CallKit/ConnectionService

&nbsp;   

&nbsp;   D->>CF: startAgoraCall(appointmentId)

&nbsp;   CF->>CF: Generate Agora Tokens

&nbsp;   CF->>FCM: Send VoIP Notification

&nbsp;   FCM->>P: High-Priority Message

&nbsp;   P->>CK: showIncomingCall()

&nbsp;   CK->>P: Display Native Call UI

&nbsp;   P->>CK: Accept Call

&nbsp;   CK->>P: Join Agora Channel

&nbsp;   P->>D: Video Call Connected

```



\#### VoIP Notification Payload



```javascript

// FCM Message Structure

{

&nbsp; token: patientFcmToken,

&nbsp; notification: {

&nbsp;   title: `مكالمة واردة من ${doctorName}`,

&nbsp;   body: 'اضغط للرد على الاستشارة'

&nbsp; },

&nbsp; data: {

&nbsp;   type: 'incoming\_call',

&nbsp;   appointmentId: '...',

&nbsp;   doctorName: '...',

&nbsp;   agoraChannelName: '...',

&nbsp;   agoraToken: '...',

&nbsp;   agoraUid: '...'

&nbsp; },

&nbsp; android: {

&nbsp;   priority: 'high',

&nbsp;   notification: {

&nbsp;     channelId: 'incoming\_calls',

&nbsp;     priority: 'max',

&nbsp;     sound: 'default'

&nbsp;   }

&nbsp; },

&nbsp; apns: {

&nbsp;   headers: { 'apns-priority': '10' },

&nbsp;   payload: {

&nbsp;     aps: {

&nbsp;       'content-available': 1,

&nbsp;       sound: 'default'

&nbsp;     }

&nbsp;   }

&nbsp; }

}

```



\#### Cold Start Handling

The system handles app launch from terminated state:

```dart

// Check for pending calls on app startup

await \_checkActiveCallsOnStartup();



// Restore call data from CallKit/ConnectionService

final activeCalls = await FlutterCallkitIncoming.activeCalls();

if (activeCalls.isNotEmpty) {

&nbsp; final callData = activeCalls.last\['extra'];

&nbsp; // Restore agoraToken, channelName, appointmentId

}

```



---



\### 3. Call Monitoring Service



\*\*File\*\*: \[`lib/core/services/call\_monitoring\_service.dart`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/core/services/call\_monitoring\_service.dart)



\#### Purpose

Comprehensive logging system for debugging and analytics.



\#### Logged Events



| Event Type | Trigger | Data Collected |

|-----------|---------|----------------|

| `call\_attempt` | Doctor initiates call | User ID, appointment ID, device info |

| `call\_started` | Successfully joined channel | Channel name, Agora UID |

| `call\_error` | Any failure during call | Error type, message, stack trace, device info |

| `connection\_failure` | Network disconnection | Connection state, reason, metadata |

| `media\_device\_error` | Camera/mic failure | Device type, error message |

| `call\_ended` | Call terminated | Duration, end reason |



\#### Firestore Schema (`call\_logs` collection)



```typescript

interface CallLog {

&nbsp; id: string;                    // UUID

&nbsp; appointmentId: string;

&nbsp; userId: string;                // Doctor or patient ID

&nbsp; eventType: CallLogEventType;

&nbsp; timestamp: Timestamp;

&nbsp; errorCode?: string;

&nbsp; errorMessage?: string;

&nbsp; stackTrace?: string;

&nbsp; deviceInfo?: DeviceInfoModel;

&nbsp; metadata?: Record<string, any>;

}

```



\#### Integration with Agora Service

```dart

// Automatic logging on connection state changes

onConnectionStateChanged: (connection, state, reason) async {

&nbsp; if (state == ConnectionStateType.connectionStateFailed) {

&nbsp;   await \_callMonitoringService.logConnectionFailure(

&nbsp;     appointmentId: \_currentAppointmentId!,

&nbsp;     userId: \_currentUserId!,

&nbsp;     reason: 'Connection state: $state, Reason: $reason',

&nbsp;     metadata: {

&nbsp;       'connectionState': state.toString(),

&nbsp;       'connectionReason': reason.toString(),

&nbsp;     },

&nbsp;   );

&nbsp; }

}

```



---



\### 4. Role-Based Dashboards

The app implements a dynamic dashboard system based on user roles (Admin, Doctor, Patient).

**Routing Logic**:
- **Admin** → [`AdminDashboardScreen`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/features/admin/presentation/screens/admin_dashboard_screen.dart)
- **Doctor** → [`DoctorDashboardScreen`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/features/doctor/dashboard/presentation/screens/doctor_dashboard_screen.dart)
- **Patient** → [`PatientMainScreen`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/features/patient/navigation/presentation/screens/patient_main_screen.dart)

**Account Status (`isActive`)**:
- If `isActive == false`, the user is logged out with the message: *'الحساب معطّل، برجاء التواصل مع الدعم.'* (Account disabled, please contact support).

**Login & Role-Based Routing Quality**:
The login and role-based routing (Admin / Doctor / Patient) flows are fully covered by unit and widget tests, including edge cases such as inactive accounts (`isActive == false`), unknown `userType` values, initial sync race conditions (`isAuthenticated == true` while `user == null`), and pending VoIP call handling during the splash phase.

---

### 5. Authentication System (Phone Auth + Firestore)

Secure authentication is handled via Firebase Phone Auth with explicit Firestore user mapping.

**Implementation Details**:
- **Prerequisites**: Firebase Phone Auth enabled, SHA-1/SHA-256 fingerprints registered, and correct `google-services.json`.
- **Phone Format**: Must follow E.164 standard (e.g., +20...).
- **Key Files**:
  - [`auth_repository_impl.dart`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/features/auth/data/repositories/auth_repository_impl.dart): Handles `verifyPhoneNumber` and `signInWithCredential`.
  - [`auth_provider.dart`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/features/auth/providers/auth_provider.dart): Manages auth state and UI flow.
  - [`phone_login_screen.dart`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/features/auth/presentation/screens/phone_login_screen.dart): UI for number input.
  - [`otp_verification_screen.dart`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/features/auth/presentation/screens/otp_verification_screen.dart): UI for OTP verification.

> [!IMPORTANT]
> **Anonymous users are NOT allowed.** Every authenticated Firebase user MUST have a corresponding document under `users/{uid}` in the `elajtech` database to access application features.

---

### 6. Device Info Service



\*\*File\*\*: \[`lib/core/services/device\_info\_service.dart`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/core/services/device\_info\_service.dart)



\#### Collected Information



```dart

class DeviceInfoModel {

&nbsp; final String platform;           // 'android' or 'ios'

&nbsp; final String deviceModel;        // e.g., 'Samsung Galaxy S21'

&nbsp; final String manufacturer;       // e.g., 'Samsung', 'Apple'

&nbsp; final String osVersion;          // e.g., 'Android 13', 'iOS 16.5'

&nbsp; final String appVersion;         // e.g., '1.0.0'

&nbsp; final String appBuildNumber;     // e.g., '1'

&nbsp; final String connectionType;     // 'wifi', 'mobile', 'none'

&nbsp; final int? availableMemoryMB;    // Optional

&nbsp; final String screenResolution;   // e.g., '1080x2400'

}

```



\#### Caching Strategy

\- Device info is cached on first retrieval

\- Only `connectionType` is refreshed on subsequent calls

\- Cache can be manually cleared if needed



\#### Usage in Call Monitoring

```dart

// Automatically collected when logging errors

await \_callMonitoringService.logCallError(

&nbsp; appointmentId: appointmentId,

&nbsp; userId: userId,

&nbsp; errorType: 'join\_channel\_failed',

&nbsp; errorMessage: e.toString(),

&nbsp; // deviceInfo is auto-collected if not provided

);

```



---



\### 5. FCM Service



\*\*File\*\*: \[`lib/core/services/fcm\_service.dart`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/core/services/fcm\_service.dart)



\#### Message Handlers



1\. \*\*Background Handler\*\* (`@pragma('vm:entry-point')`)

&nbsp;  - Runs when app is in background or terminated

&nbsp;  - Displays incoming call UI via VoIPCallService

&nbsp;  - Must be top-level function



2\. \*\*Foreground Handler\*\* (`FirebaseMessaging.onMessage`)

&nbsp;  - Runs when app is active

&nbsp;  - Shows local notification for regular messages

&nbsp;  - Triggers incoming call UI for VoIP calls



3\. \*\*Notification Tap Handler\*\* (`FirebaseMessaging.onMessageOpenedApp`)

&nbsp;  - Runs when user taps notification

&nbsp;  - Routes to appropriate screen based on message type



\#### Permission Request

```dart

final settings = await \_messaging.requestPermission(

&nbsp; criticalAlert: true,  // Essential for VoIP calls

);

```



---



\## 🔐 Security Protocols



\### 1. Agora Token Security



\#### Server-Side Token Generation

\*\*File\*\*: \[`functions/index.js`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/functions/index.js) (Lines 23-51)



```javascript

function generateAgoraToken(channelName, uid, role = 'publisher', expirationTime = 3600) {

&nbsp; // Secrets stored in Firebase Functions config

&nbsp; const appId = functions.config().agora.app\_id;

&nbsp; const appCertificate = functions.config().agora.app\_certificate;

&nbsp; 

&nbsp; // Generate token with 1-hour expiration

&nbsp; const token = RtcTokenBuilder.buildTokenWithUid(

&nbsp;   appId,

&nbsp;   appCertificate,

&nbsp;   channelName,

&nbsp;   uid,

&nbsp;   RtcRole.PUBLISHER,

&nbsp;   currentTimestamp + expirationTime

&nbsp; );

&nbsp; 

&nbsp; return token;

}

```



\#### Environment Secrets Management



```bash

\# Set secrets via Firebase CLI

firebase functions:config:set agora.app\_id="YOUR\_APP\_ID"

firebase functions:config:set agora.app\_certificate="YOUR\_CERTIFICATE"



\# Access in code

process.env.AGORA\_APP\_ID  # Alternative method

```



> \*\*⚠️ CRITICAL\*\*: Never expose `AGORA\_APP\_CERTIFICATE` in client code. Always generate tokens server-side.



---



\### 2. Firebase Auth Integration



\#### Doctor Authorization Check

```javascript

// In startAgoraCall Cloud Function

if (appointment.doctorId !== doctorId) {

&nbsp; throw new functions.https.HttpsError(

&nbsp;   'permission-denied',

&nbsp;   'غير مصرح لك ببدء هذه المكالمة'

&nbsp; );

}

```



\#### User ID Binding

\- Each Agora channel is tied to a specific `appointmentId`

\- Only the assigned doctor can generate tokens for that appointment

\- Patient receives token via secure FCM data payload



---

#### Phone Number Format (E.164)

All phone numbers in AndroCare360 **must** be entered, stored, and processed in E.164 international format.

- Examples:
  - `+201008266544`
  - `+9665XXXXXXXX`

Any UI validation, repository logic, or Firestore fields that deal with phone numbers must assume and enforce this format.

---



\### 3. Firestore Security Rules



\*\*File\*\*: \[`firestore.rules`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/firestore.rules)



Key rules:

\- Users can only read/write their own profile

\- Appointments are accessible only to involved doctor and patient

\- Call logs are write-only (prevent tampering)

\- EMR records require role-based access



---



\### 4. Data Encryption



\*\*Service\*\*: \[`lib/core/services/encryption\_service.dart`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/core/services/encryption\_service.dart)



\- Sensitive data encrypted before storage

\- Uses `encrypt` package with AES encryption

\- Keys stored in `flutter\_secure\_storage`



---



\### 5. Firebase App Check (Temporarily Disabled)



\*\*Status\*\*: Commented out in \[`main.dart`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/main.dart) (Lines 159-232)



\*\*Planned Implementation\*\*:

\- \*\*Debug Mode\*\*: Debug provider for testing

\- \*\*Release Mode\*\*: Play Integrity API for Android

\- \*\*Purpose\*\*: Prevent unauthorized API access



---



\## 🚀 Technical Features



\### 1. Dynamic Connectivity Handling



\*\*Challenge\*\*: `connectivity\_plus` API changed from returning single value to list.



\*\*Solution\*\* (\[`device\_info\_service.dart`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/core/services/device\_info\_service.dart#L140-L171)):

```dart

Future<String> \_getConnectionType() async {

&nbsp; final dynamic result = await \_connectivity.checkConnectivity();

&nbsp; 

&nbsp; // Handle both single value and list return types

&nbsp; List<ConnectivityResult> results;

&nbsp; if (result is List<ConnectivityResult>) {

&nbsp;   results = result;

&nbsp; } else if (result is ConnectivityResult) {

&nbsp;   results = \[result];

&nbsp; } else {

&nbsp;   return 'unknown';

&nbsp; }

&nbsp; 

&nbsp; // Check for connection types

&nbsp; if (results.contains(ConnectivityResult.wifi)) return 'wifi';

&nbsp; if (results.contains(ConnectivityResult.mobile)) return 'mobile';

&nbsp; // ...

}

```



---



\### 2. Atomic Timestamp Updates



\*\*Usage\*\*: `FieldValue.serverTimestamp()` for accurate audit logs.



```javascript

// In Cloud Functions

await appointmentRef.update({

&nbsp; callStartedAt: admin.firestore.FieldValue.serverTimestamp(),

&nbsp; status: 'scheduled',

});

```



\*\*Benefits\*\*:

\- Eliminates client-server time drift

\- Ensures consistent timestamps across all clients

\- Critical for call duration calculations



---



\### 3. Lifecycle-Aware Call Cleanup



\*\*File\*\*: \[`main.dart`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/main.dart) (Lines 485-519)



```dart

@override

void didChangeAppLifecycleState(AppLifecycleState state) {

&nbsp; if (state == AppLifecycleState.resumed) {

&nbsp;   unawaited(\_checkAndCleanupCalls());

&nbsp; }

}



Future<void> \_checkAndCleanupCalls() async {

&nbsp; // Clean up CallKit/ConnectionService notifications

&nbsp; final appointmentId = await VoIPCallService().cleanupAfterCall();

&nbsp; 

&nbsp; if (appointmentId != null \&\& user.userType == UserType.doctor) {

&nbsp;   // Show confirmation dialog for doctor

&nbsp;   await \_showDoctorSessionEndDialog(appointmentId);

&nbsp; } else {

&nbsp;   // Auto-complete for patient

&nbsp;   await completeAppointment(appointmentId);

&nbsp; }

}

```



---



\### 4. Screen Resolution Detection



\*\*Android\*\*:

```dart

final view = ui.PlatformDispatcher.instance.views.first;

final physicalSize = view.physicalSize;

screenResolution = '${physicalSize.width.toInt()}x${physicalSize.height.toInt()}';

```



\*\*iOS\*\*: Uses device model name (can be enhanced with specific resolution mapping).



---



\### 5. Missed Call \& Decline Handling



\*\*VoIP Service\*\* (\[`voip\_call\_service.dart`](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/core/services/voip\_call\_service.dart#L342-L391)):



```dart

void \_onCallTimeout(CallEvent event) {

&nbsp; // Notify server of missed call

&nbsp; \_notifyServerMissedCall(appointmentId);

}



void \_onCallDeclined(CallEvent event) {

&nbsp; // Notify server of declined call

&nbsp; \_notifyServerCallDeclined(appointmentId);

}

```



\*\*Cloud Functions\*\* (to be implemented):

\- `handleMissedCall` - Updates appointment status, sends notification to doctor

\- `handleCallDeclined` - Logs decline reason, notifies doctor



---



\## 📊 Data Flow



\### Complete Call Initiation Flow



```mermaid

sequenceDiagram

&nbsp;   autonumber

&nbsp;   participant Doc as Doctor App

&nbsp;   participant CF as Cloud Functions

&nbsp;   participant FS as Firestore

&nbsp;   participant FCM as FCM

&nbsp;   participant Pat as Patient App

&nbsp;   participant Agora as Agora RTC

&nbsp;   

&nbsp;   Doc->>CF: startAgoraCall(appointmentId, doctorId, deviceInfo)

&nbsp;   CF->>CF: Verify authentication (context.auth)

&nbsp;   CF->>FS: Get appointment document

&nbsp;   CF->>CF: Verify doctorId matches appointment.doctorId

&nbsp;   CF->>CF: Generate unique channelName

&nbsp;   CF->>CF: Generate doctorToken (RtcTokenBuilder)

&nbsp;   CF->>CF: Generate patientToken (RtcTokenBuilder)

&nbsp;   CF->>FS: Update appointment with tokens \& channel

&nbsp;   CF->>FS: Log call\_attempt event to call\_logs

&nbsp;   CF->>FS: Get patient FCM token from users collection

&nbsp;   CF->>FCM: Send high-priority VoIP notification

&nbsp;   FCM->>Pat: Deliver notification (even if app closed)

&nbsp;   Pat->>Pat: VoIPCallService.showIncomingCall()

&nbsp;   Pat->>Pat: Display CallKit/ConnectionService UI

&nbsp;   CF->>FS: Log call\_started event

&nbsp;   CF->>Doc: Return { agoraToken, agoraChannelName, agoraUid }

&nbsp;   Doc->>Agora: Join channel with doctorToken

&nbsp;   

&nbsp;   Note over Pat: Patient accepts call

&nbsp;   Pat->>Agora: Join channel with patientToken

&nbsp;   Agora->>Doc: onUserJoined(patientUid)

&nbsp;   Agora->>Pat: onUserJoined(doctorUid)

&nbsp;   

&nbsp;   Note over Doc,Pat: Video call in progress

&nbsp;   

&nbsp;   Doc->>CF: endAgoraCall(appointmentId)

&nbsp;   CF->>FS: Update callEndedAt timestamp

&nbsp;   Doc->>Agora: Leave channel

&nbsp;   Pat->>Agora: Leave channel

```



\### Appointment Booking to Call Flow



1\. \*\*Booking Phase\*\*:

&nbsp;  - Patient selects doctor and time slot

&nbsp;  - `AppointmentRepository` creates Firestore document

&nbsp;  - Status: `pending` → `confirmed` (after doctor approval)



2\. \*\*Pre-Call Phase\*\*:

&nbsp;  - Doctor opens appointment screen

&nbsp;  - Sees "Start Video Call" button

&nbsp;  - Clicks button → triggers `startAgoraCall` Cloud Function



3\. \*\*Call Initiation\*\*:

&nbsp;  - Cloud Function generates Agora tokens

&nbsp;  - Updates Firestore with `agoraChannelName`, `agoraToken`, `doctorAgoraToken`

&nbsp;  - Sends FCM notification to patient



4\. \*\*Patient Notification\*\*:

&nbsp;  - FCM delivers high-priority message

&nbsp;  - `FCMService` background handler receives message

&nbsp;  - `VoIPCallService.showIncomingCall()` displays native UI



5\. \*\*Call Connection\*\*:

&nbsp;  - Patient accepts → joins Agora channel

&nbsp;  - Doctor already in channel

&nbsp;  - Agora triggers `onUserJoined` events

&nbsp;  - Video streams established



6\. \*\*Call End\*\*:

&nbsp;  - Either party leaves channel

&nbsp;  - `endAgoraCall` updates `callEndedAt`

&nbsp;  - Doctor manually marks appointment as `completed`



---



\## ✅ Testing \& QA Plan



\### 1. Video Call Testing



\#### Unit Tests

\- \[ ] Agora token generation (server-side)

\- \[ ] Channel name uniqueness

\- \[ ] Token expiration validation

\- \[ ] Permission handling



\#### Integration Tests

\- \[ ] End-to-end call flow (doctor → patient)

\- \[ ] Call acceptance from terminated app state

\- \[ ] Call decline handling

\- \[ ] Missed call timeout (60 seconds)

\- \[ ] Network disconnection recovery



\#### Device Tests



| Scenario | Android | iOS |

|----------|---------|-----|

| App in foreground | ✅ | ✅ |

| App in background | ✅ | ✅ |

| App terminated (cold start) | ⚠️ Test | ⚠️ Test |

| Lock screen display | ✅ | ✅ |

| Multiple incoming calls | ⚠️ Test | ⚠️ Test |



---



\### 2. Security Testing



\#### Checklist

\- \[ ] Verify Agora tokens expire after 1 hour

\- \[ ] Attempt unauthorized call start (wrong doctorId)

\- \[ ] Test Firestore security rules

\- \[ ] Validate FCM token refresh mechanism

\- \[ ] Test encryption service for sensitive data



---



\### 3. Performance Testing



\#### Metrics to Monitor

\- \*\*Call Setup Time\*\*: < 3 seconds from button press to ringing

\- \*\*Video Quality\*\*: Maintain 640x480 @ 15fps on 3G connection

\- \*\*Memory Usage\*\*: < 200MB during active call

\- \*\*Battery Drain\*\*: < 10% per 30-minute call



\#### Tools

\- Flutter DevTools (Memory, Performance tabs)

\- Agora Analytics Dashboard

\- Firebase Performance Monitoring



---



\### 4. Call Monitoring Validation



\#### Test Cases

\- \[ ] Verify `call\_attempt` logged on button press

\- \[ ] Verify `call\_started` logged after successful join

\- \[ ] Trigger connection failure → check `connection\_failure` log

\- \[ ] Disable camera → check `media\_device\_error` log

\- \[ ] Verify device info collected correctly



\#### Firestore Query Test

```dart

// Retrieve all error logs for debugging

final errorLogs = await CallMonitoringService().getErrorLogs(limit: 100);

for (final log in errorLogs) {

&nbsp; print('Error: ${log.errorCode} - ${log.errorMessage}');

&nbsp; print('Device: ${log.deviceInfo?.deviceModel}');

}

```



---



\### 5. UI/UX Testing



\#### Patient Experience

\- \[ ] Incoming call displays doctor name correctly

\- \[ ] Call UI shows video feed within 2 seconds

\- \[ ] Mute/unmute buttons work correctly

\- \[ ] Switch camera button works

\- \[ ] End call button terminates session



\#### Doctor Experience

\- \[ ] "Start Call" button enabled only for confirmed appointments

\- \[ ] Loading indicator during token generation

\- \[ ] Error message if patient doesn't answer (timeout)

\- \[ ] Confirmation dialog after call ends

\- \[ ] Appointment status updates to "completed"



---



\### 6. Edge Cases



| Scenario | Expected Behavior |

|----------|-------------------|

| Patient has no FCM token | Log error, show "Patient unreachable" message |

| Agora App ID missing | Cloud Function throws `failed-precondition` error |

| Network switches mid-call (WiFi → Mobile) | Agora auto-reconnects, log `connection\_failure` |

| App crashes during call | On restart, check for active calls and cleanup |

| Doctor cancels before patient answers | Send cancel notification, update appointment status |



---



\### 7. Regression Testing



After each deployment:

1\. Run full test suite (unit + integration)

2\. Perform manual smoke test:

&nbsp;  - Login as doctor

&nbsp;  - Start video call

&nbsp;  - Login as patient (different device)

&nbsp;  - Accept call

&nbsp;  - Verify video/audio

&nbsp;  - End call

&nbsp;  - Verify appointment marked as completed



---



\## 📚 Documentation

Comprehensive documentation is available to help you understand and contribute to AndroCare360.

\### Core Documentation

| Document | Description | Location |
|----------|-------------|----------|
| **README.md** | Project overview, architecture, and setup guide | Root directory |
| **CHANGELOG.md** | Version history and release notes | [CHANGELOG.md](CHANGELOG.md) |
| **CONTRIBUTING.md** | Development guidelines and contribution process | [CONTRIBUTING.md](CONTRIBUTING.md) |
| **API_DOCUMENTATION.md** | Cloud Functions API reference | [API_DOCUMENTATION.md](API_DOCUMENTATION.md) |

\### Code Documentation Standards

All code follows strict documentation standards:

\#### DartDoc Comments
- **Bilingual Documentation**: Arabic for medical/business logic, English for technical specifications
- **Class-Level Documentation**: Purpose, responsibilities, and usage examples
- **Method-Level Documentation**: Parameters, return values, exceptions, and examples
- **Field-Level Documentation**: Purpose and constraints

\#### Example Documentation

```dart
/// خدمة إدارة المكالمات المرئية عبر Agora
/// 
/// Video call management service using Agora RTC Engine
///
/// This service handles:
/// - Agora RTC Engine initialization
/// - Channel join/leave operations
/// - Audio/video control (mute, unmute, camera switch)
/// - Connection state monitoring
/// - Error handling and logging
///
/// **Usage Example:**
/// ```dart
/// final agoraService = getIt<AgoraService>();
/// await agoraService.initialize();
/// await agoraService.joinChannel(
///   token: 'agora_token',
///   channelName: 'channel_123',
///   uid: 12345,
/// );
/// ```
@LazySingleton()
class AgoraService {
  // Implementation...
}
```

\### API Documentation

For detailed Cloud Functions API documentation, see [API_DOCUMENTATION.md](API_DOCUMENTATION.md):

- **startAgoraCall**: Initiate video call with token generation
- **endAgoraCall**: End video call session
- **completeAppointment**: Mark appointment as completed

\#### Quick API Example

```dart
// Initialize with correct region
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

// Start video call
final result = await functions.httpsCallable('startAgoraCall').call({
  'appointmentId': 'apt_123',
  'doctorId': 'doctor_456',
});

// Use returned tokens
final agoraToken = result.data['agoraToken'];
final channelName = result.data['agoraChannelName'];
```

\### Critical Project Rules

\#### 1. Database ID Rule
⚠️ **NEVER use `FirebaseFirestore.instance`**

```dart
// ✅ CORRECT
final firestore = FirebaseFirestore.instanceFor(
  app: Firebase.app(),
  databaseId: 'elajtech',
);

// ❌ WRONG
final firestore = FirebaseFirestore.instance;
```

\#### 2. Cloud Functions Region Rule
All functions are deployed in **europe-west1** region:

```dart
// ✅ CORRECT
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

// ❌ WRONG
final functions = FirebaseFunctions.instance;
```

\#### 3. Build Runner Rule
Run after modifying `@injectable`, `@freezed`, or `@JsonSerializable`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

\#### 4. Clinic Isolation Rule
Each specialty clinic must have independent Model and Repository:
- ✅ `nutrition_emr_repository_impl.dart`
- ✅ `physiotherapy_emr_repository_impl.dart`
- ✅ `internal_medicine_emr_repository_impl.dart`
- ❌ Merged clinic logic in one file

\### Additional Resources

- **Agora Documentation**: https://docs.agora.io/
- **Firebase Documentation**: https://firebase.google.com/docs
- **Flutter Documentation**: https://docs.flutter.dev/
- **Riverpod Documentation**: https://riverpod.dev/

---



\## 📦 Dependencies



\### Core Dependencies



```yaml

\# Video \& VoIP

agora\_rtc\_engine: ^6.3.2

flutter\_callkit\_incoming: ^2.0.4+1

permission\_handler: ^12.0.1



\# Firebase

firebase\_core: ^3.8.1

firebase\_auth: ^5.3.3

cloud\_firestore: ^5.5.2

cloud\_functions: ^5.6.2

firebase\_messaging: ^15.2.10



\# State Management

flutter\_riverpod: ^2.5.1



\# Dependency Injection

get\_it: ^9.2.0

injectable: ^2.7.1+4



\# Device Info

device\_info\_plus: ^12.0.0

package\_info\_plus: ^8.1.3

connectivity\_plus: ^5.0.0



\# Utilities

uuid: any

encrypt: ^5.0.0

```



---



\## 🔄 Future Enhancements



1\. \*\*Firebase App Check\*\*: Re-enable Play Integrity for production

2\. \*\*Call Recording\*\*: Implement server-side recording with user consent

3\. \*\*Screen Sharing\*\*: Add Agora screen share extension

4\. \*\*Group Calls\*\*: Support multi-party consultations

5\. \*\*AI Transcription\*\*: Real-time medical transcription

6\. \*\*Analytics Dashboard\*\*: Admin panel for call quality metrics



---



\## 👥 Team Onboarding

\### For New Developers

Welcome to AndroCare360! Follow these steps to get started:

\#### 1. Read Documentation

Before writing any code, familiarize yourself with:
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Development guidelines, coding standards, and critical rules
- **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - Cloud Functions API reference
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and recent changes
- This README - Project architecture and technical overview

\#### 2. Setup Development Environment

```bash
# Install dependencies
flutter pub get

# Login to Firebase
firebase login

# Select the elajtech project
firebase use elajtech

# Verify Flutter installation
flutter doctor
```

\#### 3. Environment Secrets

Request the following from your team lead:
- Agora App ID and Certificate
- Firebase project access

Set Firebase Functions config:
```bash
firebase functions:config:set agora.app_id="YOUR_APP_ID"
firebase functions:config:set agora.app_certificate="YOUR_CERTIFICATE"
```

\#### 4. Run the App

```bash
# Run on connected device/emulator
flutter run

# Run with specific flavor (if applicable)
flutter run --flavor dev
```

\#### 5. Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

\#### 6. Deploy Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

\### Critical Rules to Remember

⚠️ **Before writing any code, review these critical rules:**

1. **Database ID**: Always use `databaseId: 'elajtech'` - NEVER use `FirebaseFirestore.instance`
2. **Cloud Functions Region**: Always specify `region: 'europe-west1'`
3. **Build Runner**: Run after modifying `@injectable`, `@freezed`, or `@JsonSerializable`
4. **Clinic Isolation**: Each specialty clinic has independent Model and Repository
5. **Test Persistence**: All 664+ tests must pass - no breaking changes
6. **Bilingual Documentation**: Use DartDoc in both Arabic and English

See [CONTRIBUTING.md](CONTRIBUTING.md) for complete details.

\### Key Files to Review

1. [`functions/index.js`](functions/index.js) - Cloud Functions implementation
2. [`lib/core/services/agora_service.dart`](lib/core/services/agora_service.dart) - Video engine
3. [`lib/core/services/voip_call_service.dart`](lib/core/services/voip_call_service.dart) - VoIP system
4. [`lib/main.dart`](lib/main.dart) - App initialization
5. [`lib/core/di/injection.dart`](lib/core/di/injection.dart) - Dependency injection setup

\### Development Workflow

1. **Create Feature Branch**: `git checkout -b feature/your-feature-name`
2. **Write Code**: Follow coding standards in CONTRIBUTING.md
3. **Write Tests**: Maintain 70%+ coverage
4. **Run Tests**: `flutter test` - all must pass
5. **Run Analyzer**: `flutter analyze` - no errors allowed
6. **Create PR**: Follow PR template in CONTRIBUTING.md
7. **Code Review**: Address reviewer feedback
8. **Merge**: After approval and passing CI

\### Getting Help

- **Technical Questions**: Review documentation first, then ask team lead
- **Bug Reports**: Check `call_logs` collection in Firestore for debugging
- **API Issues**: Consult [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
- **External Resources**:
  - Agora: https://docs.agora.io/
  - Firebase: https://firebase.google.com/docs
  - Flutter: https://docs.flutter.dev/

---

\## 📞 Support

For technical questions or issues:
- Review [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines
- Check [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for Cloud Functions reference
- Review `call_logs` collection in Firestore for debugging
- Consult external documentation (Agora, Firebase, Flutter)

---



\*\*Last Updated\*\*: 2026-02-16  
\*\*Version\*\*: 1.0.0  
\*\*Maintained by\*\*: AndroCare360 Development Team



