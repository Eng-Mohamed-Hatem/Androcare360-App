import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/services/background_service.dart';
import 'package:elajtech/core/services/cloud_functions_version_service.dart';
import 'package:elajtech/core/services/call_monitoring_service.dart';
import 'package:elajtech/core/services/fcm_service.dart';
import 'package:elajtech/core/services/notification_service.dart';
import 'package:elajtech/core/services/encryption_service.dart';
import 'package:elajtech/core/services/connection_service.dart';
import 'package:elajtech/core/services/appointment_completion_service.dart';
import 'package:elajtech/core/services/video_consultation_service.dart';
import 'package:elajtech/core/services/voip_call_service.dart';
import 'package:elajtech/core/services/permission_service.dart';
import 'package:elajtech/core/theme/light_theme.dart';
import 'package:elajtech/features/auth/presentation/screens/login_screen.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/doctor/dashboard/presentation/screens/doctor_dashboard_screen.dart';
import 'package:elajtech/features/patient/navigation/presentation/screens/patient_main_screen.dart';
import 'package:elajtech/features/patient/consultation/presentation/screens/agora_video_call_screen.dart';
import 'package:elajtech/features/patient/consultation/presentation/screens/incoming_call_screen.dart';
import 'package:elajtech/features/patient/consultation/presentation/providers/consultation_call_providers.dart';
import 'package:elajtech/features/patient/navigation/presentation/helpers/patient_navigation_helper.dart';
import 'package:elajtech/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:elajtech/firebase_options.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

/// Check if running on a platform that supports Firebase
bool _isFirebaseSupported() {
  if (kIsWeb) return true;

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      return true;
    case TargetPlatform.macOS:
      return true;
    case TargetPlatform.linux:
      return true;
    case TargetPlatform.fuchsia:
      return true;
    case TargetPlatform.windows:
      return true;
  }
}

