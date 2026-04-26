# Implementation Plan: Doctor Analytics Dashboard

**Branch**: `010-doctor-analytics-dashboard` | **Date**: 2026-04-25 | **Spec**: [spec.md](./spec.md) | **Input**: Feature specification from `/specs/010-doctor-analytics-dashboard/spec.md`

## Summary

Admin-facing analytics screen integrated into the existing Admin Dashboard via a **6th NavCard** (not a tab — existing dashboard uses `Navigator.push` card navigation), providing a platform-wide overview of all doctors' performance (bookings, revenue, performance score) in a sortable table, with drill-down to per-doctor detail. Includes smart alerts, PDF/Excel payout export, time-series charts, patient retention rate, and specialty breakdown. Data is aggregated from the `appointments` and `users` collections via Cloud Functions for heavy aggregation, with client-side caching via Riverpod providers.

## Prerequisites *(must be completed before feature implementation)*

| ID | Prerequisite | File | Why |
|----|-------------|------|-----|
| PR-001 | Add `lastLoginAt: DateTime?` to `UserModel` | `lib/shared/models/user_model.dart` | Required by FR-016 (inactivity alert). Update on each successful login via `AuthStateChanges` listener. |
| PR-002 | Add `completedAt: DateTime?` to `AppointmentModel` | `lib/shared/models/appointment_model.dart` | Required by FR-010, FR-011 (time-series), FR-017 (payout reports). Set when appointment status transitions to `completed`. |
| PR-003 | Create `platform_settings/commission` Firestore doc | Firestore (manual or migration) | Required by FR-005, FR-006, FR-007. Document: `{ rate: 0.15 }`. No admin UI needed initially. |
| PR-004 | Add 6th NavCard "إحصائيات الأطباء" to admin dashboard | `lib/features/admin/presentation/screens/admin_dashboard_screen.dart` | Required for navigation. Uses existing `_NavCard` pattern + `Navigator.push` to `AnalyticsTabScreen`. |
| PR-005 | Add `confirmedAt: DateTime?` to `AppointmentModel` | `lib/shared/models/appointment_model.dart` | Required by FR-003 (average response time). Set on first status transition from `pending` to `confirmed`/`scheduled`. |
| PR-006 | Create `admin_settings/alert_thresholds` Firestore doc | Firestore (manual or migration) | Required by FR-014, FR-015, FR-016. Document: `{ payoutThreshold: 5000.0, completionRateThreshold: 0.70, inactivityDaysThreshold: 7 }`. |

## Technical Context

**Language/Version**: Dart SDK ^3.10.4 / Flutter 3.x | **Primary Dependencies**: flutter_riverpod ^2.5.1, cloud_firestore ^5.5.2, cloud_functions ^5.6.2, freezed ^3.2.4, injectable ^2.7.1+4, dartz ^0.10.1, go_router ^14.0.0, pdf ^3.11.3, printing ^5.14.2, fl_chart (charts), syncfusion_flutter_xlsio (Excel export) | **Storage**: Firebase Firestore (databaseId: 'elajtech'), Cloud Storage | **Testing**: flutter_test, mocktail, integration_test, Jest + firebase-functions-test ^3.1.0 (CF unit tests — already in devDependencies) | **Target Platform**: Android / iOS / Web (admin panel) | **Project Type**: Mobile app (Flutter) with Cloud Functions backend (Node.js 20) | **Performance Goals**: Dashboard loads in &lt; 5s initial / &lt; 2s pages / &lt; 3s sort+filter for 500 doctors (SC-006), export in &lt; 60s (SC-004) | **Constraints**: databaseId 'elajtech' only, europe-west1 CF region, no `!` on user, Clean Architecture separation, Clinic Isolation Rule, kDebugMode logging, 80%+ test coverage | **Scale/Scope**: Up to 500 doctors, 8 user stories, 28 functional requirements (FR-001→FR-022 + FR-005a, FR-009a, FR-014a, FR-014b, FR-017a, FR-018a), 6 NFRs

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Clean Architecture | PASS | New feature under `lib/features/admin/analytics/` with data/domain/presentation separation |
| II. State Management | PASS | Riverpod StateNotifier + providers, consistent with existing `admin_provider.dart` pattern |
| III. Code Quality | PASS | DRY, SRP, small widgets, effective dart |
| IV. Documentation | PASS | DartDoc in Arabic (business) + English (technical) per Task 13 |
| V. Security | PASS | Admin-only access, read-only analytics, no patient PHI in logs, Firestore rules; payout recording is append-only admin action to `doctor_payouts/` subcollection |
| VI. Performance | PASS | Cloud Functions for heavy aggregation, lazy loading, pagination at 20 doctors, caching |
| VII. UX/UI | PASS | RTL Arabic support, error/loading/empty states, existing design system |
| VIII. Testing | PASS | 80%+ coverage: unit (usecases, repos), widget (screens), CF unit tests in `functions/test/analytics-*.test.js` (T039a/b, T052a, T066d, T069a, T074, T087a — financial logic, performance score weight redistribution, alert conditions, time-series edge cases), integration (happy path + edge cases) |
| IX. Integration | PASS | Fits existing `lib/features/admin/` structure, adds 6th NavCard to `admin_dashboard_screen.dart` via Navigator.push |
| X. Spec Kit | PASS | Following lifecycle: specify → clarify → plan → tasks → implement |
| XI. Decision Governance | PASS | Key decisions documented in [research.md](./research.md) with rationale |
| XII. Telemedicine | PASS | Reads call completion data from appointments (no call state transitions) |

