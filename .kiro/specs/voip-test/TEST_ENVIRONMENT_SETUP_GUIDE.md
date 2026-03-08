# Test Environment Setup Guide
## VoIP Video Call System Testing - AndroCare360

**Version:** 1.0.0  
**Date:** 2026-02-16  
**Status:** Ready for Execution

---

## Overview

This guide provides step-by-step instructions for setting up the complete test environment for AndroCare360 video call system testing. Follow each section carefully to ensure all prerequisites are met before test execution.

---

## 1. Test Devices Setup

### 1.1 Required Devices

**Minimum Configuration:**
- **2 Android devices** (one for doctor role, one for patient role)
- **2 iOS devices** (one for doctor role, one for patient role)

**Recommended Configuration:**
- **4-6 Android devices** covering multiple OS versions
- **4-6 iOS devices** covering multiple OS versions

### 1.2 Android Devices

**Target OS Versions:**
- Android 10 (API 29)
- Android 11 (API 30)
- Android 12 (API 31)
- Android 13 (API 33)

**Recommended Device Models:**
- Samsung Galaxy S21/S22/S23
- Google Pixel 5/6/7
- Xiaomi Mi 11/12
- OnePlus 9/10

**Setup Steps:**

1. **Enable Developer Options:**
   ```
   Settings → About Phone → Tap "Build Number" 7 times
   ```

2. **Enable USB Debugging:**
   ```
   Settings → Developer Options → USB Debugging (ON)
   ```

3. **Install ADB (Android Debug Bridge):**
   ```bash
   # Windows (via Chocolatey)
   choco install adb
   
   # macOS (via Homebrew)
   brew install android-platform-tools
   
   # Linux (Ubuntu/Debian)
   sudo apt-get install android-tools-adb
   ```

4. **Verify Device Connection:**
   ```bash
   adb devices
   # Should show your device listed
   ```

5. **Install AndroCare360 App:**
   - Download latest APK from development team
   - Install via ADB:
     ```bash
     adb install path/to/androcare360.apk
     ```
   - Or install manually from device

6. **Grant Required Permissions:**
   ```
   Settings → Apps → AndroCare360 → Permissions
   - Camera: Allow
   - Microphone: Allow
   - Notifications: Allow
   - Phone: Allow (for ConnectionService)
   ```

7. **Configure Logcat Logging:**
   ```bash
   # Start logging to file
   adb logcat -c  # Clear existing logs
   adb logcat > android_test_logs.txt
   ```

### 1.3 iOS Devices

**Target OS Versions:**
- iOS 14.x
- iOS 15.x
- iOS 16.x
- iOS 17.x

**Recommended Device Models:**
- iPhone 11/12/13
- iPhone 13 Pro/14 Pro
- iPhone 15/15 Pro

**Setup Steps:**

1. **Enable Developer Mode (iOS 16+):**
   ```
   Settings → Privacy & Security → Developer Mode (ON)
   Restart device when prompted
   ```

2. **Install Xcode (macOS only):**
   - Download from Mac App Store
   - Install Command Line Tools:
     ```bash
     xcode-select --install
     ```

3. **Trust Development Certificate:**
   ```
   Settings → General → VPN & Device Management
   → Trust [Developer Certificate]
   ```

4. **Install AndroCare360 App:**
   - Install via TestFlight (recommended)
   - Or install via Xcode for development builds

5. **Grant Required Permissions:**
   ```
   Settings → AndroCare360
   - Camera: Allow
   - Microphone: Allow
   - Notifications: Allow
   ```

6. **Configure Console Logging:**
   - Open Console.app on macOS
   - Connect iPhone via USB
   - Select device from sidebar
   - Filter by "AndroCare360" process

### 1.4 Device Preparation Checklist

For each device, verify:

- [ ] Device is fully charged (100%)
- [ ] Latest AndroCare360 app installed
- [ ] All required permissions granted
- [ ] Developer options enabled (Android)
- [ ] USB debugging enabled (Android)
- [ ] Device connected to computer for logging
- [ ] Screen lock disabled or set to 30 minutes
- [ ] Do Not Disturb mode disabled
- [ ] Automatic updates disabled during testing
- [ ] Sufficient storage space (minimum 2GB free)

---

## 2. Network Environment Configuration

### 2.1 WiFi Network Setup

