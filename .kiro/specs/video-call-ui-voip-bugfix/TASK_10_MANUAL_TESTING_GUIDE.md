# Task 10: VoIP Notification in All App States - Testing Guide

## Overview

This guide provides comprehensive instructions for testing VoIP notifications across all app states (foreground, background, terminated) on both iOS and Android platforms.

**Task:** 10. Test VoIP notification in all app states  
**Requirements:** 2.5, 6.7  
**Type:** Manual Cross-Platform Testing

---

## Prerequisites

### Required Setup

1. **Test Devices:**
   - iOS device (iPhone) - Physical device recommended
   - Android device - Physical device recommended
   - Both devices should have the latest app build

2. **Test Accounts:**
   - Doctor account credentials
   - Patient account credentials (for each device)

3. **Test Appointments:**
   - Create separate test appointments for iOS and Android testing
   - Each appointment should have:
     - Doctor: Test doctor account
     - Patient: Test patient account (iOS or Android)
     - Status: Confirmed

4. **Environment:**
   - Firebase Console access
   - Cloud Functions deployed
   - FCM configured for both platforms
   - APNs certificates configured (for iOS)

### Environment Verification

Before testing, verify:
- [ ] Both devices have the latest app build
- [ ] Both devices have internet connectivity
- [ ] Notification permissions granted on both devices
- [ ] FCM tokens saved for both patient accounts
- [ ] Cloud Functions are deployed and working (verified in Task 9)

---

## Test Matrix

This task requires testing **3 app states × 2 platforms = 6 test scenarios**:

| App State | iOS | Android |
|-----------|-----|---------|
| Foreground | Test 1 | Test 4 |
| Background | Test 2 | Test 5 |
| Terminated | Test 3 | Test 6 |

---

## iOS Testing

### Test 1: iOS - App in Foreground

#### Setup:
1. Sign in as patient on iOS device
2. Keep app in foreground (visible on screen)
3. Navigate to any screen (home, appointments, profile)

#### Test Steps:
1. On doctor device, initiate video call
2. Observe iOS patient device immediately

