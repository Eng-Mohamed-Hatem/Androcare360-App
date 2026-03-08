# Phase 6: US4 – Admin Patient Packages & Document Upload Verification Plan

## 1. Task Verification Matrix & Expected Behaviours

| Task | Component | Required Tests | Expected Manual QA Behaviours |
|---|---|---|---|
| **T070** | `GetPatientPackagesForAdminUseCase` Tests | Unit tests covering: paginated success, empty result, inclusion of `notes` field. | (N/A - backend only) |
| **T071** | `GetPatientPackagesForAdminUseCase` Impl | N/A (Tested in T070) | يقوم النظام بجلب الباقات الخاصة بالمريض للأدمن مع تضمين حقل "الملاحظات" (Notes) ويدعم التقسيم لصفحات (20 عنصر). |
| **T072** | `UploadPackageDocumentUseCase` Tests | Unit tests covering: success, Storage error, file > 20MB, unsupported type, null `serviceId`, offline. | (N/A - backend only) |
| **T073** | `UploadPackageDocumentUseCase` Impl | N/A (Tested in T072) | يمكن رفع ملفات PDF/JPG/PNG حجمها أقل من 20 ميجا. يتم الحفظ في قاعدة البيانات وإرسال إشعار للمريض. |
| **T074** | `UpdatePackageServiceUsageUseCase` Tests | Unit tests covering: usedCount increment, usedServicesCount logic, and concurrent execution transaction safety. | (N/A - backend only) |
| **T075** | `UpdatePackageServiceUsageUseCase` Impl | N/A (Tested in T074) | يتم تحديث الاستخدام بشكل آمن عند تسجيل الأدمن لخدمة محددة، مع منع فقدان البيانات في حال التحديث المتزامن. |
| **T076** | Admin Providers | Unit/Integration tests for `adminPatientPackagesProvider` and `uploadDocumentProvider`. | (N/A - State management) |
| **T077** | Admin Patient Detail Integration | Widget/Manual validation | ظهور قسم "باقات المريض" في صفحة تفاصيل المريض للأدمن. |
| **T078** | `AdminPatientPackagesPage` | Widget test (T081) | ظهور قائمة باقات المريض (الاسم، الفئة، الحالة، التقدم، التواريخ) باللغة العربية، وحقل "الملاحظات" ظاهر وقابل للتعديل للأدمن. |
| **T079** | `AdminPatientPackageContextView` | Widget test | عرض تفاصيل استخدام كل خدمة (مثال: 2/5)، قائمة المستندات، وزر "رفع مستند" العائم. ظهور تسميات "طبيب" / "أدمن". |
| **T080** | `DocumentUploadBottomSheet` | Widget test | نموذج لرفع المستند: نوع المستند (قائمة منسدلة)، العنوان (إلزامي)، الوصف، اختيار ملف (<= 20MB). رسائل الخطأ والنجاح باللغة العربية. |
| **T081** | Admin Package Widget Tests | Widget tests covering: loading, empty state, package list, upload button, and `notes` visibility. | (N/A - Automated UI verification) |

---

## 2. Automated Testing Commands

Run the following commands to strictly verify Phase 6 Implementation:

**Targeted Unit Tests for Phase 6:**
```bash
flutter test test/unit/features/packages/domain/get_patient_packages_for_admin_usecase_test.dart
flutter test test/unit/features/packages/domain/upload_package_document_usecase_test.dart
flutter test test/unit/features/packages/domain/update_package_service_usage_usecase_test.dart
```

**Targeted Widget Tests for Phase 6:**
```bash
flutter test test/widget/features/packages/admin/admin_patient_packages_page_test.dart
```

**Full Suite Verification (Regression check):**
```bash
flutter test
```

---

## 3. Specific Confirmation Steps

### A. Visibility of `notes` Field (R2)
- **Unit Test**: Ensure `fromFirestoreForAdmin()` correctly parses the `notes` field while `fromFirestore()` (used by patients) ignores or drops it (must be covered in `T070`).
- **Manual QA**: 
  1. Login as a Patient -> navigate to Package Details -> Ensure **no** "notes" field is visible.
  2. Login as Admin/Doctor -> navigate to the Patient's Package page (`AdminPatientPackagesPage`) -> Ensure the `notes` field **is visible**.

### B. Transaction Safety for `UpdatePackageServiceUsageUseCase` (R3, R10)
- **Unit Test Check**: Verify test T074(d) passes. This test must simulate two concurrent calls and use Mockito's `verify` to ensure `Transaction.update` was fired securely.
- **Code Check**: Open `update_package_service_usage_usecase.dart`. Verify there is no direct call to `collection(...).doc(...).update(...)`. All logic reading/writing usage counts **must** be inside `FirebaseFirestore.instance.runTransaction()`.

