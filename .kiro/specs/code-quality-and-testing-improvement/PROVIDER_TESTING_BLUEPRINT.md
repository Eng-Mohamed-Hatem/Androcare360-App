# Provider Testing Blueprint 📘

## Overview

This document serves as a comprehensive guide for testing Riverpod providers and StateNotifiers in the AndroCare360 project. It consolidates patterns, best practices, and lessons learned from Phase 4 testing.

**Target Audience**: Developers implementing tests for remaining providers (AppointmentsProvider, etc.)

---

## Quick Start Checklist

Before writing tests for a new provider:

- [ ] Read this blueprint
- [ ] Identify provider dependencies (repositories, services)
- [ ] Check for platform dependencies (biometrics, storage, etc.)
- [ ] Create fixture files for test data
- [ ] Set up mock generators with @GenerateMocks
- [ ] Run build_runner to generate mocks
- [ ] Write tests following established patterns
- [ ] Verify zero warnings
- [ ] Document any platform limitations

---

## Provider Testing Patterns

### Pattern 1: Basic Provider Container Setup

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([Repository, Service])
import 'provider_test.mocks.dart';

void main() {
  late MockRepository mockRepository;
  final getIt = GetIt.instance;

  setUp(() {
    mockRepository = MockRepository();
    
    // Register mock in GetIt
    if (getIt.isRegistered<Repository>()) {
      getIt.unregister<Repository>();
    }
    getIt.registerSingleton<Repository>(mockRepository);
  });

  tearDown() async {
    if (getIt.isRegistered<Repository>()) {
      await getIt.unregister<Repository>();
    }
  });

  group('Provider - Test Group', () {
    test('should do something', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      // Test code here
    });
  });
}
```

### Pattern 2: Testing State Transitions

```dart
test('should transition from loading to loaded', () async {
  // Arrange
  final data = TestFixtures.createData();
  when(mockRepository.getData())
      .thenAnswer((_) async => Right(data));
  
  final container = ProviderContainer();
  addTearDown(container.dispose);
  
  // Assert initial state
  expect(container.read(provider).isLoading, false);
  
  // Act
  await container.read(provider.notifier).loadData();
  
  // Assert final state
  final state = container.read(provider);
  expect(state.isLoading, false);
  expect(state.data, equals(data));
  expect(state.error, isNull);
});
```

### Pattern 3: Testing Error Handling

```dart
test('should handle repository failure', () async {
  // Arrange
  const errorMessage = 'Failed to load data';
  when(mockRepository.getData())
      .thenAnswer((_) async => Left(ServerFailure(errorMessage)));
  
  final container = ProviderContainer();
  addTearDown(container.dispose);
  
  // Act
  await container.read(provider.notifier).loadData();
  
  // Assert
  final state = container.read(provider);
  expect(state.error, errorMessage);
  expect(state.data, isNull);
});
```

### Pattern 4: Testing Async Loading States

```dart
test('should set loading state during async operation', () async {
  // Arrange
  final data = TestFixtures.createData();
  when(mockRepository.getData()).thenAnswer((_) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return Right(data);
  });
  
  final container = ProviderContainer();
  addTearDown(container.dispose);
  
  // Act
  final future = container.read(provider.notifier).loadData();
  
  // Assert loading state
  await Future<void>.delayed(const Duration(milliseconds: 10));
  expect(container.read(provider).isLoading, true);
  
  // Wait for completion
  await future;
  expect(container.read(provider).isLoading, false);
});
```

### Pattern 5: Testing Field Updates

```dart
test('should update field and mark as dirty', () async {
  // Arrange
  final entity = TestFixtures.createEntity();
  when(mockRepository.getEntity(any))
      .thenAnswer((_) async => Right(entity));
  
  final container = ProviderContainer();
  addTearDown(container.dispose);
  
  await container.read(provider.notifier).loadEntity('id');
  
  // Act
  container.read(provider.notifier).updateField(
    fieldName: 'name',
    value: 'New Name',
  );
  
  // Assert
  final state = container.read(provider);
  expect(state.hasUnsavedChanges, true);
  expect(state.entity!.name, 'New Name');
});
```

---

## Fixture Creation Best Practices

### 1. Create Comprehensive Fixtures

```dart
class EntityFixtures {
  /// Creates a complete entity with all fields filled
  static Entity createComplete({
    String id = 'entity_001',
    String name = 'Test Entity',
  }) {
    return Entity(
      id: id,
      name: name,
      createdAt: DateTime.now(),
      // ... all required fields
    );
  }
  
