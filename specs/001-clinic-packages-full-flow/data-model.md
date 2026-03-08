# Data Model: Clinic Packages Full Flow

## 1. Overview

This document defines the high-level Firestore data model and relationships required for:
- Clinic package definitions per clinic/specialty.
- Patient package purchases and usage progress.
- Medical documents (lab results / imaging reports) linked to specific package services.

All collections must use Firestore `databaseId = 'elajtech'` and respect Clinic Isolation (no shared mixed models between clinics).  
All **UI text shown to patients and doctors (package names, descriptions, category labels, status labels, service names)** must be stored or rendered **in Arabic**, while field names and enum values remain in English for consistency in code.

---

## 2. Collections Overview

1. `clinics/{clinicId}/packages/{packageId}`  
   - Master definitions of clinic packages per specialty.

2. `patients/{patientId}/packages/{patientPackageId}`  
   - Patient-specific purchases of packages, including status and progress.

3. `patients/{patientId}/packageDocuments/{documentId}`  
   - Documents (lab results, imaging reports, other files) linked to a patient package and an optional service inside that package.

(If the current project already has `clinics` / `patients` collections, this model extends them rather than replacing anything.)

---

## 3. Clinic Packages Collection

**Path**: `clinics/{clinicId}/packages/{packageId}`  

Represents a package that belongs to a specific clinic/specialty and a public category in the UI.

### 3.1 Fields

- `id` : `string`  
  - Document ID (duplicate field for convenience; equals `packageId`).

- `clinicId` : `string`  
  - Reference to the owning clinic/specialty (e.g. andrology, physiotherapy).  
  - Used to enforce Clinic Isolation in repositories.

- `category` : `string` (enum)  
  - Stored values (for logic and queries):  
    - `ANDROLOGY_INFERTILITY_PROSTATE`   → UI label (Arabic): **"باقات الذكورة والعقم والبروستاتا"**  
    - `PHYSIOTHERAPY_REHABILITATION`     → **"باقات العلاج الطبيعي والتأهيل"**  
    - `INTERNAL_FAMILY_MEDICINE`         → **"باقات الباطنة وطب الأسرة"**  
    - `OBESITY_THERAPEUTIC_NUTRITION`    → **"باقات السمنة والتغذية العلاجية"**  
    - `CHRONIC_DISEASES`                 → **"باقات الأمراض المزمنة"**  

- `name` : `string`  
  - اسم الباقة كما يظهر للمريض والطبيب **بالعربية** (مثال: "باقة الخصوبة الأساسية").

- `shortDescription` : `string`  
  - وصف مختصر للباقة **بالعربية** (تسويقي/طبي مختصر يظهر في كروت الباقات).

- `description` : `string` (optional, long)  
  - وصف تفصيلي **بالعربية** لمحتوى الباقة، خطواتها، وأي ملاحظات أو تعليمات.

- `services` : `array<object>`  
  - قائمة الخدمات داخل الباقة (تحاليل، أشعة، زيارات، جلسات). كل عنصر:
    - `serviceId` : `string`  
      - معرف داخلي للخدمة أو كود خدمة موجود في نظام الخدمات (لا يظهر للمريض مباشرة).
    - `serviceType` : `string` (enum: `LAB`, `IMAGING`, `VISIT`, `SESSION`, `OTHER`)  
      - نوع الخدمة للاستخدام المنطقي في الكود (مثلاً لعرض أيقونة مختلفة في الواجهة).
    - `displayName` : `string`  
      - اسم الخدمة كما يظهر للمريض والطبيب **بالعربية** (مثال: "تحليل سائل منوي").
    - `quantity` : `number` (optional, default 1)  
      - عدد المرات المسموح بها من هذه الخدمة داخل الباقة (خاصة للجلسات/الزيارات).

- `validityDays` : `number`  
  - مدة صلاحية الباقة بعد الشراء بعدد الأيام (مثال: 30).

- `termsAndConditions` : `string` (optional)  
  - نص الشروط والأحكام **بالعربية**، يمكن عرضه في شاشة تفاصيل الباقة.

