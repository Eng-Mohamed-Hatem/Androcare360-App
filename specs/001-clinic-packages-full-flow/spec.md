# Feature Spec: Clinic Packages Full Flow

## 1. Overview

Design and implement a complete Clinic Packages experience for AndroCare/Elajtech, covering:
- Patient app: Operations section packages flow + My Packages tab in profile.
- Admin dashboard: Packages management per clinic + Patient Packages view.

Goal: Sell clinic-specific medical packages (investigations, visits, sessions) in a clear, trackable way for both patients and admins, while respecting Clean Architecture and Clinic Isolation rules.

## 2. In Scope

- Patient app:
  - Replace "Video Consultation" button in Operations section with "Packages" button.
  - New Packages Categories screen with 5 categories:
    1. Andrology, Infertility & Prostate Packages
    2. Physiotherapy & Rehabilitation Packages
    3. Internal Medicine & Family Medicine Packages
    4. Obesity & Therapeutic Nutrition Packages
    5. Chronic Diseases Packages
  - Category Packages List screen showing all active packages for the selected category.
  - Package Details screen with:
    - Name, short description, category.
    - Full list of included services (lab tests, imaging, visits/sessions).
    - Financial info (price, currency, discount, video/physical/only investigations).
    - Validity in days and usage conditions.
    - Package status for the current patient (Active / Completed / Expired / Pending).
    - Primary action:
      - "Buy Now" if not purchased.
      - "View Package" if already purchased.
  - Post-purchase behavior:
    - After successful purchase, change the button to "View Package".
    - Tapping "View Package" navigates to the My Packages tab (specific package view).

- Patient profile:
  - New "My Packages" tab.
  - For each purchased package:
    - Name, category, status (Active / Completed / Expired / Pending).
    - Purchase date and expiry date.
    - Progress: used services vs total services (e.g. 3/5).
    - Simple progress indicator (percentage or bar).
  - Package detail view from My Packages:
    - Same base info as Package Details.
    - Services used vs remaining.
    - Lab results / imaging reports / documents uploaded by doctor/admin and linked to this package.

- Admin dashboard:
  - New "Packages" tab for managing clinic packages.
  - Per-package configuration:
    - Basic:
      - Package name.
      - Short description.
      - Linked category (one of the 5 categories above).
    - Medical content:
      - List of included services (lab tests, imaging, clinical visits/sessions).
      - Number of sessions/visits (if any).
      - Validity in days.
      - Usage terms and conditions (text).
    - Financial:
      - Price.
      - Currency (e.g. EGP).
      - Optional discount vs individual services.
      - Package type: includes video consultations, physical visits, both, or investigations only.
    - State & display:
      - Status: Active / Inactive / Hidden from patient UI.
      - Display order inside its category.
      - Featured flag (to highlight in patient UI).
  - Packages index view:
    - Filters by clinic/category/status.
    - Actions: Edit, Activate/Deactivate, Duplicate.

- Admin dashboard – Patient Packages:
  - In patient details view, add a "Patient Packages" area:
    - List all packages purchased by this patient with:
      - Name, category, status, progress, purchase/expiry dates.
    - Ability to open a patient-package context view:
      - See all services in that package.
      - Upload lab results / imaging reports / documents.
      - Link each upload to a specific service inside the package.
  - Ensure linked documents are visible to the patient under the corresponding package in My Packages.

## 3. Out of Scope (for this spec)

- Payment gateway integration details (assume an existing purchase success signal).
- Patient ratings/reviews for packages (can be added in a later feature).
- Advanced analytics dashboards (only basic counts may be considered later).

## 4. User Flows (High Level)

### 4.1 Patient – Operations → Packages

1. Patient opens Operations section.
2. Sees "Packages" button instead of "Video Consultation".
3. Taps "Packages".
4. App shows categories list (5 package categories).
5. Patient selects a category.
6. App shows packages list for that category (Active & Visible packages).
7. Patient taps a package → Package Details screen.
8. If not purchased:
   - Sees "Buy Now" → completes purchase flow.
   - On success: button becomes "View Package" → navigates to My Packages (this package).
9. If already purchased:
   - Sees "View Package" → navigates directly to this package in My Packages.

### 4.2 Patient – Profile → My Packages

1. Patient opens profile.
2. Selects "My Packages" tab.
3. Sees list of purchased packages with status and progress.
4. Selects a package to open detailed view.
5. Sees:
   - Remaining vs used services.
   - Validity dates.
   - Linked lab results / imaging / documents per service.

### 4.3 Admin – Packages Management

1. Admin opens dashboard and navigates to "Packages".
2. Chooses clinic/specialty (respecting Clinic Isolation).
3. Sees list of packages for that clinic with filters and actions.
4. Creates or edits a package:
   - Fills basic info, medical content, financial info, state & display settings.
5. Saves package → it becomes available (if Active & not Hidden) in the patient app for the mapped category.

### 4.4 Admin – Patient Packages & Documents

1. Admin opens "Patients" → selects a patient.
2. Opens "Patient Packages" section.
3. Sees list of packages purchased by this patient.
4. Opens a specific patient-package context.
5. Uploads lab results / imaging / documents and associates them with specific package services.
6. Patient later sees these documents in My Packages under the corresponding package.

