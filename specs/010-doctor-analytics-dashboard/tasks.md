# Tasks: Doctor Analytics Dashboard

**Input**: Design documents from `/specs/010-doctor-analytics-dashboard/`

**Prerequisites**: [./plan.md](./plan.md), [./spec.md](./spec.md), [./research.md](./research.md), [./data-model.md](./data-model.md), contracts/, [./quickstart.md](./quickstart.md)

**Tests**: Included — [./plan.md](./plan.md) requires 80%+ test coverage.

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **\[P\]**: Can run in parallel (different files, no dependencies)
- **\[Story\]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter app**: `lib/` at repository root
- **Cloud Functions**: `functions/` at repository root
- **Tests**: `test/` at repository root

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add dependencies, create directory structure, configure Firestore indexes

- \[X\] T001 Add fl_chart ^0.69.0 and syncfusion_flutter_xlsio ^28.1.33 to pubspec.yaml dependencies
- \[X\] T002 Create feature directory structure: lib/features/admin/analytics/{data/{models,repositories},domain/{entities,repositories,usecases},presentation/{providers,screens,widgets}} with .gitkeep files
- \[X\] T003 Add 7 composite indexes to firestore.indexes.json per contracts/cloud-functions.md: appointments(doctorId,status,completedAt), appointments(doctorId,completedAt), appointments(doctorId,patientId), appointments(status,completedAt), admin_alerts(isRead,createdAt), admin_alerts(type,createdAt), users(userType,isActive)
- \[X\] T004 Create platform_settings/commission Firestore document with { rate: 0.15 } (PR-003) via Firebase Console or migration script
- \[X\] T004a Create admin_settings/alert_thresholds Firestore document with { payoutThreshold: 5000.0, completionRateThreshold: 0.70, inactivityDaysThreshold: 7 } (PR-006) via Firebase Console or migration script

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Codebase prerequisites (PR-001, PR-002, PR-004, PR-005) + shared domain entities and repository interfaces that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Prerequisites

- \[X\] T005 PR-001: Add `lastLoginAt: DateTime?` field to UserModel in lib/shared/models/user_model.dart and update auth state listener to set it on each successful login
- \[X\] T006 PR-002: Add `completedAt: DateTime?` field to AppointmentModel in lib/shared/models/appointment_model.dart and set it when appointment status transitions to `completed`
- \[X\] T006a PR-005: Add `confirmedAt: DateTime?` field to AppointmentModel in lib/shared/models/appointment_model.dart and set it when appointment status first transitions from `pending` to `confirmed` or `scheduled`
- \[X\] T007 PR-004: Add 6th NavCard "إحصائيات الأطباء" to lib/features/admin/presentation/screens/admin_dashboard_screen.dart using existing \_NavCard pattern with Navigator.push to AnalyticsTabScreen placeholder

### Domain Entities (shared across multiple stories)

- \[X\] T008 \[P\] Create DateRange value object and AnalyticsPeriod, PayoutStatus, AlertType enums in lib/features/admin/analytics/domain/entities/date_range.dart and lib/features/admin/analytics/domain/entities/enums.dart
- \[X\] T009 \[P\] Create DoctorAnalytics entity (@freezed) in lib/features/admin/analytics/domain/entities/doctor_analytics.dart — includes all fields from [./data-model.md](./data-model.md): doctorId, doctorName, specialty, isActive, appointment counts, completionRate, financialSummary, performanceScore, patientRetentionRate (double? — nullable, populated only in getDoctorAnalyticsDetail), lastLoginAt, period
- \[X\] T010 \[P\] Create PlatformSummary entity (@freezed) in lib/features/admin/analytics/domain/entities/platform_summary.dart
- \[X\] T011 \[P\] Create FinancialSummary entity (@freezed) in lib/features/admin/analytics/domain/entities/financial_summary.dart — totalRevenue, platformCommission, netPayout, paidAmount, pendingAmount, commissionRate
- \[X\] T012 \[P\] Create PerformanceScore entity (@freezed) in lib/features/admin/analytics/domain/entities/performance_score.dart — totalScore, 4 dimension scores, hasIncompleteData, missingDimensions, isOverviewScore
- \[X\] T013 \[P\] Create AdminAlert entity (@freezed) in lib/features/admin/analytics/domain/entities/admin_alert.dart
- \[X\] T014 \[P\] Create PayoutReport and PayoutEntry entities (@freezed) in lib/features/admin/analytics/domain/entities/payout_report.dart

### Repository Interfaces

- \[X\] T015 Create AnalyticsRepository abstract interface in lib/features/admin/analytics/domain/repositories/analytics_repository.dart with methods: getPlatformSummary, getDoctorsOverview, getDoctorDetail, getDoctorTimeSeries, getAdminAlerts, acknowledgeAlert, getSpecialtyBreakdown, getPatientRetention (per contracts/repository-interfaces.md)
- \[X\] T016 Create PayoutExportRepository abstract interface in lib/features/admin/analytics/domain/repositories/payout_export_repository.dart with methods: getPayoutReportData, generatePdf, generateExcel, recordPayout (per contracts/repository-interfaces.md)

### State Classes

- \[X\] T017 Create AnalyticsFilters, AnalyticsState, FiltersState, AlertsState immutable classes in lib/features/admin/analytics/presentation/providers/state.dart — state-only data classes, no logic

### Generate Freezed Code

- \[X\] T018 Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate freezed code for all entities and verify zero errors

**Checkpoint**: Foundation ready — all entities, interfaces, and state classes exist. User story implementation can begin in parallel.

---

## Phase 3: User Story 1 — Doctors Overview + Summary Cards (Priority: P1) 🎯 MVP

**Goal**: Admin taps "إحصائيات الأطباء" NavCard, sees 4 platform summary cards + paginated sortable doctors table with filtering by period/specialty/status/search. Tapping a doctor opens detail screen shell.