- `price` : `number`  
  - سعر الباقة الإجمالي.

- `currency` : `string`  
  - مثال: `EGP`.

- `discountPercentage` : `number` (optional)  
  - نسبة الخصم مقارنة بشراء الخدمات منفصلة (تستخدم للتسويق في الواجهة).

- `packageType` : `string` (enum)  
  - **الحقل الأساسي (authoritative)** لنوع الباقة:
    - `VIDEO_ONLY`            → UI label: **"استشارات فيديو فقط"**
    - `PHYSICAL_ONLY`         → **"زيارات حضورية فقط"**
    - `BOTH`                  → **"فيديو وحضوري"**
    - `INVESTIGATIONS_ONLY`   → **"تحاليل وأشعة فقط"**

- `includesVideoConsultation` : `bool`  
  - **Derived from `packageType`** (true if `packageType` is `VIDEO_ONLY` or `BOTH`). **Must always be recomputed by the use case on every Create/Update write** — never written independently. Planned for removal in a future iteration once all queries use `packageType` directly. *(CHK014, CHK067)*  

- `includesPhysicalVisit` : `bool`  
  - **Derived from `packageType`** (true if `packageType` is `PHYSICAL_ONLY` or `BOTH`). Same derivation rule as above. *(CHK014, CHK067)*

- `status` : `string` (enum)  
  - القيم المخزنة:
    - `ACTIVE`   → UI label: **"مفعّلة"** (تظهر وتُشترى إذا لم تكن مخفية).  
    - `INACTIVE` → UI label: **"موقوفة"** (لا يمكن شراؤها، تظهر للأدمن فقط).  
    - `HIDDEN`   → UI label: **"مخفية من الواجهة"** (لا تظهر للمريض لكن تبقى في السجلات).

- `displayOrder` : `number`  
  - رقم ترتيب عرض الباقة داخل القسم (أصغر رقم يظهر أولاً).

- `isFeatured` : `bool`  
  - عند true يمكن إظهار شارة مثل "الأكثر اختيارًا" أو "موصى بها" في الـ UI.

- `createdAt` : `Timestamp`  
- `updatedAt` : `Timestamp`

### 3.2 Field Constraints *(CHK046)*

These constraints must be enforced client-side (form validation) and are documented here as the source of truth for all layers:

| Field | Type | Required | Constraint |
|---|---|---|---|
| `name` | string | ✅ | 1–200 chars (trimmed, Arabic) |
| `shortDescription` | string | ✅ | 1–500 chars |
| `description` | string | ❌ | max 3000 chars |
| `services` (array) | array | ✅ | min 1 item; each `displayName` 1–200 chars; `quantity` ≥ 1 |
| `validityDays` | number | ✅ | integer ≥ 1 and ≤ 3650 |
| `price` | number | ✅ | > 0, max 999999.99 |
| `discountPercentage` | number | ❌ | float 0–99.99 |
| `displayOrder` | number | ✅ | integer ≥ 1 |
| `currency` | string | ✅ | exactly 3 uppercase chars (e.g. `EGP`) |
| `termsAndConditions` | string | ❌ | max 5000 chars |

### 3.3 Mandatory Indexes *(CHK048)*

> Previously listed as "suggestions" — these are now **mandatory requirements** and must be created in Firestore before the feature is deployed.

- **Index 1** (Clinic package listing — patient & admin): `clinicId` ASC + `category` ASC + `status` ASC + `displayOrder` ASC
- **Index 2** (Featured packages query): `clinicId` ASC + `isFeatured` ASC + `displayOrder` ASC
- **Query limit** *(CHK049)*: All admin queries use `limit(20)` with cursor-based pagination (`startAfterDocument`). Patient-facing category queries load up to `limit(50)` in a single call (sufficient for expected package counts per category).

---

## 4. Patient Packages (Purchases)

**Path**: `patients/{patientId}/packages/{patientPackageId}`  

Represents a specific purchase of a package by a patient, including status and usage.

### 4.1 Fields

- `id` : `string`  
  - Document ID for this patient-package record.

- `patientId` : `string`  
  - Duplicate of `{patientId}` for easier queries / denormalization.

