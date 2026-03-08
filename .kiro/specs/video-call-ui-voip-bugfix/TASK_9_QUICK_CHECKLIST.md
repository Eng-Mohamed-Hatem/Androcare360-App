# Task 9: VoIP Notification End-to-End Testing - Quick Checklist

## Pre-Test Setup
- [ ] Two physical devices ready (Device A: Doctor, Device B: Patient)
- [ ] Latest app build deployed to both devices
- [ ] Test appointment created in Firestore
- [ ] Firebase Console access ready
- [ ] Cloud Functions logs access ready

---

## Test Steps

### 1. Patient Setup (Device B)
- [ ] Sign in as patient
- [ ] Wait for sign-in to complete
- [ ] Keep app in foreground

### 2. Verify FCM Token in Firestore
- [ ] Open Firebase Console → Firestore → elajtech database
- [ ] Navigate to users collection → patient document
- [ ] Verify `fcmToken` field exists and has value
- [ ] Verify `fcmTokenUpdatedAt` field exists
- [ ] **Screenshot:** Patient document with FCM token

### 3. Doctor Initiates Call (Device A)
- [ ] Sign in as doctor
- [ ] Navigate to appointments list
- [ ] Find test appointment
- [ ] Tap "Start Video Call" button
- [ ] Video call screen opens

### 4. Check Cloud Functions Logs
- [ ] Open Firebase Console → Functions → Logs
- [ ] Filter by: `startAgoraCall`
- [ ] Verify log: "📱 Retrieving FCM token for patient: [patientId]"
- [ ] Verify log: "✅ FCM token retrieved successfully"
- [ ] Verify log: "📤 Sending VoIP notification to patient"
- [ ] Verify log: "✅ VoIP notification sent successfully"
- [ ] **Screenshot:** Cloud Functions logs

### 5. Patient Receives Notification (Device B)
- [ ] Incoming call notification appears (within 1-3 seconds)
- [ ] Doctor's name displayed
- [ ] Accept and Decline buttons visible
- [ ] Ringtone playing
- [ ] **Screenshot:** Incoming call UI

### 6. Check Patient Device Logs (if accessible)
- [ ] Log: "📨 Background message received"
- [ ] Log: "📞 Incoming call detected"
- [ ] Log: "📱 Incoming call notification received for appointment: [id]"

### 7. Patient Accepts Call (Device B)
- [ ] Tap "Accept" button
- [ ] App opens (if in background)
- [ ] Video call screen appears
- [ ] Camera permission granted
- [ ] Microphone permission granted
- [ ] Local video preview visible

### 8. Verify Navigation
- [ ] AgoraVideoCallScreen displayed
- [ ] Appointment details visible
- [ ] Waiting message: "جاري الاتصال بالطبيب..."
- [ ] Control buttons visible
- [ ] **Screenshot:** Patient video call screen

### 9. Verify Video Connection
- [ ] Doctor's video appears on patient device (full screen)
- [ ] Patient's video appears on doctor device (full screen)
- [ ] Waiting messages disappear
- [ ] Connection status: "متصل" (Connected)
- [ ] Audio working on both devices
- [ ] **Screenshot:** Connected call (both devices)

---

## Test Scenarios

### Scenario A: App in Foreground
- [ ] Patient app in foreground
- [ ] Notification appears
- [ ] All steps complete

### Scenario B: App in Background
- [ ] Patient app in background
- [ ] Notification appears
- [ ] App opens when accepted
- [ ] All steps complete

### Scenario C: App Terminated
- [ ] Patient app completely closed
- [ ] Notification appears
- [ ] App launches when accepted
- [ ] All steps complete

---

## Quick Troubleshooting

### No notification received?
1. Check FCM token exists in Firestore
2. Check Cloud Functions logs for errors
3. Verify notification permissions granted
4. Try with app in foreground first

### Cloud Functions error?
1. Check error message in logs
2. Verify appointment exists in Firestore
3. Verify database ID is 'elajtech'
4. Check network connectivity

### Video doesn't connect?
1. Verify Agora tokens generated
2. Check network on both devices
3. Verify same channel name used
4. Check Agora service initialized

---

## Success Criteria
- [ ] All 9 test steps completed successfully
- [ ] All 3 scenarios tested (foreground, background, terminated)
- [ ] All required screenshots captured
- [ ] No errors in Cloud Functions logs
- [ ] Video call connects and works properly

---

## Screenshots to Capture
1. Patient document with FCM token (Firestore)
2. Cloud Functions logs (4 log messages)
3. Incoming call UI (patient device)
4. Patient video call screen (after accepting)
5. Connected call (both devices)

---

**Task:** 9. Test VoIP notification delivery end-to-end  
**Requirements:** 2.1, 2.2, 2.3, 2.4, 2.5, 2.6  
**Date:** _____________  
**Tester:** _____________