## 5. Data Model (High Level Proposal)

> NOTE: This section only proposes structure; final design must respect Firestore `databaseId = elajtech`, Clean Architecture, and Clinic Isolation (separate models/repositories per clinic).

- Package definition (per clinic/specialty):
  - Collection (example): `clinics/{clinicId}/packages/{packageId}`
  - Fields:
    - id
    - clinicId / specialtyId
    - category (enum: ANDROLOGY, PHYSIOTHERAPY, INTERNAL_FAMILY, OBESITY_NUTRITION, CHRONIC_DISEASES)
    - name
    - shortDescription
    - description
    - services[]:
      - serviceId
      - serviceType (LAB, IMAGING, VISIT, SESSION)
      - displayName
    - validityDays
    - termsAndConditions
    - price
    - currency
    - discountPercentage (optional)
    - includesVideoConsultation (bool)
    - includesPhysicalVisit (bool)
    - status (ACTIVE, INACTIVE, HIDDEN)
    - displayOrder
    - isFeatured (bool)
    - createdAt, updatedAt

- Patient package purchase:
  - Collection (example): `patients/{patientId}/packages/{patientPackageId}`
  - Fields:
    - patientId
    - packageId (reference/path to clinic package)
    - clinicId / specialtyId
    - status (ACTIVE, COMPLETED, EXPIRED, PENDING)
    - purchaseDate
    - expiryDate
    - usedServicesCount
    - totalServicesCount
    - servicesUsage[]:
      - serviceId
      - used (bool)
      - usedAt (optional)

- Package-linked documents:
  - Collection (example): `patients/{patientId}/packageDocuments/{documentId}`
  - Fields:
    - patientId
    - patientPackageId
    - packageId
    - serviceId (within the package)
    - documentType (LAB_RESULT, IMAGING_REPORT, OTHER)
    - storagePath / URL
    - uploadedByUserId
    - uploadedByRole (DOCTOR, ADMIN)
    - uploadedAt

## 6. Constraints & Architecture Alignment

- Must follow Clean Architecture (Presentation / Domain / Data) as defined in project rules.
- Must respect Clinic Isolation:
  - Separate models and repositories per clinic/specialty for package definitions.
- Must use Firestore with `databaseId = "elajtech"` only (no default instance).
- Must not break existing tests; new feature requires appropriate unit tests for:
  - Package domain logic.
  - Mapping between package definitions, patient purchases, and documents.

### 6.1 Package Expiry (EXPIRED) Mechanism

Expiry is enforced at two levels:

1. **UI layer (read-only display)**: On every load of the My Packages tab or the Package Details screen, the app compares `expiryDate` with the current device timestamp. If `expiryDate < now()` and status is still `ACTIVE`, the UI renders the package as `EXPIRED` without writing to Firestore.
2. **Server layer (authoritative)**: A scheduled Cloud Function deployed in region `europe-west1` runs daily at **midnight Cairo time (UTC+2)**. It queries all `patients/{patientId}/packages` documents where `status == 'ACTIVE'` AND `expiryDate < now()`, updates `status` to `EXPIRED`, and sets `updatedAt = serverTimestamp()`. *(CHK024)*

> This two-level approach ensures the UI is always accurate even before the Cloud Function has run, while keeping Firestore as the authoritative source of truth.

**Race-condition handling** *(CHK036)*: If a package was `ACTIVE` when the patient loaded the packages list, but has since expired before they open the Package Details screen, the Detail screen re-evaluates `expiryDate < now()` on load and displays the `EXPIRED` state immediately. No crash or stale-data display is acceptable; the UI must re-derive expiry status from the loaded document's `expiryDate` field on every render.

## 7. Clarifications & Resolved Decisions

### 7.1 Multiple Purchases of the Same Package – **RESOLVED** (CHK023)

> **Decision**: A patient **cannot** purchase the same package (`packageId`) while an `ACTIVE` or `PENDING` record for that package already exists in `patients/{patientId}/packages`.
> - The domain-layer guard is implemented inside `PurchasePackageUseCase` (see §7.4 for full use-case behaviour). The repository interface for `PatientPackageRepository` must expose a `findActiveOrPendingByPackageId(patientId, packageId)` query method used exclusively by this guard.
> - If the existing record is `EXPIRED` or `COMPLETED`, a new purchase is allowed.

### 7.2 Document Upload Permissions – **RESOLVED**

> **Decision**: Both `DOCTOR` and `ADMIN` roles are authorised to upload documents (lab results, imaging reports, other files) to a patient package.
> - The `uploadedByRole` field in `packageDocuments` records which role performed the upload (`DOCTOR` or `ADMIN`).
> - Firestore Security Rules must enforce that only authenticated users with role `DOCTOR` or `ADMIN` can write to `patients/{patientId}/packageDocuments`.

### 7.3 Open Questions (still pending)

- How to handle partial refunds or cancellations (out of scope for this spec, deferred to a future feature).

---

### 7.4 Payment Success Signal – **RESOLVED** (CHK003)

> **Source of truth for a successful purchase**: A package purchase is considered `SUCCESSFUL` only when the payment module returns a valid success callback that contains a non-empty `transactionId`.

