# Production Deployment Guide - Task 21.1

**Feature:** Video Call UI and VoIP Notification Critical Bugfixes  
**Deployment Date:** [TO BE FILLED]  
**Deployed By:** [TO BE FILLED]  
**Version:** [TO BE FILLED]

---

## Pre-Deployment Checklist

### ✅ Prerequisites Verification

Before starting deployment, verify ALL of the following:

- [ ] **All tests passing**: Run `flutter test` - must show 664+ tests passing
- [ ] **No analyzer warnings**: Run `flutter analyze` - must show "No issues found"
- [ ] **No deprecated APIs**: Run `flutter analyze lib/ | grep deprecated_member_use` - must show no output
- [ ] **Rollback plan ready**: Task 21 completed with documented rollback procedures
- [ ] **Staging tested**: All scenarios tested successfully in staging environment
- [ ] **QA approval**: Task 20 completed with QA sign-off
- [ ] **Production credentials**: Firebase, App Store, Google Play access verified
- [ ] **Code signing**: iOS and Android certificates valid and accessible
- [ ] **Monitoring setup**: Dashboards and alerts configured
- [ ] **On-call engineer**: Notified and available for 24-hour monitoring period
- [ ] **Communication**: Stakeholders notified of deployment schedule

### ✅ Code Verification

```bash
# 1. Verify you're on the correct branch
git branch --show-current
# Should show: main or release branch

# 2. Verify latest code
git pull origin main

# 3. Run full test suite
flutter test
# Expected: All tests passing (664+/664+)

# 4. Run static analysis
flutter analyze
# Expected: No issues found

# 5. Check for deprecated APIs
flutter analyze lib/ | grep deprecated_member_use
# Expected: No output (zero warnings)

# 6. Verify build succeeds
flutter build apk --release
flutter build ios --release
# Expected: Both builds succeed without errors
```

---

## Part 1: Deploy Cloud Functions

### Step 1: Verify Cloud Functions Tests

```bash
cd functions

# Install dependencies
npm install

# Run all tests
npm test

# Expected output:
# - 48 unit tests passing
# - 400 property-based test iterations
# - Database configuration tests passing
# - Database isolation tests passing
```

### Step 2: Verify Firebase Project

```bash
# Check current Firebase project
firebase use

# Expected output: elajtech (production)

# If not on elajtech project:
firebase use elajtech

# Verify project configuration
firebase projects:list
```

### Step 3: Review Changes to Deploy

```bash
# Review functions code
git diff HEAD~1 functions/index.js

# Key changes to verify:
# - Database configuration: db.settings({ databaseId: 'elajtech' })
# - Error logging with database context
# - Environment variable support for Agora credentials
```

### Step 4: Deploy Cloud Functions

```bash
# Deploy functions to production
firebase deploy --only functions --project elajtech

# Expected output:
# ✔ functions[startAgoraCall(europe-west1)] Successful update operation.
# ✔ functions[endAgoraCall(europe-west1)] Successful update operation.
# ✔ functions[completeAppointment(europe-west1)] Successful update operation.

# Deployment typically takes 2-5 minutes
```

### Step 5: Verify Cloud Functions Deployment

```bash
# List deployed functions
firebase functions:list --project elajtech

# Expected output:
# startAgoraCall(europe-west1)
# endAgoraCall(europe-west1)
# completeAppointment(europe-west1)

# Test function invocation (use staging appointment ID)
firebase functions:shell --project elajtech
# In shell:
# startAgoraCall({appointmentId: 'test_apt_123', doctorId: 'test_doctor_456'})
```

### Step 6: Monitor Initial Function Logs

```bash
# Watch logs in real-time
firebase functions:log --project elajtech

# Look for:
# - ✅ Functions deployed successfully
# - ✅ Database configuration applied: [DB: elajtech]
# - ❌ No errors in initialization
```

---

## Part 2: Deploy Flutter App

### Android Deployment (Google Play)

#### Step 1: Prepare Android Build

```bash
# Navigate to project root
cd /path/to/androcare360

# Clean previous builds
flutter clean
flutter pub get

# Update version in pubspec.yaml
# Increment version number (e.g., 1.0.0+1 -> 1.0.1+2)
# Format: version: <major>.<minor>.<patch>+<build_number>
```

#### Step 2: Build Android Release

```bash
# Build release APK
flutter build apk --release

# Or build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Expected output:
# ✓ Built build/app/outputs/bundle/release/app-release.aab
# File size: ~XX MB
```

