# VoIP Video Call System - Monitoring Setup Guide

**Project**: AndroCare360  
**Component**: Video Call System Testing  
**Version**: 1.0  
**Date**: 2026-02-16  
**Status**: In Progress

---

## Overview

This guide provides step-by-step instructions for setting up the monitoring and logging infrastructure required for comprehensive VoIP video call system testing. The monitoring infrastructure enables real-time tracking of call events, error detection, performance metrics collection, and evidence gathering.

---

## 1. Firebase Console Access Configuration

### 1.1 Access Firebase Console

**URL**: https://console.firebase.google.com/

**Steps**:
1. Navigate to Firebase Console
2. Sign in with authorized Google account
3. Select project: **elajtech-fc804**
4. Verify access to the following sections:
   - Firestore Database
   - Authentication
   - Cloud Functions
   - Cloud Messaging

### 1.2 Configure Firestore Database Access

**CRITICAL**: The project uses a custom database ID: `elajtech`

**Steps**:
1. In Firebase Console, navigate to **Firestore Database**
2. In the database dropdown (top of page), select: **elajtech**
3. Verify you can see the following collections:
   - `users`
   - `appointments`
   - `call_logs`
   - `emr_records`
   - `prescriptions`

**Important Notes**:
- Always ensure you're viewing the `elajtech` database, not the default database
- The database selector is at the top of the Firestore page
- If you don't see the `elajtech` option, contact the project administrator


### 1.3 Set Up Real-Time Call Logs Monitoring

**Purpose**: Monitor call events in real-time during test execution

**Steps**:

1. **Navigate to call_logs Collection**:
   - In Firestore Database, click on `call_logs` collection
   - This collection stores all call monitoring events

