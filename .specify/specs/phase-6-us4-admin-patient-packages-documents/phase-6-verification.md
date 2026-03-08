# Phase 6 - US4: Admin Patient Packages & Document Upload
# Verification & QA Plan

This document outlines the Comprehensive Verification and Quality Assurance Plan for **Phase 6 (US4)**. 

---

## 1. Test Matrix

### Domain Use Cases (Unit Tests)
| Component | Scenarios | Test Type |
|-----------|-----------|-----------|
| `GetPatientPackagesForAdminUseCase` | - Valid ID returns accurate package list<br>- Empty list returned for patient with no packages<br>- Invalid/Null IDs return appropriate Failures | Unit |
| `UploadPackageDocumentUseCase` | - Valid file (≤20MB, pdf/jpg/png) generates reliable URL<br>- File >20MB rejected with correct Arabic message<br>- Invalid type rejected with correct Arabic message | Unit |
| `UpdatePackageServiceUsageUseCase`| - Firebase transaction correctly commits new usage object<br>- `usedServicesCount` dynamically matches length<br>- Failure/race condition handled securely | Unit |

### Providers & UI Components (Widget Tests & UI Integration)
| Component | Scenarios | Test Type |
|-----------|-----------|-----------|
| `adminPatientPackagesProvider`<br>`uploadDocumentProvider` | - State changes tracked correctly (loading, success, error) | Unit / Widget |
| `AdminPatientPackagesPage` | - Packages list structurally correct<br>- Loading skeletons display appropriately<br>- Empty state displays nicely | Widget |
| `AdminPatientPackageContextView`| - Admins can visibly read the `notes`<br>- List of used Services properly builds | Widget |
| `DocumentUploadBottomSheet` | - Upload button disabled when no file picked<br>- File picker behaves intuitively<br>- Pre-upload UI validation flags oversized / invalid files natively | Widget |

---

## 2. Automated Checks

Run the following commands directly via terminal before concluding Phase 6:

### Unit Tests
```bash
flutter test test/features/admin/domain/use_cases/get_patient_packages_for_admin_use_case_test.dart
flutter test test/features/admin/domain/use_cases/upload_package_document_use_case_test.dart
flutter test test/features/admin/domain/use_cases/update_package_service_usage_use_case_test.dart
```

### Widget Tests
```bash
flutter test test/features/admin/presentation/screens/admin_patient_packages_page_test.dart
flutter test test/features/admin/presentation/widgets/admin_patient_package_context_view_test.dart
flutter test test/features/admin/presentation/widgets/document_upload_bottom_sheet_test.dart
```

### Regression & Static Analysis
```bash
# Verify no regressions across all tests!
flutter test

# Verify zero static-analysis violations
flutter analyze
```

---

## 3. Firestore & Storage Verification

To confirm backend integrity, perform the following validation:

1. **Storage Path & Metadata**
   - Upload a test document from the app.
   - Go to Firebase Storage Console. Verify the file exists exactly at `/patient_packages/{packageId}/{documentId}`.
   - Check file metadata natively in the console: file type and size must be accurate.
2. **Atomic Usage Tracking (Firestore)**
   - Go to Firestore -> `patient_packages` collection.
   - Check the `servicesUsage` array. A new mapped entry should be appended.
   - Verify `usedServicesCount` actively matches `servicesUsage.length`. Confirm there are NO lost updates (atomic transaction success).
3. **Notes Field (Data Protection)**
   - Verify that the `notes` field is strictly stored inside the queried package document.
   - Execute the Admin query and ensure `notes` maps properly.
   - Emulate a Patient query and actively confirm the `notes` field is entirely missing / stripped from the payload!

---

## 4. Manual QA Scenarios

Run these manual End-to-End steps systematically within a real-device or emulator testing environment:

1. **View Patient Packages List**
   - Login with Admin credentials. Navigate to the assigned patient's packages list.
   - Confirm previously generated test packages visibly load.
2. **Open a Package & Inspect Usage**
   - Tap onto one specific package.
   - Read the explicit `notes` field natively in the Admin UI. Confirm current count of applied services is accurate.
3. **Upload Valid Document**
   - Open Document Upload Bottom Sheet. Select a valid `.pdf` or `.png` file (<20MB).
   - Press "Upload" and wait for the success response. Refresh the list to check visibility.
4. **Trigger Validation Errors**
   - Attempt to upload an incredibly large `.pdf` (>20MB). *Observe the UI for Arabic text limiting size constraints.*
   - Attempt to upload an `.exe` or `.txt`. *Observe the UI for Arabic text enforcing supported files formatting.*