  /// Creates an empty entity
  static Entity createEmpty({
    String id = 'entity_002',
  }) {
    return Entity(
      id: id,
      name: '',
      createdAt: DateTime.now(),
      // ... minimal fields
    );
  }
  
  /// Creates a partial entity
  static Entity createPartial({
    String id = 'entity_003',
  }) {
    return Entity(
      id: id,
      name: 'Partial',
      createdAt: DateTime.now(),
      // ... some fields filled
    );
  }
  
  /// Creates multiple entities for list testing
  static List<Entity> createMultiple() {
    return [
      createComplete(id: 'entity_001'),
      createComplete(id: 'entity_002'),
      createComplete(id: 'entity_003'),
    ];
  }
}
```

### 2. Make Fixtures Configurable

```dart
static Entity createComplete({
  String? id,
  String? name,
  DateTime? createdAt,
}) {
  return Entity(
    id: id ?? 'entity_001',
    name: name ?? 'Test Entity',
    createdAt: createdAt ?? DateTime.now(),
  );
}
```

---

## Common Test Scenarios

### Scenario 1: CRUD Operations

```dart
group('Provider - CRUD Operations', () {
  test('should create entity', () async {
    // Arrange
    final entity = TestFixtures.createComplete();
    when(mockRepository.create(any))
        .thenAnswer((_) async => Right(entity));
    
    final container = ProviderContainer();
    addTearDown(container.dispose);
    
    // Act
    await container.read(provider.notifier).create(entity);
    
    // Assert
    expect(container.read(provider).entity, equals(entity));
  });
  
  test('should read entity', () async {
    // Similar pattern
  });
  
  test('should update entity', () async {
    // Similar pattern
  });
  
  test('should delete entity', () async {
    // Similar pattern
  });
});
```

### Scenario 2: Validation

```dart
group('Provider - Validation', () {
  test('should validate required fields', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    
    final notifier = container.read(provider.notifier);
    
    // Act
    final isValid = notifier.validate(emptyEntity);
    
    // Assert
    expect(isValid, false);
    expect(container.read(provider).validationErrors, isNotEmpty);
  });
  
  test('should pass validation with complete data', () {
    // Similar pattern
  });
});
```

### Scenario 3: State Persistence

```dart
group('Provider - State Persistence', () {
  test('should save state', () async {
    // Arrange
    final entity = TestFixtures.createComplete();
    when(mockRepository.save(any))
        .thenAnswer((_) async => Right(unit));
    
    final container = ProviderContainer();
    addTearDown(container.dispose);
    
    // Act
    await container.read(provider.notifier).save(entity);
    
    // Assert
    verify(mockRepository.save(entity)).called(1);
  });
});
```

---

## Handling Platform Dependencies

### Identifying Platform Dependencies

Platform-dependent code includes:
- Biometric authentication (LocalAuth)
- Secure storage (FlutterSecureStorage)
- Background services (Workmanager)
- Platform channels
- Native plugins

### Strategy 1: Skip Platform Tests

```dart
test('should login successfully', () async {
  // This test is blocked by BackgroundService.init()
  // See AUTH_PROVIDER_CORE_TESTING_SUMMARY.md for details
}, skip: 'Blocked by platform dependency: BackgroundService');
```

### Strategy 2: Document Limitations

```dart
/// Unit tests for AuthProvider (Core Authentication Only)
///
/// EXPLICITLY SKIPPED (Platform-Dependent):
/// - Biometric authentication
/// - Secure storage operations
/// - Background service initialization
///
/// These features require integration testing.
```

### Strategy 3: Test Error Paths Only

```dart
// Test all error scenarios (no platform code)
test('should handle wrong password', () async {
  // This works because error path doesn't call platform code
});

// Skip success scenarios (platform code)
test('should login successfully', () async {
  // This is blocked by BackgroundService.init()
}, skip: 'Platform dependency');
```

---

## Mock Setup Examples

### Example 1: Repository Mock

```dart
@GenerateMocks([EntityRepository])
import 'provider_test.mocks.dart';

