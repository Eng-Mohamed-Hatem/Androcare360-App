# Checklist: Clinic Packages Full Flow

## 1. Specification & Scope

- [ ] spec.md reviewed and confirmed it covers:
  - استبدال زر "استشارة فيديو" في قسم العمليات بزر "الباقات".
  - شاشة أقسام الباقات الخمسة بالعربية.
  - قائمة الباقات لكل قسم (category packages list).
  - شاشة تفاصيل الباقة (تفاصيل، سعر، حالة، زر شراء/عرض).
  - تبويب "باقاتي" في ملف المريض (قائمة + تفاصيل + تقدم الاستخدام + المستندات).
  - تبويب "الباقات" في لوحة تحكم الأدمن.
  - قسم "باقات المريض" في صفحة المريض بلوحة التحكم.
- [ ] speckit.clarify section reviewed and critical questions addressed (payment flow, multiple purchases, permissions).

## 2. Data Model & Firestore

- [ ] data-model.md reviewed and confirms:
  - Packages collection per clinic:
    - `clinics/{clinicId}/packages/{packageId}`.
  - Patient packages (purchases) per patient:
    - `patients/{patientId}/packages/{patientPackageId}`.
  - Package documents per patient:
    - `patients/{patientId}/packageDocuments/{documentId}`.
- [ ] All fields shown in the UI are stored as Arabic text:
  - `name`, `shortDescription`, `description`, `services.displayName`,
    `title`, `description` in package documents.
- [ ] Enum values (`category`, `status`, `documentType`, `serviceType`) are documented with their Arabic labels.
- [ ] Firestore usage always goes through `databaseId = 'elajtech'` (no default `FirebaseFirestore.instance`).
- [ ] Required indexes identified:
  - Packages: `clinicId + category + status + displayOrder`.
  - Patient packages: `patientId + status`, `patientId + category`.
  - Package documents: `patientId + patientPackageId` (and optionally `patientPackageId + serviceId`).

## 3. Domain Layer (Use Cases & Repositories)

- [ ] Core domain repositories defined:
  - `PackageRepository`.
  - `PatientPackageRepository`.
- [ ] Domain use cases listed in spec.md (Domain Use Cases section):

  **Patient:**
  - `ListCategoryPackagesUseCase` – عرض قائمة الباقات لقسم معيّن.
  - `GetPackageDetailsUseCase` – عرض تفاصيل الباقة.
  - `PurchasePackageUseCase` – تسجيل شراء الباقة بعد نجاح الدفع.
  - `GetPatientPackagesUseCase` – تبويب "باقاتي".
  - `GetPatientPackageDetailsUseCase` – تفاصيل باقة معيّنة داخل "باقاتي".

  **Admin – Packages:**
  - `CreateClinicPackageUseCase`.
  - `UpdateClinicPackageUseCase`.
  - `TogglePackageStatusUseCase`.
  - `ListClinicPackagesForAdminUseCase`.

  **Admin – Patient Packages:**
  - `GetPatientPackagesForAdminUseCase`.
  - `UploadPackageDocumentUseCase`.
  - `UpdatePackageServiceUsageUseCase` (if adopted).

- [ ] Clinic Isolation respected:
  - No single repository mixing logic for different clinics.
  - Separate implementations per clinic in data layer where needed (andrology, physiotherapy, etc.).

## 4. Patient App – UI & UX

### 4.1 Operations → Packages

- [ ] "Packages" button position in Operations screen clearly defined and replaces/augments "استشارة فيديو" as per final design.
- [ ] Categories screen shows 5 Arabic categories:
  - "باقات الذكورة والعقم والبروستاتا"
  - "باقات العلاج الطبيعي والتأهيل"
  - "باقات الباطنة وطب الأسرة"
  - "باقات السمنة والتغذية العلاجية"
  - "باقات الأمراض المزمنة"
- [ ] Category packages list screen:
  - Shows package name (Arabic), short description (Arabic), price, featured badge if applicable, and clear pricing state.
  - Handles empty state with a clear Arabic message (لا توجد باقات متاحة لهذا القسم).
- [ ] Package details screen:
  - Displays:
    - الاسم، القسم، وصف تفصيلي بالعربية.
    - قائمة الخدمات (تحاليل/أشعة/جلسات) بأسماء عربية.
    - السعر، العملة، الخصم إن وجد، مدة الصلاحية، الشروط بالعربية.
    - حالة الباقة للمريض إن كانت مشتراة.
  - Primary action button:
    - "اشترِ الآن" إذا لم تُشترَ.
    - "عرض الباقة" إذا كانت مشتراة (ينقل إلى تبويب "باقاتي" على نفس الباقة).

### 4.2 Profile → My Packages

