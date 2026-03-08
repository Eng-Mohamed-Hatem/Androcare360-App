# Task 10: VoIP Notification in All App States - Screenshots

## Overview

This folder contains screenshots captured during Task 10 manual testing across different app states on both iOS and Android platforms.

**Task:** 10. Test VoIP notification in all app states  
**Requirements:** 2.5, 6.7

---

## Required Screenshots

### iOS Screenshots

#### 1. iOS - Foreground
**Filename:** `ios_foreground_incoming_call.png`

**What to capture:**
- iOS device screen with app in foreground
- CallKit incoming call screen displayed
- Doctor's name visible
- Accept and Decline buttons visible
- Timestamp visible (if possible)

**Purpose:** Verify CallKit appears when app is in foreground

---

#### 2. iOS - Background
**Filename:** `ios_background_incoming_call.png`

**What to capture:**
- iOS device screen with app in background
- CallKit incoming call screen displayed over home screen or lock screen
- Doctor's name visible
- Accept and Decline buttons visible
- Background apps or lock screen visible (to prove app is in background)

**Purpose:** Verify CallKit appears when app is in background

---

#### 3. iOS - Terminated
**Filename:** `ios_terminated_incoming_call.png`

**What to capture:**
- iOS device screen with app completely closed
- CallKit incoming call screen displayed
- Doctor's name visible
- Accept and Decline buttons visible
- Recent apps screen showing app was closed (optional second screenshot)

**Purpose:** Verify CallKit appears when app is terminated (cold start)

---

### Android Screenshots

#### 4. Android - Foreground
**Filename:** `android_foreground_incoming_call.png`

**What to capture:**
- Android device screen with app in foreground
- ConnectionService incoming call UI displayed
- Doctor's name visible
- Accept and Decline buttons visible
- Timestamp visible (if possible)

**Purpose:** Verify ConnectionService appears when app is in foreground

---

#### 5. Android - Background
**Filename:** `android_background_incoming_call.png`

**What to capture:**
- Android device screen with app in background
- ConnectionService incoming call UI displayed over home screen or lock screen
- Doctor's name visible
- Accept and Decline buttons visible
- Background apps or lock screen visible (to prove app is in background)

**Purpose:** Verify ConnectionService appears when app is in background

---

#### 6. Android - Terminated
**Filename:** `android_terminated_incoming_call.png`

**What to capture:**
- Android device screen with app completely closed
- ConnectionService incoming call UI displayed
- Doctor's name visible
- Accept and Decline buttons visible
- Recent apps screen showing app was closed (optional second screenshot)

**Purpose:** Verify ConnectionService appears when app is terminated (cold start)

---

## Optional Screenshots (for documentation)

### 7. iOS - Recent Apps (Before Termination)
**Filename:** `ios_recent_apps_before_termination.png`

**What to capture:**
- iOS recent apps screen showing the app
- Before swiping away to close

**Purpose:** Document that app was running before termination test

---

### 8. iOS - Recent Apps (After Termination)
**Filename:** `ios_recent_apps_after_termination.png`

**What to capture:**
- iOS recent apps screen without the app
- After swiping away to close

**Purpose:** Document that app was completely closed

---

### 9. Android - Recent Apps (Before Termination)
**Filename:** `android_recent_apps_before_termination.png`

**What to capture:**
- Android recent apps screen showing the app
- Before swiping away to close

**Purpose:** Document that app was running before termination test

---

### 10. Android - Recent Apps (After Termination)
**Filename:** `android_recent_apps_after_termination.png`

**What to capture:**
- Android recent apps screen without the app
- After swiping away to close

**Purpose:** Document that app was completely closed

---

### 11. iOS - Lock Screen
**Filename:** `ios_lock_screen_incoming_call.png`

**What to capture:**
- iOS lock screen with CallKit incoming call
- Device locked, screen lit up
- CallKit UI displayed over lock screen

**Purpose:** Document lock screen behavior on iOS

---

### 12. Android - Lock Screen
**Filename:** `android_lock_screen_incoming_call.png`

**What to capture:**
- Android lock screen with ConnectionService incoming call
- Device locked, screen lit up
- ConnectionService UI displayed over lock screen

**Purpose:** Document lock screen behavior on Android

---

## Screenshot Organization