2. **Create Monitoring Query**:
   - Click "Start collection" if empty
   - Set up a filter to view recent logs:
     - Field: `timestamp`
     - Operator: `>=`
     - Value: [Today's date at 00:00]

3. **Enable Auto-Refresh**:
   - Firestore Console auto-refreshes, but you can manually refresh
   - Keep this tab open during testing for real-time monitoring

4. **Bookmark Important Queries**:
   - Create browser bookmarks for common queries:
     - All call_attempt events
     - All call_error events
     - All connection_failure events
     - Logs for specific appointment IDs

### 1.4 Create Monitoring Queries for call_logs Collection

**Query 1: Recent Call Attempts**
```
Collection: call_logs
Filter: eventType == "call_attempt"
Order by: timestamp (descending)
Limit: 50
```

**Query 2: Call Errors**
```
Collection: call_logs
Filter: eventType == "call_error"
Order by: timestamp (descending)
Limit: 50
```

**Query 3: Connection Failures**
```
Collection: call_logs
Filter: eventType == "connection_failure"
Order by: timestamp (descending)
Limit: 50
```

**Query 4: Logs for Specific Appointment**
```
Collection: call_logs
Filter: appointmentId == "apt_test_001"
Order by: timestamp (ascending)
```


### 1.5 Verify Test Data in Firestore

**Verify Test Accounts**:
1. Navigate to `users` collection
2. Search for test accounts:
   - doctor.test1@androcare360.test
   - doctor.test2@androcare360.test
   - doctor.test3@androcare360.test
   - patient.test1@androcare360.test
   - patient.test2@androcare360.test
   - patient.test3@androcare360.test
   - patient.test4@androcare360.test
   - patient.test5@androcare360.test
3. Verify each account has:
   - Valid `fcmToken` field (for patients)
   - Correct `userType` (doctor or patient)
   - Complete profile information

**Verify Test Appointments**:
1. Navigate to `appointments` collection
2. Search for test appointments:
   - apt_test_001 through apt_test_010
3. Verify each appointment has:
   - Valid `doctorId`
   - Valid `patientId`
   - Status: "confirmed" (for most tests)
   - Scheduled time in the future

**Create Missing Test Data**:
If any test data is missing, create it manually or use the test data creation script (if available).

---

## 2. Agora Analytics Dashboard Configuration

### 2.1 Access Agora Console

**URL**: https://console.agora.io/

**Steps**:
1. Navigate to Agora Console
2. Sign in with Agora account credentials
3. Select project: **AndroCare360**
4. Verify access to:
   - Project Overview
   - Analytics
   - Quality Insights
   - Usage Statistics

### 2.2 Set Up Quality Metrics Monitoring

**Purpose**: Monitor video and audio quality during test calls

**Steps**:

1. **Navigate to Analytics**:
   - In Agora Console, click "Analytics" in left sidebar
   - Select "Call Search" or "Quality Insights"

2. **Configure Time Range**:
   - Set time range to "Today" or "Last 24 hours"
   - This will show all test calls

3. **Enable Real-Time Monitoring**:
   - Keep Analytics page open during testing
   - Refresh periodically to see new call data


### 2.3 Configure Report Exports

**Purpose**: Export call quality data for analysis

**Steps**:

1. **Set Up Automatic Reports** (if available):
   - Navigate to "Reports" section
   - Configure daily or weekly reports
   - Set email delivery to QA team

2. **Manual Export Process**:
   - After each test session, export call data:
     - Go to "Call Search"
     - Filter by date range (test session dates)
     - Click "Export" button
     - Download CSV or JSON format
     - Save to evidence folder

3. **Key Metrics to Export**:
   - Call duration
   - Video resolution
   - Frame rate
   - Bitrate
   - Packet loss rate
   - Audio latency
   - Network quality score

### 2.4 Understand Agora Metrics

**Video Quality Metrics**:
- **Resolution**: Target 640x480 minimum
- **Frame Rate**: Target 15fps minimum
- **Bitrate**: Auto-adjusted based on network
- **Packet Loss**: Should be < 5%

**Audio Quality Metrics**:
- **Latency**: Target < 200ms
- **Packet Loss**: Should be < 3%
- **Jitter**: Should be < 30ms

**Connection Metrics**:
- **Join Time**: Time to join channel (target < 3 seconds)
- **First Frame Time**: Time to first video frame (target < 5 seconds)
- **Connection State**: Connected, Reconnecting, Failed

---

## 3. Device Log Collection Setup

### 3.1 Android Device Log Collection (logcat)

**Prerequisites**:
- Android device with USB debugging enabled
- ADB (Android Debug Bridge) installed on computer
- USB cable to connect device

**Setup Steps**:

1. **Enable Developer Options**:
   - On Android device, go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Developer Options now enabled

2. **Enable USB Debugging**:
   - Go to Settings > Developer Options
   - Enable "USB Debugging"
   - Connect device to computer via USB
   - Accept USB debugging prompt on device

3. **Verify ADB Connection**:
   ```bash
   adb devices
   ```
   - Should show your device listed

4. **Start Log Collection**:
   ```bash
   # Clear existing logs
   adb logcat -c
   
   # Start collecting logs (save to file)
   adb logcat > android_test_logs_[timestamp].txt
   ```

5. **Filter Logs for AndroCare360**:
   ```bash
   # Filter by package name
   adb logcat | grep "com.androcare360"
   
   # Filter by specific tags
   adb logcat | grep -E "AgoraService|VoIPCallService|FCMService"
   ```


### 3.2 iOS Device Log Collection (Console.app)

**Prerequisites**:
- iOS device
- macOS computer with Xcode installed
- Lightning/USB-C cable to connect device

**Setup Steps**:

1. **Connect iOS Device**:
   - Connect iOS device to Mac via cable
   - Trust the computer on iOS device if prompted

2. **Open Console.app**:
   - On Mac, open Console.app (Applications > Utilities > Console)
   - Or search for "Console" in Spotlight

3. **Select Device**:
   - In Console.app left sidebar, under "Devices"
   - Click on your iOS device name

4. **Filter Logs**:
   - In search bar, enter: `process:AndroCare360`
   - Or filter by subsystem: `subsystem:com.androcare360`

5. **Start Log Collection**:
   - Click "Start" button to begin streaming logs
   - Logs will appear in real-time

6. **Save Logs**:
   - File > Save
   - Choose location and filename
   - Format: Text or .logarchive

**Alternative: Xcode Console**:
1. Open Xcode
2. Window > Devices and Simulators
3. Select your device
4. Click "Open Console" button
5. Filter and save logs as needed

### 3.3 Create Log Filtering Scripts

**Android Log Filter Script** (`filter_android_logs.sh`):
```bash
#!/bin/bash
# Filter Android logs for VoIP testing

LOG_FILE=$1
OUTPUT_FILE="filtered_${LOG_FILE}"

# Filter for relevant tags
grep -E "AgoraService|VoIPCallService|FCMService|CallMonitoring|FirebaseFirestore" "$LOG_FILE" > "$OUTPUT_FILE"

echo "Filtered logs saved to: $OUTPUT_FILE"
```

**iOS Log Filter Script** (`filter_ios_logs.sh`):
```bash
#!/bin/bash
# Filter iOS logs for VoIP testing

LOG_FILE=$1
OUTPUT_FILE="filtered_${LOG_FILE}"

# Filter for AndroCare360 process
grep "AndroCare360" "$LOG_FILE" | grep -E "Agora|VoIP|FCM|CallMonitoring" > "$OUTPUT_FILE"

echo "Filtered logs saved to: $OUTPUT_FILE"
```

---

## 4. Monitoring Query Scripts

### 4.1 Firestore Query Scripts

**Script 1: Get Recent Call Logs** (`get_call_logs.js`):
```javascript
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();
db.settings({ databaseId: 'elajtech' });

async function getRecentCallLogs(limit = 50) {
  const snapshot = await db.collection('call_logs')
    .orderBy('timestamp', 'desc')
    .limit(limit)
    .get();
  
  snapshot.forEach(doc => {
    console.log(doc.id, '=>', doc.data());
  });
}

getRecentCallLogs();
```


**Script 2: Get Error Logs** (`get_error_logs.js`):
```javascript
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();
db.settings({ databaseId: 'elajtech' });

async function getErrorLogs(limit = 50) {
  const snapshot = await db.collection('call_logs')
    .where('eventType', '==', 'call_error')
    .orderBy('timestamp', 'desc')
    .limit(limit)
    .get();
  
  console.log(`Found ${snapshot.size} error logs:\n`);
  
  snapshot.forEach(doc => {
    const data = doc.data();
    console.log(`[${data.timestamp.toDate()}] ${data.errorCode}: ${data.errorMessage}`);
    console.log(`  Appointment: ${data.appointmentId}`);
    console.log(`  User: ${data.userId}`);
    console.log('---');
  });
}

getErrorLogs();
```

**Script 3: Get Logs for Specific Appointment** (`get_appointment_logs.js`):
```javascript
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();
db.settings({ databaseId: 'elajtech' });

async function getAppointmentLogs(appointmentId) {
  const snapshot = await db.collection('call_logs')
    .where('appointmentId', '==', appointmentId)
    .orderBy('timestamp', 'asc')
    .get();
  
  console.log(`Call logs for appointment ${appointmentId}:\n`);
  
  snapshot.forEach(doc => {
    const data = doc.data();
    console.log(`[${data.timestamp.toDate()}] ${data.eventType}`);
    if (data.errorMessage) {
      console.log(`  Error: ${data.errorMessage}`);
    }
  });
}

// Usage: node get_appointment_logs.js apt_test_001
const appointmentId = process.argv[2] || 'apt_test_001';
getAppointmentLogs(appointmentId);
```

### 4.2 Performance Metrics Aggregation Script

**Script: Aggregate Performance Metrics** (`aggregate_metrics.js`):
```javascript
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();
db.settings({ databaseId: 'elajtech' });

async function aggregateMetrics(startDate, endDate) {
  const snapshot = await db.collection('call_logs')
    .where('timestamp', '>=', startDate)
    .where('timestamp', '<=', endDate)
    .get();
  
  const metrics = {
    totalCalls: 0,
    successfulCalls: 0,
    failedCalls: 0,
    errors: {},
    avgSetupTime: 0,
  };
  
  snapshot.forEach(doc => {
    const data = doc.data();
    
    if (data.eventType === 'call_attempt') {
      metrics.totalCalls++;
    }
    
    if (data.eventType === 'call_started') {
      metrics.successfulCalls++;
    }
    
    if (data.eventType === 'call_error') {
      metrics.failedCalls++;
      const errorCode = data.errorCode || 'unknown';
      metrics.errors[errorCode] = (metrics.errors[errorCode] || 0) + 1;
    }
  });
  
  console.log('Performance Metrics:');
  console.log(`  Total Calls: ${metrics.totalCalls}`);
  console.log(`  Successful: ${metrics.successfulCalls}`);
  console.log(`  Failed: ${metrics.failedCalls}`);
  console.log(`  Success Rate: ${(metrics.successfulCalls / metrics.totalCalls * 100).toFixed(2)}%`);
  console.log('\nError Breakdown:');
  Object.entries(metrics.errors).forEach(([code, count]) => {
    console.log(`  ${code}: ${count}`);
  });
}

// Usage: node aggregate_metrics.js
const today = new Date();
today.setHours(0, 0, 0, 0);
const tomorrow = new Date(today);
tomorrow.setDate(tomorrow.getDate() + 1);

aggregateMetrics(today, tomorrow);
```

---

## 5. Evidence Collection Structure

### 5.1 Create Folder Structure

Create the following folder structure for organizing test evidence:

```
voip_test_evidence/
├── screenshots/
│   ├── android/
│   │   ├── scenario_1.1/
│   │   ├── scenario_1.2/
│   │   └── ...
│   └── ios/
│       ├── scenario_1.1/
│       ├── scenario_1.2/
│       └── ...
├── videos/
│   ├── android/
│   └── ios/
├── logs/
│   ├── android/
│   │   ├── device_logs/
│   │   └── filtered_logs/
│   ├── ios/
│   │   ├── device_logs/
│   │   └── filtered_logs/
│   └── firestore/
│       ├── call_logs/
│       └── error_logs/
├── metrics/
│   ├── agora_analytics/
│   ├── performance_metrics/
│   └── aggregated_data/
└── reports/
    ├── daily_reports/
    └── final_report/
```


### 5.2 File Naming Conventions

**Screenshots**:
- Format: `[platform]_[scenario_id]_[step_number]_[description]_[timestamp].png`
- Example: `android_1.1_step3_start_call_button_20260216_143022.png`
- Example: `ios_2.3_step9_incoming_call_ui_20260216_143045.png`

**Videos**:
- Format: `[platform]_[scenario_id]_[description]_[timestamp].mp4`
- Example: `android_1.1_successful_call_initiation_20260216_143000.mp4`
- Example: `ios_3.1_call_connection_20260216_144500.mp4`

**Device Logs**:
- Format: `[platform]_[device_name]_[scenario_id]_[timestamp].txt`
- Example: `android_samsung_s21_1.1_20260216_143000.txt`
- Example: `ios_iphone13_2.3_20260216_144000.txt`

**Firestore Logs**:
- Format: `firestore_[collection]_[query_type]_[timestamp].json`
- Example: `firestore_call_logs_errors_20260216_150000.json`
- Example: `firestore_call_logs_apt_test_001_20260216_150030.json`

### 5.3 Automated Backup Setup

**Create Backup Script** (`backup_evidence.sh`):
```bash
#!/bin/bash
# Backup test evidence to cloud storage

EVIDENCE_DIR="voip_test_evidence"
BACKUP_DIR="voip_test_evidence_backup_$(date +%Y%m%d_%H%M%S)"
CLOUD_STORAGE="gs://androcare360-test-evidence"  # Example: Google Cloud Storage

# Create backup
echo "Creating backup..."
cp -r "$EVIDENCE_DIR" "$BACKUP_DIR"

# Compress backup
echo "Compressing backup..."
tar -czf "${BACKUP_DIR}.tar.gz" "$BACKUP_DIR"

# Upload to cloud storage (optional)
# gsutil cp "${BACKUP_DIR}.tar.gz" "$CLOUD_STORAGE/"

echo "Backup complete: ${BACKUP_DIR}.tar.gz"
```

---

## 6. Monitoring Dashboard Setup (Optional)

### 6.1 Create Real-Time Monitoring Dashboard

For advanced monitoring, consider setting up a real-time dashboard using:

**Option 1: Firebase Extensions**
- Install Firebase Extensions for monitoring
- Configure real-time alerts

**Option 2: Custom Dashboard**
- Use Grafana or similar tool
- Connect to Firestore for real-time data
- Create visualizations for:
  - Call success rate
  - Error rate by type
  - Average call setup time
  - Active calls count

**Option 3: Google Sheets Integration**
- Export Firestore data to Google Sheets
- Create charts and graphs
- Share with team for real-time visibility

### 6.2 Set Up Alerts

**Firebase Alerts**:
1. Navigate to Firebase Console > Alerts
2. Create alert rules:
   - Alert when error rate > 10%
   - Alert when call setup time > 5 seconds
   - Alert when connection failure rate > 5%

**Email Notifications**:
- Configure email notifications for critical errors
- Set up distribution list for QA team

---

## 7. Verification Checklist

Before proceeding to test execution, verify the following:

### Firebase Console Access
- [ ] Can access Firebase Console
- [ ] Can view elajtech database
- [ ] Can query call_logs collection
- [ ] Can view users collection
- [ ] Can view appointments collection
- [ ] Monitoring queries bookmarked

### Agora Analytics Dashboard
- [ ] Can access Agora Console
- [ ] Can view AndroCare360 project
- [ ] Can access Analytics section
- [ ] Can view Quality Insights
- [ ] Know how to export reports

### Device Log Collection
- [ ] Android device connected via ADB
- [ ] Can collect Android logs via logcat
- [ ] iOS device connected to Mac
- [ ] Can collect iOS logs via Console.app
- [ ] Log filtering scripts created and tested

### Monitoring Scripts
- [ ] Firestore query scripts created
- [ ] Scripts tested and working
- [ ] Performance metrics script ready
- [ ] Error log extraction script ready

### Evidence Collection
- [ ] Folder structure created
- [ ] File naming conventions documented
- [ ] Backup script created
- [ ] Team knows where to save evidence

### Test Data
- [ ] All test accounts verified in Firestore
- [ ] All test appointments created
- [ ] FCM tokens present for all patients
- [ ] Appointment statuses correct

---

## 8. Troubleshooting

### Issue: Cannot Access elajtech Database

**Solution**:
1. Verify you're signed in with correct Google account
2. Check database selector at top of Firestore page
3. Contact project administrator for access if needed

### Issue: ADB Not Detecting Android Device

**Solution**:
1. Verify USB debugging enabled on device
2. Try different USB cable
3. Restart ADB server: `adb kill-server && adb start-server`
4. Check device drivers on Windows

### Issue: Cannot See iOS Logs in Console.app

**Solution**:
1. Verify device is trusted on Mac
2. Restart Console.app
3. Try disconnecting and reconnecting device
4. Check if device is in Developer Mode

### Issue: Firestore Query Scripts Not Working

**Solution**:
1. Verify Firebase Admin SDK initialized correctly
2. Check database ID is set to 'elajtech'
3. Verify service account has correct permissions
4. Check Node.js version compatibility

---

## 9. Next Steps

After completing this monitoring setup:

1. **Verify All Systems**: Run through verification checklist
2. **Conduct Dry Run**: Execute Scenario 1.1 as a test
3. **Brief Team**: Review monitoring tools with all testers
4. **Proceed to Task 5**: Begin executing test scenarios

---

**Document Version**: 1.0  
**Last Updated**: 2026-02-16  
**Status**: Complete  
**Next Task**: Task 5 - Execute Call Initiation Test Scenarios