**Independent Test**: Open admin dashboard → tap 6th NavCard → verify 4 summary cards show (completed appointments, revenue, avg performance, pending payouts) → verify doctors table loads with pagination → apply specialty filter → verify table updates → sort by revenue column → verify reordering.

### Data Models for US1

- \[X\] T019 \[P\] \[US1\] Create DoctorAnalyticsModel (@freezed, implements DoctorAnalytics) in lib/features/admin/analytics/data/models/doctor_analytics_model.dart with fromJson/toJson
- \[X\] T020 \[P\] \[US1\] Create PlatformSummaryModel (@freezed, implements PlatformSummary) in lib/features/admin/analytics/data/models/platform_summary_model.dart with fromJson/toJson
- \[X\] T021 \[P\] \[US1\] Create FinancialSummaryModel (@freezed, implements FinancialSummary) in lib/features/admin/analytics/data/models/financial_summary_model.dart with fromJson/toJson

### Cloud Functions for US1

- \[X\] T022 \[US1\] Implement getDoctorsOverview callable CF in functions/src/doctor_analytics.js — paginated query on appointments (cursor-based, page size 20). Per doctor: (1) apply financial eligibility rule (status=completed AND fee&gt;0, BR-001), calculate commission from platform_settings/commission.rate (FR-005), sum pendingAmount = totalRevenue − sum(doctor_payouts/{doctorId}/transactions); (2) compute **Booking Completion Rate** = completedCount / totalCount (FR-002 — used for overview column and as one performance score input); (3) compute **overview performance score** using 3-dimension redistribution per FR-008: EMR speed is omitted in batch context (querying emr_records per doctor across 500 doctors is too costly). Redistribute weights proportionally: completionRate (completed/total) × 33.33pts + patientRating (DoctorModel.rating/5.0) × 33.33pts + punctuality (completed/(completed+notCompleted) — FR-009a) × 33.33pts = 100pts. Set hasIncompleteData=true, missingDimensions=['emrSpeed'], isOverviewScore=true on the score object. Admin auth check (userType=admin). Request/response per contracts/cloud-functions.md
- \[X\] T023 \[US1\] Implement getPlatformSummary callable CF in functions/src/doctor_analytics.js — platform-wide aggregation: total completed appointments, total revenue (financial eligibility rule), total pending payouts, average performance score, active doctor count (userType=doctor AND isActive=true). Admin auth check
- \[X\] T024 \[US1\] Register getDoctorsOverview and getPlatformSummary exports in functions/index.js

### Repository + Use Cases for US1

- \[X\] T025 \[US1\] Implement AnalyticsRepositoryImpl in lib/features/admin/analytics/data/repositories/analytics_repository_impl.dart — @LazySingleton, implement getPlatformSummary() and getDoctorsOverview() calling Cloud Functions via cloud_functions package, map responses to domain entities, handle errors with Either&lt;Failure, T&gt;
- \[X\] T026 \[US1\] Create GetPlatformSummaryUseCase in lib/features/admin/analytics/domain/usecases/get_platform_summary_usecase.dart
- \[X\] T027 \[US1\] Create GetDoctorsOverviewUseCase in lib/features/admin/analytics/domain/usecases/get_doctors_overview_usecase.dart

### Providers for US1

- \[X\] T028 \[US1\] Implement FiltersProvider (StateNotifier) in lib/features/admin/analytics/presentation/providers/filters_provider.dart — manages AnalyticsPeriod (day/week/month/custom), custom date range, specialtyFilter, statusFilter (all/active/inactive), searchQuery
- \[X\] T029 \[US1\] Implement AnalyticsProvider (StateNotifier) in lib/features/admin/analytics/presentation/providers/analytics_provider.dart — loads platform summary + doctors overview, handles pagination (nextCursor), filtering (re-fetches on filter change), sorting (sortBy/sortOrder), loading/error states

### Widgets for US1

- \[X\] T030 \[US1\] Create SummaryCardsRow widget in lib/features/admin/analytics/presentation/widgets/summary_cards_row.dart — 4 RTL Arabic cards: إجمالي الحجوزات المكتملة, إجمالي الإيرادات (SAR), متوسط نقطة الأداء, المستحقات المعلقة. Loading shimmer + error states
- \[X\] T031 \[US1\] Create FiltersBar widget in lib/features/admin/analytics/presentation/widgets/filters_bar.dart — period selector (day/week/month/custom with date range picker), specialty dropdown (from clinic_types.dart), status filter (all/active/inactive), search field. RTL Arabic labels
- \[X\] T032 \[US1\] Create DoctorsOverviewTable widget in lib/features/admin/analytics/presentation/widgets/doctors_overview_table.dart — paginated table with columns: الطبيب | الحجوزات | الإيرادات | نقطة الأداء* | المستحق | الإجراءات. Sortable column headers (tap to toggle asc/desc). Pagination controls at 20 rows. The "نقطة الأداء*" column header includes an Icons.info_outline (size 14) with Tooltip: "* تقريبية (3 أبعاد) — افتح التفاصيل للنقطة الكاملة بـ 4 أبعاد". Score cells where isOverviewScore=true render value in grey italic style to visually distinguish from the full 4-dimension detail score (H2 resolution)
- \[X\] T033 \[US1\] Create DoctorTableRow widget in lib/features/admin/analytics/presentation/widgets/doctor_table_row.dart — single table row. Dimmed style + "غير نشط" badge when isActive=false (excluded from summary cards but visible in table per edge case). "عرض التفاصيل" action button

### Screen for US1

- \[X\] T034 \[US1\] Create AnalyticsTabScreen in lib/features/admin/analytics/presentation/screens/analytics_tab_screen.dart — composes SummaryCardsRow + FiltersBar + DoctorsOverviewTable. Pull-to-refresh via RefreshIndicator. Loading state with shimmer. Error state with retry button. Empty state "لا يوجد أطباء مسجلين". Consumes AnalyticsProvider and FiltersProvider

