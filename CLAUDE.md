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
