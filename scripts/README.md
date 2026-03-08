# Test Setup Scripts
## AndroCare360 VoIP Testing Automation

This folder contains automated scripts to set up the test environment for VoIP video call system testing.

---

## Available Scripts

### 1. create_test_accounts.dart
Creates test doctor and patient accounts in Firebase Authentication and Firestore.

**Creates:**
- 3 doctor accounts (doctor.test1-3@androcare360.test)
- 5 patient accounts (patient.test1-5@androcare360.test)

**Usage:**
```bash
# Using Firebase Emulator (recommended for testing)
dart scripts/create_test_accounts.dart --environment emulator

# Using development environment
dart scripts/create_test_accounts.dart --environment dev

# Using production environment (⚠️ use with caution)
dart scripts/create_test_accounts.dart --environment prod
```

**Prerequisites:**
- Firebase project configured
- Firebase CLI installed and logged in
- For emulator: Firebase Emulator Suite running

**Output:**
- Firebase Auth users created
- Firestore user documents created with FCM tokens
- Summary report with credentials

---

### 2. create_test_appointments.dart
Creates test appointments between doctors and patients.

**Creates:**
- 10 test appointments with various statuses
- 7 confirmed appointments (ready for testing)
- 1 pending appointment
- 2 scheduled appointments

**Usage:**
```bash
# Using Firebase Emulator
dart scripts/create_test_appointments.dart --environment emulator

# Using development environment
dart scripts/create_test_appointments.dart --environment dev
```

**Prerequisites:**
- Test accounts must be created first (run create_test_accounts.dart)
- Firebase project configured

**Output:**
- Appointment documents created in Firestore
- Summary report with appointment IDs

---

### 3. verify_test_environment.dart
Verifies that all test accounts and appointments are properly configured.

**Verifies:**
- Database configuration (databaseId: 'elajtech')
- Firestore collections (users, appointments, call_logs)
- 3 doctor accounts (authentication + Firestore documents)
- 5 patient accounts (authentication + Firestore documents)
- 10 test appointments (with valid doctor/patient references)

**Usage:**
```bash
# Using Firebase Emulator
dart scripts/verify_test_environment.dart --environment emulator

# Using development environment
dart scripts/verify_test_environment.dart --environment dev

# With detailed report
dart scripts/verify_test_environment.dart --environment emulator --detailed
```

**Prerequisites:**
- Test accounts and appointments must be created first
- Firebase project configured

**Output:**
- Verification results for each check
- Success rate percentage
- Detailed report (if --detailed flag used)
- Exit code 0 if all checks pass, 1 if any fail

**Example Output:**
```
🔍 AndroCare360 Test Environment Verifier
Environment: emulator
============================================================

⚙️  Verifying Database Configuration:
  ✅ Database ID: elajtech (verified)

🗄️  Verifying Firestore Collections:
  ✅ users - 8 documents found
  ✅ appointments - 10 documents found
  ✅ call_logs - Collection accessible

👨‍⚕️  Verifying Doctor Accounts:
  ✅ doctor.test1@androcare360.test
  ✅ doctor.test2@androcare360.test
  ✅ doctor.test3@androcare360.test

👤 Verifying Patient Accounts:
  ✅ patient.test1@androcare360.test
  ✅ patient.test2@androcare360.test
  ✅ patient.test3@androcare360.test
  ✅ patient.test4@androcare360.test
  ✅ patient.test5@androcare360.test

📅 Verifying Appointments:
  ✅ apt_test_001 (confirmed)
  ✅ apt_test_002 (confirmed)
  ... (8 more)

============================================================
📊 VERIFICATION SUMMARY
============================================================

Total Checks: 24
✅ Passed: 24
❌ Failed: 0
⚠️  Warnings: 0

Success Rate: 100.0%

🎉 Perfect! All checks passed. Environment is ready for testing.
============================================================
```

---

## Quick Start Guide

### Step 1: Install Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.2
```

Then run:
```bash
flutter pub get
```

### Step 2: Start Firebase Emulator (Optional but Recommended)

```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Start emulators
firebase emulators:start
```

The emulator UI will be available at: http://localhost:4000

### Step 3: Run Account Creation Script

```bash
dart scripts/create_test_accounts.dart --environment emulator
```

**Expected Output:**
```
🚀 AndroCare360 Test Account Creator
Environment: emulator
============================================================

