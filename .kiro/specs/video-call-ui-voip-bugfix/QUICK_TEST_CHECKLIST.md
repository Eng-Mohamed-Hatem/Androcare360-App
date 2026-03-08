# Quick Test Checklist: Video Call UI Text Fix

## 🎯 Quick Reference for Manual Testing

Use this checklist for rapid testing of the UI text fix. For detailed instructions, see `MANUAL_TESTING_GUIDE.md`.

---

## ✅ Pre-Test Setup

- [ ] Two test devices ready (Device A: Doctor, Device B: Patient)
- [ ] Latest app build deployed to both devices
- [ ] Test accounts ready (doctor + patient)
- [ ] Test appointment created and confirmed
- [ ] Internet connectivity verified on both devices

---

## 👨‍⚕️ Doctor View Tests (Device A)

### Sign In & Initiate Call
- [ ] Sign in as doctor
- [ ] Navigate to test appointment
- [ ] Tap "Start Video Call"
- [ ] Video call screen opens

### Verify UI Text
- [ ] ✅ Main message: **"جاري الاتصال بالمريض..."** (Calling patient...)
- [ ] ❌ NOT showing: "جاري الاتصال بالطبيب..."
- [ ] ✅ Sub-message: **"في انتظار رد [Patient Name]..."**
- [ ] ✅ Patient name is correct
- [ ] ❌ NOT showing: "يرجى الانتظار، سيتم الاتصال بك قريباً"

### Screenshots
- [ ] 📸 Main waiting message
- [ ] 📸 Sub-message with patient name
- [ ] 📸 Connection status

---

## 👤 Patient View Tests (Device B)

### Receive Call
- [ ] Sign in as patient
- [ ] Wait for incoming call notification
- [ ] Incoming call UI appears (CallKit/ConnectionService)
- [ ] Tap "Accept"
- [ ] Video call screen opens

### Verify UI Text
- [ ] ✅ Main message: **"جاري الاتصال بالطبيب..."** (Calling doctor...)
- [ ] ❌ NOT showing: "جاري الاتصال بالمريض..."
- [ ] ✅ Sub-message: **"يرجى الانتظار، سيتم الاتصال بك قريباً"**
- [ ] ❌ NOT showing: "في انتظار رد [name]..."

### Screenshots
- [ ] 📸 Incoming call notification
- [ ] 📸 Main waiting message
- [ ] 📸 Sub-message
- [ ] 📸 Connection status

---

## 🔗 Video Connection Tests

### Both Devices
- [ ] Doctor's video visible on patient's screen
- [ ] Patient's video visible on doctor's screen
- [ ] Audio working both ways
- [ ] Waiting messages disappear after connection
- [ ] No UI glitches or errors

### Screenshots
- [ ] 📸 Connected view (doctor device)
- [ ] 📸 Connected view (patient device)

---

## 📋 Requirements Validation

- [ ] **Req 1.1:** Doctor sees "جاري الاتصال بالمريض..." ✅
- [ ] **Req 1.2:** Doctor sees "في انتظار رد [patient name]..." ✅
- [ ] **Req 1.3:** Patient sees "جاري الاتصال بالطبيب..." ✅
- [ ] **Req 1.4:** Patient sees "يرجى الانتظار، سيتم الاتصال بك قريباً" ✅

---

## 🐛 Issues Found

**Issue 1:**
- Description: _____________________
- Severity: [ ] Critical [ ] High [ ] Medium [ ] Low

**Issue 2:**
- Description: _____________________
- Severity: [ ] Critical [ ] High [ ] Medium [ ] Low

**Issue 3:**
- Description: _____________________
- Severity: [ ] Critical [ ] High [ ] Medium [ ] Low

---

## ✅ Test Result

- [ ] **ALL TESTS PASSED** ✅ - Ready for Phase 2
- [ ] **SOME TESTS FAILED** ⚠️ - Needs fixes
- [ ] **CRITICAL ISSUES** 🚨 - Immediate attention required

---

## 📁 Screenshot Organization

Save screenshots in:
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

## 📝 Next Steps

After completing this checklist:

1. [ ] Fill out detailed results in `MANUAL_TEST_RESULTS_TEMPLATE.md`
2. [ ] Organize and save all screenshots
3. [ ] Document any issues found
4. [ ] Update Task 3 status to "completed" in `tasks.md`
5. [ ] Proceed to Task 4: Checkpoint

---

**Quick Tip:** If you find any issues, refer to the Troubleshooting section in `MANUAL_TESTING_GUIDE.md` for solutions.
