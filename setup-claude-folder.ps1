# =============================================================
# Elajtech — .claude Folder Setup Script
# Run from project root: C:\Users\moham\Desktop\androcare\elajtech\elajtech
# PowerShell: Right-click → "Run with PowerShell"
# Or: cd to project folder, then: .\setup-claude-folder.ps1
# =============================================================

$projectRoot = "C:\Users\moham\Desktop\androcare\elajtech\elajtech"
Set-Location $projectRoot

Write-Host "🚀 Creating .claude folder structure for Elajtech..." -ForegroundColor Cyan

# Create directories
$dirs = @(
    ".claude",
    ".claude\hooks",
    ".claude\rules",
    ".claude\skills\new-feature",
    ".claude\skills\code-review",
    ".claude\agents"
)
foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
Write-Host "✅ Directories created" -ForegroundColor Green

# =============================================================
# CLAUDE.md (project root)
# =============================================================
$claudeMd = @'
# Elajtech — AndroCare360 Flutter App

## Project Identity
- **Database ID**: `elajtech` (NOT the default Firebase DB — critical)
- **Cloud Functions Region**: `europe-west1`
- **Flutter**: 3.x | **Dart**: 3.10.4
- **State Management**: Riverpod 2.5.x
- **DI**: get_it + injectable
- **Architecture**: Clean Architecture (Presentation / Domain / Data)
- **Feature-First**: `lib/features/<feature>/data/` `domain/` `presentation/`

---

## Commands
```bash
flutter pub get
flutter run
flutter test                        # 700+ tests — ALL must pass
flutter analyze                     # Must return ZERO errors/warnings/info
dart format lib/ test/

# After ANY change to @injectable / @freezed / @JsonSerializable:
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🔴 Non-Negotiable Rules

### 1. Firestore Database
```dart
// ✅ ALWAYS (via DI — preferred)
final FirebaseFirestore _firestore; // injected via constructor

// ✅ Direct (only in FirebaseModule)
FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'elajtech')

// ❌ NEVER — will hit wrong database
FirebaseFirestore.instance
```

### 2. Cloud Functions
```dart
// ✅ ALWAYS
FirebaseFunctions.instanceFor(region: 'europe-west1')

// ❌ NEVER
FirebaseFunctions.instance
```

### 3. Auth / Null Safety
```dart
// ✅ ALWAYS
final user = ref.watch(authProvider).user;
if (user == null) return const LoadingWidget();

// ❌ NEVER
final user = ref.watch(authProvider).user!;
```

### 4. List Safety
```dart
// ✅ ALWAYS
final spec = list.isNotEmpty ? list.first : 'General';

