# Data Model: Doctor Analytics Dashboard

**Branch**: `010-doctor-analytics-dashboard` | **Date**: 2026-04-25

## Entity Relationship Overview

```
PlatformSummary (1) ←── computed from ──→ AppointmentModel (many)
DoctorAnalytics (N) ←── computed from ──→ AppointmentModel (many)
DoctorAnalytics (1) ──→ has one ──→ FinancialSummary
DoctorAnalytics (1) ──→ has one ──→ PerformanceScore
DoctorAnalytics (1) ──→ has one ──→ PayoutReport (per period)
AdminAlert (N) ←── triggered by ──→ DoctorAnalytics / UserModel
```

## Entities

### PlatformSummary

Maps to: Summary Cards row in analytics tab (US1). Aggregated platform-wide.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| totalCompletedAppointments | `int` | All completed appointments in period | >= 0 |
| totalRevenue | `double` | Sum of all appointment fees in period | >= 0.0 |
| totalPendingPayouts | `double` | Sum of all pending doctor payouts | >= 0.0 |
| averagePerformanceScore | `double` | Mean of all active doctors' scores | 0.0 - 100.0 |
| activeDoctorsCount | `int` | Doctors with isActive=true and userType=doctor | >= 0 |
| period | `DateRange` | The time period this summary covers | required |

### DoctorAnalytics

Maps to: One row in Doctors Overview Table (US1). Also populates detail screen.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| doctorId | `String` | Firestore document ID from users collection | required, non-empty |
| doctorName | `String` | Full name from user model | required |
| profileImage | `String?` | Profile image URL | nullable URL |
| specialty | `String` | Primary specialization (`clinicType` from `clinic_types.dart`) | required, fallback "General" |
| isActive | `bool` | Whether doctor account is active | required |
| totalAppointments | `int` | All appointments in period | >= 0 |
| completedAppointments | `int` | Completed status count | >= 0 |
| cancelledAppointments | `int` | Cancelled status count | >= 0 |
| noShowAppointments | `int` | Patient no-show count (`missed` status) | >= 0 |
| completionRate | `double` | completedAppointments / totalAppointments | 0.0 - 1.0 |
| averageResponseTime | `double?` | Avg minutes from `appointment.createdAt` to first `confirmed`/`scheduled` status change | >= 0.0, nullable |
| financialSummary | `FinancialSummary` | Embedded financial data | required |
| performanceScore | `PerformanceScore` | Embedded score data (weights redistributed if incomplete) | required |
| pendingPayout | `double` | Current pending payout amount | >= 0.0 |
| payoutStatus | `PayoutStatus` | paid / pending / partial (transitions require admin action) | enum |
| patientRetentionRate | `double?` | Ratio of returning patients (min 5 unique patients required) | 0.0 - 1.0, nullable |
| lastLoginAt | `DateTime?` | Doctor's last login timestamp (PR-001 prerequisite) | nullable |
| period | `DateRange` | Period these analytics cover (UTC boundaries) | required |

### FinancialSummary

Maps to: Financial breakdown section in doctor detail (US1, FR-004 through FR-007). Source of truth: Cloud Function computation from raw `appointments`. All amounts in SAR, rounded to 2 decimal places.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| totalRevenue | `double` | Sum of `fee` from appointments where `status == 'completed'` AND `fee > 0` | >= 0.0 |
| platformCommission | `double` | totalRevenue * commissionRate (from `platform_settings/commission.rate`, default 0.15) | >= 0.0 |
| netPayout | `double` | totalRevenue - platformCommission | >= 0.0 |
| paidAmount | `double` | Amount already disbursed to doctor (admin action) | >= 0.0 |
| pendingAmount | `double` | Amount awaiting disbursement | >= 0.0 |
| commissionRate | `double` | Platform commission percentage from `platform_settings/commission.rate` | 0.0 - 1.0 |

### PerformanceScore

Maps to: Performance indicator in table row and detail view (US2, FR-008, FR-009). Patient rating uses `DoctorModel.rating` (0-5.0). EMR speed uses `emr.createdAt` - `appointment.scheduledDateTime`.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| totalScore | `double` | Weighted sum (0-100). Weights redistributed proportionally when dimensions lack data. | 0.0 - 100.0 |
| completionRateScore | `double` | Component: completion rate (0-25) | 0.0 - 25.0 |
| patientRatingScore | `double` | Component: `DoctorModel.rating` / 5.0 * 25 (0-25) | 0.0 - 25.0 |
| punctualityScore | `double` | Component: on-time ratio (0-25) | 0.0 - 25.0 |
| emrSpeedScore | `double` | Component: report creation speed (0-25) | 0.0 - 25.0 |
| hasIncompleteData | `bool` | Whether some dimensions lack data (< 3 data points or < 30 days) | required |
| missingDimensions | `List<String>` | Names of dimensions without data | subset of 4 dimension names |