5. **Cross-Reference Patient View**
   - Login natively as the Patient attached to the active package.
   - View the detailed package overview; assert that the newly uploaded document displays correctly, but the **`notes` field is absolutely hidden.**

---

## 5. Exit Criteria for Phase 6

To declare Phase 6 100% "Done", all checkboxes must be successfully cleared:
- [ ] All US4 specific unit and widget tests are natively passing.
- [ ] No new or existing tests are failing (100% test integrity across the 700+ suite).
- [ ] `flutter analyze` returns completely clean (Zero warnings, info, or errors).
- [ ] Firestore transactions exclusively handle `servicesUsage` updates to maintain atomic integrity.
- [ ] `notes` field logic remains isolated (Visible to Admins/Doctors, Hidden from Patients).
- [ ] Storage paths properly align to `/patient_packages/...` structure with validated constraints (≤20MB / appropriate extensions).
- [ ] All required UI error messaging natively displays in Arabic.

<br>
<br>

---

# ترجمة الخطة إلى اللغة العربية
<div dir="rtl" align="right">

# المرحلة السادسة - قصة المستخدم 4: باقات المرضى للمسؤولين ورفع المستندات
# خطة التحقق وضمان الجودة

تحدد هذه الوثيقة خطة التحقق الشاملة وضمان الجودة لـ **المرحلة السادسة (US4)**.

---

## 1. مصفوفة الاختبارات

### حالات الاستخدام (اختبارات الوحدة - Unit Tests)
| المكون | السيناريوهات | نوع الاختبار |
|--------|--------------|--------------|
| `GetPatientPackagesForAdminUseCase` | - معرّف صحيح يرجع القائمة بدقة<br>- المريض بدون باقات يرجع قائمة فارغة<br>- المعرّف الخاطئ/الفارغ يرجع خطأ صريح | وحدة |
| `UploadPackageDocumentUseCase` | - ملف صحيح (≤20MB، بصيغة pdf/jpg/png) يرفع بنجاح<br>- ملف >20MB يُرفض مع رسالة عربية صحيحة<br>- صيغة غير صالحة تُرفض مع رسالة عربية صحيحة | وحدة |
| `UpdatePackageServiceUsageUseCase`| - تحديث الاستخدام يتم كعملية واحدة (Transaction)<br>- العداد `usedServicesCount` يتطابق مع طول القائمة<br>- التعامل مع الفشل بشكل آمن | وحدة |

### المزودات ومكونات الواجهة (اختبارات الواجهة - Widget Tests)
| المكون | السيناريوهات | نوع الاختبار |
|--------|--------------|--------------|
| `adminPatientPackagesProvider`<br>`uploadDocumentProvider` | - تتبع تغييرات الحالة بدقة (جاري التحميل، نجاح، فشل) | وحدة / واجهة |
| `AdminPatientPackagesPage` | - هيكلة قائمة الباقات صحيحة<br>- عرض تأثيرات التحميل عند طلب البيانات<br>- العرض السليم عند عدم وجود باقات | واجهة |
| `AdminPatientPackageContextView`| - للمسؤولين صلاحية رؤية حقل `الملاحظات` (Notes)<br>- عرض قائمة الخدمات المستخدمة وسجلها | واجهة |
| `DocumentUploadBottomSheet` | - زر الرفع غير مفعل إن لم يُختر ملف<br>- عمل لاقط الملفات بشكل طبيعي<br>- التحقق قبل الرفع يُظهر رسائل التحذير للأحجام العالية أو الصيغ المرفوضة | واجهة |

---

## 2. الفحوصات الآلية

نفذ الأوامر التالية عبر الطرفية (Terminal) قبل إنهاء المرحلة 6:

### اختبارات الوحدة (Unit Tests)
```bash
flutter test test/features/admin/domain/use_cases/get_patient_packages_for_admin_use_case_test.dart
flutter test test/features/admin/domain/use_cases/upload_package_document_use_case_test.dart
flutter test test/features/admin/domain/use_cases/update_package_service_usage_use_case_test.dart
```

### اختبارات الواجهة (Widget Tests)
```bash
flutter test test/features/admin/presentation/screens/admin_patient_packages_page_test.dart
flutter test test/features/admin/presentation/widgets/admin_patient_package_context_view_test.dart
flutter test test/features/admin/presentation/widgets/document_upload_bottom_sheet_test.dart
```