🔧 Connecting to Firebase Emulator...
✅ Connected to Firebase Emulator

============================================================
👨‍⚕️  CREATING DOCTOR ACCOUNTS
============================================================

📝 Creating account: doctor.test1@androcare360.test
  ✅ Firebase Auth user created
  📌 UID: abc123...
  ✅ Firestore document created

... (more accounts)

✅ Created 3/3 doctor accounts

============================================================
👤 CREATING PATIENT ACCOUNTS
============================================================

... (patient accounts)

✅ Created 5/5 patient accounts

============================================================
📊 ACCOUNT CREATION SUMMARY
============================================================

✅ Total Accounts Created: 8
   - Doctors: 3
   - Patients: 5

📋 Test Credentials:

Doctor Accounts:
  Email: doctor.test1@androcare360.test
  Email: doctor.test2@androcare360.test
  Email: doctor.test3@androcare360.test
  Password: TestDoctor123!

Patient Accounts:
  Email: patient.test1@androcare360.test
  Email: patient.test2@androcare360.test
  Email: patient.test3@androcare360.test
  Email: patient.test4@androcare360.test
  Email: patient.test5@androcare360.test
  Password: TestPatient123!

🔗 Quick Verification:
  Firestore UI: http://localhost:4000/firestore
  Auth UI: http://localhost:4000/auth

============================================================

✅ Account creation completed successfully!
```

### Step 4: Run Appointment Creation Script

```bash
dart scripts/create_test_appointments.dart --environment emulator
```

**Expected Output:**
```
🚀 AndroCare360 Test Appointment Creator
Environment: emulator
============================================================

🔧 Connecting to Firestore Emulator...
✅ Connected to Firestore Emulator

============================================================
📅 CREATING TEST APPOINTMENTS
============================================================

📝 Creating appointment: apt_test_001
  ✅ Appointment created successfully
  👨‍⚕️ Doctor: doctor.test1@androcare360.test
  👤 Patient: patient.test1@androcare360.test
  📅 Scheduled: 2026-02-16 15:00:00.000
  📊 Status: confirmed

... (more appointments)

✅ Created 10/10 appointments

============================================================
📊 APPOINTMENT CREATION SUMMARY
============================================================

✅ Total Appointments Created: 10

📋 Appointment IDs:
  - apt_test_001
  - apt_test_002
  - apt_test_003
  - apt_test_004
  - apt_test_005
  - apt_test_006
  - apt_test_007
  - apt_test_008
  - apt_test_009
  - apt_test_010

📝 Status Breakdown:
  - Confirmed: 7 (ready for video call testing)
  - Pending: 1
  - Scheduled: 2

🔗 Verification:
  Firestore UI: http://localhost:4000/firestore
  Collection: appointments

============================================================

✅ Appointment creation completed successfully!
```

### Step 5: Verify Test Environment (Automated)

```bash
dart scripts/verify_test_environment.dart --environment emulator
```

**Expected Output:**
```
🔍 AndroCare360 Test Environment Verifier
Environment: emulator
============================================================

⚙️  Verifying Database Configuration:
  ✅ Database ID: elajtech (verified)

🗄️  Verifying Firestore Collections:
  ✅ users - 8 documents found
  ✅ appointments - 10 documents found
  ✅ call_logs - Collection accessible

👨‍⚕️  Verifying Doctor Accounts:
  ✅ doctor.test1@androcare360.test
  ✅ doctor.test2@androcare360.test
  ✅ doctor.test3@androcare360.test

👤 Verifying Patient Accounts:
  ✅ patient.test1@androcare360.test
  ✅ patient.test2@androcare360.test
  ✅ patient.test3@androcare360.test
  ✅ patient.test4@androcare360.test
  ✅ patient.test5@androcare360.test