### Tests for US1

- \[X\] T035 \[P\] \[US1\] Unit test for GetPlatformSummaryUseCase in test/features/admin/analytics/domain/usecases/get_platform_summary_usecase_test.dart
- \[X\] T036 \[P\] \[US1\] Unit test for GetDoctorsOverviewUseCase in test/features/admin/analytics/domain/usecases/get_doctors_overview_usecase_test.dart
- \[X\] T037 \[P\] \[US1\] Unit test for AnalyticsProvider in test/features/admin/analytics/presentation/analytics_provider_test.dart — verify state transitions: initial → loading → loaded, filter change triggers re-fetch, sort change, pagination (loadMore), error handling
- \[X\] T038 \[P\] \[US1\] Widget test for SummaryCardsRow in test/features/admin/analytics/presentation/widgets/summary_cards_row_test.dart — verify 4 cards render with data, loading shimmer, zero state
- \[X\] T039 \[P\] \[US1\] Widget test for DoctorsOverviewTable in test/features/admin/analytics/presentation/widgets/doctors_overview_table_test.dart — verify sorting interaction, pagination controls, inactive doctor row styling
- \[X\] T039a \[P\] \[US1\] CF unit test for getDoctorsOverview in functions/test/analytics-get-doctors-overview.test.js — uses existing setup.js (emulator-backed, databaseId: 'elajtech'). Seed `appointments` + `users` collections; verify: financial eligibility rule (status=completed AND fee&gt;0 per BR-001 — zero-fee rows excluded), commission = fee × commissionRate from platform_settings/commission.rate, Booking Completion Rate = completedCount/totalCount (FR-002 formula), overview performance score: 3-dimension redistribution (completionRate×33.33 + rating×33.33 + punctuality×33.33 = 100, isOverviewScore=true, missingDimensions=['emrSpeed'], FR-008), pagination cursor returns correct next page, admin auth rejection (missing context.auth → throws unauthenticated)
- \[X\] T039b \[P\] \[US1\] CF unit test for getPlatformSummary in functions/test/analytics-get-platform-summary.test.js — uses setup.js (emulator-backed). Seed appointments + users; verify: total completed appointments count, total revenue with financial eligibility filter (completed AND fee&gt;0), pendingAmount aggregation, average overview performance score across active doctors, active doctor count filter (isActive=true AND userType=doctor — excludes isActive=false), admin auth rejection

**Checkpoint**: MVP complete. Admin can open analytics, see summary cards, browse doctors table with filter/sort/pagination. Doctor detail screen shell ready for US2.

---

## Phase 4: User Story 2 — Performance Score + Doctor Detail (Priority: P2)

**Goal**: Admin drills into a doctor's full analytics detail showing appointment stats, financial breakdown, and composite performance score (4 dimensions × 25 points from 100). Score uses DoctorModel.rating for patient rating, weight redistribution when data missing.

**Independent Test**: From overview table, tap "عرض التفاصيل" on a doctor → verify detail screen shows appointment stats (completed/cancelled/missed counts + completion rate + avg response time), financial summary (revenue, commission, net, paid/pending), and performance score breakdown with 4 dimension bars.

### Data Model for US2

- \[X\] T040 \[P\] \[US2\] Create PerformanceScoreModel (@freezed, implements PerformanceScore) in lib/features/admin/analytics/data/models/performance_score_model.dart with fromJson/toJson

### Cloud Function for US2

- \[X\] T041 \[US2\] Implement getDoctorAnalyticsDetail callable CF in functions/src/doctor_analytics.js — single doctor deep aggregation: booking stats by status (FR-001), completion rate (FR-002), avg response time from createdAt to first confirmed/scheduled status change (FR-003), financial summary with financial eligibility rule (BR-001→FR-007), performance score calculation: completionRate×25 + DoctorModel.rating/5.0×25 + punctuality(completedCount / (completedCount + notCompletedCount) × 25 — FR-009a) + emrSpeed(emr.createdAt - appointment.scheduledDateTime)×25. Weight redistribution when dimension has &lt;3 data points or &lt;30 days (FR-008). Returns appointmentStats, financialSummary, performanceScore. Admin auth check. Request/response per contracts/cloud-functions.md

### Repository + Use Cases for US2

- \[X\] T042 \[US2\] Register getDoctorAnalyticsDetail export in functions/index.js
- \[X\] T043 \[US2\] Add getDoctorDetail() method to AnalyticsRepositoryImpl in lib/features/admin/analytics/data/repositories/analytics_repository_impl.dart — calls getDoctorAnalyticsDetail CF, maps response
- \[X\] T044 \[US2\] Create GetDoctorAnalyticsDetailUseCase in lib/features/admin/analytics/domain/usecases/get_doctor_analytics_detail_usecase.dart
- \[X\] T045 \[US2\] Create GetPerformanceScoreUseCase in lib/features/admin/analytics/domain/usecases/get_performance_score_usecase.dart

### Widgets for US2

- \[X\] T046 \[US2\] Create AppointmentStatsWidget in lib/features/admin/analytics/presentation/widgets/appointment_stats_widget.dart — completed/cancelled/missed counts with colored badges, completion rate percentage, average response time in minutes. RTL Arabic labels (FR-001→FR-003)
- \[X\] T047 \[US2\] Create FinancialSummaryWidget in lib/features/admin/analytics/presentation/widgets/financial_summary_widget.dart — total revenue, platform commission (with rate %), net payout, paid vs pending breakdown. All amounts SAR with 2 decimal places (FR-004→FR-007)
- \[X\] T048 \[US2\] Create PerformanceScoreWidget in lib/features/admin/analytics/presentation/widgets/performance_score_widget.dart — total score /100 as large number, 4 dimension progress bars (معدل الإتمام, تقييم المرضى, الالتزام بالمواعيد, سرعة التقارير) with individual scores. "بيانات غير كافية" indicator when hasIncompleteData=true showing which dimensions are missing (FR-008, FR-009)