**No violations to justify.**

## Requirements Tracking

### Core Functional Requirements (FR-001 → FR-022)

| FR | Category | Description | Key Implementation Detail |
|----|----------|-------------|--------------------------|
| FR-001 | Bookings | Booking counts by status (completed/cancelled/missed) | AppointmentStatus enum values |
| FR-002 | Bookings | Video call completion rate (Booking Completion Rate) | completed / total |
| FR-003 | Bookings | Average response time to new booking | `createdAt` → first `confirmed`/`scheduled` status change, in minutes. Appointments still in `pending` (no transition) are excluded from average. |
| FR-004 | Financial | Total revenue per doctor per period | Financial Eligibility: `status == 'completed'` AND `fee > 0` |
| FR-005 | Financial | Platform commission per doctor | `totalRevenue × commissionRate` from `platform_settings/commission.rate` |
| FR-005a | Financial | Exclude notCompleted from revenue/commission | Additional filter on FR-004 eligibility |
| FR-006 | Financial | Net payout (revenue − commission) | Rounded to 2dp, SAR |
| FR-007 | Financial | Classify payouts as paid/pending/partial | Admin records disbursement via `recordPayout` callable CF (T066a); append-only audit in `doctor_payouts/{doctorId}/transactions/` (BR-002) |
| FR-008 | Performance | Composite score from 100 (4 dimensions × 25) | Weight redistribution when data missing; overview table uses 3-dim redistribution (`isOverviewScore=true`, EMR speed omitted for batch performance) |
| FR-009 | Performance | Score dimension breakdown | Patient rating = `DoctorModel.rating / 5.0 × 25` |
| FR-009a | Performance | Punctuality dimension | `completed / (completed + notCompleted) × 25`; denominator = 0 → weight redistributed |
| FR-010 | Time-series | Daily/weekly/monthly charts | &lt; 3 points → single markers (`isMarker=true`), 1 month → bar chart |
| FR-011 | Time-series | Period-over-period comparison | Min 2 data points per period; previous period total = 0 → `comparison=null` (not Infinity) |
| FR-012 | Specialty | Booking distribution by service type | AppointmentType (video/clinic) + clinicType |
| FR-013 | Specialty | Clinic Isolation Rule | Optional clinicType filter on all queries |
| FR-014 | Alerts | Financial threshold alert | From `admin_settings/alert_thresholds.payoutThreshold` (default 5000 SAR) |
| FR-014a | Alerts | Alert deduplication | One active alert per doctor per condition type; second trigger updates `createdAt` on existing doc |
| FR-014b | Alerts | In-app only | No Push/email in this phase |
| FR-015 | Alerts | Low completion rate alert (&lt; 70%) | Trailing 30 days |
| FR-016 | Alerts | Doctor inactivity alert (&gt; 7 days) | Requires PR-001 (`lastLoginAt`) |
| FR-017 | Reports | Monthly PDF/Excel export | On-demand only, &gt; 200 entries supported |
| FR-017a | Reports | PDF invoice template, Excel tabular | Standard layout with logo, doctor info, table, footer |
| FR-018 | Reports | Report row-level details | fee + commission + netAmount per row, CF source of truth |
| FR-018a | Reports | Report rules match detail view | Single CF serves both display and export; verified by cross-CF consistency assertion in T069a |
| FR-019 | Comparison | Sortable doctors table | Revenue / rating / appointments / performance score |
| FR-020 | Comparison | Specialty-scoped comparison | Primary `clinicType` used |
| FR-021 | Retention | Patient retention rate | Min 5 unique patients |
| FR-022 | Retention | Display retention in doctor profile | Part of DoctorAnalytics (`patientRetentionRate: double?` — populated only in detail view, null in overview) |

