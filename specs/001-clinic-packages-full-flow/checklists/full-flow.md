# Full-Flow Requirements Checklist: Clinic Packages Full Flow

**Purpose**: Unit-test the quality of requirements across spec.md, plan.md, and data-model.md — assessing completeness, clarity, consistency, measurability, and coverage before writing code.  
**Created**: 2026-03-07 | **Last updated**: 2026-03-07 (all gaps resolved)  
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md) | [data-model.md](../data-model.md)  
**Depth**: Standard | **Audience**: Reviewer (PR / pre-implementation gate)

---

## 1. Requirement Completeness

- [x] CHK001 — Are all five patient-facing flows fully documented (Operations→Packages, Category List, Package Details, Buy Now, My Packages)? [Completeness, Spec §4] ✅ **Covered** — flows 4.1–4.4 present.
- [x] CHK002 — Are the exact UI states defined for the "Buy Now" / "View Package" button transition after purchase (loading, success, failure)? [Completeness, Spec §9.1] ✅ **Covered** — four states (idle, loading, success, already-purchased) defined.
- [x] CHK003 — Is the payment-success signal (which event/callback marks a purchase `ACTIVE`) fully specified? [Completeness, Spec §7.4] ✅ **Covered** — §7.4 defines payment module contract and document creation rules.
- [x] CHK004 — Are empty-state requirements defined for every list screen? [Completeness, Spec §9.2] ✅ **Covered** — all five screens have explicit Arabic empty-state messages.
- [x] CHK005 — Are admin management actions (Create, Edit, Activate/Deactivate, Duplicate) documented? [Completeness, Spec §2] ✅ **Covered**.
- [x] CHK006 — Is there a requirement for what happens when a patient opens Package Details for a package whose clinic has been deactivated? [Completeness, Spec §7.9] ✅ **Covered** — `ClinicUnavailableFailure` + Arabic error message + button hidden.
- [x] CHK007 — Is offline/low-connectivity behavior specified for the Packages flow? [Completeness, Spec §7.10] ✅ **Covered** — offline persistence, retry button, disabled purchase button when offline.
- [x] CHK008 — Are Cloud Function region requirements documented for the expiry scheduler? [Completeness, Spec §6.1] ✅ **Covered** — `europe-west1` at midnight Cairo time.
- [x] CHK009 — Are requirements defined for admin uploading a document when `serviceId` is unknown/optional? [Completeness, Spec §9.13] ✅ **Covered** — `serviceId` is optional; document is linked with `serviceId = null`.
- [x] CHK010 — Are notification requirements defined for when a new document is uploaded to a patient package? [Completeness, Spec §7.11] ✅ **Covered** — FCM push notification with Arabic title/body and deep-link; best-effort delivery.

---

## 2. Requirement Clarity

- [x] CHK011 — Is "prominent display" for featured packages (`isFeatured`) defined with measurable visual criteria? [Clarity, Spec §9.3] ✅ **Covered** — badge label *"الأكثر اختيارًا"*, amber/gold colour, top-right corner; featured packages sort first.
- [x] CHK012 — Is "Simple progress indicator" specified with a concrete choice? [Clarity, Spec §9.4] ✅ **Covered** — format `X / Y` with western numerals + `LinearProgressIndicator`.
- [x] CHK013 — Is `displayOrder` defined as auto-assigned or manually entered by admin? [Clarity, Spec §9.5] ✅ **Covered** — manually entered, defaults to `last + 1`, lower = first.
- [x] CHK014 — Is `packageType` alignment with `includesVideoConsultation`/`includesPhysicalVisit` defined? [Clarity, Spec §9.6, Data-Model §3.1] ✅ **Covered** — `packageType` is authoritative; booleans are always recomputed on write.
- [x] CHK015 — Is `validityDays` described as starting from `purchaseDate` or first service use? [Clarity, Spec §9.7] ✅ **Covered** — counted from `purchaseDate`; no first-use activation.
- [x] CHK016 — Are enum values for `status`, `category`, `documentType`, `serviceType` defined with Arabic labels? [Clarity, Data-Model §§3.1, 4.1, 5.1] ✅ **Covered**.
- [x] CHK017 — Is `price` specified as inclusive? Currency display format defined? [Clarity, Spec §9.8] ✅ **Covered** — price is inclusive of all fees; patient display format `"[price] جنيه"`.
- [x] CHK018 — Is "duplicate package" action defined (same clinic? target clinic)? [Clarity, Spec §9.9] ✅ **Covered** — same clinic only; new status = INACTIVE; name prefixed with *"نسخة من: "*.
- [x] CHK019 — Is "linked to this package" for documents specified with a clear ownership rule? [Clarity, Spec §9.10] ✅ **Covered** — scoped to single patient; no cross-patient reads.
- [x] CHK020 — Is the "progress" calculation rule defined when a service has `quantity > 1`? [Clarity, Spec §9.4, Data-Model §4.1] ✅ **Covered** — `usedServicesCount` counts fully consumed services only (`usedCount >= quantity`).

