# Task 18: Deprecated API Migration - Implementation Plan (Updated)

## Overview

This document provides a detailed implementation plan for Task 18 of the code-quality-and-testing-improvement spec, focusing on migrating deprecated Flutter APIs to their current alternatives.

**⚠️ CRITICAL UPDATE:** This plan has been updated based on Flutter 3.27+ breaking changes, particularly the RadioGroup API redesign.

## Context

**Current Status:**
- Phase A (Critical Fixes): ✅ Complete
- Phase B (Testing Infrastructure): ✅ Complete  
- Phase C (Documentation): ✅ Complete
- Phase D (Performance & Polish): 🔄 In Progress

**Task 18 Position:** Part of Phase D - Performance & Polish (Week 6, Day 1)

**Dependencies:**
- All previous phases completed
- Test infrastructure in place (627+ tests passing)
- Documentation standards established

## Objectives

1. **Eliminate all deprecated API warnings** from the codebase
2. **Maintain visual consistency** - ensure no UI changes after migration
3. **Verify functionality** - all tests must continue passing
4. **Document changes** - record any behavior differences
5. **Establish prevention mechanisms** - pre-commit hooks and CI/CD checks

## Requirements Mapping

| Subtask | Requirements | Description |
|---------|-------------|-------------|
| 18.0 | N/A | Pre-migration analysis and setup |
| 18.1 | 10.1, 10.2 | Replace `withOpacity()` with `withValues(alpha:)` |
| 18.2 | 10.3 | Update Radio widget to RadioGroup pattern |
| 18.3 | 10.4, 10.5 | Verify zero deprecated warnings |
| 18.4 | N/A | Setup prevention mechanisms (hooks, CI/CD) |

---

## Executive Summary

### Critical Changes from v1.0

**Version 2.0 Updates (2026-02-16):**

1. **Added Subtask 18.0:** Pre-migration analysis, backups, and ColorExtensions setup
2. **Complete Rewrite of Subtask 18.2:** RadioGroup migration (Flutter 3.27+ breaking change)
3. **Added Subtask 18.4:** Prevention mechanisms (pre-commit hooks, CI/CD, golden tests)
4. **Extended Timeline:** 4-6 hours → 6-8 hours (due to RadioGroup complexity)
5. **Added ColorExtensions:** Backward-compatible extension methods
6. **Added Golden Tests:** Visual regression testing setup
7. **Added Automation:** Pre-commit hooks and GitHub Actions workflows
8. **Enhanced Documentation:** Comprehensive migration guides and reports


### What Changed

**Subtask 18.0 (NEW):**
- Pre-migration analysis with `flutter analyze` baseline
- Comprehensive backup strategy
- ColorExtensions utility for backward compatibility
- Environment setup and verification

**Subtask 18.1 (ENHANCED):**
- Added ColorExtensions for gradual migration
- Enhanced testing with visual regression checks
- Added rollback procedures

**Subtask 18.2 (COMPLETE REWRITE):**
- **BREAKING CHANGE**: RadioGroup API redesign in Flutter 3.27+
- Multiple migration patterns for different Radio usage scenarios
- Comprehensive testing strategy for each pattern
- Visual regression testing with golden files

**Subtask 18.3 (ENHANCED):**
- Added verification of ColorExtensions usage
- Enhanced reporting with before/after metrics
- Added migration completion checklist

**Subtask 18.4 (NEW):**
- Pre-commit hooks for deprecated API detection
- GitHub Actions workflow for CI/CD enforcement
- Golden test setup for visual regression
- Automated rollback script

---

## Subtask 18.0: Pre-Migration Analysis & Setup

**Duration:** 30 minutes  
**Priority:** CRITICAL - Must complete before any code changes

### Objectives

1. Establish baseline metrics for deprecated API usage
2. Create comprehensive backups
3. Setup ColorExtensions utility for backward compatibility
4. Verify development environment

### Steps

#### Step 1: Baseline Analysis (10 minutes)

Run comprehensive analysis to document current state:

```bash
# Run analyzer and save output
flutter analyze > analysis_baseline.txt 2>&1

# Count deprecated warnings
grep -c "deprecated_member_use" analysis_baseline.txt

# List all deprecated API locations
grep "deprecated_member_use" analysis_baseline.txt > deprecated_locations.txt
```

**Expected Output:**
```
analysis_baseline.txt:
- Total warnings: ~50
- deprecated_member_use warnings: 6
  - 4x Color.withOpacity() in agora_video_call_screen.dart
  - 2x Radio widget usage (location TBD)
```



#### Step 2: Create Backups (5 minutes)

Create comprehensive backups before making any changes:

```bash
# Create backup directory with timestamp
BACKUP_DIR="backups/task18_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup files to be modified
cp lib/features/video_call/presentation/screens/agora_video_call_screen.dart "$BACKUP_DIR/"
cp -r lib/features/ "$BACKUP_DIR/features_backup/"

# Backup test files
cp -r test/ "$BACKUP_DIR/test_backup/"

# Create backup manifest
echo "Backup created: $(date)" > "$BACKUP_DIR/MANIFEST.txt"
echo "Files backed up:" >> "$BACKUP_DIR/MANIFEST.txt"
find "$BACKUP_DIR" -type f >> "$BACKUP_DIR/MANIFEST.txt"
```

**Verification:**
- Backup directory created with timestamp
- All target files backed up
- MANIFEST.txt contains file list

#### Step 3: Create ColorExtensions Utility (10 minutes)

Create backward-compatible extension methods for gradual migration:

```dart
// lib/core/extensions/color_extensions.dart

import 'package:flutter/material.dart';

/// Extension methods for Color to support both old and new opacity APIs.
///
/// This extension provides backward-compatible methods for migrating from
/// the deprecated `withOpacity()` to the new `withValues(alpha:)` API.
///
/// **Migration Strategy:**
/// 1. Use `withAlpha()` extension method during migration
/// 2. Gradually replace with direct `withValues(alpha:)` calls
/// 3. Remove extension after full migration
///
/// **Example:**
/// ```dart
/// // Old (deprecated)
/// final color = Colors.blue.withOpacity(0.7);
///
/// // Transition (using extension)
/// final color = Colors.blue.withAlpha(0.7);
///
/// // New (direct API)
/// final color = Colors.blue.withValues(alpha: 0.7);
/// ```
extension ColorExtensions on Color {
  /// Creates a copy of this color with the specified alpha value.
  ///
  /// This is a backward-compatible wrapper around `withValues(alpha:)`.
  ///
  /// Parameters:
  /// - [alpha]: Alpha value between 0.0 (transparent) and 1.0 (opaque)
  ///
  /// Returns a new Color with the specified alpha value.
  Color withAlpha(double alpha) {
    assert(alpha >= 0.0 && alpha <= 1.0, 'Alpha must be between 0.0 and 1.0');
    return withValues(alpha: alpha);
  }
}
```



**Create Test for ColorExtensions:**

```dart
// test/unit/core/extensions/color_extensions_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elajtech/core/extensions/color_extensions.dart';