### Non-Functional Requirements

| NFR | Category | Target |
|-----|----------|--------|
| NFR-001 | Data refresh | On-demand (open/filter change) + pull-to-refresh. No auto-refresh. |
| NFR-002 | Query performance | &lt; 5s paginated, &lt; 10s full aggregation |
| NFR-003 | Security | Admin-only via CF auth check, no patient PHI in analytics |
| NFR-004 | Concurrency | Analytics reads are read-only; payout recording (`recordPayout` CF) is append-only writes to `doctor_payouts/` — no read-side conflicts |
| NFR-005 | Logging | CF: `console.log` (including `[PAYOUT]` prefix for recordPayout), client: `firebase_crashlytics` |
| NFR-006 | Accessibility | Platform defaults only, no additional a11y this iteration |

## Project Structure

### Documentation (this feature)

```text
specs/010-doctor-analytics-dashboard/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── cloud-functions.md
│   └── repository-interfaces.md
├── checklists/
│   ├── requirements.md  # Initial spec quality pass
│   └── analytics.md     # Comprehensive 54-item requirements quality review
└── tasks.md             # Phase 2 output (NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/features/admin/analytics/
├── data/
│   ├── models/
│   │   ├── doctor_analytics_model.dart        # @freezed - table row model
│   │   ├── platform_summary_model.dart        # @freezed - summary cards model
│   │   ├── performance_score_model.dart       # @freezed - 4-dimension score
│   │   ├── financial_summary_model.dart       # @freezed - revenue/commission/net
│   │   ├── admin_alert_model.dart             # @freezed - alert notification
│   │   └── payout_report_model.dart           # @freezed - exportable report
│   └── repositories/
│       ├── analytics_repository_impl.dart     # @LazySingleton - Firestore queries + CF calls
│       └── payout_export_repository_impl.dart # @LazySingleton - PDF/Excel generation + recordPayout CF call
├── domain/
│   ├── entities/
│   │   ├── doctor_analytics.dart              # @freezed entity
│   │   ├── platform_summary.dart              # @freezed entity
│   │   ├── performance_score.dart             # @freezed entity
│   │   ├── financial_summary.dart             # @freezed entity
│   │   ├── admin_alert.dart                   # @freezed entity
│   │   └── payout_report.dart                 # @freezed entity
│   ├── repositories/
│   │   ├── analytics_repository.dart          # Abstract interface
│   │   └── payout_export_repository.dart      # Abstract interface
│   └── usecases/
│       ├── get_platform_summary_usecase.dart
│       ├── get_doctors_overview_usecase.dart
│       ├── get_doctor_analytics_detail_usecase.dart
│       ├── get_performance_score_usecase.dart
│       ├── get_admin_alerts_usecase.dart
│       ├── get_patient_retention_usecase.dart
│       ├── get_specialty_breakdown_usecase.dart
│       ├── export_payout_report_usecase.dart
│       └── record_payout_usecase.dart         # NEW (T066b) - admin payout disbursement recording
└── presentation/
    ├── providers/
    │   ├── analytics_provider.dart            # StateNotifier<AnalyticsState>
    │   ├── filters_provider.dart              # Period, specialty, status, search
    │   └── alerts_provider.dart               # StateNotifier<AlertsState>
    ├── screens/
    │   ├── analytics_tab_screen.dart          # Main screen (pushed via Navigator.push from NavCard #6)
    │   └── doctor_analytics_detail_screen.dart # Drill-down (FR-001 → FR-022)
    └── widgets/
        ├── summary_cards_row.dart             # 4 platform summary cards
        ├── filters_bar.dart                   # Period/specialty/status/search filters
        ├── doctors_overview_table.dart        # Paginated sortable table
        ├── doctor_table_row.dart              # Single row in overview table
        ├── performance_score_widget.dart      # Score display with dimensions
        ├── financial_summary_widget.dart      # Revenue/commission/net breakdown + "تسجيل صرف" action (T066c)
        ├── appointment_stats_widget.dart      # Completed/cancelled/no-show counts
        ├── specialty_breakdown_widget.dart    # Service type distribution
        ├── time_series_chart_widget.dart      # Daily/weekly/monthly charts
        ├── patient_retention_widget.dart      # Retention rate display
        ├── admin_alerts_widget.dart           # Alert notifications panel
        └── payout_export_button.dart          # PDF/Excel export trigger

lib/features/admin/presentation/screens/
└── admin_dashboard_screen.dart                # MODIFY: add 6th NavCard "إحصائيات الأطباء"

lib/shared/models/
├── user_model.dart                            # MODIFY: add lastLoginAt (PR-001)
└── appointment_model.dart                     # MODIFY: add completedAt (PR-002) + confirmedAt (PR-005)

functions/
├── index.js                                   # MODIFY: add new callable + scheduled functions
└── src/
    └── doctor_analytics.js                    # NEW: analytics aggregation + recordPayout functions

functions/test/                                # CF unit tests (emulator-backed, Jest + firebase-functions-test)
├── analytics-get-doctors-overview.test.js     # T039a
├── analytics-get-platform-summary.test.js     # T039b
├── analytics-get-doctor-detail.test.js        # T052a
├── analytics-record-payout.test.js            # T066d
├── analytics-export-payout-report.test.js     # T069a
├── analytics-time-series.test.js              # T074
└── analytics-check-admin-alerts.test.js       # T087a

firestore.indexes.json                          # MODIFY: add 7 composite indexes

test/
├── features/admin/analytics/
│   ├── domain/usecases/
│   │   ├── get_platform_summary_usecase_test.dart
│   │   ├── get_doctors_overview_usecase_test.dart
│   │   ├── get_doctor_analytics_detail_usecase_test.dart
│   │   ├── get_performance_score_usecase_test.dart
│   │   ├── get_admin_alerts_usecase_test.dart
│   │   ├── get_patient_retention_usecase_test.dart
│   │   ├── get_specialty_breakdown_usecase_test.dart
│   │   ├── export_payout_report_usecase_test.dart
│   │   └── record_payout_usecase_test.dart
│   ├── data/repositories/
│   │   ├── analytics_repository_impl_test.dart
│   │   └── payout_export_repository_impl_test.dart
│   └── presentation/
│       ├── analytics_provider_test.dart
│       ├── filters_provider_test.dart
│       ├── alerts_provider_test.dart
│       └── widgets/
│           ├── summary_cards_row_test.dart
│           ├── doctors_overview_table_test.dart
│           ├── filters_bar_test.dart
│           └── doctor_analytics_detail_screen_test.dart
```

**Structure Decision**: Following the existing `lib/features/admin/` Clean Architecture pattern with `data/domain/presentation` separation. The analytics feature is a new subdirectory `analytics/` under the existing admin feature, mirroring the structure of `admin/data/`, `admin/domain/`, `admin/presentation/`.

## Navigation Flow

```
AdminDashboard (existing, 5 NavCards)
   └── NavCard #6: "إحصائيات الأطباء" (NEW, PR-004) → Navigator.push → AnalyticsTabScreen
        ├── Summary Cards — platform totals
        ├── Filters Bar — period / specialty / status / search
        ├── Doctors Overview Table — paginated, sortable
        └── → [tap doctor] → Navigator.push → DoctorAnalyticsDetailScreen
```

## Complexity Tracking

> No violations to justify. All constitution principles pass. 6 prerequisites (PR-001→PR-006) must be completed before feature implementation begins. 6 new FRs added during requirements quality review (FR-005a, FR-009a, FR-014a, FR-014b, FR-017a, FR-018a). 6 NFRs added (NFR-001→NFR-006) covering data refresh, performance, security, concurrency, logging, accessibility.