- `packageId` : `string`  
  - ID of the clinic package (from `clinics/{clinicId}/packages`).

- `clinicId` : `string`  
  - Owning clinic/specialty of this package.

- `category` : `string` (enum, copied from package)  
  - تستخدم في الفلاتر داخل تبويب "باقاتي"، وتُحوَّل إلى التسميات العربية المذكورة في قسم `category`.

- `status` : `string` (enum)  
  - القيم المخزنة:
    - `PENDING`   → UI label: **"في انتظار التفعيل / الدفع"**  
    - `ACTIVE`    → **"نشطة"**  
    - `COMPLETED` → **"مكتملة"**  
    - `EXPIRED`   → **"منتهية الصلاحية"**  

- `purchaseDate` : `Timestamp`  
  - تاريخ شراء الباقة (يُعرض للمريض بالعربية بصيغة التاريخ المحلية).

- `expiryDate` : `Timestamp`  
  - تاريخ انتهاء صلاحية الباقة.

- `totalServicesCount` : `number`  
  - إجمالي عدد الخدمات داخل الباقة (يُستخدم لحساب التقدم مثل ٣/٥).

- `usedServicesCount` : `number`  
  - عدد الخدمات التي تم استخدامها فعليًا.

- `servicesUsage` : `array<object>` (optional)  
  - تتبُّع استخدام كل خدمة داخل الباقة. يدعم الخدمات المتكررة (مثل 5 جلسات علاج طبيعي تُستخدم على دفعات):
    - `serviceId`   : `string` — معرف الخدمة (من `package.services`).
    - `usedCount`   : `number` — عدد المرات التي استُخدمت فيها الخدمة فعليًا (0 إذا لم تُستخدَم بعد). يُقارَن بـ `package.services[].quantity` لتحديد المتبقي.
    - `lastUsedAt`  : `Timestamp` (optional) — وقت آخر استخدام لهذه الخدمة.
  - **ملاحظة**: `usedServicesCount` على مستوى الوثيقة يُحسَب كعدد الخدمات التي وصل `usedCount` فيها إلى `quantity` المسموح به.
  - ⚠️ **متطلب الذرية (R3)**: جميع عمليات الكتابة إلى `servicesUsage` و`usedServicesCount` يجب أن تستخدم **Firestore Transaction** (قراءة ثم كتابة داخل Transaction لمنع التحديثات الضائعة عند التزامن). لا يجوز استخدام `update()` المباشر لهذين الحقلين.

- `paymentTransactionId` : `string` (**mandatory** when status = ACTIVE)  
  - معرف معاملة الدفع الصادر من بوابة الدفع. **هذا الحقل إلزامي وغير قابل للقيمة الفارغة عندما تكون الحالة ACTIVE** (spec.md §7.4). يُستخدَم للمطابقة والتدقيق المالي. مثال: `"TXN_20260307_0001"`.

- `notes` : `string` (optional — **admin/doctor only; never mapped to patient-facing entities**)  
  - ملاحظات داخلية للأدمن/الطبيب. **هذا الحقل مخصص للأدمن والطبيب حصريًا** ولا يُمرَّر أبدًا إلى الـ Entity المُعادة لشاشات المريض — التطبيق هو المسؤول عن إخفائه، وليس قواعد Firestore (R2، spec.md §7.8).

- `createdAt` : `Timestamp`  
- `updatedAt` : `Timestamp`

### 4.2 Mandatory Indexes *(CHK048)*

> These are **mandatory requirements**, not suggestions.

- **Index 3**: `patientId` ASC + `status` ASC
- **Index 4**: `patientId` ASC + `category` ASC (for filters in My Packages)
- **Index 5**: `patientId` ASC + `packageId` ASC + `status` ASC (for the `findActiveOrPendingByPackageId` guard in `PurchasePackageUseCase`)
- **Index 6 — Collection Group Index** *(R9)*: A **Firestore collection group index** on the `packages` collection group (cross-patient query) with fields `status` ASC + `expiryDate` ASC. **This index is mandatory for the Cloud Function's daily expiry query** (`collectionGroup('packages').where('status', '==', 'ACTIVE').where('expiryDate', '<', now())`). Without it, the Cloud Function query will fail with a Firestore index error at deploy time.
  - Also ensure the Cloud Function's service account has read/write permission to all `patients/*/packages` documents (add a `rules_version = '2'` collection group read rule for service accounts in `firestore.rules`).
