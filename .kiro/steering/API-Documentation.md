# AndroCare360 API Documentation

This document provides comprehensive documentation for all Cloud Functions APIs used in the AndroCare360 platform.

## Table of Contents

- [Introduction](#introduction)
- [Authentication](#authentication)
- [Region Configuration](#region-configuration)
- [API Endpoints](#api-endpoints)
  - [startAgoraCall](#startagoracall)
  - [endAgoraCall](#endagoracall)
  - [completeAppointment](#completeappointment)
- [Common Error Codes](#common-error-codes)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

---

## Introduction

AndroCare360 uses Firebase Cloud Functions (v2) to handle backend operations, particularly for video call management and appointment workflows.

### Recent Updates

**Deprecated API Migration (2026-02-16):**
The AndroCare360 codebase has been fully migrated to Flutter 3.27+ current APIs, eliminating all deprecated API warnings from source code. This ensures compatibility with future Flutter versions and maintains code quality standards. See `TASK_18_COMPLETION_REPORT.md` for details.

### Architecture Overview

- **Runtime**: Node.js
- **Region**: europe-west1 (CRITICAL - see [Region Configuration](#region-configuration))
- **Protocol**: HTTPS Callable Functions
- **Authentication**: Firebase Auth (required for all endpoints)

### Base Configuration

All Cloud Functions are deployed in the **europe-west1** region and require Firebase Authentication.

```dart
// Initialize Firebase Functions with correct region
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
```

---


## Authentication

All Cloud Functions require Firebase Authentication. The authentication token is automatically included when using Firebase's `httpsCallable` method.

### How Authentication Works

1. User signs in via Firebase Auth
2. Client automatically includes auth token in function calls
3. Server validates token and extracts user ID (`context.auth.uid`)
4. Functions check user permissions based on user ID

### Including Auth Token

Firebase automatically includes the auth token when using `httpsCallable`:

```dart
// Auth token is automatically included
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

try {
  final result = await functions.httpsCallable('startAgoraCall').call({
    'appointmentId': 'apt_123',
    'doctorId': 'doctor_456',
  });
  // Process result
} on FirebaseFunctionsException catch (e) {
  // Handle error
}
```

### Handling Authentication Errors

```dart
try {
  final result = await functions.httpsCallable('startAgoraCall').call(data);
} on FirebaseFunctionsException catch (e) {
  if (e.code == 'unauthenticated') {
    // User not signed in or token expired
    // Redirect to login screen
    Navigator.pushReplacementNamed(context, '/login');
  } else if (e.code == 'permission-denied') {
    // User doesn't have required permissions
    showError('You do not have permission to perform this action');
  }
}
```

### Token Refresh

Firebase automatically refreshes auth tokens. If you encounter authentication errors:

1. Check if user is still signed in:
   ```dart
   final user = FirebaseAuth.instance.currentUser;
   if (user == null) {
     // User not signed in
   }
   ```

2. Force token refresh (if needed):
   ```dart
   await FirebaseAuth.instance.currentUser?.getIdToken(true);
   ```

3. Retry the function call

---


## ⚠️ CRITICAL: Region Configuration

All Cloud Functions for AndroCare360 are deployed in the **europe-west1** region.

### Flutter Configuration

**✅ CORRECT:**

```dart
// Always specify the region
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

// Use the configured instance for all calls
final result = await functions.httpsCallable('startAgoraCall').call(data);
```

**❌ INCORRECT:**

```dart
// DON'T DO THIS! Will result in NOT_FOUND error
final functions = FirebaseFunctions.instance; // ❌ WRONG!

// This will fail because it uses the default region
final result = await functions.httpsCallable('startAgoraCall').call(data);
```

### Error Handling for Wrong Region

If you see "NOT_FOUND" errors, verify you're using the correct region:

**Error:**
```
FirebaseFunctionsException: NOT_FOUND
Function 'startAgoraCall' not found
```

**Solution:**
1. Ensure `region: 'europe-west1'` is specified in `FirebaseFunctions.instanceFor()`
2. Check function name spelling
3. Verify functions are deployed: `firebase deploy --only functions`

### Why Region Matters

- Cloud Functions are region-specific
- Using the wrong region results in "NOT_FOUND" errors
- The default region may not be europe-west1
- Always explicitly specify the region

---


## API Endpoints

### startAgoraCall

Initiates a video call session by generating Agora tokens and notifying the patient.

**Endpoint:** `startAgoraCall`  
**Method:** HTTPS Callable Function  
**Region:** europe-west1  
**Authentication:** Required (Firebase Auth)

#### Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `appointmentId` | string | Yes | Unique appointment identifier |
| `doctorId` | string | Yes | Doctor's user ID (must match authenticated user) |
| `deviceInfo` | object | No | Device information for logging (platform, deviceModel, osVersion) |

#### Request Example

```dart
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

try {
  final result = await functions.httpsCallable('startAgoraCall').call({
    'appointmentId': 'apt_123456',
    'doctorId': 'doctor_789',
    'deviceInfo': {
      'platform': 'android',
      'deviceModel': 'Samsung Galaxy S21',
      'osVersion': 'Android 13',
    },
  });

  final data = result.data;
  print('Agora Token: ${data['agoraToken']}');
  print('Channel Name: ${data['agoraChannelName']}');
  print('UID: ${data['agoraUid']}');
  
  // Use the token to join Agora channel
  await agoraService.joinChannel(
    token: data['agoraToken'],
    channelName: data['agoraChannelName'],
    uid: data['agoraUid'],
  );
} on FirebaseFunctionsException catch (e) {
  print('Error: ${e.code} - ${e.message}');
  // Handle specific error codes
  if (e.code == 'permission-denied') {
    showError('You are not authorized to start this call');
  } else if (e.code == 'not-found') {
    showError('Appointment not found');
  }
}
```

#### Response

**Success (200):**

```json
{
  "agoraToken": "006abc123def456...",
  "agoraChannelName": "channel_apt_123456_1234567890",
  "agoraUid": 12345
}
```

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `agoraToken` | string | JWT token for joining Agora channel (1-hour expiration) |
| `agoraChannelName` | string | Unique channel identifier for this call |
| `agoraUid` | number | User ID within the Agora channel |


#### Error Responses

| Code | Message | Description |
|------|---------|-------------|
| `unauthenticated` | "المستخدم غير مصادق عليه" | User not authenticated with Firebase Auth |
| `permission-denied` | "غير مصرح لك ببدء هذه المكالمة" | Doctor ID doesn't match appointment's doctorId |
| `not-found` | "الموعد غير موجود" | Appointment document not found in Firestore |
| `failed-precondition` | "Agora credentials not configured" | Server configuration error (contact admin) |
| `invalid-argument` | "appointmentId is required" | Missing required parameter |

#### Side Effects

1. **Updates Appointment Document:**
   - `agoraChannelName`: Unique channel identifier
   - `agoraToken`: Patient's token for joining
   - `doctorAgoraToken`: Doctor's token for joining
   - `callStartedAt`: Server timestamp

2. **Logs Call Attempt:**
   - Creates document in `call_logs` collection
   - Event type: `call_attempt`
   - Includes user ID, appointment ID, device info

3. **Sends FCM Notification:**
   - Retrieves patient's FCM token from users collection
   - Sends high-priority VoIP notification
   - Includes call data (tokens, channel name, doctor info)

#### Security

- Validates authenticated user matches `doctorId` parameter
- Generates tokens with 1-hour expiration
- Tokens are single-use per appointment
- Only the assigned doctor can initiate the call

#### Token Expiration

- Agora tokens expire after **1 hour**
- Calls are expected to complete within this timeframe
- For longer calls, implement token refresh mechanism (future enhancement)

---


### endAgoraCall

Marks the end of a video call session and updates the appointment record.

**Endpoint:** `endAgoraCall`  
**Method:** HTTPS Callable Function  
**Region:** europe-west1  
**Authentication:** Required (Firebase Auth)

#### Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `appointmentId` | string | Yes | Unique appointment identifier |

#### Request Example

```dart
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

try {
  await functions.httpsCallable('endAgoraCall').call({
    'appointmentId': 'apt_123456',
  });
  
  print('Call ended successfully');
  
  // Leave the Agora channel
  await agoraService.leaveChannel();
  
  // Navigate to completion screen
  Navigator.pushReplacementNamed(context, '/call-completed');
} on FirebaseFunctionsException catch (e) {
  print('Error ending call: ${e.code} - ${e.message}');
  
  if (e.code == 'not-found') {
    showError('Appointment not found');
  }
}
```

#### Response

**Success (200):**

```json
{
  "success": true,
  "message": "Call ended successfully"
}
```

#### Error Responses

| Code | Message | Description |
|------|---------|-------------|
| `unauthenticated` | "المستخدم غير مصادق عليه" | User not authenticated |
| `not-found` | "الموعد غير موجود" | Appointment not found |
| `invalid-argument` | "appointmentId is required" | Missing required parameter |

#### Side Effects

1. **Updates Appointment Document:**
   - `callEndedAt`: Server timestamp marking call end time

2. **Logs Call End Event:**
   - Creates document in `call_logs` collection
   - Event type: `call_ended`
   - Includes call duration (calculated from callStartedAt to callEndedAt)

#### Usage Notes

- Can be called by either doctor or patient
- Should be called before leaving the Agora channel
- Call duration is automatically calculated server-side

---


### completeAppointment

Marks an appointment as completed after the consultation, updating its status and completion timestamp.

**Endpoint:** `completeAppointment`  
**Method:** HTTPS Callable Function  
**Region:** europe-west1  
**Authentication:** Required (Firebase Auth)

#### Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `appointmentId` | string | Yes | Unique appointment identifier |

#### Request Example

```dart
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

try {
  await functions.httpsCallable('completeAppointment').call({
    'appointmentId': 'apt_123456',
  });
  
  print('Appointment marked as completed');
  
  // Show success message
  showSuccess('Appointment completed successfully');
  
  // Navigate to appointments list
  Navigator.pushReplacementNamed(context, '/appointments');
} on FirebaseFunctionsException catch (e) {
  print('Error completing appointment: ${e.code} - ${e.message}');
  
  if (e.code == 'not-found') {
    showError('Appointment not found');
  } else if (e.code == 'permission-denied') {
    showError('You do not have permission to complete this appointment');
  }
}
```

#### Response

**Success (200):**

```json
{
  "success": true,
  "message": "Appointment completed successfully"
}
```

#### Error Responses

| Code | Message | Description |
|------|---------|-------------|
| `unauthenticated` | "المستخدم غير مصادق عليه" | User not authenticated |
| `permission-denied` | "غير مصرح لك بإكمال هذا الموعد" | User not authorized to complete this appointment |
| `not-found` | "الموعد غير موجود" | Appointment not found |
| `invalid-argument` | "appointmentId is required" | Missing required parameter |

#### Side Effects

1. **Updates Appointment Document:**
   - `status`: Changed to "completed"
   - `completedAt`: Server timestamp marking completion time

2. **Enables EMR Access:**
   - After completion, EMR records can be created/edited
   - 24-hour edit window starts from completion time

#### Usage Notes

- Typically called by the doctor after the consultation
- Should be called after `endAgoraCall`
- Triggers the 24-hour edit window for medical records
- Appointment status change is permanent (cannot be reverted)

#### Workflow

```
1. Doctor starts call → startAgoraCall()
2. Video consultation happens
3. Doctor ends call → endAgoraCall()
4. Doctor completes appointment → completeAppointment()
5. Doctor can now add EMR, prescriptions, lab requests (24-hour window)
```

---


## Common Error Codes

All Cloud Functions use standard Firebase Functions error codes. Here are the most common ones:

| Code | Description | Common Causes | Solution |
|------|-------------|---------------|----------|
| `unauthenticated` | User not authenticated | User not signed in, token expired | Sign in user, refresh token |
| `permission-denied` | Insufficient permissions | User doesn't have required role, wrong user ID | Verify user permissions, check authorization logic |
| `not-found` | Resource not found | Appointment/user doesn't exist, wrong region | Check resource ID, verify region configuration |
| `invalid-argument` | Invalid parameters | Missing required parameter, wrong data type | Verify all required parameters are provided |
| `failed-precondition` | Server configuration error | Missing Agora credentials, database misconfiguration | Contact system administrator |
| `unavailable` | Service temporarily unavailable | Network issue, Firebase outage | Retry after a short delay |
| `deadline-exceeded` | Request timeout | Slow network, large payload | Check network connection, reduce payload size |
| `internal` | Internal server error | Unexpected exception in function | Check Cloud Functions logs, contact support |

### Error Handling Pattern

```dart
try {
  final result = await functions.httpsCallable('functionName').call(data);
  // Handle success
} on FirebaseFunctionsException catch (e) {
  switch (e.code) {
    case 'unauthenticated':
      // Redirect to login
      Navigator.pushReplacementNamed(context, '/login');
      break;
    case 'permission-denied':
      showError('You do not have permission to perform this action');
      break;
    case 'not-found':
      showError('Resource not found');
      break;
    case 'unavailable':
      // Retry logic
      await Future.delayed(Duration(seconds: 2));
      // Retry the call
      break;
    default:
      showError('An error occurred: ${e.message}');
  }
} catch (e) {
  // Handle unexpected errors
  showError('Unexpected error: $e');
}
```

---


## Troubleshooting

### "NOT_FOUND" Error

**Problem:** Function not found error when calling Cloud Functions.

```
FirebaseFunctionsException: NOT_FOUND
Function 'startAgoraCall' not found
```

**Solutions:**

1. **Verify Region Configuration:**
   ```dart
   // Make sure you're using europe-west1
   final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
   ```

2. **Check Function Name:**
   - Ensure function name is spelled correctly
   - Function names are case-sensitive

3. **Verify Deployment:**
   ```bash
   # Check if functions are deployed
   firebase functions:list
   
   # Deploy functions if needed
   firebase deploy --only functions
   ```

### "UNAUTHENTICATED" Error

**Problem:** User authentication failed.

```
FirebaseFunctionsException: UNAUTHENTICATED
The request does not have valid authentication credentials
```

**Solutions:**

1. **Check User Sign-In Status:**
   ```dart
   final user = FirebaseAuth.instance.currentUser;
   if (user == null) {
     // User not signed in - redirect to login
     Navigator.pushReplacementNamed(context, '/login');
   }
   ```

2. **Refresh Auth Token:**
   ```dart
   try {
     await FirebaseAuth.instance.currentUser?.getIdToken(true);
     // Retry the function call
   } catch (e) {
     // Token refresh failed - user needs to sign in again
   }
   ```

3. **Re-authenticate User:**
   ```dart
   await FirebaseAuth.instance.signOut();
   // Navigate to login screen
   ```

### "PERMISSION_DENIED" Error

**Problem:** User doesn't have required permissions.

```
FirebaseFunctionsException: PERMISSION_DENIED
غير مصرح لك ببدء هذه المكالمة
```

**Solutions:**

1. **Verify User Role:**
   ```dart
   final user = ref.watch(authProvider).user;
   if (user?.userType != 'doctor') {
     showError('Only doctors can start video calls');
     return;
   }
   ```

2. **Check User ID Match:**
   ```dart
   // For startAgoraCall, doctorId must match authenticated user
   final doctorId = FirebaseAuth.instance.currentUser?.uid;
   await functions.httpsCallable('startAgoraCall').call({
     'appointmentId': appointmentId,
     'doctorId': doctorId, // Must match current user
   });
   ```

### Database Configuration Issue (FIXED)

**Symptom**: "Appointment Not Found" errors even though appointments exist in Firestore.

**Root Cause**: The Firebase Admin SDK in Cloud Functions wasn't consistently applying the `databaseId` configuration, causing queries to fall back to the default database instead of the `elajtech` database.

**Fix Applied** (2026-02-13):
```javascript
// In functions/index.js
const db = admin.firestore();
db.settings({ databaseId: 'elajtech' }); // ✅ CRITICAL FIX
```

**What This Fixes**:
- ✅ Appointment lookups now consistently target the `elajtech` database
- ✅ Call logs are written to the correct database
- ✅ Patient FCM tokens are retrieved from the correct database
- ✅ All Firestore operations use the `elajtech` database

**Verification**:
All error logs now include database context in metadata:
```javascript
{
  errorMessage: '[DB: elajtech] الموعد غير موجود في قاعدة البيانات elajtech',
  metadata: {
    databaseId: 'elajtech',
    queriedDatabase: 'elajtech',
    queriedCollection: 'appointments',
    queriedDocumentId: 'apt_123'
  }
}
```

**For Developers**:
If you're working on Cloud Functions, always ensure:
1. Database configuration is applied: `db.settings({ databaseId: 'elajtech' })`
2. All collection references use the configured `db` instance
3. Tests verify database configuration correctness

**Reference**: See `functions/README.md` for complete database configuration requirements.


### Token Expiration

**Problem:** Agora tokens expire after 1 hour.

**Current Behavior:**
- Tokens are generated with 1-hour expiration
- Tokens are single-use per appointment
- Calls are expected to complete within 1 hour

**Solutions:**

1. **For Short Calls (< 1 hour):**
   - No action needed
   - Current implementation handles this automatically

2. **For Long Calls (> 1 hour):**
   - Implement token refresh mechanism (future enhancement)
   - Monitor token expiration time
   - Request new token before expiration

3. **Workaround:**
   ```dart
   // Monitor call duration
   final callStartTime = DateTime.now();
   
   // Check if approaching 1 hour
   Timer.periodic(Duration(minutes: 50), (timer) {
     final duration = DateTime.now().difference(callStartTime);
     if (duration.inMinutes >= 50) {
       // Warn user about approaching time limit
       showWarning('Call will end in 10 minutes due to time limit');
     }
   });
   ```

### Network Issues

**Problem:** Slow network or connectivity issues.

**Solutions:**

1. **Implement Retry Logic:**
   ```dart
   Future<T> retryFunction<T>(
     Future<T> Function() function, {
     int maxAttempts = 3,
     Duration delay = const Duration(seconds: 2),
   }) async {
     for (int attempt = 1; attempt <= maxAttempts; attempt++) {
       try {
         return await function();
       } catch (e) {
         if (attempt == maxAttempts) rethrow;
         await Future.delayed(delay);
       }
     }
     throw Exception('Max retry attempts reached');
   }
   
   // Usage
   final result = await retryFunction(() =>
     functions.httpsCallable('startAgoraCall').call(data)
   );
   ```

2. **Check Network Status:**
   ```dart
   final connectivity = await Connectivity().checkConnectivity();
   if (connectivity == ConnectivityResult.none) {
     showError('No internet connection');
     return;
   }
   ```

3. **Add Timeout Handling:**
   ```dart
   try {
     final result = await functions
       .httpsCallable('startAgoraCall')
       .call(data)
       .timeout(
         Duration(seconds: 30),
         onTimeout: () {
           throw TimeoutException('Function call timed out');
         },
       );
   } on TimeoutException {
     showError('Request timed out. Please check your connection.');
   }
   ```

### Debugging Tips

1. **Enable Cloud Functions Logging:**
   ```dart
   // In main.dart (debug mode only)
   if (kDebugMode) {
     FirebaseFunctions.instanceFor(region: 'europe-west1')
       .useFunctionsEmulator('localhost', 5001);
   }
   ```

2. **Check Cloud Functions Logs:**
   ```bash
   # View real-time logs
   firebase functions:log
   
   # View logs for specific function
   firebase functions:log --only startAgoraCall
   ```

3. **Monitor Call Logs Collection:**
   ```dart
   // Query recent error logs
   final errorLogs = await FirebaseFirestore.instanceFor(
     app: Firebase.app(),
     databaseId: 'elajtech',
   )
     .collection('call_logs')
     .where('eventType', isEqualTo: 'call_error')
     .orderBy('timestamp', descending: true)
     .limit(10)
     .get();
   
   for (final doc in errorLogs.docs) {
     print('Error: ${doc.data()}');
   }
   ```

---


## Best Practices

### Error Handling

1. **Always Use Typed Exception Handling:**
   ```dart
   try {
     final result = await functions.httpsCallable('startAgoraCall').call(data);
     // Process result
   } on FirebaseFunctionsException catch (e) {
     // Handle Firebase Functions specific errors
     _handleFunctionsError(e);
   } on TimeoutException catch (e) {
     // Handle timeout errors
     showError('Request timed out');
   } catch (e) {
     // Handle unexpected errors
     debugPrint('Unexpected error: $e');
     showError('An unexpected error occurred');
   }
   ```

2. **Provide User-Friendly Error Messages:**
   ```dart
   void _handleFunctionsError(FirebaseFunctionsException e) {
     final message = switch (e.code) {
       'unauthenticated' => 'Please sign in to continue',
       'permission-denied' => 'You do not have permission to perform this action',
       'not-found' => 'The requested resource was not found',
       'unavailable' => 'Service temporarily unavailable. Please try again.',
       _ => 'An error occurred: ${e.message}',
     };
     
     showError(message);
   }
   ```

3. **Log Errors for Debugging:**
   ```dart
   try {
     final result = await functions.httpsCallable('startAgoraCall').call(data);
   } on FirebaseFunctionsException catch (e, stackTrace) {
     // Log to Firebase Crashlytics or monitoring service
     if (kDebugMode) {
       debugPrint('Function error: ${e.code} - ${e.message}');
       debugPrint('Stack trace: $stackTrace');
     }
     
     // Log to call monitoring service
     await CallMonitoringService().logCallError(
       appointmentId: appointmentId,
       userId: userId,
       errorType: 'cloud_function_error',
       errorMessage: '${e.code}: ${e.message}',
       stackTrace: stackTrace.toString(),
     );
   }
   ```

### Retry Strategies

1. **Implement Exponential Backoff:**
   ```dart
   Future<T> retryWithBackoff<T>(
     Future<T> Function() function, {
     int maxAttempts = 3,
     Duration initialDelay = const Duration(seconds: 1),
   }) async {
     Duration delay = initialDelay;
     
     for (int attempt = 1; attempt <= maxAttempts; attempt++) {
       try {
         return await function();
       } on FirebaseFunctionsException catch (e) {
         // Don't retry on client errors
         if (e.code == 'invalid-argument' ||
             e.code == 'permission-denied' ||
             e.code == 'unauthenticated') {
           rethrow;
         }
         
         if (attempt == maxAttempts) rethrow;
         
         // Exponential backoff
         await Future.delayed(delay);
         delay *= 2;
       }
     }
     throw Exception('Max retry attempts reached');
   }
   
   // Usage
   final result = await retryWithBackoff(() =>
     functions.httpsCallable('startAgoraCall').call(data)
   );
   ```

2. **Retry Only on Transient Errors:**
   ```dart
   bool isRetryableError(String code) {
     return code == 'unavailable' ||
            code == 'deadline-exceeded' ||
            code == 'internal';
   }
   
   Future<T> smartRetry<T>(Future<T> Function() function) async {
     try {
       return await function();
     } on FirebaseFunctionsException catch (e) {
       if (isRetryableError(e.code)) {
         // Wait and retry once
         await Future.delayed(Duration(seconds: 2));
         return await function();
       }
       rethrow;
     }
   }
   ```

### Timeout Handling

1. **Set Appropriate Timeouts:**
   ```dart
   // Short timeout for quick operations
   final result = await functions
     .httpsCallable('endAgoraCall')
     .call(data)
     .timeout(Duration(seconds: 10));
   
   // Longer timeout for complex operations
   final result = await functions
     .httpsCallable('startAgoraCall')
     .call(data)
     .timeout(Duration(seconds: 30));
   ```

2. **Handle Timeouts Gracefully:**
   ```dart
   try {
     final result = await functions
       .httpsCallable('startAgoraCall')
       .call(data)
       .timeout(
         Duration(seconds: 30),
         onTimeout: () async {
           // Log timeout
           await CallMonitoringService().logCallError(
             appointmentId: appointmentId,
             userId: userId,
             errorType: 'timeout',
             errorMessage: 'Function call timed out after 30 seconds',
           );
           
           throw TimeoutException('Call initiation timed out');
         },
       );
   } on TimeoutException {
     showError('Request timed out. Please check your connection and try again.');
   }
   ```

### Logging Recommendations

1. **Log All Function Calls:**
   ```dart
   Future<T> callFunctionWithLogging<T>(
     String functionName,
     Map<String, dynamic> data,
   ) async {
     if (kDebugMode) {
       debugPrint('Calling function: $functionName');
       debugPrint('Parameters: $data');
     }
     
     final startTime = DateTime.now();
     
     try {
       final result = await functions.httpsCallable(functionName).call(data);
       
       final duration = DateTime.now().difference(startTime);
       if (kDebugMode) {
         debugPrint('Function $functionName completed in ${duration.inMilliseconds}ms');
       }
       
       return result.data as T;
     } catch (e) {
       final duration = DateTime.now().difference(startTime);
       if (kDebugMode) {
         debugPrint('Function $functionName failed after ${duration.inMilliseconds}ms: $e');
       }
       rethrow;
     }
   }
   ```

2. **Use Call Monitoring Service:**
   ```dart
   // Always log call attempts
   await CallMonitoringService().logCallAttempt(
     appointmentId: appointmentId,
     userId: userId,
     deviceInfo: await DeviceInfoService().getDeviceInfo(),
   );
   
   try {
     final result = await functions.httpsCallable('startAgoraCall').call(data);
     
     // Log successful call start
     await CallMonitoringService().logCallStarted(
       appointmentId: appointmentId,
       userId: userId,
       channelName: result.data['agoraChannelName'],
     );
   } catch (e) {
     // Log call error
     await CallMonitoringService().logCallError(
       appointmentId: appointmentId,
       userId: userId,
       errorType: 'call_initiation_failed',
       errorMessage: e.toString(),
     );
   }
   ```

### Performance Optimization

1. **Cache Function Instances:**
   ```dart
   // In a service or provider
   class CloudFunctionsService {
     static final _functions = FirebaseFunctions.instanceFor(
       region: 'europe-west1',
     );
     
     Future<Map<String, dynamic>> startAgoraCall({
       required String appointmentId,
       required String doctorId,
     }) async {
       final result = await _functions.httpsCallable('startAgoraCall').call({
         'appointmentId': appointmentId,
         'doctorId': doctorId,
       });
       
       return result.data as Map<String, dynamic>;
     }
   }
   ```

2. **Minimize Payload Size:**
   ```dart
   // Only send required data
   await functions.httpsCallable('startAgoraCall').call({
     'appointmentId': appointmentId,
     'doctorId': doctorId,
     // Don't send unnecessary data
   });
   ```

3. **Use Parallel Calls When Possible:**
   ```dart
   // If operations are independent, run them in parallel
   final results = await Future.wait([
     functions.httpsCallable('endAgoraCall').call({'appointmentId': id1}),
     functions.httpsCallable('completeAppointment').call({'appointmentId': id2}),
   ]);
   ```

### Security Best Practices

1. **Never Expose Sensitive Data:**
   ```dart
   // ❌ DON'T DO THIS
   await functions.httpsCallable('startAgoraCall').call({
     'appointmentId': appointmentId,
     'agoraCertificate': 'secret_key', // ❌ NEVER send secrets from client
   });
   
   // ✅ DO THIS
   await functions.httpsCallable('startAgoraCall').call({
     'appointmentId': appointmentId,
     'doctorId': doctorId,
     // Server generates tokens using stored secrets
   });
   ```

2. **Validate User Permissions Client-Side:**
   ```dart
   // Check permissions before calling function
   final user = ref.watch(authProvider).user;
   if (user?.userType != 'doctor') {
     showError('Only doctors can start video calls');
     return;
   }
   
   // Proceed with function call
   await functions.httpsCallable('startAgoraCall').call(data);
   ```

3. **Handle Token Expiration:**
   ```dart
   // Monitor token expiration
   final tokenExpirationTime = DateTime.now().add(Duration(hours: 1));
   
   // Warn user before expiration
   Timer(Duration(minutes: 50), () {
     showWarning('Call will end in 10 minutes');
   });
   ```

### Testing

1. **Use Firebase Emulator for Development:**
   ```dart
   // In main.dart (debug mode only)
   if (kDebugMode) {
     FirebaseFunctions.instanceFor(region: 'europe-west1')
       .useFunctionsEmulator('localhost', 5001);
   }
   ```

2. **Mock Functions in Tests:**
   ```dart
   // In test file
   class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}
   
   test('startAgoraCall returns valid token', () async {
     final mockFunctions = MockFirebaseFunctions();
     
     when(mockFunctions.httpsCallable('startAgoraCall').call(any))
       .thenAnswer((_) async => HttpsCallableResult(data: {
         'agoraToken': 'mock_token',
         'agoraChannelName': 'mock_channel',
         'agoraUid': 12345,
       }));
     
     // Test your code
   });
   ```

---

**Version:** 1.0.0  
**Last Updated:** 2026-02-16  
**Maintained by:** AndroCare360 Development Team

For questions or issues, refer to the [CONTRIBUTING.md](CONTRIBUTING.md) guide or contact the development team.
