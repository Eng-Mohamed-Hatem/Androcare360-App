# Task 10: VoIP Notification in All App States - Quick Checklist

## Pre-Test Setup
- [ ] iOS device ready with latest app build
- [ ] Android device ready with latest app build
- [ ] Test appointments created for both platforms
- [ ] Doctor device ready to initiate calls
- [ ] Notification permissions granted on both devices

---

## iOS Testing

### Test 1: iOS - Foreground
- [ ] Patient signed in on iOS device
- [ ] App in foreground (visible on screen)
- [ ] Doctor initiates call
- [ ] CallKit incoming call screen appears (1-3 seconds)
- [ ] Doctor's name visible
- [ ] Accept/Decline buttons visible
- [ ] Ringtone playing
- [ ] **Screenshot:** `ios_foreground_incoming_call.png`

### Test 2: iOS - Background
- [ ] Patient signed in on iOS device
- [ ] App in background (Home button pressed)
- [ ] Doctor initiates call
- [ ] CallKit incoming call screen appears (1-3 seconds)
- [ ] Doctor's name visible
- [ ] Accept/Decline buttons visible
- [ ] Ringtone playing
- [ ] Screen lights up (if locked)
- [ ] **Screenshot:** `ios_background_incoming_call.png`

### Test 3: iOS - Terminated
- [ ] Patient signed in on iOS device
- [ ] App completely closed (swiped away from recent apps)
- [ ] Doctor initiates call
- [ ] CallKit incoming call screen appears (1-3 seconds)
- [ ] Doctor's name visible
- [ ] Accept/Decline buttons visible
- [ ] Ringtone playing
- [ ] Screen lights up (if locked)
- [ ] App launches when call accepted
- [ ] **Screenshot:** `ios_terminated_incoming_call.png`

---

## Android Testing

### Test 4: Android - Foreground
- [ ] Patient signed in on Android device
- [ ] App in foreground (visible on screen)
- [ ] Doctor initiates call
- [ ] ConnectionService incoming call UI appears (1-3 seconds)
- [ ] Doctor's name visible
- [ ] Accept/Decline buttons visible
- [ ] Ringtone playing
- [ ] **Screenshot:** `android_foreground_incoming_call.png`

### Test 5: Android - Background
- [ ] Patient signed in on Android device
- [ ] App in background (Home button pressed)
- [ ] Doctor initiates call
- [ ] ConnectionService incoming call UI appears (1-3 seconds)
- [ ] Doctor's name visible
- [ ] Accept/Decline buttons visible
- [ ] Ringtone playing
- [ ] Screen lights up (if locked)
- [ ] **Screenshot:** `android_background_incoming_call.png`

### Test 6: Android - Terminated
- [ ] Patient signed in on Android device
- [ ] App completely closed (swiped away from recent apps)
- [ ] Doctor initiates call
- [ ] ConnectionService incoming call UI appears (1-3 seconds)
- [ ] Doctor's name visible
- [ ] Accept/Decline buttons visible
- [ ] Ringtone playing
- [ ] Screen lights up (if locked)
- [ ] App launches when call accepted
- [ ] **Screenshot:** `android_terminated_incoming_call.png`

---

## Platform Differences Documentation

### iOS Observations
- [ ] CallKit UI style documented
- [ ] Ringtone behavior documented
- [ ] Lock screen behavior documented
- [ ] Background wakeup reliability documented
- [ ] Cold start performance documented
- [ ] Any issues documented

### Android Observations
- [ ] ConnectionService UI style documented
- [ ] Ringtone behavior documented
- [ ] Lock screen behavior documented
- [ ] Background wakeup reliability documented
- [ ] Cold start performance documented
- [ ] Battery optimization impact documented
- [ ] Device manufacturer differences documented
- [ ] Any issues documented

---

## Test Results Summary

### iOS Results
- [ ] Test 1 (Foreground): ⬜ Pass / ⬜ Fail
- [ ] Test 2 (Background): ⬜ Pass / ⬜ Fail
- [ ] Test 3 (Terminated): ⬜ Pass / ⬜ Fail

### Android Results
- [ ] Test 4 (Foreground): ⬜ Pass / ⬜ Fail
- [ ] Test 5 (Background): ⬜ Pass / ⬜ Fail
- [ ] Test 6 (Terminated): ⬜ Pass / ⬜ Fail

---

## Quick Troubleshooting

### iOS Issues
- **CallKit doesn't appear?** Check notification permissions and CallKit permissions
- **Notification delayed?** Check network, APNs certificates, Low Power Mode
- **App doesn't launch?** Enable Background App Refresh

### Android Issues
- **ConnectionService doesn't appear?** Check Phone permission, Display over apps permission
- **Notification delayed?** Disable battery optimization, check network
- **App doesn't launch?** Disable battery optimization, grant autostart permission

---

## Success Criteria
- [ ] All 6 tests pass (3 iOS + 3 Android)
- [ ] All 6 screenshots captured
- [ ] Platform differences documented
- [ ] Any issues documented with workarounds

---

## Screenshots to Capture
1. `ios_foreground_incoming_call.png`
2. `ios_background_incoming_call.png`
3. `ios_terminated_incoming_call.png`
4. `android_foreground_incoming_call.png`
5. `android_background_incoming_call.png`
6. `android_terminated_incoming_call.png`

---

**Task:** 10. Test VoIP notification in all app states  
**Requirements:** 2.5, 6.7  
**Date:** _____________  
**Tester:** _____________  
**iOS Device:** _____________  
**Android Device:** _____________
