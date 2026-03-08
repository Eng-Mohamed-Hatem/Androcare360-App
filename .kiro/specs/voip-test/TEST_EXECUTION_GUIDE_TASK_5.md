# Test Execution Guide: Task 5 - Call Initiation Test Scenarios

## Overview

This guide provides step-by-step instructions for executing Task 5: Call Initiation Test Scenarios. These are **manual tests** that require real Android/iOS devices and must be performed by a human tester.

**Task Status:** Ready for Execution  
**Estimated Duration:** 45-60 minutes  
**Required Resources:** 2 devices (1 doctor, 1 patient), WiFi network, test accounts

---

## Pre-Test Setup Checklist

Before starting test execution, ensure the following:

### Device Preparation

- [ ] **Doctor Device:**
  - Device charged (>80% battery)
  - AndroCare360 app installed (latest version)
  - Logged in as test doctor account
  - WiFi connected
  - Screen recording enabled (optional but recommended)

- [ ] **Patient Device:**
  - Device charged (>80% battery)
  - AndroCare360 app installed (latest version)
  - Logged in as test patient account
  - WiFi connected
  - Notifications enabled
  - Screen recording enabled (optional but recommended)

### Test Data Preparation

- [ ] **Valid Test Appointment:**
  - Appointment ID: `_________________` (fill in)
  - Doctor ID: `_________________` (fill in)
  - Patient ID: `_________________` (fill in)
  - Status: `confirmed`
  - Scheduled time: Within next 24 hours

- [ ] **Invalid Test Appointment:**
  - Non-existent Appointment ID: `invalid_apt_12345`

- [ ] **Wrong Doctor Test Appointment:**
  - Appointment ID: `_________________` (fill in)
  - Assigned to different doctor than logged-in user

### Monitoring Tools Setup

- [ ] **Firebase Console:**
  - Open: https://console.firebase.google.com/
  - Navigate to: Firestore Database → `elajtech` → `call_logs`
  - Keep tab open for real-time monitoring

- [ ] **Device Logs (Optional):**
  - Android: `adb logcat -c` (clear logs)
  - iOS: Open Console.app, select device

- [ ] **Evidence Folder:**
  - Create folder: `evidence/task_5_call_initiation/`
  - Subfolders: `screenshots/`, `logs/`, `videos/`

---

## Test Scenario 5.1: Successful Call Initiation

**Objective:** Verify that a doctor can successfully initiate a video call and the patient receives the notification.

**Priority:** Critical  
**Estimated Duration:** 10-15 minutes

### Preconditions

- Doctor logged in with valid credentials
- Patient logged in with valid credentials
- Valid appointment exists in Firestore
- Both devices connected to WiFi
- Patient app in foreground (for this test)

### Test Steps

#### Step 1: Doctor Initiates Call

**Action (Doctor Device):**
1. Open AndroCare360 app
2. Navigate to "Appointments" screen
3. Find the test appointment
4. Tap "Start Video Call" button

**Expected Result:**
- Loading indicator appears
- Button becomes disabled during processing

**Evidence to Capture:**
- [ ] Screenshot: Doctor appointment screen before call
- [ ] Screenshot: Loading state after button press
- [ ] Note timestamp: `__:__:__`

#### Step 2: System Processes Call Initiation

**Action (System):**
- Cloud Function `startAgoraCall` is called
- Agora tokens are generated
- FCM notification is sent to patient

**Expected Result:**
- Call initiated within 3 seconds
- No error messages displayed to doctor

**Evidence to Capture:**
- [ ] Note: Time from button press to next screen: `___` seconds
- [ ] Check Firebase Console for `call_attempt` log entry
- [ ] Check Firebase Console for `call_started` log entry

#### Step 3: Patient Receives Notification

**Action (Patient Device):**
- Wait for incoming call notification

**Expected Result:**
- Incoming call UI displays within 2 seconds
- Doctor name is displayed correctly
- "Accept" and "Decline" buttons are visible

**Evidence to Capture:**
- [ ] Screenshot: Patient incoming call screen
- [ ] Note: Time from doctor button press to patient notification: `___` seconds
- [ ] Verify doctor name displayed: `_________________`

#### Step 4: Verify Firestore Logs

**Action (Tester):**
1. Open Firebase Console → Firestore → `call_logs`
2. Query for logs with the test appointment ID
3. Verify log entries exist

**Expected Result:**
- `call_attempt` event logged with:
  - `appointmentId`: Correct appointment ID
  - `userId`: Doctor's user ID
  - `timestamp`: Recent timestamp
  - `deviceInfo`: Contains platform, model, OS version
  
- `call_started` event logged with:
  - `appointmentId`: Correct appointment ID
  - `userId`: Doctor's user ID
  - `metadata.agoraChannelName`: Channel name present
  - `metadata.agoraUid`: UID present

**Evidence to Capture:**
- [ ] Screenshot: Firebase Console showing `call_attempt` log
- [ ] Screenshot: Firebase Console showing `call_started` log
- [ ] Export logs as JSON: `evidence/task_5_call_initiation/logs/scenario_5_1_firestore_logs.json`