// ❌ NEVER
final spec = list.first;
```

### 5. Firestore Snapshot Parsing
Every `fromFirestore` must:
- Check `snapshot.exists && snapshot.data() != null` first
- Wrap parsing in `try-catch` with `debugPrint(stackTrace.toString())`

### 6. Firestore Write Logging
Every write/update must include:
```dart
if (kDebugMode) {
  debugPrint('[SAVE] userId:$userId | patientId:$patientId | appointmentId:$appointmentId');
}
```

### 7. DI Registration
- Every new service → must have `@lazySingleton()` or `@injectable()`
- Must appear in `injection_container.config.dart` after build_runner
- `configureDependencies()` must complete before any `GetIt.I<T>()` call

### 8. Repository Return Type
All repository methods → `Either<Failure, T>` (dartz)

---

## Auth & Routing Safety
- Unknown `userType` → safe fallback (splash/login) + log, never crash
- `isActive == false` → block with: `'الحساب معطّل، برجاء التواصل مع الدعم.'`
- Any auth change → preserve all existing auth tests + add new ones

---

## Clinic Isolation (SRP)
Each specialty = independent Model + Repository file.
Never merge Nutrition / Physiotherapy / Internal Medicine logic.

---

## UI Rules
- English content in clinic forms → wrap with `Directionality(textDirection: TextDirection.ltr, ...)`
- Phone fields → E.164 validation only (`r'^\+\d{8,15}$'`)
- No deprecated APIs: `withOpacity()` → `withValues(alpha:)`

---

## Testing
- 700+ tests must always pass — zero regressions
- New feature → unit tests (happy path + failure cases) required immediately
- Auth changes → add widget/unit tests for every new scenario
- Native services (VoIP, notifications) → handle `MissingPluginException` in tests

---

## Speckit Lifecycle (New Features)
Never jump from idea → code. Required sequence:
`/speckit.specify` → `/speckit.clarify` → `/speckit.plan` → `/speckit.checklist` → `/speckit.tasks` → `/speckit.analyze` → `/speckit.implement`

Specs live in `.specify/specs/[feature]/spec.md` and `plan.md`

---

## Documentation
All public classes/methods → DartDoc in **Arabic** (business logic) + **English** (technical):
```dart
/// خدمة إدارة المكالمات المرئية
/// Video call management service
///
/// Usage: `getIt<AgoraService>().joinChannel(...)`
```

---

## Watch Out For
- New service not registered in GetIt → app crashes on splash screen
- `FirebaseFirestore.instance` → silent wrong-database reads
- `list.first` on empty list → `StateError` crash
- `flutter analyze` with deprecated APIs → CI failure
- Auth change without tests → regression in 700+ suite
- Merging clinic repositories → SRP violation, reject in review
'@

Set-Content -Path "CLAUDE.md" -Value $claudeMd -Encoding UTF8
Write-Host "✅ CLAUDE.md created" -ForegroundColor Green

# =============================================================
# CLAUDE.local.md (gitignored — personal overrides)
# =============================================================
$claudeLocalMd = @'
# My Personal Overrides (gitignored — not shared with team)

## Local Environment
# Add your local overrides here, for example:
# - Local DB port if different
# - Personal tool preferences
# - IDE-specific settings

## Example
# My local emulator runs on a different port:
# Use FUNCTIONS_EMULATOR_PORT=5002 for local testing
'@

Set-Content -Path "CLAUDE.local.md" -Value $claudeLocalMd -Encoding UTF8
Write-Host "✅ CLAUDE.local.md created" -ForegroundColor Green

# =============================================================
# .claude/rules/firebase-safety.md
# =============================================================
$firebaseSafety = @'
---
# No paths = always active for all files
---
# Firebase & DI Safety Rules — CRITICAL

## Firestore Database
- NEVER use `FirebaseFirestore.instance` anywhere in the codebase
- ALWAYS use injected `_firestore` via constructor (preferred)
- Direct access only in FirebaseModule:
  `FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'elajtech')`

## Firestore Snapshot Parsing
Every `fromFirestore` method MUST follow this pattern:
```dart
factory MyModel.fromFirestore(DocumentSnapshot snapshot) {
  if (!snapshot.exists || snapshot.data() == null) {
    throw Exception('Document does not exist or has no data');
  }
  try {
    return MyModel.fromJson(snapshot.data() as Map<String, dynamic>);
  } catch (e, stackTrace) {
    debugPrint('Error parsing MyModel: $e');
    debugPrint('StackTrace: $stackTrace');
    rethrow;
  }
}
```

## Write/Update Logging (Mandatory)
Every Firestore write/update MUST have debug logging:
```dart
if (kDebugMode) {
  debugPrint('[SAVE] userId: $userId | patientId: $patientId | appointmentId: $appointmentId');
}
```

## Cloud Functions
- ALWAYS: `FirebaseFunctions.instanceFor(region: 'europe-west1')`
- NEVER: `FirebaseFunctions.instance`

## DI Registration
- Every service used as a dependency MUST have `@lazySingleton()` or `@injectable()`
- After adding any service: run `flutter pub run build_runner build --delete-conflicting-outputs`
- Verify the service appears in `injection_container.config.dart`
- `configureDependencies()` MUST be called before any `GetIt.I<T>()` in `main.dart`

## Previous Bug — Must Not Repeat (CallMonitoringService Incident)
- FCMService depended on CallMonitoringService in constructor
- CallMonitoringService was NOT registered in GetIt
- App crashed on splash screen with: "Bad state: GetIt: Object/factory with type CallMonitoringService is not registered"
- Always verify every constructor dependency is also registered in DI

## Object Initialization
- NEVER use `late final` for services that can be initialized immediately
- Use constructor initializer list instead
'@

Set-Content -Path ".claude\rules\firebase-safety.md" -Value $firebaseSafety -Encoding UTF8
Write-Host "✅ rules/firebase-safety.md created" -ForegroundColor Green

# =============================================================
# .claude/rules/testing.md
# =============================================================
$testingRules = @'
---
# No paths = always active
---
# Testing Rules — Non-Negotiable

## The Golden Rule
- The 700+ test suite MUST always pass. Zero regressions.
- Any PR that breaks an existing test is REJECTED immediately.
- Run `flutter test` before declaring any task complete.

## New Feature Requirements
Every new feature MUST include:
1. Unit tests for happy path
2. Unit tests for failure/edge cases
3. Widget tests for new screens/widgets (if any)

## Test Naming Convention
```
methodName_stateUnderTest_expectedBehavior
// Examples:
signIn_withValidCredentials_returnsUser
signIn_withInvalidCredentials_returnsFailure
getUser_withInactiveAccount_returnsBlockedFailure
startAgoraCall_withWrongDoctorId_returnsPermissionDenied
```

## Test File Locations
- Unit:        `test/unit/`
- Widget:      `test/widget/`
- Integration: `test/integration/` (manual — require emulator)

## Mocking
- Use `mockito` for all mocks
- Platform native services (VoIP, Notifications): wrap in try-catch for `MissingPluginException`
- NEVER call real Firebase in unit tests — mock everything
- NEVER use `FirebaseFirestore.instance` in tests — use fake/mock instances

## Authentication-Related Tests
Any change touching auth flows MUST:
1. Keep all existing auth tests passing
2. Add tests for every new scenario (new role, new account state)
3. Cover `isActive == false` blocking
4. Cover unknown `userType` fallback
5. Cover initial sync race condition (`isAuthenticated == true` while `user == null`)

## Coverage Targets
- Core Services:  >= 80%
- Repositories:   >= 80%
- Critical flows (auth, video call, appointments): 100%

## Run Commands
```bash
flutter test                          # All tests
flutter test --coverage               # With coverage report
flutter test test/unit/               # Unit tests only
flutter test --name "AuthRepository"  # Specific group
```
'@

Set-Content -Path ".claude\rules\testing.md" -Value $testingRules -Encoding UTF8
Write-Host "✅ rules/testing.md created" -ForegroundColor Green

# =============================================================
# .claude/rules/architecture.md
# =============================================================
$architectureRules = @'
---
# No paths = always active
---
# Architecture & Code Quality Rules

## Clean Architecture Layers (Strict)
- Presentation: UI widgets, Riverpod providers/notifiers — NO business logic here
- Domain:       Entities, Use Cases — pure Dart, NO Flutter imports
- Data:         Repository impls, data sources, Firestore models

## Feature Structure (Mandatory)
```
lib/features/<feature>/
├── data/
│   ├── models/           # Firestore models with fromFirestore/toJson
│   ├── repositories/     # Repository implementations
│   └── datasources/      # Firestore/API data sources
├── domain/
│   ├── entities/         # Pure Dart entities
│   └── usecases/         # Business logic use cases (optional)
└── presentation/
    ├── screens/
    ├── widgets/
    └── providers/        # Riverpod providers/notifiers