**`PurchasePackageUseCase` behaviour**:

1. **Duplication guard** — Before initiating any payment, the use case queries `patients/{patientId}/packages` filtered by `packageId`. If a document with `status == ACTIVE` or `status == PENDING` already exists, it immediately returns `PackageAlreadyActiveFailure` and does **not** proceed to payment.
2. **On payment success** (valid `transactionId` received) — The use case creates a new document under `patients/{patientId}/packages/{patientPackageId}` with at least:
   - `status = ACTIVE`
   - `paymentTransactionId = <transactionId>` — **this field is mandatory and must be non-empty whenever a purchase reaches `ACTIVE` status**; it is never null for confirmed purchases *(CHK027)*.
   - `purchaseDate = now()`
   - `expiryDate = purchaseDate + validityDays` (days, not hours; computed as a Firestore Timestamp)
   - `totalServicesCount` (copied from the package definition at time of purchase)
   - `usedServicesCount = 0`
   - `servicesUsage` initialised from the package's `services` list (all `usedCount = 0`).
3. **On no success signal** — No document is created or modified in `patients/{patientId}/packages`.

---

### 7.5 Purchase Failure Handling – **RESOLVED** (CHK035)

> **On payment or network failure, no patient package document is ever created or modified.**

**Typed failures returned by `PurchasePackageUseCase`**:

| Failure type | Trigger |
|---|---|
| `PackageAlreadyActiveFailure` | An ACTIVE or PENDING record already exists for this `packageId` |
| `PaymentFailure` | The payment gateway rejected or declined the payment |
| `NetworkFailure` | Connection was lost before receiving a payment success callback |
| `PackageNotFoundFailure` | The package definition could not be loaded from Firestore |

**UI behaviour during purchase**:

1. When the patient taps "اشترِ الآن", the button immediately enters a **loading/processing state** (disabled, shows a spinner).
2. `PurchasePackageUseCase` is called.
3. **On success** — The button transitions to "عرض الباقة" and the patient is navigated to My Packages.
4. **On any failure** — A Toast/Dialog is shown in Arabic, for example:
   - `PaymentFailure` → *"تعذر إتمام عملية الدفع، برجاء المحاولة مرة أخرى."*
   - `NetworkFailure` → *"لا يوجد اتصال بالإنترنت، برجاء التحقق من الاتصال والمحاولة مرة أخرى."*
   - The button is restored to **"اشترِ الآن"** (enabled) to allow retry without leaving the screen.

---

### 7.6 Firestore Patient Read Isolation – **RESOLVED** (CHK044)

> **Core rule**: A patient can only read documents stored under `patients/{patientId}` where `patientId` equals their own authenticated UID.

**Firestore Security Rules requirement** (conceptual — exact syntax in implementation phase):

```
// patients/{patientId}/packages
match /patients/{patientId}/packages/{docId} {
  allow read: if request.auth != null && request.auth.uid == patientId;
}

// patients/{patientId}/packageDocuments
match /patients/{patientId}/packageDocuments/{docId} {
  allow read: if request.auth != null && request.auth.uid == patientId;
}
```

**Patient app behaviour**:

- All Dart queries for packages and packageDocuments on the patient app side are always scoped to the authenticated patient's UID (obtained via `authProvider` — never via a null-unchecked `!` operator).
- No cross-patient queries are ever issued; the patient UID is always the scope boundary.

---

### 7.7 Admin & Doctor Clinic Isolation – **RESOLVED** (CHK068, R4)

> **Clinic Isolation extends from the data layer to the admin role level.** Every access to clinic packages is always scoped to the specific `clinicId` of the requesting user.

**Role model**:

| Role | Access scope |
|---|---|
| `ADMIN_GLOBAL` | Full read/write access to packages for **all** clinics |
| `ADMIN_CLINIC` | Read/write access only to packages where `clinicId` is in their `allowedClinics` list (stored in their user profile/claims) |
| `DOCTOR_<SPECIALTY>` (e.g. `DOCTOR_PHYSIOTHERAPY`) | Read/write access only to packages of **their own clinic/specialty** (`clinicId` must match) |

**`clinicId` derivation mechanism (ClinicAccessResolver)** *(R4)*:

The single authoritative mechanism for resolving which `clinicId`(s) a user may access is a `ClinicAccessResolver` helper class at `lib/core/auth/clinic_access_resolver.dart`. It:
1. Reads the Firebase Auth custom claims of the current user (`idTokenResult.claims`).
2. Falls back to a Firestore lookup at `users/{uid}/roles` if claims are absent or stale.
3. Returns an `allowedClinics: List<String>` (empty for unauthenticated/unknown roles; full list for `ADMIN_GLOBAL`).

`ClinicAccessResolver` is the **only** source of `clinicId` in all admin use cases (`ListClinicPackagesForAdminUseCase`, `CreateClinicPackageUseCase`, `DuplicatePackageUseCase`, etc.) and all admin Riverpod providers.

**Enforcement requirements**:

1. **Admin UI** — All admin dashboard queries for packages are filtered by the `clinicId`(s) returned by `ClinicAccessResolver`. An admin/doctor never sees a list that crosses their allowed clinic boundaries.
2. **Firestore Security Rules** — Rules use the same custom claims to enforce the allowed `clinicId` set:
   - A request to read/write `clinics/{clinicId}/packages` is allowed only if the requesting user's role grants access to that `clinicId`.
