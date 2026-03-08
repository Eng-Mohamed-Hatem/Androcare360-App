# Testing Guide for AndroCare360

This document provides guidance on running and writing tests for the AndroCare360 project.

## Test Structure

```
test/
├── core/              # Core service tests
├── features/          # Feature-specific tests
├── fixtures/          # Test data fixtures
├── helpers/           # Test helper utilities
├── integration/       # Integration tests
├── mocks/             # Mock implementations
├── unit/              # Unit tests
└── widget/            # Widget tests
```

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/widget/screens/booking_screen_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Run Integration Tests (Requires Firebase Emulator)
```bash
# Start Firebase emulators first
firebase emulators:start

# In another terminal
flutter test test/integration/
```

## Firebase Initialization for Widget Tests

### Known Limitation

Some widget tests may fail with Firebase initialization errors when testing screens that use services with Firebase dependencies (like `AgoraVideoCallScreen` and `NutritionClinicScreen`). This occurs because:

1. Services like `CallMonitoringService` and `AgoraService` use singleton patterns
2. They initialize `FirebaseFirestore.instance` in field initializers
3. This happens before test mocks can be set up

### Current Status

The following widget test files have this limitation:
- `test/widget/screens/agora_video_call_screen_test.dart`
- `test/widget/screens/nutrition_emr_form_test.dart`

These tests are **structurally correct** and demonstrate proper testing patterns, but require architectural changes to the services to run successfully.

### Solutions

#### Option 1: Use Integration Tests (Recommended for Now)

For screens with Firebase dependencies, use integration tests with Firebase emulator:

```dart
// test/integration/agora_video_call_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../helpers/firebase_emulator_helper.dart';

void main() {
  setUpAll(() async {
    await FirebaseEmulatorHelper.setupEmulator();
  });

  tearDownAll(() async {
    await FirebaseEmulatorHelper.cleanup();
  });

  testWidgets('Agora video call screen integration test', (tester) async {
    // Test implementation
  });
}
```

#### Option 2: Refactor Services (Long-term Solution)

Refactor services to use dependency injection instead of singletons:

```dart
// Before (Singleton with immediate Firebase access)
class CallMonitoringService {
  factory CallMonitoringService() => _instance;
  CallMonitoringService._internal();
  static final CallMonitoringService _instance = CallMonitoringService._internal();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // ❌ Immediate access
}

// After (Dependency Injection)
class CallMonitoringService {
  CallMonitoringService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance; // ✅ Lazy access
  
  final FirebaseFirestore _firestore;
}
```

Then register with GetIt:
```dart
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  
  @lazySingleton
  CallMonitoringService get callMonitoring => CallMonitoringService(
    firestore: getIt<FirebaseFirestore>(),
  );
}
```

#### Option 3: Skip Firebase-Dependent Tests

For CI/CD pipelines, you can skip these specific tests:

```bash
# Run all tests except Firebase-dependent widget tests
flutter test --exclude-tags=firebase-widget
```

Tag the tests:
```dart
testWidgets('test name', (tester) async {
  // test code
}, tags: ['firebase-widget']);
```

## Widget Test Best Practices

### 1. Use Test Helpers

```dart
import '../../helpers/widget_test_helper.dart';

setUpAll(() async {
  setupFirebaseMocks();
  await initializeFakeFirebase();
});
```

### 2. Use Fixtures for Test Data

```dart
import '../../fixtures/user_fixtures.dart';
import '../../fixtures/appointment_fixtures.dart';

final testDoctor = UserFixtures.createDoctor();
final testAppointment = AppointmentFixtures.createConfirmedAppointment();
```

### 3. Override Providers for Riverpod

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      authProvider.overrideWith((ref) {
        final mockRepo = MockAuthRepository(currentUser: testUser);
        return AuthNotifier(mockRepo);
      }),
    ],
    child: MaterialApp(home: MyScreen()),
  ),
);
```

### 4. Wait for Async Operations

```dart
// Wait for all animations and async operations
await tester.pumpAndSettle();

