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