3. **Concrete example** — A Physiotherapy doctor (`DOCTOR_PHYSIOTHERAPY`) must **not** be able to list, read, edit, or duplicate packages under any other clinicId (e.g. Andrology). This must be enforced at both the `ClinicAccessResolver` level (Dart) and the Firestore security rule level.

---

### 7.8 Notes Field Visibility – **RESOLVED** (CHK026, CHK069, R2)

> The `notes` field in `patients/{patientId}/packages` is **admin/doctor-only**.

**Important architectural constraint (R2)**: Firestore Security Rules operate at the **document level**, not at the field level. It is therefore **not possible** to hide the `notes` field via Firestore rules alone. Enforcement is done exclusively at the **application layer**:

- `GetPatientPackagesUseCase` and **all patient-facing providers** must **never map the `notes` field** into the `PatientPackageEntity` returned to patient screens. The entity returned to patients must omit `notes` (treat it as if the field does not exist).
- A dedicated repository method `PatientPackageRepository.getPatientPackageByIdForPatient(patientId, patientPackageId)` must **strip the `notes` field** before returning the entity — it is separate from the admin variant which includes `notes`.
- A unit test in `get_patient_packages_usecase_test.dart` must assert that the `notes` field is `null` / absent on the entity returned for a patient role, even when the Firestore document contains a non-null `notes` value.
- In the admin dashboard's Patient Packages context view, the `notes` field is editable by both `ADMIN` and `DOCTOR` roles and displayed prominently below the package services list.
- Firestore Security Rules secure the document as a whole (patient read isolation via `request.auth.uid == patientId`), but field-level hiding is not achievable at the rules layer.

---

### 7.9 Deactivated / Missing Clinic Edge Case – **RESOLVED** (CHK006)

If a patient navigates to a Package Details screen for a package whose parent clinic has been deactivated or whose Firestore document no longer exists:

- `GetPackageDetailsUseCase` returns a `ClinicUnavailableFailure`.
- The UI displays a non-dismissable Arabic message: *"هذه الباقة غير متاحة حاليًا. يرجى التواصل مع العيادة للمزيد من المعلومات."*
- The "اشترِ الآن" / "عرض الباقة" button is hidden.
- This package still appears in the patient's My Packages tab if they purchased it before deactivation, but a subtle banner *"(غير متاحة حاليًا)"* is shown next to the package name.

---

### 7.10 Offline / Low-Connectivity Behaviour – **RESOLVED** (CHK007, R7)

- **Firestore offline persistence** is enabled for the Packages feature. Previously loaded package lists and patient package records are served from the local Firestore cache when offline.
- If the cache has no data and the device is offline, the app shows an Arabic error banner: *"لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى."* with a "إعادة المحاولة" retry button.
- The "اشترِ الآن" button is **disabled** when the device is offline; tapping it shows: *"تعذر الاتصال بالإنترنت. يرجى التحقق من اتصالك قبل الشراء."*
- Document uploads (`UploadPackageDocumentUseCase`) require an active connection and return `NetworkFailure` if offline.

**Connectivity mechanism (R7)**: Connectivity state is detected via the `connectivity_plus` package (already a common AndroCare dependency). A shared `ConnectivityProvider` at `lib/core/network/connectivity_provider.dart` exposes a `Stream<bool> isOnline` used by all package screens. If the project does not yet have this provider, it must be created as part of Phase 1 setup (T002b). The `PackageDetailsPage` watches `ConnectivityProvider` to conditionally enable/disable the "اشترِ الآن" button.

---

### 7.11 Patient Notification on Document Upload – **RESOLVED** (CHK010)

- When an admin or doctor uploads a document to a patient package (`UploadPackageDocumentUseCase`), an in-app or FCM push notification is sent to the patient.
- Notification content (Arabic):
  - Title: *"مستند جديد في باقتك"*
  - Body: *"تم إضافة نتيجة طبية إلى باقة [packageName]. اضغط لعرضها."*
- The notification deep-links to the patient's My Packages detail view for the relevant `patientPackageId`.
- If the patient has opted out of notifications or FCM is unavailable, the upload proceeds without notification (best-effort delivery; no failure on notification error).

---

### 7.12 servicesUsage Storage Decision – **RESOLVED** (CHK042, R3)

- For this release, `servicesUsage` is stored as an **embedded array** inside the `patients/{patientId}/packages/{patientPackageId}` document.
- Rationale: The expected package size is ≤ 20 services. Firestore document size limit (1 MB) is not a concern at this scale.
- **Decision threshold**: If a package definition exceeds **30 distinct services**, the `servicesUsage` field for that package should be migrated to a dedicated subcollection `patients/{patientId}/packages/{patientPackageId}/serviceUsage/{serviceId}`. This migration is **deferred to a future iteration** and out of scope for this release.