void main() {
  group('ColorExtensions', () {
    test('withAlpha should create color with correct alpha value', () {
      // Arrange
      const baseColor = Colors.blue;
      const alphaValue = 0.7;
      
      // Act
      final result = baseColor.withAlpha(alphaValue);
      
      // Assert
      expect(result.alpha, closeTo(0.7 * 255, 1.0));
      expect(result.red, baseColor.red);
      expect(result.green, baseColor.green);
      expect(result.blue, baseColor.blue);
    });
    
    test('withAlpha should handle edge cases', () {
      const baseColor = Colors.red;
      
      // Test fully transparent
      final transparent = baseColor.withAlpha(0.0);
      expect(transparent.alpha, 0);
      
      // Test fully opaque
      final opaque = baseColor.withAlpha(1.0);
      expect(opaque.alpha, 255);
    });
    
    test('withAlpha should assert on invalid alpha values', () {
      const baseColor = Colors.green;
      
      // Test negative alpha
      expect(() => baseColor.withAlpha(-0.1), throwsAssertionError);
      
      // Test alpha > 1.0
      expect(() => baseColor.withAlpha(1.1), throwsAssertionError);
    });
  });
}
```

**Run Test:**
```bash
flutter test test/unit/core/extensions/color_extensions_test.dart
```

**Expected:** All 3 tests pass ✅

#### Step 4: Environment Verification (5 minutes)

Verify Flutter version and dependencies:

```bash
# Check Flutter version
flutter --version
# Expected: Flutter 3.27.0 or later

# Check for deprecated API warnings
flutter analyze | grep deprecated_member_use

# Verify test infrastructure
flutter test --version

# Check git status
git status
# Expected: Clean working directory (all changes committed)
```



### Deliverables

- ✅ `analysis_baseline.txt` - Baseline analyzer output
- ✅ `deprecated_locations.txt` - List of all deprecated API usage
- ✅ `backups/task18_YYYYMMDD_HHMMSS/` - Comprehensive backup directory
- ✅ `lib/core/extensions/color_extensions.dart` - ColorExtensions utility
- ✅ `test/unit/core/extensions/color_extensions_test.dart` - Extension tests
- ✅ Environment verified (Flutter 3.27+, clean git status)

### Success Criteria

- [ ] Baseline analysis complete with documented metrics
- [ ] All target files backed up with manifest
- [ ] ColorExtensions created and tested (3/3 tests passing)
- [ ] Flutter version ≥ 3.27.0
- [ ] Git working directory clean

---

## Subtask 18.1: Replace withOpacity with withValues

**Duration:** 45 minutes  
**Priority:** HIGH  
**Requirements:** 10.1, 10.2

### Objectives

1. Replace all 4 instances of `Color.withOpacity()` with `Color.withValues(alpha:)`
2. Verify visual appearance unchanged
3. Ensure all tests pass

### Context

**File:** `lib/features/video_call/presentation/screens/agora_video_call_screen.dart`

**Deprecated API:**
```dart
Colors.black.withOpacity(0.5)  // ❌ Deprecated in Flutter 3.27+
```

**Current API:**
```dart
Colors.black.withValues(alpha: 0.5)  // ✅ Current API
```

### Migration Steps

#### Step 1: Locate All Instances (5 minutes)

```bash
# Find all withOpacity usage in target file
grep -n "withOpacity" lib/features/video_call/presentation/screens/agora_video_call_screen.dart

# Expected output (4 instances):
# Line 123: Colors.black.withOpacity(0.5)
# Line 187: Colors.white.withOpacity(0.8)
# Line 245: Colors.red.withOpacity(0.7)
# Line 312: Colors.grey.withOpacity(0.6)
```



#### Step 2: Replace Instances (15 minutes)

**Migration Pattern:**

```dart
// BEFORE (Deprecated)
final overlayColor = Colors.black.withOpacity(0.5);

// AFTER (Current API)
final overlayColor = Colors.black.withValues(alpha: 0.5);
```

**Apply to all 4 instances:**

1. **Line ~123** - Video overlay background:
```dart
// Before
Container(
  color: Colors.black.withOpacity(0.5),
  child: ...,
)

// After
Container(
  color: Colors.black.withValues(alpha: 0.5),
  child: ...,
)
```

2. **Line ~187** - Control button background:
```dart
// Before
decoration: BoxDecoration(
  color: Colors.white.withOpacity(0.8),
  borderRadius: BorderRadius.circular(8),
)

// After
decoration: BoxDecoration(
  color: Colors.white.withValues(alpha: 0.8),
  borderRadius: BorderRadius.circular(8),
)
```

3. **Line ~245** - Error indicator:
```dart
// Before
Icon(Icons.error, color: Colors.red.withOpacity(0.7))

// After
Icon(Icons.error, color: Colors.red.withValues(alpha: 0.7))
```

4. **Line ~312** - Loading indicator background:
```dart
// Before
CircularProgressIndicator(
  backgroundColor: Colors.grey.withOpacity(0.6),
)

// After
CircularProgressIndicator(
  backgroundColor: Colors.grey.withValues(alpha: 0.6),
)
```

**Add inline comments:**
```dart
// Migrated from withOpacity() to withValues(alpha:) - Flutter 3.27+ API
final overlayColor = Colors.black.withValues(alpha: 0.5);
```



#### Step 3: Verify No Remaining Instances (5 minutes)

```bash
# Search for any remaining withOpacity usage
grep -r "withOpacity" lib/features/video_call/

# Expected: No matches (or only in comments)

# Run analyzer to verify deprecated warnings reduced
flutter analyze | grep deprecated_member_use | wc -l
# Expected: 2 (down from 6 - only Radio warnings remain)
```

#### Step 4: Visual Verification (10 minutes)

**Manual Testing:**

1. Run the app:
```bash
flutter run
```

2. Navigate to video call screen
3. Verify visual appearance:
   - [ ] Video overlay background opacity correct (50% black)
   - [ ] Control buttons background opacity correct (80% white)
   - [ ] Error indicator opacity correct (70% red)
   - [ ] Loading indicator background opacity correct (60% grey)

4. Take screenshots for comparison:
```bash
# Before migration (from backup)
# After migration (current)
```

**Automated Visual Testing (Optional):**

```dart
// test/widget/screens/agora_video_call_screen_golden_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  testGoldens('AgoraVideoCallScreen color opacity migration', (tester) async {
    await tester.pumpWidgetBuilder(
      const AgoraVideoCallScreen(),
      surfaceSize: const Size(375, 667),
    );
    
    await screenMatchesGolden(tester, 'agora_video_call_screen_after_migration');
  });
}
```



#### Step 5: Run Tests (10 minutes)

```bash
# Run all tests to ensure no regressions
flutter test

# Expected: All 627+ tests pass ✅

# Run specific video call tests
flutter test test/widget/screens/agora_video_call_screen_test.dart

# Run with coverage
flutter test --coverage
# Expected: Coverage maintained at 70%+
```

### Rollback Procedure

If visual appearance is incorrect or tests fail:

```bash
# Restore from backup
BACKUP_DIR="backups/task18_YYYYMMDD_HHMMSS"
cp "$BACKUP_DIR/agora_video_call_screen.dart" lib/features/video_call/presentation/screens/

# Verify restoration
git diff lib/features/video_call/presentation/screens/agora_video_call_screen.dart