**Primary WiFi Network:**
- Network Name: `AndroCare_Test_WiFi`
- Speed: 50+ Mbps download, 10+ Mbps upload
- Frequency: 5GHz preferred (less interference)
- Security: WPA2/WPA3

**Setup Steps:**

1. **Connect All Test Devices:**
   - Connect all Android and iOS devices to the same WiFi network
   - Verify internet connectivity on each device

2. **Measure Network Speed:**
   - Use Speedtest app on each device
   - Document baseline speeds:
     ```
     Device: [Model]
     Download: [XX] Mbps
     Upload: [XX] Mbps
     Ping: [XX] ms
     ```

3. **Configure Router (if accessible):**
   - Disable QoS (Quality of Service) for consistent testing
   - Reserve IP addresses for test devices (optional)
   - Enable logging for network diagnostics

### 2.2 Mobile Data Configuration

**4G/LTE Setup:**

1. **Verify 4G/LTE Availability:**
   - Check signal strength on each device
   - Ensure 4G/LTE is enabled (not 3G only)

2. **Disable WiFi for Mobile Data Tests:**
   ```
   Settings → WiFi → OFF
   Settings → Mobile Data → ON
   Settings → Mobile Data → 4G/LTE (ON)
   ```

3. **Monitor Data Usage:**
   - Note starting data usage
   - Calculate data consumed during tests

**3G Network Setup:**

1. **Force 3G Connection (Android):**
   ```
   Settings → Mobile Networks → Preferred Network Type → 3G only
   ```

2. **Force 3G Connection (iOS):**
   ```
   Settings → Cellular → Cellular Data Options
   → Voice & Data → 3G
   ```

3. **Verify 3G Connection:**
   - Check status bar shows "3G" indicator
   - Test internet connectivity

### 2.3 Network Switching Scenarios

**WiFi to Mobile Data:**
- Prepare to disable WiFi during active call
- Document switching procedure for each device

**Mobile Data to WiFi:**
- Prepare to enable WiFi during active call
- Document switching procedure for each device

### 2.4 Network Monitoring Tools

**Install Network Monitoring Apps:**

**Android:**
- Network Monitor Mini (Play Store)
- NetMonster (for detailed network info)

**iOS:**
- Network Analyzer (App Store)
- Speedtest by Ookla

**Desktop Tools (Optional):**
- Wireshark (for packet analysis)
- Charles Proxy (for HTTP/HTTPS monitoring)

---

## 3. Test Accounts and Appointments

### 3.1 Firebase Console Access

**Prerequisites:**
- Firebase project access to `elajtech`
- Firestore database access to `elajtech` database
- Appropriate permissions (Editor or Owner role)

**Access Steps:**

1. **Login to Firebase Console:**
   - URL: https://console.firebase.google.com
   - Select project: `elajtech`

2. **Navigate to Firestore Database:**
   - Click "Firestore Database" in left sidebar
   - Verify database ID: `elajtech`

3. **Verify Collections:**
   - `users` - User profiles
   - `appointments` - Appointment records
   - `call_logs` - Call monitoring logs

### 3.2 Create Test Doctor Accounts

**Required: Minimum 3 doctor accounts**

**Doctor Account Template:**
```json
{
  "id": "doctor_test_001",
  "email": "doctor.test1@androcare360.test",
  "fullName": "Dr. Ahmed Test",
  "userType": "doctor",
  "specializations": ["internal_medicine"],
  "fcmToken": "[will be generated on login]",
  "createdAt": "[timestamp]",
  "isActive": true
}
```

**Creation Steps:**

1. **Via Firebase Console:**
   - Go to Authentication → Users
   - Click "Add User"
   - Email: `doctor.test1@androcare360.test`
   - Password: `TestDoctor123!` (use secure password)
   - Copy the generated UID

2. **Create Firestore Document:**
   - Go to Firestore Database
   - Collection: `users`
   - Document ID: [Use the UID from Authentication]
   - Add fields as per template above

3. **Repeat for Additional Doctors:**
   - `doctor.test2@androcare360.test`
   - `doctor.test3@androcare360.test`

**Test Doctor Credentials:**
```
Doctor 1:
  Email: doctor.test1@androcare360.test
  Password: TestDoctor123!
  ID: [document_id]

Doctor 2:
  Email: doctor.test2@androcare360.test
  Password: TestDoctor123!
  ID: [document_id]

Doctor 3:
  Email: doctor.test3@androcare360.test
  Password: TestDoctor123!
  ID: [document_id]
```