### C. Upload Validation & FCM Behaviour (R5)
- **Validation QA**: Attempt to upload a dummy file > 20 MB via `DocumentUploadBottomSheet`. Expect a localized error: `حجم الملف يجب ألا يتجاوز 20 ميجابايت`. Attempt an unsupported format (e.g., `.txt`) and verify rejection.
- **FCM Behaviour QA**: Upload a valid PDF. Switch to the Patient account and verify receipt of a notification. Ensure that if FCM fails (can be mocked in tests), the document is still successfully uploaded to Firestore.

---

## 4. Exit Criteria for Phase 6 (DONE)

- [ ] **T070 - T081** are marked as complete.
- [ ] All Unit and Widget tests for Phase 6 pass successfully (`GetPatientPackagesForAdminUseCase`, `UploadPackageDocumentUseCase`, `UpdatePackageServiceUsageUseCase`, `AdminPatientPackagesPage`).
- [ ] `flutter analyze` returns zero issues.
- [ ] `flutter pub run build_runner build --delete-conflicting-outputs` completes without conflict.
- [ ] Manual Verification QA matching the behaviours described above is passed.
- [ ] The `notes` field remains strictly hidden from patients but fully transparent to admins.
- [ ] Mandatory debugPrint logs for all Updates (Firestore Update Rule) are present for `UpdatePackageServiceUsageUseCase`.

---

<div dir="rtl">

# المرحلة السادسة: خطة التحقق من باقات المريض للأدمن ورفع المستندات (US4)

## 1. مصفوفة التحقق من المهام والسلوكيات المتوقعة

| المهمة | المكون | الاختبارات المطلوبة | السلوكيات المتوقعة في الفحص اليدوي (QA) |
|---|---|---|---|
| **T070** | اختبارات `GetPatientPackagesForAdminUseCase` | اختبارات الوحدة: المسار الناجح مع التقسيم لصفحات، النتيجة الفارغة، وجود حقل `notes`. | (لا يوجد - يخص الباك إند فقط) |
| **T071** | تنفيذ `GetPatientPackagesForAdminUseCase` | لا يوجد (تم اختباره في T070) | يقوم النظام بجلب الباقات الخاصة بالمريض للأدمن مع تضمين حقل "الملاحظات" (Notes) ويدعم التقسيم لصفحات (20 عنصر). |
| **T072** | اختبارات `UploadPackageDocumentUseCase` | اختبارات الوحدة: المسار الناجح، خطأ في مساحة التخزين، ملف > 20 ميجا، صيغة غير مدعومة، `serviceId` غير موجود، انقطاع الشبكة. | (لا يوجد - يخص الباك إند فقط) |
| **T073** | تنفيذ `UploadPackageDocumentUseCase` | لا يوجد (تم اختباره في T072) | يمكن رفع ملفات PDF/JPG/PNG حجمها أقل من 20 ميجا. يتم الحفظ في قاعدة البيانات وإرسال إشعار للمريض. |
| **T074** | اختبارات `UpdatePackageServiceUsageUseCase` | اختبارات الوحدة: زيادة عدد الاستخدام، اكتمال العدد -> زيادة الخدمات المستخدمة، واختبار أمان المعاملات المتزامنة. | (لا يوجد - يخص الباك إند فقط) |
| **T075** | تنفيذ `UpdatePackageServiceUsageUseCase` | لا يوجد (تم اختباره في T074) | يتم تحديث الاستخدام بشكل آمن عند تسجيل الأدمن لخدمة محددة، مع منع فقدان البيانات في حال التحديث المتزامن. |
| **T076** | مزودات حالة الأدمن | اختبارات للمزودات: `adminPatientPackagesProvider` و `uploadDocumentProvider`. | (لا يوجد - يخص إدارة الحالة) |
| **T077** | دمج صفحة تفاصيل المريض للأدمن | تحقق يدوي / اختبار واجهة | ظهور قسم "باقات المريض" في صفحة تفاصيل المريض للأدمن. |
| **T078** | صفحة باقات مريض للأدمن | اختبار واجهة (T081) | ظهور قائمة باقات المريض (الاسم، الفئة، الحالة، التقدم، التواريخ) باللغة العربية، وحقل "الملاحظات" ظاهر وقابل للتعديل للأدمن. |
| **T079** | القائمة التفصيلية لباقة المريض | اختبار واجهة | عرض تفاصيل استخدام كل خدمة (مثال: 2/5)، قائمة المستندات، وزر "رفع مستند" العائم. ظهور تسميات "طبيب" / "أدمن". |
| **T080** | نافذة رفع المستندات | اختبار واجهة | نموذج لرفع المستند: نوع المستند (قائمة منسدلة)، العنوان (إلزامي)، الوصف، اختيار ملف (<= 20 ميجابايت). رسائل الخطأ والنجاح باللغة العربية. |
| **T081** | اختبارات واجهة أدمن الباقات | اختبارات الواجهة التي تغطي: حالة التحميل، الحالة الفارغة، القائمة، زر الرفع، وظهور حقل الملاحظات. | (لا يوجد - تحقق آلي من الواجهة) |

