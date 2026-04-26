# Research: Doctor Analytics Dashboard

**Branch**: `010-doctor-analytics-dashboard` | **Date**: 2026-04-25

## Research Tasks

### R-001: Firestore Aggregation Strategy for Doctor Analytics

**Decision**: Use Cloud Functions for on-demand aggregation. No caching — source of truth is always raw appointments (CHK046).

**Rationale**: Firestore client SDK does not support complex aggregation queries (SUM, AVG, GROUP BY). With up to 500 doctors and potentially thousands of appointments, client-side aggregation would require downloading all appointment documents — impractical for mobile. Cloud Functions can run server-side queries and aggregate efficiently. The client calls CF on-demand per filter change; no pre-computed cache is stored.

**Override note**: Initial plan included caching results in a `doctor_analytics` collection. This was overridden after CHK046 established that the source of truth must always be live CF computation from raw appointments — cached values risk staleness and inconsistency with the detail view (FR-018a).

**Alternatives considered**:
1. **Client-side aggregation**: Fetch all appointments and compute in Dart. Rejected — would require downloading thousands of documents, exceeding Firestore read quotas and degrading mobile performance.
2. **Firestore count() aggregation**: Only supports COUNT, not SUM/AVG. Insufficient for financial calculations.
3. **Scheduled Cloud Functions only (no real-time)**: Would miss recent data. Hybrid approach (callable + scheduled) ensures freshness.

**Implementation approach**:
- Callable CF `getDoctorsOverview`: Aggregates per-doctor summary from `appointments` collection, returns list of `DoctorAnalyticsModel`.
- Callable CF `getDoctorDetail`: Deep aggregation for single doctor (time-series, retention, specialty breakdown).
- Callable CF `getPlatformSummary`: Platform-wide aggregation for summary cards.
- Scheduled CF `checkAdminAlerts`: Runs hourly to evaluate alert conditions and write to `admin_alerts` collection.
- Callable CF `exportPayoutReport`: Generates report data server-side, returns structured data for client-side PDF/Excel rendering.

### R-002: Time-Series Data Storage

**Decision**: Compute on-demand from `appointments` collection using date-range queries in Cloud Functions. No pre-computed time-series documents.

**Rationale**: Time-series needs are flexible (daily/weekly/monthly, custom ranges). Pre-computing for every granularity would bloat storage. Firestore supports efficient `where('doctorId', '==', id).where('completedAt', '>=', start).where('completedAt', '<=', end).orderBy('completedAt')` queries with composite indexes. Cloud Function aggregates the results into the required granularity. **Note**: `completedAt` field requires PR-002 prerequisite — queries fall back to `scheduledDateTime` if `completedAt` is null.

**Alternatives considered**:
1. **Pre-computed daily/weekly/monthly snapshots**: Would require maintenance and storage. Overkill for admin-only analytics.
2. **Third-party analytics service (e.g., BigQuery)**: Adds cost and complexity. Not justified for 500-doctor scale.

### R-003: PDF/Excel Export Strategy

**Decision**: Client-side generation using existing `pdf` + `printing` packages (already in pubspec.yaml). For Excel, add `syncfusion_flutter_xlsio` (free for non-commercial use, no Office dependency).

**Rationale**: The project already has `pdf ^3.11.3` and `printing ^5.14.2` as dependencies. Client-side generation avoids server-side file storage and download complexity. Cloud Function provides the structured data, Flutter generates the file.

**Alternatives considered**:
1. **Server-side PDF generation (Cloud Functions)**: Requires headless Chrome or pdfkit in Node.js — complex deployment. Rejected.
2. **csv instead of Excel**: Less professional for accounting purposes. Excel is preferred.
3. **`excel` package**: Popular but `syncfusion_flutter_xlsio` offers better formatting and is free community license.

### R-004: Charts Library Selection

**Decision**: Use `fl_chart` (^0.69.0) for time-series line charts and bar charts.

**Rationale**: `fl_chart` is the most popular Flutter charting library, well-maintained, supports line/bar/pie charts with animations and touch interactions. Lightweight, no native dependencies, works on all platforms.

**Alternatives considered**:
1. **`syncfusion_flutter_charts`**: More feature-rich but heavier package. Overkill for admin-only charts.
2. **`charts_flutter`**: Deprecated (Google discontinued).
3. **Custom Canvas painting**: Too much effort for standard chart types.

### R-005: Performance Score Calculation

**Decision**: Compute in Cloud Function using weighted formula, store as part of `DoctorAnalytics`.

**Rationale**: Performance score requires data from multiple sources (appointments for completion rate, `DoctorModel.rating` for patient reviews, appointments for punctuality, `emr_records.createdAt` for report speed). Only Cloud Functions can efficiently cross-reference these collections server-side.

**Formula** (from FR-008):
- Completion Rate: 25 points (`completion_rate * 25`)
- Patient Ratings: 25 points (`DoctorModel.rating / 5.0 * 25`) — **sole source**: denormalized aggregate field from doctor's user document. No separate `ratings` Firestore collection exists or is planned. No per-booking ratings exist. Final decision per CHK051.
- Punctuality: 25 points (`on_time_ratio * 25`)
- EMR Report Speed: 25 points (`within_threshold_ratio * 25`) — measured from `appointment.scheduledDateTime` to `emr.createdAt` (EMR records have `createdAt` only, no `updatedAt` or `completedAt`)