- [ ] "باقاتي" tab added to patient profile.
- [ ] My Packages list shows for each package:
  - اسم الباقة بالعربية.
  - القسم بالعربية.
  - الحالة بالعربية:
    - "نشطة"، "مكتملة"، "منتهية الصلاحية"، "في انتظار التفعيل".
  - تاريخ الشراء وتاريخ الانتهاء (بصيغة عربية/محلية).
  - Progress indicator: عدد الخدمات المستخدمة / الإجمالي (مثال: ٣ / ٥).
- [ ] Package details inside "باقاتي" show:
  - الخدمات المستخدمة والمتبقية.
  - المستندات المرتبطة بكل خدمة (تحليل، أشعة، مستند آخر) بعناوين عربية.
- [ ] Edge cases covered:
  - لا توجد باقات.
  - باقة منتهية مع توضيح السبب/الوقت.
  - أخطاء الشبكة مع زر "إعادة المحاولة".

## 5. Admin Dashboard – Packages Management

- [ ] "الباقات" tab added to admin dashboard.
- [ ] Packages list view:
  - Filtering by clinic/category/status/featured.
  - Columns include: اسم الباقة (عربي)، القسم، الحالة، السعر، ترتيب العرض، مميزة أو لا.
- [ ] Create / Edit package screen:
  - Inputs:
    - الاسم بالعربية.
    - الوصف المختصر والتفصيلي بالعربية.
    - القسم (واحد من الأقسام الخمسة).
    - قائمة الخدمات (services) مع `displayName` بالعربية لكل خدمة.
    - مدة الصلاحية (أيام).
    - الشروط بالعربية.
    - السعر، العملة، نسبة الخصم.
    - نوع الباقة (تشمل استشارات فيديو / زيارات حضورية / تحاليل فقط).
    - الحالة (مفعّلة، موقوفة، مخفية من الواجهة).
    - ترتيب العرض وكونها باقة مميزة (Featured).
- [ ] Management actions available:
  - إنشاء باقة جديدة.
  - تعديل باقة موجودة.
  - تفعيل / إيقاف / إخفاء باقة.
  - نسخ (Duplicate) باقة لتسريع إنشاء باقات مشابهة.

## 6. Admin Dashboard – Patient Packages & Documents

- [ ] "باقات المريض" section exists on admin patient detail page.
- [ ] Section shows:
  - All packages purchased by the patient with status, progress, and dates.
- [ ] Admin/doctor can open a specific patient-package context to see:
  - الخدمات داخل الباقة وحالة استخدامها.
  - المستندات المرتبطة بكل خدمة.
- [ ] Document upload flow:
  - الطبيب/الأدمن يمكنه رفع:
    - نتائج تحاليل (LAB_RESULT).
    - تقارير أشعة (IMAGING_REPORT).
    - مستندات أخرى (OTHER).
  - عنوان المستند ووصفه يُكتبان بالعربية.
  - المستند يُربط بـ `patientPackageId`، ويفضل أيضًا بـ `serviceId` عندما يكون مرتبطًا بخدمة محددة.

## 7. Security, Auth & Data Safety

- [ ] Auth rules respected:
  - Access to `patients/{patientId}` data only for authorized users.
- [ ] Firestore access:
  - No use of default `FirebaseFirestore.instance`; only the elajtech instance (`databaseId = 'elajtech'`).
  - All snapshot parsing checks `snapshot.exists` and `snapshot.data` before mapping to models.
- [ ] Null-safety:
  - No `!` used on potentially null objects (especially auth user and Firestore data).
- [ ] Permissions considered:
  - من يستطيع رؤية الباقات ونتائجها (المريض نفسه + الأطباء المصرّح لهم).
  - من يستطيع رفع المستندات (طبيب، أدمن فقط).

## 8. Testing & QA

- [ ] Unit tests:
  - Use cases: list packages, get package details, purchase package, get patient packages, upload package document.
  - Repositories: correct Firestore reads/writes and error handling.
- [ ] Widget tests:
  - Category packages list screen (including empty/error states).
  - Package details screen.
  - "باقاتي" tab (states: no packages, active packages, expired packages).
- [ ] Integration test:
  - Full flow:
    - فتح قسم العمليات → الضغط على "الباقات".
    - اختيار قسم → اختيار باقة.
    - محاكاة شراء ناجح (Mock payment) → ظهور الباقة في تبويب "باقاتي".
- [ ] Existing tests preserved:
  - No existing tests are broken (Test Persistence Rule respected).

## 9. Localization & Arabic UI

- [ ] All user-facing text for patients and doctors in this feature is Arabic:
  - Category names, package names, service names, status labels, document titles, error/empty messages.
- [ ] Mapping from enum values (`status`, `category`, `documentType`) to Arabic labels implemented in code or intl ARB files.
- [ ] RTL layout verified:
  - النصوص تُعرض باتجاه صحيح (RTL)، والأزرار/الأيقونات متوافقة مع تصميم التطبيق الحالي.