#### Expected Results:
- ✅ Incoming call notification appears within 1-3 seconds
- ✅ CallKit native incoming call screen displays
- ✅ Doctor's name is visible
- ✅ "Accept" and "Decline" buttons are visible
- ✅ Ringtone plays
- ✅ App remains in foreground (doesn't minimize)

#### Screenshot Required:
- `ios_foreground_incoming_call.png`

#### Device Logs to Check:
```
Expected logs:
- "📨 Foreground message received!"
- "📞 Incoming call detected in foreground!"
- "📱 Incoming call notification received for appointment: [id]"
- "📱 Displaying incoming call UI for appointment: [id]"
```

#### Notes:
- iOS CallKit should display even when app is in foreground
- The app should not show its own custom UI, only CallKit
- Ringtone should play through device speakers

---

### Test 2: iOS - App in Background

#### Setup:
1. Sign in as patient on iOS device
2. Open the app, then press Home button to background it
3. Verify app is in background (not visible, but not terminated)

#### Test Steps:
1. On doctor device, initiate video call
2. Observe iOS patient device immediately

#### Expected Results:
- ✅ Incoming call notification appears within 1-3 seconds
- ✅ CallKit native incoming call screen displays
- ✅ Doctor's name is visible
- ✅ "Accept" and "Decline" buttons are visible
- ✅ Ringtone plays
- ✅ Screen lights up if device was locked
- ✅ CallKit appears over lock screen if device is locked

#### Screenshot Required:
- `ios_background_incoming_call.png`

#### Device Logs to Check:
```
Expected logs:
- "📨 Background message received: [messageId]"
- "📞 Incoming call detected in background!"
- "📱 Incoming call notification received for appointment: [id]"
- "📱 Displaying incoming call UI for appointment: [id]"
```

#### Notes:
- iOS should wake up the app in background to process notification
- CallKit should display even if device is locked
- This is the most common scenario for real-world usage

---

### Test 3: iOS - App Terminated (Cold Start)

#### Setup:
1. Sign in as patient on iOS device
2. Completely close the app:
   - Swipe up from bottom (or double-click Home button)
   - Swipe up on app preview to close it
3. Verify app is not in recent apps list

#### Test Steps:
1. On doctor device, initiate video call
2. Observe iOS patient device immediately

#### Expected Results:
- ✅ Incoming call notification appears within 1-3 seconds
- ✅ CallKit native incoming call screen displays
- ✅ Doctor's name is visible
- ✅ "Accept" and "Decline" buttons are visible
- ✅ Ringtone plays
- ✅ Screen lights up if device was locked
- ✅ App launches in background when call is accepted

#### Screenshot Required:
- `ios_terminated_incoming_call.png`

#### Device Logs to Check:
```
Expected logs (after accepting call):
- "📨 Background message received: [messageId]"
- "📞 Incoming call detected in background!"
- "📱 Incoming call notification received for appointment: [id]"
- "📱 Displaying incoming call UI for appointment: [id]"
- App initialization logs
```

#### Notes:
- iOS should launch the app in background to process notification
- CallKit should display even when app is completely closed
- This tests the most challenging scenario (cold start)
- App should launch quickly when call is accepted

---

## Android Testing

### Test 4: Android - App in Foreground

#### Setup:
1. Sign in as patient on Android device
2. Keep app in foreground (visible on screen)
3. Navigate to any screen (home, appointments, profile)

#### Test Steps:
1. On doctor device, initiate video call
2. Observe Android patient device immediately

#### Expected Results:
- ✅ Incoming call notification appears within 1-3 seconds
- ✅ Full-screen incoming call UI displays (ConnectionService)
- ✅ Doctor's name is visible
- ✅ "Accept" and "Decline" buttons are visible
- ✅ Ringtone plays
- ✅ App shows incoming call UI overlay

#### Screenshot Required:
- `android_foreground_incoming_call.png`

#### Device Logs to Check:
```
Expected logs:
- "📨 Foreground message received!"
- "📞 Incoming call detected in foreground!"
- "📱 Incoming call notification received for appointment: [id]"
- "📱 Displaying incoming call UI for appointment: [id]"
```

#### Notes:
- Android may show ConnectionService UI or custom in-app UI
- Behavior may vary by Android version and device manufacturer
- Some devices may show notification instead of full-screen UI

---

### Test 5: Android - App in Background

#### Setup:
1. Sign in as patient on Android device
2. Open the app, then press Home button to background it
3. Verify app is in background (not visible, but not terminated)

#### Test Steps:
1. On doctor device, initiate video call
2. Observe Android patient device immediately

#### Expected Results:
- ✅ Incoming call notification appears within 1-3 seconds
- ✅ Full-screen incoming call UI displays (ConnectionService)
- ✅ Doctor's name is visible
- ✅ "Accept" and "Decline" buttons are visible
- ✅ Ringtone plays
- ✅ Screen lights up if device was locked
- ✅ Notification appears over lock screen if device is locked

#### Screenshot Required:
- `android_background_incoming_call.png`

#### Device Logs to Check:
```
Expected logs:
- "📨 Background message received: [messageId]"
- "📞 Incoming call detected in background!"
- "📱 Incoming call notification received for appointment: [id]"
- "📱 Displaying incoming call UI for appointment: [id]"
```

#### Notes:
- Android should wake up the app in background to process notification
- ConnectionService should display even if device is locked
- Battery optimization settings may affect notification delivery

---

### Test 6: Android - App Terminated (Cold Start)

#### Setup:
1. Sign in as patient on Android device
2. Completely close the app:
   - Open recent apps (square button or swipe up gesture)
   - Swipe away the app to close it
3. Verify app is not in recent apps list

#### Test Steps:
1. On doctor device, initiate video call
2. Observe Android patient device immediately

#### Expected Results:
- ✅ Incoming call notification appears within 1-3 seconds
- ✅ Full-screen incoming call UI displays (ConnectionService)
- ✅ Doctor's name is visible
- ✅ "Accept" and "Decline" buttons are visible
- ✅ Ringtone plays
- ✅ Screen lights up if device was locked
- ✅ App launches when call is accepted

#### Screenshot Required:
- `android_terminated_incoming_call.png`

#### Device Logs to Check:
```
Expected logs (after accepting call):
- "📨 Background message received: [messageId]"
- "📞 Incoming call detected in background!"
- "📱 Incoming call notification received for appointment: [id]"
- "📱 Displaying incoming call UI for appointment: [id]"
- App initialization logs
```

#### Notes:
- Android should launch the app in background to process notification
- ConnectionService should display even when app is completely closed
- Battery optimization may prevent notification delivery on some devices
- App should launch quickly when call is accepted

---

## Platform Differences Documentation

### Expected Differences

| Feature | iOS (CallKit) | Android (ConnectionService) |
|---------|---------------|----------------------------|
| **UI Style** | Native iOS incoming call screen | Full-screen custom UI or system UI |
| **Lock Screen** | Always displays over lock screen | May require additional permissions |
| **Ringtone** | System ringtone | Custom or system ringtone |
| **Notification Priority** | High (APNs priority 10) | High (FCM priority high) |
| **Background Wakeup** | Automatic | Automatic (if not battery optimized) |
| **Cold Start** | Launches app in background | Launches app in background |
| **Permissions** | Notification + CallKit | Notification + Phone + Display over apps |

### Observed Differences (To Be Documented)

After testing, document any differences observed:

**iOS Observations:**
- [ ] CallKit UI appearance and behavior
- [ ] Ringtone behavior
- [ ] Lock screen behavior
- [ ] Background wakeup reliability
- [ ] Cold start performance
- [ ] Any issues or unexpected behavior

**Android Observations:**
- [ ] ConnectionService UI appearance and behavior
- [ ] Ringtone behavior
- [ ] Lock screen behavior
- [ ] Background wakeup reliability
- [ ] Cold start performance
- [ ] Battery optimization impact
- [ ] Device manufacturer differences (Samsung, Google, etc.)
- [ ] Any issues or unexpected behavior

---

## Test Results Matrix

### iOS Test Results

| Test | App State | Result | Screenshot | Notes |
|------|-----------|--------|------------|-------|
| 1 | Foreground | ⬜ Pass / ⬜ Fail | ⬜ Captured | |
| 2 | Background | ⬜ Pass / ⬜ Fail | ⬜ Captured | |
| 3 | Terminated | ⬜ Pass / ⬜ Fail | ⬜ Captured | |

### Android Test Results

| Test | App State | Result | Screenshot | Notes |
|------|-----------|--------|------------|-------|
| 4 | Foreground | ⬜ Pass / ⬜ Fail | ⬜ Captured | |
| 5 | Background | ⬜ Pass / ⬜ Fail | ⬜ Captured | |
| 6 | Terminated | ⬜ Pass / ⬜ Fail | ⬜ Captured | |

---

## Troubleshooting

### iOS Issues

#### Issue: CallKit doesn't appear
**Possible Causes:**
- CallKit permissions not granted
- VoIPCallService not configured correctly
- FCM notification not received

**Solutions:**
1. Check Settings → [App Name] → Notifications → Allow Notifications
2. Verify VoIPCallService.showIncomingCall() is called (check logs)
3. Check Cloud Functions logs for notification send confirmation

#### Issue: Notification delayed or doesn't appear
**Possible Causes:**
- Network connectivity issue
- APNs certificate issue
- Device in Low Power Mode

**Solutions:**
1. Check network connectivity
2. Verify APNs certificates in Firebase Console
3. Disable Low Power Mode
4. Try with device plugged in

#### Issue: App doesn't launch on cold start
**Possible Causes:**
- Background app refresh disabled
- Notification permissions not granted

**Solutions:**
1. Enable Settings → General → Background App Refresh
2. Grant notification permissions

---

### Android Issues

#### Issue: ConnectionService doesn't appear
**Possible Causes:**
- Phone permissions not granted
- Display over other apps permission not granted
- Battery optimization blocking notifications

**Solutions:**
1. Grant Phone permission in app settings
2. Grant "Display over other apps" permission
3. Disable battery optimization for the app
4. Check device manufacturer's battery settings

#### Issue: Notification delayed or doesn't appear
**Possible Causes:**
- Battery optimization enabled
- Network connectivity issue
- Device in Doze mode

**Solutions:**
1. Disable battery optimization for the app
2. Check network connectivity
3. Keep device plugged in during testing
4. Disable Doze mode for testing

#### Issue: App doesn't launch on cold start
**Possible Causes:**
- Battery optimization blocking background launch
- Autostart permission not granted (some manufacturers)

**Solutions:**
1. Disable battery optimization
2. Grant autostart permission (Xiaomi, Huawei, etc.)
3. Add app to protected apps list (manufacturer-specific)

---

## Success Criteria

Task 10 is considered complete when:

### iOS:
- ✅ Test 1 (Foreground) passes - CallKit appears
- ✅ Test 2 (Background) passes - CallKit appears
- ✅ Test 3 (Terminated) passes - CallKit appears
- ✅ All 3 screenshots captured
- ✅ Platform differences documented

### Android:
- ✅ Test 4 (Foreground) passes - ConnectionService appears
- ✅ Test 5 (Background) passes - ConnectionService appears
- ✅ Test 6 (Terminated) passes - ConnectionService appears
- ✅ All 3 screenshots captured
- ✅ Platform differences documented

### Overall:
- ✅ All 6 tests pass (3 iOS + 3 Android)
- ✅ All 6 screenshots captured
- ✅ Platform differences documented
- ✅ Any issues documented with workarounds

---

## Next Steps

After completing Task 10:

1. **If all tests pass:**
   - Mark Task 10 as completed in tasks.md
   - Document platform differences in a summary file
   - Proceed to Task 11: Implement graceful error handling

2. **If issues found:**
   - Document issues in detail with screenshots
   - Identify if issues are platform-specific or general
   - Determine if issues are blockers or can be addressed later
   - Fix critical issues before proceeding

3. **Documentation:**
   - Save all screenshots to `.kiro/specs/video-call-ui-voip-bugfix/screenshots/task10/`
   - Create platform differences summary document
   - Update test results template with findings

---

## References

- **Requirements:** `.kiro/specs/video-call-ui-voip-bugfix/requirements.md` (2.5, 6.7)
- **Design:** `.kiro/specs/video-call-ui-voip-bugfix/design.md`
- **Tasks:** `.kiro/specs/video-call-ui-voip-bugfix/tasks.md`
- **Task 9 Guide:** `.kiro/specs/video-call-ui-voip-bugfix/TASK_9_MANUAL_TESTING_GUIDE.md`
- **VoIP Service:** `lib/core/services/voip_call_service.dart`
- **FCM Service:** `lib/core/services/fcm_service.dart`

---

**Document Version:** 1.0  
**Last Updated:** 2026-02-17  
**Task:** 10. Test VoIP notification in all app states  
**Author:** AndroCare360 Development Team