---

## 3. Requirement Consistency

- [x] CHK021 — Do all Firestore collection paths consistently use `databaseId = 'elajtech'`? [Consistency, Spec §6] ✅ **Covered**.
- [x] CHK022 — Is Clinic Isolation consistently applied across layers? [Consistency, Plan §Project Structure] ✅ **Covered**.
- [x] CHK023 — Is the duplicate-purchase guard documented in the domain layer design? [Consistency, Spec §7.1] ✅ **Covered** — `PatientPackageRepository.findActiveOrPendingByPackageId` method required; guard in `PurchasePackageUseCase` (§7.4).
- [x] CHK024 — Is the Expiry mechanism and `updatedAt` behaviour consistently referenced? [Consistency, Spec §6.1] ✅ **Covered** — Cloud Function sets `status = EXPIRED` and `updatedAt = serverTimestamp()`.
- [x] CHK025 — Are `uploadedByRole` values consistent between spec §7.2 and data-model §5.1? [Consistency] ✅ **Covered**.
- [x] CHK026 — Is the `notes` field in patient packages referenced in UI requirements? [Consistency, Spec §7.8] ✅ **Covered** — admin/doctor only; never shown to patient; editable in admin context view.
- [x] CHK027 — Is `paymentTransactionId` always present after a confirmed purchase? [Consistency, Spec §7.4] ✅ **Covered** — mandatory, non-null for all purchases with `status = ACTIVE`.

---

## 4. Acceptance Criteria Quality

- [x] CHK028 — Is there a measurable acceptance criterion for screen load time? [Measurability, Spec §10.1, Plan §Technical Context] ✅ **Covered** — ≤ 2 seconds on mid-range 4G device (soft target).
- [x] CHK029 — Is the acceptance criterion for `PurchasePackageUseCase` duplication guard testable? [Measurability, Spec §10.3] ✅ **Covered** — exact test scenario and assertion defined.
- [x] CHK030 — Is the Cloud Function daily expiry schedule defined with an acceptance criterion? [Measurability, Spec §10.2] ✅ **Covered** — completes within 5 minutes of midnight trigger; batch processing if needed.
- [x] CHK031 — Is the progress indicator specified with a measurable rendering rule? [Measurability, Spec §9.4] ✅ **Covered** — testable criterion: 2 of 3 services used → label `"2 / 3"`, bar ≈67%.
- [x] CHK032 — Is test coverage percentage defined as an acceptance criterion? [Measurability, Spec §10.4, Plan §Constitution Check] ✅ **Covered** — domain ≥80%, data ≥70% line coverage.

---

## 5. Scenario & Edge-Case Coverage

- [x] CHK033 — Is the primary patient happy path fully documented? [Coverage, Spec §4.1] ✅ **Covered**.
- [x] CHK034 — Is the "already purchased" path documented? [Coverage, Spec §4.1 step 9] ✅ **Covered**.
- [x] CHK035 — Is the error path for a failed purchase defined? [Coverage, Spec §7.5] ✅ **Covered** — typed failures, no write on failure, Arabic errors, retry.
- [x] CHK036 — Is the ACTIVE→EXPIRED race condition between list and details handled? [Coverage, Spec §6.1] ✅ **Covered** — Detail screen re-derives expiry from `expiryDate` on every render.
- [x] CHK037 — Is the scenario of INACTIVE/HIDDEN package after purchase addressed? [Coverage, Spec §9.11] ✅ **Covered** — patient continues to see purchased package in My Packages; hidden from new-patient listing.
- [x] CHK038 — Is the concurrent-edit scenario defined for admin? [Coverage, Spec §7.13] ✅ **Covered** — last-write-wins + `updatedAt` optimistic-concurrency guard; full merge deferred.
- [x] CHK039 — Are requirements defined for large service lists inside a package? [Coverage, Spec §7.12] ✅ **Covered** — embedded array for ≤30 services; subcollection migration deferred for >30.
- [x] CHK040 — Is the document-viewing flow defined for the patient? [Coverage, Spec §9.10] ✅ **Covered** — PDF/image inline preview via full-screen viewer; download supported.
- [x] CHK041 — Are max file size and allowed file types defined for document uploads? [Coverage, Spec §9.13] ✅ **Covered** — max 20 MB; PDF/JPEG/PNG only; client-side validation.
- [x] CHK042 — Is the `servicesUsage` embedded vs sub-collection decision documented? [Coverage, Spec §7.12] ✅ **Covered** — embedded for this release; sub-collection migration threshold = 30 services.