### AdminAlert

Maps to: Alert notification in admin dashboard (US4, FR-014 through FR-016). Deduplicated: one active alert per doctor per condition type.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| id | `String` | Auto-generated document ID | required |
| type | `AlertType` | financial / performance / activity | enum |
| doctorId | `String` | Related doctor's ID | required |
| doctorName | `String` | Related doctor's name | required |
| title | `String` | Short alert title | required, non-empty |
| message | `String` | Detailed description | required |
| triggerValue | `String` | The value that triggered the alert (e.g., "5000 SAR", "65%", "12 days") | required |
| threshold | `String` | The configured threshold (from `admin_settings/alert_thresholds`) | required |
| isRead | `bool` | Whether admin has acknowledged | default false |
| createdAt | `DateTime` | When alert was generated (renewed on update for same condition) | required |
| resolvedAt | `DateTime?` | When admin acknowledged | nullable |

### PayoutReport

Maps to: Exportable monthly report (US5, FR-017, FR-018). Source of truth: Cloud Function `exportPayoutReport` computation from raw `appointments`. Calculations identical to detail view (FR-004→FR-007).

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| doctorId | `String` | Doctor's ID | required |
| doctorName | `String` | Doctor's name | required |
| period | `DateRange` | Report period (calendar month, UTC) | required |
| entries | `List<PayoutEntry>` | Individual appointment records (financially eligible: `completed` AND `fee > 0`) | required |
| totalRevenue | `double` | Sum of entry revenues | >= 0.0 |
| totalCommission | `double` | Sum of entry commissions (each: fee × commissionRate) | >= 0.0 |
| totalNetPayout | `double` | totalRevenue - totalCommission | >= 0.0 |
| generatedAt | `DateTime` | When report was generated | required |

### PayoutEntry (embedded in PayoutReport)

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| appointmentId | `String` | Appointment document ID | required |
| patientName | `String` | Patient's full name (admin-visible only, no PHI in analytics) | required |
| appointmentDate | `DateTime` | Date of appointment | required |
| status | `String` | Appointment status at time of report | required |
| fee | `double` | Appointment fee (gross, from `AppointmentModel.fee` in SAR) | >= 0.0 |
| commission | `double` | Platform commission (fee × commissionRate), rounded 2dp | >= 0.0 |
| netAmount | `double` | fee - commission, rounded 2dp | >= 0.0 |

### DateRange (shared value object)

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| start | `DateTime` | Period start (inclusive, UTC) | required |
| end | `DateTime` | Period end (inclusive, UTC, >= start) | required, >= start |

## Enums

### PayoutStatus

- `paid` — All outstanding amount has been disbursed (admin action)
- `pending` — Amount awaiting disbursement (default for new earnings)
- `partial` — Partial payment made, remainder pending (admin action)

### AlertType

- `financial` — Pending payout exceeds threshold (FR-014)
- `performance` — Completion rate dropped below 70% (FR-015)
- `activity` — Doctor inactive for 7+ days (FR-016)

### AnalyticsPeriod (for filter)

- `day` — Current day
- `week` — Current week (last 7 days)
- `month` — Current month
- `custom` — User-defined range

## State Transitions

### AdminAlert Lifecycle

```
CREATED (isRead: false) → ACKNOWLEDGED (isRead: true, resolvedAt: set)
```

### PayoutStatus

```
pending → partial → paid
        ↘ paid
```

## Firestore Collections Used

| Collection | Usage | Access Pattern |
|------------|-------|---------------|
| `appointments` | Source of truth for all analytics. Fields: `doctorId`, `patientId`, `status`, `fee` (SAR), `createdAt`, `completedAt` (PR-002), `type` (video/clinic), `specialization` | Read-only, server-side queries |
| `users` | Doctor profiles (`DoctorModel.rating`, `reviewsCount`), active status, `lastLoginAt` (PR-001), `clinicType`, `userType` | Read-only |
| `admin_alerts` | Generated by scheduled CF, read by client via real-time listener | Write (CF), Read (client) |
| `platform_settings/commission` | Commission rate (`rate` field, default 0.15) | Read-only (CF reads) |
| `admin_settings/alert_thresholds` | Alert thresholds: `payoutThreshold` (5000 SAR), `completionRateThreshold` (0.70), `inactivityDaysThreshold` (7) | Read-only (CF reads) |
| `emr_records` | EMR report timestamps (`createdAt`) for speed calculation | Read-only, server-side queries |

## Data Volume Estimates

| Entity | Expected Volume | Notes |
|--------|----------------|-------|
| DoctorAnalytics rows | Up to 500 | One per active doctor |
| PlatformSummary | 1 per query | Computed on demand |
| AdminAlert | 0-50 active | Cleared after acknowledgment |
| PayoutReport entries | 10-200 per doctor per month | Depends on appointment volume |
| Appointment queries | 100-50,000 per aggregation | Server-side only |
