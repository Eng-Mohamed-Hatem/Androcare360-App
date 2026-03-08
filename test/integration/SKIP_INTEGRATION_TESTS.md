# Integration Tests - Firebase Emulator Required

## ⚠️ Important Notice

All integration tests in this directory require Firebase Emulator to be running.
They are currently **failing** because the emulator is not set up.

## Current Status

- **Total Integration Tests**: 11
- **Status**: Failing (require emulator)
- **Recommendation**: Skip in CI, run manually with emulator

## Test Files

1. `appointment_booking_test.dart` - 3 tests
2. `emr_workflow_test.dart` - 5 tests  
3. `video_call_flow_test.dart` - 3 tests

## How to Run Integration Tests

### Prerequisites

1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Initialize Firebase in project (if not done):
   ```bash
   firebase init emulators
   ```
   Select: Firestore, Authentication, Functions

### Running Tests

1. Start Firebase Emulator:
   ```bash
   firebase emulators:start
   ```

2. In another terminal, run integration tests:
   ```bash
   flutter test test/integration/
   ```

## Skipping Integration Tests in CI

Add to your CI configuration:

```yaml
# GitHub Actions example
- name: Run Unit Tests Only
  run: flutter test --exclude-tags=integration
```

Or exclude the integration directory:

```yaml
- name: Run Unit Tests Only
  run: flutter test --exclude-path=test/integration/
```

## Alternative: Mark as @Tags

You can add tags to integration tests:

```dart
@Tags(['integration', 'requires-emulator'])
void main() {
  // tests...
}
```

Then run:
```bash
# Run only unit tests
flutter test --exclude-tags=integration

# Run only integration tests
flutter test --tags=integration
```

## Current Workaround

For now, integration tests are documented but not blocking the main test suite.
Unit tests provide 94%+ pass rate (390+ passing tests).

## Future Work

- Set up Firebase Emulator in CI/CD pipeline
- Create emulator startup script
- Add integration test documentation
- Consider converting some to unit tests with mocks
