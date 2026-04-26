# Requirements Quality Checklist: Doctor Analytics Dashboard

**Purpose**: Validate requirement completeness, clarity, consistency, and measurability across all 8 user stories and 22 functional requirements — comprehensive pre-implementation review **Created**: 2026-04-25 **Updated**: 2026-04-25 (all 54 items resolved — [spec.md](http://spec.md), [data-model.md](http://data-model.md), contracts updated) **Feature**: [spec.md](../spec.md)**Focus**: Full-scope with financial calculation emphasis

## Requirement Completeness

- \[x\] CHK001 Are data refresh frequency requirements specified (real-time, hourly, on-demand) for dashboard statistics? \[Gap → NFR-001: on-demand on open/filter change + pull-to-refresh\]
- \[x\] CHK002 Are alert delivery mechanism requirements defined (in-app, push notification, email) for FR-014→FR-016? \[Gap → FR-014b: in-app only via admin_alerts collection + real-time listener\]
- \[x\] CHK003 Is the report generation trigger specified (on-demand vs. scheduled) for FR-017? \[Gap → FR-017: on-demand only, no scheduled generation\]
- \[x\] CHK004 Are PDF and Excel report formatting/layout requirements documented beyond field lists in FR-018? \[Gap → FR-017a: standard invoice template with logo, doctor info, itemized table, summary footer\]
- \[x\] CHK005 Are the allowed service type categories defined for specialty breakdown (FR-012)? \[Gap → FR-012: AppointmentType enum (video/clinic) + clinicType for specialty categorization\]
- \[x\] CHK006 Are requirements specified for concurrent admin users viewing/modifying the same analytics data? \[Gap → NFR-004: read-only data, multiple admins can view simultaneously without conflict\]
- \[x\] CHK007 Is there a requirement for audit trail or change logging on financial calculations? \[Gap → Deferred: admin actions logged via existing audit log. View-only operations not audited.\]
- \[x\] CHK008 Are requirements defined for offline or poor-connectivity behavior of the dashboard? \[Gap → Edge Case: display last cached data with "may be outdated" indicator + retry button\]

## Requirement Clarity

- \[x\] CHK009 Is "average response time to new booking" (FR-003) defined with a start and end event? \[Clarity → FR-003: from appointment.createdAt to first status change pending→confirmed/scheduled, in minutes\]
- \[x\] CHK010 Is the "predefined financial threshold" (FR-014) specified with an actual value or configuration mechanism? \[Clarity → FR-014: from admin_settings/alert_thresholds.payoutThreshold, default 5000 SAR\]
- \[x\] CHK011 Is the performance score partial-calculation algorithm documented when dimensions have insufficient data? \[Clarity → FR-008: proportional weight redistribution among available dimensions, hasIncompleteData flag\]
- \[x\] CHK012 Is the minimum data threshold for displaying patient retention rate quantified? \[Clarity → FR-021: minimum 5 unique patients, below threshold shows "N/A — insufficient data"\]
- \[x\] CHK013 Is "smoothly" (SC-006) quantified with specific load-time or interaction-latency targets? \[Clarity → SC-006: &lt; 5s initial load, &lt; 2s pages, &lt; 3s sort/filter, measured at 500 doctors\]
- \[x\] CHK014 Are "satisfaction rate" (FR-019) and "patient ratings" (FR-008) defined as the same metric or distinguished? \[Clarity → FR-019: same metric — DoctorModel.rating (0-5.0 scale)\]
- \[x\] CHK015 Is the minimum number of data points required for time-series comparison (FR-011) specified? \[Clarity → FR-011: minimum 2 data points per period. Single-point periods show without comparison\]

## Requirement Consistency

- \[x\] CHK016 Are the zero-data display requirements consistent between US5 Scenario 3 and the Edge Cases section? \[Consistency → Harmonized: zero values in table row, "لا تتوفر بيانات" in detail view\]
- \[x\] CHK017 Is the completion-rate alert period (30 days in US4 Scenario 2) consistently reflected in FR-015? \[Consistency → FR-015: explicitly trailing 30 days from current date\]
- \[x\] CHK018 Are the performance score weight redistribution rules consistent between FR-008 and US2? \[Consistency → FR-008: proportional redistribution when dimension has &lt; 3 data points or &lt; 30 days\]
- \[x\] CHK019 Are financial inclusions/exclusions consistently defined across FR-001, FR-004, and FR-006? \[Consistency → FR-004: Financial Eligibility Rule: status == 'completed' AND fee &gt; 0\]
- \[x\] CHK020 Is the "isActive = false" display treatment consistent across all table views and detail screens? \[Consistency → Edge Case: dimmed row + "غير نشط" badge in table, excluded from summary cards, visible in detail\]

## Acceptance Criteria Quality

- \[x\] CHK021 Can SC-002 ("100% match") be objectively verified? \[Measurability → SC-002: cross-reference CF output against raw Firestore appointments query for sample of 10 doctors\]
- \[x\] CHK022 Can SC-003 ("within one hour") be measured? \[Measurability → SC-003: start = scheduled CF detects condition, end = alert visible in admin UI\]
- \[x\] CHK023 Is SC-005 ("90% have clear score") testable? \[Measurability → SC-005: "clear" = hasIncompleteData == false OR explicit partial-data indicator, measured over trailing 90 days\]
- \[x\] CHK024 Can SC-007 ("compare in under 10 seconds") be measured? \[Measurability → SC-007: apply specialty filter then sort by revenue, 10s from filter tap to fully rendered table\]
- \[x\] CHK025 Are all 22 functional requirements traceable to at least one acceptance scenario? \[Traceability → Yes: FR-001→FR-022 mapped to US1-US8 acceptance scenarios\]

## Scenario Coverage

- \[x\] CHK026 Are requirements defined for the zero-doctor state? \[Coverage → Edge Case: summary cards show zeros, table shows "لا يوجد أطباء مسجلين"\]
- \[x\] CHK027 Are export failure scenarios addressed? \[Coverage → Edge Case: error message + retry, no partial export support\]
- \[x\] CHK028 Are chart rendering requirements specified for sparse or single-data-point periods? \[Coverage → FR-010: &lt; 3 points → single markers (not lines), single month → bar chart\]
- \[x\] CHK029 Are requirements defined for stale data indicators? \[Coverage → NFR-001: on-demand fetch per filter change, no stale-data indicators needed\]
- \[x\] CHK030 Are alert fatigue management requirements specified? \[Coverage → FR-014a: deduplicated per doctor per condition type, one active alert max per type\]
- \[x\] CHK031 Are requirements for large-month exports addressed? \[Coverage → FR-017: &gt; 200 entries supported without limit, CF returns full dataset\]

## Edge Case Coverage

- \[x\] CHK032 Are timezone handling requirements defined for monthly report boundaries? \[Edge Case → Assumptions: all timestamps UTC, monthly boundaries use UTC start/end, display converts to device timezone\]
- \[x\] CHK033 Is the handling of bookings with zero or null price values specified for financial calculations? \[Edge Case → FR-004: excluded and logged as anomalies\]
- \[x\] CHK034 Are requirements defined for a doctor registered mid-month? \[Edge Case → Edge Case: analytics from registration date, "partial month" indicator\]
- \[x\] CHK035 Is the behavior specified when commission rate changes mid-reporting-period? \[Edge Case → FR-005: rate at time of each appointment's completion\]
- \[x\] CHK036 Are requirements defined for doctors with multiple specialties when specialty filtering is applied? \[Edge Case → FR-020: primary clinicType used, filter matches on clinicType field\]

## Financial Requirements (Deep Dive)

- \[x\] CHK037 Is the commission rate value or its configuration source documented? \[Completeness → FR-005: from platform_settings/commission.rate, default 0.15. PR-003 prerequisite.\] **→ Implemented via platform_settings/commission Firestore document (PR-003, T004)**
- \[x\] CHK038 Are requirements for commission calculation on partially-refunded bookings defined? \[Gap → FR-005a: notCompleted status excluded from revenue and commission\]
- \[x\] CHK039 Are the business rules for classifying a booking as "completed" for financial purposes explicitly stated? \[Clarity → FR-004: Financial Eligibility Rule — status == 'completed' AND fee &gt; 0\] **→ Consolidated as BR-001 in spec.md. Applied in getDoctorsOverview, getDoctorAnalyticsDetail, exportPayoutReport CFs.**
- \[x\] CHK040 Is the rounding/precision specification for financial amounts defined? \[Gap → FR-006: 2 decimal places, SAR currency\]
- \[x\] CHK041 Are requirements for handling currency discrepancies documented? \[Gap → Assumption: SAR only via CurrencyConstants.defaultCurrency, no multi-currency\]
- \[x\] CHK042 Is the "paid" vs. "pending" classification trigger for payouts defined with explicit criteria? \[Clarity → FR-007: pending = default, paid = admin records disbursement, partial = partial disbursement\]
- \[x\] CHK043 Are financial summary requirements consistent between detail view and export report? \[Consistency → FR-018a: single CF serves both, identical calculation rules\]
- \[x\] CHK044 Is the conflict resolution rule for "completed booking with zero price" reflected in FR-004? \[Consistency → FR-004: excluded from financial aggregation and logged as anomaly\]
- \[x\] CHK045 Are report row-level financial calculations specified? \[Completeness → FR-018: each row has fee (gross), commission (fee × rate), netAmount (fee − commission)\]
- \[x\] CHK046 Is the source-of-truth for payout amounts documented? \[Ambiguity → FR-018: Cloud Function computation from raw appointments, no cached values\] **→ On-demand CF computation confirmed. No cached values. R-001 override documented in research.md.**

## Non-Functional Requirements

- \[x\] CHK047 Are specific query performance requirements defined beyond the overall "30 seconds" target? \[Gap → NFR-002: &lt; 5s paginated queries, &lt; 10s full aggregation\]
- \[x\] CHK048 Are security requirements beyond "admin-only access" specified? \[Gap → NFR-003: admin-only via CF auth check, no patient PHI in analytics\]
- \[x\] CHK049 Are accessibility requirements defined for the dashboard? \[Gap → NFR-006: platform defaults only, no additional a11y this iteration\]
- \[x\] CHK050 Are logging and error-monitoring requirements specified? \[Gap → NFR-005: CF via console.log, client via firebase_crashlytics\]

## Dependencies & Assumptions

- \[x\] CHK051 Is the assumption "ratings exist and are linked to bookings" validated? \[Assumption → Validated: ratings are denormalized on DoctorModel (rating + reviewsCount), no per-booking ratings. FR-009 updated to use DoctorModel.rating.\]
- \[x\] CHK052 Is the assumption "EMR reports have timestamps for speed calculation" validated? \[Assumption → Validated: emr_records have createdAt only. Speed = scheduledDateTime → emr.createdAt.\]
- \[x\] CHK053 Is the assumption "admin dashboard supports adding a new tab" verified? \[Assumption → Invalidated: no tab bar. Changed to NavCard #6 pattern (PR-004). Navigation Flow updated.\]
- \[x\] CHK054 Is the assumption "last login is recorded in user document" validated? \[Assumption → Invalidated: no lastLoginAt field. Added as PR-001 prerequisite.\]

## Notes

- All 54 items resolved via [spec.md](http://spec.md), [data-model.md](http://data-model.md), and contracts/cloud-functions.md updates
- 4 assumptions invalidated by codebase exploration (CHK051→CHK054) — 2 required new prerequisites (PR-001, PR-002, PR-003, PR-004)
- 10 financial deep-dive items (CHK037→CHK046) resolved with explicit Financial Eligibility Rule, commission source, rounding spec, and source-of-truth documentation
- 6 new NFRs added (NFR-001 through NFR-006)
- Items CHK007 (audit trail) and CHK049 (accessibility) deferred to future iterations
