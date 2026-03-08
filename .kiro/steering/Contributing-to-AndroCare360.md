# Contributing to AndroCare360

Welcome to AndroCare360! 🏥

We're excited that you're interested in contributing to our comprehensive medical consultation platform. This document provides guidelines and standards to ensure code quality, consistency, and maintainability across the project.

## Table of Contents

- [Getting Help](#getting-help)
- [Development Environment Setup](#development-environment-setup)
- [Project Structure](#project-structure)
- [Coding Standards](#coding-standards)
- [Documentation Standards](#documentation-standards)
- [Testing Requirements](#testing-requirements)
- [Build Runner Usage](#build-runner-usage)
- [Pull Request Process](#pull-request-process)
- [Git Workflow](#git-workflow)
- [Code Review Guidelines](#code-review-guidelines)

---

## Getting Help

If you have questions or need assistance:

- **Documentation**: Check the [README.md](README.md) for project overview
- **API Reference**: See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for Cloud Functions
- **Version History**: Review [CHANGELOG.md](CHANGELOG.md) for recent changes
- **Issues**: Search existing issues or create a new one
- **Team**: Contact the development team for urgent matters

---

## Development Environment Setup

### Prerequisites

Before you begin, ensure you have the following installed:


1. **Flutter SDK** (3.x or later)
   ```bash
   flutter --version
   # Should show Flutter 3.x
   ```

2. **Dart SDK** (3.10.4 or later)
   - Comes with Flutter

3. **Firebase CLI**
   ```bash
   npm install -g firebase-tools
   firebase --version
   ```

4. **Node.js** (for Cloud Functions)
   ```bash
   node --version
   # Should be v18 or later
   ```

5. **Git**
   ```bash
   git --version
   ```

6. **IDE** (recommended)
   - Visual Studio Code with Flutter/Dart extensions
   - Android Studio with Flutter plugin

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd androcare360
   ```

2. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

3. **Install Firebase CLI and Login**
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

4. **Select Firebase Project**
   ```bash
   firebase use elajtech
   ```

5. **Install Cloud Functions Dependencies**
   ```bash
   cd functions
   npm install
   cd ..
   ```


### Firebase Project Configuration

The project uses a custom Firestore database. Configuration is handled automatically, but you need to ensure:

1. **Firebase Configuration Files**
   - `android/app/google-services.json` (for Android)
   - `ios/Runner/GoogleService-Info.plist` (for iOS)
   - Contact team lead if these files are missing

2. **Firestore Database**
   - Database ID: `elajtech`
   - Region: `europe-west1`
   - **CRITICAL**: Never use `FirebaseFirestore.instance` (see Coding Standards)

### Agora Credentials Setup

For video call functionality:

1. **Request Credentials**
   - Contact team lead for Agora App ID and Certificate
   - These are stored in Firebase Functions config (not in code)

2. **Set Firebase Functions Config** (Team Lead Only)
   ```bash
   firebase functions:config:set agora.app_id="YOUR_APP_ID"
   firebase functions:config:set agora.app_certificate="YOUR_CERTIFICATE"
   ```

### Running the App Locally

1. **Start an Emulator or Connect a Device**
   ```bash
   # List available devices
   flutter devices
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

3. **Run in Debug Mode**
   ```bash
   flutter run --debug
   ```

4. **Run in Release Mode**
   ```bash
   flutter run --release
   ```

### Deploying Cloud Functions (Team Lead Only)

```bash
cd functions
npm install
firebase deploy --only functions
```

---


## Project Structure

AndroCare360 follows **Clean Architecture** with clear separation of concerns:

```
lib/
├── core/                    # Shared infrastructure
│   ├── services/           # Platform services (21 services)
│   │   ├── agora_service.dart
│   │   ├── voip_call_service.dart
│   │   ├── call_monitoring_service.dart
│   │   └── ...
│   ├── models/             # Data models
│   ├── constants/          # App-wide constants
│   ├── errors/             # Custom exceptions and failures
│   └── di/                 # Dependency injection setup
├── features/               # Feature modules (16 features)
│   ├── auth/              # Authentication
│   │   ├── data/          # Repositories, data sources
│   │   ├── domain/        # Entities, use cases
│   │   └── presentation/  # UI, state management
│   ├── appointments/      # Appointment management
│   ├── doctor/            # Doctor-specific features
│   ├── patient/           # Patient-specific features
│   ├── emr/               # Electronic Medical Records
│   ├── nutrition/         # Nutrition clinic
│   ├── prescriptions/     # Prescription management
│   ├── lab_requests/      # Lab requests
│   ├── radiology_requests/# Radiology requests
│   ├── device_requests/   # Device requests
│   ├── notifications/     # Notifications
│   └── ...
└── shared/                # Shared UI components
    ├── widgets/
    └── utils/
```

### Architecture Layers

1. **Presentation Layer**
   - UI widgets and screens
   - State management (Riverpod providers)
   - User input handling

2. **Domain Layer**
   - Business logic
   - Entities (pure Dart classes)
   - Use cases (optional, for complex logic)

3. **Data Layer**
   - Repositories (implement domain interfaces)
   - Data sources (Firestore, API calls)
   - Models (with JSON serialization)

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE` or `kCamelCase`
- **Private members**: `_leadingUnderscore`

---


## Coding Standards

### Dart Style Guide

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and [Effective Dart](https://dart.dev/guides/language/effective-dart).

### Flutter Best Practices

- Use `const` constructors whenever possible
- Keep `build()` methods lightweight
- Break down large widgets into smaller, reusable widgets
- Use `ListView.builder` for long lists
- Implement proper error handling
- Follow the [Flutter Best Practices](https://docs.flutter.dev/perf/best-practices)

---

## ⚠️ CRITICAL: Elajtech Project Rules

These rules are **MANDATORY** for all AndroCare360 development. Violations will result in PR rejection.

### 1. Firestore Database Configuration

**NEVER use `FirebaseFirestore.instance` directly!**

The AndroCare360 project uses a custom Firestore database with ID `elajtech`.

#### ✅ Correct Usage:

```dart
// Via dependency injection (PREFERRED)
@LazySingleton(as: MyRepository)
class MyRepositoryImpl implements MyRepository {
  MyRepositoryImpl(this._firestore); // Injected instance
  final FirebaseFirestore _firestore;
  
  Future<void> saveData() async {
    await _firestore.collection('my_collection').add({...});
  }
}

// Direct instantiation (ONLY in firebase_module.dart)
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech',
  );
}
```

#### ❌ Incorrect Usage:

```dart
// DON'T DO THIS!
final firestore = FirebaseFirestore.instance; // ❌ WRONG!

// This will use the default database, not 'elajtech'
await FirebaseFirestore.instance.collection('users').get(); // ❌ WRONG!
```


### 2. Build Runner Execution

After modifying any class with these annotations, you **MUST** run build_runner:

- `@injectable`, `@lazySingleton`, `@module`
- `@freezed`
- `@JsonSerializable`

#### Command:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

#### When to Run:

- After creating a new repository with `@LazySingleton`
- After creating a new service with `@injectable`
- After modifying a Freezed model
- After adding/modifying JSON serialization

#### Example:

```dart
// After creating this class, run build_runner
@freezed
class UserModel with _$UserModel {
  factory UserModel({
    required String id,
    required String fullName,
  }) = _UserModel;
  
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

### 3. Clinic Isolation Principle

Each specialty clinic **MUST** have its own independent Model and Repository.

**DO NOT** merge the logic of different clinics into a single file.

#### ✅ Correct Structure:

```
lib/features/
├── nutrition/
│   └── data/
│       └── repositories/
│           └── nutrition_emr_repository_impl.dart
├── emr/
│   └── data/
│       └── repositories/
│           ├── physiotherapy_emr_repository_impl.dart
│           ├── internal_medicine_emr_repository_impl.dart
│           └── emr_repository_impl.dart (base)
```

#### ❌ Incorrect:

- Merging nutrition and physiotherapy logic into one repository
- Sharing EMR models across different specialties
- Creating a "universal" EMR repository for all clinics

**Why?** This maintains the Single Responsibility Principle (SRP) and ensures project scalability.


### 4. Cloud Functions Region

All Cloud Functions are deployed in the **europe-west1** region.

#### ✅ Correct Usage:

```dart
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

final result = await functions.httpsCallable('startAgoraCall').call({
  'appointmentId': 'apt_123',
  'doctorId': 'doctor_456',
});
```

#### ❌ Incorrect Usage:

```dart
// This will fail with "NOT_FOUND" error
final functions = FirebaseFunctions.instance; // ❌ WRONG!
```

### 5. Null Safety Patterns

Never use the null-check operator (`!`) on user objects from `authProvider`.

#### ✅ Correct Pattern:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(authProvider).user;
  
  if (user == null) {
    return const LoadingWidget();
  }
  
  // Now safe to use user.id, user.fullName, etc.
  return Text('Welcome, ${user.fullName}');
}
```

#### ❌ Incorrect Pattern:

```dart
// DON'T DO THIS!
final user = ref.watch(authProvider).user!; // ❌ WRONG!
// This will crash if user is null
```

### 6. Error Handling with Either<Failure, T>

All repository methods must return `Either<Failure, T>` from the `dartz` package.

#### ✅ Correct Pattern:

```dart
@override
Future<Either<Failure, UserModel>> getUser(String id) async {
  try {
    final doc = await _firestore.collection('users').doc(id).get();
    
    if (doc.exists && doc.data() != null) {
      return Right(UserModel.fromJson(doc.data()!));
    } else {
      return const Left(ServerFailure('User not found'));
    }
  } on FirebaseException catch (e) {
    return Left(ServerFailure(e.message ?? 'Unknown error'));
  } on Exception catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```


### 7. Firestore Snapshot Validation

Always validate Firestore snapshots before parsing.

#### ✅ Correct Pattern:

```dart
factory UserModel.fromFirestore(DocumentSnapshot snapshot) {
  if (!snapshot.exists || snapshot.data() == null) {
    throw Exception('Document does not exist or has no data');
  }
  
  try {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel.fromJson(data);
  } catch (e, stackTrace) {
    debugPrint('Error parsing UserModel: $e');
    debugPrint('StackTrace: $stackTrace');
    rethrow;
  }
}
```

### 8. Diagnostic Logging

All Write/Update operations must include debug logging.

#### ✅ Correct Pattern:

```dart
Future<Either<Failure, Unit>> saveAppointment(AppointmentModel appointment) async {
  try {
    if (kDebugMode) {
      debugPrint('Saving appointment: ${appointment.id}');
      debugPrint('Patient ID: ${appointment.patientId}');
      debugPrint('Doctor ID: ${appointment.doctorId}');
    }
    
    await _firestore
        .collection('appointments')
        .doc(appointment.id)
        .set(appointment.toJson());
    
    if (kDebugMode) {
      debugPrint('Appointment saved successfully: ${appointment.id}');
    }
    
    return const Right(unit);
  } on Exception catch (e) {
    if (kDebugMode) {
      debugPrint('Error saving appointment: $e');
    }
    return Left(ServerFailure(e.toString()));
  }
}
```

### 9. Deprecated API Prevention

⚠️ **CRITICAL**: Never use deprecated APIs. The codebase has been fully migrated to Flutter 3.27+ current APIs.

#### Prevention Mechanisms

**Pre-Commit Hooks:**
```bash
# Setup hooks (run once)
bash .githooks/setup.sh  # Unix/Linux/macOS
.githooks\setup.bat      # Windows
```

**CI/CD Enforcement:**
- Automated checks on every push/PR
- Build fails if deprecated APIs detected
- See `.github/workflows/deprecated-api-check.yml`

**Common Migrations:**

| Deprecated API | Current API | Example |
|----------------|-------------|---------|
| `Color.withOpacity(0.5)` | `Color.withValues(alpha: 0.5)` | `Colors.white.withValues(alpha: 0.1)` |
| `Radio(groupValue:, onChanged:)` | `RadioGroup(groupValue:, onChanged:, child:)` | See `TASK_18_COMPLETION_REPORT.md` |

**Reference Documentation:**
- `DEPRECATED_API_PREVENTION_STRATEGY.md` - Complete prevention guide
- `TASK_18_COMPLETION_REPORT.md` - Migration report
- `test/golden/README.md` - Golden tests guide

---


## Documentation Standards

All public classes and methods **MUST** be documented using DartDoc (`///`) comments.

### Bilingual Documentation

Documentation must be provided in **both Arabic and English**:

- **Arabic**: For medical and business logic
- **English**: For technical specifications

### Class-Level Documentation

```dart
/// Authentication Repository implementation for the AndroCare360 system.
/// مستودع المصادقة لنظام AndroCare360.
///
/// This repository implements the [AuthRepository] interface and handles
/// all Firebase Authentication operations.
/// يقوم هذا المستودع بتنفيذ واجهة [AuthRepository] ويتعامل مع جميع
/// عمليات المصادقة في Firebase.
///
/// **CRITICAL DATABASE RULES:**
/// - Must use `databaseId: 'elajtech'` for ALL Firestore operations
/// - Never use FirebaseFirestore.instance directly
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final repository = getIt<AuthRepository>();
/// ```
///
/// **Usage Example:**
/// ```dart
/// final result = await repository.signIn(email, password);
/// result.fold(
///   (failure) => showError(failure.message),
///   (user) => navigateToHome(user),
/// );
/// ```
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  // Implementation
}
```

### Method-Level Documentation

```dart
/// Sign in a user with email and password.
/// تسجيل دخول المستخدم باستخدام البريد الإلكتروني وكلمة المرور.
///
/// Authenticates the user with Firebase Auth and retrieves their profile
/// from Firestore.
/// يقوم بمصادقة المستخدم مع Firebase Auth واسترجاع ملفه الشخصي
/// من Firestore.
///
/// Parameters:
/// - email: User's email address (required)
/// - password: User's password (required)
///
/// Returns:
/// - Right(UserModel): User authenticated successfully
/// - Left(ServerFailure): Authentication failed
///
/// Example:
/// ```dart
/// final result = await repository.signIn('user@example.com', 'password123');
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (user) => print('Welcome, ${user.fullName}'),
/// );
/// ```
@override
Future<Either<Failure, UserModel>> signIn(String email, String password) async {
  // Implementation
}
```

### Documentation Requirements

- ✅ All public classes must have class-level documentation
- ✅ All public methods must have method-level documentation
- ✅ Include usage examples in code blocks
- ✅ Document all parameters and return values
- ✅ List possible failure scenarios
- ✅ Use bilingual comments (Arabic/English)

---


## Testing Requirements

### Coverage Expectations

- **Overall Coverage:** ≥ 70%
- **Core Services:** ≥ 80%
- **Repositories:** ≥ 80%
- **Critical Flows:** 100% (authentication, video calls, appointments)

### Test Persistence Rule

⚠️ **CRITICAL**: Merging or committing any code that causes a failure in any of the current 664+ tests is **strictly prohibited**.

When adding a new feature, corresponding Unit Tests **MUST** be implemented immediately, ensuring coverage for both happy paths and edge/failure cases.

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
# macOS
open coverage/html/index.html

# Windows
start coverage/html/index.html

# Linux
xdg-open coverage/html/index.html
```

### Test Structure

```
test/
├── fixtures/              # Test data fixtures
│   ├── user_fixtures.dart
│   ├── appointment_fixtures.dart
│   └── emr_fixtures.dart
├── helpers/               # Test utilities
│   ├── test_helpers.dart
│   ├── firebase_emulator_helper.dart
│   └── provider_container_helper.dart
├── mocks/                 # Generated mocks
│   └── mocks.dart
├── unit/                  # Unit tests
│   ├── services/
│   │   ├── agora_service_test.dart
│   │   ├── voip_call_service_test.dart
│   │   └── ...
│   └── repositories/
│       ├── auth_repository_test.dart
│       ├── appointment_repository_test.dart
│       └── ...
├── widget/                # Widget tests
│   ├── screens/
│   │   ├── booking_screen_test.dart
│   │   └── ...
│   └── widgets/
└── integration/           # Integration tests
    ├── video_call_flow_test.dart
    ├── appointment_booking_test.dart
    └── emr_workflow_test.dart
```


### Test Naming Convention

Follow the pattern: `methodName_stateUnderTest_expectedBehavior`

```dart
// Good examples
test('signIn_withValidCredentials_returnsUser', () { ... });
test('signIn_withInvalidCredentials_returnsFailure', () { ... });
test('signIn_withNetworkError_returnsNetworkFailure', () { ... });

// Bad examples
test('test sign in', () { ... }); // Too vague
test('signIn', () { ... }); // Missing context
```

### Writing Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('AuthRepository', () {
    late AuthRepositoryImpl repository;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      repository = AuthRepositoryImpl(mockAuth, mockFirestore);
    });

    test('signIn_withValidCredentials_returnsUser', () async {
      // Arrange
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await repository.signIn('test@example.com', 'password');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (user) => expect(user.email, 'test@example.com'),
      );
    });
  });
}
```

### Platform Mocking Rule (CI Stability)

When writing tests for services interacting with Native APIs (e.g., VoIP or Notifications), always utilize try-catch blocks to handle `MissingPluginException` or implement MethodChannel Mocks.

```dart
test('voipService_showIncomingCall_handlesNativeAPI', () async {
  try {
    await voipService.showIncomingCall(callData);
    // Test passes if no exception
  } on MissingPluginException {
    // Expected in test environment without native platform
    // Test still passes
  }
});
```

---


## Build Runner Usage

### When to Run Build Runner

Run build_runner after modifying any class with these annotations:

- `@injectable`, `@lazySingleton`, `@module` (Dependency Injection)
- `@freezed` (Immutable models)
- `@JsonSerializable` (JSON serialization)

### Command

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Common Scenarios

1. **After creating a new repository:**
   ```dart
   @LazySingleton(as: MyRepository)
   class MyRepositoryImpl implements MyRepository {
     // Run build_runner after this
   }
   ```

2. **After creating a new service:**
   ```dart
   @injectable
   class MyService {
     // Run build_runner after this
   }
   ```

3. **After modifying a Freezed model:**
   ```dart
   @freezed
   class MyModel with _$MyModel {
     // Run build_runner after modifying this
   }
   ```

4. **After adding JSON serialization:**
   ```dart
   @JsonSerializable()
   class MyModel {
     // Run build_runner after this
   }
   ```

### Troubleshooting

If you encounter build_runner errors:

1. **Clean generated files:**
   ```bash
   flutter clean
   flutter pub get
   flutter pub run build_runner clean
   ```

2. **Rebuild:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Check for conflicts:**
   - Ensure no duplicate class names
   - Verify all imports are correct
   - Check for syntax errors in annotations

---


## Pull Request Process

### Before Submitting a PR

Ensure your code meets these requirements:

- [ ] Code follows Dart style guide
- [ ] All tests pass (`flutter test`)
- [ ] No new analyzer warnings (`flutter analyze`)
- [ ] No deprecated API warnings in source code (`flutter analyze lib/ | grep deprecated_member_use`)
- [ ] Build runner executed if needed
- [ ] Documentation updated (if applicable)
- [ ] Test coverage maintained or improved
- [ ] No breaking changes to existing tests (664+ tests must pass)
- [ ] Pre-commit hooks setup and passing

### Branch Naming Conventions

Use descriptive branch names with prefixes:

- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions/modifications

**Examples:**
```
feature/add-prescription-management
fix/video-call-connection-issue
docs/update-api-documentation
refactor/improve-error-handling
test/add-appointment-repository-tests
```

### Commit Message Format

Follow the Conventional Commits specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(appointments): add conflict detection for booking

fix(video-call): resolve connection timeout issue

docs(contributing): update testing guidelines

test(auth): add unit tests for sign-in flow
```


### PR Description Template

When creating a pull request, use this template:

```markdown
## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Test addition/modification

## Description

[Provide a clear and concise description of your changes]

## Related Issue

Closes #[issue number]

## Changes Made

- [List the main changes made in this PR]
- [Be specific about what was added, modified, or removed]

## Testing

[Describe how you tested your changes]

- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed

## Screenshots (if applicable)

[Add screenshots to demonstrate UI changes]

## Checklist

- [ ] My code follows the project's coding standards
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] My changes generate no deprecated API warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published
- [ ] I have run build_runner if needed
- [ ] I have verified the database ID rule (databaseId: 'elajtech')
- [ ] I have followed the clinic isolation principle (if applicable)
- [ ] Pre-commit hooks are setup and passing

## Additional Notes

[Any additional information that reviewers should know]
```

### Code Review Checklist

Reviewers should verify:

- [ ] Code follows Dart/Flutter best practices
- [ ] Critical Elajtech rules are followed (database ID, build runner, clinic isolation)
- [ ] No deprecated API warnings in source code
- [ ] Error handling is comprehensive
- [ ] Documentation is complete and bilingual
- [ ] Tests are adequate and pass
- [ ] No security vulnerabilities introduced
- [ ] Performance considerations addressed
- [ ] Code is maintainable and readable
- [ ] Pre-commit hooks and CI/CD checks passing

---


## Git Workflow

### Branch Strategy

We use a feature branch workflow:

1. **main** - Production-ready code
2. **develop** - Integration branch for features (if used)
3. **feature/** - Feature branches
4. **fix/** - Bug fix branches

### Workflow Steps

1. **Create a branch from main:**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/my-new-feature
   ```

2. **Make your changes and commit:**
   ```bash
   git add .
   git commit -m "feat(scope): description"
   ```

3. **Keep your branch up to date:**
   ```bash
   git checkout main
   git pull origin main
   git checkout feature/my-new-feature
   git rebase main
   ```

4. **Push your branch:**
   ```bash
   git push origin feature/my-new-feature
   ```

5. **Create a Pull Request** on GitHub/GitLab

6. **Address review comments** if any

7. **Merge after approval**

### Rebase vs Merge

- **Use rebase** when updating your feature branch with main:
  ```bash
  git rebase main
  ```

- **Use merge** when integrating approved PRs into main (done by maintainers)

### Commit Best Practices

- Make small, focused commits
- Write clear, descriptive commit messages
- Commit related changes together
- Don't commit generated files (*.g.dart, *.freezed.dart)
- Don't commit sensitive information (API keys, credentials)

---


## Code Review Guidelines

### For Authors

When submitting a PR:

1. **Self-review first** - Review your own code before requesting review
2. **Provide context** - Explain why changes were made
3. **Keep PRs focused** - One feature/fix per PR
4. **Respond promptly** - Address review comments quickly
5. **Be open to feedback** - Code reviews improve code quality

### For Reviewers

When reviewing a PR:

1. **Review promptly** - Aim to review within 24 hours
2. **Be constructive** - Provide helpful feedback, not just criticism
3. **Check critical rules** - Verify Elajtech-specific rules are followed
4. **Test locally** - Pull the branch and test if needed
5. **Approve or request changes** - Be clear about your decision

### What to Check

#### Code Quality
- [ ] Code is readable and maintainable
- [ ] No code duplication
- [ ] Proper error handling
- [ ] Efficient algorithms and data structures
- [ ] No deprecated APIs used

#### Elajtech Rules
- [ ] Database ID rule followed (databaseId: 'elajtech')
- [ ] Build runner executed if needed
- [ ] Clinic isolation maintained
- [ ] Cloud Functions region specified (europe-west1)
- [ ] Null safety patterns followed
- [ ] No deprecated API warnings

#### Documentation
- [ ] Public classes documented
- [ ] Public methods documented
- [ ] Bilingual comments (Arabic/English)
- [ ] Usage examples provided

#### Testing
- [ ] Tests added for new features
- [ ] Tests updated for modified features
- [ ] All tests pass
- [ ] Coverage maintained or improved

#### Security
- [ ] No sensitive data exposed
- [ ] Proper authentication checks
- [ ] Input validation implemented
- [ ] Security rules followed

### Response Time Expectations

- **Initial review**: Within 24 hours
- **Follow-up reviews**: Within 12 hours
- **Approval/merge**: Within 48 hours of final approval

### Approval Requirements

- At least **1 approval** from a team member
- All **CI checks passing**
- No **unresolved comments**
- **Merge conflicts resolved**

---


## Additional Resources

### Documentation

- [README.md](README.md) - Project overview and architecture
- [CHANGELOG.md](CHANGELOG.md) - Version history
- [API_DOCUMENTATION.md](API_DOCUMENTATION.md) - Cloud Functions API reference

### External Resources

- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Agora Documentation](https://docs.agora.io/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Tools

- [Flutter DevTools](https://docs.flutter.dev/tools/devtools) - Debugging and profiling
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite) - Local testing
- [Dart Analyzer](https://dart.dev/tools/dart-analyze) - Static analysis

---

## Questions or Issues?

If you have questions or encounter issues:

1. **Check existing documentation** - README, CHANGELOG, API_DOCUMENTATION
2. **Search existing issues** - Someone may have already asked
3. **Ask the team** - Reach out to team members
4. **Create an issue** - If you found a bug or have a feature request

---

## Thank You!

Thank you for contributing to AndroCare360! Your efforts help us build a better healthcare platform for doctors and patients.

---

**Last Updated:** 2026-02-16  
**Version:** 1.0.0  
**Maintained by:** AndroCare360 Development Team