- **Query limit** *(CHK049)*: Admin queries on patient packages use `limit(20)` per page. Patient My Packages tab loads all records in a single call (expected < 20 per patient).

---

## 5. Package Documents (Lab/Imaging Results)

**Path**: `patients/{patientId}/packageDocuments/{documentId}`  

Represents a document uploaded by doctor/admin that is linked to a patient package and optionally to a specific service inside that package.

### 5.1 Fields

- `id` : `string`  
  - Document ID.

- `patientId` : `string`  
  - Duplicate of `{patientId}`.

- `patientPackageId` : `string`  
  - Link to `patients/{patientId}/packages/{patientPackageId}`.

- `packageId` : `string`  
  - Source clinic package ID (denormalized for easier reporting).

- `clinicId` : `string`  
  - Owning clinic/specialty.

- `serviceId` : `string` (optional)  
  - معرف الخدمة داخل الباقة التي ينتمي لها هذا التقرير/التحليل (مثلاً تحليل معين داخل الباقة).

- `documentType` : `string` (enum)  
  - Stored values:
    - `LAB_RESULT`      → UI label: **"نتيجة تحليل معملي"**  
    - `IMAGING_REPORT`  → **"تقرير أشعة"**  
    - `OTHER`           → **"مستند طبي آخر"**  

- `title` : `string`  
  - عنوان قصير **بالعربية** يظهر للمريض في تبويب "باقاتي" (مثال: "نتيجة تحليل السكر").

- `description` : `string` (optional)  
  - وصف/ملاحظات **بالعربية** من الطبيب (مثال: "النتائج ضمن المعدل الطبيعي").

- `filePath` / `fileUrl` : `string`  
  - مسار التخزين أو رابط التحميل من Cloud Storage (لا يظهر للمريض كنص، بل يستخدمه التطبيق لعرض الملف).

- `uploadedByUserId` : `string`  
- `uploadedByRole` : `string` (e.g. `DOCTOR`, `ADMIN`)  
  - يمكن ترجمتها في الواجهة إلى "طبيب" / "أدمن".

- `uploadedAt` : `Timestamp`  
  - تاريخ ووقت رفع المستند.

### 5.2 Mandatory Index *(CHK048)*

> **Mandatory**, not a suggestion.

- **Index 6**: `patientId` ASC + `patientPackageId` ASC
- **Optional Index 7**: `patientPackageId` ASC + `serviceId` ASC (required if per-service document queries are implemented).
- **Query limit** *(CHK049)*: Document list queries per patient package use `limit(50)` (sufficient for expected max documents per package).

---

## 6. Relations Summary

- **Clinic Package → Patient Package**  
  - علاقة 1-to-many: باقة واحدة في `clinics/{clinicId}/packages/{packageId}` يمكن أن يكون لها عدة مشتريات في `patients/{patientId}/packages/{patientPackageId}` عبر `packageId` و `clinicId`.

- **Patient Package → Package Documents**  
  - علاقة 1-to-many: كل سجل شراء باقة يمكن أن يكون له عدة مستندات في `packageDocuments` مرتبطة بـ `patientPackageId` (و `serviceId` اختيارياً).

- **Patient → Packages + Documents**  
  - كل بيانات المريض (باقات + مستندات) تبقى تحت شجرة `patients/{patientId}` بما يتماشى مع هيكل الـ EMR الحالي إن وجد.

---

## 7. Open Points (to align with spec clarify)

- Confirm how the existing payment module signals “purchase success” and where to store transaction IDs (may add `paymentTransactionId` field to patient packages).  
- Decide whether a patient can have multiple active purchases for the same `packageId` simultaneously.  
- Decide whether `servicesUsage` remains embedded inside the patient package document or moved to a dedicated subcollection if we expect very large packages.