# Run tests to confirm rollback
flutter test
```

### Deliverables

- ✅ All 4 `withOpacity()` instances replaced with `withValues(alpha:)`
- ✅ Inline comments added explaining migration
- ✅ Visual appearance verified (manual or golden tests)
- ✅ All tests passing (627+)
- ✅ Deprecated warnings reduced from 6 to 2

### Success Criteria

- [ ] Zero `withOpacity()` usage in `agora_video_call_screen.dart`
- [ ] Visual appearance unchanged (screenshots match)
- [ ] All tests pass (0 failures)
- [ ] Analyzer shows 2 deprecated warnings (Radio only)

---

## Subtask 18.2: Update Radio Widget to RadioGroup Pattern

**Duration:** 2.5 hours  
**Priority:** CRITICAL - BREAKING CHANGE  
**Requirements:** 10.3

### ⚠️ CRITICAL: Breaking Change Alert

**Flutter 3.27+ introduces a BREAKING CHANGE to the Radio widget API:**

- **Old API (Deprecated):** Individual `Radio<T>` widgets with `groupValue` and `onChanged`
- **New API (Required):** `RadioGroup<T>` wrapper with children `Radio<T>` widgets

This is NOT a simple find-replace operation. It requires structural changes to the widget tree.



### Objectives

1. Locate all Radio widget usage in the codebase
2. Identify migration patterns for each usage scenario
3. Migrate to RadioGroup API
4. Verify functionality unchanged
5. Ensure all tests pass

### Context

**Deprecated Pattern:**
```dart
Radio<String>(
  value: 'option1',
  groupValue: selectedValue,
  onChanged: (value) => setState(() => selectedValue = value),
)
```

**New Pattern:**
```dart
RadioGroup<String>(
  groupValue: selectedValue,
  onChanged: (value) => setState(() => selectedValue = value),
  children: [
    Radio<String>(value: 'option1'),
    Radio<String>(value: 'option2'),
  ],
)
```

### Migration Steps

#### Step 1: Locate All Radio Usage (15 minutes)

```bash
# Find all Radio widget usage
grep -rn "Radio<" lib/ --include="*.dart" > radio_usage.txt

# Find RadioListTile usage (also affected)
grep -rn "RadioListTile<" lib/ --include="*.dart" >> radio_usage.txt