/// اختبار اتصال Firestore في بيئة التطوير
Future<void> _testFirestoreConnection() async {
  if (!kDebugMode) return;

  try {
    debugPrint('\n🔍 بدء اختبار اتصال Firestore...');
    final firestore = getIt<FirebaseFirestore>();

    debugPrint('✅ Firestore connection test PASSED');
    debugPrint('   📊 Database ID: elajtech');
    debugPrint('   🧩 Instance hash: ${firestore.hashCode}');
    debugPrint('   🌐 Injected instance resolved successfully');
  } on Exception catch (e) {
    debugPrint('⚠️ Firestore connection test WARNING: $e');
    // لا نوقف التطبيق، فقط تحذير
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  debugPrint('\n🚀 ===== Elajtech App Initialization Started =====\n');

  // Initialize Firebase only on supported platforms (Android, iOS, Web)
  if (_isFirebaseSupported()) {
    try {
      debugPrint('🔧 Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // التحقق من أن Firebase App جاهز
      final app = Firebase.app();
      debugPrint('✅ Firebase initialized successfully');
      debugPrint('   📱 App Name: ${app.name}');
      debugPrint('   🆔 Project ID: ${app.options.projectId}');
      debugPrint('   🌍 Platform: $defaultTargetPlatform');

      debugPrint('ℹ️ App Check is DISABLED (temporarily)');
    } on Exception catch (e, stackTrace) {
      debugPrint('❌ Firebase initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      _firebaseError = e.toString();
      runApp(const ProviderScope(child: FirebaseErrorApp()));
      return;
    }
  } else {
    debugPrint('⚠️ Running on unsupported platform - Firebase disabled');
    debugPrint('For testing, please use Android emulator or physical device');
  }

  // Initialize Dependency Injection (بعد نجاح تهيئة Firebase)
  try {
    debugPrint('\n🔌 Configuring Dependency Injection...');
    await configureDependencies();
    debugPrint('✅ Dependencies configured successfully');

    // التحقق من FirebaseFirestore بعد الحقن
    try {
      getIt<FirebaseFirestore>();
      debugPrint('✅ FirebaseFirestore instance retrieved from DI');
      debugPrint('   🗄️  Database ID: elajtech (custom database)');
    } on Exception catch (e) {
      debugPrint('⚠️ Warning: Could not retrieve FirebaseFirestore: $e');
    }

    // اختبار الاتصال بقاعدة البيانات
    await _testFirestoreConnection();
  } on Exception catch (e, stackTrace) {
    debugPrint('❌ Failed to configure dependencies: $e');
    debugPrint('Stack trace: $stackTrace');
    _firebaseError = 'Dependency Injection Error:\n$e';
    runApp(const ProviderScope(child: FirebaseErrorApp()));
    return;
  }

  // Verify Cloud Functions version and database configuration
  try {
    debugPrint('\n☁️ Verifying Cloud Functions version...');
    final versionService = getIt<CloudFunctionsVersionService>();
    await versionService.verifyCloudFunctionsVersion();
  } on Exception catch (e) {
    debugPrint('⚠️ Warning: Could not verify Cloud Functions version: $e');
    // Continue app initialization even if verification fails
  }

  // Initialize Encryption Service
  debugPrint('\n🔐 Initializing Services...');
  try {
    await EncryptionService.instance.initialize();
    debugPrint('✅ Encryption Service initialized');
  } on Exception catch (e) {
    debugPrint('❌ Failed to initialize Encryption Service: $e');
  }

  // Initialize Connection Service
  try {
    await ConnectionService.initialize();
    debugPrint('✅ Connection Service initialized');
  } on Exception catch (e) {
    debugPrint('❌ Failed to initialize Connection Service: $e');
  }

  // Initialize Notification Service
  try {
    await NotificationService().init();
    debugPrint('✅ Notification Service initialized');
  } on Exception catch (e) {
    debugPrint('❌ Failed to initialize Notification Service: $e');
  }

  // Initialize FCM Service
  try {
    // ✅ Use dependency injection to get FCMService
    final fcmService = getIt<FCMService>();
    await fcmService.initialize();
    debugPrint('✅ FCM Service initialized');
  } on Exception catch (e) {
    debugPrint('❌ Failed to initialize FCM Service: $e');
  }

  // ملاحظة: نستخدم Agora RTC Engine للمكالمات المرئية داخل التطبيق
  // التحكم يتم عبر AgoraService و AgoraVideoCallScreen
  debugPrint(
    'ℹ️ Agora integration: Using Agora RTC Engine for in-app video calls',
  );

  // Initialize VoIP Call Service (لمكالمات الفيديو الواردة)
  try {
    await getIt<VoIPCallService>().initialize();
    debugPrint('✅ VoIP Call Service initialized');
  } on Exception catch (e) {
    debugPrint('❌ Failed to initialize VoIP Call Service: $e');
  }

  // Initialize Background Service (Mobile only)
  if (!kIsWeb) {
    try {
      await BackgroundService.init();
      debugPrint('✅ Background Service initialized');
    } on Exception catch (e) {
      debugPrint('❌ Failed to initialize Background Service: $e');
    }
  }

  debugPrint('\n✅ All services initialized successfully');
  debugPrint('\n🚀 ===== Elajtech App Initialization Completed =====\n');

  runApp(const ProviderScope(child: MyApp()));
}

/// Storez error message for display
late String? _firebaseError;

/// Error app when Firebase fails to initialize
class FirebaseErrorApp extends StatelessWidget {
  const FirebaseErrorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: AppStrings.appName,
    theme: LightTheme.theme,
    themeMode: ThemeMode.light,
    locale: const Locale('ar', 'SA'),
    supportedLocales: const [
      Locale('ar', 'SA'), // Arabic
      Locale('en', 'US'), // English
    ],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'خطأ في تهيئة Firebase',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_firebaseError != null && _firebaseError!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _firebaseError!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.left,
                      textDirection: TextDirection.ltr,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Main App Widget
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: AppStrings.appName,
    theme: LightTheme.theme,
    themeMode: ThemeMode.light,
    locale: const Locale('ar', 'SA'),
    supportedLocales: const [
      Locale('ar', 'SA'), // Arabic
      Locale('en', 'US'), // English
    ],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const AuthWrapper(),
    navigatorKey: getIt<GlobalKey<NavigatorState>>(),
  );
}

/// AuthWrapper - مغلف المصادقة
/// يتحقق من حالة المستخدم قبل عرض الواجهة
/// ويتعامل مع المكالمات المعلقة عند فتح التطبيق من الإشعار
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key, this.completeAppointment});

  final Future<CompletionResult> Function({
    required String appointmentId,
    required String doctorId,
  })?
  completeAppointment;

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper>
    with WidgetsBindingObserver {
  bool _isCheckingPendingCall = true;
  bool _hasPendingCall = false;
  StreamSubscription<VoIPCallEvent>? _callEventSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_checkPendingCall());

    // Subscribe to warm-start call acceptance events.
    // When the user accepts from the native CallKit/ConnectionService screen
    // while the app is backgrounded, _joinPendingCall() handles navigation.
    _callEventSubscription = getIt<VoIPCallService>().callEventStream.listen(
      _onVoIPCallEvent,
    );

    // 🛡️ التحقق من أذونات المكالمات عند تشغيل التطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(PermissionsService.checkAndRequestPermissions(context));
    });
  }

  void _onVoIPCallEvent(VoIPCallEvent event) {
    if (event.type == VoIPCallEventType.accepted &&
        mounted &&
        !_hasPendingCall) {
      unawaited(_handleCallAccepted());
    }
  }

  /// Syncs the Riverpod provider state before navigating.
  ///
  /// `showIncomingCall()` only updates `VoIPCallService._pendingCallData` directly.
  /// The `consultationCallControllerProvider` is NOT notified, so its state is
  /// stale (null) on warm-start paths. Refreshing here ensures `_joinPendingCall`
  /// sees the correct data when the user accepts from the native ring screen.
  Future<void> _handleCallAccepted() async {
    await ref
        .read(consultationCallControllerProvider.notifier)
        .refreshPendingCall();
    if (mounted) unawaited(_joinPendingCall());
  }

  @override
  void dispose() {
    unawaited(_callEventSubscription?.cancel());
    _callEventSubscription = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_checkAndCleanupCalls());
    }
  }

  /// فحص وتنظيف المكالمات عند العودة للتطبيق
  Future<void> _checkAndCleanupCalls() async {
    // 1. تنظيف المكالمات والإشعارات
    final appointmentId = await ref
        .read(consultationCallControllerProvider.notifier)
        .cleanupOnResume();

    // Reset deduplication so a doctor retry to the same appointment is not dropped
    getIt<FCMService>().resetCallDeduplication();

    if (appointmentId != null && appointmentId.isNotEmpty && mounted) {
      final user = ref.read(authProvider).user;
      if (user == null) return;

      if (user.userType == UserType.doctor) {
        // 🛑 للطبيب: طلب تأكيد إنهاء الجلسة
        await _showDoctorSessionEndDialog(appointmentId);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم إنهاء المكالمة. يبقى الموعد بانتظار تحديث الطبيب.',
              ),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    }
  }

  /// نافذة تأكيد انتهاء الجلسة للطبيب
  Future<void> _showDoctorSessionEndDialog(String appointmentId) async {
    final messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('انتهاء الجلسة الطبية'),
        content: const Text(
          'هل اكتملت الجلسة الطبية مع المريض؟\n\n'
          '• نعم: سيتم تحديث حالة الموعد إلى "مكتمل".\n'
          '• لا: سيتم إبقاء الموعد نشطاً (يمكنك العودة للمكالمة لاحقاً).',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق النافذة
              // لا نفعل شيئاً (تم مسح الإشعار فقط)
            },
            child: const Text('لا، لم تكتمل'),
          ),
          TextButton(
            onPressed: () async {
              // إغلاق النافذة أولاً
              Navigator.of(context).pop();

              final user = ref.read(authProvider).user;
              if (user == null) {
                return;
              }

              final completionAction =
                  widget.completeAppointment ??
                  AppointmentCompletionService().completeAppointment;
              final result = await completionAction(
                appointmentId: appointmentId,
                doctorId: user.id,
              );

              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      result.success
                          ? (result.message ?? 'تم تسجيل الجلسة كمكتملة')
                          : (result.error ?? 'تعذر إكمال الموعد'),
                    ),
                    backgroundColor: result.success
                        ? AppColors.success
                        : AppColors.error,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('نعم، اكتملت'),
          ),
        ],
      ),
    );
  }

  /// فحص المكالمات المعلقة عند بدء التطبيق
  Future<void> _checkPendingCall() async {
    try {
      // فحص إذا كان التطبيق فُتح من الرد على مكالمة
      await ref
          .read(consultationCallControllerProvider.notifier)
          .refreshPendingCall();
      final pendingCallData = ref
          .read(consultationCallControllerProvider)
          .pendingCallData;

      if (pendingCallData != null && pendingCallData.agoraChannelName != null) {
        debugPrint(
          '📞 [AuthWrapper] pending call restored'
          ' | appointmentId=${pendingCallData.appointmentId}'
          ' | channelName=${pendingCallData.agoraChannelName}'
          ' | hasToken=${pendingCallData.agoraToken != null}'
          ' | hasUid=${pendingCallData.agoraUid != null}',
        );
        _hasPendingCall = true;
      }
    } on Exception catch (e) {
      debugPrint('❌ Error checking pending call: $e');
    }

    if (mounted) {
      setState(() => _isCheckingPendingCall = false);
    }
  }

  /// الانضمام للمكالمة المعلقة (Agora)
  Future<void> _joinPendingCall() async {
    final pendingCallData = ref
        .read(consultationCallControllerProvider)
        .pendingCallData;
    if (pendingCallData == null) {
      debugPrint(
        '⚠️ [AuthWrapper] _joinPendingCall aborted: no pendingCallData',
      );
      return;
    }

    debugPrint(
      '📞 [AuthWrapper] _joinPendingCall:start'
      ' | appointmentId=${pendingCallData.appointmentId}'
      ' | channelName=${pendingCallData.agoraChannelName}'
      ' | hasToken=${pendingCallData.agoraToken != null}'
      ' | hasUid=${pendingCallData.agoraUid != null}',
    );

    // agoraToken is intentionally not checked here: on cold start the token is
    // null (removed from CallKit extra for security). The patientJoinCall()
    // fallback below fetches a fresh token from the server.
    if (pendingCallData.agoraChannelName == null ||
        pendingCallData.agoraUid == null ||
        pendingCallData.appointmentId.isEmpty) {
      debugPrint(
        '⚠️ [AuthWrapper] _joinPendingCall aborted: pending call data incomplete'
        ' | appointmentId=${pendingCallData.appointmentId}'
        ' | channelName=${pendingCallData.agoraChannelName}'
        ' | token=${pendingCallData.agoraToken != null}'
        ' | uid=${pendingCallData.agoraUid != null}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر استعادة المكالمة الواردة. حاول انتظار إعادة الاتصال.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    try {
      ref.read(consultationCallControllerProvider.notifier).markJoinStarted();
      debugPrint('🎥 Navigating to Agora call screen');
      debugPrint('   Channel: ${pendingCallData.agoraChannelName}');
      debugPrint('   Appointment: ${pendingCallData.appointmentId}');

      var restoredToken = pendingCallData.agoraToken;
      var restoredChannelName = pendingCallData.agoraChannelName;
      var restoredUid = pendingCallData.agoraUid;
      var hasFreshJoinAuthorization = false;
      final hasActiveNativeCall = await getIt<VoIPCallService>()
          .hasActiveCalls();
      final hasAcceptedFromCallKit = pendingCallData.acceptedFromCallKit;

      final currentUser = ref.read(authProvider).user;
      debugPrint(
        '📞 [AuthWrapper] _joinPendingCall user snapshot'
        ' | userId=${currentUser?.id}'
        ' | userType=${currentUser?.userType.name}',
      );

      if (currentUser?.userType == UserType.patient) {
        try {
          debugPrint(
            '📞 [AuthWrapper] _joinPendingCall -> notifyPatientAnswered:start'
            ' | appointmentId=${pendingCallData.appointmentId}',
          );
          await VideoConsultationService().notifyPatientAnswered(
            appointmentId: pendingCallData.appointmentId,
          );
          debugPrint(
            '✅ [AuthWrapper] _joinPendingCall -> notifyPatientAnswered:success'
            ' | appointmentId=${pendingCallData.appointmentId}',
          );

          debugPrint(
            '📞 [AuthWrapper] _joinPendingCall -> patientJoinCall:start'
            ' | appointmentId=${pendingCallData.appointmentId}'
            ' | patientId=${currentUser?.id}',
          );
          final patientId = currentUser?.id;
          if (patientId != null && patientId.isNotEmpty) {
            final refreshedJoinData = await VideoConsultationService()
                .patientJoinCall(
                  appointmentId: pendingCallData.appointmentId,
                  patientId: patientId,
                );
            restoredToken = refreshedJoinData.agoraToken;
            restoredChannelName = refreshedJoinData.channelName;
            restoredUid = refreshedJoinData.uid;
            hasFreshJoinAuthorization = true;
            debugPrint(
              '✅ [AuthWrapper] _joinPendingCall -> patientJoinCall:success'
              ' | appointmentId=${pendingCallData.appointmentId}'
              ' | channelName=$restoredChannelName'
              ' | uid=$restoredUid',
            );
          }
        } on Exception catch (e) {
          debugPrint(
            '⚠️ [AuthWrapper] _joinPendingCall -> patientJoinCall failed, using pending payload'
            ' | appointmentId=${pendingCallData.appointmentId}'
            ' | error=$e',
          );
        }
      }

      final appointmentSnapshot = await getIt<FirebaseFirestore>()
          .collection('appointments')
          .doc(pendingCallData.appointmentId)
          .get();

      if (!appointmentSnapshot.exists || appointmentSnapshot.data() == null) {
        throw StateError('Appointment not found for pending call');
      }

      final appointmentData = <String, dynamic>{
        ...appointmentSnapshot.data()!,
        'id': appointmentSnapshot.id,
      };

      final appointment = AppointmentModel.fromJson(appointmentData).copyWith(
        status: hasFreshJoinAuthorization ? AppointmentStatus.inProgress : null,
        agoraToken: restoredToken,
        agoraChannelName: restoredChannelName,
        agoraUid: restoredUid,
      );

      debugPrint(
        '📞 [AuthWrapper] _joinPendingCall appointment snapshot'
        ' | appointmentStatus=${appointment.status.name}'
        ' | hasFreshJoinAuthorization=$hasFreshJoinAuthorization'
        ' | hasAcceptedFromCallKit=$hasAcceptedFromCallKit'
        ' | hasActiveNativeCall=$hasActiveNativeCall'
        ' | channelName=${appointment.agoraChannelName}'
        ' | uid=${appointment.agoraUid}',
      );

      if (currentUser?.userType == UserType.patient &&
          !shouldRestoreIncomingCall(
            appointment.status,
            hasFreshJoinAuthorization: hasFreshJoinAuthorization,
            hasAcceptedFromCallKit: hasAcceptedFromCallKit,
            hasActiveNativeCall: hasActiveNativeCall,
          )) {
        debugPrint(
          '⚠️ [AuthWrapper] _joinPendingCall navigation blocked by shouldRestoreIncomingCall'
          ' | appointmentStatus=${appointment.status.name}'
          ' | hasFreshJoinAuthorization=$hasFreshJoinAuthorization',
        );
        if (!mounted) {
          return;
        }

        await PatientNavigationHelper.openAppointments(context);
        return;
      }

      await getIt<CallMonitoringService>().logStructuredEvent(
        appointmentId: pendingCallData.appointmentId,
        userId: currentUser?.id ?? 'system',
        eventType: 'active_call_restored',
        metadata: {
          'restoreSource': 'pending_call_payload',
          'channelName': restoredChannelName,
        },
      );

      if (!mounted) {
        return;
      }

      debugPrint(
        '🚀 [AuthWrapper] _joinPendingCall -> AgoraVideoCallScreen'
        ' | appointmentId=${appointment.id}'
        ' | channelName=${appointment.agoraChannelName}'
        ' | uid=${appointment.agoraUid}',
      );

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => AgoraVideoCallScreen(
            appointment: appointment,
            firebaseAuth: getIt<FirebaseAuth>(),
          ),
        ),
      );
    } on Exception catch (e) {
      debugPrint('❌ [AuthWrapper] _joinPendingCall failed: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The call has ended.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // مراقبة حالة المصادقة
    final authState = ref.watch(authProvider);

    debugPrint(
      '🧭 [AuthWrapper] auth snapshot'
      ' | isLoading=${authState.isLoading}'
      ' | isAuthenticated=${authState.isAuthenticated}'
      ' | hasUser=${authState.user != null}'
      ' | userType=${authState.user?.userType.name}'
      ' | isActive=${authState.user?.isActive}',
    );

    // 1. انتظار فحص المكالمة المعلقة
    if (_isCheckingPendingCall) {
      return const _SplashScreen();
    }

    // 2. انتظار تحميل حالة المصادقة
    if (authState.isLoading) {
      return const _SplashScreen();
    }

    // 3. المستخدم غير مسجل → شاشة تسجيل الدخول
    if (!authState.isAuthenticated) {
      debugPrint('🧭 [AuthWrapper] navigation decision -> LoginScreen');
      return const LoginScreen();
    }

    // 4. حالة سباق: مسجل ولكن بيانات المستخدم لم تحمل بعد → شاشة التحميل
    if (authState.user == null) {
      debugPrint(
        '🚫 [AuthWrapper] patient redirect blocked reason=authenticated-without-user',
      );
      return const _SplashScreen();
    }

    // 4. المستخدم مسجل + مكالمة معلقة → انضم للمكالمة
    if (_hasPendingCall) {
      // تنفيذ بعد البناء لتجنب setState أثناء build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_joinPendingCall());
        setState(() => _hasPendingCall = false);
      });
    }

    // 5. توجيه المستخدم بناءً على نوع حسابه
    final user = authState.user;
    if (user == null) {
      return const _SplashScreen();
    }

    final userType = user.userType;
    debugPrint('🧭 [AuthWrapper] navigation decision -> ${userType.name}');
    return switch (userType) {
      UserType.admin => ref.watch(adminDashboardProvider),
      UserType.doctor => ref.watch(doctorDashboardProvider),
      UserType.patient => ref.watch(patientDashboardProvider),
    };
  }
}

/// Providers for dashboard screens to allow mocking in tests
final adminDashboardProvider = Provider<Widget>(
  (ref) => const AdminDashboardScreen(),
);
final doctorDashboardProvider = Provider<Widget>(
  (ref) => const DoctorDashboardScreen(),
);
final patientDashboardProvider = Provider<Widget>(
  (ref) => const PatientMainScreen(),
);

/// شاشة التحميل (Splash)
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  static const _splashImage =
      'assets/images/Medical Online Doctor Consultation Instagram Story.jpg';

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(_splashImage, fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.06),
                Colors.white.withValues(alpha: 0.14),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              const Spacer(),
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'جاري التحميل...',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    ),
  );
}
