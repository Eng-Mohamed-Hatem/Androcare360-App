# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

**Language/Version**: Dart [version used in project] + Flutter [channel/version]  
**Primary Dependencies**: Flutter SDK, Riverpod, dio, firebase_core, cloud_firestore, flutter_secure_storage, intl, [any feature-specific packages]  
**Storage**: Firestore (`databaseId: 'elajtech'` via `FirebaseFirestore.instanceFor`), local secure storage, shared_preferences/Hive if applicable  
**Testing**: flutter_test, mockito, integration_test, [any other testing utilities]  
**Target Platform**: Android (min SDK), iOS (min version), possibly Web/Desktop if supported  
**Project Type**: Flutter mobile app (AndroCare medical app) with Clean Architecture (Presentation/Domain/Data)  
**Performance Goals**: Smooth 60 fps UI; fast screen transitions; minimal jank; responsive UX on mid-range Android devices  
**Constraints**: Must respect Auth Safety + Firestore safety rules; low network overhead; avoid blocking UI thread; support RTL where needed  
**Scale/Scope**: [e.g., number of screens/components affected, estimated number of new providers/use cases/repos, user volume if relevant]


## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [ ] **Architecture Check**: Follows Clean Architecture (Presentation/Domain/Data) and SOLID as defined in the AndroCare constitution?  
- [ ] **State Check**: Uses Riverpod (or approved state management) correctly without leaking complex state into Widgets?  
- [ ] **Security Check**: Complies with Auth Safety rules, Firestore Mapping rules, and uses `databaseId: 'elajtech'` per `important-rules.md`?  
- [ ] **Data Safety**: No `!` on auth user objects, strict validation of Firestore snapshots, safe list access (no `.first` without checks)?  
- [ ] **UX/UI Check**: Uses the AndroCare design system, handles error/loading/empty states, and applies LTR/RTL direction rules where necessary?  
- [ ] **Testing Check**: Includes Unit + Widget tests for new logic, respects Test Persistence rule, and mocks Platform channels when needed?  
- [ ] **Spec Kit Check**: This feature followed the full Spec Kit lifecycle (specify → clarify → plan → checklist → tasks → analyze → implement)?

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (Flutter project root)

```text
lib/
├── core/
│   ├── routing/
│   ├── theming/
│   ├── widgets/            # Shared reusable UI components
│   ├── errors/             # Failure models, exceptions
│   ├── utils/              # Helpers, formatters, etc.
│   └── services/           # Cross-cutting services (e.g., analytics, logging)
│
├── features/
│   ├── auth/               # Authentication feature (login, OTP, logout, etc.)
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   ├── widgets/
│   │   │   └── controllers/ or viewmodels/providers
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── usecases/
│   │   │   └── repositories/ (interfaces)
│   │   └── data/
│   │       ├── models/
│   │       ├── datasources/
│   │       └── repositories/ (implementations)
│   │
│   ├── appointments/       # Appointment booking & management feature
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   └── [feature-name]/
│       ├── presentation/
│       ├── domain/
│       └── data/
│
└── main.dart               # App entry point

test/
├── unit/
│   ├── features/
│   │   ├── auth/
│   │   ├── appointments/
│   │   └── [feature-name]/
│   └── core/
├── widget/
│   └── features/
│       ├── auth/
│       ├── appointments/
│       └── [feature-name]/
└── integration/
    └── [flows or end-to-end scenarios]


**Structure Decision**:  
[Describe where this feature will live, e.g.:  
- lib/features/packages/ (presentation/domain/data)  
- test/unit/features/packages/ and test/widget/features/packages/  
Mention if any new top-level modules or packages are introduced.

### Presentation Layer Extensions (CA-003)
- **Patient Portfolio**: Update `lib/features/packages/presentation/pages/my_packages_page.dart` to display a `(Test)` / `(تجريبي)` label for packages where `isTestPurchase` is true.
- **Admin Dashboard**: Update `lib/features/admin/presentation/widgets/package_list_item_admin.dart` (or equivalent) to visually distinguish test subscriptions with a specific badge and filter logic.

- **Default Value**: The `isTestPurchase` field in `PatientPackageEntity` and `PatientPackageModel` MUST default to `false`. This ensures that existing records in Firestore (which lack this field) are correctly interpreted as real purchases during deserialization.
- **Cleanup Strategy**: Test records can be queried in Firestore using `.where('isTestPurchase', '==', true)` for manual or automated batch deletion.

### Presentation Logic (CHK003, CHK004)
- **Loading State**: The "Buy Now" button in `PackageDetailsPage` will use `ref.watch(purchasePackageProvider).isLoading` (or equivalent `AsyncValue` state) to show a `CircularProgressIndicator` during the transaction.
- **Error Handling**: The `PackageDetailsPage` will use `ref.listen(purchasePackageProvider, ...)` to intercept `AsyncError` states and display a localized error SnackBar using `ScaffoldMessenger`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