```

## Core Structure
```
lib/core/
├── services/             # 21 platform services (AgoraService, FCMService, etc.)
├── models/               # Shared models
├── errors/               # Custom Failures and Exceptions
├── constants/            # App-wide constants
└── di/                   # injection_container.dart + injection_container.config.dart
```

## Clinic Isolation Rule (SRP — Non-Negotiable)
- Every specialty clinic = independent Model + Repository
- NEVER merge Nutrition + Physiotherapy + Internal Medicine logic
- Each clinic's repository is in its own file
- Violations will be rejected in code review

## Error Handling
- Repositories MUST return `Either<Failure, T>` from `dartz`
- Create custom Failure classes in domain layer (e.g., ServerFailure, NetworkFailure)
- NEVER expose raw Firebase exceptions to presentation layer
- NEVER expose stack traces to users

## Null Safety Patterns
```dart
// ✅ ALWAYS
final user = ref.watch(authProvider).user;
if (user == null) return const LoadingWidget();
// safe to use user.id, user.fullName here

// ❌ NEVER
final user = ref.watch(authProvider).user!; // crash risk
```

## List Safety
```dart
// ✅ ALWAYS
final spec = user.specializations.isNotEmpty
    ? user.specializations.first
    : 'General';

// ❌ NEVER — throws StateError on empty list
final spec = user.specializations.first;
```

## Auth & Routing Safety
- AuthWrapper MUST have a fallback for unknown `userType`
  → redirect to login + debugPrint the unknown value
- Inactive users (`isActive == false`)
  → show: 'الحساب معطّل، برجاء التواصل مع الدعم.'
  → block access at repository, provider, AND UI level

## Phone Numbers
- Store and compare in E.164 format ONLY: `+201008266544`
- Validate with: `r'^\+\d{8,15}$'`
- Never store local format: `01008266544`

## Documentation (Bilingual — Mandatory for Public APIs)
```dart
/// خدمة إدارة المصادقة لنظام AndroCare360
/// Authentication management service for AndroCare360
///
/// Handles Firebase Phone Auth + Firestore user profile lookup.
///
/// Usage:
/// ```dart
/// final result = await repository.signIn(email, password);
/// result.fold(
///   (failure) => showError(failure.message),
///   (user) => navigateToHome(user),
/// );
/// ```
```
'@

Set-Content -Path ".claude\rules\architecture.md" -Value $architectureRules -Encoding UTF8
Write-Host "✅ rules/architecture.md created" -ForegroundColor Green

# =============================================================
# .claude/rules/ui-rules.md
# =============================================================
$uiRules = @'
---
paths:
  - "lib/features/**/presentation/**/*.dart"
  - "lib/shared/**/*.dart"
---
# UI & Presentation Layer Rules

## Directionality
- App global direction is RTL (Arabic)
- ALWAYS wrap English content in clinic forms with:
  `Directionality(textDirection: TextDirection.ltr, child: ...)`
- This ensures input fields, checkboxes, and alignment display correctly

## Phone Number Validation
- Input fields for phone: validate against E.164 format
- Regex: `r'^\+\d{8,15}$'`
- Show inline error if format is wrong before allowing submission

## Widget Performance
- Use `const` constructors wherever possible
- Keep `build()` lightweight — no expensive operations inside
- Break large widgets into smaller, reusable sub-widgets
- Use `ListView.builder` for any list that could grow

## State Management (Riverpod)
- In build: `ref.watch(provider)` for reactive UI
- In callbacks/event handlers: `ref.read(provider)` only
- Always handle all 3 states: loading, error, data
- Use `AsyncValue.when()` for clean state handling

## Error Display to User
- ALL Firestore/network errors → show user-friendly Arabic message
- NEVER show raw exception messages, stack traces, or English errors to users
- Use localized strings from ARB files

## Deprecated APIs — Zero Tolerance
- NEVER: `Color.withOpacity(x)` → USE: `Color.withValues(alpha: x)`
- NEVER: deprecated `Radio(groupValue:, onChanged:)` → USE: `RadioGroup`
- After any UI change: run `flutter analyze` and verify 0 deprecated_member_use warnings
'@

Set-Content -Path ".claude\rules\ui-rules.md" -Value $uiRules -Encoding UTF8
Write-Host "✅ rules/ui-rules.md created" -ForegroundColor Green

# =============================================================
# .claude/settings.json
# =============================================================
$settingsJson = @'
{
  "permissions": {
    "allow": [
      "Bash(flutter pub get)",
      "Bash(flutter run*)",
      "Bash(flutter test*)",
      "Bash(flutter analyze)",
      "Bash(flutter pub run build_runner*)",
      "Bash(dart format*)",
      "Bash(git status)",
      "Bash(git diff*)",
      "Bash(git log*)",
      "Bash(git add*)",
      "Bash(git commit*)",
      "Read(**)",
      "Write(**)",
      "Edit(**)"
    ],
    "deny": [
      "Bash(rm -rf*)",
      "Bash(git push --force*)",
      "Bash(firebase deploy*)",
      "Bash(cat .env*)",
      "Bash(type .env*)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/auto-format.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/enforce-analyze.sh"
          }
        ]
      }
    ]
  }
}
'@

Set-Content -Path ".claude\settings.json" -Value $settingsJson -Encoding UTF8
Write-Host "✅ settings.json created" -ForegroundColor Green

# =============================================================
# .claude/hooks/enforce-analyze.sh
# =============================================================
$enforceAnalyze = @'
#!/bin/bash
# Stop hook: prevents Claude from declaring "done" if flutter analyze has issues
# Exit codes: 0 = pass, 2 = block + send error to Claude for self-correction

STOP_HOOK_ACTIVE=$(cat | jq -r '.stop_hook_active // false')

# Prevent infinite loop — if already retrying, let Claude stop
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

echo "🔍 Running flutter analyze..."
OUTPUT=$(flutter analyze 2>&1)
echo "$OUTPUT"

if echo "$OUTPUT" | grep -qE "error •|warning •|info •"; then
  echo "" >&2
  echo "❌ flutter analyze found issues — fix all errors/warnings/info before finishing!" >&2
  echo "Run: flutter analyze" >&2
  exit 2
fi

echo "✅ flutter analyze passed — no issues found"
exit 0
'@

Set-Content -Path ".claude\hooks\enforce-analyze.sh" -Value $enforceAnalyze -Encoding UTF8
Write-Host "✅ hooks/enforce-analyze.sh created" -ForegroundColor Green

# =============================================================
# .claude/hooks/auto-format.sh
# =============================================================
$autoFormat = @'
#!/bin/bash
# PostToolUse hook: runs dart format on every .dart file Claude edits

FILE_PATH=$(cat | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then exit 0; fi

if [[ "$FILE_PATH" =~ \.dart$ ]]; then
  dart format "$FILE_PATH" 2>/dev/null
  echo "✅ Formatted: $FILE_PATH"
fi

exit 0
'@

Set-Content -Path ".claude\hooks\auto-format.sh" -Value $autoFormat -Encoding UTF8
Write-Host "✅ hooks/auto-format.sh created" -ForegroundColor Green

# =============================================================
# .claude/skills/new-feature/SKILL.md
# =============================================================
$newFeatureSkill = @'
# Skill: New Feature — Speckit Lifecycle

## Trigger
Activate when asked to implement any new feature, improvement, or significant refactor.

## Mandatory Steps (in order — NEVER skip)

1. Check `.specify/specs/[feature]/spec.md`
   - If NOT present → STOP. Tell user to run `/speckit.specify` first.

2. Check `.specify/specs/[feature]/plan.md`
   - If NOT present → STOP. Tell user to run `/speckit.plan` first.

3. If spec/plan exist but anything is ambiguous → run `/speckit.clarify`

4. After plan is approved → run `/speckit.checklist`

5. After tasks are defined → run `/speckit.analyze` before implementing

6. Only after ALL above steps → run `/speckit.implement`

## Implementation Checklist (verify every item before marking done)

### Firebase & DI
- [ ] Uses injected `_firestore` or `FirebaseFirestore.instanceFor(databaseId: 'elajtech')`
- [ ] New service/repository has `@lazySingleton()` or `@injectable()`
- [ ] build_runner executed after any DI/freezed/JsonSerializable change
- [ ] New service appears in `injection_container.config.dart`
- [ ] Constructor dependencies are also registered in DI

### Code Safety
- [ ] Null checks on `authProvider.user` — NO `!` operator used
- [ ] Lists checked with `.isNotEmpty` before `.first`
- [ ] `Either<Failure, T>` returned from all repository methods
- [ ] `fromFirestore` validates snapshot before parsing

### Logging & Observability
- [ ] Debug logging (`if (kDebugMode)`) on all Firestore writes
- [ ] Logged: userId, patientId, appointmentId where applicable

### Testing
- [ ] Unit tests written for happy path
- [ ] Unit tests written for failure/edge cases
- [ ] Widget tests written if new screen/widget added
- [ ] All 700+ existing tests still passing

### Final Quality Gate
- [ ] `flutter analyze` returns ZERO errors, warnings, and info messages
- [ ] `dart format lib/ test/` applied
- [ ] No deprecated APIs used
'@

Set-Content -Path ".claude\skills\new-feature\SKILL.md" -Value $newFeatureSkill -Encoding UTF8
Write-Host "✅ skills/new-feature/SKILL.md created" -ForegroundColor Green

# =============================================================
# .claude/skills/code-review/SKILL.md
# =============================================================
$codeReviewSkill = @'
# Skill: Code Review

## Trigger
Activate when asked to review code, a PR, a file, or any Dart/Flutter changes.

## Review Process

Run through every category below. Report each item explicitly.

### 1. Firebase & DI Safety
- [ ] No `FirebaseFirestore.instance` usage
- [ ] No `FirebaseFunctions.instance` (must use `region: 'europe-west1'`)
- [ ] Every new service has DI annotation (`@lazySingleton`/`@injectable`)
- [ ] Service is registered in `injection_container.config.dart`
- [ ] No `GetIt.I<T>()` called before `configureDependencies()` completes

### 2. Null Safety
- [ ] No `authProvider.user!` — null check must precede usage
- [ ] No `.first` on lists without `.isNotEmpty` guard

### 3. Data Layer
- [ ] `fromFirestore` checks `snapshot.exists && snapshot.data() != null`
- [ ] `fromFirestore` has try-catch with `debugPrint(stackTrace.toString())`
- [ ] Repository methods return `Either<Failure, T>`
- [ ] No raw Firebase exceptions leaking to presentation layer

### 4. Architecture
- [ ] Clinic isolation maintained (no merged specialty repositories)
- [ ] Domain layer has no Flutter imports
- [ ] Business logic is NOT in presentation layer

### 5. Auth & Routing
- [ ] Unknown `userType` has safe fallback (no crash)
- [ ] `isActive == false` blocks user with Arabic error message

### 6. Testing
- [ ] New code has unit tests (happy path + failure)
- [ ] No existing test was broken
- [ ] Auth changes have corresponding test coverage

### 7. Code Quality
- [ ] `flutter analyze` returns 0 issues
- [ ] No deprecated APIs (`withOpacity`, old Radio, etc.)
- [ ] Public classes/methods have bilingual DartDoc (Arabic + English)
- [ ] Phone numbers use E.164 format

## Output Format
```
## Review Summary

