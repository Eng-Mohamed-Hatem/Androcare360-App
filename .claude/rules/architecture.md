---
# No paths = always active
---
# Architecture & Code Quality Rules

## Clean Architecture Layers (Strict)
- Presentation: UI widgets, Riverpod providers/notifiers — NO business logic here
- Domain:       Entities, Use Cases — pure Dart, NO Flutter imports
- Data:         Repository impls, data sources, Firestore models

## Feature Structure (Mandatory)
```
lib/features/<feature>/
├── data/
│   ├── models/           # Firestore models with fromFirestore/toJson
│   ├── repositories/     # Repository implementations
│   └── datasources/      # Firestore/API data sources
├── domain/
│   ├── entities/         # Pure Dart entities
│   └── usecases/         # Business logic use cases
└── presentation/
    ├── screens/
    ├── widgets/
    └── providers/        # Riverpod providers/notifiers
```

## Core Structure
```
lib/core/
├── services/             # 21 platform services (AgoraService, FCMService, etc.)
├── models/               # Shared models
├── errors/               # Custom Failures and Exceptions
├── constants/            # App-wide constants
└── di/                   # injection_container.dart + injection_container.config.dart
```

## Clinic Isolation Rule (SRP — Non-Negotiable)
- Every specialty clinic = independent Model + Repository
- NEVER merge Nutrition + Physiotherapy + Internal Medicine logic
- Each clinic's repository is in its own file
- Violations will be rejected in code review

## Error Handling
- Repositories MUST return `Either<Failure, T>` from `dartz`
- Create custom Failure classes in domain layer (e.g., ServerFailure, NetworkFailure)
- NEVER expose raw Firebase exceptions to presentation layer

## Null Safety Patterns
```dart
// ✅ ALWAYS
final user = ref.watch(authProvider).user;
if (user == null) return const LoadingWidget();

// ❌ NEVER
final user = ref.watch(authProvider).user!;
```

## List Safety
```dart
// ✅ ALWAYS
final spec = user.specializations.isNotEmpty
    ? user.specializations.first
    : 'General';

// ❌ NEVER — throws StateError on empty list
final spec = user.specializations.first;
```

## Auth & Routing Safety
- AuthWrapper MUST have a fallback for unknown `userType` → redirect to login + debugPrint
- Inactive users (`isActive == false`) → show: 'الحساب معطّل، برجاء التواصل مع الدعم.'
- Block at repository, provider, AND UI level

## Phone Numbers
- Store and compare in E.164 format ONLY: `+201008266544`
- Validate with: `r'^\+\d{8,15}$'`
- Never store local format: `01008266544`

## Documentation (Bilingual — Mandatory for Public APIs)
```dart
/// خدمة إدارة المصادقة لنظام AndroCare360
/// Authentication management service for AndroCare360
///
/// Usage:
/// ```dart
/// final result = await repository.signIn(email, password);
/// result.fold(
///   (failure) => showError(failure.message),
///   (user) => navigateToHome(user),
/// );
/// ```
```
