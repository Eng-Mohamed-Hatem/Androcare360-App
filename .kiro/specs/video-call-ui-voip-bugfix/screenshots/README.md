# Screenshots Directory

## Purpose

This directory contains screenshots captured during manual testing of the Video Call UI Text Fix.

## Directory Structure

```
screenshots/
├── doctor/                 # Doctor view screenshots
│   ├── waiting_main_message.png
│   ├── waiting_sub_message.png
│   ├── connection_status.png
│   └── connected_view.png
└── patient/                # Patient view screenshots
    ├── incoming_call_notification.png
    ├── waiting_main_message.png
    ├── waiting_sub_message.png
    ├── connection_status.png
    └── connected_view.png
```

## Screenshot Requirements

### Doctor View Screenshots

#### 1. waiting_main_message.png
**What to capture:**
- Full video call screen showing waiting room UI
- Main message: "جاري الاتصال بالمريض..." clearly visible
- Loading indicator visible
- Connection status in top-left corner

**When to capture:**
- Immediately after doctor initiates call
- Before patient joins the channel

**Validates:** Requirement 1.1

#### 2. waiting_sub_message.png
**What to capture:**
- Sub-message below main message
- Patient name clearly visible in the text
- Full text: "في انتظار رد [Patient Name]..."

**When to capture:**
- Same screen as waiting_main_message.png
- Can be same screenshot or zoomed-in version

**Validates:** Requirement 1.2

#### 3. connection_status.png
**What to capture:**
- Connection status indicator in top-left corner
- Status text (e.g., "جاري الاتصال..." or "متصل")
- Status color indicator

**When to capture:**
- During waiting phase or after connection

**Validates:** Connection state visibility

#### 4. connected_view.png
**What to capture:**
- Full screen after patient joins
- Remote video (patient's video) visible in full screen
- Local video preview in top-right corner
- Control buttons at bottom
- No waiting messages visible

**When to capture:**
- After patient successfully joins the channel

**Validates:** Successful video connection

---

### Patient View Screenshots

#### 1. incoming_call_notification.png
**What to capture:**
- Native incoming call UI (CallKit on iOS or ConnectionService on Android)
- Doctor's name displayed
- Accept and Decline buttons visible
- Call notification details

**When to capture:**
- When patient receives incoming call notification
- Before accepting the call

**Validates:** VoIP notification delivery (Phase 2 requirement)

#### 2. waiting_main_message.png
**What to capture:**
- Full video call screen showing waiting room UI
- Main message: "جاري الاتصال بالطبيب..." clearly visible
- Loading indicator visible
- Connection status in top-left corner

**When to capture:**
- Immediately after patient accepts call
- Before doctor's video appears

**Validates:** Requirement 1.3

#### 3. waiting_sub_message.png
**What to capture:**
- Sub-message below main message
- Full text: "يرجى الانتظار، سيتم الاتصال بك قريباً"

**When to capture:**
- Same screen as waiting_main_message.png
- Can be same screenshot or zoomed-in version

**Validates:** Requirement 1.4

#### 4. connection_status.png
**What to capture:**
- Connection status indicator in top-left corner
- Status text (e.g., "جاري الاتصال..." or "متصل")
- Status color indicator

**When to capture:**
- During waiting phase or after connection

**Validates:** Connection state visibility

#### 5. connected_view.png
**What to capture:**
- Full screen after doctor's video appears
- Remote video (doctor's video) visible in full screen
- Local video preview in top-right corner
- Control buttons at bottom
- No waiting messages visible

**When to capture:**
- After successfully connecting to doctor

**Validates:** Successful video connection

---

## Screenshot Guidelines

### Quality Requirements
- **Resolution:** High resolution (at least 1080p)
- **Format:** PNG (preferred) or JPEG
- **Clarity:** Text must be clearly readable
- **Framing:** Capture full screen, not cropped

### Naming Convention
- Use lowercase with underscores
- Be descriptive and consistent
- Follow the structure above

### File Size
- Keep individual files under 5MB
- Compress if necessary without losing quality

### Privacy
- Use test accounts only
- Blur or redact any sensitive information
- Do not include real patient/doctor data

## How to Capture Screenshots

### Android
1. Press **Power + Volume Down** simultaneously
2. Screenshot saved to Gallery/Screenshots
3. Transfer to computer via USB or cloud storage

### iOS
1. Press **Side Button + Volume Up** simultaneously (iPhone X and later)
2. Or **Home + Power** (iPhone 8 and earlier)
3. Screenshot saved to Photos app
4. Transfer to computer via AirDrop or iCloud

### Emulator
1. Use emulator's screenshot button
2. Or use IDE's screenshot feature
3. Save directly to project directory

## Organizing Screenshots

After capturing:

1. **Rename files** according to the structure above
2. **Place in correct directory** (doctor/ or patient/)
3. **Verify quality** - ensure text is readable
4. **Document in test results** - reference screenshots in `MANUAL_TEST_RESULTS_TEMPLATE.md`

## Screenshot Checklist

Use this checklist to ensure all required screenshots are captured:

### Doctor View
- [ ] `doctor/waiting_main_message.png`
- [ ] `doctor/waiting_sub_message.png`
- [ ] `doctor/connection_status.png`
- [ ] `doctor/connected_view.png`

### Patient View
- [ ] `patient/incoming_call_notification.png`
- [ ] `patient/waiting_main_message.png`
- [ ] `patient/waiting_sub_message.png`
- [ ] `patient/connection_status.png`
- [ ] `patient/connected_view.png`

## Troubleshooting

### Issue: Screenshot not saving
**Solution:** Check device storage space, verify permissions

### Issue: Screenshot quality poor
**Solution:** Use native screenshot method, avoid third-party apps

### Issue: Text not readable
**Solution:** Retake screenshot, ensure high resolution

### Issue: Wrong screen captured
**Solution:** Verify timing, retake at correct moment

## Additional Screenshots

If you encounter issues or edge cases, capture additional screenshots:

1. Create subdirectories: `doctor/issues/` or `patient/issues/`
2. Name descriptively: `issue_long_name_overflow.png`
3. Document in test results with reference to issue

## Review Checklist

Before submitting screenshots:

- [ ] All 9 required screenshots captured
- [ ] Files named correctly
- [ ] Placed in correct directories
- [ ] Quality verified (readable text)
- [ ] No sensitive information visible
- [ ] Referenced in test results document

---

**Note:** Screenshots are essential evidence for test validation. Ensure all required screenshots are captured before marking Task 3 as complete.
