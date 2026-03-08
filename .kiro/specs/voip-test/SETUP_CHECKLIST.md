# Test Environment Setup Checklist
## Quick Reference for VoIP Testing Setup

**Date:** _______________  
**Tester:** _______________

---

## 1. Test Devices (□ = Not Started, ◐ = In Progress, ✓ = Complete)

### Android Devices
- [ ] Device 1: _____________ (OS: _____) - Role: Doctor
- [ ] Device 2: _____________ (OS: _____) - Role: Patient
- [ ] Device 3: _____________ (OS: _____) - Role: _______
- [ ] Device 4: _____________ (OS: _____) - Role: _______

### iOS Devices
- [ ] Device 1: _____________ (OS: _____) - Role: Doctor
- [ ] Device 2: _____________ (OS: _____) - Role: Patient
- [ ] Device 3: _____________ (OS: _____) - Role: _______
- [ ] Device 4: _____________ (OS: _____) - Role: _______

### Device Configuration (Per Device)
- [ ] Developer options enabled
- [ ] USB debugging enabled (Android)
- [ ] AndroCare360 app installed
- [ ] All permissions granted (Camera, Mic, Notifications)
- [ ] Device fully charged
- [ ] Screen lock disabled/extended
- [ ] Logging configured

---

## 2. Network Configuration

### WiFi Network
- [ ] WiFi network configured: _______________
- [ ] Speed test completed: Download _____ Mbps, Upload _____ Mbps
- [ ] All devices connected to WiFi
- [ ] Network stability verified

### Mobile Data
- [ ] 4G/LTE verified on all devices
- [ ] 3G configuration tested
- [ ] Data usage baseline recorded

### Network Tools
- [ ] Network monitoring app installed
- [ ] Wireshark configured (optional)
- [ ] Charles Proxy configured (optional)

---

## 3. Test Accounts

### Doctor Accounts (Minimum 3)
- [ ] doctor.test1@androcare360.test - ID: _______________
- [ ] doctor.test2@androcare360.test - ID: _______________
- [ ] doctor.test3@androcare360.test - ID: _______________

### Patient Accounts (Minimum 5)
- [ ] patient.test1@androcare360.test - ID: _______________
- [ ] patient.test2@androcare360.test - ID: _______________
- [ ] patient.test3@androcare360.test - ID: _______________
- [ ] patient.test4@androcare360.test - ID: _______________
- [ ] patient.test5@androcare360.test - ID: _______________

### Account Verification
- [ ] All accounts created in Firebase Authentication
- [ ] All user profiles created in Firestore
- [ ] Login tested for all accounts
- [ ] FCM tokens generated for all accounts

---

## 4. Test Appointments

### Appointments Created (Minimum 10)
- [ ] apt_test_001: Doctor 1 → Patient 1
- [ ] apt_test_002: Doctor 1 → Patient 2
- [ ] apt_test_003: Doctor 2 → Patient 3
- [ ] apt_test_004: Doctor 2 → Patient 4
- [ ] apt_test_005: Doctor 3 → Patient 5
- [ ] apt_test_006: Doctor 1 → Patient 3
- [ ] apt_test_007: Doctor 2 → Patient 1
- [ ] apt_test_008: Doctor 3 → Patient 2
- [ ] apt_test_009: Doctor 1 → Patient 4
- [ ] apt_test_010: Doctor 2 → Patient 5

### Appointment Verification
- [ ] All appointments visible in Firestore
- [ ] Appointments visible in doctor app
- [ ] Appointments visible in patient app
- [ ] Appointment statuses correct (confirmed/scheduled)

---

## 5. Monitoring Tools

### Firebase Console
- [ ] Firebase Console access verified
- [ ] Firestore database access confirmed (elajtech)
- [ ] call_logs collection accessible
- [ ] Real-time monitoring configured
- [ ] Query filters created

### Agora Analytics Dashboard
- [ ] Agora Console access verified
- [ ] AndroCare360 project selected
- [ ] Analytics dashboard accessible
- [ ] Quality metrics enabled
- [ ] Real-time monitoring enabled
- [ ] Report exports configured

### Device Logging
- [ ] Android logcat configured
- [ ] iOS Console.app configured
- [ ] Log collection scripts created
- [ ] Log filtering tested
- [ ] Log file naming convention defined

### Screen Recording
- [ ] Android screen recording tested
- [ ] iOS screen recording tested
- [ ] Recording quality verified
- [ ] Storage space sufficient

---

## 6. Evidence Collection

### Folder Structure
- [ ] test_evidence/ folder created
- [ ] screenshots/ subfolders created
- [ ] videos/ subfolders created
- [ ] logs/ subfolders created
- [ ] metrics/ subfolders created
- [ ] reports/ subfolders created

### File Naming Convention
- [ ] Naming convention documented
- [ ] Example files created
- [ ] Team trained on naming convention

---

## 7. Pre-Test Verification

### Smoke Test
- [ ] Doctor can login successfully
- [ ] Patient can login successfully
- [ ] Appointments visible in both apps
- [ ] Basic navigation works
- [ ] Permissions working correctly

### End-to-End Test
- [ ] Doctor initiates call successfully
- [ ] Patient receives notification
- [ ] Patient accepts call
- [ ] Video/audio connection established
- [ ] Call controls work (mute, video, camera)
- [ ] Call ends successfully
- [ ] Logs captured in Firestore

### Monitoring Verification
- [ ] Call logs visible in Firestore
- [ ] Device logs captured
- [ ] Screenshots captured successfully
- [ ] Video recording successful
- [ ] Agora analytics showing data

---

## 8. Documentation

- [ ] Device specifications documented
- [ ] Network configurations documented
- [ ] Test credentials documented
- [ ] Appointment IDs documented
- [ ] Monitoring access documented
- [ ] Troubleshooting guide reviewed

---

## 9. Team Readiness

- [ ] All team members have access to Firebase Console
- [ ] All team members have access to Agora Dashboard
- [ ] Roles assigned (who tests doctor, who tests patient)
- [ ] Communication channel established
- [ ] Test schedule created
- [ ] Evidence collection procedures understood

---

## 10. Final Verification

- [ ] All checklist items above completed
- [ ] Setup guide reviewed
- [ ] Any issues documented
- [ ] Backup plan established
- [ ] Ready to proceed to Task 2 (Test Plan Creation)

---

## Notes and Issues

**Issues Encountered:**
```
[Document any issues encountered during setup]




```

**Resolutions:**
```
[Document how issues were resolved]




```

**Additional Notes:**
```
[Any additional observations or notes]




```

---

## Sign-Off

**Setup Completed By:** _______________  
**Date:** _______________  
**Signature:** _______________

**Verified By:** _______________  
**Date:** _______________  
**Signature:** _______________

---

**Next Step:** Proceed to Task 2 - Create Comprehensive Test Plan Document

**Reference:** See TEST_ENVIRONMENT_SETUP_GUIDE.md for detailed instructions