📅 Verifying Appointments:
  ✅ apt_test_001 (confirmed)
  ✅ apt_test_002 (confirmed)
  ✅ apt_test_003 (confirmed)
  ✅ apt_test_004 (confirmed)
  ✅ apt_test_005 (confirmed)
  ✅ apt_test_006 (pending)
  ✅ apt_test_007 (scheduled)
  ✅ apt_test_008 (confirmed)
  ✅ apt_test_009 (confirmed)
  ✅ apt_test_010 (confirmed)

============================================================
📊 VERIFICATION SUMMARY
============================================================

Total Checks: 24
✅ Passed: 24
❌ Failed: 0
⚠️  Warnings: 0

Success Rate: 100.0%

🎉 Perfect! All checks passed. Environment is ready for testing.
============================================================
```

**For Detailed Report:**
```bash
dart scripts/verify_test_environment.dart --environment emulator --detailed
```

This will show:
- Database statistics (user count, appointment count)
- Complete list of all user accounts
- Complete list of all appointments

### Step 6: Verify in Firebase Console (Manual)

**Using Emulator:**
1. Open http://localhost:4000
2. Click "Firestore" to view database
3. Check `users` collection (should have 8 documents)
4. Check `appointments` collection (should have 10 documents)
5. Click "Authentication" to view auth users

**Using Production/Dev:**
1. Open https://console.firebase.google.com
2. Select your project
3. Navigate to Firestore Database
4. Verify `users` and `appointments` collections

---

## Test Credentials Reference

### Doctor Accounts

| Email | Password | Specialization | UID |
|-------|----------|----------------|-----|
| doctor.test1@androcare360.test | TestDoctor123! | Nutrition | [generated] |
| doctor.test2@androcare360.test | TestDoctor123! | Physiotherapy | [generated] |
| doctor.test3@androcare360.test | TestDoctor123! | Internal Medicine | [generated] |

### Patient Accounts

| Email | Password | Full Name | UID |
|-------|----------|-----------|-----|
| patient.test1@androcare360.test | TestPatient123! | Omar Ibrahim | [generated] |
| patient.test2@androcare360.test | TestPatient123! | Fatima Ahmed | [generated] |
| patient.test3@androcare360.test | TestPatient123! | Ali Hassan | [generated] |
| patient.test4@androcare360.test | TestPatient123! | Layla Mohamed | [generated] |
| patient.test5@androcare360.test | TestPatient123! | Youssef Ali | [generated] |

### Test Appointments

| ID | Doctor | Patient | Status | Scheduled |
|----|--------|---------|--------|-----------|
| apt_test_001 | doctor.test1 | patient.test1 | confirmed | +1 hour |
| apt_test_002 | doctor.test1 | patient.test2 | confirmed | +2 hours |
| apt_test_003 | doctor.test2 | patient.test3 | confirmed | +3 hours |
| apt_test_004 | doctor.test2 | patient.test4 | confirmed | +4 hours |
| apt_test_005 | doctor.test3 | patient.test5 | confirmed | +5 hours |
| apt_test_006 | doctor.test1 | patient.test3 | pending | +1 day |
| apt_test_007 | doctor.test2 | patient.test1 | scheduled | +1 day 2h |
| apt_test_008 | doctor.test3 | patient.test2 | confirmed | +6 hours |
| apt_test_009 | doctor.test1 | patient.test4 | confirmed | +7 hours |
| apt_test_010 | doctor.test2 | patient.test5 | confirmed | +8 hours |

---

## Troubleshooting

### Error: "Firebase not initialized"

**Solution:**
Ensure Firebase is properly configured in your project:
1. Check `firebase_options.dart` exists
2. Verify Firebase configuration files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### Error: "Cannot connect to emulator"

**Solution:**
1. Ensure Firebase Emulator Suite is running:
   ```bash
   firebase emulators:start
   ```
2. Check emulator ports are not in use:
   - Firestore: 8080
   - Auth: 9099
   - Emulator UI: 4000

### Error: "Email already in use"

**Solution:**
The script handles this automatically by skipping Auth creation and using the existing account. If you want to recreate accounts:

**Using Emulator:**
1. Stop emulator
2. Delete emulator data: `rm -rf .firebase/`
3. Restart emulator
4. Run script again

**Using Production/Dev:**
1. Manually delete accounts from Firebase Console
2. Run script again

### Error: "Permission denied"

**Solution:**
1. Check Firestore security rules allow writes
2. Verify you have appropriate Firebase project permissions
3. For production, ensure service account has necessary roles

### Error: "User not found" when creating appointments

**Solution:**
Ensure test accounts are created first:
```bash
dart scripts/create_test_accounts.dart --environment emulator
```

Then run appointment creation:
```bash
dart scripts/create_test_appointments.dart --environment emulator
```

### Verification Script Shows Failures

**Solution:**

1. **Check which checks failed:**
   - Review the output to see specific failures
   - Common issues: accounts not created, appointments missing, wrong database

2. **Re-run setup scripts:**
   ```bash
   # Recreate accounts
   dart scripts/create_test_accounts.dart --environment emulator
   
   # Recreate appointments
   dart scripts/create_test_appointments.dart --environment emulator
   
   # Verify again
   dart scripts/verify_test_environment.dart --environment emulator
   ```

3. **Check database configuration:**
   - Ensure `databaseId: 'elajtech'` is used
   - Verify Firebase project is correct

4. **Use detailed report for debugging:**
   ```bash
   dart scripts/verify_test_environment.dart --environment emulator --detailed
   ```

### Verification Script Shows Warnings

**Solution:**
Warnings are typically non-critical issues:

- **Missing FCM token:** Normal for test accounts, can be ignored
- **call_logs collection not accessible:** Will be created on first call, can be ignored

If all critical checks pass (✅), you can proceed with testing.

---

## Advanced Usage

### Running Against Production

⚠️ **Warning:** Only run against production if you understand the implications.

```bash
# Create accounts in production
dart scripts/create_test_accounts.dart --environment prod

