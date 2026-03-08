# Task 5 Quick Reference Card

**Print this page for quick reference during test execution**

---

## Test Scenarios Overview

| ID | Scenario | Priority | Duration | Devices |
|----|----------|----------|----------|---------|
| 5.1 | Successful Call Initiation | Critical | 10-15 min | Doctor + Patient |
| 5.2 | Invalid Appointment | High | 5-10 min | Doctor only |
| 5.3 | No Authentication | High | 5-10 min | Doctor only |
| 5.4 | Wrong Doctor | High | 5-10 min | Doctor only |

**Total Estimated Time:** 45-60 minutes

---

## Pre-Test Checklist (5 minutes)

- [ ] Doctor device: Charged, app installed, logged in, WiFi connected
- [ ] Patient device: Charged, app installed, logged in, WiFi connected
- [ ] Test appointments created in Firestore
- [ ] Firebase Console open: https://console.firebase.google.com/
- [ ] Evidence folder created: `evidence/task_5_call_initiation/`
- [ ] Screen recording ready (optional)

---

## Scenario 5.1: Successful Call (10-15 min)

### Quick Steps
1. **Doctor:** Tap "Start Video Call" → Capture screenshot
2. **Wait:** Note time (should be < 3 seconds)
3. **Patient:** Incoming call appears → Capture screenshot
4. **Verify:** Check Firebase Console for logs
5. **Record:** Fill in test results template

### Success Criteria
✓ Call initiated within 3 seconds  
✓ Patient notification within 2 seconds  
✓ Doctor name displayed correctly  
✓ Firestore logs: `call_attempt` + `call_started`  
✓ No error messages

### Evidence to Capture
- [ ] Screenshot: Doctor appointment screen
- [ ] Screenshot: Loading state
- [ ] Screenshot: Patient notification
- [ ] Screenshot: Firebase `call_attempt` log
- [ ] Screenshot: Firebase `call_started` log
- [ ] Export: Firestore logs as JSON

---

## Scenario 5.2: Invalid Appointment (5-10 min)

### Quick Steps
1. **Doctor:** Attempt call with ID: `invalid_apt_12345`
2. **Observe:** Error message appears → Capture screenshot
3. **Verify:** Check Firebase Console for `call_error` log
4. **Record:** Fill in test results template

### Success Criteria
✓ Error message displayed  
✓ Error code: `not-found`  
✓ User-friendly message  
✓ Call did not proceed  
✓ Error logged to Firestore

### Evidence to Capture
- [ ] Screenshot: Error message
- [ ] Screenshot: Firebase `call_error` log
- [ ] Export: Error log as JSON

---

## Scenario 5.3: No Authentication (5-10 min)

### Quick Steps
1. **Doctor:** Sign out from app
2. **Attempt:** Call Cloud Function without auth
3. **Observe:** Error or login prompt → Capture screenshot
4. **Record:** Fill in test results template

### Success Criteria
✓ Unauthenticated call rejected  
✓ Error code: `unauthenticated`  
✓ User prompted to sign in  
✓ Call did not proceed

### Evidence to Capture
- [ ] Screenshot: Error message or login prompt

---

## Scenario 5.4: Wrong Doctor (5-10 min)

### Quick Steps
1. **Setup:** Doctor A logged in, use Doctor B's appointment
2. **Doctor A:** Attempt to start call
3. **Observe:** Permission error → Capture screenshot
4. **Verify:** Check Firebase Console for `call_error` log
5. **Record:** Fill in test results template

### Success Criteria
✓ Error message displayed  
✓ Error code: `permission-denied`  
✓ Clear error message  
✓ Call did not proceed  
✓ Error logged with correct user ID

### Evidence to Capture
- [ ] Screenshot: Error message
- [ ] Screenshot: Firebase `call_error` log
- [ ] Export: Error log as JSON

---

## Firebase Console Quick Access

**URL:** https://console.firebase.google.com/

**Navigation:**
1. Select project: `elajtech`
2. Go to: Firestore Database
3. Select database: `elajtech`
4. Open collection: `call_logs`

**Query for Test Logs:**
```
Filter by: appointmentId == [your_test_appointment_id]
Order by: timestamp (descending)
```

**Log Event Types to Look For:**
- `call_attempt` - Call initiation started
- `call_started` - Call successfully started
- `call_error` - Error occurred

---

## Evidence Naming Convention

**Screenshots:**
```
scenario_[ID]_step_[N]_[description].png

Examples:
- scenario_5_1_step_1_doctor_appointment.png
- scenario_5_1_step_3_patient_notification.png
- scenario_5_2_error_message.png
```

**Logs:**
```
scenario_[ID]_[type]_logs.json

Examples:
- scenario_5_1_firestore_logs.json
- scenario_5_2_error_log.json
```

---

## Common Issues & Quick Fixes

### Patient doesn't receive notification
- Check patient FCM token in Firestore: `users/{patientId}/fcmToken`
- Verify patient device has internet
- Ensure app is running (at least in background)
- Check notification permissions

### "NOT_FOUND" error
- Verify region: `europe-west1`
- Check function deployment: `firebase functions:list`
- Verify function name: `startAgoraCall`

### Cannot access Firebase Console
- Request access to `elajtech` project
- Use Firebase CLI: `firebase firestore:get call_logs`

### Appointment not found in app
- Create test appointment in Firestore manually
- Verify status: `confirmed`
- Check `doctorId` matches logged-in doctor
- Ensure using database: `elajtech`

---

## Performance Targets

| Metric | Target | Measure |
|--------|--------|---------|
| Call Setup Time | < 3 seconds | Button press → notification sent |
| Notification Delivery | < 2 seconds | Doctor press → patient sees |
| Error Response | Immediate | Error displayed to user |

---

## Post-Test Checklist (10 minutes)

- [ ] All screenshots captured and saved
- [ ] All logs exported from Firebase Console
- [ ] Evidence files organized in folders
- [ ] Test results template filled out
- [ ] Evidence index created
- [ ] Defects documented (if any)
- [ ] Task status updated in tasks.md
- [ ] Test summary completed

---

## Contact Information

**For Technical Issues:**
- Check: `API_DOCUMENTATION.md`
- Check: `CONTRIBUTING.md`
- Contact: Development Team

**For Test Questions:**
- Reference: `TEST_EXECUTION_GUIDE_TASK_5.md`
- Reference: Design document (`.kiro/specs/voip-test/design.md`)

---

## Quick Commands

**Export Firestore Logs (Firebase CLI):**
```bash
firebase firestore:export evidence/task_5_call_initiation/logs/
```

**Android Device Logs:**
```bash
adb logcat -c  # Clear logs
adb logcat > scenario_5_1_android.log  # Start logging
adb logcat -d > scenario_5_1_android_full.log  # Save logs
```

**iOS Device Logs:**
1. Open Console.app on Mac
2. Select device from sidebar
3. Filter for "AndroCare"
4. Start recording
5. Save logs after test

---

**Print Date:** `_________________`  
**Tester:** `_________________`  
**Version:** 1.0
