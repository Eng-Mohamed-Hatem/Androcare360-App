# Implementation Plan: Appointments Tabs UI & Lifecycle Observer

## Goal
1.  **Appointments UI**: Redesign the `AppointmentsManagementScreen` to use a TabBar with "Upcoming" and "Past" tabs.
2.  **Lifecycle Observer**: Implement a lifecycle observer to detect when the user returns from Zoom, clear call notifications, and mark the appointment as completed.

## User Review Required
> [!NOTE]
> The lifecycle observer assumes that returning to the app *during* or *after* a call implies the call is finished (since Zoom is external). This logic will force-complete the appointment if an appointment ID is tracked as "active".

## Proposed Changes

### Appointments UI
#### [MODIFY] [patient_profile_screen.dart](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/features/patient_profile_screen.dart)
-   Refactor `AppointmentsManagementScreen` to use `DefaultTabController`.
-   Add `TabBar` with two tabs: "مواعيد قادمة" (Upcoming) and "مواعيد سابقة" (Past).
-   Implement filtering logic:
    -   **Upcoming**: Status `pending` or `confirmed`.
    -   **Past**: Status `completed` or `cancelled`.
-   Update `_AppointmentCard` or create a new listing widget to handle the specific visuals for past appointments.

### Lifecycle Observer
#### [MODIFY] [voip_call_service.dart](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/core/services/voip_call_service.dart)
-   Add `cleanupAfterCall()` method to:
    -   Call `FlutterCallkitIncoming.endAllCalls()`.
    -   Return the `appointmentId` of the pending/active call to be completed.
    -   Clear local call state.

#### [MODIFY] [main.dart](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/main.dart)
-   In `_AuthWrapperState`:
    -   Add `WidgetsBindingObserver` mixin.
    -   Implement `didChangeAppLifecycleState`.
    -   On `AppLifecycleState.resumed`:
        -   Call `VoIPCallService().cleanupAfterCall()`.
        -   If an appointment ID is returned, use `ref.read(appointmentsProvider.notifier).completeAppointment(id)` to update Firestore.

## Verification Plan

### Automated Tests
-   Not applicable for this UI/Service interaction task.

### Manual Verification
1.  **Tabs UI**:
    -   Open Patient Profile -> Appointments.
    -   Verify two tabs exist.
    -   Verify "Upcoming" shows only pending/confirmed appointments.
    -   Verify "Past" shows only completed/cancelled appointments.
    -   Verify icons/colors for past appointments.

2.  **Lifecycle Observer**:
    -   Start a video call.
    -   Accept call.
    -   Return to the app.
    -   Verify "Hung up" notification is cleared.
    -   Verify appointment status updates to 'completed' in Firestore and UI.

## Translation
بعد انشاء خطة العمل Implementation Plan يتم اضافه اللغه العربية بالاسفل وان يكون اتجاه النص من اليمين الي اليسار

# خطة التنفيذ: واجهة تبويبات المواعيد ومراقب دورة حياة التطبيق

## الهدف
1.  **واجهة المواعيد**: إعادة تصميم شاشة إدارة المواعيد `AppointmentsManagementScreen` لاستخدام نظام التبويبات (TabBar) مع تبويبين: "مواعيد قادمة" و "مواعيد سابقة".
2.  **مراقب دورة الحياة**: تنفيذ مراقب لدورة حياة التطبيق لاكتشاف عودة المستخدم من تطبيق Zoom، مسح إشعارات المكالمات، وتحديد الموعد على أنه "مكتمل".

## مراجعة المستخدم مطلوبة
> [!NOTE]
> يفترض مراقب دورة الحياة أن العودة إلى التطبيق *أثناء* أو *بعد* المكالمة يعني أن المكالمة قد انتهت (نظرًا لأن Zoom تطبيق خارجي). هذا المنطق سيقوم بإنهاء الموعد "بقوة" إذا كان معرف الموعد لا يزال مسجلاً كـ "نشط".

## التغييرات المقترحة

### واجهة المواعيد
#### [تعديل] [patient_profile_screen.dart](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/features/patient_profile_screen.dart)
-   إعادة هيكلة `AppointmentsManagementScreen` لاستخدام `DefaultTabController`.
-   إضافة `TabBar` مع تبويبين: "مواعيد قادمة" و "مواعيد سابقة".
-   تنفيذ منطق الفرز:
    -   **قادمة**: الحالة `pending` (قيد الانتظار) أو `confirmed` (مؤكد).
    -   **سابقة**: الحالة `completed` (مكتمل) أو `cancelled` (ملغي).
-   تحديث `_AppointmentCard` أو إنشاء ويدجت عرض جديد للتعامل مع المرئيات الخاصة بالمواعيد السابقة.

### مراقب دورة الحياة
#### [تعديل] [voip_call_service.dart](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/core/services/voip_call_service.dart)
-   إضافة دالة `cleanupAfterCall()` لـ:
    -   استدعاء `FlutterCallkitIncoming.endAllCalls()`.
    -   إرجاع `appointmentId` للمكالمة المعلقة/النشطة ليتم إكمالها.
    -   مسح حالة المكالمة المحلية.

#### [تعديل] [main.dart](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/lib/main.dart)
-   في `_AuthWrapperState`:
    -   إضافة `WidgetsBindingObserver` mixin.
    -   تنفيذ `didChangeAppLifecycleState`.
    -   عند `AppLifecycleState.resumed`:
        -   استدعاء `VoIPCallService().cleanupAfterCall()`.
        -   إذا تم إرجاع معرف موعد، استخدم `ref.read(appointmentsProvider.notifier).completeAppointment(id)` لتحديث Firestore.

## خطة التحقق

### الاختبارات المؤتمتة
-   غير قابل للتطبيق لهذه المهمة التفاعلية بين واجهة المستخدم والخدمة.

### التحقق اليدوي
1.  **واجهة التبويبات**:
    -   افتح الملف الشخصي للمريض -> المواعيد.
    -   تحقق من وجود علامتي تبويب.
    -   تحقق من أن "مواعيد قادمة" تعرض فقط المواعيد المعلقة/المؤكدة.
    -   تحقق من أن "مواعيد سابقة" تعرض فقط المواعيد المكتملة/الملغاة.
    -   تحقق من الأيقونات/الألوان للمواعيد السابقة.

2.  **مراقب دورة الحياة**:
    -   ابدأ مكالمة فيديو.
    -   وافق على المكالمة.
    -   عد إلى التطبيق.
    -   تحقق من مسح إشعار "Hung up".
    -   تحقق من تحديث حالة الموعد إلى "مكتمل" في Firestore والواجهة.