setUp(() {
  mockRepository = MockEntityRepository();
  
  if (getIt.isRegistered<EntityRepository>()) {
    getIt.unregister<EntityRepository>();
  }
  getIt.registerSingleton<EntityRepository>(mockRepository);
});
```

### Example 2: Multiple Dependencies

```dart
@GenerateMocks([
  EntityRepository,
  NotificationService,
  ValidationService,
])
import 'provider_test.mocks.dart';

setUp(() {
  mockRepository = MockEntityRepository();
  mockNotificationService = MockNotificationService();
  mockValidationService = MockValidationService();
  
  // Register all mocks
  getIt.registerSingleton<EntityRepository>(mockRepository);
  getIt.registerSingleton<NotificationService>(mockNotificationService);
  getIt.registerSingleton<ValidationService>(mockValidationService);
});
```

---

## Error Handling Patterns

### Pattern 1: Repository Errors

```dart
test('should handle repository error', () async {
  when(mockRepository.getData())
      .thenAnswer((_) async => Left(ServerFailure('Error')));
  
  final container = ProviderContainer();
  addTearDown(container.dispose);
  
  await container.read(provider.notifier).loadData();
  
  expect(container.read(provider).error, 'Error');
});
```

### Pattern 2: Network Errors

```dart
test('should handle network error', () async {
  when(mockRepository.getData())
      .thenAnswer((_) async => Left(ServerFailure('No internet')));
  
  final container = ProviderContainer();
  addTearDown(container.dispose);
  
  await container.read(provider.notifier).loadData();
  
  expect(container.read(provider).error, 'No internet');
});
```

### Pattern 3: Validation Errors

```dart
test('should handle validation error', () {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  
  final notifier = container.read(provider.notifier);
  
  // Act
  notifier.updateField('email', 'invalid-email');
  
  // Assert
  expect(container.read(provider).validationErrors['email'], isNotNull);
});
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Forgetting to Dispose Container

❌ **Wrong**:
```dart
test('should do something', () {
  final container = ProviderContainer();
  // Test code
  // Container never disposed!
});
```

✅ **Correct**:
```dart
test('should do something', () {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  // Test code
});
```

### Pitfall 2: Not Awaiting Async Operations

❌ **Wrong**:
```dart
test('should load data', () {
  container.read(provider.notifier).loadData(); // Not awaited!
  expect(container.read(provider).data, isNotNull); // Fails!
});
```

✅ **Correct**:
```dart
test('should load data', () async {
  await container.read(provider.notifier).loadData();
  expect(container.read(provider).data, isNotNull);
});
```

### Pitfall 3: Using Wrong Failure Type

❌ **Wrong**:
```dart
when(mockRepository.getData())
    .thenAnswer((_) async => Left(Failure.firestore('Error')));
// Wrong Failure class!
```

✅ **Correct**:
```dart
when(mockRepository.getData())
    .thenAnswer((_) async => Left(ServerFailure('Error')));
// Correct Failure class for this repository
```

### Pitfall 4: Not Cleaning Up GetIt

❌ **Wrong**:
```dart
setUp(() {
  getIt.registerSingleton<Repository>(mockRepository);
  // Never unregistered!
});
```

✅ **Correct**:
```dart
setUp(() {
  if (getIt.isRegistered<Repository>()) {
    getIt.unregister<Repository>();
  }
  getIt.registerSingleton<Repository>(mockRepository);
});

tearDown() async {
  if (getIt.isRegistered<Repository>()) {
    await getIt.unregister<Repository>();
  }
});
```

---

## Test Organization

### Group Structure

```dart
void main() {
  // Setup
  
  group('Provider - State Initialization', () {
    // Tests for initial state
  });
  
  group('Provider - Load Operations', () {
    // Tests for loading data
  });
  
  group('Provider - Update Operations', () {
    // Tests for updating data
  });
  
  group('Provider - Save Operations', () {
    // Tests for saving data
  });
  
  group('Provider - Error Handling', () {
    // Tests for error scenarios
  });
  
  group('Provider - Edge Cases', () {
    // Tests for edge cases
  });
}
```

### Test Naming