**Atomicity requirement (R3)**: Because `servicesUsage` is an embedded array and multiple concurrent service-usage updates could occur simultaneously (e.g., two admins recording use of different services for the same patient package), **all writes to `servicesUsage` and `usedServicesCount` MUST use a Firestore Transaction** (read-then-write within a transaction). This prevents silent lost updates caused by last-write-wins semantics. `UpdatePackageServiceUsageUseCase` must use `FirebaseFirestore.runTransaction()` for every increment, not a direct `update()` call.

---

### 7.13 Concurrent Admin Edits – **RESOLVED** (CHK038, R1)

- Firestore uses **last-write-wins** semantics. If two admins edit the same package simultaneously, the last Firestore write prevails.
- To reduce conflict risk, the admin dashboard's Edit Package screen reads the current `updatedAt` timestamp **on form mount** and stores it as `loadedAt` in the form state. `UpdateClinicPackageUseCase` requires `loadedAt: Timestamp` as a **mandatory parameter**.

**`UpdateClinicPackageUseCase` concurrency behaviour (R1)**:
1. The use case receives `loadedAt: Timestamp` as a required parameter. If `loadedAt` is `null` or absent, the use case returns `StaleDataFailure` **immediately** without performing any Firestore read or write.
2. It reads the current `updatedAt` from Firestore for the package document.
3. If `currentUpdatedAt != loadedAt`, it returns `StaleDataFailure` without writing.
4. Otherwise it proceeds to validate fields, recompute derived booleans, and write with `updatedAt = serverTimestamp()`.

The admin is shown an Arabic prompt on `StaleDataFailure`: *"تم تعديل هذه الباقة من قِبل مستخدم آخر. الرجاء إعادة تحميل النموذج للاستمرار."*

- Full conflict-resolution (merge, lock) is **deferred to a future iteration**.

---

### 7.14 Payment Gateway Assumption – **RESOLVED** (CHK062)

- The existing AndroCare payment module (`PaymentService` / equivalent) is assumed to be available and callable from `PurchasePackageUseCase` via the DI container.
- The payment module is expected to expose a method with the following contract (exact API adapts to the current implementation):
  ```dart
  Future<Either<PaymentFailure, PaymentSuccess>> initiatePayment({required double amount, required String currency, required String packageRef});
  ```
  Where `PaymentSuccess` contains a non-empty `transactionId: String`.
- If the existing module does not provide this interface, an adapter wrapper (`PackagePaymentAdapter`) must be created in the Data layer without modifying the existing payment module.

---

### 7.15 Cloud Storage Configuration Assumption – **RESOLVED** (CHK063)

- Document uploads use **Firebase Storage** in the same Firebase project as the app.
- Storage bucket: the default project bucket (e.g. `gs://<project-id>.appspot.com`).
- Storage path pattern: `packageDocuments/{clinicId}/{patientId}/{patientPackageId}/{documentId}/{filename}`.
- Storage Security Rules must enforce that only `DOCTOR` and `ADMIN` roles can write to `packageDocuments/**`, and only the owning patient (`request.auth.uid == patientId` from the path) or an authorised role can read.
- Uploads are performed via the Flutter `firebase_storage` package (already a project dependency).

---

### 7.16 Clinic Records Existence Assumption – **RESOLVED** (CHK065)

- All five clinic records (`clinicId` values for Andrology, Physiotherapy, Internal/Family Medicine, Obesity/Nutrition, Chronic Diseases) **must exist** in Firestore under `clinics/{clinicId}` before this feature can be used.
- This is a **deployment prerequisite**: the DevOps/setup script or admin seeding step must create these records prior to release.
- If a `clinicId` referenced by a package is not found, `GetPackageDetailsUseCase` returns `ClinicUnavailableFailure` (see §7.9).
- **Validation**: Before submitting for review, run a Firestore read check on all five expected `clinicId` values in the `elajtech` database as part of the release checklist.

---

## 8. Domain Use Cases & Data Access (Summary)

### 8.1 Patient-side use cases

- **ListCategoryPackagesUseCase**  
  - Reads: `clinics/{clinicId}/packages` (filtered by `clinicId`, `category`, `status = ACTIVE`, ordered by `displayOrder`).  
  - Purpose: عرض قائمة الباقات في قسم معيّن للمريض.

- **GetPackageDetailsUseCase**  
  - Reads: `clinics/{clinicId}/packages/{packageId}` (+ اختيارياً سجل الباقة للمريض إن وجد).  
  - Purpose: عرض تفاصيل الباقة قبل الشراء أو عند الفتح من البطاقات.

- **PurchasePackageUseCase**  
  - Reads: تعريف الباقة من `clinics/{clinicId}/packages/{packageId}`.  
  - Writes: `patients/{patientId}/packages/{patientPackageId}` (إنشاء سجل شراء جديد بعد نجاح الدفع).

- **GetPatientPackagesUseCase**  
  - Reads: `patients/{patientId}/packages`.  
  - Purpose: تبويب "باقاتي" في ملف المريض (قائمة الباقات + الحالة + التقدم).

- **GetPatientPackageDetailsUseCase**  
  - Reads:  
    - `patients/{patientId}/packages/{patientPackageId}`  
    - `patients/{patientId}/packageDocuments` (filtered by `patientPackageId`).  
  - Purpose: تفاصيل الباقة داخل "باقاتي" بما في ذلك الخدمات المستخدمة والنتائج المرفوعة.