### 3.3 Create Test Patient Accounts

**Required: Minimum 5 patient accounts**

**Patient Account Template:**
```json
{
  "id": "patient_test_001",
  "email": "patient.test1@androcare360.test",
  "fullName": "Patient Test One",
  "userType": "patient",
  "fcmToken": "[will be generated on login]",
  "createdAt": "[timestamp]",
  "isActive": true
}
```

**Creation Steps:**

1. **Via Firebase Console:**
   - Go to Authentication → Users
   - Click "Add User"
   - Email: `patient.test1@androcare360.test`
   - Password: `TestPatient123!`
   - Copy the generated UID

2. **Create Firestore Document:**
   - Go to Firestore Database
   - Collection: `users`
   - Document ID: [Use the UID from Authentication]
   - Add fields as per template above

3. **Repeat for Additional Patients:**
   - `patient.test2@androcare360.test`
   - `patient.test3@androcare360.test`
   - `patient.test4@androcare360.test`
   - `patient.test5@androcare360.test`

**Test Patient Credentials:**
```
Patient 1:
  Email: patient.test1@androcare360.test
  Password: TestPatient123!
  ID: [document_id]

Patient 2:
  Email: patient.test2@androcare360.test
  Password: TestPatient123!
  ID: [document_id]

Patient 3:
  Email: patient.test3@androcare360.test
  Password: TestPatient123!
  ID: [document_id]

Patient 4:
  Email: patient.test4@androcare360.test
  Password: TestPatient123!
  ID: [document_id]

Patient 5:
  Email: patient.test5@androcare360.test
  Password: TestPatient123!
  ID: [document_id]
```

### 3.4 Create Test Appointments

**Required: Minimum 10 test appointments**

**Appointment Template:**
```json
{
  "id": "apt_test_001",
  "doctorId": "doctor_test_001",
  "patientId": "patient_test_001",
  "status": "confirmed",
  "scheduledAt": "[future_timestamp]",
  "createdAt": "[timestamp]",
  "appointmentType": "video_consultation",
  "duration": 30,
  "notes": "Test appointment for video call testing"
}
```

**Creation Steps:**

1. **Via Firestore Console:**
   - Collection: `appointments`
   - Click "Add Document"
   - Document ID: `apt_test_001`
   - Add fields as per template

2. **Create Multiple Appointments:**
   - Create 10 appointments with different doctor-patient combinations
   - Vary the status: `confirmed`, `pending`, `scheduled`
   - Use future timestamps for `scheduledAt`

**Test Appointment IDs:**
```
apt_test_001: Doctor 1 → Patient 1 (confirmed)
apt_test_002: Doctor 1 → Patient 2 (confirmed)
apt_test_003: Doctor 2 → Patient 3 (confirmed)
apt_test_004: Doctor 2 → Patient 4 (confirmed)
apt_test_005: Doctor 3 → Patient 5 (confirmed)
apt_test_006: Doctor 1 → Patient 3 (pending)
apt_test_007: Doctor 2 → Patient 1 (scheduled)
apt_test_008: Doctor 3 → Patient 2 (confirmed)
apt_test_009: Doctor 1 → Patient 4 (confirmed)
apt_test_010: Doctor 2 → Patient 5 (confirmed)
```

### 3.5 Verify Test Data

**Verification Checklist:**

- [ ] All doctor accounts created in Authentication
- [ ] All doctor profiles created in Firestore `users` collection
- [ ] All patient accounts created in Authentication
- [ ] All patient profiles created in Firestore `users` collection
- [ ] All test appointments created in `appointments` collection
- [ ] Doctor-patient relationships are valid
- [ ] All appointments have `confirmed` or `scheduled` status
- [ ] Test credentials documented and accessible

---

## 4. Monitoring Tools Installation

### 4.1 Firebase Console Setup

**Access Configuration:**

1. **Bookmark Firebase Console:**
   - URL: https://console.firebase.google.com/project/elajtech

2. **Firestore Database Access:**
   - Navigate to: Firestore Database
   - Verify database: `elajtech`
   - Bookmark: Firestore → Data → call_logs collection

3. **Create Firestore Query for Call Logs:**
   - Collection: `call_logs`
   - Order by: `timestamp` (descending)
   - Limit: 100
   - Save query for quick access