✅ **Good Names**:
- `should load data successfully`
- `should handle network error during load`
- `should update field and mark as dirty`
- `should transition from loading to loaded`

❌ **Bad Names**:
- `test1`
- `it works`
- `check data`
- `test loading`

---

## Documentation Requirements

### 1. File Header

```dart
/// Unit tests for [ProviderName]
///
/// Tests cover:
/// - State initialization
/// - CRUD operations
/// - Error handling
/// - State transitions
/// - Validation
///
/// EXPLICITLY SKIPPED (if applicable):
/// - Platform-dependent features
/// - Integration scenarios
///
/// Target: 85%+ coverage
```

### 2. Test Summary Document

Create a summary document for each provider:
- Coverage achieved
- Tests created
- Key insights
- Challenges overcome
- Platform dependencies identified

### 3. Architecture Decision Records

Document any significant decisions:
- Why certain features are skipped
- Platform dependency strategies
- Integration test requirements

---

## Running Tests

### Run Single Provider Tests

```bash
flutter test test/unit/providers/provider_name_test.dart
```

### Run All Provider Tests

```bash
flutter test test/unit/providers/
```

### Generate Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Check for Warnings

```bash
flutter analyze test/unit/providers/provider_name_test.dart
```

---

## Success Criteria

A provider test suite is complete when:

- [ ] 85%+ coverage achieved
- [ ] All testable scenarios covered
- [ ] Zero warnings
- [ ] All tests passing
- [ ] Fixtures created
- [ ] Documentation written
- [ ] Platform dependencies documented
- [ ] Integration test requirements identified

---

## Examples from Phase 4

### Best Example: DoctorsListProvider
- Simple, focused tests
- Clear error handling
- Good fixture usage
- Zero warnings
- 100% pass rate

**File**: `test/unit/providers/doctors_list_provider_test.dart`

### Complex Example: NutritionEMRNotifier
- Complex state management
- Multiple test scenarios
- Comprehensive fixtures
- Audit trail testing
- Lock management

**File**: `test/unit/providers/nutrition_emr_notifier_test.dart`

### Platform Dependency Example: AuthProvider
- Core functionality tested
- Platform dependencies documented
- Error paths validated
- Integration requirements identified

**File**: `test/unit/providers/auth_provider_test.dart`

---

## Quick Reference

### Imports Needed

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
```

### Common Failure Types

```dart
ServerFailure('message')  // For repository errors
CacheFailure('message')   // For cache errors
AuthFailure('message')    // For auth errors
```

### Common Matchers

```dart
expect(value, isNull);
expect(value, isNotNull);
expect(value, equals(expected));
expect(value, isTrue);
expect(value, isFalse);
expect(list, isEmpty);
expect(list, isNotEmpty);
expect(list, contains(item));
expect(value, greaterThan(0));
expect(value, lessThan(100));
```

---

## Getting Help

### Resources
1. **Phase 4 Documentation**: See all summary documents in `.kiro/specs/code-quality-and-testing-improvement/`
2. **Existing Tests**: Review completed provider tests for patterns
3. **Riverpod Docs**: https://riverpod.dev/docs/concepts/testing
4. **Mockito Docs**: https://pub.dev/packages/mockito

### Common Questions

**Q: How do I handle platform dependencies?**  
A: Document them and defer to integration tests. See AUTH_PROVIDER_CORE_TESTING_SUMMARY.md

**Q: What if my provider uses multiple repositories?**  
A: Mock all of them in setUp and register with GetIt.

**Q: How do I test stream providers?**  
A: Use `expectLater` with `emitsInOrder`. See DoctorsListProvider for examples.

**Q: What if tests are flaky?**  
A: Ensure proper async/await usage and container disposal.

---

## Conclusion

This blueprint provides everything needed to test Riverpod providers in the AndroCare360 project. Follow these patterns, avoid the pitfalls, and you'll create high-quality, maintainable tests.

**Remember**:
- Start with fixtures
- Test one method at a time
- Document platform dependencies
- Aim for 85%+ coverage
- Keep tests focused and clear

Happy testing! 🎯

---

*Provider Testing Blueprint*  
*Created*: February 12, 2026  
*Based on*: Phase 4 Testing Experience  
*Status*: ✅ Complete and Ready for Use