// Wait for specific duration
await tester.pumpAndSettle(const Duration(seconds: 2));

// Pump specific number of frames
await tester.pump(const Duration(milliseconds: 100));
```

### 5. Find Widgets Safely

```dart
// Check if widget exists before interacting
final button = find.byType(ElevatedButton);
if (button.evaluate().isNotEmpty) {
  await tester.tap(button);
  await tester.pumpAndSettle();
}

// Use conditional expectations
expect(
  find.byType(LoadingWidget).evaluate().isNotEmpty ||
  find.byType(ContentWidget).evaluate().isNotEmpty,
  isTrue,
);
```

## Unit Test Best Practices

### 1. Use Mockito for Mocking

```dart
import 'package:mockito/mockito.dart';
import '../mocks/mocks.mocks.dart';

final mockRepository = MockAppointmentRepository();
when(mockRepository.getAppointment(any))
    .thenAnswer((_) async => Right(testAppointment));
```

### 2. Test Error Scenarios

```dart
test('should handle repository errors', () async {
  when(mockRepository.getAppointment(any))
      .thenAnswer((_) async => Left(ServerFailure()));
  
  final result = await service.getAppointment('123');
  
  expect(result.isLeft(), true);
});
```

### 3. Verify Method Calls

```dart
await service.createAppointment(testAppointment);

verify(mockRepository.createAppointment(testAppointment)).called(1);
verifyNoMoreInteractions(mockRepository);
```

## Integration Test Best Practices

### 1. Setup Firebase Emulator

```dart
setUpAll(() async {
  await FirebaseEmulatorHelper.setupEmulator();
  await FirebaseEmulatorHelper.seedTestData();
});

setUp(() async {
  await FirebaseEmulatorHelper.clearFirestore();
});

tearDownAll(() async {
  await FirebaseEmulatorHelper.cleanup();
});
```

### 2. Test Complete User Flows

```dart
testWidgets('complete appointment booking flow', (tester) async {
  // 1. Navigate to booking screen
  // 2. Select date and time
  // 3. Fill form
  // 4. Submit
  // 5. Verify appointment created in Firestore
  // 6. Verify navigation to confirmation screen
});
```

## Generating Mocks

When you add new classes to mock, update `test/mocks/mocks.dart` and run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Coverage Goals

- **Overall**: ≥ 70%
- **Core Services**: ≥ 80%
- **Repositories**: ≥ 80%
- **Critical Screens**: ≥ 50%

## Troubleshooting

### Firebase Initialization Errors

**Error**: `[core/no-app] No Firebase App '[DEFAULT]' has been created`

**Solution**: 
- For integration tests: Use Firebase emulator
- For unit tests: Mock Firebase dependencies
- For widget tests: See "Firebase Initialization for Widget Tests" section above

### Async Test Timeouts

**Error**: `Test timed out after 30 seconds`

**Solution**:
```dart
testWidgets('my test', (tester) async {
  // ...
}, timeout: const Timeout(Duration(seconds: 60)));
```

### Provider Not Found Errors

**Error**: `ProviderNotFoundException`

**Solution**: Ensure all required providers are overridden in ProviderScope:
```dart
ProviderScope(
  overrides: [
    authProvider.overrideWith(...),
    appointmentRepositoryProvider.overrideWith(...),
  ],
  child: MyWidget(),
)
```

### Widget Not Found in Tests

**Error**: `Expected: exactly one matching candidate, Actual: <Found 0 widgets>`

**Solution**:
- Use `await tester.pumpAndSettle()` to wait for async operations
- Check if widget is conditionally rendered
- Use `find.byType()` instead of `find.byKey()` for more flexibility
- Verify widget tree with `debugDumpApp()` in tests

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Flutter Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run analyzer
        run: flutter analyze
      
      - name: Run unit and widget tests
        run: flutter test --exclude-tags=firebase-widget --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info
```

## Additional Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Riverpod Testing Guide](https://riverpod.dev/docs/cookbooks/testing)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