✅ Passed: [item description]
⚠️ Warning: [item] — [explanation, non-blocking]
🚫 Violation: [item] — [exact fix required, blocking]

## Verdict
APPROVED / CHANGES REQUIRED
```
'@

Set-Content -Path ".claude\skills\code-review\SKILL.md" -Value $codeReviewSkill -Encoding UTF8
Write-Host "✅ skills/code-review/SKILL.md created" -ForegroundColor Green

# =============================================================
# .claude/agents/flutter-reviewer.md
# =============================================================
$flutterReviewer = @'
# Agent: Elajtech Flutter Code Reviewer

## Persona
You are a senior Flutter/Firebase engineer with deep knowledge of the Elajtech/AndroCare360 codebase.
You enforce project rules strictly and constructively.
You know every rule in `important-rules.md`, `CLAUDE.md`, and all `.claude/rules/` files.

## Behavior
- Review every item in the checklist — never skip
- Flag violations immediately with the exact fix required
- Be constructive: explain WHY each rule exists
- Block approval until all 🚫 violations are resolved

## Full Review Checklist

### Firebase & DI
- [ ] No `FirebaseFirestore.instance` — must use injected instance or `instanceFor(databaseId: 'elajtech')`
- [ ] No `FirebaseFunctions.instance` — must use `instanceFor(region: 'europe-west1')`
- [ ] Every new service has `@lazySingleton()` or `@injectable()`
- [ ] Service appears in `injection_container.config.dart`
- [ ] No service used before `configureDependencies()` completes

### Null & Type Safety
- [ ] No `authProvider.user!` — null check must come first
- [ ] No `.first` on lists without `.isNotEmpty` guard
- [ ] No `late final` for variables that can be initialized immediately

### Data Layer
- [ ] `fromFirestore` validates `snapshot.exists` and `snapshot.data() != null`
- [ ] `fromFirestore` has try-catch with `debugPrint(e)` and `debugPrint(stackTrace)`
- [ ] Repository methods return `Either<Failure, T>` — no raw returns

### Architecture
- [ ] Clinic isolation: each specialty has its own Model + Repository file
- [ ] Domain layer imports are pure Dart — no Flutter/Firebase imports
- [ ] Presentation layer contains NO business logic

### Auth & Routing
- [ ] `AuthWrapper` handles unknown `userType` with safe fallback + logging
- [ ] `isActive == false` blocked at all layers with Arabic error message

### Tests
- [ ] New features have unit tests (happy path + failure cases)
- [ ] Zero regressions in 700+ test suite
- [ ] Auth-related changes have test coverage for all new scenarios

### Code Quality
- [ ] `flutter analyze` returns 0 issues (errors + warnings + info)
- [ ] No deprecated APIs used
- [ ] Public classes/methods have bilingual DartDoc (Arabic + English)
- [ ] All Firestore writes have `if (kDebugMode) debugPrint(...)` logging

## Output Format
```
## Code Review — [Feature/File Name]

