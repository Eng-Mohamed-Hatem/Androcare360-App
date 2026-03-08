# Task 9: VoIP Notification End-to-End Testing - Screenshots

## Overview

This folder contains screenshots captured during Task 9 manual testing. These screenshots serve as evidence that the VoIP notification delivery flow works correctly end-to-end.

**Task:** 9. Test VoIP notification delivery end-to-end  
**Requirements:** 2.1, 2.2, 2.3, 2.4, 2.5, 2.6

---

## Required Screenshots

### 1. Firebase Console - Patient FCM Token
**Filename:** `01_firestore_patient_fcm_token.png`

**What to capture:**
- Firebase Console → Firestore Database
- Database: elajtech
- Collection: users
- Document: Patient user ID
- Fields visible: `fcmToken`, `fcmTokenUpdatedAt`

**Purpose:** Verify that patient's FCM token is saved in Firestore

---

### 2. Cloud Functions Logs
**Filename:** `02_cloud_functions_logs.png`

**What to capture:**
- Firebase Console → Functions → Logs
- Filter: startAgoraCall
- All 4 log messages visible:
  1. "📱 Retrieving FCM token for patient: [patientId]"
  2. "✅ FCM token retrieved successfully"
  3. "📤 Sending VoIP notification"
  4. "✅ VoIP notification sent successfully: [response]"

**Purpose:** Verify that Cloud Function successfully sends VoIP notification

---

### 3. Patient Device - Incoming Call Notification
**Filename:** `03_patient_incoming_call_notification.png`

**What to capture:**
- Patient device screen
- Incoming call UI (CallKit on iOS or ConnectionService on Android)
- Doctor's name visible
- Accept and Decline buttons visible

**Purpose:** Verify that patient device receives and displays incoming call notification

---

### 4. Patient Device - Video Call Screen (After Accepting)
**Filename:** `04_patient_video_call_screen.png`

**What to capture:**
- Patient device screen after accepting call
- AgoraVideoCallScreen displayed
- Local video preview visible in corner
- Waiting message: "جاري الاتصال بالطبيب..."
- Control buttons visible at bottom

**Purpose:** Verify that app navigates to video call screen after accepting

---

### 5. Doctor Device - Video Call Screen (Waiting)
**Filename:** `05_doctor_video_call_screen_waiting.png`

**What to capture:**
- Doctor device screen after initiating call
- AgoraVideoCallScreen displayed
- Local video preview visible in corner
- Waiting message: "جاري الاتصال بالمريض..."
- Control buttons visible at bottom

**Purpose:** Verify that doctor sees correct waiting screen

---

### 6. Both Devices - Connected Video Call
**Filename:** `06_connected_video_call_both_devices.png`

**What to capture:**
- Side-by-side photo of both devices
- Doctor device showing patient's video (full screen)
- Patient device showing doctor's video (full screen)
- Connection status: "متصل" (Connected) on both
- No waiting messages visible

**Purpose:** Verify that video call connects successfully

---

## Optional Screenshots (for different scenarios)

### 7. App in Background - Incoming Call
**Filename:** `07_background_incoming_call.png`

**What to capture:**
- Patient device with app in background
- Incoming call notification appears
- Lock screen or home screen visible

**Purpose:** Verify notification works when app is in background

---

### 8. App Terminated - Incoming Call
**Filename:** `08_terminated_incoming_call.png`

**What to capture:**
- Patient device with app completely closed
- Incoming call notification appears
- Recent apps screen showing app was closed

**Purpose:** Verify notification works when app is terminated

---

### 9. Device Logs (if accessible)
**Filename:** `09_patient_device_logs.txt` or `09_patient_device_logs.png`

**What to capture:**
- Patient device console logs
- Logs showing:
  - "📨 Background message received"
  - "📞 Incoming call detected"
  - "📱 Incoming call notification received for appointment: [id]"

**Purpose:** Verify that FCM message is received and processed correctly

---

## Screenshot Organization

```
screenshots/task9/
├── README.md (this file)
├── 01_firestore_patient_fcm_token.png
├── 02_cloud_functions_logs.png
├── 03_patient_incoming_call_notification.png
├── 04_patient_video_call_screen.png
├── 05_doctor_video_call_screen_waiting.png
├── 06_connected_video_call_both_devices.png
├── 07_background_incoming_call.png (optional)
├── 08_terminated_incoming_call.png (optional)
└── 09_patient_device_logs.txt (optional)
```

---

## How to Capture Screenshots

### Firebase Console (Screenshots 1 & 2):
1. Open Firebase Console in browser
2. Use browser's screenshot tool or OS screenshot tool
3. Ensure all relevant information is visible
4. Crop if needed to focus on important parts

### Mobile Devices (Screenshots 3-8):
- **iOS:** Press Volume Up + Side Button simultaneously
- **Android:** Press Volume Down + Power Button simultaneously
- **Alternative:** Use device's built-in screenshot tool

### Device Logs (Screenshot 9):
- **iOS:** Use Xcode → Devices and Simulators → View Device Logs
- **Android:** Use Android Studio → Logcat or `adb logcat`
- Copy relevant logs to text file or take screenshot

---

## Screenshot Quality Guidelines

1. **Resolution:** Use high resolution (at least 1080p)
2. **Clarity:** Ensure text is readable
3. **Focus:** Crop to show relevant information
4. **Lighting:** Avoid glare or reflections on device screens
5. **Orientation:** Use portrait for mobile devices, landscape for console
6. **Annotations:** Add arrows or highlights if needed (optional)

---

## Verification Checklist

After capturing all screenshots, verify:

- [ ] All required screenshots (1-6) are captured
- [ ] Screenshots are clear and readable
- [ ] All expected UI elements are visible
- [ ] Timestamps are visible (where applicable)
- [ ] File names match the naming convention
- [ ] Screenshots are saved in this folder

---

## Usage

These screenshots will be used for:

1. **Documentation:** Evidence that Task 9 was completed successfully
2. **Troubleshooting:** Reference for debugging issues
3. **Training:** Examples for new team members
4. **QA:** Verification that VoIP flow works correctly
5. **Compliance:** Proof of testing for audit purposes

---

## Notes

- Screenshots should be taken during actual testing, not staged
- Ensure no sensitive information (real patient data) is visible
- Use test accounts and test appointments only
- If real data is accidentally captured, redact before committing

---

**Last Updated:** 2026-02-17  
**Task:** 9. Test VoIP notification delivery end-to-end  
**Status:** Awaiting screenshots from manual testing