### Screen for US2

- \[X\] T049 \[US2\] Create DoctorAnalyticsDetailScreen in lib/features/admin/analytics/presentation/screens/doctor_analytics_detail_screen.dart — receives doctorId + period, calls getDoctorDetail, composes AppointmentStatsWidget + FinancialSummaryWidget + PerformanceScoreWidget in scrollable layout. RTL Arabic title with doctor name. Loading/error/empty states

### Tests for US2

- \[X\] T050 \[P\] \[US2\] Unit test for GetDoctorAnalyticsDetailUseCase in test/features/admin/analytics/domain/usecases/get_doctor_analytics_detail_usecase_test.dart
- \[X\] T051 \[P\] \[US2\] Unit test for GetPerformanceScoreUseCase in test/features/admin/analytics/domain/usecases/get_performance_score_usecase_test.dart — verify weight redistribution logic when dimensions have &lt;3 data points
- \[X\] T052 \[P\] \[US2\] Widget test for DoctorAnalyticsDetailScreen in test/features/admin/analytics/presentation/widgets/doctor_analytics_detail_screen_test.dart — verify all 3 sections render, incomplete data indicator
- \[X\] T052a \[P\] \[US2\] CF unit test for getDoctorAnalyticsDetail (core) in functions/test/analytics-get-doctor-detail.test.js — uses setup.js (emulator-backed). Verify: (1) booking stats grouped by AppointmentStatus values; (2) avg response time measured from createdAt to first confirmed/scheduled status change — appointments remaining in pending are excluded from average (M3 fix); (3) financial summary: BR-001 eligibility, commission from platform_settings/commission.rate, net rounded to 2dp; (4) full 4-dimension performance score: completionRate (FR-002: completed/total)×25, patientRating (DoctorModel.rating/5.0)×25, punctuality (FR-009a: completed/(completed+notCompleted))×25, emrSpeed (emr.createdAt−appointment.scheduledDateTime)×25; (5) weight redistribution when dimension has &lt;3 data points — missingDimensions populated, remaining weights normalized to sum to 100; (6) completed appointment with no linked EMR record → emrSpeed treated as missing data point, weight redistributed; (7) admin auth rejection

**Checkpoint**: Doctor detail screen functional with appointment stats, financial summary, and performance score. US1 overview → US2 detail navigation works end-to-end.

---

## Phase 5: User Story 8 — Specialty Distribution (Priority: P2)

**Goal**: Admin sees distribution of a doctor's bookings by service type (video/clinic from AppointmentType) and specialty (clinicType), respecting Clinic Isolation Rule.

**Independent Test**: Open doctor detail → verify specialty breakdown section shows pie/bar chart with video vs clinic percentages. Apply clinicType filter → verify only matching appointments shown.

### Implementation for US8

- \[X\] T053 \[US8\] Add specialty breakdown aggregation to getDoctorAnalyticsDetail CF response in functions/src/doctor_analytics.js — group appointments by type (video/clinic) and clinicType, calculate counts + percentages. When clinicType filter provided, add where clause (FR-012, FR-013 Clinic Isolation Rule)
- \[X\] T054 \[US8\] Add getSpecialtyBreakdown() method to AnalyticsRepositoryImpl in lib/features/admin/analytics/data/repositories/analytics_repository_impl.dart
- \[X\] T055 \[US8\] Create GetSpecialtyBreakdownUseCase in lib/features/admin/analytics/domain/usecases/get_specialty_breakdown_usecase.dart
- \[X\] T056 \[US8\] Create SpecialtyBreakdownWidget in lib/features/admin/analytics/presentation/widgets/specialty_breakdown_widget.dart — fl_chart pie chart showing distribution by AppointmentType (استشارة فيديو / زيارة عيادية) with counts and percentages. RTL Arabic labels (FR-012)
- \[X\] T057 \[US8\] Integrate SpecialtyBreakdownWidget into DoctorAnalyticsDetailScreen in lib/features/admin/analytics/presentation/screens/doctor_analytics_detail_screen.dart

### Tests for US8

- \[X\] T058 \[P\] \[US8\] Unit test for GetSpecialtyBreakdownUseCase in test/features/admin/analytics/domain/usecases/get_specialty_breakdown_usecase_test.dart
- \[X\] T059 \[P\] \[US8\] Widget test for SpecialtyBreakdownWidget in test/features/admin/analytics/presentation/widgets/specialty_breakdown_widget_test.dart — verify chart renders with data, zero-data state

**Checkpoint**: Specialty breakdown visible in doctor detail. Clinic isolation respected.

---

## Phase 6: User Story 5 — Payout Report Export (Priority: P2)

**Goal**: Admin exports monthly payout report for any doctor in PDF and Excel format. Report shows itemized bookings with fee, commission, net amount. Source of truth: CF computation from raw appointments (FR-018a — same rules as detail view).

**Independent Test**: Open doctor detail → tap export button → select month → choose PDF → verify file generates with correct layout (logo header, doctor info, itemized table, summary footer). Choose Excel → verify tabular format with same data. Verify financial data matches detail view exactly.

### Data Model for US5

- \[X\] T060 \[P\] \[US5\] Create PayoutReportModel and PayoutEntryModel (@freezed) in lib/features/admin/analytics/data/models/payout_report_model.dart implementing entities with fromJson/toJson

### Cloud Function for US5

- \[X\] T061 \[US5\] Implement exportPayoutReport callable CF in functions/src/doctor_analytics.js — query appointments for given doctorId+year+month, apply financial eligibility rule BR-001 (completed AND fee&gt;0), for each row calculate: fee (gross), commission (fee × commissionRate from platform_settings), netAmount (fee − commission). Round all amounts to 2dp. Return structured report with entries + totals. Admin auth check. Request/response per contracts/cloud-functions.md (FR-017, FR-018, FR-018a)
- \[X\] T062 \[US5\] Register exportPayoutReport export in functions/index.js

