# Manual Testing Guide: Video Call UI Text Fix

## Overview

This guide provides step-by-step instructions for manually testing the UI text fix implemented in Task 1 and Task 2. The fix ensures that doctors and patients see role-appropriate waiting messages during video call initiation.

**Related Requirements:** 1.1, 1.2, 1.3, 1.4

## Prerequisites

### Required Setup

1. **Two Test Devices:**
   - Device A: For doctor testing
   - Device B: For patient testing
   - Can be physical devices or emulators

2. **Test Accounts:**
   - Doctor account credentials
   - Patient account credentials

3. **Test Appointment:**
   - Create a test appointment with:
     - Doctor: Test doctor account
     - Patient: Test patient account
     - Status: Confirmed
     - Scheduled time: Current or near-future time

4. **App Build:**
   - Ensure latest code is deployed to both devices
   - Verify Tasks 1 and 2 are completed (role detection + UI text update)

### Environment Verification

Before testing, verify:
- [ ] Both devices have the latest app build
- [ ] Both devices have internet connectivity
- [ ] Firebase Auth is working
- [ ] Firestore database is accessible (databaseId: 'elajtech')
- [ ] Agora credentials are configured in Cloud Functions

---

## Test Scenario 1: Doctor Initiates Call

### Objective
Verify that when a doctor initiates a video call, they see the correct waiting messages indicating they are calling the patient.

### Test Steps

#### Step 1: Sign in as Doctor (Device A)

1. Open the app on Device A
2. Sign in with doctor credentials
3. Navigate to appointments list
4. Locate the test appointment

**Expected Result:**
- ✅ Doctor successfully signed in
- ✅ Test appointment visible in list

#### Step 2: Initiate Video Call

1. Tap on the test appointment
2. Tap "Start Video Call" button
3. Wait for the video call screen to load

**Expected Result:**
- ✅ Video call screen opens
- ✅ Camera permission granted (if prompted)
- ✅ Microphone permission granted (if prompted)
- ✅ Local video preview appears in top-right corner

#### Step 3: Verify Main Waiting Message

**What to Check:**
- Look at the center of the screen
- Verify the main waiting message text

**Expected Result:**
- ✅ Main message displays: **"جاري الاتصال بالمريض..."** (Calling patient...)
- ❌ Should NOT display: "جاري الاتصال بالطبيب..." (Calling doctor...)

**Screenshot Required:** Take screenshot showing the main waiting message

#### Step 4: Verify Sub-Message with Patient Name

**What to Check:**
- Look below the main message
- Verify the sub-message includes the patient's name

**Expected Result:**
- ✅ Sub-message displays: **"في انتظار رد [Patient Name]..."** (Waiting for [Patient Name] to answer...)
- ✅ Patient name is correctly displayed (matches appointment.patientName)
- ❌ Should NOT display: "يرجى الانتظار، سيتم الاتصال بك قريباً"

**Screenshot Required:** Take screenshot showing the sub-message with patient name

#### Step 5: Verify Connection Status

**What to Check:**
- Look at the top-left corner
- Verify connection status indicator

**Expected Result:**
- ✅ Connection status shows "جاري الاتصال..." or "متصل"
- ✅ Status indicator is visible

**Screenshot Required:** Take screenshot showing connection status

---

## Test Scenario 2: Patient Receives Call

### Objective
Verify that when a patient receives an incoming video call, they see the correct waiting messages indicating they are being called by the doctor.

### Test Steps

#### Step 1: Sign in as Patient (Device B)

1. Open the app on Device B
2. Sign in with patient credentials
3. Keep the app in foreground

**Expected Result:**
- ✅ Patient successfully signed in
- ✅ App is ready to receive notifications

#### Step 2: Doctor Initiates Call (Device A)

1. On Device A (doctor), initiate the video call (as in Scenario 1)
2. Wait for FCM notification to be sent

**Expected Result:**
- ✅ Doctor's device shows waiting screen
- ✅ Cloud Function sends FCM notification to patient

#### Step 3: Patient Receives Notification (Device B)

**What to Check:**
- Verify incoming call notification appears
- Verify CallKit (iOS) or ConnectionService (Android) displays

