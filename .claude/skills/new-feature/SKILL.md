# Skill: New Feature — Speckit Lifecycle

## Trigger
Activate when asked to implement any new feature, improvement, or significant refactor.

## Mandatory Steps (in order — NEVER skip)

1. Check `.specify/specs/[feature]/spec.md`
   - If NOT present → STOP. Tell user to run `/speckit.specify` first.

2. Check `.specify/specs/[feature]/plan.md`
   - If NOT present → STOP. Tell user to run `/speckit.plan` first.

3. If spec/plan exist but anything is ambiguous → suggest `/speckit.clarify`

4. After plan is approved → run `/speckit.checklist`

5. After tasks are defined → run `/speckit.analyze` before implementing

6. Only after ALL above steps → run `/speckit.implement`

---

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
- [ ] `fromFirestore` has try-catch with `debugPrint(stackTrace.toString())`

### Logging & Observability
- [ ] Debug logging (`if (kDebugMode)`) on all Firestore writes
- [ ] Logged: userId, patientId, appointmentId where applicable

### Auth & Routing
- [ ] Unknown `userType` has safe fallback — never crashes
- [ ] `isActive == false` blocked with Arabic error message at all layers

### Clinic Isolation
- [ ] New specialty clinic has its own independent Model + Repository file
- [ ] No logic merged with other specialties

### Testing
- [ ] Unit tests written for happy path
- [ ] Unit tests written for failure/edge cases
- [ ] Widget tests written if new screen/widget added
- [ ] All 700+ existing tests still passing (`flutter test`)

### Final Quality Gate
- [ ] `flutter analyze` returns ZERO errors, warnings, and info messages
- [ ] `dart format lib/ test/` applied
- [ ] No deprecated APIs used (`withOpacity` etc.)
- [ ] Bilingual DartDoc on all new public classes/methods