### Repository + Use Case for US5

- \[X\] T063 \[US5\] Implement PayoutExportRepositoryImpl in lib/features/admin/analytics/data/repositories/payout_export_repository_impl.dart — @LazySingleton, getPayoutReportData() calls exportPayoutReport CF, generatePdf() uses pdf package to create invoice template: header with clinic logo, doctor info section, itemized bookings table (date, patient, status, fee, commission, net), summary footer with totals. generateExcel() uses syncfusion_flutter_xlsio for tabular format with same structure (FR-017a)
- \[X\] T064 \[US5\] Create ExportPayoutReportUseCase in lib/features/admin/analytics/domain/usecases/export_payout_report_usecase.dart

### Widget + Integration for US5

- \[X\] T065 \[US5\] Create PayoutExportButton widget in lib/features/admin/analytics/presentation/widgets/payout_export_button.dart — month/year picker, PDF/Excel format toggle, "تصدير التقرير" button with loading spinner. Error state with retry. "لا توجد بيانات لهذه الفترة" when no appointments. Save file using printing package (PDF) or file write (Excel)
- \[X\] T066 \[US5\] Integrate PayoutExportButton into DoctorAnalyticsDetailScreen in lib/features/admin/analytics/presentation/screens/doctor_analytics_detail_screen.dart

### Payout Action for FR-007

- \[X\] T066a \[US5\] Implement recordPayout callable CF in functions/src/doctor_analytics.js — admin-only (userType=admin auth check via context.auth). Accepts: `{ doctorId: string, amount: number, currency: 'SAR', note?: string }`. Validates: amount &gt; 0, doctorId exists in users collection. Writes append-only document to `doctor_payouts/{doctorId}/transactions/{auto-id}`: `{ amount, status: amount &gt;= currentPendingAmount ? 'paid' : 'partial', recordedAt: FieldValue.serverTimestamp(), recordedByUid: context.auth.uid, note: note ?? null }`. `currentPendingAmount` computed from totalRevenue − sum of existing transactions for this doctorId. console.log(`[PAYOUT] doctorId:${doctorId} | amount:${amount} | status:${status} | by:${uid}`) (NFR-005). Register export in functions/index.js
- \[X\] T066b \[US5\] Add recordPayout() method to PayoutExportRepositoryImpl in lib/features/admin/analytics/data/repositories/payout_export_repository_impl.dart — calls recordPayout CF via `FirebaseFunctions.instanceFor(region: 'europe-west1')`, maps HttpsCallableResult to `Either<Failure, Unit>`. Create RecordPayoutUseCase in lib/features/admin/analytics/domain/usecases/record_payout_usecase.dart — takes doctorId, amount, optional note; delegates to repository; returns Either&lt;Failure, Unit&gt;
- \[X\] T066c \[US5\] Add "تسجيل صرف" action to FinancialSummaryWidget in lib/features/admin/analytics/presentation/widgets/financial_summary_widget.dart — show TextButton "تسجيل صرف" when pendingAmount &gt; 0. Tap opens BottomSheet with: numeric amount TextField (pre-filled with pendingAmount, editable for partial disbursement, validates amount &gt; 0 AND amount &lt;= pendingAmount), optional note TextField, "تأكيد الصرف" ElevatedButton. On submit: call RecordPayoutUseCase, show CircularProgressIndicator, disable button. On success: close sheet, show SnackBar "تم تسجيل الصرف بنجاح", call setState to refresh financial section. On failure: show error SnackBar with retry option. Display "مدفوع بالكامل" green badge when paidAmount &gt;= totalRevenue (FR-007, BR-002)
- \[X\] T066d \[P\] \[US5\] CF unit test for recordPayout in functions/test/analytics-record-payout.test.js — uses setup.js (emulator-backed). Verify: (1) valid call creates document in doctor_payouts/{doctorId}/transactions/ with correct amount, recordedByUid=context.auth.uid, serverTimestamp; (2) amount &lt; currentPendingAmount → status='partial'; amount &gt;= currentPendingAmount → status='paid'; (3) invalid doctorId (not in users collection) → throws not-found; (4) amount &lt;= 0 → throws invalid-argument; (5) missing context.auth → throws unauthenticated; (6) console.log called with '[PAYOUT]' prefix per NFR-005

### Tests for US5

- \[X\] T067 \[P\] \[US5\] Unit test for ExportPayoutReportUseCase in test/features/admin/analytics/domain/usecases/export_payout_report_usecase_test.dart
- \[X\] T068 \[P\] \[US5\] Unit test for PayoutExportRepositoryImpl in test/features/admin/analytics/data/repositories/payout_export_repository_impl_test.dart — verify PDF generation from mock CF response, verify Excel generation, verify financial calculations match
- \[X\] T069 \[P\] \[US5\] Widget test for PayoutExportButton in test/features/admin/analytics/presentation/widgets/payout_export_button_test.dart — verify export trigger, loading state, no-data message
- \[X\] T069a \[P\] \[US5\] CF unit test for exportPayoutReport in functions/test/analytics-export-payout-report.test.js — uses setup.js (emulator-backed). Verify: financial eligibility rule applied per BR-001 (only status=completed AND fee&gt;0), per-row calculation: fee=gross amount, commission=fee×commissionRate from platform_settings/commission.rate, netAmount=fee−commission, all amounts rounded to 2dp; totals sum correctly across all qualifying rows; empty month (no eligible appointments) returns entries=[] with totalRevenue=0 and totals zeroed; calculation rules identical to getDoctorAnalyticsDetail financial summary — seed same doctor data, call both CFs, assert equal financial totals (FR-018a consistency check); admin auth rejection