---

## 6. Non-Functional Requirements

### 6.1 Security & Auth

- [x] CHK043 — Are Firestore Security Rules requirements specified for who can read/write patient packages and documents? [Security, Spec §7.2] ✅ **Covered**.
- [x] CHK044 — Are Firestore Security Rules specified for patient-side reads? [Security, Spec §7.6] ✅ **Covered** — `request.auth.uid == patientId` for all patient reads.
- [x] CHK045 — Is null-safety on auth user enforced? [Security, Plan §Constraints] ✅ **Covered**.
- [x] CHK046 — Is input validation defined for admin package creation fields? [Security, Spec §9.12, Data-Model §3.2] ✅ **Covered** — field constraints table with char limits, price range, required flags.
- [x] CHK047 — Is the `databaseId = 'elajtech'` Firestore rule traceable through all docs? [Security, Spec §6] ✅ **Covered**.

### 6.2 Performance

- [x] CHK048 — Are Firestore composite index requirements mandatory (not suggestions)? [Performance, Data-Model §§3.3, 4.2, 5.2] ✅ **Covered** — 7 indexes defined as mandatory requirements.
- [x] CHK049 — Is pagination/query limit defined for admin list queries? [Performance, Plan §Pagination, Data-Model §3.3] ✅ **Covered** — admin: `limit(20)` with cursor; patient: `limit(50)` single-call.
- [x] CHK050 — Are caching requirements defined? [Performance, Plan §Caching] ✅ **Covered** — Firestore offline persistence; no additional in-memory cache in this release; explicit deferral noted.

### 6.3 Arabic Language & RTL

- [x] CHK051 — Are all patient-visible text fields required to be stored and displayed in Arabic? [RTL, Data-Model §2] ✅ **Covered**.
- [x] CHK052 — Are enum-to-Arabic-label mapping requirements defined? [RTL, Data-Model §§3.1, 4.1, 5.1] ✅ **Covered**.
- [x] CHK053 — Is RTL layout direction explicitly required for all new screens? [RTL, Spec §9.14] ✅ **Covered** — all screens inherit global RTL; English-only widgets wrapped with `TextDirection.ltr`; progress bar wrapped.
- [x] CHK054 — Are date/time display formats specified in Arabic locale? [RTL, Spec §9.14] ✅ **Covered** — `DateFormat.yMMMMd('ar')` (e.g., *"7 مارس 2026"*).

### 6.4 Testing Requirements

- [x] CHK055 — Are unit test requirements defined for all domain use cases? [Testing, Plan §test/unit] ✅ **Covered** — all 10 use cases listed.
- [x] CHK056 — Are widget test requirements defined for all major patient screens? [Testing, Plan §test/widget] ✅ **Covered** — categories list, package details, my packages.
- [x] CHK057 — Is an integration test requirement defined for end-to-end patient purchase flow? [Testing, Plan §test/integration] ✅ **Covered**.
- [x] CHK058 — Are mock/stub requirements defined for the payment signal in tests? [Testing, Plan §Payment Mock Strategy] ✅ **Covered** — `MockPaymentService` in unit tests; `FakePaymentService` via DI override in integration tests.
- [x] CHK059 — Are widget test requirements defined for admin screens? [Testing, Plan §test/widget/admin] ✅ **Covered** — admin packages list, create/edit form, patient packages view.
- [x] CHK060 — Is the Test Persistence Rule explicitly enforced? [Testing, Plan §Constitution Check] ✅ **Covered**.

---

## 7. Dependencies & Assumptions

- [x] CHK061 — Is the dependency on existing `clinics` and `patients` Firestore collections documented? [Dependency, Data-Model §2] ✅ **Covered**.
- [x] CHK062 — Is the assumption that a payment gateway already exists documented with its interface contract? [Assumption, Spec §7.14] ✅ **Covered** — `PaymentService.initiatePayment` contract defined; `PackagePaymentAdapter` fallback if needed.
- [x] CHK063 — Is the Cloud Storage dependency documented (bucket, region, path, access rules)? [Dependency, Spec §7.15, Plan §Technical Context] ✅ **Covered** — Firebase Storage, default project bucket, path pattern, Storage Security Rules.
- [x] CHK064 — Is the Cloud Functions dependency documented with region and schedule? [Dependency, Spec §6.1] ✅ **Covered**.
- [x] CHK065 — Is the assumption that all 5 clinics exist in Firestore documented and validated? [Assumption, Spec §7.16] ✅ **Covered** — deployment prerequisite; Firestore read-check required pre-release.
- [x] CHK066 — Is `build_runner` execution noted as a CI/CD dependency? [Dependency, Plan §Technical Context, Plan §Constitution Check] ✅ **Covered** — mandatory in both local workflow and CI pipeline.