#### Step 3: Test Release Build

```bash
# Install on test device
flutter install --release

# Verify:
# - App launches successfully
# - No crashes on startup
# - Video call functionality works
# - VoIP notifications received
```

#### Step 4: Upload to Google Play Console

**Manual Steps:**

1. Go to [Google Play Console](https://play.google.com/console)
2. Select AndroCare360 app
3. Navigate to **Production** > **Create new release**
4. Upload `build/app/outputs/bundle/release/app-release.aab`
5. Fill in release notes:
   ```
   Bug Fixes:
   - Fixed UI text issue where doctors saw incorrect waiting messages
   - Fixed VoIP notification delivery to patient devices
   - Improved error logging with database context
   - Enhanced Agora credential configuration
   
   Improvements:
   - Better error handling for video call initiation
   - More detailed logging for debugging
   ```
6. Set rollout percentage: **Start with 10%** (staged rollout)
7. Review and publish

#### Step 5: Monitor Google Play Release

- Check crash reports in Play Console
- Monitor user reviews
- Watch for increased crash rate
- Be ready to halt rollout if issues detected

### iOS Deployment (App Store)

#### Step 1: Prepare iOS Build

```bash
# Navigate to project root
cd /path/to/androcare360

# Clean previous builds
flutter clean
flutter pub get

# Update version in pubspec.yaml (same as Android)
# Increment version number (e.g., 1.0.0+1 -> 1.0.1+2)
```

#### Step 2: Build iOS Release

```bash
# Build iOS release
flutter build ios --release

# Expected output:
# ✓ Built build/ios/iphoneos/Runner.app
```

#### Step 3: Archive and Upload via Xcode

**Manual Steps:**

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Product** > **Archive**
3. Wait for archive to complete (5-10 minutes)
4. In Organizer window, select the archive
5. Click **Distribute App**
6. Select **App Store Connect**
7. Upload to App Store Connect
8. Wait for processing (15-30 minutes)

#### Step 4: Submit for Review

**Manual Steps:**

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select AndroCare360 app
3. Navigate to **App Store** tab
4. Click **+ Version** to create new version
5. Fill in version information:
   - Version: 1.0.1 (match pubspec.yaml)
   - What's New:
     ```
     Bug Fixes:
     - Fixed UI text issue where doctors saw incorrect waiting messages
     - Fixed VoIP notification delivery to patient devices
     - Improved error logging and debugging capabilities
     
     Improvements:
     - Enhanced video call reliability
     - Better error handling
     ```
6. Select the uploaded build
7. Submit for review
8. Expected review time: 24-48 hours

#### Step 5: Release Strategy

- **Phased Release**: Enable phased release (7-day rollout)
- **Monitor**: Watch for crashes and user feedback
- **Rollback**: Be ready to halt release if issues detected

---

## Part 3: Post-Deployment Monitoring (24 Hours)

### Hour 0-1: Immediate Verification

#### Verify Cloud Functions

```bash
# Monitor function logs
firebase functions:log --project elajtech --only startAgoraCall

# Look for:
# - ✅ Successful call initiations
# - ✅ Database context in logs: [DB: elajtech]
# - ✅ VoIP notifications sent successfully
# - ❌ No "Appointment Not Found" errors
```

#### Verify VoIP Notifications

```bash
# Query call_logs for VoIP notification events
# Use Firebase Console or run query:

# In Firebase Console:
# 1. Go to Firestore
# 2. Select database: elajtech
# 3. Navigate to call_logs collection
# 4. Filter: eventType == 'voip_notification_sent'
# 5. Sort by timestamp (descending)
# 6. Verify recent notifications
```

#### Test End-to-End Flow

**Manual Test:**

1. Sign in as doctor on test device
2. Initiate video call to patient
3. Verify patient receives VoIP notification
4. Patient accepts call
5. Verify video call connects
6. Verify UI text is correct for both doctor and patient
7. End call successfully

### Hour 1-6: Active Monitoring

#### Monitor Key Metrics

**VoIP Notification Success Rate:**

```javascript
// Firebase Console > Firestore > Run query
// Collection: call_logs
// Filter: timestamp >= [deployment_time]

// Calculate success rate:
// success_rate = voip_notification_sent / (voip_notification_sent + voip_notification_failed)
// Target: > 95%
```

**Call Initiation Success Rate:**

```javascript
// Firebase Console > Firestore > Run query
// Collection: call_logs
// Filter: timestamp >= [deployment_time]

// Calculate success rate:
// success_rate = call_started / call_attempt
// Target: > 90%
```

**Patient Join Rate:**

```javascript
// Firebase Console > Firestore > Run query
// Collection: appointments
// Filter: callStartedAt >= [deployment_time]

// Calculate join rate:
// join_rate = (appointments with callEndedAt) / (appointments with callStartedAt)
// Target: > 90% within 60 seconds
```

#### Monitor Error Logs

```bash
# Watch for errors in Cloud Functions
firebase functions:log --project elajtech | grep "❌"

# Watch for errors in call_logs
# Firebase Console > Firestore > call_logs
# Filter: eventType == 'call_error'
# Sort by timestamp (descending)
```

#### Monitor App Crashes

**Google Play Console:**
- Navigate to **Quality** > **Android vitals** > **Crashes & ANRs**
- Check crash-free users rate (target: > 99.5%)
- Investigate any new crash clusters

**App Store Connect:**
- Navigate to **TestFlight** > **Crashes**
- Check crash rate (target: < 0.5%)
- Investigate any new crash types

### Hour 6-24: Continuous Monitoring

#### Set Up Alerts

**Firebase Alerts:**

```bash
# Set up Cloud Functions error rate alert
# Firebase Console > Functions > Metrics
# Create alert: Error rate > 5% for 5 minutes

# Set up Firestore alert
# Firebase Console > Firestore > Usage
# Create alert: Read/Write errors > 1% for 5 minutes
```

**App Monitoring:**

- Enable Firebase Crashlytics alerts
- Set up email notifications for crash rate > 1%
- Monitor user reviews on Play Store and App Store

#### Periodic Checks

**Every 2 Hours:**

- [ ] Check VoIP notification success rate
- [ ] Check call initiation success rate
- [ ] Check patient join rate
- [ ] Review error logs
- [ ] Check app crash rates
- [ ] Review user feedback

**Every 6 Hours:**

- [ ] Run end-to-end test manually
- [ ] Verify all metrics within target ranges
- [ ] Document any issues or anomalies
- [ ] Update stakeholders on deployment status

### Metrics Dashboard

Create a monitoring dashboard with these queries:

**Query 1: VoIP Notification Success Rate (Last 24 Hours)**

```javascript
// Firestore query
const now = new Date();
const yesterday = new Date(now.getTime() - 24 * 60 * 60 * 1000);

const sentCount = await db
  .collection('call_logs')
  .where('eventType', '==', 'voip_notification_sent')
  .where('timestamp', '>=', yesterday)
  .count()
  .get();

const failedCount = await db
  .collection('call_logs')
  .where('eventType', '==', 'call_error')
  .where('errorCode', 'in', ['fcm_token_missing', 'voip_notification_failed'])
  .where('timestamp', '>=', yesterday)
  .count()
  .get();

const successRate = (sentCount / (sentCount + failedCount)) * 100;
console.log(`VoIP Notification Success Rate: ${successRate.toFixed(2)}%`);
// Target: > 95%
```

**Query 2: Call Initiation Success Rate (Last 24 Hours)**

```javascript
// Firestore query
const attemptCount = await db
  .collection('call_logs')
  .where('eventType', '==', 'call_attempt')
  .where('timestamp', '>=', yesterday)
  .count()
  .get();

const startedCount = await db
  .collection('call_logs')
  .where('eventType', '==', 'call_started')
  .where('timestamp', '>=', yesterday)
  .count()
  .get();

const successRate = (startedCount / attemptCount) * 100;
console.log(`Call Initiation Success Rate: ${successRate.toFixed(2)}%`);
// Target: > 90%
```

**Query 3: FCM Token Coverage**

```javascript
// Firestore query
const totalUsers = await db
  .collection('users')
  .where('userType', '==', 'patient')
  .count()
  .get();

const usersWithToken = await db
  .collection('users')
  .where('userType', '==', 'patient')
  .where('fcmToken', '!=', null)
  .count()
  .get();

const coverage = (usersWithToken / totalUsers) * 100;
console.log(`FCM Token Coverage: ${coverage.toFixed(2)}%`);
// Target: > 98%
```

---

## Part 4: Rollback Procedures

### When to Rollback

Initiate rollback if ANY of the following occur:

- VoIP notification success rate < 90%
- Call initiation success rate < 85%
- App crash rate > 2%
- Critical bugs reported by users
- Database errors > 5% of operations
- Any data loss or corruption

### Cloud Functions Rollback

```bash
# Step 1: Get previous version hash (from Task 21)
git log --oneline functions/index.js
# Identify the commit hash before the bugfix changes

# Step 2: Checkout previous version
git checkout <previous-commit-hash> functions/index.js

# Step 3: Deploy previous version
firebase deploy --only functions --project elajtech

# Step 4: Verify rollback
firebase functions:log --project elajtech

# Step 5: Monitor for 30 minutes
# Ensure previous functionality restored
```

### Flutter App Rollback

**Google Play:**

1. Go to Google Play Console
2. Navigate to **Production** > **Releases**
3. Find the problematic release
4. Click **Halt rollout**
5. Previous version automatically becomes active
6. Monitor for 1 hour to confirm stability

**App Store:**

1. Go to App Store Connect
2. Navigate to **App Store** > **Versions**
3. Click **Remove from Sale** on problematic version
4. Submit previous version for expedited review
5. Contact Apple Developer Support for emergency rollback
6. Expected rollback time: 2-4 hours

### Post-Rollback Actions

1. **Notify stakeholders** of rollback
2. **Document the issue** that triggered rollback
3. **Investigate root cause** in staging environment
4. **Fix the issue** and re-test thoroughly
5. **Plan re-deployment** after fix verified

---

## Part 5: Success Criteria

### Deployment Successful If:

- [ ] **Cloud Functions deployed** without errors
- [ ] **Flutter app deployed** to both platforms
- [ ] **VoIP notification success rate** > 95%
- [ ] **Call initiation success rate** > 90%
- [ ] **Patient join rate** > 90% within 60 seconds
- [ ] **App crash rate** < 0.5%
- [ ] **No critical bugs** reported
- [ ] **All 664+ tests** still passing
- [ ] **No rollback** required during 24-hour period
- [ ] **User feedback** positive or neutral

### Metrics Targets (24-Hour Period)

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| VoIP Notification Success Rate | > 95% | [TO BE FILLED] | ⏳ |
| Call Initiation Success Rate | > 90% | [TO BE FILLED] | ⏳ |
| Patient Join Rate (< 60s) | > 90% | [TO BE FILLED] | ⏳ |
| FCM Token Coverage | > 98% | [TO BE FILLED] | ⏳ |
| App Crash Rate (Android) | < 0.5% | [TO BE FILLED] | ⏳ |
| App Crash Rate (iOS) | < 0.5% | [TO BE FILLED] | ⏳ |
| Database Error Rate | < 1% | [TO BE FILLED] | ⏳ |

---

## Part 6: Communication Plan

### Pre-Deployment Communication

**To: Development Team**
```
Subject: Production Deployment - Video Call Bugfixes

Deployment scheduled for: [DATE] at [TIME]
Expected duration: 2-3 hours
Monitoring period: 24 hours

Changes:
- Fixed UI text issue for doctor/patient roles
- Fixed VoIP notification delivery
- Enhanced error logging

Rollback plan: Ready (see Task 21)
On-call engineer: [NAME]
```

**To: QA Team**
```
Subject: Production Deployment - Please Monitor

We're deploying video call bugfixes to production.
Please monitor user reports and test the following:
- Doctor initiates call → correct UI text
- Patient receives VoIP notification
- Video call connects successfully

Report any issues immediately to: [CONTACT]
```

**To: Support Team**
```
Subject: Production Deployment - User-Facing Changes

We're deploying fixes for video call issues.

What's Fixed:
- Doctors now see "Calling patient..." (was showing "Calling doctor...")
- Patients receive incoming call notifications more reliably

What to Watch For:
- User reports of video call issues
- Notification delivery problems

Escalation: Contact [ON-CALL ENGINEER] immediately
```

### Post-Deployment Communication

**After 1 Hour:**
```
Subject: Deployment Update - 1 Hour

Status: ✅ Stable
Metrics:
- VoIP notifications: [X]% success rate
- Call initiations: [X]% success rate
- No critical errors detected

Continuing monitoring...
```

**After 24 Hours:**
```
Subject: Deployment Complete - 24 Hour Report

Status: ✅ Successful / ⚠️ Issues Detected / ❌ Rolled Back

Final Metrics:
- VoIP Notification Success Rate: [X]%
- Call Initiation Success Rate: [X]%
- Patient Join Rate: [X]%
- App Crash Rate: [X]%

Summary:
[Brief summary of deployment outcome]

Next Steps:
[Any follow-up actions needed]
```

---

## Part 7: Troubleshooting

### Issue: Cloud Functions Deployment Fails

**Symptoms:**
```
Error: Failed to deploy functions
```

**Solutions:**

1. Check Firebase project:
   ```bash
   firebase use
   # Ensure: elajtech
   ```

2. Check Node.js version:
   ```bash
   node --version
   # Required: v18 or later
   ```

3. Check function syntax:
   ```bash
   cd functions
   npm run lint
   ```

4. Check Firebase CLI version:
   ```bash
   firebase --version
   # Update if needed: npm install -g firebase-tools
   ```

### Issue: Flutter Build Fails

**Symptoms:**
```
Error: Build failed with exception
```

**Solutions:**

1. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

2. Check for deprecated APIs:
   ```bash
   flutter analyze lib/ | grep deprecated_member_use
   ```

3. Verify dependencies:
   ```bash
   flutter pub outdated
   ```

### Issue: VoIP Notifications Not Received

**Symptoms:**
- Patients not receiving incoming call notifications

**Investigation:**

1. Check FCM token exists:
   ```javascript
   // Firebase Console > Firestore > users collection
   // Find patient document
   // Verify fcmToken field is not null
   ```

2. Check Cloud Functions logs:
   ```bash
   firebase functions:log --project elajtech | grep "voip_notification"
   ```

3. Check call_logs for errors:
   ```javascript
   // Firebase Console > Firestore > call_logs
   // Filter: errorCode == 'fcm_token_missing' OR 'voip_notification_failed'
   ```

4. Verify database configuration:
   ```bash
   # Check functions logs for database context
   firebase functions:log --project elajtech | grep "\[DB: elajtech\]"
   ```

### Issue: High Error Rate

**Symptoms:**
- Error rate > 5% in Cloud Functions

**Investigation:**

1. Check error types:
   ```bash
   firebase functions:log --project elajtech | grep "❌"
   ```

2. Query call_logs for patterns:
   ```javascript
   // Firebase Console > Firestore > call_logs
   // Filter: eventType == 'call_error'
   // Group by errorCode
   ```

3. Check for database issues:
   ```bash
   # Verify database ID in logs
   firebase functions:log --project elajtech | grep "databaseId"
   ```

---

## Deployment Checklist Summary

### Pre-Deployment
- [ ] All tests passing (664+)
- [ ] No analyzer warnings
- [ ] No deprecated APIs
- [ ] Rollback plan ready
- [ ] Staging tested and approved
- [ ] Production credentials verified
- [ ] Monitoring setup complete
- [ ] Stakeholders notified

### Cloud Functions Deployment
- [ ] Functions tests passing
- [ ] Firebase project verified (elajtech)
- [ ] Changes reviewed
- [ ] Functions deployed successfully
- [ ] Deployment verified
- [ ] Initial logs checked

### Flutter App Deployment
- [ ] Version incremented
- [ ] Android build successful
- [ ] Android uploaded to Play Store
- [ ] iOS build successful
- [ ] iOS uploaded to App Store
- [ ] Release notes added
- [ ] Staged rollout configured

### Post-Deployment Monitoring
- [ ] Hour 0-1: Immediate verification complete
- [ ] Hour 1-6: Active monitoring in progress
- [ ] Hour 6-24: Continuous monitoring active
- [ ] Metrics dashboard created
- [ ] Alerts configured
- [ ] Periodic checks scheduled

### 24-Hour Completion
- [ ] All metrics within target ranges
- [ ] No critical issues detected
- [ ] No rollback required
- [ ] Stakeholders notified of success
- [ ] Documentation updated

---

## Notes

- **Deployment Window**: Schedule during low-traffic hours (e.g., 2-4 AM local time)
- **Team Availability**: Ensure on-call engineer available for full 24-hour period
- **Rollback Time**: Cloud Functions: 5 minutes, Android: 30 minutes, iOS: 2-4 hours
- **Communication**: Keep all stakeholders informed throughout deployment
- **Documentation**: Update CHANGELOG.md after successful deployment

---

**Prepared By:** Kiro AI Assistant  
**Date:** 2026-02-19  
**Version:** 1.0  
**Reference:** `.kiro/specs/video-call-ui-voip-bugfix/tasks.md` - Task 21.1