**Checkpoint**: PDF and Excel export working. Financial data in report matches detail view exactly.

---

## Phase 7: User Story 3 — Time-Series Charts (Priority: P3)

**Goal**: Admin sees daily/weekly/monthly performance charts for each doctor with automatic period-over-period comparison showing % change.

**Independent Test**: Open doctor detail → select monthly granularity for last 6 months → verify line chart renders with data points → verify % change badge comparing to previous period. Select daily view with only 2 data points → verify single markers (not connected lines). Select period with only 1 data point → verify bar chart without comparison.

### Implementation for US3

- \[X\] T070 \[US3\] Add time-series aggregation to getDoctorAnalyticsDetail CF response in functions/src/doctor_analytics.js — query appointments by doctorId in period, group by granularity (day/week/month), compute data points (appointments count, revenue, performanceScore, completionRate per bucket). Calculate previous period comparison with % change. Require min 2 data points per period for comparison (FR-010, FR-011)
- \[X\] T071 \[US3\] Add getDoctorTimeSeries() method to AnalyticsRepositoryImpl in lib/features/admin/analytics/data/repositories/analytics_repository_impl.dart
- \[X\] T072 \[US3\] Create TimeSeriesChartWidget in lib/features/admin/analytics/presentation/widgets/time_series_chart_widget.dart — fl_chart line chart (default), granularity selector tabs (يومي/أسبوعي/شهري), &lt; 3 data points render as single markers not connected lines, single month renders as bar chart. Period comparison badge: "↑ 15.4%" green or "↓ 8.2%" red. "لا تتوفر بيانات كافية للمقارنة" when comparison unavailable (FR-010, FR-011)
- \[X\] T073 \[US3\] Integrate TimeSeriesChartWidget into DoctorAnalyticsDetailScreen in lib/features/admin/analytics/presentation/screens/doctor_analytics_detail_screen.dart

### Tests for US3

- \[X\] T074 \[P\] \[US3\] CF unit test for time-series aggregation in functions/test/analytics-time-series.test.js — uses setup.js (emulator-backed). Verify: appointments grouped into correct daily/weekly/monthly buckets by completedAt; period-over-period % change = (current − previous) / previous × 100 rounded to 1dp; when previous period total = 0 → comparison=null (never Infinity or NaN); when either period has &lt;2 data points → hasComparison=false, comparison field omitted; single appointment per bucket → isMarker=true (point, not connected line per FR-010); admin auth rejection
- \[X\] T075 \[P\] \[US3\] Widget test for TimeSeriesChartWidget in test/features/admin/analytics/presentation/widgets/time_series_chart_widget_test.dart — verify chart renders with normal data, sparse data (&lt; 3 points), single data point, comparison badge

**Checkpoint**: Time-series charts visible in doctor detail with period-over-period comparison.

---

## Phase 8: User Story 4 — Smart Alerts (Priority: P3)

**Goal**: Admin receives automatic in-app alerts when: doctor's pending payout exceeds 5000 SAR, completion rate drops below 70% (trailing 30 days), or doctor inactive for 7+ days. Alerts are deduplicated: one active alert per doctor per condition type.

**Independent Test**: Create test data where doctor has pendingPayout &gt; 5000 SAR → trigger checkAdminAlerts scheduled CF → verify alert document appears in admin_alerts collection → open analytics screen → verify alert shows in alerts panel with type badge and trigger value → acknowledge alert → verify isRead=true.

### Data Model for US4

- \[X\] T076 \[P\] \[US4\] Create AdminAlertModel (@freezed, implements AdminAlert) in lib/features/admin/analytics/data/models/admin_alert_model.dart with fromJson/toJson

### Cloud Functions for US4

- \[X\] T077 \[US4\] Implement checkAdminAlerts scheduled CF using Firebase Functions v2 `onSchedule` (every 60 minutes, europe-west1) in functions/src/doctor_analytics.js — query all active doctors (userType=doctor), for each evaluate 3 conditions: (1) financial: sum pending payouts, compare to admin_settings/alert_thresholds.payoutThreshold (default 5000 SAR), (2) performance: completion rate over trailing 30 days, compare to completionRateThreshold (default 0.70), (3) activity: days since lastLoginAt (PR-001), compare to inactivityDaysThreshold (default 7). Deduplication (FR-014a): query existing active alert for same doctorId+type, if found update createdAt instead of creating new. Write to admin_alerts collection. Log all evaluations via console.log (FR-014, FR-015, FR-016)
- \[X\] T078 \[US4\] Implement getAdminAlerts callable CF in functions/src/doctor_analytics.js — query admin_alerts collection with optional includeRead filter, limit 50, ordered by createdAt desc. Return alerts + unreadCount. Implement acknowledgeAlert callable CF — set isRead=true and resolvedAt=now on given alertId. Admin auth check on both
- \[X\] T079 \[US4\] Register checkAdminAlerts using functions/v2 scheduler `onSchedule({schedule: 'every 60 minutes', region: 'europe-west1', timeZone: 'UTC'})`, getAdminAlerts, acknowledgeAlert exports in functions/index.js

### Repository + Use Case for US4

- \[X\] T080 \[US4\] Add getAdminAlerts() and acknowledgeAlert() methods to AnalyticsRepositoryImpl in lib/features/admin/analytics/data/repositories/analytics_repository_impl.dart
- \[X\] T081 \[US4\] Create GetAdminAlertsUseCase in lib/features/admin/analytics/domain/usecases/get_admin_alerts_usecase.dart

### Provider + Widget for US4