### 8.2 Admin-side use cases (Packages tab)

- **CreateClinicPackageUseCase**  
  - Writes: `clinics/{clinicId}/packages/{packageId}`.  
  - Purpose: إنشاء باقة جديدة لقسم معيّن من لوحة التحكم مع اسم/وصف عربيين.

- **UpdateClinicPackageUseCase**  
  - Reads/Writes: نفس الوثيقة في `clinics/{clinicId}/packages/{packageId}`.  
  - Purpose: تعديل بيانات الباقة (سعر، وصف، محتوى طبي، حالة…).

- **TogglePackageStatusUseCase**  
  - Writes: حقل `status` في `clinics/{clinicId}/packages/{packageId}`.  
  - Purpose: تفعيل/إيقاف/إخفاء الباقة بسرعة.

- **ListClinicPackagesForAdminUseCase**  
  - Reads: `clinics/{clinicId}/packages` مع فلاتر (`category`, `status`, `isFeatured`).  
  - Purpose: شاشة إدارة الباقات في لوحة التحكم.

### 8.3 Admin-side use cases (Patient Packages & Documents)

- **GetPatientPackagesForAdminUseCase**  
  - Reads: `patients/{patientId}/packages`.  
  - Purpose: عرض جميع الباقات التي اشتراها المريض في صفحة المريض بلوحة التحكم.

- **UploadPackageDocumentUseCase**  
  - Writes:  
    - ملف في Cloud Storage.  
    - وثيقة في `patients/{patientId}/packageDocuments/{documentId}` مرتبطة بـ `patientPackageId` و `serviceId` (إن وُجد).  
  - Purpose: رفع نتائج التحاليل/الأشعة وربطها بباقات المريض.

- **UpdatePackageServiceUsageUseCase** (اختياري)  
  - Reads/Writes: `patients/{patientId}/packages/{patientPackageId}` (تحديث `usedServicesCount` و `servicesUsage`).  
  - Purpose: تحديث تقدّم استخدام الباقة عند استهلاك خدمة داخلها.

## speckit.clarify: clinic_packages_full_flow

> All original clarification questions have been resolved. See §7.1–7.16 for decisions. The only remaining deferred items are: partial refunds/cancellations (§7.3), large-package servicesUsage migration (§7.12), and concurrent-edit full merge strategy (§7.13).

---

## 9. UX & UI Specifications

### 9.1 Button States – **RESOLVED** (CHK002)

The primary action button on the Package Details screen has four states:

| State | Label | Visual | Condition |
|---|---|---|---|
| Idle – not purchased | اشترِ الآن | Filled primary colour, enabled | No patient package record for this `packageId` |
| Loading – processing | (spinner, no text) | Filled, disabled | `PurchasePackageUseCase` in progress |
| Success – purchased | عرض الباقة | Filled secondary colour, enabled | Purchase succeeded; navigates to My Packages on tap |
| Already purchased (on load) | عرض الباقة | Filled secondary colour, enabled | A non-EXPIRED/COMPLETED record already exists |

- The transition from "اشترِ الآن" → loading → "عرض الباقة" must be **immediate** with no intermediate screen change.
- On any failure the button returns to "اشترِ الآن" (enabled) — see §7.5.

---

### 9.2 Empty States – **RESOLVED** (CHK004)

Every list screen must define an empty state:

| Screen | Empty state Arabic message |
|---|---|
| Category Packages List | *"لا توجد باقات متاحة في هذا القسم حاليًا"* + icon |
| My Packages (patient) | *"لم تشترِ أي باقة بعد. استكشف باقاتنا من قسم العمليات"* + CTA button |
| Package Documents (inside My Packages detail) | *"لم يتم رفع أي مستندات لهذه الباقة حتى الآن"* + icon |
| Admin – Packages List | *"لا توجد باقات مضافة لهذا القسم. اضغط على «إضافة باقة» للبدء"* |
| Admin – Patient Packages | *"لم يشترِ هذا المريض أي باقة حتى الآن"* |

- Empty states must not show a loading spinner; they appear after data is loaded and confirmed empty.

---

### 9.3 Featured Packages Display – **RESOLVED** (CHK011)

- A package with `isFeatured = true` displays a badge in the top-right corner of its card:
  - Badge label (Arabic): *"الأكثر اختيارًا"*
  - Badge colour: `AppColors.featured` (amber/gold from the existing design system; exact hex to be confirmed by designer).
  - Badge position: absolute, top-right corner of the package card, overlapping the card border.
- Featured packages appear first within their category list regardless of `displayOrder` value (featured flag overrides sort within the featured tier, then non-featured packages follow sorted by `displayOrder`).

---

### 9.4 Progress Indicator Format – **RESOLVED** (CHK012, CHK020, CHK031)