4. **Enable Real-Time Monitoring:**
   - Keep Firestore console open during testing
   - Refresh to see new call log entries
   - Filter by `appointmentId` or `userId` as needed

### 4.2 Agora Analytics Dashboard

**Prerequisites:**
- Agora account access
- AndroCare360 project credentials

**Setup Steps:**

1. **Login to Agora Console:**
   - URL: https://console.agora.io
   - Use AndroCare360 project credentials

2. **Navigate to Analytics:**
   - Select Project: AndroCare360
   - Click "Analytics" in left sidebar

3. **Configure Quality Metrics:**
   - Enable: Call Quality
   - Enable: Network Quality
   - Enable: Video Quality
   - Enable: Audio Quality

4. **Set Up Real-Time Monitoring:**
   - Go to: Real-Time Monitoring
   - Enable: Active Calls
   - Enable: Quality Indicators

5. **Configure Report Exports:**
   - Go to: Reports
   - Schedule: Daily reports
   - Format: CSV
   - Email: [your_email]

### 4.3 Device Log Collection Tools

**Android - Logcat Setup:**

1. **Install Android Studio (Optional but Recommended):**
   - Download from: https://developer.android.com/studio
   - Install Android SDK Platform Tools

2. **Configure Logcat Filtering:**
   ```bash
   # Filter by AndroCare360 app
   adb logcat | grep "com.androcare360"
   
   # Filter by specific tags
   adb logcat | grep -E "AgoraService|VoIPCallService|CallMonitoring"
   
   # Save to file with timestamp
   adb logcat -v time > "android_logs_$(date +%Y%m%d_%H%M%S).txt"
   ```

3. **Create Log Collection Script (Windows):**
   ```batch
   @echo off
   set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
   set TIMESTAMP=%TIMESTAMP: =0%
   adb logcat -v time > "android_logs_%TIMESTAMP%.txt"
   ```

4. **Create Log Collection Script (macOS/Linux):**
   ```bash
   #!/bin/bash
   TIMESTAMP=$(date +%Y%m%d_%H%M%S)
   adb logcat -v time > "android_logs_${TIMESTAMP}.txt"
   ```

**iOS - Console.app Setup:**

1. **Open Console.app (macOS):**
   - Applications → Utilities → Console

2. **Connect iOS Device:**
   - Connect via USB
   - Select device from sidebar

3. **Configure Filtering:**
   - Search: `AndroCare360`
   - Filter by: Process
   - Include: All Messages

4. **Save Logs:**
   - File → Save Selection
   - Format: Plain Text
   - Filename: `ios_logs_[timestamp].txt`

5. **Create Log Export Script:**
   ```bash
   #!/bin/bash
   # Export iOS logs using idevicesyslog (requires libimobiledevice)
   brew install libimobiledevice
   idevicesyslog > "ios_logs_$(date +%Y%m%d_%H%M%S).txt"
   ```

### 4.4 Screen Recording Tools

**Android Screen Recording:**

1. **Built-in Screen Recorder:**
   - Pull down notification shade
   - Tap "Screen Recorder"
   - Start recording

2. **ADB Screen Recording:**
   ```bash
   # Record screen (max 3 minutes)
   adb shell screenrecord /sdcard/test_recording.mp4
   
   # Pull recording to computer
   adb pull /sdcard/test_recording.mp4
   ```

3. **Third-Party Apps:**
   - AZ Screen Recorder (Play Store)
   - Mobizen Screen Recorder

**iOS Screen Recording:**

1. **Built-in Screen Recording:**
   - Settings → Control Center
   - Add "Screen Recording"
   - Swipe down from top-right → Tap record button

2. **QuickTime Screen Recording (macOS):**
   - Connect iPhone via USB
   - Open QuickTime Player
   - File → New Movie Recording
   - Select iPhone as camera source
   - Click record button

### 4.5 Network Monitoring Tools

**Wireshark Setup (Optional - Advanced):**

1. **Install Wireshark:**
   - Download from: https://www.wireshark.org
   - Install on testing computer

2. **Configure for Mobile Device Monitoring:**
   - Set up WiFi hotspot on computer
   - Connect test devices to hotspot
   - Capture traffic on hotspot interface

3. **Filter for Agora Traffic:**
   ```
   Filter: udp.port == 3478 || udp.port == 3479
   (Agora uses STUN/TURN protocols)
   ```