- \[X\] T082 \[US4\] Implement AlertsProvider (StateNotifier) in lib/features/admin/analytics/presentation/providers/alerts_provider.dart — loads alerts via getAdminAlerts, tracks unreadCount, acknowledgeAlert sets isRead and decrements unreadCount
- \[X\] T083 \[US4\] Create AdminAlertsWidget in lib/features/admin/analytics/presentation/widgets/admin_alerts_widget.dart — alert cards with type badge (مالي/أداء/نشاط), doctor name, trigger value, threshold, timestamp. "تم القراءة" acknowledge button. Unread count badge. In-app only per FR-014b
- \[X\] T084 \[US4\] Integrate AdminAlertsWidget into AnalyticsTabScreen in lib/features/admin/analytics/presentation/screens/analytics_tab_screen.dart — alerts section above or alongside summary cards

### Tests for US4

- \[X\] T085 \[P\] \[US4\] Unit test for GetAdminAlertsUseCase in test/features/admin/analytics/domain/usecases/get_admin_alerts_usecase_test.dart
- \[X\] T086 \[P\] \[US4\] Unit test for AlertsProvider in test/features/admin/analytics/presentation/alerts_provider_test.dart — verify loading, loaded, acknowledgment flow, unread count tracking
- \[X\] T087 \[P\] \[US4\] Widget test for AdminAlertsWidget in test/features/admin/analytics/presentation/widgets/admin_alerts_widget_test.dart — verify alert card rendering by type, acknowledge interaction
- \[X\] T087a \[P\] \[US4\] CF unit test for checkAdminAlerts in functions/test/analytics-check-admin-alerts.test.js — uses setup.js (emulator-backed). Verify all 3 alert conditions independently: (1) financial: doctor with pendingAmount &gt; admin_settings/alert_thresholds.payoutThreshold → creates document in admin_alerts with type='financial', correct doctorId, triggerValue; (2) performance: completionRate (trailing 30 days) &lt; completionRateThreshold → creates alert type='performance'; (3) activity: lastLoginAt older than inactivityDaysThreshold days → creates alert type='activity'; deduplication (FR-014a): second CF run for same doctorId+type → updates createdAt on existing document, no duplicate created, document count unchanged; doctor with isActive=false is skipped entirely; threshold values read from Firestore admin_settings doc — verify by seeding different threshold values between test cases (not hardcoded)

**Checkpoint**: Alerts system fully functional. Admin sees real-time deduplicated alerts, can acknowledge them.

---

## Phase 9: User Story 7 — Patient Retention Rate (Priority: P3)

**Goal**: Admin sees patient retention rate (% of returning patients) for each doctor. Requires minimum 5 unique patients — below that shows "غير متوفر — بيانات غير كافية".

**Independent Test**: Open doctor detail for a doctor with 100 patients (30 returning) → verify retention shows 30%. Open doctor detail for doctor with 3 patients → verify "غير متوفر — بيانات غير كافية" message.

### Implementation for US7

- \[X\] T088 \[US7\] Add patient retention calculation to getDoctorAnalyticsDetail CF response in functions/src/doctor_analytics.js — query appointments by doctorId, group by patientId, count unique patients, count patients with 2+ appointments (returning), calculate ratio. Set hasSufficientData = totalUniquePatients &gt;= 5 (FR-021)
- \[X\] T089 \[US7\] Add getPatientRetention() method to AnalyticsRepositoryImpl in lib/features/admin/analytics/data/repositories/analytics_repository_impl.dart
- \[X\] T090 \[US7\] Create GetPatientRetentionUseCase in lib/features/admin/analytics/domain/usecases/get_patient_retention_usecase.dart
- \[X\] T091 \[US7\] Create PatientRetentionWidget in lib/features/admin/analytics/presentation/widgets/patient_retention_widget.dart — displays retention rate as percentage with circular indicator when hasSufficientData=true. Shows "غير متوفر — بيانات غير كافية" when hasSufficientData=false. RTL Arabic (FR-021, FR-022)
- \[X\] T092 \[US7\] Integrate PatientRetentionWidget into DoctorAnalyticsDetailScreen in lib/features/admin/analytics/presentation/screens/doctor_analytics_detail_screen.dart

### Tests for US7

- \[X\] T093 \[P\] \[US7\] Unit test for GetPatientRetentionUseCase in test/features/admin/analytics/domain/usecases/get_patient_retention_usecase_test.dart — verify retention calculation, 5-patient minimum threshold, edge cases (0 patients, all returning, none returning)
- \[X\] T094 \[P\] \[US7\] Widget test for PatientRetentionWidget in test/features/admin/analytics/presentation/widgets/patient_retention_widget_test.dart — verify percentage display and insufficient-data message

**Checkpoint**: Patient retention rate visible in doctor detail with proper data-sufficiency handling.

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Error handling, logging, security validation, edge cases, and final verification

- \[X\] T095 Add network error handling across AnalyticsProvider and AlertsProvider — on failure show last cached data with "قد لا تكون البيانات محدثة" indicator + retry button. Handle zero-fee anomalies by logging and excluding from financial aggregation (FR-004 edge case)
- \[X\] T096 \[P\] Verify console.log instrumentation in all Cloud Functions (getDoctorsOverview, getDoctorAnalyticsDetail, getPlatformSummary, exportPayoutReport, recordPayout, checkAdminAlerts, getAdminAlerts, acknowledgeAlert) per NFR-005. Verify firebase_crashlytics captures client-side errors
- \[X\] T097 \[P\] Verify admin-only auth check (userType == 'admin' via context.auth) on all 7 callable Cloud Functions per NFR-003. Ensure no patient PHI exposed in analytics responses (only patientName in export reports for admin)
- \[X\] T098 Run `flutter analyze` and fix all errors and warnings. Run `flutter pub run build_runner build --delete-conflicting-outputs` to verify all freezed models generate cleanly
- \[X\] T099 Run full [./quickstart.md](./quickstart.md) verification checklist from specs/010-doctor-analytics-dashboard/quickstart.md — validate all 17 checklist items pass

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **US1 / Phase 3**: Depends on Phase 2 only — no dependencies on other stories
- **US2 / Phase 4**: Depends on Phase 2 + Phase 3 (adds to repo impl, creates detail screen)
- **US8 / Phase 5**: Depends on Phase 2 + Phase 4 (adds widget to detail screen)
- **US5 / Phase 6**: Depends on Phase 2 + Phase 4 (adds export button to detail screen)
- **US3 / Phase 7**: Depends on Phase 2 + Phase 4 (adds chart to detail screen)
- **US4 / Phase 8**: Depends on Phase 2 only (independent — alerts on overview screen)
- **US7 / Phase 9**: Depends on Phase 2 + Phase 4 (adds widget to detail screen)
- **Polish / Phase 10**: Depends on all desired user stories being complete

