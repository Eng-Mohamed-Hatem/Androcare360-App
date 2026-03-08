# Task 19: Large File Refactoring - Quick Reference

## Overview
Break down 3 large files (>500 lines) into smaller, maintainable components.

## Target Files & Goals

### 19.1 Patient Profile Screen
- **From**: 650 lines → **To**: 150 lines
- **Extract**: 4 widgets
  1. `patient_profile_header.dart` (80 lines)
  2. `patient_appointments_list.dart` (120 lines)
  3. `patient_medical_records_summary.dart` (100 lines)
  4. `patient_action_buttons.dart` (60 lines)
- **Time**: 5.5 hours

### 19.2 Main.dart
- **From**: 678 lines → **To**: 300 lines
- **Extract**: 4 initialization modules
  1. `firebase_initialization.dart` (80 lines)
  2. `dependency_injection_setup.dart` (60 lines)
  3. `background_services_initialization.dart` (100 lines)
  4. `app_configuration.dart` (70 lines)
- **Time**: 7 hours

### 19.3 Doctor Appointments Screen
- **From**: TBD → **To**: ≤300 lines
- **Extract**: 4 widgets
  1. `appointment_card.dart` (100 lines)
  2. `appointment_filter.dart` (80 lines)
  3. `appointment_sort.dart` (60 lines)
  4. `empty_appointments_state.dart` (50 lines)
- **Time**: 5 hours

## Total Effort
- **Base Time**: 17.5 hours
- **With Buffer**: 21 hours (3 days)

## Critical Checkpoints

### Before Starting
- [ ] Run `flutter analyze` - record baseline
- [ ] Run `flutter test` - verify 664+ tests pass
- [ ] Take screenshots of all screens

### After Each Extraction
- [ ] Run `flutter analyze` - no new warnings
- [ ] Compile successfully
- [ ] Test specific functionality

### After Completion
- [ ] All 664+ tests pass
- [ ] Zero new analyzer warnings
- [ ] Manual testing confirms identical functionality
- [ ] UI appearance unchanged

## Key Commands

```bash
# Analyze code
flutter analyze

# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Build runner (if DI changes)
flutter pub run build_runner build --delete-conflicting-outputs
```

## Critical Rules
1. ✅ Use `databaseId: 'elajtech'` for Firestore
2. ✅ Use `region: 'europe-west1'` for Functions
3. ✅ Add bilingual doc comments
4. ✅ Use `const` constructors
5. ✅ Test after each extraction

## Git Strategy
- Branch: `feature/task-19-refactor-large-files`
- Sub-branches for each subtask
- Commit after each widget extraction
- Create PR for each subtask

## Success Criteria
- ✅ All target files meet line count goals
- ✅ All 664+ tests pass
- ✅ Zero new analyzer warnings
- ✅ All extracted widgets documented
- ✅ Functionality identical
- ✅ UI appearance unchanged

---

**See TASK_19_REFACTORING_PLAN.md for complete details**