**Charles Proxy Setup (Optional):**

1. **Install Charles Proxy:**
   - Download from: https://www.charlesproxy.com
   - Install on testing computer

2. **Configure Mobile Devices:**
   - Install Charles SSL certificate on devices
   - Configure proxy settings to point to computer

3. **Monitor HTTPS Traffic:**
   - Enable SSL Proxying
   - Add Firebase and Agora domains to SSL Proxying list

### 4.6 Evidence Collection Structure

**Create Folder Structure:**

```
test_evidence/
├── screenshots/
│   ├── android/
│   │   ├── scenario_1_1/
│   │   ├── scenario_1_2/
│   │   └── ...
│   └── ios/
│       ├── scenario_1_1/
│       ├── scenario_1_2/
│       └── ...
├── videos/
│   ├── android/
│   └── ios/
├── logs/
│   ├── android/
│   │   ├── device_logs/
│   │   └── firestore_logs/
│   └── ios/
│       ├── device_logs/
│       └── firestore_logs/
├── metrics/
│   ├── performance/
│   ├── network/
│   └── agora_analytics/
└── reports/
    ├── daily/
    └── final/
```

**Create Folder Structure Script (Windows):**
```batch
@echo off
mkdir test_evidence
cd test_evidence
mkdir screenshots\android screenshots\ios
mkdir videos\android videos\ios
mkdir logs\android\device_logs logs\android\firestore_logs
mkdir logs\ios\device_logs logs\ios\firestore_logs
mkdir metrics\performance metrics\network metrics\agora_analytics
mkdir reports\daily reports\final
echo Folder structure created successfully!
```

**Create Folder Structure Script (macOS/Linux):**
```bash
#!/bin/bash
mkdir -p test_evidence/{screenshots,videos,logs,metrics,reports}/{android,ios}
mkdir -p test_evidence/logs/android/{device_logs,firestore_logs}
mkdir -p test_evidence/logs/ios/{device_logs,firestore_logs}
mkdir -p test_evidence/metrics/{performance,network,agora_analytics}
mkdir -p test_evidence/reports/{daily,final}
echo "Folder structure created successfully!"
```

---

## 5. Pre-Test Verification

### 5.1 Device Verification Checklist

**For Each Test Device:**

- [ ] Device fully charged (100%)
- [ ] AndroCare360 app installed and updated
- [ ] Test account logged in successfully
- [ ] All permissions granted
- [ ] Network connectivity verified (WiFi and mobile data)
- [ ] Screen recording capability tested
- [ ] Device logs accessible and collecting
- [ ] FCM token generated and stored in Firestore

### 5.2 Network Verification

- [ ] WiFi network speed tested (50+ Mbps)
- [ ] 4G/LTE connectivity verified on all devices
- [ ] 3G connectivity verified on all devices
- [ ] Network switching procedure documented
- [ ] Network monitoring tools configured

### 5.3 Account Verification

- [ ] All doctor accounts can login successfully
- [ ] All patient accounts can login successfully
- [ ] FCM tokens generated for all accounts
- [ ] Test appointments visible in app
- [ ] Doctor can see assigned appointments
- [ ] Patient can see their appointments

### 5.4 Monitoring Tools Verification

- [ ] Firebase Console accessible
- [ ] Firestore call_logs collection visible
- [ ] Agora Analytics Dashboard accessible
- [ ] Android device logs collecting
- [ ] iOS device logs collecting
- [ ] Screen recording working on all devices
- [ ] Evidence folder structure created

### 5.5 Test Execution Readiness

- [ ] All test scenarios documented
- [ ] Test data prepared (appointment IDs, credentials)
- [ ] Evidence collection procedures defined
- [ ] Defect reporting process established
- [ ] Test schedule created
- [ ] Team members assigned to roles (doctor/patient)

---

## 6. Quick Reference

### 6.1 Test Credentials Quick Access

**Doctor Accounts:**
```
doctor.test1@androcare360.test / TestDoctor123!
doctor.test2@androcare360.test / TestDoctor123!
doctor.test3@androcare360.test / TestDoctor123!
```

**Patient Accounts:**
```
patient.test1@androcare360.test / TestPatient123!
patient.test2@androcare360.test / TestPatient123!
patient.test3@androcare360.test / TestPatient123!
patient.test4@androcare360.test / TestPatient123!
patient.test5@androcare360.test / TestPatient123!
```