For missing dimensions (< 3 data points or < 30 days history), the score is calculated from available dimensions only with proportional weight redistribution (FR-008). Sets `hasIncompleteData = true` and lists `missingDimensions`.

### R-006: Pagination Strategy for Doctors Table

**Decision**: Firestore cursor-based pagination with page size of 20, implemented in Cloud Function.

**Rationale**: Firestore `limit()` + `startAfterDocument()` is the standard pagination pattern. Cloud Function handles the query, applies filters and sorting, returns paginated results. Client-side Riverpod provider manages the pagination state.

**Alternatives considered**:
1. **Infinite scroll**: Good UX but more complex state management. Can be added later.
2. **Load all at once**: Works for <50 doctors but violates SC-006 (500 doctors).
3. **Client-side pagination**: Would still require downloading all data. Server-side is more efficient.

### R-007: Alert Evaluation Mechanism

**Decision**: Scheduled Cloud Function runs every hour, evaluates all alert conditions, writes matching alerts to `admin_alerts` Firestore collection. Client reads from this collection in real-time via `snapshots()` stream. **Deduplication rule** (FR-014a): one active alert per doctor per condition type. If condition persists, existing alert is updated (renewed `createdAt`) rather than creating a duplicate.

**Rationale**: Alerts require cross-referencing multiple data points (pending payouts, completion rates, last login timestamps). A scheduled function is the most efficient way to evaluate all conditions periodically. Writing results to a collection allows real-time client updates via Firestore listeners.

**Alert conditions** (from FR-014, FR-015, FR-016):
1. Financial: `pendingPayout > threshold` — threshold from `admin_settings/alert_thresholds.payoutThreshold` (default **5000 SAR**, CHK010)
2. Performance: `completionRate < 0.70` over last 30 days (trailing from current date, CHK017)
3. Activity: `lastLoginAt > now - 7 days` — requires PR-001 prerequisite (`lastLoginAt` field on `UserModel`)

**Configuration source**: `admin_settings/alert_thresholds` Firestore document with fields: `payoutThreshold` (5000.0), `completionRateThreshold` (0.70), `inactivityDaysThreshold` (7).

### R-008: Patient Retention Rate Calculation

**Decision**: Cloud Function aggregates unique patients per doctor, counts repeat patients (2+ appointments with same doctor), returns ratio.

**Rationale**: Requires scanning all appointments for a doctor and grouping by patient. Server-side aggregation is efficient using Firestore queries. The function counts distinct patients who appear more than once.

**Formula** (from FR-021):
```
retention_rate = patients_with_2plus_appointments / total_unique_patients
```
Minimum threshold: **5 unique patients** before displaying (FR-021, CHK012) — below this shows "غير متوفر — بيانات غير كافية". Avoids misleading small-sample statistics.

### R-009: Clinic Isolation Rule Compliance

**Decision**: All analytics queries accept an optional `clinicType` filter. When specified, queries add `where('clinicType', '==', type)` to isolate data per specialty. Each specialty's analytics remain independent.

**Rationale**: The existing project uses `clinicType` field on appointments and doctors (from `shared/constants/clinic_types.dart`). The Clinic Isolation Rule (Rule #9 in important-rules.md) requires independent models and repositories per specialty. Analytics queries must respect this by allowing clinic-specific filtering while the overview table shows all clinics aggregated.

### R-010: Firestore Index Requirements

**Decision**: Define composite indexes in `firestore.indexes.json` for all analytics query patterns.

**Required indexes**:
1. `appointments`: `(doctorId, status, completedAt)` — booking stats by doctor
2. `appointments`: `(doctorId, completedAt)` — time-series by doctor
3. `appointments`: `(doctorId, status)` — status counts
4. `appointments`: `(doctorId, patientId)` — retention calculation
5. `appointments`: `(status, completedAt)` — platform-wide aggregation
6. `users`: `(userType, isActive)` — active doctor count
7. `admin_alerts`: `(type, createdAt)` — alert listing

**Rationale**: Firestore requires composite indexes for multi-field queries. Without them, queries will fail at runtime. The indexes file is already tracked in the project (`firestore.indexes.json`). **Note**: Indexes using `completedAt` (indexes 1, 2, 4) require PR-002 prerequisite. Deploy indexes after adding the field.

## Resolved Decisions Summary

| ID | Decision | Key Choice |
|----|----------|------------|
| R-001 | Aggregation strategy | Cloud Functions, on-demand (no cache) — override: caching removed per CHK046 |
| R-002 | Time-series storage | On-demand from appointments |
| R-003 | PDF/Excel export | Client-side (pdf + syncfusion_flutter_xlsio) |
| R-004 | Charts library | fl_chart |
| R-005 | Performance score | CF computed, weighted formula using DoctorModel.rating (sole source — no separate ratings collection) |
| R-006 | Pagination | Server-side cursor-based, page size 20 |
| R-007 | Alert mechanism | Scheduled CF hourly, Firestore collection, deduplicated per doctor per type |
| R-008 | Retention calculation | CF aggregated, min 5 patients threshold (FR-021) |
| R-009 | Clinic isolation | Optional clinicType filter on all queries |
| R-010 | Firestore indexes | 7 composite indexes defined |
