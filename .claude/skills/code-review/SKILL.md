# Skill: Code Review

## Trigger
Activate when asked to review code, a PR, a file, or any Dart/Flutter changes.

## Review Process
Run through every category below. Report each item explicitly. Never skip.

---

### 1. Firebase & DI Safety
- [ ] No `FirebaseFirestore.instance` usage anywhere
- [ ] No `FirebaseFunctions.instance` — must use `region: 'europe-west1'`
- [ ] Every new service has `@lazySingleton()` or `@injectable()`
- [ ] Service is registered in `injection_container.config.dart`
- [ ] No `GetIt.I<T>()` called before `configureDependencies()` completes

### 2. Null & Type Safety
- [ ] No `authProvider.user!` — null check must precede usage
- [ ] No `.first` on lists without `.isNotEmpty` guard
- [ ] No `late final` for variables that can be initialized immediately

### 3. Data Layer
- [ ] `fromFirestore` checks `snapshot.exists && snapshot.data() != null`
- [ ] `fromFirestore` has try-catch with `debugPrint(e)` + `debugPrint(stackTrace)`
- [ ] Repository methods return `Either<Failure, T>`
- [ ] No raw Firebase exceptions leaking to presentation layer

### 4. Architecture
- [ ] Clinic isolation maintained — no merged specialty repositories
- [ ] Domain layer has no Flutter/Firebase imports
- [ ] Business logic is NOT in presentation layer

### 5. Auth & Routing
- [ ] Unknown `userType` has safe fallback (no crash, logs the value)
- [ ] `isActive == false` blocks user with Arabic error message

### 6. Testing
- [ ] New code has unit tests (happy path + failure)
- [ ] Zero regressions — no existing test was broken
- [ ] Auth changes have corresponding test coverage

### 7. Code Quality
- [ ] `flutter analyze` returns 0 issues (errors + warnings + info)
- [ ] No deprecated APIs (`withOpacity`, old Radio, etc.)
- [ ] Public classes/methods have bilingual DartDoc (Arabic + English)
- [ ] Phone numbers use E.164 format
- [ ] All Firestore writes have `if (kDebugMode) debugPrint(...)` logging

---

## Output Format
```
## Review Summary

✅ Passed: [item description]
⚠️ Warning: [item] — [explanation, non-blocking]
🚫 Violation: [item] — [exact fix required, blocking]

## Verdict
APPROVED / CHANGES REQUIRED — [N violations must be fixed]
```