### 6.2 Important URLs

- **Firebase Console:** https://console.firebase.google.com/project/elajtech
- **Firestore Database:** https://console.firebase.google.com/project/elajtech/firestore
- **Agora Console:** https://console.agora.io
- **Firebase Authentication:** https://console.firebase.google.com/project/elajtech/authentication

### 6.3 Common Commands

**Android:**
```bash
# List connected devices
adb devices

# Install app
adb install androcare360.apk

# Start logcat
adb logcat > logs.txt

# Screen recording
adb shell screenrecord /sdcard/recording.mp4

# Pull file from device
adb pull /sdcard/recording.mp4
```

**iOS:**
```bash
# List connected devices (requires libimobiledevice)
idevice_id -l

# Export logs
idevicesyslog > logs.txt
```

### 6.4 Firestore Query Examples

**Query Call Logs by Appointment:**
```javascript
db.collection('call_logs')
  .where('appointmentId', '==', 'apt_test_001')
  .orderBy('timestamp', 'desc')
  .get()
```

**Query Error Logs:**
```javascript
db.collection('call_logs')
  .where('eventType', '==', 'call_error')
  .orderBy('timestamp', 'desc')
  .limit(50)
  .get()
```

---

## 7. Troubleshooting

### 7.1 Device Connection Issues

**Problem:** ADB not detecting Android device

**Solutions:**
1. Enable USB Debugging in Developer Options
2. Try different USB cable
3. Restart ADB server: `adb kill-server && adb start-server`
4. Install device-specific USB drivers (Windows)

**Problem:** iOS device not showing in Console.app

**Solutions:**
1. Trust computer on iOS device
2. Reconnect USB cable
3. Restart Console.app
4. Check USB cable is data-capable (not charge-only)

### 7.2 App Installation Issues

**Problem:** App won't install on Android

**Solutions:**
1. Enable "Install from Unknown Sources"
2. Uninstall previous version first
3. Check APK is compatible with device architecture
4. Verify sufficient storage space

**Problem:** App won't install on iOS

**Solutions:**
1. Trust developer certificate in Settings
2. Enable Developer Mode (iOS 16+)
3. Check provisioning profile is valid
4. Reinstall via TestFlight

### 7.3 Login Issues

**Problem:** Cannot login with test accounts

**Solutions:**
1. Verify account exists in Firebase Authentication
2. Check password is correct
3. Verify user document exists in Firestore
4. Check network connectivity
5. Clear app data and try again

### 7.4 FCM Token Issues

**Problem:** FCM token not generating

**Solutions:**
1. Verify Google Services configuration
2. Check notification permissions granted
3. Restart app
4. Check Firebase Cloud Messaging is enabled
5. Verify internet connectivity

---

## 8. Next Steps

After completing this setup:

1. **Verify All Checklist Items** - Ensure every item is checked
2. **Perform Smoke Test** - Test basic login and navigation
3. **Test One Complete Call Flow** - Verify end-to-end functionality
4. **Document Any Issues** - Note any setup problems encountered
5. **Proceed to Task 2** - Begin creating the comprehensive test plan document

---

## Appendix A: Device Specifications Template

Use this template to document each test device:

```
Device ID: [Unique identifier]
Platform: [Android/iOS]
Manufacturer: [Samsung/Apple/etc]
Model: [Galaxy S21/iPhone 13/etc]
OS Version: [Android 13/iOS 16.5/etc]
Screen Size: [6.2 inches]
Resolution: [1080x2400]
RAM: [8GB]
Storage: [128GB]
Network Capabilities: [WiFi 6, 5G, 4G LTE]
Test Role: [Doctor/Patient]
Test Account: [email]
Notes: [Any special considerations]
```

---

## Appendix B: Network Configuration Template

```
Network Type: [WiFi/4G/3G]
Network Name: [SSID]
Speed Test Results:
  - Download: [XX] Mbps
  - Upload: [XX] Mbps
  - Ping: [XX] ms
  - Jitter: [XX] ms
Signal Strength: [Excellent/Good/Fair/Poor]
Frequency: [2.4GHz/5GHz]
Test Date: [YYYY-MM-DD]
Test Time: [HH:MM]
Notes: [Any observations]
```

---

**Document Version:** 1.0.0  
**Last Updated:** 2026-02-16  
**Maintained By:** AndroCare360 QA Team
