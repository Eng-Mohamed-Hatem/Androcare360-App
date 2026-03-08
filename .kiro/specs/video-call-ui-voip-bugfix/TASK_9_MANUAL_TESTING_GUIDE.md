# Task 9: VoIP Notification Delivery End-to-End Testing Guide

## Overview

This guide provides comprehensive instructions for manually testing the complete VoIP notification delivery flow from doctor initiating a call to patient receiving and accepting the call.

**Task:** 9. Test VoIP notification delivery end-to-end  
**Requirements:** 2.1, 2.2, 2.3, 2.4, 2.5, 2.6

---

## Prerequisites

### Required Setup

1. **Two Physical Test Devices (CRITICAL):**
   - Device A: For doctor testing (Android or iOS)
   - Device B: For patient testing (Android or iOS)
   - **Note:** Emulators may not reliably receive FCM notifications, especially for VoIP

2. **Test Accounts:**
   - Doctor account credentials (with userType: 'doctor')
   - Patient account credentials (with userType: 'patient')

3. **Test Appointment:**
   - Create a test appointment in Firestore with:
     - `doctorId`: Test doctor's user ID
     - `patientId`: Test patient's user ID
     - `status`: 'confirmed'
     - `scheduledAt`: Current or near-future timestamp

4. **Firebase Access:**
   - Access to Firebase Console (https://console.firebase.google.com)
   - Access to Firestore database (elajtech)
   - Access to Cloud Functions logs

5. **App Build:**
   - Latest code deployed to both devices
   - Tasks 5, 5.2, 6, 7, and 8 completed
   - FCM service properly configured with dependency injection

### Environment Verification

Before testing, verify:
- [ ] Both devices have the latest app build with all Phase 2 changes
- [ ] Both devices have internet connectivity (WiFi or mobile data)
- [ ] Firebase Auth is working on both devices
- [ ] Firestore database is accessible (databaseId: 'elajtech')
- [ ] Cloud Functions are deployed to europe-west1 region
- [ ] Agora credentials are configured in Cloud Functions (.env or functions.config())
- [ ] FCM is enabled in Firebase Console
- [ ] APNs certificates configured (for iOS devices)

---

## Test Procedure

### Step 1: Sign in as Patient (Device B)

#### Actions:
1. Open the app on Device B (patient device)
2. Sign in with patient credentials
3. Wait for sign-in to complete
4. Keep the app in foreground initially

#### Expected Results:
- ✅ Patient successfully signed in
- ✅ Home screen or appointments list is displayed
- ✅ No errors in console logs

#### Verification:
```
Check device logs (if accessible):
- Look for: "✅ User granted notification permission"
- Look for: "✅ FCM Token received: [token]..."
- Look for: "✅ FCM token saved to Firestore for user: [userId]"
```

---

### Step 2: Verify FCM Token Saved in Firestore

#### Actions:
1. Open Firebase Console in browser
2. Navigate to Firestore Database
3. Select database: **elajtech** (CRITICAL - not default database)
4. Navigate to `users` collection
5. Find the patient's user document (by patient user ID)
6. Check for `fcmToken` and `fcmTokenUpdatedAt` fields

#### Expected Results:
- ✅ Patient user document exists in `users` collection
- ✅ `fcmToken` field is present and contains a valid FCM token string
- ✅ `fcmTokenUpdatedAt` field is present with a recent timestamp
- ✅ Token is not null or empty

#### Screenshot Required:
Take screenshot of Firestore showing patient document with FCM token fields

#### Troubleshooting:
If FCM token is missing:
1. Check device logs for errors during token retrieval
2. Verify FCM service is initialized in `main.dart`
3. Verify notification permissions are granted
4. Try signing out and signing in again
5. Check that `FCMService` uses injected `FirebaseFirestore` instance (Task 5.2)

---

### Step 3: Sign in as Doctor (Device A)

#### Actions:
1. Open the app on Device A (doctor device)
2. Sign in with doctor credentials
3. Navigate to appointments list
4. Locate the test appointment

#### Expected Results:
- ✅ Doctor successfully signed in
- ✅ Test appointment is visible in appointments list
- ✅ Appointment shows patient name and scheduled time
- ✅ "Start Video Call" button is visible (if appointment is confirmed)

---

### Step 4: Initiate Video Call from Doctor Device

#### Actions:
1. On Device A (doctor), tap on the test appointment
2. Tap "Start Video Call" button
3. Wait for Cloud Function to execute

#### Expected Results:
- ✅ Loading indicator appears
- ✅ Video call screen opens after a few seconds
- ✅ Doctor's local video preview appears in top-right corner
- ✅ Waiting message displays: "جاري الاتصال بالمريض..."

#### What Happens Behind the Scenes:
1. App calls `startAgoraCall` Cloud Function
2. Cloud Function generates Agora tokens
3. Cloud Function retrieves patient's FCM token from Firestore
4. Cloud Function sends VoIP notification to patient device
5. Cloud Function returns tokens to doctor device
6. Doctor joins Agora channel

---

### Step 5: Verify Cloud Functions Logs

#### Actions:
1. Open Firebase Console in browser
2. Navigate to Functions → Logs
3. Filter logs by function: `startAgoraCall`
4. Look for recent logs (within last minute)

#### Expected Log Messages (in order):

```
1. "📱 Retrieving FCM token for patient: [patientId]"
   - Confirms function is attempting to get patient's FCM token

2. "✅ FCM token retrieved successfully"
   - Confirms token was found in Firestore users collection
   - If you see "❌ FCM token missing" instead, STOP and troubleshoot

3. "📤 Sending VoIP notification to patient"
   - Confirms function is attempting to send FCM notification
   - Should include: appointmentId, doctorName, agoraChannelName

4. "✅ VoIP notification sent successfully: [response]"
   - Confirms FCM notification was sent without errors
   - If you see "❌ Error sending VoIP notification" instead, check error details
```

#### Screenshot Required:
Take screenshot of Cloud Functions logs showing all 4 log messages

#### Troubleshooting:
If logs show errors:

**Error: "❌ FCM token missing"**
- Patient's FCM token not saved in Firestore
- Go back to Step 2 and verify token exists
- Check that patient signed in successfully
- Verify FCM service initialized on patient device

**Error: "❌ Error sending VoIP notification"**
- Check error message for details
- Verify FCM is enabled in Firebase Console
- Verify APNs certificates configured (for iOS)
- Check network connectivity

**Error: "[DB: elajtech] الموعد غير موجود"**
- Appointment not found in Firestore
- Verify appointment exists in `appointments` collection
- Verify `databaseId: 'elajtech'` is used (not default database)
- Check Cloud Functions database configuration (Task 5)

---

### Step 6: Verify Patient Device Receives Notification

#### Actions:
1. Observe Device B (patient device)
2. Wait for incoming call notification to appear (should be within 1-3 seconds)

#### Expected Results:

**For iOS (CallKit):**
- ✅ Native iOS incoming call screen appears
- ✅ Doctor's name is displayed as caller
- ✅ "Accept" and "Decline" buttons are visible
- ✅ Ringtone plays
- ✅ Screen lights up even if device was locked

**For Android (ConnectionService):**
- ✅ Full-screen incoming call UI appears
- ✅ Doctor's name is displayed as caller
- ✅ "Accept" and "Decline" buttons are visible
- ✅ Ringtone plays
- ✅ Notification appears even if app was in background

#### Screenshot Required:
Take screenshot of incoming call notification on patient device

#### Check Device Logs (if accessible):

```
Expected logs on patient device:
1. "📨 Background message received: [messageId]"
   - Confirms FCM message was received

2. "📞 Incoming call detected in background!"
   - Confirms message type is 'incoming_call'

3. "📱 Incoming call notification received for appointment: [appointmentId]"
   - Confirms appointmentId was extracted from message

4. "📱 Displaying incoming call UI for appointment: [appointmentId]"
   - Confirms VoIPCallService.showIncomingCall() was called
```

#### Troubleshooting:
If notification doesn't appear:

1. **Check patient device logs:**
   - Look for FCM message receipt
   - Look for any errors in FCM service or VoIP service

2. **Verify app state:**
   - Try with app in foreground, background, and terminated
   - Some devices may have battery optimization that blocks notifications

3. **Check notification permissions:**
   - Verify notification permissions are granted
   - Check device notification settings

4. **Check FCM configuration:**
   - Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is correct
   - Verify FCM is enabled in Firebase Console

---

### Step 7: Verify CallKit/ConnectionService Displays Incoming Call UI

#### Actions:
1. Observe the incoming call UI on Device B (patient device)
2. Verify all UI elements are present and correct

#### Expected Results:

**UI Elements:**
- ✅ Doctor's name is displayed prominently
- ✅ "Accept" button is visible and functional
- ✅ "Decline" button is visible and functional
- ✅ Ringtone is playing
- ✅ UI is full-screen (not just a notification banner)

**Behavior:**
- ✅ UI appears within 1-3 seconds of doctor initiating call
- ✅ UI persists until user accepts or declines
- ✅ UI works even if app was in background or terminated
- ✅ Device screen lights up if it was off

#### Screenshot Required:
Take screenshot showing full incoming call UI with all elements

---

### Step 8: Accept Call from Patient Device

#### Actions:
1. On Device B (patient device), tap "Accept" button
2. Wait for video call screen to load

#### Expected Results:
- ✅ Incoming call UI dismisses
- ✅ App opens (if it was in background)
- ✅ Video call screen appears
- ✅ Camera permission granted (if prompted)
- ✅ Microphone permission granted (if prompted)
- ✅ Patient's local video preview appears in top-right corner
- ✅ Waiting message displays: "جاري الاتصال بالطبيب..."

#### Check Device Logs (if accessible):

```
Expected logs on patient device:
1. "✅ Call accepted by user"
   - Confirms user tapped Accept button

2. "Joining Agora channel: [channelName]"
   - Confirms patient is joining Agora channel

3. "✅ Successfully joined channel"
   - Confirms patient joined successfully
```

---

### Step 9: Verify Navigation to AgoraVideoCallScreen

#### Actions:
1. Observe Device B (patient device) after accepting call
2. Verify correct screen is displayed

#### Expected Results:
- ✅ `AgoraVideoCallScreen` is displayed
- ✅ Screen shows appointment details (doctor name, patient name)
- ✅ Local video preview is visible in top-right corner
- ✅ Waiting message is displayed in center
- ✅ Control buttons are visible at bottom (mute, camera, end call)
- ✅ Connection status indicator is visible at top-left

#### Screenshot Required:
Take screenshot of patient's video call screen after accepting

---

### Step 10: Verify Video Call Connects Successfully

#### Actions:
1. Wait for both users to join the Agora channel (should be within 2-5 seconds)
2. Observe both devices

#### Expected Results:

**On Doctor Device (Device A):**
- ✅ Patient's video appears in full screen
- ✅ Doctor's local video moves to small preview in corner
- ✅ Waiting message disappears
- ✅ Connection status shows "متصل" (Connected)
- ✅ Audio is working (can hear patient)

**On Patient Device (Device B):**
- ✅ Doctor's video appears in full screen
- ✅ Patient's local video moves to small preview in corner
- ✅ Waiting message disappears
- ✅ Connection status shows "متصل" (Connected)
- ✅ Audio is working (can hear doctor)

#### Screenshot Required:
Take screenshots of both devices showing connected video call

#### Check Device Logs (if accessible):

```
Expected logs on both devices:
1. "Remote user joined: [uid]"
   - Confirms remote user joined the channel

2. "Remote video stream received"
   - Confirms video stream is being received

3. "Call connected successfully"
   - Confirms call is fully connected
```

---

## Test Results Checklist

### Patient Device Setup
- [ ] Patient signed in successfully
- [ ] FCM token saved in Firestore users collection
- [ ] FCM token verified in Firebase Console (screenshot captured)
- [ ] Patient device ready to receive notifications

### Doctor Initiates Call
- [ ] Doctor signed in successfully
- [ ] Test appointment visible in appointments list
- [ ] "Start Video Call" button tapped
- [ ] Video call screen opened on doctor device

### Cloud Functions Logs
- [ ] Log: "📱 Retrieving FCM token for patient: [patientId]"
- [ ] Log: "✅ FCM token retrieved successfully"
- [ ] Log: "📤 Sending VoIP notification to patient"
- [ ] Log: "✅ VoIP notification sent successfully"
- [ ] Screenshot of Cloud Functions logs captured

### Patient Receives Notification
- [ ] Patient device received FCM notification
- [ ] Device logs show: "📨 Background message received"
- [ ] Device logs show: "📞 Incoming call detected"
- [ ] Device logs show: "📱 Incoming call notification received for appointment"

### CallKit/ConnectionService UI
- [ ] Incoming call UI displayed on patient device
- [ ] Doctor's name displayed correctly
- [ ] Accept and Decline buttons visible
- [ ] Ringtone playing
- [ ] Screenshot of incoming call UI captured

### Patient Accepts Call
- [ ] Patient tapped "Accept" button
- [ ] App opened (if in background)
- [ ] Video call screen appeared
- [ ] Camera and microphone permissions granted

### Navigation to AgoraVideoCallScreen
- [ ] AgoraVideoCallScreen displayed on patient device
- [ ] Local video preview visible
- [ ] Waiting message displayed
- [ ] Control buttons visible
- [ ] Screenshot captured

### Video Call Connection
- [ ] Doctor's video appears on patient device
- [ ] Patient's video appears on doctor device
- [ ] Waiting messages disappear on both devices
- [ ] Connection status shows "متصل" on both devices
- [ ] Audio working on both devices
- [ ] Screenshots of connected call captured (both devices)

---

## Test Scenarios

### Scenario 1: App in Foreground
- [ ] Patient app is in foreground when call initiated
- [ ] Incoming call notification appears
- [ ] All steps complete successfully

### Scenario 2: App in Background
- [ ] Patient app is in background when call initiated
- [ ] Incoming call notification appears
- [ ] App opens when call accepted
- [ ] All steps complete successfully

### Scenario 3: App Terminated (Cold Start)
- [ ] Patient app is completely closed when call initiated
- [ ] Incoming call notification appears
- [ ] App launches when call accepted
- [ ] All steps complete successfully

---

## Troubleshooting Guide

### Issue: Patient doesn't receive notification

**Possible Causes:**
1. FCM token not saved in Firestore
2. Cloud Function not sending notification
3. Network connectivity issue
4. Notification permissions not granted
5. Battery optimization blocking notifications

**Solutions:**
1. Verify FCM token exists in Firestore (Step 2)
2. Check Cloud Functions logs for errors (Step 5)
3. Verify patient device has internet connectivity
4. Check notification permissions in device settings
5. Disable battery optimization for the app
6. Try with app in foreground first

### Issue: Cloud Functions logs show "❌ FCM token missing"

**Possible Causes:**
1. Patient never signed in
2. FCM service not initialized
3. Notification permissions not granted
4. Token not saved to Firestore

**Solutions:**
1. Ensure patient signed in successfully
2. Verify `FCMService.initialize()` is called in `main.dart`
3. Grant notification permissions when prompted
4. Check device logs for FCM token retrieval errors
5. Verify `FCMService` uses injected `FirebaseFirestore` instance (Task 5.2)

### Issue: Cloud Functions logs show "[DB: elajtech] الموعد غير موجود"

**Possible Causes:**
1. Appointment doesn't exist in Firestore
2. Wrong database being queried (default instead of elajtech)
3. Appointment ID mismatch

**Solutions:**
1. Verify appointment exists in Firestore `appointments` collection
2. Verify Cloud Functions use `db.settings({ databaseId: 'elajtech' })`
3. Check appointment ID matches between app and Firestore
4. Verify database configuration in Cloud Functions (Task 5)

### Issue: Incoming call UI doesn't appear

**Possible Causes:**
1. VoIPCallService not configured correctly
2. CallKit/ConnectionService permissions not granted
3. Platform-specific configuration missing

**Solutions:**
1. Verify `VoIPCallService.showIncomingCall()` is called (check logs)
2. Check CallKit permissions (iOS) or Phone permissions (Android)
3. Verify `flutter_callkit_incoming` package is configured correctly
4. Check platform-specific configuration files

### Issue: Video call doesn't connect

**Possible Causes:**
1. Agora tokens invalid or expired
2. Network connectivity issue
3. Agora channel name mismatch
4. Agora service not initialized

**Solutions:**
1. Verify Agora tokens are generated correctly (check Cloud Functions logs)
2. Check network connectivity on both devices
3. Verify both devices use same channel name
4. Check Agora service initialization in app

---

## Success Criteria

All of the following must be true for Task 9 to be considered complete:

- ✅ Patient FCM token saved in Firestore users collection
- ✅ Cloud Functions logs show all 4 expected log messages
- ✅ Patient device receives incoming call notification
- ✅ CallKit (iOS) or ConnectionService (Android) displays incoming call UI
- ✅ Patient can accept call successfully
- ✅ App navigates to AgoraVideoCallScreen
- ✅ Video call connects successfully
- ✅ Both users can see and hear each other
- ✅ All required screenshots captured
- ✅ Test works in all app states (foreground, background, terminated)

---

## Next Steps

After completing Task 9:

1. **If all tests pass:**
   - Mark Task 9 as completed in tasks.md
   - Proceed to Task 10: Test VoIP notification in all app states
   - Continue with Phase 2 implementation

2. **If issues found:**
   - Document issues in detail with screenshots
   - Check troubleshooting guide for solutions
   - Fix issues before proceeding
   - Re-test after fixes

3. **Documentation:**
   - Save all screenshots to `.kiro/specs/video-call-ui-voip-bugfix/screenshots/task9/`
   - Update test results template with findings
   - Share results with development team

---

## References

- **Requirements:** `.kiro/specs/video-call-ui-voip-bugfix/requirements.md` (2.1, 2.2, 2.3, 2.4, 2.5, 2.6)
- **Design:** `.kiro/specs/video-call-ui-voip-bugfix/design.md`
- **Tasks:** `.kiro/specs/video-call-ui-voip-bugfix/tasks.md`
- **Cloud Functions:** `functions/index.js`
- **FCM Service:** `lib/core/services/fcm_service.dart`
- **VoIP Service:** `lib/core/services/voip_call_service.dart`
- **Video Call Screen:** `lib/features/patient/consultation/presentation/screens/agora_video_call_screen.dart`

---

**Document Version:** 1.0  
**Last Updated:** 2026-02-17  
**Task:** 9. Test VoIP notification delivery end-to-end  
**Author:** AndroCare360 Development Team