- The progress indicator uses the format: **`X / Y`** where X = `usedServicesCount` and Y = `totalServicesCount`.
- Numerals: **Western Arabic numerals** (0–9) to match the existing app convention (not Eastern Arabic ٠–٩); this can be revisited if the design system requires otherwise.
- In addition to the numeric label, a linear progress bar (`LinearProgressIndicator`) is shown below the label showing `usedServicesCount / totalServicesCount` as a percentage fill (0–100%).
- **With `quantity > 1` per service** *(CHK020)*: `usedServicesCount` at the package level is the count of services where `usedCount >= quantity` (i.e., fully consumed). A service partially used (e.g., 2 of 5 sessions) does **not** count toward `usedServicesCount` until all `quantity` units are used.
- **Testable acceptance criterion** *(CHK031)*: Given a package with 3 services (all `quantity = 1`) where 2 are used, the progress label must render as `"2 / 3"` and the bar must be filled to ≈67%.

---

### 9.5 displayOrder – **RESOLVED** (CHK013)

- `displayOrder` is a **manually entered integer** by the admin when creating or editing a package.
- **Default value**: when creating a new package, `displayOrder` defaults to `last_existing_displayOrder + 1` (i.e., the new package appears last within its category). If no packages exist yet, default = `1`.
- The admin UI provides a numeric input field for `displayOrder` in the Create/Edit Package form.
- Lower values appear first in the list (ascending sort).

---

### 9.6 packageType & Derived Boolean Fields – **RESOLVED** (CHK014, CHK067)

- `packageType` is the **single authoritative field** for the package consultation type.
- `includesVideoConsultation` and `includesPhysicalVisit` are **computed/denormalised booleans** kept for faster UI queries:
  - `includesVideoConsultation = packageType == 'VIDEO_ONLY' || packageType == 'BOTH'`
  - `includesPhysicalVisit = packageType == 'PHYSICAL_ONLY' || packageType == 'BOTH'`
- On every Create or Update operation, `CreateClinicPackageUseCase` and `UpdateClinicPackageUseCase` **must always recompute and write** these two derived fields from `packageType`. They must never be written independently.
- No **conflict** exists between the fields as long as this invariant is enforced. Planned removal of the booleans is **deferred to a future iteration** once all Firestore queries have been migrated to use `packageType` directly.

---

### 9.7 Validity Days – Start Date – **RESOLVED** (CHK015)

- `validityDays` is counted from **`purchaseDate`** (the Firestore Timestamp of the confirmed purchase), regardless of when the patient first uses a service.
- `expiryDate = purchaseDate + validityDays × 86400 seconds`.
- There is no "first-use" activation model in this release. The countdown starts at purchase.

---

### 9.8 Price Display – **RESOLVED** (CHK017)

- `price` is the **full package price inclusive of any applicable taxes/fees**. There is no separate tax field in this release.
- Patient-facing display format: `"[price] [currency]"` — for example: *"500 جنيه"* (using the Arabic word for the currency where available, falling back to the `currency` code).
- Admin-facing display: numeric field showing the raw value; currency shown as the stored code (e.g. `EGP`).
- `discountPercentage` (if present) is shown as a marketing callout (e.g., *"وفّر 20%"*) alongside the original price (calculated as `price / (1 - discountPercentage/100)` rounded to 2 decimal places).

---

### 9.9 Duplicate Package Action – **RESOLVED** (CHK018, CHK070)

**Semantics (CHK018)**:
- "Duplicate" creates a full copy of the package **within the same clinic** (`clinicId` is identical to the source). Cross-clinic duplication is not supported in this release.
- The duplicated package is created with:
  - All fields copied from the source except:
    - `id` → a new auto-generated Firestore document ID.
    - `status` → `INACTIVE` (the copy is always inactive by default to prevent accidental publishing).
    - `displayOrder` → `last_existing_displayOrder + 1` in the same category.
    - `createdAt` / `updatedAt` → `serverTimestamp()`.
  - `name` is prefixed with *"نسخة من: "* in the admin UI to distinguish it visually.

**`DuplicatePackageUseCase` (CHK070)**:
- Reads: `clinics/{clinicId}/packages/{sourcePackageId}`.
- Writes: `clinics/{clinicId}/packages/{newPackageId}` (new document with the fields above).
- Returns `Right(newPackageId)` on success, or a typed `Failure` on error.
- This use case is placed in `domain/usecases/` alongside other package use cases (see plan.md §Project Structure).

---

### 9.10 Document Ownership & Viewing – **RESOLVED** (CHK019, CHK040)

**Ownership (CHK019)**:
- Each document in `patients/{patientId}/packageDocuments` is scoped to a single patient. No cross-patient document queries are allowed (enforced by Firestore Security Rules per §7.6).
- The admin can see documents uploaded by any `DOCTOR` or `ADMIN` role for that patient, but not documents from other patients.

