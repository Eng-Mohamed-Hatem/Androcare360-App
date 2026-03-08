# Firebase Emulator Database ID Limitation

## Issue

Firebase Emulators do NOT support custom Firestore database IDs. They only work with the default database `(default)`.

## Impact on AndroCare360

AndroCare360 uses a custom Firestore database with ID `elajtech` in production, but integration tests with emulators must use the default database.

## Configuration Comparison

| Environment | Database ID | Configuration |
|-------------|-------------|---------------|
| **Production** | `elajtech` | `FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'elajtech')` |
| **Emulator** | `(default)` | `FirebaseFirestore.instance` |

## What This Means

### ✅ What Integration Tests CAN Verify

- Business logic correctness
- Data flow between components
- Cloud Functions execution
- Authentication flows
- FCM notification handling
- Error handling and edge cases
- End-to-end workflows

### ⚠️ What Integration Tests CANNOT Verify

- The `databaseId: 'elajtech'` configuration itself
- That production code targets the correct database
- Database isolation between `elajtech` and `(default)`

## How We Handle This

### 1. Integration Tests (Emulator)

Use the default database for functional testing:

```dart
// test/helpers/integration_test_config.dart
static FirebaseFirestore getFirestore() {
  // Returns FirebaseFirestore.instance (default database)
  return FirebaseFirestore.instance;
}
```

### 2. Unit Tests (Mocked)

Verify database ID configuration with mocks:

```dart
test('repository uses elajtech database', () {
  final mockFirestore = MockFirebaseFirestore();
  
  // Verify instanceFor called with correct databaseId
  verify(FirebaseFirestore.instanceFor(
    app: any,
    databaseId: 'elajtech',
  ));
});
```

### 3. Property Tests (Cloud Functions)

Verify Cloud Functions target correct database:

```javascript
// functions/test/database-targeting-consistency.property.test.js
test('all Firestore operations target elajtech database', () => {
  // Verify db.settings({ databaseId: 'elajtech' }) is applied
  expect(db._settings.databaseId).toBe('elajtech');
});
```

### 4. Code Reviews

Manual verification that all Firestore instances use:
```dart
FirebaseFirestore.instanceFor(
  app: Firebase.app(),
  databaseId: 'elajtech',
)
```

### 5. Production Monitoring

Monitor actual database usage in production to ensure correct targeting.

## Implementation Details

### Before (Incorrect)

```dart
// ❌ This doesn't work with emulators
static Future<void> connectToEmulators() async {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech', // ❌ Emulators don't support this
  );
  firestore.useFirestoreEmulator('localhost', 8080);
}
```

**Result**: 
```
🔧 [INIT] Firestore Database ID: (default)
❌ [CRITICAL] Firestore database ID configuration FAILED!
```

### After (Correct)

```dart
// ✅ This works with emulators
static Future<void> connectToEmulators() async {
  final firestore = FirebaseFirestore.instance; // ✅ Use default
  firestore.useFirestoreEmulator('localhost', 8080);
  
  print('🔧 [INIT] Firestore Database ID: (default)');
  print('⚠️  [NOTE] Emulators use (default) database, not elajtech');
}
```

**Result**:
```
✅ [FIRESTORE] Connected to emulator: localhost:8080
🔧 [INIT] Firestore Database ID: (default)
⚠️  [NOTE] Emulators use (default) database, not elajtech
```

## Testing Strategy

### Layer 1: Integration Tests (Emulator)
- **Purpose**: Validate business logic and workflows
- **Database**: `(default)` (emulator limitation)
- **Coverage**: End-to-end flows, error handling, edge cases

### Layer 2: Unit Tests (Mocked)
- **Purpose**: Verify database ID configuration
- **Database**: Mocked with `databaseId: 'elajtech'`
- **Coverage**: Repository initialization, DI setup

### Layer 3: Property Tests (Cloud Functions)
- **Purpose**: Verify Cloud Functions database targeting
- **Database**: Verify `db.settings({ databaseId: 'elajtech' })`
- **Coverage**: All Firestore operations in functions

### Layer 4: Production Monitoring
- **Purpose**: Verify actual database usage
- **Database**: Monitor `elajtech` database metrics
- **Coverage**: Real-world usage patterns

## References

- [Firebase Emulator Limitations](https://firebase.google.com/docs/emulator-suite/connect_firestore#limitations)
- [CONTRIBUTING.md - Database ID Rule](../../CONTRIBUTING.md#1-firestore-database-configuration)
- [test/helpers/README.md - Database Isolation](README.md#database-isolation)
- [test/integration/README.md - Database ID Limitation](../integration/README.md#database-id-limitation)

## Conclusion

This is a **known limitation** of Firebase Emulators, not a bug in our code. We've implemented a comprehensive testing strategy that:

1. ✅ Uses emulators for functional testing (business logic)
2. ✅ Uses unit tests to verify database ID configuration
3. ✅ Uses property tests to verify Cloud Functions database targeting
4. ✅ Documents the limitation clearly
5. ✅ Provides monitoring for production verification

The integration tests are still valuable for validating workflows and business logic, even though they can't verify the specific database ID configuration.

---

**Last Updated**: 2026-02-19  
**Status**: Documented and Resolved  
**Impact**: Low (limitation is understood and mitigated)