```
screenshots/task10/
├── README.md (this file)
├── ios_foreground_incoming_call.png
├── ios_background_incoming_call.png
├── ios_terminated_incoming_call.png
├── android_foreground_incoming_call.png
├── android_background_incoming_call.png
├── android_terminated_incoming_call.png
├── ios_recent_apps_before_termination.png (optional)
├── ios_recent_apps_after_termination.png (optional)
├── android_recent_apps_before_termination.png (optional)
├── android_recent_apps_after_termination.png (optional)
├── ios_lock_screen_incoming_call.png (optional)
└── android_lock_screen_incoming_call.png (optional)
```

---

## How to Capture Screenshots

### iOS Device:
- **Method 1:** Press Volume Up + Side Button simultaneously
- **Method 2:** Use AssistiveTouch → Device → More → Screenshot
- **Method 3:** Use Xcode → Devices and Simulators → Take Screenshot

### Android Device:
- **Method 1:** Press Volume Down + Power Button simultaneously
- **Method 2:** Use device's built-in screenshot tool (varies by manufacturer)
- **Method 3:** Use Android Studio → Logcat → Screenshot button

### Tips:
1. Ensure good lighting to avoid glare
2. Hold device steady for clear screenshots
3. Capture full screen (don't crop)
4. Take multiple shots if first attempt is blurry
5. Verify screenshot is clear before proceeding

---

## Screenshot Quality Guidelines

1. **Resolution:** Use device's native resolution (no scaling)
2. **Clarity:** Ensure all text is readable
3. **Focus:** Show entire screen, including status bar
4. **Lighting:** Avoid glare or reflections
5. **Orientation:** Portrait mode for mobile devices
6. **Timing:** Capture immediately when incoming call appears
7. **Annotations:** Add arrows or highlights if needed (optional)

---

## Verification Checklist

After capturing all screenshots, verify:

### Required Screenshots:
- [ ] `ios_foreground_incoming_call.png` captured
- [ ] `ios_background_incoming_call.png` captured
- [ ] `ios_terminated_incoming_call.png` captured
- [ ] `android_foreground_incoming_call.png` captured
- [ ] `android_background_incoming_call.png` captured
- [ ] `android_terminated_incoming_call.png` captured

### Quality Check:
- [ ] All screenshots are clear and readable
- [ ] Doctor's name is visible in all screenshots
- [ ] Accept/Decline buttons are visible in all screenshots
- [ ] File names match the naming convention
- [ ] Screenshots are saved in this folder

### Optional Screenshots (if captured):
- [ ] Recent apps screenshots (before/after termination)
- [ ] Lock screen screenshots
- [ ] Any additional documentation screenshots

---

## Platform Comparison

After capturing all screenshots, you can create a side-by-side comparison:

### Foreground Comparison
| iOS | Android |
|-----|---------|
| ![iOS Foreground](ios_foreground_incoming_call.png) | ![Android Foreground](android_foreground_incoming_call.png) |

### Background Comparison
| iOS | Android |
|-----|---------|
| ![iOS Background](ios_background_incoming_call.png) | ![Android Background](android_background_incoming_call.png) |

### Terminated Comparison
| iOS | Android |
|-----|---------|
| ![iOS Terminated](ios_terminated_incoming_call.png) | ![Android Terminated](android_terminated_incoming_call.png) |

---

## Usage

These screenshots will be used for:

1. **Documentation:** Evidence that Task 10 was completed successfully
2. **Platform Comparison:** Visual comparison of iOS vs Android behavior
3. **Troubleshooting:** Reference for debugging platform-specific issues
4. **Training:** Examples for new team members
5. **QA:** Verification that VoIP works in all app states
6. **User Support:** Reference for helping users with notification issues

---

## Notes

- Screenshots should be taken during actual testing, not staged
- Ensure no sensitive information (real patient data) is visible
- Use test accounts and test appointments only
- If real data is accidentally captured, redact before committing
- Document any unusual behavior or issues in the platform differences document

---

## Device Information

When submitting screenshots, also document:

**iOS Device:**
- Device Model: _____________
- iOS Version: _____________
- App Version: _____________
- Test Date: _____________

**Android Device:**
- Device Model: _____________
- Manufacturer: _____________
- Android Version: _____________
- App Version: _____________
- Test Date: _____________

---

**Last Updated:** 2026-02-17  
**Task:** 10. Test VoIP notification in all app states  
**Status:** Awaiting screenshots from manual testing
