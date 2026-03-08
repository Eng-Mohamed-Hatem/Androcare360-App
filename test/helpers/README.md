# Integration Test Helpers

This directory contains helper utilities for integration testing with Firebase Emulators.

## Prerequisites

Before running integration tests, ensure you have:

1. **Firebase CLI** installed (v15.2.1+)
   ```bash
   npm install -g firebase-tools
   ```

2. **Java 21+** installed (required for Cloud Functions emulator)
   ```bash
   java -version
   # Should show: openjdk version "21.0.10" or higher
   ```

3. **Firebase Emulators** configured in `firebase.json`:
   - Firestore: port 8080
   - Authentication: port 9099
   - Functions: port 5001
   - Emulator UI: port 4000

## Starting Emulators

### Option 1: Start in Background (Recommended for CI/CD)

```bash
# Start emulators in background
firebase emulators:start &

# Or on Windows PowerShell
Start-Process firebase -ArgumentList "emulators:start" -NoNewWindow
```

### Option 2: Start in Separate Terminal

```bash
# In a separate terminal window
firebase emulators:start
```

### Verify Emulators are Running

Check that all emulators are accessible:

- Firestore: http://localhost:8080
- Authentication: http://localhost:9099
- Functions: http://localhost:5001
- Emulator UI: http://localhost:4000

## Using Integration Test Config

### Basic Setup

```dart
import 'package:flutter_test/flutter_test.dart';
import '../helpers/integration_test_config.dart';

void main() {
  setUpAll(() async {
    // Connect to Firebase Emulators
    await IntegrationTestConfig.connectToEmulators();
  });

  tearDownAll(() async {
    // Cleanup after all tests
    await IntegrationTestConfig.cleanup();
  });

  test('example integration test', () async {
    // Your test code here
    final firestore = IntegrationTestConfig.getFirestore();
    final functions = IntegrationTestConfig.getFunctions();
    final auth = IntegrationTestConfig.getAuth();
    
    // Test logic...
  });
}
```

### Creating Test Users

```dart
// Create a test user
final doctorUid = await IntegrationTestConfig.createTestUser(
  email: 'doctor@test.com',
  password: 'password123',
  displayName: 'Dr. Test',
);

// Sign in the test user
final user = await IntegrationTestConfig.signInTestUser(
  email: 'doctor@test.com',
  password: 'password123',
);
```

### Creating Test Data

```dart
// Create a test appointment
await IntegrationTestConfig.createTestDocument(
  collection: 'appointments',
  documentId: 'apt_test_001',
  data: {
    'doctorId': doctorUid,
    'patientId': patientUid,
    'status': 'confirmed',
    'scheduledAt': FieldValue.serverTimestamp(),
  },
);
```

### Clearing Data Between Tests

```dart
setUp(() async {
  // Clear data before each test
  await IntegrationTestConfig.clearFirestoreData();
  await IntegrationTestConfig.signOutAllUsers();
});
```

## Database Isolation

**CRITICAL LIMITATION**: Firebase Emulators do NOT support custom database IDs.

### Production vs Emulator Database Configuration

| Environment | Database ID | Configuration |
|-------------|-------------|---------------|
| **Production** | `elajtech` | `FirebaseFirestore.instanceFor(databaseId: 'elajtech')` |
| **Emulator** | `(default)` | `FirebaseFirestore.instance` |

### Why This Matters

In production, AndroCare360 uses a custom Firestore database with ID `elajtech`. However, Firebase Emulators only support the default database `(default)`.

**What This Means for Testing**:
- ✅ Integration tests run against the emulator's default database
- ✅ Tests still validate business logic and data flow
- ✅ Database isolation is maintained (emulator data is separate from production)
- ⚠️ Tests cannot verify the `databaseId: 'elajtech'` configuration itself
- ⚠️ Production database targeting must be verified through other means (unit tests, property tests)

### How We Handle This

The `IntegrationTestConfig` helper automatically:
1. Connects to the emulator's default database
2. Logs a warning that emulators use `(default)` instead of `elajtech`
3. Provides clear documentation about this limitation

```dart
// In integration tests (emulator)
final firestore = IntegrationTestConfig.getFirestore();
// Returns: FirebaseFirestore.instance (connected to emulator's default database)

// In production code
final firestore = FirebaseFirestore.instanceFor(
  app: Firebase.app(),
  databaseId: 'elajtech',
);
// Uses: Custom 'elajtech' database
```

### Verifying Database Configuration

Since emulators can't test the `databaseId` configuration, we verify it through:

1. **Unit Tests**: Mock Firestore and verify `databaseId: 'elajtech'` is used
2. **Property Tests**: Test database targeting consistency (see `functions/test/database-targeting-consistency.property.test.js`)
3. **Code Reviews**: Ensure all Firestore instances use correct database ID
4. **Production Monitoring**: Monitor actual database usage in production

### References

- [Firebase Emulator Limitations](https://firebase.google.com/docs/emulator-suite/connect_firestore#limitations)
- [CONTRIBUTING.md - Database ID Rule](../../CONTRIBUTING.md#1-firestore-database-configuration)

## Troubleshooting

### Emulators Not Running

**Error**: `Emulators not accessible`

**Solution**:
```bash
# Check if emulators are running
firebase emulators:start

# Or verify ports are accessible
curl http://localhost:8080
curl http://localhost:9099
curl http://localhost:5001
curl http://localhost:4000
```

### Connection Refused

**Error**: `Connection refused to localhost:8080`

**Solution**:
1. Ensure emulators are started: `firebase emulators:start`
2. Check firewall settings allow localhost connections
3. Verify ports are not in use by other applications

### Java Not Found

**Error**: `Java is not installed or not in PATH`

**Solution**:
1. Install Java 21+: https://adoptium.net/
2. Add Java to PATH
3. Verify: `java -version`

### Wrong Database ID

**Error**: `Document not found` or `Collection not found`

**Solution**:
- Always use `IntegrationTestConfig.getFirestore()` to get Firestore instance
- Never use `FirebaseFirestore.instance` directly in integration tests
- The helper ensures correct database ID (`elajtech`) is used

## Best Practices

1. **Always connect to emulators first**:
   ```dart
   setUpAll(() async {
     await IntegrationTestConfig.connectToEmulators();
   });
   ```

2. **Clean up after tests**:
   ```dart
   tearDownAll(() async {
     await IntegrationTestConfig.cleanup();
   });
   ```

3. **Clear data between tests**:
   ```dart
   setUp(() async {
     await IntegrationTestConfig.clearFirestoreData();
   });
   ```

4. **Use helper methods**:
   - `getFirestore()` - Get Firestore instance
   - `getFunctions()` - Get Functions instance
   - `getAuth()` - Get Auth instance
   - `createTestUser()` - Create test users
   - `createTestDocument()` - Create test data

5. **Verify emulators before running tests**:
   ```dart
   final running = await IntegrationTestConfig.verifyEmulatorsRunning();
   if (!running) {
     throw StateError('Emulators not running. Start with: firebase emulators:start');
   }
   ```

## CI/CD Integration

For automated testing in CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Start Firebase Emulators
  run: firebase emulators:start &
  
- name: Wait for Emulators
  run: sleep 10
  
- name: Run Integration Tests
  run: flutter test test/integration/
  
- name: Stop Emulators
  run: pkill -f "firebase emulators"
```

## References

- [Firebase Emulator Suite Documentation](https://firebase.google.com/docs/emulator-suite)
- [README.md - Firebase Emulator Setup](../../README.md#firebase-emulator-setup)
- [CONTRIBUTING.md - Testing Requirements](../../CONTRIBUTING.md#testing-requirements)