---

## 8. Ambiguities & Conflicts

- [x] CHK067 — Are `includesVideoConsultation` / `includesPhysicalVisit` fields clarified (keep vs remove)? [Ambiguity, Spec §9.6, Data-Model §3.1] ✅ **Covered** — kept as computed/denormalised fields; always recomputed on write; planned removal deferred.
- [x] CHK068 — Does admin Packages tab respect Clinic Isolation per role? [Consistency, Spec §7.7] ✅ **Covered** — three-role model defined; `clinicId`-scoped access enforced at UI and Firestore level.
- [x] CHK069 — Is the `notes` field in patient packages visibility resolved? [Ambiguity, Spec §7.8] ✅ **Covered** — admin/doctor only; never shown to patient.
- [x] CHK070 — Is `DuplicatePackageUseCase` specified in spec.md to match plan.md? [Conflict, Spec §9.9] ✅ **Covered** — full use-case spec added (reads, writes, return type).
- [x] CHK071 — Should a `HIDDEN` clinic package remain visible in patient's My Packages? [Ambiguity, Spec §9.11] ✅ **Covered** — patient continues to see purchased package regardless of admin status change.

---

## Summary: Coverage Status

| Category | Total Items | ✅ Covered | ⚠️ Partially | ❌ Gap/Ambiguity |
|---|---|---|---|---|
| 1. Completeness | 10 | **10** | 0 | **0** |
| 2. Clarity | 10 | **10** | 0 | **0** |
| 3. Consistency | 7 | **7** | 0 | **0** |
| 4. Acceptance Criteria | 5 | **5** | 0 | **0** |
| 5. Scenario & Edge Cases | 10 | **10** | 0 | **0** |
| 6a. Security & Auth | 5 | **5** | 0 | **0** |
| 6b. Performance | 3 | **3** | 0 | **0** |
| 6c. Arabic Language & RTL | 4 | **4** | 0 | **0** |
| 6d. Testing | 6 | **6** | 0 | **0** |
| 7. Dependencies & Assumptions | 6 | **6** | 0 | **0** |
| 8. Ambiguities & Conflicts | 5 | **5** | 0 | **0** |
| **TOTAL** | **71** | **71 (100%)** | **0 (0%)** | **0 (0%)** |

> **2026-03-07 (initial)**: CHK003, CHK035, CHK044, CHK068 resolved — spec §§7.4–7.7 added.  
> **2026-03-07 (final)**: All 71 items resolved. spec §§7.8–7.16, §9, §10 added; plan.md and data-model.md updated.

---

## Notes

- All items are ✅ **Covered**. The documentation is ready for `/speckit.tasks` and implementation.
- Intentionally deferred items (not blockers for this release):
  - Partial refunds/cancellations (spec §7.3) — future feature.
  - `servicesUsage` subcollection migration when packages exceed 30 services (spec §7.12) — future iteration.
  - Concurrent-edit full merge/lock strategy (spec §7.13) — future iteration.
  - Removal of `includesVideoConsultation` / `includesPhysicalVisit` booleans (spec §9.6, data-model §3.1) — future iteration.
  - Cross-clinic package duplication (spec §9.9) — future iteration.

---

<div dir="rtl">

## ملاحظات بالعربية

تم حل جميع بنود القائمة بالكامل (71/71).  
الوثائق الثلاثة (`spec.md`، `plan.md`، `data-model.md`) جاهزة الآن كمصدر وحيد للحقيقة قبل تنفيذ `/speckit.tasks` والبدء في كتابة الكود.

**البنود المؤجلة عمداً (لا تُعيق هذا الإصدار):**
- الاسترداد الجزئي وإلغاء الاشتراك (مؤجل لميزة مستقبلية).
- ترحيل `servicesUsage` إلى subcollection إذا تجاوزت الخدمات 30 عنصرًا.
- إزالة الحقلين المشتقين `includesVideoConsultation` و`includesPhysicalVisit` (مؤجل).
- النسخ المتزامن لنفس الباقة بين عيادات مختلفة (مؤجل).

</div>