### اختبار التراجع وتحليل الكود الشامل
```bash
# لضمان عدم تعطل أي كود سابق:
flutter test

# للتأكد من عدم وجود رسائل تحذير أو أخطاء برمجية:
flutter analyze
```

---

## 3. التحقق من قاعدة البيانات (Firestore) ومساحة التخزين (Storage)

لضمان سلامة الخلفية (Backend)، اتبع الآتي:

1. **مسار التخزين والبيانات الوصفية (Metadata)**
   - ارفع مستنداً للاختبار من التطبيق.
   - افتح لوحة Firebase Storage وتأكد من وجود الملف في مسار `/patient_packages/{packageId}/{documentId}`.
   - تحقق من حجم ونوع الملف في لوحة تحكم Firebase وتأكد من دقتهما.
2. **تتبع الاستخدام الدقيق (Transactions في Firestore)**
   - توجه إلى مجموعة `patient_packages` في Firestore.
   - قائمة `servicesUsage` يجب أن تتضمن قيداً جديداً.
   - العداد `usedServicesCount` يجب أن يُحدث ويكون مطابقاً تماماً لطول قائمة `servicesUsage`.
3. **حقل الملاحظات (سرية البيانات)**
   - تأكد أن حقل `notes` يُحفظ كجزء من سجل الباقة.
   - تحقق من إرجاع الحقل عند الاستعلام بصلاحيات المسؤول (Admin).
   - تحقق من إخفاء حقل `notes` بالكامل عند الاستعلام بحساب المريض.

---

## 4. سيناريوهات الاختبار اليدوي (Manual QA)

قم بإجراء هذه الخطوات يدوياً بشكل متسلسل داخل بيئة محاكي أو جهاز حقيقي:

1. **عرض قائمة باقات المرضى**
   - سجل الدخول بحساب مسؤول. انتقل إلى قائمة الباقات لمريض الاختبار.
   - تأكد من ظهور باقات المريض بشكل سليم.
2. **فتح الباقة وفحص سجل الاستخدام**
   - انقر لتفقد إحدى الباقات.
   - اقرأ حقل `الملاحظات` من واجهة المسؤول بصرياً، وتأكد من تعداد الخدمات بشكل دقيق.
3. **رفع مستند صالح**
   - افتح القائمة السفلية للرفع، واختر ملف `.pdf` أو `.png` بحجم أقل من 20MB.
   - اضغط "رفع" وانتظر رسالة النجاح، ثم قم بتحديث الصفحة للتأكد من ظهور المستند.
4. **تعمد إحداث أخطاء (Validation Errors)**
   - حاول رفع ملف PDF يتخطى 20 ميجابايت ولاحظ رسالة الخطأ العربية: *"حجم الملف كبير جداً (الحد الأقصى: 20 ميجابايت)"*.
   - حاول رفع ملف مثل `.exe` ولاحظ ظهور الرسالة العربية: *"نوع الملف غير مدعوم. يرجى اختيار PDF أو صورة"*.
5. **مراجعة وتطابق حساب المريض**
   - سجل الدخول كـ "مريض" باستخدام حساب متصل بالباقة المختبرة.
   - راجع تفاصيل الباقة وتأكد من أن المستند الجديد مرئي، ولكن تأكد تماماً أن **حقل الملاحظات (Notes) مخفي كلياً**.

---

## 5. معايير الإنهاء وختم المرحلة 6

لإعلان اكتمال هذه المرحلة بشكل قطعي، يجب وضع علامة الالتزام على كافة النقاط التالية:
- [ ] نجاح جميع اختبارات الوحدة والواجهة المخصصة لقصة المستخدم US4.
- [ ] لا يوجد أي تراجع (Regressions) أو تعطل في بطاقات الاختبار السابقة (أكثر من 700 اختبار).
- [ ] أمر `flutter analyze` يعود نظيفاً بالكامل بلا تحذيرات (Zero Errors/Warnings).
- [ ] نجاح عمليات Firestore التبادلية (Transactions) بالربط الدقيق بين `usedServicesCount` وسجل `servicesUsage`.
- [ ] آلية إخفاء `notes` صارمة وفعالة لتوفير حماية وخصوصية المريض بينما تُتاح للمسؤول.
- [ ] آلية الموافقة على رفع الملفات تمنع بصورة مرئية أي ملف يفوق الحدود الحجمية أو يختلف بالصيغة المدعومة قبل عملية الرفع بالخادم.
- [ ] المستندات المرفوعة تستخدم المسار التخزيني الاستراتيجي المعتمد والمحدد مسبقاً في خطة التطوير بشكل تام.

</div>