### Test Result

**Status:** [ ] Pass  [ ] Fail  [ ] Blocked

**Actual Duration:** `___` minutes

**Notes:**
```
[Record any observations, issues, or deviations from expected behavior]




```

**Defects Found:**
```
[If test failed, describe the defect]
Defect ID: 
Severity: 
Description: 



```

---

## Test Scenario 5.2: Invalid Appointment

**Objective:** Verify that the system properly handles attempts to initiate a call with a non-existent appointment ID.

**Priority:** High  
**Estimated Duration:** 5-10 minutes

### Preconditions

- Doctor logged in with valid credentials
- Using a non-existent appointment ID: `invalid_apt_12345`

### Test Steps

#### Step 1: Attempt Call with Invalid Appointment

**Action (Doctor Device):**
1. Manually trigger call initiation with invalid appointment ID
   - This may require developer tools or direct Cloud Function call
   - Alternative: Modify appointment ID in app code temporarily

**Expected Result:**
- Error message displayed: "الموعد غير موجود" (Appointment not found)
- Or English: "Unable to start call. Please refresh and try again."
- Call does not proceed

**Evidence to Capture:**
- [ ] Screenshot: Error message displayed
- [ ] Note: Error message text: `_________________`

#### Step 2: Verify Error Logging

**Action (Tester):**
1. Check Firebase Console → `call_logs`
2. Look for `call_error` event

**Expected Result:**
- `call_error` event logged with:
  - `errorCode`: `not-found`
  - `errorMessage`: Contains "not found" or "غير موجود"
  - `appointmentId`: The invalid appointment ID used

**Evidence to Capture:**
- [ ] Screenshot: Firebase Console showing `call_error` log
- [ ] Export error log as JSON

### Test Result

**Status:** [ ] Pass  [ ] Fail  [ ] Blocked

**Actual Duration:** `___` minutes

**Notes:**
```
[Record any observations]




```

---

## Test Scenario 5.3: No Authentication

**Objective:** Verify that unauthenticated users cannot initiate calls.

**Priority:** High  
**Estimated Duration:** 5-10 minutes

### Preconditions

- User not signed in (or auth token expired)

### Test Steps

#### Step 1: Attempt Call Without Authentication

**Action (Doctor Device):**
1. Sign out from the app
2. Attempt to call `startAgoraCall` Cloud Function directly
   - This requires developer tools or API testing tool
   - Alternative: Modify app to bypass auth check temporarily

**Expected Result:**
- Error: `unauthenticated`
- Error message: "المستخدم غير مصادق عليه" or "Please sign in to continue"

**Evidence to Capture:**
- [ ] Screenshot: Error message
- [ ] Note: Error code received: `_________________`

#### Step 2: Verify Error Handling

**Action (Tester):**
- Verify app redirects to login screen or displays appropriate error

**Expected Result:**
- User is prompted to sign in
- Call does not proceed

**Evidence to Capture:**
- [ ] Screenshot: Login prompt or error message

### Test Result

**Status:** [ ] Pass  [ ] Fail  [ ] Blocked

**Actual Duration:** `___` minutes

**Notes:**
```
[Record any observations]




```

---

## Test Scenario 5.4: Wrong Doctor

**Objective:** Verify that a doctor cannot initiate a call for another doctor's appointment.

**Priority:** High  
**Estimated Duration:** 5-10 minutes

### Preconditions

- Doctor A logged in
- Test appointment assigned to Doctor B (different doctor)

### Test Steps

#### Step 1: Attempt Call for Another Doctor's Appointment

**Action (Doctor Device):**
1. Doctor A attempts to start call for Doctor B's appointment
2. Tap "Start Video Call" button

**Expected Result:**
- Error message: "غير مصرح لك ببدء هذه المكالمة" (Not authorized to start this call)
- Or English: "You do not have permission to start this call"
- Call does not proceed

**Evidence to Capture:**
- [ ] Screenshot: Error message displayed
- [ ] Note: Logged-in doctor ID: `_________________`
- [ ] Note: Appointment's doctor ID: `_________________`

#### Step 2: Verify Permission Error Logging

**Action (Tester):**
1. Check Firebase Console → `call_logs`
2. Look for `call_error` event

**Expected Result:**
- `call_error` event logged with:
  - `errorCode`: `permission-denied`
  - `errorMessage`: Contains "not authorized" or "غير مصرح"
  - `userId`: Doctor A's ID
  - `appointmentId`: The appointment ID

**Evidence to Capture:**
- [ ] Screenshot: Firebase Console showing `call_error` log
- [ ] Export error log as JSON

### Test Result

**Status:** [ ] Pass  [ ] Fail  [ ] Blocked

**Actual Duration:** `___` minutes

**Notes:**
```
[Record any observations]




```

---

## Post-Test Activities

After completing all test scenarios:

### 1. Organize Evidence

