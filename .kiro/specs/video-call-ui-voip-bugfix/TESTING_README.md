# Testing Documentation: Video Call UI Text Fix

## Overview

This directory contains comprehensive testing documentation for the Video Call UI Text Fix (Phase 1 of the VoIP bugfix spec).

## 📚 Documentation Files

### 1. MANUAL_TESTING_GUIDE.md
**Purpose:** Comprehensive step-by-step manual testing guide

**Use When:**
- Performing detailed manual testing
- Need complete test scenarios with expected results
- Training new testers
- Documenting test procedures

**Contents:**
- Detailed test scenarios (Doctor view, Patient view, Edge cases)
- Step-by-step instructions with expected results
- Screenshot requirements and organization
- Troubleshooting guide
- Test completion checklist

### 2. MANUAL_TEST_RESULTS_TEMPLATE.md
**Purpose:** Template for documenting test execution results

**Use When:**
- Recording test execution results
- Documenting issues found
- Creating test reports
- Tracking test coverage

**Contents:**
- Test execution information form
- Pass/Fail checkboxes for each test step
- Issue tracking section
- Requirements validation checklist
- Screenshot checklist
- Sign-off section

### 3. QUICK_TEST_CHECKLIST.md
**Purpose:** Quick reference checklist for rapid testing

**Use When:**
- Need quick verification of UI text fix
- Performing smoke tests
- Quick regression testing
- Time-constrained testing

**Contents:**
- Condensed test steps
- Quick pass/fail checkboxes
- Essential screenshot list
- Quick issue tracking

## 🎯 Testing Workflow

### For First-Time Testing

1. **Read:** `MANUAL_TESTING_GUIDE.md` (complete guide)
2. **Prepare:** Set up test environment as per prerequisites
3. **Execute:** Follow test scenarios step-by-step
4. **Document:** Fill out `MANUAL_TEST_RESULTS_TEMPLATE.md`
5. **Capture:** Take all required screenshots
6. **Review:** Verify all requirements are validated

### For Quick Verification

1. **Use:** `QUICK_TEST_CHECKLIST.md`
2. **Execute:** Run through quick checklist
3. **Document:** Note any issues found
4. **Escalate:** If issues found, perform full testing using guide

### For Regression Testing

1. **Use:** `QUICK_TEST_CHECKLIST.md` for initial check
2. **If issues found:** Use `MANUAL_TESTING_GUIDE.md` for detailed investigation
3. **Document:** Fill out `MANUAL_TEST_RESULTS_TEMPLATE.md`

## 📸 Screenshot Requirements

### Required Screenshots (9 total)

**Doctor View (4 screenshots):**
1. `doctor/waiting_main_message.png` - Main message "جاري الاتصال بالمريض..."
2. `doctor/waiting_sub_message.png` - Sub-message with patient name
3. `doctor/connection_status.png` - Connection status indicator
4. `doctor/connected_view.png` - Full screen after patient joins

**Patient View (5 screenshots):**
1. `patient/incoming_call_notification.png` - Incoming call notification
2. `patient/waiting_main_message.png` - Main message "جاري الاتصال بالطبيب..."
3. `patient/waiting_sub_message.png` - Sub-message "يرجى الانتظار..."
4. `patient/connection_status.png` - Connection status indicator
5. `patient/connected_view.png` - Full screen after doctor joins

### Screenshot Organization

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

## ✅ Requirements Being Tested

### Requirement 1.1
**Description:** Doctor sees "جاري الاتصال بالمريض..." when initiating call  
**Test Coverage:** Scenario 1, Step 3  
**Evidence:** Screenshot `doctor/waiting_main_message.png`

### Requirement 1.2
**Description:** Doctor sees "في انتظار رد [patient name]..." with patient name  
**Test Coverage:** Scenario 1, Step 4  
**Evidence:** Screenshot `doctor/waiting_sub_message.png`

### Requirement 1.3
**Description:** Patient sees "جاري الاتصال بالطبيب..." when receiving call  
**Test Coverage:** Scenario 2, Step 5  
**Evidence:** Screenshot `patient/waiting_main_message.png`

### Requirement 1.4
**Description:** Patient sees "يرجى الانتظار، سيتم الاتصال بك قريباً"  
**Test Coverage:** Scenario 2, Step 6  
**Evidence:** Screenshot `patient/waiting_sub_message.png`

## 🔧 Test Environment Setup

### Prerequisites

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
   - Verify Tasks 1 and 2 are completed

### Environment Verification

Before testing, verify:
- [ ] Both devices have the latest app build
- [ ] Both devices have internet connectivity
- [ ] Firebase Auth is working
- [ ] Firestore database is accessible (databaseId: 'elajtech')
- [ ] Agora credentials are configured in Cloud Functions

## 🐛 Common Issues & Solutions

### Issue: Waiting messages not appearing

**Solutions:**
1. Verify Tasks 1 and 2 are completed
2. Rebuild the app: `flutter clean && flutter pub get && flutter run`
3. Check role detection logic in `agora_video_call_screen.dart`

### Issue: Wrong messages displayed

**Solutions:**
1. Verify current user ID matches appointment.doctorId (for doctor)
2. Check appointment data in Firestore
3. Add debug logs to verify role detection

### Issue: Patient doesn't receive notification

**Solutions:**
1. Verify FCM token exists in Firestore users collection
2. Check Cloud Functions logs for errors
3. Verify patient device has internet connectivity
4. See Phase 2 tasks for VoIP notification debugging

## 📊 Test Metrics

### Test Coverage
- **Total Test Scenarios:** 3 (Doctor view, Patient view, Edge cases)
- **Total Test Steps:** 18
- **Requirements Covered:** 4 (1.1, 1.2, 1.3, 1.4)
- **Screenshots Required:** 9

### Success Criteria
- All 18 test steps pass
- All 4 requirements validated
- All 9 screenshots captured
- No critical issues found

## 🚀 Next Steps After Testing

### If All Tests Pass
1. Mark Task 3 as completed in `tasks.md`
2. Proceed to Task 4: Checkpoint - Ensure Phase 1 tests pass
3. Begin Phase 2: VoIP notification investigation

### If Issues Found
1. Document issues in `MANUAL_TEST_RESULTS_TEMPLATE.md`
2. Create bug reports with screenshots
3. Fix issues before proceeding to Phase 2
4. Re-test after fixes

## 📝 Related Documentation

### Spec Documents
- **Requirements:** `requirements.md`
- **Design:** `design.md`
- **Tasks:** `tasks.md`

### Implementation
- **Video Call Screen:** `lib/features/patient/consultation/presentation/screens/agora_video_call_screen.dart`
- **Widget Tests:** `test/widget/screens/agora_video_call_screen_test.dart`

### Project Documentation
- **README:** `README.md` (project root)
- **Contributing:** `CONTRIBUTING.md`
- **API Documentation:** `API_DOCUMENTATION.md`

## 👥 Roles & Responsibilities

### Tester
- Execute test scenarios
- Capture screenshots
- Document results
- Report issues

### Developer
- Fix issues found during testing
- Verify fixes
- Update implementation

### Reviewer
- Review test results
- Approve test completion
- Sign off on test reports

## 📞 Support

For questions or issues:
- Review troubleshooting section in `MANUAL_TESTING_GUIDE.md`
- Check related documentation
- Contact development team

---

**Version:** 1.0  
**Last Updated:** 2026-02-17  
**Maintained by:** AndroCare360 Development Team