### Firebase & DI
✅ Firestore instance correctly injected via DI
🚫 VIOLATION: `FirebaseFunctions.instance` used in call_service.dart:42
   FIX: Replace with `FirebaseFunctions.instanceFor(region: 'europe-west1')`

### [Category]
...

## Final Verdict
🚫 CHANGES REQUIRED — [N] violations must be fixed before merge
```
'@

Set-Content -Path ".claude\agents\flutter-reviewer.md" -Value $flutterReviewer -Encoding UTF8
Write-Host "✅ agents/flutter-reviewer.md created" -ForegroundColor Green

# =============================================================
# Add CLAUDE.local.md to .gitignore (if .gitignore exists)
# =============================================================
if (Test-Path ".gitignore") {
    $gitignore = Get-Content ".gitignore"
    $entriesToAdd = @()

    if (-not ($gitignore -contains "CLAUDE.local.md")) {
        $entriesToAdd += "CLAUDE.local.md"
    }
    if (-not ($gitignore -contains ".claude/settings.local.json")) {
        $entriesToAdd += ".claude/settings.local.json"
    }

    if ($entriesToAdd.Count -gt 0) {
        Add-Content -Path ".gitignore" -Value ""
        Add-Content -Path ".gitignore" -Value "# Claude local overrides"
        foreach ($entry in $entriesToAdd) {
            Add-Content -Path ".gitignore" -Value $entry
        }
        Write-Host "✅ Added CLAUDE.local.md and settings.local.json to .gitignore" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  .gitignore entries already present" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  No .gitignore found — add CLAUDE.local.md manually" -ForegroundColor Yellow
}

# =============================================================
# Final summary
# =============================================================
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "✅ All files created successfully!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files created:" -ForegroundColor White
Write-Host "  📄 CLAUDE.md" -ForegroundColor Yellow
Write-Host "  📄 CLAUDE.local.md (gitignored)" -ForegroundColor Yellow
Write-Host "  ⚙️  .claude/settings.json" -ForegroundColor Yellow
Write-Host "  🔥 .claude/rules/firebase-safety.md" -ForegroundColor Yellow
Write-Host "  🧪 .claude/rules/testing.md" -ForegroundColor Yellow
Write-Host "  🏗️  .claude/rules/architecture.md" -ForegroundColor Yellow
Write-Host "  🎨 .claude/rules/ui-rules.md" -ForegroundColor Yellow
Write-Host "  🪝 .claude/hooks/enforce-analyze.sh" -ForegroundColor Yellow
Write-Host "  🪝 .claude/hooks/auto-format.sh" -ForegroundColor Yellow
Write-Host "  ⚡ .claude/skills/new-feature/SKILL.md" -ForegroundColor Yellow
Write-Host "  ⚡ .claude/skills/code-review/SKILL.md" -ForegroundColor Yellow
Write-Host "  🤖 .claude/agents/flutter-reviewer.md" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Open Claude Code in this project" -ForegroundColor White
Write-Host "  2. Type /memory to verify Claude loaded the rules" -ForegroundColor White
Write-Host "  3. The hooks require 'jq' on WSL/Git Bash to work" -ForegroundColor White
Write-Host "     Install: https://stedolan.github.io/jq/" -ForegroundColor White
Write-Host ""