- [ ] Move all screenshots to: `evidence/task_5_call_initiation/screenshots/`
- [ ] Move all logs to: `evidence/task_5_call_initiation/logs/`
- [ ] Move all videos to: `evidence/task_5_call_initiation/videos/`
- [ ] Rename files with clear naming convention

### 2. Export Firestore Logs

```bash
# Using Firebase CLI (if available)
firebase firestore:export evidence/task_5_call_initiation/logs/firestore_export

# Or manually export from Firebase Console
# Firestore → call_logs → Export to JSON
```

### 3. Create Evidence Index

Create file: `evidence/task_5_call_initiation/EVIDENCE_INDEX.md`

```markdown
# Evidence Index: Task 5 - Call Initiation Test Scenarios

## Scenario 5.1: Successful Call Initiation
- Screenshots:
  - scenario_5_1_step_1_doctor_appointment.png
  - scenario_5_1_step_2_loading_state.png
  - scenario_5_1_step_3_patient_notification.png
  - scenario_5_1_step_4_firestore_call_attempt.png
  - scenario_5_1_step_4_firestore_call_started.png
- Logs:
  - scenario_5_1_firestore_logs.json
  - scenario_5_1_android_doctor.log (optional)
  - scenario_5_1_ios_patient.log (optional)

## Scenario 5.2: Invalid Appointment
- Screenshots:
  - scenario_5_2_error_message.png
  - scenario_5_2_firestore_error_log.png
- Logs:
  - scenario_5_2_error_log.json

## Scenario 5.3: No Authentication
- Screenshots:
  - scenario_5_3_error_message.png
  - scenario_5_3_login_prompt.png

## Scenario 5.4: Wrong Doctor
- Screenshots:
  - scenario_5_4_error_message.png
  - scenario_5_4_firestore_error_log.png
- Logs:
  - scenario_5_4_error_log.json
```

### 4. Update Task Status

Update `.kiro/specs/voip-test/tasks.md`:

- Mark Task 5 as complete: `- [x] 5. Execute Call Initiation Test Scenarios`
- Mark each subtask as complete:
  - `- [x] 5.1 Execute Scenario 1.1: Successful Call Initiation`
  - `- [x] 5.2 Execute Scenario 1.2: Invalid Appointment`
  - `- [x] 5.3 Execute Scenario 1.3: No Authentication`
  - `- [x] 5.4 Execute Scenario 1.4: Wrong Doctor`

### 5. Document Defects

If any defects were found, create defect reports in:
`evidence/task_5_call_initiation/DEFECTS_FOUND.md`

Use the defect template from the design document.

---

## Troubleshooting

### Issue: Patient doesn't receive notification

**Possible Causes:**
1. Patient FCM token missing or invalid
2. Network connectivity issue
3. App not running or terminated
4. Notification permissions denied

**Solutions:**
1. Check patient's FCM token in Firestore: `users/{patientId}/fcmToken`
2. Verify patient device has internet connection
3. Ensure patient app is running (at least in background)
4. Check notification permissions in device settings

### Issue: "NOT_FOUND" error when calling Cloud Function

**Possible Causes:**
1. Wrong region specified
2. Function not deployed
3. Function name misspelled

**Solutions:**
1. Verify using `europe-west1` region in code
2. Check function deployment: `firebase functions:list`
3. Verify function name spelling: `startAgoraCall`

### Issue: Cannot access Firebase Console

**Solutions:**
1. Verify you have access to the `elajtech` Firebase project
2. Request access from project administrator
3. Use Firebase CLI as alternative: `firebase firestore:get call_logs`

### Issue: Appointment not found in app

**Solutions:**
1. Create test appointment in Firestore manually
2. Verify appointment status is `confirmed`
3. Check appointment `doctorId` matches logged-in doctor
4. Ensure using correct database: `elajtech`

---

## Test Execution Summary

**Tester Name:** `_________________`  
**Execution Date:** `_________________`  
**Total Duration:** `___` minutes

### Results Summary

| Scenario | Status | Duration | Notes |
|----------|--------|----------|-------|
| 5.1 Successful Call Initiation | [ ] Pass [ ] Fail | ___ min | |
| 5.2 Invalid Appointment | [ ] Pass [ ] Fail | ___ min | |
| 5.3 No Authentication | [ ] Pass [ ] Fail | ___ min | |
| 5.4 Wrong Doctor | [ ] Pass [ ] Fail | ___ min | |

**Overall Pass Rate:** `____%` (__ out of 4 scenarios passed)

### Critical Issues Found

```
[List any critical issues that block further testing]




```

### Recommendations

```
[Provide recommendations for fixes or improvements]




```

---

## Next Steps

After completing Task 5:

1. **Review Results:** Analyze test results and evidence
2. **Fix Critical Issues:** Address any critical defects found
3. **Proceed to Task 6:** Execute VoIP Notification Delivery Test Scenarios
4. **Update Test Report:** Add Task 5 results to comprehensive test report

---

**Document Version:** 1.0  
**Last Updated:** 2026-02-16  
**Maintained by:** AndroCare360 QA Team
