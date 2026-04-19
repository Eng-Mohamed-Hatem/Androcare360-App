---
# No paths = always active for all files
---
# Firebase & DI Safety Rules — CRITICAL

## Firestore Database
- NEVER use `FirebaseFirestore.instance` anywhere in the codebase
- ALWAYS use injected `_firestore` via constructor (preferred)
- Direct access only in FirebaseModule: `FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'elajtech')`

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
  debugPrint('[SAVE] userId: $userId | appointmentId: $appointmentId');
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

## Object Initialization
- NEVER use `late final` for services that can be initialized immediately
- Use constructor initializer list instead