**Expected Result:**
- ✅ Incoming call notification appears
- ✅ Doctor's name is displayed in notification
- ✅ Accept and Decline buttons are visible

**Screenshot Required:** Take screenshot of incoming call notification

#### Step 4: Patient Accepts Call

1. Tap "Accept" button on the incoming call notification
2. Wait for video call screen to load

**Expected Result:**
- ✅ Video call screen opens
- ✅ Camera permission granted (if prompted)
- ✅ Microphone permission granted (if prompted)
- ✅ Local video preview appears in top-right corner

#### Step 5: Verify Main Waiting Message (Patient View)

**What to Check:**
- Look at the center of the screen
- Verify the main waiting message text

**Expected Result:**
- ✅ Main message displays: **"جاري الاتصال بالطبيب..."** (Calling doctor...)
- ❌ Should NOT display: "جاري الاتصال بالمريض..." (Calling patient...)

**Screenshot Required:** Take screenshot showing the main waiting message

#### Step 6: Verify Sub-Message (Patient View)

**What to Check:**
- Look below the main message
- Verify the sub-message text

**Expected Result:**
- ✅ Sub-message displays: **"يرجى الانتظار، سيتم الاتصال بك قريباً"** (Please wait, you will be called soon)
- ❌ Should NOT display: "في انتظار رد [name]..."

**Screenshot Required:** Take screenshot showing the sub-message

#### Step 7: Verify Connection Status (Patient View)

**What to Check:**
- Look at the top-left corner
- Verify connection status indicator

**Expected Result:**
- ✅ Connection status shows "جاري الاتصال..." or "متصل"
- ✅ Status indicator is visible

**Screenshot Required:** Take screenshot showing connection status

#### Step 8: Verify Video Connection

**What to Check:**
- Wait for both users to join the channel
- Verify remote video appears

**Expected Result:**
- ✅ Doctor's video appears on patient's screen (full screen)
- ✅ Patient's video appears on doctor's screen (full screen)
- ✅ Waiting messages disappear once remote user joins
- ✅ Both users can see and hear each other

**Screenshot Required:** Take screenshot of connected video call (both devices)

---

## Test Scenario 3: Edge Cases

### Test 3.1: Unknown User Role

**Objective:** Verify behavior when current user ID doesn't match doctorId or patientId

**Steps:**
1. Create a test scenario where user ID is neither doctor nor patient
2. Attempt to join the video call

**Expected Result:**
- ✅ App defaults to patient role (safer assumption)
- ✅ Patient waiting messages are displayed
- ✅ No crash or error occurs

### Test 3.2: Missing Patient/Doctor Name

**Objective:** Verify behavior when appointment data is incomplete

**Steps:**
1. Create a test appointment with missing patientName or doctorName
2. Initiate video call

**Expected Result:**
- ✅ App handles missing name gracefully
- ✅ Sub-message displays without name or with placeholder
- ✅ No crash or error occurs

### Test 3.3: Long Names

**Objective:** Verify UI handles long patient/doctor names

**Steps:**
1. Create a test appointment with very long patient name (e.g., 50+ characters)
2. Initiate video call as doctor

**Expected Result:**
- ✅ Long name is displayed correctly (may wrap to multiple lines)
- ✅ UI remains readable and properly formatted
- ✅ No text overflow or layout issues

---

## Screenshot Documentation

### Required Screenshots

For each test scenario, capture the following screenshots:

#### Doctor View (Scenario 1):
1. **doctor_waiting_main_message.png** - Main message "جاري الاتصال بالمريض..."
2. **doctor_waiting_sub_message.png** - Sub-message with patient name
3. **doctor_connection_status.png** - Connection status indicator
4. **doctor_connected_view.png** - Full screen after patient joins

#### Patient View (Scenario 2):
1. **patient_incoming_call_notification.png** - Incoming call notification
2. **patient_waiting_main_message.png** - Main message "جاري الاتصال بالطبيب..."
3. **patient_waiting_sub_message.png** - Sub-message "يرجى الانتظار..."
4. **patient_connection_status.png** - Connection status indicator
5. **patient_connected_view.png** - Full screen after doctor joins

### Screenshot Organization