# Review results
cat radio_usage.txt
```

**Expected Locations:**
- EMR forms (nutrition, physiotherapy, internal medicine)
- Settings screens
- Questionnaire widgets
- Filter/sort dialogs

**Document findings:**
```
radio_usage.txt:
lib/features/emr/nutrition/presentation/widgets/nutrition_form.dart:123: Radio<String>(
lib/features/emr/nutrition/presentation/widgets/nutrition_form.dart:145: Radio<String>(
lib/features/emr/physiotherapy/presentation/widgets/assessment_form.dart:89: Radio<bool>(
lib/features/settings/presentation/screens/preferences_screen.dart:234: RadioListTile<String>(
... (continue for all instances)
```



#### Step 2: Identify Migration Patterns (20 minutes)

Analyze each Radio usage and categorize by pattern:

**Pattern A: Simple Radio Group (Most Common)**

Multiple Radio widgets with shared state:

```dart
// BEFORE (Deprecated)
Column(
  children: [
    Radio<String>(
      value: 'male',
      groupValue: gender,
      onChanged: (value) => setState(() => gender = value),
    ),
    Radio<String>(
      value: 'female',
      groupValue: gender,
      onChanged: (value) => setState(() => gender = value),
    ),
  ],
)

// AFTER (RadioGroup API)
RadioGroup<String>(
  groupValue: gender,
  onChanged: (value) => setState(() => gender = value),
  children: [
    Radio<String>(value: 'male'),
    Radio<String>(value: 'female'),
  ],
)
```

**Pattern B: Radio with Labels (Common in Forms)**

Radio widgets with adjacent Text labels:

```dart
// BEFORE (Deprecated)
Row(
  children: [
    Radio<String>(
      value: 'yes',
      groupValue: answer,
      onChanged: (value) => setState(() => answer = value),
    ),
    const Text('Yes'),
  ],
)

// AFTER (RadioGroup with custom children)
RadioGroup<String>(
  groupValue: answer,
  onChanged: (value) => setState(() => answer = value),
  children: [
    Row(
      children: [
        Radio<String>(value: 'yes'),
        const Text('Yes'),
      ],
    ),
    Row(
      children: [
        Radio<String>(value: 'no'),
        const Text('No'),
      ],
    ),
  ],
)
```



**Pattern C: RadioListTile (Material Design)**

RadioListTile widgets need special handling:

```dart
// BEFORE (Deprecated)
RadioListTile<String>(
  title: const Text('Option 1'),
  value: 'option1',
  groupValue: selectedOption,
  onChanged: (value) => setState(() => selectedOption = value),
)

// AFTER (RadioGroup with RadioListTile children)
RadioGroup<String>(
  groupValue: selectedOption,
  onChanged: (value) => setState(() => selectedOption = value),
  children: [
    RadioListTile<String>(
      title: const Text('Option 1'),
      value: 'option1',
    ),
    RadioListTile<String>(
      title: const Text('Option 2'),
      value: 'option2',
    ),
  ],
)
```

**Pattern D: Conditional Radio (Dynamic Lists)**

Radio widgets generated from lists:

```dart
// BEFORE (Deprecated)
Column(
  children: options.map((option) => Radio<String>(
    value: option,
    groupValue: selectedOption,
    onChanged: (value) => setState(() => selectedOption = value),
  )).toList(),
)

// AFTER (RadioGroup with mapped children)
RadioGroup<String>(
  groupValue: selectedOption,
  onChanged: (value) => setState(() => selectedOption = value),
  children: options.map((option) => Radio<String>(
    value: option,
  )).toList(),
)
```

**Pattern E: Riverpod State Management**

Radio with Riverpod state:

```dart
// BEFORE (Deprecated)
final selectedValue = ref.watch(selectionProvider);

Radio<String>(
  value: 'option1',
  groupValue: selectedValue,
  onChanged: (value) => ref.read(selectionProvider.notifier).update(value),
)

// AFTER (RadioGroup with Riverpod)
final selectedValue = ref.watch(selectionProvider);

RadioGroup<String>(
  groupValue: selectedValue,
  onChanged: (value) => ref.read(selectionProvider.notifier).update(value),
  children: [
    Radio<String>(value: 'option1'),
    Radio<String>(value: 'option2'),
  ],
)
```



#### Step 3: Create Migration Checklist (10 minutes)

For each file with Radio usage, create a checklist:

```markdown
## Radio Migration Checklist

### File: lib/features/emr/nutrition/presentation/widgets/nutrition_form.dart

- [ ] Line 123-145: Gender selection (Pattern A - Simple Radio Group)
  - Current: 2 Radio<String> widgets
  - Target: RadioGroup<String> with 2 children
  - State: gender (local state)
  
- [ ] Line 234-267: Meal frequency (Pattern B - Radio with Labels)
  - Current: 4 Radio<int> with Text labels
  - Target: RadioGroup<int> with Row children
  - State: mealFrequency (local state)

### File: lib/features/emr/physiotherapy/presentation/widgets/assessment_form.dart

- [ ] Line 89-112: Pain assessment (Pattern C - RadioListTile)
  - Current: 5 RadioListTile<int> widgets
  - Target: RadioGroup<int> with RadioListTile children
  - State: painLevel (Riverpod provider)

... (continue for all files)
```

#### Step 4: Migrate Each File (90 minutes)

**Priority Order:**
1. Simple forms with Pattern A (30 min)
2. Forms with Pattern B and C (30 min)
3. Dynamic lists with Pattern D (20 min)
4. Riverpod integration with Pattern E (10 min)

**For Each File:**

1. **Backup the file:**
```bash
cp lib/path/to/file.dart backups/task18_YYYYMMDD_HHMMSS/
```

2. **Apply migration pattern:**
   - Identify all Radio widgets in the file
   - Group related Radio widgets
   - Wrap with RadioGroup
   - Move `groupValue` and `onChanged` to RadioGroup
   - Remove `groupValue` and `onChanged` from individual Radio widgets

3. **Add migration comments:**
```dart
// Migrated to RadioGroup API - Flutter 3.27+ breaking change
RadioGroup<String>(
  groupValue: selectedValue,
  onChanged: (value) => setState(() => selectedValue = value),
  children: [
    Radio<String>(value: 'option1'), // Removed groupValue and onChanged
    Radio<String>(value: 'option2'),
  ],
)
```

4. **Test the file:**
```bash
# Run widget tests for the specific file
flutter test test/widget/path/to/file_test.dart
```



#### Step 5: Verify All Migrations (20 minutes)

```bash
# Verify no deprecated Radio usage remains
grep -rn "Radio<.*>(" lib/ --include="*.dart" | grep "groupValue"
# Expected: No matches (all Radio widgets should be inside RadioGroup)

# Run full analyzer
flutter analyze | grep deprecated_member_use
# Expected: 0 deprecated warnings

# Run all tests
flutter test
# Expected: All 627+ tests pass ✅
```

#### Step 6: Manual Testing (15 minutes)

**Test Each Migrated Screen:**

1. **Nutrition EMR Form:**
   - [ ] Gender selection works (radio buttons respond)
   - [ ] Meal frequency selection works
   - [ ] Selected value persists
   - [ ] Form submission includes correct values

2. **Physiotherapy Assessment Form:**
   - [ ] Pain level selection works
   - [ ] RadioListTile displays correctly
   - [ ] Selection updates Riverpod state

3. **Settings/Preferences:**
   - [ ] All radio options selectable
   - [ ] Settings save correctly

**Verification Checklist:**
- [ ] Radio buttons visually correct (no layout issues)
- [ ] Selection state updates correctly
- [ ] Only one radio selected at a time per group
- [ ] Form validation works
- [ ] Data persistence works

#### Step 7: Update Tests (20 minutes)

Update widget tests to match new RadioGroup structure:

```dart
// BEFORE (Testing deprecated Radio)
testWidgets('should select gender when radio tapped', (tester) async {
  await tester.pumpWidget(const NutritionForm());
  
  await tester.tap(find.byWidgetPredicate(
    (widget) => widget is Radio<String> && widget.value == 'male',
  ));
  await tester.pump();
  
  expect(find.byWidgetPredicate(
    (widget) => widget is Radio<String> && 
                widget.value == 'male' && 
                widget.groupValue == 'male',
  ), findsOneWidget);
});

// AFTER (Testing RadioGroup)
testWidgets('should select gender when radio tapped', (tester) async {
  await tester.pumpWidget(const NutritionForm());
  
  // Find RadioGroup first
  final radioGroup = find.byType(RadioGroup<String>);
  expect(radioGroup, findsOneWidget);
  
  // Find Radio within RadioGroup
  await tester.tap(find.descendant(
    of: radioGroup,
    matching: find.byWidgetPredicate(
      (widget) => widget is Radio<String> && widget.value == 'male',
    ),
  ));
  await tester.pump();
  
  // Verify RadioGroup groupValue updated
  final radioGroupWidget = tester.widget<RadioGroup<String>>(radioGroup);
  expect(radioGroupWidget.groupValue, 'male');
});
```



### Rollback Procedure

If functionality breaks or tests fail:

```bash
# Identify failed file
FAILED_FILE="lib/features/emr/nutrition/presentation/widgets/nutrition_form.dart"

# Restore from backup
BACKUP_DIR="backups/task18_YYYYMMDD_HHMMSS"
cp "$BACKUP_DIR/$(basename $FAILED_FILE)" "$FAILED_FILE"

# Verify restoration
git diff "$FAILED_FILE"

# Run tests to confirm rollback
flutter test test/widget/features/emr/nutrition/nutrition_form_test.dart
```

### Common Issues and Solutions

**Issue 1: Layout breaks after migration**

**Symptom:** Radio buttons stack incorrectly or spacing is wrong

**Solution:**
```dart
// Add explicit layout constraints
RadioGroup<String>(
  groupValue: selectedValue,
  onChanged: (value) => setState(() => selectedValue = value),
  children: [
    SizedBox(
      width: double.infinity,
      child: Radio<String>(value: 'option1'),
    ),
  ],
)
```

**Issue 2: State not updating**

**Symptom:** Radio selection doesn't update UI

**Solution:**
```dart
// Ensure onChanged is properly connected
RadioGroup<String>(
  groupValue: selectedValue,
  onChanged: (value) {
    setState(() {
      selectedValue = value;
    });
    // Or for Riverpod:
    // ref.read(selectionProvider.notifier).update(value);
  },
  children: [...],
)
```

**Issue 3: Tests fail with "Radio not found"**

**Symptom:** Widget tests can't find Radio widgets

**Solution:**
```dart
// Use descendant finder
find.descendant(
  of: find.byType(RadioGroup<String>),
  matching: find.byType(Radio<String>),
)
```



### Deliverables

- ✅ `radio_usage.txt` - Complete list of Radio widget locations
- ✅ Migration checklist for each file
- ✅ All Radio widgets migrated to RadioGroup pattern
- ✅ Migration comments added to all changes
- ✅ Widget tests updated to match new structure
- ✅ Manual testing completed for all affected screens
- ✅ All tests passing (627+)

### Success Criteria

- [ ] Zero deprecated Radio usage (no `groupValue` on individual Radio widgets)
- [ ] All Radio widgets wrapped in RadioGroup
- [ ] Functionality unchanged (manual testing confirms)
- [ ] All tests pass (0 failures)
- [ ] Analyzer shows 0 deprecated warnings

---

## Subtask 18.3: Verify No Deprecated API Warnings

**Duration:** 30 minutes  
**Priority:** HIGH  
**Requirements:** 10.4, 10.5

### Objectives

1. Run comprehensive analyzer check
2. Verify zero deprecated_member_use warnings
3. Document any remaining issues
4. Generate completion report

### Steps

#### Step 1: Run Comprehensive Analysis (10 minutes)

```bash
# Run full analyzer with detailed output
flutter analyze --no-fatal-infos > analysis_final.txt 2>&1

# Count total warnings
grep -c "warning •" analysis_final.txt

# Count deprecated warnings (should be 0)
grep -c "deprecated_member_use" analysis_final.txt

# Compare with baseline
echo "Baseline warnings: $(grep -c 'warning •' analysis_baseline.txt)"
echo "Final warnings: $(grep -c 'warning •' analysis_final.txt)"
echo "Deprecated warnings reduced: $(grep -c 'deprecated_member_use' analysis_baseline.txt) → $(grep -c 'deprecated_member_use' analysis_final.txt)"
```

**Expected Output:**
```
Baseline warnings: 50
Final warnings: 44
Deprecated warnings reduced: 6 → 0
```



#### Step 2: Verify ColorExtensions Usage (5 minutes)

Check if ColorExtensions is being used (optional migration path):

```bash
# Search for ColorExtensions usage
grep -rn "withAlpha" lib/ --include="*.dart"

# If found, document for future direct API migration
echo "ColorExtensions usage found - consider migrating to direct withValues() in future" > color_extensions_usage.txt
```

#### Step 3: Run Full Test Suite (10 minutes)

```bash
# Run all tests with coverage
flutter test --coverage

# Verify all tests pass
echo "Test Results:"
flutter test --reporter expanded | tail -n 5

# Check coverage maintained
genhtml coverage/lcov.info -o coverage/html
# Open coverage/html/index.html and verify ≥ 70%
```

**Expected:**
- All 627+ tests pass ✅
- Coverage ≥ 70% ✅
- No test failures related to API migration

#### Step 4: Document Behavior Changes (5 minutes)

Create migration report documenting any behavior differences:

```markdown
# Task 18: Deprecated API Migration - Completion Report

## Summary

- **Start Date:** YYYY-MM-DD
- **Completion Date:** YYYY-MM-DD
- **Duration:** X hours
- **Status:** ✅ Complete

## Metrics

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Total Warnings | 50 | 44 | -6 (-12%) |
| Deprecated Warnings | 6 | 0 | -6 (-100%) |
| Test Pass Rate | 100% | 100% | No change |
| Test Coverage | 70%+ | 70%+ | Maintained |

## Changes Made

### Subtask 18.1: withOpacity → withValues
- **Files Modified:** 1
- **Instances Replaced:** 4
- **Visual Changes:** None
- **Behavior Changes:** None

### Subtask 18.2: Radio → RadioGroup
- **Files Modified:** X
- **Instances Migrated:** Y
- **Visual Changes:** None
- **Behavior Changes:** None (functionality preserved)

## API Behavior Differences

### Color.withValues(alpha:)
- **Old API:** `Colors.blue.withOpacity(0.5)`
- **New API:** `Colors.blue.withValues(alpha: 0.5)`
- **Behavior:** Identical - both produce same color with 50% opacity
- **Breaking:** No

### RadioGroup<T>
- **Old API:** Individual Radio widgets with groupValue/onChanged
- **New API:** RadioGroup wrapper with children Radio widgets
- **Behavior:** Identical - selection logic unchanged
- **Breaking:** Yes - requires structural widget tree changes

## Verification

- [x] Zero deprecated_member_use warnings
- [x] All tests pass (627+)
- [x] Coverage maintained (70%+)
- [x] Visual appearance unchanged
- [x] Functionality preserved

## Recommendations

1. **Future Migrations:**
   - Consider removing ColorExtensions after team familiarity with withValues()
   - Monitor Flutter release notes for future API changes

2. **Prevention:**
   - Setup pre-commit hooks (see Subtask 18.4)
   - Enable CI/CD checks for deprecated APIs
   - Regular dependency updates

## Files Modified

- lib/features/video_call/presentation/screens/agora_video_call_screen.dart
- lib/core/extensions/color_extensions.dart (new)
- test/unit/core/extensions/color_extensions_test.dart (new)
- [List all Radio migration files]

## Backup Location

`backups/task18_YYYYMMDD_HHMMSS/`
```



### Deliverables

- ✅ `analysis_final.txt` - Final analyzer output
- ✅ `color_extensions_usage.txt` - ColorExtensions usage report (if applicable)
- ✅ `TASK_18_COMPLETION_REPORT.md` - Comprehensive migration report
- ✅ Test results showing 100% pass rate
- ✅ Coverage report showing ≥ 70%

### Success Criteria

- [ ] Analyzer shows 0 deprecated_member_use warnings
- [ ] Total warnings reduced by ≥ 6
- [ ] All tests pass (627+)
- [ ] Coverage maintained at ≥ 70%
- [ ] Completion report generated

---

## Subtask 18.4: Setup Prevention Mechanisms

**Duration:** 1.5 hours  
**Priority:** HIGH  
**Requirements:** N/A (Future-proofing)

### Objectives

1. Setup pre-commit hooks to detect deprecated APIs
2. Configure CI/CD to enforce zero deprecated warnings
3. Create golden tests for visual regression
4. Document prevention strategy

### Why This Matters

Preventing deprecated API usage is more efficient than fixing it later:
- **Catches issues early** in development
- **Prevents accumulation** of technical debt
- **Enforces standards** across team
- **Reduces future migration effort**

### Steps

#### Step 1: Create Pre-Commit Hook (30 minutes)

Create a Git pre-commit hook to check for deprecated APIs:

```bash
# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

echo "Running pre-commit checks..."

# Run Flutter analyzer
echo "Checking for deprecated API usage..."
DEPRECATED_COUNT=$(flutter analyze 2>&1 | grep -c "deprecated_member_use")

if [ "$DEPRECATED_COUNT" -gt 0 ]; then
  echo "❌ ERROR: Found $DEPRECATED_COUNT deprecated API usage(s)"
  echo ""
  echo "Deprecated APIs found:"
  flutter analyze 2>&1 | grep "deprecated_member_use"
  echo ""
  echo "Please fix deprecated API usage before committing."
  echo "See .kiro/specs/code-quality-and-testing-improvement/TASK_18_IMPLEMENTATION_PLAN.md for migration guide."
  exit 1
fi

echo "✅ No deprecated APIs found"

# Run tests on changed files
echo "Running tests..."
flutter test --no-pub

if [ $? -ne 0 ]; then
  echo "❌ ERROR: Tests failed"
  exit 1
fi

echo "✅ All checks passed"
exit 0
EOF

# Make hook executable
chmod +x .git/hooks/pre-commit

# Test the hook
.git/hooks/pre-commit
```



**Create Installation Script:**

```bash
# scripts/install-hooks.sh

#!/bin/bash

echo "Installing Git hooks..."

# Copy pre-commit hook
cp scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

echo "✅ Git hooks installed successfully"
echo ""
echo "The pre-commit hook will:"
echo "  - Check for deprecated API usage"
echo "  - Run tests on changed files"
echo "  - Prevent commits with deprecated APIs"
```

**Add to CONTRIBUTING.md:**

```markdown
## Git Hooks

This project uses Git hooks to enforce code quality standards.

### Installation

```bash
./scripts/install-hooks.sh
```

### Pre-Commit Hook

The pre-commit hook automatically:
- Checks for deprecated API usage
- Runs tests on changed files
- Prevents commits with deprecated APIs

To bypass the hook (not recommended):
```bash
git commit --no-verify
```
```

#### Step 2: Configure CI/CD Pipeline (30 minutes)

Create GitHub Actions workflow to enforce deprecated API checks:

```yaml
# .github/workflows/deprecated-api-check.yml

name: Deprecated API Check

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  check-deprecated-apis:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.27.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Check for deprecated APIs
      run: |
        echo "Checking for deprecated API usage..."
        DEPRECATED_COUNT=$(flutter analyze 2>&1 | grep -c "deprecated_member_use" || true)
        
        if [ "$DEPRECATED_COUNT" -gt 0 ]; then
          echo "❌ ERROR: Found $DEPRECATED_COUNT deprecated API usage(s)"
          echo ""
          echo "Deprecated APIs found:"
          flutter analyze 2>&1 | grep "deprecated_member_use"
          echo ""
          echo "Please fix deprecated API usage before merging."
          exit 1
        fi
        
        echo "✅ No deprecated APIs found"
    
    - name: Run tests
      run: flutter test
    
    - name: Generate report
      if: failure()
      run: |
        echo "## Deprecated API Check Failed" >> $GITHUB_STEP_SUMMARY
        echo "" >> $GITHUB_STEP_SUMMARY
        echo "Found deprecated API usage. Please migrate to current APIs." >> $GITHUB_STEP_SUMMARY
        echo "" >> $GITHUB_STEP_SUMMARY
        echo "See migration guide: .kiro/specs/code-quality-and-testing-improvement/TASK_18_IMPLEMENTATION_PLAN.md" >> $GITHUB_STEP_SUMMARY
```



#### Step 3: Setup Golden Tests for Visual Regression (20 minutes)

Create golden tests to catch visual changes from API migrations:

```bash
# Add golden_toolkit dependency
flutter pub add golden_toolkit --dev
```

**Create Golden Test:**

```dart
// test/golden/video_call_screen_golden_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:elajtech/features/video_call/presentation/screens/agora_video_call_screen.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });
  
  group('AgoraVideoCallScreen Golden Tests', () {
    testGoldens('should match golden file for default state', (tester) async {
      await tester.pumpWidgetBuilder(
        const AgoraVideoCallScreen(),
        surfaceSize: const Size(375, 667), // iPhone SE size
      );
      
      await screenMatchesGolden(tester, 'agora_video_call_screen_default');
    });
    
    testGoldens('should match golden file with overlay visible', (tester) async {
      await tester.pumpWidgetBuilder(
        const AgoraVideoCallScreen(showOverlay: true),
        surfaceSize: const Size(375, 667),
      );
      
      await screenMatchesGolden(tester, 'agora_video_call_screen_overlay');
    });
  });
}
```

**Generate Golden Files:**

```bash
# Generate golden files
flutter test --update-goldens test/golden/

# Verify golden files created
ls test/golden/goldens/
# Expected: agora_video_call_screen_default.png, agora_video_call_screen_overlay.png
```

**Add to CI/CD:**

```yaml
# Add to .github/workflows/deprecated-api-check.yml

    - name: Run golden tests
      run: flutter test test/golden/
    
    - name: Upload golden test failures
      if: failure()
      uses: actions/upload-artifact@v3
      with:
        name: golden-test-failures
        path: test/golden/failures/
```



#### Step 4: Create Automated Rollback Script (10 minutes)

Create a script to quickly rollback if issues are found:

```bash
# scripts/rollback-task18.sh

#!/bin/bash

echo "Task 18 Rollback Script"
echo "======================="
echo ""

# Find latest backup
BACKUP_DIR=$(ls -td backups/task18_* 2>/dev/null | head -1)

if [ -z "$BACKUP_DIR" ]; then
  echo "❌ ERROR: No backup found"
  echo "Expected backup directory: backups/task18_YYYYMMDD_HHMMSS/"
  exit 1
fi

echo "Found backup: $BACKUP_DIR"
echo ""

# Confirm rollback
read -p "Are you sure you want to rollback? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Rollback cancelled"
  exit 0
fi

echo ""
echo "Rolling back changes..."

# Restore files
if [ -f "$BACKUP_DIR/agora_video_call_screen.dart" ]; then
  cp "$BACKUP_DIR/agora_video_call_screen.dart" lib/features/video_call/presentation/screens/
  echo "✅ Restored agora_video_call_screen.dart"
fi

# Restore all backed up files
find "$BACKUP_DIR" -name "*.dart" -type f | while read file; do
  RELATIVE_PATH=$(echo "$file" | sed "s|$BACKUP_DIR/||")
  TARGET_PATH="lib/$RELATIVE_PATH"
  
  if [ -f "$TARGET_PATH" ]; then
    cp "$file" "$TARGET_PATH"
    echo "✅ Restored $RELATIVE_PATH"
  fi
done

echo ""
echo "Running tests to verify rollback..."
flutter test

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Rollback successful - all tests pass"
else
  echo ""
  echo "⚠️  WARNING: Some tests failed after rollback"
  echo "Manual intervention may be required"
fi
```

**Make executable:**
```bash
chmod +x scripts/rollback-task18.sh
```

**Test rollback script:**
```bash
# Dry run (without confirmation)
echo "no" | ./scripts/rollback-task18.sh
```



### Deliverables

- ✅ `.git/hooks/pre-commit` - Pre-commit hook for deprecated API detection
- ✅ `scripts/install-hooks.sh` - Hook installation script
- ✅ `.github/workflows/deprecated-api-check.yml` - CI/CD workflow
- ✅ `test/golden/video_call_screen_golden_test.dart` - Golden tests
- ✅ `scripts/rollback-task18.sh` - Automated rollback script
- ✅ Updated CONTRIBUTING.md with hook documentation

### Success Criteria

- [ ] Pre-commit hook installed and tested
- [ ] CI/CD workflow configured and passing
- [ ] Golden tests created and passing
- [ ] Rollback script tested
- [ ] Documentation updated

---

## Testing Strategy

### Automated Testing

#### Unit Tests
- **ColorExtensions:** 3 tests covering alpha values and edge cases
- **Expected:** All pass ✅

#### Widget Tests
- **Video Call Screen:** Verify color opacity rendering
- **Radio Forms:** Verify RadioGroup functionality
- **Expected:** All 627+ tests pass ✅

#### Golden Tests
- **Video Call Screen:** Visual regression for color changes
- **Radio Forms:** Visual regression for layout changes
- **Expected:** All golden tests pass ✅

#### Integration Tests
- **Video Call Flow:** End-to-end video call with UI interactions
- **Form Submission:** EMR forms with Radio selections
- **Expected:** All integration tests pass ✅

### Manual Testing

#### Visual Verification
- [ ] Video call overlay opacity correct (50% black)
- [ ] Control buttons opacity correct (80% white)
- [ ] Error indicators opacity correct (70% red)
- [ ] Loading indicators opacity correct (60% grey)

#### Functional Verification
- [ ] Radio button selection works in all forms
- [ ] Only one radio selected per group
- [ ] Form validation works with Radio selections
- [ ] Data persistence works with Radio values

#### Cross-Platform Testing
- [ ] Test on Android device/emulator
- [ ] Test on iOS device/simulator
- [ ] Verify no platform-specific issues



---

## Risk Assessment

### High Risk Areas

#### 1. RadioGroup Migration (CRITICAL)

**Risk:** Breaking change may cause unexpected behavior

**Mitigation:**
- Comprehensive testing before and after migration
- Incremental migration (one file at a time)
- Immediate rollback if issues detected
- Golden tests for visual regression

**Contingency:**
- Rollback script ready
- Backup of all files
- Team member review before merge

#### 2. Test Failures

**Risk:** Tests may fail after API migration

**Mitigation:**
- Update tests alongside code changes
- Run tests after each file migration
- Use test fixtures to ensure consistency

**Contingency:**
- Rollback individual files if tests fail
- Fix tests before proceeding to next file

#### 3. Visual Regression

**Risk:** UI appearance may change subtly

**Mitigation:**
- Golden tests for critical screens
- Manual visual verification
- Screenshot comparison

**Contingency:**
- Adjust alpha values if needed
- Rollback if visual changes unacceptable

### Medium Risk Areas

#### 4. Performance Impact

**Risk:** RadioGroup may have different performance characteristics

**Mitigation:**
- Profile before and after migration
- Monitor build times
- Test on low-end devices

**Contingency:**
- Optimize RadioGroup usage if needed
- Consider alternative patterns

#### 5. Third-Party Dependencies

**Risk:** Dependencies may not support Flutter 3.27+

**Mitigation:**
- Check dependency compatibility before migration
- Update dependencies if needed
- Test all features after dependency updates

**Contingency:**
- Pin to compatible versions
- Fork and patch if necessary

### Low Risk Areas

#### 6. Color API Migration

**Risk:** Minimal - API is straightforward

**Mitigation:**
- Simple find-replace pattern
- ColorExtensions for safety
- Visual verification



---

## Timeline

### Detailed Schedule (6-8 hours total)

#### Phase 1: Preparation (30 minutes)
- **Subtask 18.0:** Pre-migration analysis and setup
- **Deliverables:** Baseline metrics, backups, ColorExtensions

#### Phase 2: Color API Migration (45 minutes)
- **Subtask 18.1:** Replace withOpacity with withValues
- **Deliverables:** 4 instances migrated, tests passing

#### Phase 3: Radio API Migration (2.5 hours)
- **Subtask 18.2:** Update Radio to RadioGroup
- **Deliverables:** All Radio usage migrated, tests updated

#### Phase 4: Verification (30 minutes)
- **Subtask 18.3:** Verify no deprecated warnings
- **Deliverables:** Completion report, zero warnings

#### Phase 5: Prevention (1.5 hours)
- **Subtask 18.4:** Setup prevention mechanisms
- **Deliverables:** Hooks, CI/CD, golden tests

#### Buffer Time (1-2 hours)
- Unexpected issues
- Additional testing
- Documentation updates

### Milestones

| Milestone | Target Time | Success Criteria |
|-----------|-------------|------------------|
| Preparation Complete | +30 min | Backups created, ColorExtensions tested |
| Color API Migrated | +1h 15min | 4 instances replaced, tests pass |
| Radio API Migrated | +3h 45min | All Radio usage migrated, tests pass |
| Verification Complete | +4h 15min | Zero deprecated warnings |
| Prevention Setup | +5h 45min | Hooks and CI/CD configured |
| Final Review | +6-8h | All deliverables complete |

### Daily Schedule (Recommended)

**Day 1 (4 hours):**
- Morning: Subtasks 18.0, 18.1 (1h 15min)
- Afternoon: Subtask 18.2 (2h 30min)
- End of day: Commit progress, run tests

**Day 2 (2-4 hours):**
- Morning: Complete Subtask 18.2 if needed
- Mid-morning: Subtask 18.3 (30min)
- Afternoon: Subtask 18.4 (1h 30min)
- End of day: Final review, merge PR



---

## Deliverables

### Code Artifacts

- ✅ `lib/core/extensions/color_extensions.dart` - ColorExtensions utility
- ✅ `test/unit/core/extensions/color_extensions_test.dart` - Extension tests
- ✅ Modified files with deprecated API migrations
- ✅ Updated widget tests for RadioGroup

### Documentation

- ✅ `analysis_baseline.txt` - Pre-migration analyzer output
- ✅ `analysis_final.txt` - Post-migration analyzer output
- ✅ `deprecated_locations.txt` - List of deprecated API locations
- ✅ `radio_usage.txt` - Radio widget usage inventory
- ✅ `TASK_18_COMPLETION_REPORT.md` - Comprehensive migration report
- ✅ Updated CONTRIBUTING.md with hook documentation

### Automation

- ✅ `.git/hooks/pre-commit` - Pre-commit hook
- ✅ `scripts/install-hooks.sh` - Hook installation script
- ✅ `.github/workflows/deprecated-api-check.yml` - CI/CD workflow
- ✅ `scripts/rollback-task18.sh` - Rollback automation

### Testing

- ✅ `test/golden/video_call_screen_golden_test.dart` - Golden tests
- ✅ Updated widget tests for all migrated components
- ✅ Test results showing 100% pass rate

### Backups

- ✅ `backups/task18_YYYYMMDD_HHMMSS/` - Complete backup directory
- ✅ `backups/task18_YYYYMMDD_HHMMSS/MANIFEST.txt` - Backup manifest

---

## Success Metrics

### Quantitative Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Deprecated Warnings | 0 | `flutter analyze \| grep deprecated_member_use \| wc -l` |
| Total Warnings Reduced | ≥ 6 | Compare baseline vs final |
| Test Pass Rate | 100% | `flutter test` |
| Test Coverage | ≥ 70% | `flutter test --coverage` |
| withOpacity Instances | 0 | `grep -r "withOpacity" lib/` |
| Radio groupValue Usage | 0 | `grep -r "Radio<.*>(" lib/ \| grep groupValue` |

### Qualitative Metrics

- ✅ Visual appearance unchanged (manual verification)
- ✅ Functionality preserved (manual testing)
- ✅ Code maintainability improved (RadioGroup pattern)
- ✅ Prevention mechanisms in place (hooks, CI/CD)
- ✅ Documentation complete and accurate
- ✅ Team can replicate migration process



---

## References

### Flutter Documentation

- [Flutter 3.27 Release Notes](https://docs.flutter.dev/release/release-notes/release-notes-3.27.0)
- [Color.withValues API Documentation](https://api.flutter.dev/flutter/dart-ui/Color/withValues.html)
- [RadioGroup Widget Documentation](https://api.flutter.dev/flutter/material/RadioGroup-class.html)
- [Migration Guide: Deprecated APIs](https://docs.flutter.dev/release/breaking-changes)

### Testing Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Golden Toolkit Package](https://pub.dev/packages/golden_toolkit)
- [Widget Testing Best Practices](https://docs.flutter.dev/cookbook/testing/widget/introduction)

### Project Documentation

- [README.md](../../../../README.md) - Project overview
- [CONTRIBUTING.md](../../../../CONTRIBUTING.md) - Development guidelines
- [CHANGELOG.md](../../../../CHANGELOG.md) - Version history
- [requirements.md](./requirements.md) - Requirement 10: Deprecated API Migration
- [design.md](./design.md) - Design section on deprecated API migration
- [tasks.md](./tasks.md) - Task 18 definition

### Related Specs

- [code-quality-and-testing-improvement](../) - Parent spec
- Phase A: Critical Fixes (Complete)
- Phase B: Testing Infrastructure (Complete)
- Phase C: Documentation (Complete)
- Phase D: Performance & Polish (In Progress - Task 18)

---

## Appendix A: Quick Reference Commands

### Analysis Commands

```bash
# Run analyzer
flutter analyze

# Count deprecated warnings
flutter analyze 2>&1 | grep -c "deprecated_member_use"

# List deprecated locations
flutter analyze 2>&1 | grep "deprecated_member_use"
```

### Testing Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/core/extensions/color_extensions_test.dart

# Update golden files
flutter test --update-goldens test/golden/
```

### Search Commands

```bash
# Find withOpacity usage
grep -rn "withOpacity" lib/ --include="*.dart"

# Find Radio usage
grep -rn "Radio<" lib/ --include="*.dart"

# Find RadioListTile usage
grep -rn "RadioListTile<" lib/ --include="*.dart"
```

### Backup Commands

```bash
# Create backup
BACKUP_DIR="backups/task18_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r lib/ "$BACKUP_DIR/"

# Restore from backup
cp "$BACKUP_DIR/path/to/file.dart" lib/path/to/file.dart
```



---

## Appendix B: Migration Patterns Cheat Sheet

### Color API Migration

```dart
// Pattern 1: Simple opacity
Colors.blue.withOpacity(0.5)           → Colors.blue.withValues(alpha: 0.5)

// Pattern 2: With ColorExtensions (transition)
Colors.blue.withOpacity(0.5)           → Colors.blue.withAlpha(0.5)

// Pattern 3: In decoration
BoxDecoration(
  color: Colors.red.withOpacity(0.7),  → color: Colors.red.withValues(alpha: 0.7),
)

// Pattern 4: In widget properties
Icon(
  Icons.star,
  color: Colors.yellow.withOpacity(0.8) → color: Colors.yellow.withValues(alpha: 0.8),
)
```

### Radio API Migration

```dart
// Pattern A: Simple Radio Group
Column(
  children: [
    Radio<String>(value: 'a', groupValue: x, onChanged: f),
    Radio<String>(value: 'b', groupValue: x, onChanged: f),
  ],
)
↓
RadioGroup<String>(
  groupValue: x,
  onChanged: f,
  children: [
    Radio<String>(value: 'a'),
    Radio<String>(value: 'b'),
  ],
)

// Pattern B: Radio with Labels
Row(
  children: [
    Radio<String>(value: 'yes', groupValue: x, onChanged: f),
    Text('Yes'),
  ],
)
↓
RadioGroup<String>(
  groupValue: x,
  onChanged: f,
  children: [
    Row(children: [Radio<String>(value: 'yes'), Text('Yes')]),
  ],
)

// Pattern C: RadioListTile
RadioListTile<String>(
  title: Text('Option'),
  value: 'opt',
  groupValue: x,
  onChanged: f,
)
↓
RadioGroup<String>(
  groupValue: x,
  onChanged: f,
  children: [
    RadioListTile<String>(title: Text('Option'), value: 'opt'),
  ],
)

// Pattern D: Dynamic Lists
Column(
  children: items.map((item) => 
    Radio<T>(value: item, groupValue: x, onChanged: f)
  ).toList(),
)
↓
RadioGroup<T>(
  groupValue: x,
  onChanged: f,
  children: items.map((item) => Radio<T>(value: item)).toList(),
)

// Pattern E: Riverpod State
final x = ref.watch(provider);
Radio<T>(
  value: val,
  groupValue: x,
  onChanged: (v) => ref.read(provider.notifier).update(v),
)
↓
final x = ref.watch(provider);
RadioGroup<T>(
  groupValue: x,
  onChanged: (v) => ref.read(provider.notifier).update(v),
  children: [Radio<T>(value: val)],
)
```



---

## Appendix C: Troubleshooting Guide

### Issue: "Radio not found" in tests

**Symptom:**
```
Test failed: Expected to find at least one widget matching type Radio<String>, but found none.
```

**Solution:**
```dart
// Use descendant finder
find.descendant(
  of: find.byType(RadioGroup<String>),
  matching: find.byType(Radio<String>),
)
```

### Issue: RadioGroup layout breaks

**Symptom:** Radio buttons stack incorrectly or have wrong spacing

**Solution:**
```dart
// Add explicit constraints
RadioGroup<String>(
  groupValue: selectedValue,
  onChanged: (value) => setState(() => selectedValue = value),
  children: [
    SizedBox(
      width: double.infinity,
      child: Radio<String>(value: 'option1'),
    ),
  ],
)
```

### Issue: State not updating after migration

**Symptom:** Radio selection doesn't update UI

**Solution:**
```dart
// Ensure onChanged is properly connected
RadioGroup<String>(
  groupValue: selectedValue,
  onChanged: (value) {
    setState(() {
      selectedValue = value;
    });
  },
  children: [...],
)
```

### Issue: Golden tests fail after migration

**Symptom:** Golden test shows visual differences

**Solution:**
```bash
# Regenerate golden files
flutter test --update-goldens test/golden/

# Review differences
open test/golden/failures/
```

### Issue: Pre-commit hook blocks valid commit

**Symptom:** Hook fails even though code is correct

**Solution:**
```bash
# Verify analyzer output
flutter analyze

# If false positive, bypass hook (not recommended)
git commit --no-verify

# Or fix hook script
nano .git/hooks/pre-commit
```

### Issue: CI/CD pipeline fails

**Symptom:** GitHub Actions workflow fails on deprecated API check

**Solution:**
```bash
# Run locally to reproduce
flutter analyze 2>&1 | grep "deprecated_member_use"

# Fix any remaining deprecated usage
# Push fix and re-run pipeline
```



---

## Appendix D: Version History

### Version 2.0 (2026-02-16) - CURRENT

**Major Updates:**
- Added Subtask 18.0: Pre-migration analysis and setup
- Complete rewrite of Subtask 18.2: RadioGroup migration (breaking change)
- Added Subtask 18.4: Prevention mechanisms
- Extended timeline from 4-6 hours to 6-8 hours
- Added ColorExtensions utility
- Added golden tests for visual regression
- Added pre-commit hooks and CI/CD workflows
- Added automated rollback script
- Enhanced documentation with migration patterns

**Changes from v1.0:**
- 4 subtasks → 5 subtasks (added 18.0 and 18.4)
- Simple migration → Comprehensive migration with prevention
- Basic testing → Golden tests + automated checks
- Manual process → Automated with hooks and CI/CD

### Version 1.0 (2026-02-13) - DEPRECATED

**Initial Version:**
- 3 subtasks: 18.1, 18.2, 18.3
- Basic migration approach
- Manual testing only
- No prevention mechanisms
- 4-6 hour timeline

**Limitations:**
- No pre-migration analysis
- RadioGroup migration underestimated (breaking change not recognized)
- No prevention mechanisms
- No automated testing

---

## Document Information

**Document Title:** Task 18: Deprecated API Migration - Implementation Plan  
**Version:** 2.0  
**Last Updated:** 2026-02-16  
**Author:** AndroCare360 Development Team  
**Status:** Ready for Implementation  

**Related Documents:**
- [requirements.md](./requirements.md) - Requirement 10
- [design.md](./design.md) - Deprecated API Migration Design
- [tasks.md](./tasks.md) - Task 18 Definition
- [CONTRIBUTING.md](../../../../CONTRIBUTING.md) - Development Guidelines

**Approval:**
- [ ] Technical Lead Review
- [ ] QA Team Review
- [ ] Product Owner Approval

**Implementation Status:**
- [ ] Subtask 18.0: Pre-Migration Analysis & Setup
- [ ] Subtask 18.1: Replace withOpacity with withValues
- [ ] Subtask 18.2: Update Radio to RadioGroup
- [ ] Subtask 18.3: Verify No Deprecated Warnings
- [ ] Subtask 18.4: Setup Prevention Mechanisms

---

**END OF DOCUMENT**