# Create appointments in production
dart scripts/create_test_appointments.dart --environment prod
```

### Customizing Test Data

To customize test accounts or appointments, edit the scripts:

**For Accounts:** Edit `create_test_accounts.dart`
- Modify `createDoctorAccounts()` method
- Modify `createPatientAccounts()` method
- Change email addresses, names, specializations

**For Appointments:** Edit `create_test_appointments.dart`
- Modify `createAllAppointments()` method
- Change appointment IDs, statuses, scheduled times

### Cleaning Up Test Data

**Using Emulator:**
```bash
# Stop emulator
# Delete emulator data
rm -rf .firebase/
# Restart emulator
firebase emulators:start
```

**Using Production/Dev:**
Manually delete from Firebase Console or create a cleanup script.

---

## Script Architecture

### create_test_accounts.dart

```
TestAccountCreator
├── initialize()           # Connect to Firebase
├── createAccount()        # Create single account
├── createDoctorAccounts() # Create all doctors
├── createPatientAccounts()# Create all patients
├── verifyAccount()        # Verify account exists
└── generateSummary()      # Print summary report
```

### create_test_appointments.dart

```
TestAppointmentCreator
├── initialize()           # Connect to Firebase
├── getUserUidByEmail()    # Get user UID from email
├── createAppointment()    # Create single appointment
├── createAllAppointments()# Create all appointments
└── generateSummary()      # Print summary report
```

---

## Best Practices

1. **Always use emulator for testing scripts**
   - Safer than production
   - Faster iteration
   - No cost implications

2. **Run scripts in order**
   - First: create_test_accounts.dart
   - Second: create_test_appointments.dart

3. **Verify data after creation**
   - Check Firestore UI
   - Verify Auth users
   - Test login with credentials

4. **Document any customizations**
   - Keep track of changes to test data
   - Update this README if you add new scripts

5. **Use version control**
   - Commit scripts to repository
   - Track changes over time

---

## Future Enhancements

Potential scripts to add:

- [ ] `cleanup_test_data.dart` - Remove all test accounts and appointments
- [x] `verify_test_environment.dart` - Verify all test data is correctly set up ✅ **COMPLETED**
- [ ] `generate_test_report.dart` - Generate test data report
- [ ] `create_test_call_logs.dart` - Create sample call logs for testing
- [ ] `reset_test_environment.dart` - Complete environment reset

---

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review Firebase Console for errors
3. Check Firebase Emulator logs
4. Consult the development team

---

**Last Updated:** 2026-02-16  
**Maintained By:** AndroCare360 QA Team