### User Story Dependencies

```
Phase 1 (Setup)
    └── Phase 2 (Foundational)
            ├── Phase 3: US1 (P1) MVP
            │       └── Phase 4: US2 (P2) Detail Screen
            │               ├── Phase 5: US8 (P2) Specialty
            │               ├── Phase 6: US5 (P2) Export
            │               ├── Phase 7: US3 (P3) Charts
            │               └── Phase 9: US7 (P3) Retention
            └── Phase 8: US4 (P3) Alerts [independent]
    └── Phase 10: Polish
```

### Within Each User Story

- Data models before repository implementations
- Cloud Functions before repository methods that call them
- Use cases before providers
- Providers before widgets
- Widgets before screens
- Tests after implementation (can be parallel within story)

### Parallel Opportunities

- **Phase 1**: T001, T002, T003, T004 all independent
- **Phase 2**: T008–T014 (all entities) fully parallel
- **Phase 3**: T019–T021 (models) parallel; T035–T039b (tests) parallel
- **Phase 4**: T040 parallel with CF work; T050–T052 (tests) parallel
- **Phase 5–9**: US8, US5, US3 can proceed in parallel after US2 (different widgets + CF additions). US4 is fully independent of US2.
- **Phase 10**: T096, T097 parallel

---

## Parallel Example: User Story 1

```
# Models (parallel):
T019: DoctorAnalyticsModel    ──┐
T020: PlatformSummaryModel    ──┤── then T022, T023 (CFs)
T021: FinancialSummaryModel   ──┘
                                 │
# After CFs + repo (T022-T025): │
T026: GetPlatformSummaryUseCase ─┤── parallel
T027: GetDoctorsOverviewUseCase ─┘
                                 │
# After providers (T028-T029):  │
T030: SummaryCardsRow       ─────┐
T031: FiltersBar            ─────┤── parallel
T032: DoctorsOverviewTable  ─────┤
T033: DoctorTableRow        ─────┘
                                 │
# Tests (all parallel):         │
T035-T039b ─────────────────────┘
```

## Parallel Example: Post-US2 Parallel Execution

```
After US2 (Phase 4) completes, up to 4 stories can proceed in parallel:

Developer A: US8 (Phase 5) — Specialty Distribution
Developer B: US5 (Phase 6) — Payout Export
Developer C: US4 (Phase 8) — Smart Alerts  ← fully independent
Developer D: US3 (Phase 7) — Time-Series Charts

Then sequentially:
Any Dev: US7 (Phase 9) — Patient Retention
Lead:    Phase 10 — Polish
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T004)
2. Complete Phase 2: Foundational (T005–T018)
3. Complete Phase 3: US1 (T019–T039b)
4. **STOP and VALIDATE**: Test overview screen independently
5. Deploy Cloud Functions (getDoctorsOverview, getPlatformSummary)
6. Demo MVP — admin can see platform summary and browse all doctors

### Incremental Delivery

| Step | Add | Delivers | Cumulative FRs |
|------|-----|----------|----------------|
| 1 | Setup + Foundational | Foundation ready | Prerequisites |
| 2 | + US1 | Overview + Summary + Table | FR-001→FR-007, FR-019, FR-020 |
| 3 | + US2 | Performance Score + Detail | + FR-008, FR-009 |
| 4 | + US8 | Specialty Distribution | + FR-012, FR-013 |
| 5 | + US5 | Payout Export | + FR-017, FR-017a, FR-018, FR-018a |
| 6 | + US3 | Time-Series Charts | + FR-010, FR-011 |
| 7 | + US4 | Smart Alerts | + FR-014→FR-016, FR-014a, FR-014b |
| 8 | + US7 | Patient Retention | + FR-021, FR-022 |
| 9 | + Polish | Production-ready | All 28 FRs + 6 NFRs |

### Suggested MVP Scope

**US1 only** (T001–T039): Admin opens analytics screen, sees 4 platform summary cards (completed appointments, revenue, avg performance, pending payouts), browses all doctors in a paginated sortable table with filter by period/specialty/status/search. Delivers immediate operational value — admin can monitor entire platform at a glance.

---

## Notes

- \[P\] = different files, no dependencies on incomplete work
- \[Story\] label maps task to specific user story for traceability
- US6 (Sorting/Comparison) merged into US1 — sortable columns built into overview table
- getDoctorAnalyticsDetail CF grows incrementally: US2 adds core → US3 adds time-series → US7 adds retention → US8 adds specialty
- All amounts in SAR, rounded to 2 decimal places
- All timestamps UTC
- RTL Arabic UI throughout
- 80%+ test coverage target per [./plan.md](./plan.md) constraint
- Financial Eligibility Rule: `status == 'completed' AND fee > 0` — consolidated as BR-001 in spec.md, referenced in US1, US2, US5
- Patient ratings source: `DoctorModel.rating` only (0.0-5.0) — no separate ratings collection exists or is planned (CHK051 final)
- patientName policy: full name visible to admin in export reports, no masking needed (NFR-003 admin-only access)
- Scheduled CF uses Firebase Functions v2 `onSchedule` (not Pub/Sub) — see T077, T079
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