**Patient viewing behaviour (CHK040)**:
- In My Packages detail, each document is shown as a card with its `title` (Arabic) and `documentType` label.
- Supported file types for inline preview: PDF and images (JPEG, PNG). Other file types are offered as a download link only.
- Tapping a PDF or image opens a full-screen in-app viewer (using the device's built-in viewer via `url_launcher` or an in-app viewer package). There is no inline embed directly in the package detail screen.
- The patient can download any document to their device from the full-screen viewer.

---

### 9.11 Package Visibility After Admin Status Changes – **RESOLVED** (CHK037, CHK071)

**INACTIVE or HIDDEN package after purchase (CHK037, CHK071)**:
- A patient who purchased a package before it was set to `INACTIVE` or `HIDDEN` by the admin **continues to see it** in My Packages with its full details and progress.
- The package is no longer visible in the Category Packages List (it is filtered out for new patients).
- No visual change is made to the package card in My Packages — it still shows `status` (ACTIVE/COMPLETED/EXPIRED/PENDING) based on the patient package record, not the clinic package status.
- If the admin permanently deletes the package definition (if supported in future), the My Packages view must gracefully handle a missing source package by showing the last-known `name` and `category` stored in the patient's own purchase record.

---

### 9.12 Admin Input Validation – **RESOLVED** (CHK046)

All Create/Edit Package form fields must be validated before submission:

| Field | Rule |
|---|---|
| `name` | Required, 1–200 characters (Arabic text; trimmed) |
| `shortDescription` | Required, 1–500 characters |
| `description` | Optional, max 3000 characters |
| `services` list | At least 1 service required; each `displayName` 1–200 chars |
| `validityDays` | Required, integer ≥ 1 and ≤ 3650 (10 years) |
| `price` | Required, numeric > 0, max 999999.99 |
| `discountPercentage` | Optional, float 0–99.99 |
| `displayOrder` | Required, integer ≥ 1 |
| `currency` | Required, exactly 3 uppercase characters (e.g. `EGP`) |
| `termsAndConditions` | Optional, max 5000 characters |

- Validation errors are shown inline next to the relevant field in Arabic (e.g. *"الاسم مطلوب ولا يمكن أن يتجاوز 200 حرف"*).
- Submission is blocked until all required validations pass.

---

### 9.13 Document Upload Limits – **RESOLVED** (CHK041)

- **Maximum file size**: 20 MB per document.
- **Allowed file types**: PDF (`.pdf`), JPEG (`.jpg`, `.jpeg`), PNG (`.png`).
- If the selected file exceeds 20 MB, show the Arabic error: *"حجم الملف يتجاوز الحد المسموح به (20 ميجابايت). يرجى اختيار ملف أصغر."*
- If the file type is not allowed, show: *"نوع الملف غير مدعوم. الأنواع المدعومة: PDF، JPEG، PNG."*
- Validation occurs on the client before upload starts (no server-round-trip for type/size rejection).
- Document upload without linking to a specific service (`serviceId` is optional) is supported; in that case `serviceId = null` in the Firestore document.

---

### 9.14 RTL Layout & Arabic Date Format – **RESOLVED** (CHK053, CHK054)

**RTL (CHK053)**:
- All new screens (Operations Packages button, Categories screen, Category Packages List, Package Details, My Packages list, My Packages detail, Admin Packages tab, Admin Patient Packages section) must use RTL layout by default, inheriting the global app `Directionality`.
- Any screen or widget that contains **English-only content** (e.g., a numeric field, a URL, or a medical code) must wrap that specific widget with `Directionality(textDirection: TextDirection.ltr, child: ...)` per the project LTR/RTL rule.
- Progress bar (`LinearProgressIndicator`) must be wrapped with `Directionality(textDirection: TextDirection.ltr)` to keep fill direction left-to-right.

**Date format (CHK054)**:
- All dates shown to patients (`purchaseDate`, `expiryDate`, `uploadedAt`) must be formatted using the Arabic locale: `dd MMMM yyyy` — for example: *"7 مارس 2026"*.
- Use the `intl` package (`DateFormat.yMMMMd('ar')`) for formatting.
- Dates in admin interfaces may use the same Arabic locale for consistency.

---

## 10. Performance & Acceptance Criteria

### 10.1 Screen Load Time – **RESOLVED** (CHK028)

- **Target**: The Category Packages List and My Packages list screens must display their content (from cache or network) within **2 seconds** on a mid-range Android device (e.g., Snapdragon 680-class) on a 4G connection.
- If data is not available within 2 seconds, a `CircularProgressIndicator` is shown during the wait, not a blank screen.
- This is a **soft target** (performance regression test, not a hard gate for release).

### 10.2 Cloud Function Expiry SLA – **RESOLVED** (CHK030)

- The expiry Cloud Function must complete processing of all expired packages **within 5 minutes** of its midnight trigger time.
- If the function exceeds execution limits, it must be split into batches (Firestore `limit()` with cursor-based pagination).
- Any failed expiry writes must be retried via Cloud Function retry policy (configured on the function).

### 10.3 Duplicate Purchase Guard – **RESOLVED** (CHK029)

- **Testable assertion**: Given a patient with an existing `ACTIVE` patient package document for `packageId = "pkg-001"`, calling `PurchasePackageUseCase(patientId, packageId: 'pkg-001', ...)` must return `Left(PackageAlreadyActiveFailure())` without creating any new Firestore document.
- Unit test must mock `PatientPackageRepository.findActiveOrPendingByPackageId` to return an existing record and assert that no write is performed.

### 10.4 Test Coverage – **RESOLVED** (CHK032)

- Minimum **80% line coverage** for all files under `lib/features/packages/domain/` (use cases and repository interfaces).
- Minimum **70% line coverage** for all files under `lib/features/packages/data/` (models, data sources, repository implementations).
- Coverage is measured with `flutter test --coverage` and reported in CI. A coverage drop below these thresholds blocks the PR merge.
