import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/specialty_constants.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

/// Permissions Service - خدمة الصلاحيات والأذونات
///
/// Manages two types of permissions in the elajtech application:
/// 1. **Business Logic Permissions**: Role-based access control for EMR tabs and
///    appointment editing based on doctor specialization and appointment timing
/// 2. **System Permissions**: Android runtime permissions for notifications, overlays,
///    and alarms required for VoIP call functionality
///
/// تدير نوعين من الصلاحيات في تطبيق elajtech:
/// 1. **صلاحيات منطق الأعمال**: التحكم في الوصول بناءً على الدور للوصول إلى
///    علامات تبويب EMR وتحرير المواعيد بناءً على تخصص الطبيب وتوقيت الموعد
/// 2. **أذونات النظام**: أذونات وقت التشغيل لنظام Android للإشعارات والتراكبات
///    والمنبهات المطلوبة لوظيفة مكالمات VoIP
///
/// **Key Features:**
/// - Specialty-based EMR tab visibility control (Andrology, Internal Medicine, Nutrition, Physiotherapy)
/// - Investigation tabs visibility based on doctor specialty
/// - Time-based appointment editing permissions (same day, after appointment time)
/// - Android runtime permissions management (notifications, overlay, exact alarms)
/// - User-friendly permission request dialogs with Arabic explanations
///
/// **Business Rules:**
/// - EMR tabs are specialty-specific and only visible to authorized doctors
/// - Investigation tabs hidden for Nutrition and Physiotherapy doctors
/// - Doctors can only edit appointments on the same day after the appointment time
/// - All permission checks include debug logging for troubleshooting
///
/// **Dependency Injection:**
/// This service uses static methods and does not require dependency injection.
/// All methods can be called directly via `PermissionsService.methodName()`.
///
/// Example usage:
/// ```dart
/// // Check if doctor can view Nutrition EMR
/// final doctor = ref.watch(authProvider).user;
/// if (PermissionsService.canViewNutritionEMR(doctor)) {
///   // Show Nutrition EMR tab
/// }
///
/// // Check if doctor can edit appointment record
/// if (PermissionsService.canEditRecord(appointment, doctor.id)) {
///   // Enable edit button
/// }
///
/// // Request Android permissions for VoIP
/// await PermissionsService.checkAndRequestPermissions(context);
/// ```
class PermissionsService {
  /// Check if doctor can view Andrology EMR tab - التحقق من صلاحية عرض علامة تبويب EMR للذكورة
  ///
  /// Determines if the doctor has permission to view the Andrology EMR tab based
  /// on their specialization. Only doctors with Andrology-related specializations
  /// (Male Surgery, Infertility, Prostate Diseases) can access this tab.
  ///
  /// يحدد ما إذا كان الطبيب لديه صلاحية لعرض علامة تبويب EMR للذكورة بناءً على
  /// تخصصه. فقط الأطباء ذوو التخصصات المتعلقة بالذكورة (جراحة الذكورة، العقم،
  /// أمراض البروستاتا) يمكنهم الوصول إلى هذه العلامة.
  ///
  /// **Allowed Specializations:**
  /// - Male Surgery (Andrology) - جراحة الذكورة
  /// - Infertility - العقم
  /// - Prostate Diseases - أمراض البروستاتا
  ///
  /// Parameters:
  /// - [doctor]: The doctor user model to check (nullable)
  ///   نموذج مستخدم الطبيب للتحقق منه (قابل للقيمة الفارغة)
  ///
  /// Returns: `true` if doctor can view Andrology EMR, `false` otherwise
  ///   يُرجع `true` إذا كان الطبيب يمكنه عرض EMR للذكورة، `false` خلاف ذلك
  ///
  /// **Debug Logging:** Logs permission check results in debug mode
  ///
  /// Example:
  /// ```dart
  /// final doctor = ref.watch(authProvider).user;
  /// if (PermissionsService.canViewEMR(doctor)) {
  ///   // Show Andrology EMR tab in UI
  ///   tabs.add(Tab(text: 'Andrology EMR'));
  /// }
  /// ```
  static bool canViewEMR(UserModel? doctor) {
    if (doctor == null || doctor.userType != UserType.doctor) {
      if (kDebugMode) {
        debugPrint(
          '❌ [EMR Permission] Doctor is null or not a doctor type',
        );
      }
      return false;
    }
    if (doctor.specializations == null || doctor.specializations!.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '❌ [EMR Permission] Doctor has no specializations - ID: ${doctor.id}',
        );
      }
      return false;
    }

    if (kDebugMode) {
      debugPrint('🔍 [EMR Permission] Checking doctor specializations:');
      for (final spec in doctor.specializations!) {
        debugPrint('   - "$spec"');
      }
    }

    // Use SpecialtyConstants for accurate detection
    final isAndrology = SpecialtyConstants.isAndrologyDoctor(
      doctor.specializations,
    );

    if (kDebugMode) {
      debugPrint(
        '✅ [EMR Permission] Andrology doctor? $isAndrology',
      );
    }

    return isAndrology;
  }

  /// Check if doctor can view Internal Medicine EMR tab - التحقق من صلاحية عرض علامة تبويب EMR للطب الباطني
  ///
  /// Determines if the doctor has permission to view the Internal Medicine EMR tab
  /// based on their specialization. Only doctors with Internal Medicine or Family
  /// Medicine specializations can access this tab.
  ///
  /// يحدد ما إذا كان الطبيب لديه صلاحية لعرض علامة تبويب EMR للطب الباطني بناءً
  /// على تخصصه. فقط الأطباء ذوو تخصصات الطب الباطني أو طب الأسرة يمكنهم الوصول
  /// إلى هذه العلامة.
  ///
  /// **Allowed Specializations:**
  /// - Internal Medicine - الطب الباطني
  /// - Family Medicine - طب الأسرة
  ///
  /// Parameters:
  /// - [doctor]: The doctor user model to check (nullable)
  ///   نموذج مستخدم الطبيب للتحقق منه (قابل للقيمة الفارغة)
  ///
  /// Returns: `true` if doctor can view Internal Medicine EMR, `false` otherwise
  ///   يُرجع `true` إذا كان الطبيب يمكنه عرض EMR للطب الباطني، `false` خلاف ذلك
  ///
  /// **Debug Logging:** Logs permission check results in debug mode
  ///
  /// Example:
  /// ```dart
  /// if (PermissionsService.canViewInternalMedicineEMR(doctor)) {
  ///   tabs.add(Tab(text: 'Internal Medicine EMR'));
  /// }
  /// ```
  static bool canViewInternalMedicineEMR(UserModel? doctor) {
    if (doctor == null || doctor.userType != UserType.doctor) {
      if (kDebugMode) {
        debugPrint(
          '❌ [Internal Medicine Permission] Doctor is null or not a doctor type',
        );
      }
      return false;
    }
    if (doctor.specializations == null || doctor.specializations!.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '❌ [Internal Medicine Permission] Doctor has no specializations - ID: ${doctor.id}',
        );
      }
      return false;
    }

    if (kDebugMode) {
      debugPrint(
        '🔍 [Internal Medicine Permission] Checking doctor specializations:',
      );
      for (final spec in doctor.specializations!) {
        debugPrint('   - "$spec"');
      }
    }

    // Use SpecialtyConstants for accurate detection
    final isInternalMedicine = SpecialtyConstants.isInternalMedicineDoctor(
      doctor.specializations,
    );

    if (kDebugMode) {
      debugPrint(
        '✅ [Internal Medicine Permission] Internal Medicine doctor? $isInternalMedicine',
      );
    }

    return isInternalMedicine;
  }

  /// Check if doctor can view Nutrition EMR tab - التحقق من صلاحية عرض علامة تبويب EMR للتغذية
  ///
  /// Determines if the doctor has permission to view the Nutrition EMR tab based
  /// on their specialization. Only doctors with Nutrition & Obesity Therapy
  /// specialization can access this tab.
  ///
  /// يحدد ما إذا كان الطبيب لديه صلاحية لعرض علامة تبويب EMR للتغذية بناءً على
  /// تخصصه. فقط الأطباء ذوو تخصص التغذية وعلاج السمنة يمكنهم الوصول إلى هذه العلامة.
  ///
  /// **Allowed Specializations:**
  /// - Nutrition & Obesity Therapy - التغذية وعلاج السمنة
  ///
  /// Parameters:
  /// - [doctor]: The doctor user model to check (nullable)
  ///   نموذج مستخدم الطبيب للتحقق منه (قابل للقيمة الفارغة)
  ///
  /// Returns: `true` if doctor can view Nutrition EMR, `false` otherwise
  ///   يُرجع `true` إذا كان الطبيب يمكنه عرض EMR للتغذية، `false` خلاف ذلك
  ///
  /// **Debug Logging:** Logs permission check results in debug mode
  ///
  /// Example:
  /// ```dart
  /// if (PermissionsService.canViewNutritionEMR(doctor)) {
  ///   tabs.add(Tab(text: 'Nutrition EMR'));
  /// }
  /// ```
  static bool canViewNutritionEMR(UserModel? doctor) {
    if (doctor == null || doctor.userType != UserType.doctor) {
      if (kDebugMode) {
        debugPrint(
          '❌ [Nutrition Permission] Doctor is null or not a doctor type',
        );
      }
      return false;
    }
    if (doctor.specializations == null || doctor.specializations!.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '❌ [Nutrition Permission] Doctor has no specializations - ID: ${doctor.id}',
        );
      }
      return false;
    }

    if (kDebugMode) {
      debugPrint('🔍 [Nutrition Permission] Checking doctor specializations:');
      for (final spec in doctor.specializations!) {
        debugPrint('   - "$spec"');
      }
    }

    // Use SpecialtyConstants for accurate detection
    final isNutrition = SpecialtyConstants.isNutritionDoctor(
      doctor.specializations,
    );

    if (kDebugMode) {
      debugPrint(
        '✅ [Nutrition Permission] Nutrition doctor? $isNutrition',
      );
    }

    return isNutrition;
  }

  /// Check if doctor can view Physiotherapy EMR tab - التحقق من صلاحية عرض علامة تبويب EMR للعلاج الطبيعي
  ///
  /// Determines if the doctor has permission to view the Physiotherapy EMR tab
  /// based on their specialization. Only doctors with Physiotherapy & Rehabilitation
  /// specialization can access this tab.
  ///
  /// يحدد ما إذا كان الطبيب لديه صلاحية لعرض علامة تبويب EMR للعلاج الطبيعي بناءً
  /// على تخصصه. فقط الأطباء ذوو تخصص العلاج الطبيعي والتأهيل يمكنهم الوصول إلى
  /// هذه العلامة.
  ///
  /// **Allowed Specializations:**
  /// - Physiotherapy & Rehabilitation - العلاج الطبيعي والتأهيل
  ///
  /// Parameters:
  /// - [doctor]: The doctor user model to check (nullable)
  ///   نموذج مستخدم الطبيب للتحقق منه (قابل للقيمة الفارغة)
  ///
  /// Returns: `true` if doctor can view Physiotherapy EMR, `false` otherwise
  ///   يُرجع `true` إذا كان الطبيب يمكنه عرض EMR للعلاج الطبيعي، `false` خلاف ذلك
  ///
  /// **Debug Logging:** Logs permission check results in debug mode
  ///
  /// Example:
  /// ```dart
  /// if (PermissionsService.canViewPhysiotherapyEMR(doctor)) {
  ///   tabs.add(Tab(text: 'Physiotherapy EMR'));
  /// }
  /// ```
  static bool canViewPhysiotherapyEMR(UserModel? doctor) {
    if (doctor == null || doctor.userType != UserType.doctor) {
      if (kDebugMode) {
        debugPrint(
          '❌ [Physiotherapy Permission] Doctor is null or not a doctor type',
        );
      }
      return false;
    }
    if (doctor.specializations == null || doctor.specializations!.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '❌ [Physiotherapy Permission] Doctor has no specializations - ID: ${doctor.id}',
        );
      }
      return false;
    }

    if (kDebugMode) {
      debugPrint(
        '🔍 [Physiotherapy Permission] Checking doctor specializations:',
      );
      for (final spec in doctor.specializations!) {
        debugPrint('   - "$spec"');
      }
    }

    // Use SpecialtyConstants for accurate detection
    final isPhysiotherapy = SpecialtyConstants.isPhysiotherapyDoctor(
      doctor.specializations,
    );

    if (kDebugMode) {
      debugPrint(
        '✅ [Physiotherapy Permission] Physiotherapy doctor? $isPhysiotherapy',
      );
    }

    return isPhysiotherapy;
  }

  /// Check if Investigation tabs should be shown for doctor - التحقق من عرض علامات تبويب الفحوصات
  ///
  /// Determines whether Investigation tabs (Lab, Radiology, Device) should be
  /// displayed based on the doctor's specialization. These tabs are hidden for
  /// Nutrition and Physiotherapy doctors as they typically don't order lab tests
  /// or imaging studies.
  ///
  /// يحدد ما إذا كان يجب عرض علامات تبويب الفحوصات (المختبر، الأشعة، الأجهزة)
  /// بناءً على تخصص الطبيب. يتم إخفاء هذه العلامات لأطباء التغذية والعلاج الطبيعي
  /// حيث أنهم عادة لا يطلبون فحوصات مخبرية أو دراسات تصويرية.
  ///
  /// **Investigation tabs HIDDEN for:**
  /// - Nutrition doctors - أطباء التغذية
  /// - Physiotherapy doctors - أطباء العلاج الطبيعي
  ///
  /// **Investigation tabs SHOWN for:**
  /// - Andrology doctors - أطباء الذكورة
  /// - Internal Medicine doctors - أطباء الباطنية
  /// - All other specialties - جميع التخصصات الأخرى
  ///
  /// Parameters:
  /// - [doctor]: The doctor user model to check (nullable)
  ///   نموذج مستخدم الطبيب للتحقق منه (قابل للقيمة الفارغة)
  ///
  /// Returns: `true` if Investigation tabs should be shown, `false` to hide them
  ///   يُرجع `true` إذا كان يجب عرض علامات تبويب الفحوصات، `false` لإخفائها
  ///
  /// **Default Behavior:** Returns `true` if doctor has no specializations (show by default)
  ///
  /// **Debug Logging:** Logs visibility decision in debug mode
  ///
  /// Example:
  /// ```dart
  /// if (PermissionsService.shouldShowInvestigationTabs(doctor)) {
  ///   tabs.addAll([
  ///     Tab(text: 'Lab Tests'),
  ///     Tab(text: 'Radiology'),
  ///     Tab(text: 'Device Tests'),
  ///   ]);
  /// }
  /// ```
  static bool shouldShowInvestigationTabs(UserModel? doctor) {
    if (doctor == null || doctor.userType != UserType.doctor) {
      if (kDebugMode) {
        debugPrint(
          '❌ [Investigation Visibility] Doctor is null or not a doctor type',
        );
      }
      return false;
    }

    if (doctor.specializations == null || doctor.specializations!.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [Investigation Visibility] Doctor has no specializations - showing tabs by default',
        );
      }
      // Default: show investigation tabs if specialty is unknown
      return true;
    }

    if (kDebugMode) {
      debugPrint(
        '🔍 [Investigation Visibility] Checking if investigation tabs should be shown:',
      );
    }

    // Check if doctor is Nutrition or Physiotherapy
    final isNutrition = SpecialtyConstants.isNutritionDoctor(
      doctor.specializations,
    );
    final isPhysiotherapy = SpecialtyConstants.isPhysiotherapyDoctor(
      doctor.specializations,
    );

    // Hide investigation tabs for Nutrition and Physiotherapy doctors
    final shouldHide = isNutrition || isPhysiotherapy;
    final shouldShow = !shouldHide;

    if (kDebugMode) {
      debugPrint('   - Is Nutrition doctor? $isNutrition');
      debugPrint('   - Is Physiotherapy doctor? $isPhysiotherapy');
      debugPrint('   - Should SHOW Investigation tabs? $shouldShow');
    }

    return shouldShow;
  }

  /// Check if doctor can edit/add records for an appointment - التحقق من صلاحية تحرير السجلات
  ///
  /// Determines if a doctor has permission to edit or add medical records for a
  /// specific appointment based on three strict business rules:
  ///
  /// يحدد ما إذا كان الطبيب لديه صلاحية لتحرير أو إضافة سجلات طبية لموعد محدد
  /// بناءً على ثلاثة قواعد عمل صارمة:
  ///
  /// **Business Rules:**
  /// 1. **Doctor Assignment**: Must be the assigned doctor for the appointment
  ///    يجب أن يكون الطبيب المعين للموعد
  /// 2. **Same Day**: Current date must match the appointment date
  ///    يجب أن يكون التاريخ الحالي مطابقاً لتاريخ الموعد
  /// 3. **After Start Time**: Current time must be after the appointment start time
  ///    يجب أن يكون الوقت الحالي بعد وقت بدء الموعد
  ///
  /// **Rationale:**
  /// - Prevents editing appointments before they occur
  /// - Prevents editing past appointments (different day)
  /// - Ensures only the assigned doctor can modify records
  ///
  /// Parameters:
  /// - [appointment]: The appointment to check edit permissions for (required)
  ///   الموعد للتحقق من صلاحيات التحرير له (مطلوب)
  /// - [doctorId]: The ID of the doctor attempting to edit (required)
  ///   معرف الطبيب الذي يحاول التحرير (مطلوب)
  ///
  /// Returns: `true` if all three conditions are met, `false` otherwise
  ///   يُرجع `true` إذا تم استيفاء جميع الشروط الثلاثة، `false` خلاف ذلك
  ///
  /// **Debug Logging:** Logs detailed permission check results including timestamps
  ///
  /// Example:
  /// ```dart
  /// final appointment = await appointmentRepo.getAppointment(appointmentId);
  /// final doctor = ref.watch(authProvider).user;
  ///
  /// if (PermissionsService.canEditRecord(appointment, doctor.id)) {
  ///   // Enable "Add EMR" button
  ///   showAddEMRButton = true;
  /// } else {
  ///   // Show read-only view
  ///   showAddEMRButton = false;
  /// }
  /// ```
  static bool canEditRecord(AppointmentModel appointment, String doctorId) {
    if (kDebugMode) {
      debugPrint('🔍 [Edit Permission] Checking edit permissions:');
      debugPrint('   - Appointment Doctor ID: ${appointment.doctorId}');
      debugPrint('   - Current Doctor ID: $doctorId');
    }

    // 1. Must be the doctor of the appointment
    if (appointment.doctorId != doctorId) {
      if (kDebugMode) {
        debugPrint('❌ [Edit Permission] Not the assigned doctor');
      }
      return false;
    }

    final now = DateTime.now();
    final appointmentTime = appointment.fullDateTime;

    if (kDebugMode) {
      debugPrint('   - Current Time: $now');
      debugPrint('   - Appointment Time: $appointmentTime');
    }

    // 2. Must be the same day
    final isSameDay =
        now.year == appointmentTime.year &&
        now.month == appointmentTime.month &&
        now.day == appointmentTime.day;

    if (!isSameDay) {
      if (kDebugMode) {
        debugPrint('❌ [Edit Permission] Not the same day');
      }
      return false;
    }

    // 3. Must be AFTER the appointment time
    if (now.isBefore(appointmentTime)) {
      if (kDebugMode) {
        debugPrint('❌ [Edit Permission] Appointment has not started yet');
      }
      return false;
    }

    if (kDebugMode) {
      debugPrint('✅ [Edit Permission] All conditions met - can edit');
    }

    return true;
  }

  /// Check and request all necessary permissions for VoIP calls - التحقق من أذونات مكالمات VoIP وطلبها
  ///
  /// Checks the status of all Android runtime permissions required for VoIP call
  /// functionality and displays a user-friendly dialog if any permissions are missing.
  /// This method is Android-specific and does nothing on iOS.
  ///
  /// يتحقق من حالة جميع أذونات وقت التشغيل لنظام Android المطلوبة لوظيفة مكالمات
  /// VoIP ويعرض مربع حوار سهل الاستخدام إذا كانت أي أذونات مفقودة. هذه الطريقة
  /// خاصة بنظام Android ولا تفعل شيئاً على iOS.
  ///
  /// **Required Permissions (Android):**
  /// 1. **Notifications** (Android 13+): For displaying incoming call notifications
  ///    الإشعارات: لعرض إشعارات المكالمات الواردة
  /// 2. **System Alert Window**: For displaying call UI over other apps and when locked
  ///    الظهور فوق التطبيقات: لعرض واجهة المكالمة فوق التطبيقات الأخرى وعند القفل
  /// 3. **Schedule Exact Alarm** (Android 12+): For precise appointment reminders
  ///    المنبهات الدقيقة: لتذكيرات المواعيد الدقيقة
  ///
  /// **User Experience:**
  /// - If permissions are missing, shows an Arabic dialog explaining why each permission is needed
  /// - User can choose to grant permissions immediately or defer to later
  /// - Dialog is non-dismissible to ensure user makes a conscious choice
  ///
  /// Parameters:
  /// - [context]: BuildContext for showing the permission dialog (required)
  ///   سياق البناء لعرض مربع حوار الأذونات (مطلوب)
  ///
  /// **Platform Support:**
  /// - Android: Checks and requests all three permissions
  /// - iOS: No-op (iOS handles permissions differently via Info.plist)
  ///
  /// **Important:** Should be called during app initialization or before initiating
  /// the first VoIP call to ensure all permissions are granted.
  ///
  /// Example:
  /// ```dart
  /// // In main app initialization
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   WidgetsBinding.instance.addPostFrameCallback((_) {
  ///     PermissionsService.checkAndRequestPermissions(context);
  ///   });
  /// }
  ///
  /// // Or before initiating a call
  /// Future<void> initiateCall() async {
  ///   await PermissionsService.checkAndRequestPermissions(context);
  ///   // Proceed with call setup
  /// }
  /// ```
  static Future<void> checkAndRequestPermissions(BuildContext context) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    // Check notification permission (Android 13+)
    final notificationStatus = await Permission.notification.status;

    // Check SYSTEM_ALERT_WINDOW (Display over other apps)
    final overlayStatus = await Permission.systemAlertWindow.status;

    // Check SCHEDULE_EXACT_ALARM (Android 12+)
    final alarmStatus = await Permission.scheduleExactAlarm.status;

    final needsPermissions =
        notificationStatus.isDenied ||
        overlayStatus.isDenied ||
        alarmStatus.isDenied;

    if (needsPermissions && context.mounted) {
      await _showPermissionDialog(context);
    }
  }

  /// Show a dialog explaining why permissions are needed - عرض مربع حوار يشرح سبب الحاجة للأذونات
  ///
  /// Displays a user-friendly Arabic dialog that explains each required permission
  /// and its purpose. The dialog includes:
  /// - Clear title and introduction
  /// - List of three permissions with icons and explanations
  /// - "Later" button to dismiss
  /// - "Grant Permissions" button to proceed with permission requests
  ///
  /// يعرض مربع حوار باللغة العربية سهل الاستخدام يشرح كل إذن مطلوب والغرض منه.
  ///
  /// **Dialog Content:**
  /// - Notifications permission explanation
  /// - Display over other apps permission explanation
  /// - Exact alarms permission explanation
  ///
  /// Parameters:
  /// - [context]: BuildContext for showing the dialog (required)
  ///   سياق البناء لعرض مربع الحوار (مطلوب)
  ///
  /// **User Actions:**
  /// - "لاحقاً" (Later): Dismisses dialog without requesting permissions
  /// - "منح الأذونات" (Grant Permissions): Calls `_requestAllPermissions()` and dismisses
  ///
  /// **UI Design:**
  /// - Non-dismissible (barrierDismissible: false) to ensure user acknowledgment
  /// - Primary color button for grant action
  /// - Icons for visual clarity
  ///
  /// Returns: Future that completes when dialog is dismissed
  static Future<void> _showPermissionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'أذونات مطلوبة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لضمان استقبال مكالمات الأطباء وتنبيهات المواعيد في وقتها، يحتاج التطبيق للأذونات التالية:',
            ),
            SizedBox(height: 16),
            _PermissionItem(
              icon: Icons.notifications_active,
              title: 'الإشعارات',
              subtitle: 'لإرسال تنبيهات المكالمات والمواعيد',
            ),
            _PermissionItem(
              icon: Icons.layers,
              title: 'الظهور فوق التطبيقات',
              subtitle: 'لإظهار واجهة المكالمة حتى لو كان الهاتف مقفلاً',
            ),
            _PermissionItem(
              icon: Icons.alarm,
              title: 'المنبهات الدقيقة',
              subtitle: 'لضمان وصول التنبيه في الوقت المحدد تماماً',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _requestAllPermissions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('منح الأذونات'),
          ),
        ],
      ),
    );
  }

  /// Request all required Android permissions - طلب جميع أذونات Android المطلوبة
  ///
  /// Sequentially requests all Android runtime permissions required for VoIP
  /// functionality. This method handles the actual permission request flow after
  /// the user confirms via the permission dialog.
  ///
  /// يطلب بشكل تسلسلي جميع أذونات وقت التشغيل لنظام Android المطلوبة لوظيفة VoIP.
  /// تتعامل هذه الطريقة مع تدفق طلب الإذن الفعلي بعد تأكيد المستخدم عبر مربع حوار الأذونات.
  ///
  /// **Permissions Requested (in order):**
  /// 1. **Notification Permission**: Standard notification permission (Android 13+)
  ///    إذن الإشعارات: إذن الإشعارات القياسي
  /// 2. **Schedule Exact Alarm**: For precise scheduled notifications (Android 12+)
  ///    جدولة المنبهات الدقيقة: للإشعارات المجدولة الدقيقة
  /// 3. **System Alert Window**: For displaying call UI over other apps
  ///    نافذة تنبيه النظام: لعرض واجهة المكالمة فوق التطبيقات الأخرى
  /// 4. **Flutter CallKit Permission**: Full screen intent for incoming calls
  ///    إذن Flutter CallKit: نية ملء الشاشة للمكالمات الواردة
  ///
  /// **Behavior:**
  /// - Each permission is checked before requesting to avoid unnecessary prompts
  /// - System Alert Window typically opens system settings automatically
  /// - Flutter CallKit handles its own permission flow for full screen intents
  /// - All exceptions are caught and logged to prevent app crashes
  ///
  /// **Debug Logging:**
  /// - Logs success message when all permissions are requested
  /// - Logs error message if any permission request fails
  ///
  /// **Note:** Some permissions (like System Alert Window) may require the user to
  /// manually enable them in system settings. The app should handle cases where
  /// permissions are not granted.
  ///
  /// Throws: Does not throw - all exceptions are caught and logged
  static Future<void> _requestAllPermissions() async {
    try {
      // 1. Notification Permission (Standard)
      await Permission.notification.request();

      // 2. Schedule Exact Alarm (Android 12+)
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }

      // 3. System Alert Window (Overlay)
      // Note: This usually opens system settings automatically
      if (await Permission.systemAlertWindow.isDenied) {
        await Permission.systemAlertWindow.request();
      }

      // 4. Flutter CallKit's own permission request (specifically for full screen intent)
      await FlutterCallkitIncoming.requestNotificationPermission(null);

      debugPrint('✅ Permissions request completed');
    } on Exception catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
    }
  }
}

/// Permission Item Widget - عنصر واجهة عنصر الإذن
///
/// A reusable widget that displays a single permission item in the permission
/// dialog. Shows an icon, title, and subtitle explaining the permission's purpose.
///
/// عنصر واجهة قابل لإعادة الاستخدام يعرض عنصر إذن واحد في مربع حوار الأذونات.
/// يعرض أيقونة وعنوان وعنوان فرعي يشرح الغرض من الإذن.
///
/// **Visual Structure:**
/// ```text
/// [Icon] Title
///        Subtitle (gray text)
/// ```
///
/// Used internally by `_showPermissionDialog()` to display each of the three
/// required permissions in a consistent format.
///
/// Parameters:
/// - [icon]: The icon to display (e.g., Icons.notifications_active)
/// - [title]: The permission name in Arabic (e.g., "الإشعارات")
/// - [subtitle]: Brief explanation of why the permission is needed
class _PermissionItem extends StatelessWidget {
  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