Create a folder structure:
```
.kiro/specs/video-call-ui-voip-bugfix/screenshots/
├── doctor/
│   ├── waiting_main_message.png
│   ├── waiting_sub_message.png
│   ├── connection_status.png
│   └── connected_view.png
└── patient/
    ├── incoming_call_notification.png
    ├── waiting_main_message.png
    ├── waiting_sub_message.png
    ├── connection_status.png
    └── connected_view.png
```

---

## Test Results Checklist

### Scenario 1: Doctor Initiates Call
- [ ] Doctor sees "جاري الاتصال بالمريض..." (main message)
- [ ] Doctor sees "في انتظار رد [Patient Name]..." (sub-message)
- [ ] Patient name is correctly displayed
- [ ] Connection status is visible
- [ ] Screenshots captured

### Scenario 2: Patient Receives Call
- [ ] Patient receives incoming call notification
- [ ] Patient sees "جاري الاتصال بالطبيب..." (main message)
- [ ] Patient sees "يرجى الانتظار، سيتم الاتصال بك قريباً" (sub-message)
- [ ] Connection status is visible
- [ ] Screenshots captured

### Scenario 3: Edge Cases
- [ ] Unknown user role handled gracefully
- [ ] Missing names handled gracefully
- [ ] Long names displayed correctly

### Video Connection
- [ ] Both users can see each other's video
- [ ] Both users can hear each other's audio
- [ ] Waiting messages disappear after connection
- [ ] No UI glitches or errors

---

## Troubleshooting

### Issue: Waiting messages not appearing

**Possible Causes:**
- Tasks 1 and 2 not completed
- Code not deployed to test devices
- Build cache issue

**Solutions:**
1. Verify Tasks 1 and 2 are marked as completed
2. Rebuild the app: `flutter clean && flutter pub get && flutter run`
3. Check that role detection logic is present in `agora_video_call_screen.dart`

### Issue: Wrong messages displayed

**Possible Causes:**
- Role detection logic incorrect
- User ID mismatch
- Appointment data incorrect

**Solutions:**
1. Verify current user ID matches appointment.doctorId (for doctor)
2. Check appointment data in Firestore
3. Add debug logs to verify role detection:
   ```dart
   debugPrint('Current User ID: $currentUserId');
   debugPrint('Doctor ID: ${widget.appointment.doctorId}');
   debugPrint('Is Doctor: $_isDoctor');
   ```

### Issue: Patient doesn't receive notification

**Possible Causes:**
- FCM token not saved
- Cloud Function not sending notification
- Network issue

**Solutions:**
1. Verify FCM token exists in Firestore users collection
2. Check Cloud Functions logs for errors
3. Verify patient device has internet connectivity
4. See Phase 2 tasks for VoIP notification debugging

---

## Test Completion

### Sign-Off

After completing all test scenarios and capturing screenshots:

1. **Review Results:**
   - All checkboxes in Test Results Checklist are marked
   - All required screenshots are captured and organized
   - No critical issues found

2. **Document Issues:**
   - If any issues found, document them in a separate file
   - Include steps to reproduce, expected vs actual behavior
   - Attach relevant screenshots

3. **Update Task Status:**
   - Mark Task 3 as completed in tasks.md
   - Add link to this testing guide
   - Add link to screenshots folder

4. **Notify Team:**
   - Share test results with development team
   - Provide feedback on UI/UX
   - Suggest improvements if needed

---

## Next Steps

After completing manual testing:

1. **If all tests pass:**
   - Mark Task 3 as completed
   - Proceed to Task 4: Checkpoint - Ensure Phase 1 tests pass
   - Begin Phase 2: VoIP notification investigation

2. **If issues found:**
   - Document issues in detail
   - Create bug reports
   - Fix issues before proceeding to Phase 2

---

## References

- **Requirements:** `.kiro/specs/video-call-ui-voip-bugfix/requirements.md`
- **Design:** `.kiro/specs/video-call-ui-voip-bugfix/design.md`
- **Tasks:** `.kiro/specs/video-call-ui-voip-bugfix/tasks.md`
- **Implementation:** `lib/features/patient/consultation/presentation/screens/agora_video_call_screen.dart`

---

**Document Version:** 1.0  
**Last Updated:** 2026-02-17  
**Author:** AndroCare360 Development Team
