# Implementation Plan: Patient "My Packages" Enhancement

## 1. Scope and Modules
- **Module**: `lib/features/packages` (shared with andrology packages).
- **Rule**: Clinic Isolation (no other clinics' logic in same entities/repositories).
- **Impacted Layers**:
    - **Domain**: `PatientPackageEntity`, `PatientPackageRepository`.
    - **Data**: `PatientPackageModel`, `PatientPackageRepositoryImpl`, `PurchasePackageUseCase`.
    - **Presentation**: `MyPackagesPage` (list), `MyPackagesDetailPage` (details).

## 2. Data and Mapping Plan
- **Name Resolution**:
    - Fix `PatientPackageRepositoryImpl.createPatientPackage` (T022) to include `packageName` in the Firestore document save.
    - Result: `PatientPackageEntity.packageName` will always contain the human-readable Arabic name from `PackageEntity.name`.
- **Snapshot Metadata on Purchase**:
    - Update `PatientPackageEntity` and `PatientPackageModel` to include:
        - `description`: Full package description.
        - `shortDescription`: Concise summary.
        - `validityDays`: Duration in days.
- **Service Usage Mapping**:
    - The UI will map `entity.packageServices` (snapshot definitions) to `entity.servicesUsage` (counters).
    - **Missing Usage Rule**: If a serviceId from `packageServices` is not found in `servicesUsage`, default its `usedCount` to 0. Show a 0% progress bar and text `Used: 0 / Y`.

## 3. Presentation Layer Tasks
- **"My Packages" Tab (Profile)**:
    - Update `_PatientPackageCard` to display `package.packageName` as the list item title.
- **Package Details Screen**:
    - Use `entity.packageName` as the screen header.
    - **NEW: "Package Info" Section**:
        - Display `description` and `validityDays` ("Duration: 90 Days").
    - **ENHANCE: "Included Services & Usage" Section**:
        - List each `packageServices` item with:
            - Icon based on `serviceType`.
            - `displayName`.
            - Ratio: `Used: X / Y`.
            - **Directionality**: Wrap the ratio text in `Directionality(textDirection: TextDirection.ltr)` to prevent RTL inversion.
            - `LinearProgressIndicator` based on the computed ratio.

## 4. Data Layer and Firestore Access
- **Repositories**: `PatientPackageRepository` (Interface), `PatientPackageRepositoryImpl`.
- **Datasources**: `FirestorePackageDatasource` (no changes needed to datasource, only to repository mapping).
- **Firestore Instance**: Use injected `FirebaseFirestore` via `GetIt` with `databaseId: 'elajtech'`.
- **Security (R2)**: Ensure `PatientPackageModel.fromFirestoreForPatient` continues to strip `notes` to prevent leaks.

## 5. Testing and Quality
- **Widget Tests**:
    - `test/features/packages/presentation/pages/my_packages_page_test.dart`: Verify correct `packageName` display.
    - `test/features/packages/presentation/pages/my_packages_detail_page_test.dart`:
        - Case: **No usage** (all 0 / Y).
        - Case: **Partial usage** (X / Y, check progress indicator value).
        - Case: **Full usage** (X == Y, check completion state).
- **Regression**: Run all existing tests in `test/integration/packages_flow_test.dart`.
- **Analytics**: Run `flutter analyze` and `flutter test --coverage` before completion.

## 6. Build Runner and Documentation
---

## الترجمة العربية (Arabic Translation)

### ١. النطاق والوحدات
- **الوحدة**: `lib/features/packages` (مشتركة مع باقات الذكورة).
- **القاعدة**: عزل العيادات (عدم خلط منطق العيادات الأخرى في نفس الكيانات/المستودعات).
- **الطبقات المتأثرة**:
    - **Domain**: `PatientPackageEntity`, `PatientPackageRepository`.
    - **Data**: `PatientPackageModel`, `PatientPackageRepositoryImpl`, `PurchasePackageUseCase`.
    - **Presentation**: `MyPackagesPage` (القائمة), `MyPackagesDetailPage` (التفاصيل).

### ٢. خطة البيانات والربط
- **حل الاسم المروض**:
    - إصلاح `PatientPackageRepositoryImpl.createPatientPackage` (T022) لتضمين `packageName` في مستند Firestore.
    - النتيجة: `PatientPackageEntity.packageName` سيحتوي دائمًا على الاسم العربي المقروء من `PackageEntity.name`.
- **أخذ لقطة من البيانات عند الشراء (Snapshot)**:
    - تحديث `PatientPackageEntity` و `PatientPackageModel` لتشمل:
        - `description`: وصف الباقة الكامل.
        - `shortDescription`: ملخص قصير.
        - `validityDays`: مدة الصلاحية بالأيام.
- **ربط استخدام الخدمات**:
    - ستقوم الواجهة بربط `packageServices` (تعريفات اللقطة) مع `servicesUsage` (العدادات).
    - **قاعدة البيانات المفقودة**: إذا لم يتم العثور على `serviceId` في `servicesUsage` ، فسيتم اعتباره 0. عرض شريط تقدم 0% ونص مثل `Used: 0 / Y`.

### ٣. مهام طبقة العرض (Presentation)
- **تبويب "باقاتي" (الملف الشخصي)**:
    - تحديث `_PatientPackageCard` لعرض `package.packageName` كعنوان رئيسي.
- **شاشة تفاصيل الباقة**:
    - استخدام `entity.packageName` كعنوان للشاشة.
    - **جديد: قسم "معلومات الباقة"**:
        - عرض `description` و `validityDays` ("المدة: 90 يومًا").
    - **تحسين: قسم "الخدمات المشمولة والاستخدام"**:
        - عرض كل خدمة مع: أيقونة، اسم الخدمة، نسبة الاستخدام `Used: X / Y`.
        - **الاتجاه**: تغليف نص النسبة بـ `Directionality(textDirection: TextDirection.ltr)` لمنع انعكاس الأرقام في الواجهة العربية.
        - شريط تقدم `LinearProgressIndicator` بناءً على النسبة المحسوبة.

### ٤. طبقة البيانات والوصول إلى Firestore
- **المستودعات**: `PatientPackageRepository` (واجهة), `PatientPackageRepositoryImpl`.
- **مصادر البيانات**: `FirestorePackageDatasource` (لا توجد تغييرات مطلوبة).
- **نسخة Firestore**: استخدام النسخة المحقونة عبر `GetIt` مع `databaseId: 'elajtech'`.
- **الأمان (R2)**: التأكد من أن `PatientPackageModel.fromFirestoreForPatient` لا يزال يزيل حقل `notes` لمنع التسريب.

### ٥. الاختبار والجودة
- **اختبارات Widget**:
    - `test/features/packages/presentation/pages/my_packages_page_test.dart`: التحقق من عرض `packageName` بشكل صحيح.
    - `test/features/packages/presentation/pages/my_packages_detail_page_test.dart`:
        - حالة: **لا يوجد استخدام** (0 / Y).
        - حالة: **استخدام جزئي** (X / Y).
        - حالة: **استخدام كامل** (X == Y).
- **التراجع**: تشغيل جميع الاختبارات الحالية في `test/integration/packages_flow_test.dart`.
- **التحليل**: تشغيل `flutter analyze` و `flutter test` قبل الانتهاء.

### ٦. منشئ الأكواد والتوثيق
- **Build Runner**: تشغيل `flutter pub run build_runner build --delete-conflicting-outputs`.
- **توثيق ثنائي اللغة (DartDoc)**:
    - إضافة تعليقات `///` إلى حقول `PatientPackageEntity` وطريقة `createPatientPackage`.
    - **العربية**: لوصف قواعد العمل.
    - **الإنجليزية**: للمواصفات التقنية.
    - تضمين أمثلة استخدام في التعليقات.