---

## 2. أوامر الاختبار الآلي

قم بتشغيل الأوامر التالية للتحقق الصارم من المرحلة السادسة:

**اختبارات الوحدة المخصصة للمرحلة السادسة:**
```bash
flutter test test/unit/features/packages/domain/get_patient_packages_for_admin_usecase_test.dart
flutter test test/unit/features/packages/domain/upload_package_document_usecase_test.dart
flutter test test/unit/features/packages/domain/update_package_service_usage_usecase_test.dart
```

**اختبارات الواجهة المخصصة للمرحلة السادسة:**
```bash
flutter test test/widget/features/packages/admin/admin_patient_packages_page_test.dart
```

**التحقق الشامل من النظام (لضمان عدم وجود تراجعات):**
```bash
flutter test
```

---

## 3. خطوات التأكيد المحددة

### أ. ظهور حقل الملاحظات `notes` (الشرط 2)
- **في اختبارات الوحدة**: التأكد من أن `fromFirestoreForAdmin()` يقوم بتحليل حقل `notes` للعودة به، بينما يتجاهله `fromFirestore()` (المستخدم لدى المرضى).
- **التحقق اليدوي**: 
  1. تسجيل الدخول كـ "مريض" والانتقال لتفاصيل الباقة -> التأكد من **عدم** ظهور حقل الملاحظات.
  2. تسجيل الدخول كـ "أدمن/طبيب" والانتقال لصفحة الباقات الخاصة بالمريض -> التأكد من **ظهور** حقل الملاحظات.

### ب. أمان المعاملات المتزامنة في تحديث الاستخدام (الشروط 3، 10)
- **التحقق البرمجي والاختباري**: التحقق من اجتياز اختبار T074(d). يجب أن يحاكي هذا الاختبار إجراء طلبين في نفس الوقت ويثبت أن `Transaction.update` يعمل بأمان.
- **التدقيق البرمجي**: في ملف `update_package_service_usage_usecase.dart`، يجب ألا يتم استدعاء التحديث المباشر `.update()`. كافة العمليات التي تقرأ أو تكتب نسب الاستخدام يجب أن تكون حصراً داخل `FirebaseFirestore.instance.runTransaction()`.

### ج. التحقق من الرفع وإرسال الإشعارات (الشرط 5)
- **التحقق من الرفع (QA)**: محاولة رفع ملف يتجاوز حجمه 20 ميجابايت عبر نافذة الرفع. توقع ظهور الخطأ: `حجم الملف يجب ألا يتجاوز 20 ميجابايت`. ومحاولة رفع ملف بصيغة غير مدعومة (مثل `.txt`) للتحقق من الرفض.
- **إرسال الإشعارات FCM**: قم برفع ملف بصيغة مدعومة (PDF)، ثم انتقل لحساب المريض وتأكد من تلقي الإشعار الخاص بالرفع. وفي حال فشل الإشعار (مُختبر نظرياً)، يجب أن يستمر الرفع بنجاح في قاعدة البيانات بلا تعطل.

---

## 4. معايير اجتياز المرحلة السادسة (الإنجاز التام)

- [ ] **كافة المهام مِن T070 حتى T081 مُكتملة (DONE).**
- [ ] نجاح جميع اختبارات الوحدة والواجهة المحددة لهذه المرحلة.
- [ ] يعطي أمر تحليل الكود `flutter analyze` نتيجة مثالية بصفر أخطاء، تحذيرات، أو ملاحظات.
- [ ] اكتمال أمر البناء `flutter pub run build_runner build --delete-conflicting-outputs` بنجاح دون أي تعارضات.
- [ ] تطابق سلوك النظام في التحقق اليدوي مع المواصفات المتوقعة باللغة العربية.
- [ ] تحقيق العزل التام لحقل الملاحظات، ليظهر للأدمن فقط ويبقى محجوباً عن المريض.
- [ ] ظهور سجلات أمان التحديثات (`debugPrint` اثناء وضع التطوير) في консоль كما تنص القواعد المركزية للمشروع.

</div>
