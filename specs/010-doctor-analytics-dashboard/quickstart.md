# Quickstart: Doctor Analytics Dashboard

**Branch**: `010-doctor-analytics-dashboard` | **Date**: 2026-04-25

## Prerequisites

### Environment

- Flutter SDK ^3.10.4 installed and on PATH
- Firebase CLI installed (`npm install -g firebase-tools`)
- Firebase project configured (`.firebaserc` present)
- Node.js 20 for Cloud Functions
- Dart build_runner installed

### Codebase Prerequisites (PR-001 → PR-004)

These must be completed before implementing the analytics feature:

1. **PR-001**: Add `lastLoginAt: DateTime?` to `UserModel` (`lib/shared/models/user_model.dart`). Update on each successful login via `AuthStateChanges` listener.
2. **PR-002**: Add `completedAt: DateTime?` to `AppointmentModel` (`lib/shared/models/appointment_model.dart`). Set when appointment status transitions to `completed`.
3. **PR-003**: Create Firestore document `platform_settings/commission` with `{ "rate": 0.15 }`.
4. **PR-004**: Add 6th NavCard "إحصائيات الأطباء" to `admin_dashboard_screen.dart` using existing `_NavCard` pattern.

## New Dependencies

Add to `pubspec.yaml` under `dependencies`:

```yaml
fl_chart: ^0.69.0
syncfusion_flutter_xlsio: ^28.1.33
```

Run:

```bash
flutter pub get
```

## Step-by-Step Setup

### 1. Generate Freezed + Injectable Code

After creating all entity, model, and repository files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Deploy Firestore Indexes

```bash
firebase deploy --only firestore:indexes
```

Verify indexes are created in Firebase Console &gt; Firestore &gt; Indexes.

### 3. Create Platform Settings Document

Create the commission rate document in Firestore:

```
Collection: platform_settings
Document: commission
Fields: { "rate": 0.15 }
```

This can be done via Firebase Console or a one-time migration script.

### 4. Deploy Cloud Functions

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

Verify functions appear in Firebase Console &gt; Functions.

### 5. Add Analytics NavCard to Admin Dashboard

Modify `lib/features/admin/presentation/screens/admin_dashboard_screen.dart`:

- Import `analytics_tab_screen.dart`
- Add a 6th `_NavCard`: "إحصائيات الأطباء" (Doctor Analytics)
- Route to `AnalyticsTabScreen` via `Navigator.push` (matching existing navigation pattern)

### 6. Run Flutter Analyze

```bash
flutter analyze
```

Must produce zero errors and zero warnings.

### 7. Run Tests

```bash
flutter test test/features/admin/analytics/
```

Target: 80%+ coverage for all files in the analytics feature.

## File Creation Order

Follow this order to avoid circular dependencies:

 1. **Domain entities** (no dependencies): `doctor_analytics.dart`, `platform_summary.dart`, `performance_score.dart`, `financial_summary.dart`, `admin_alert.dart`, `payout_report.dart`
 2. **Domain repositories** (depend on entities): `analytics_repository.dart`, `payout_export_repository.dart`
 3. **Domain usecases** (depend on repositories): all 9 usecases
 4. **Data models** (implement entities, add `@freezed`): all 6 models
 5. **Data repositories** (implement repo interfaces): `analytics_repository_impl.dart`, `payout_export_repository_impl.dart`
 6. **Presentation providers** (depend on usecases): `filters_provider.dart`, `analytics_provider.dart`, `alerts_provider.dart`
 7. **Presentation widgets** (depend on providers): all 12 widgets
 8. **Presentation screens** (depend on widgets + providers): `analytics_tab_screen.dart`, `doctor_analytics_detail_screen.dart`
 9. **Modify existing**: `admin_dashboard_screen.dart` (add 6th NavCard), `user_model.dart` (add lastLoginAt), `appointment_model.dart` (add completedAt)
10. **Cloud Functions**: `functions/src/doctor_analytics.js`, update `functions/index.js`

## Key Files to Reference

PurposeFileExisting admin dashboard`lib/features/admin/presentation/screens/admin_dashboard_screen.dart`Existing admin provider`lib/features/admin/presentation/providers/admin_provider.dart`Appointment model`lib/shared/models/appointment_model.dart`User model`lib/shared/models/user_model.dart`Doctor model`lib/shared/models/doctor_model.dart`Firebase module (DI)`lib/core/di/firebase_module.dart`Injection container`lib/core/di/injection_container.dart`Firestore indexes`firestore.indexes.json`Cloud Functions entry`functions/index.js`Important rules`docs/important-rules.md`

## Verification Checklist

- \[ \] `flutter pub get` succeeds
- \[ \] `flutter pub run build_runner build` succeeds (no errors)
- \[ \] `flutter analyze` produces 0 errors, 0 warnings
- \[ \] `flutter test` passes all tests
- \[ \] Prerequisites complete: `lastLoginAt` on UserModel (PR-001), `completedAt` on AppointmentModel (PR-002), `platform_settings/commission` doc created (PR-003)
- \[ \] Firestore indexes deployed
- \[ \] Cloud Functions deployed (6 callable + 1 scheduled)
- \[ \] Analytics NavCard visible in admin dashboard (6th card)
- \[ \] Summary cards display correct platform-wide data
- \[ \] Doctors table loads with pagination
- \[ \] Filters work (period, specialty, status, search)
- \[ \] Sorting works on all columns
- \[ \] Doctor detail screen shows all FR-001 → FR-022 data
- \[ \] PDF export generates valid file
- \[ \] Excel export generates valid file
- \[ \] Admin alerts appear when conditions are met
- \[ \] Alert acknowledgment persists
