import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/services/background_service.dart';
import 'package:elajtech/core/services/cloud_functions_version_service.dart';
import 'package:elajtech/core/services/fcm_service.dart';
import 'package:elajtech/core/services/notification_service.dart';
import 'package:elajtech/core/services/encryption_service.dart';
import 'package:elajtech/core/services/connection_service.dart';
import 'package:elajtech/core/services/voip_call_service.dart';
import 'package:elajtech/core/services/permission_service.dart';
import 'package:elajtech/core/theme/light_theme.dart';
import 'package:elajtech/features/auth/presentation/screens/login_screen.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/shared/providers/appointments_provider.dart';
import 'package:elajtech/features/doctor/dashboard/presentation/screens/doctor_dashboard_screen.dart';
import 'package:elajtech/features/patient/navigation/presentation/screens/patient_main_screen.dart';
import 'package:elajtech/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:elajtech/firebase_options.dart';
import 'package:elajtech/shared/models/user_model.dart';
// import 'package:firebase_app_check/firebase_app_check.dart'; // Temporarily disabled
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// ============================================
// 🔑 مؤقت: استخراج SHA-256 Fingerprint لـ Zoom
// احذف هذا الكود بعد الحصول على المفتاح
// ============================================
Future<void> _printSHA256Fingerprint() async {
  if (!kDebugMode) return;
  if (defaultTargetPlatform != TargetPlatform.android) {
    debugPrint('⚠️ SHA-256 extraction only works on Android');
    return;
  }

  try {
    debugPrint(r'\n🔑 ===== SHA-256 FINGERPRINT EXTRACTION =====\n');

    // استخدام MethodChannel للحصول على الـ signature من Android
    const platform = MethodChannel('com.elajtech.androcare/signature');

    try {
      final sha256 =
          await platform.invokeMethod<String>('getSHA256') ??
          'ERROR: null response';
      debugPrint(
        '╔══════════════════════════════════════════════════════════════════╗',
      );
      debugPrint(
        '║                    SHA-256 FINGERPRINT                           ║',
      );
      debugPrint(
        '╠══════════════════════════════════════════════════════════════════╣',
      );
      debugPrint('║ $sha256');
      debugPrint(
        '╚══════════════════════════════════════════════════════════════════╝',
      );
      debugPrint(
        r'\n📋 Copy the above SHA-256 and paste it in Zoom Marketplace\n',
      );
    } on PlatformException catch (e) {
      debugPrint('❌ PlatformException: ${e.message}');
      debugPrint('💡 Fallback: Getting package signature info...');

      // Fallback: طباعة معلومات مساعدة
      debugPrint(r'\n📱 To get SHA-256 manually, run in PowerShell:');
      debugPrint(
        r'   keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android',
      );
    }

    debugPrint(r'\n🔑 ===== END SHA-256 EXTRACTION =====\n');
  } on Exception catch (e) {
    debugPrint('❌ Error extracting SHA-256: $e');
  }
}

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

    // اختبار قراءة بسيط
    final testQuery = await firestore
        .collection('test')
        .limit(1)
        .get(const GetOptions(source: Source.server))
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw Exception('انتهت مهلة الاتصال'),
        );

    debugPrint('✅ Firestore connection test PASSED');
    debugPrint('   📊 Database ID: elajtech');
    debugPrint('   📄 Query successful: ${testQuery.docs.length} document(s)');
    debugPrint('   🌐 Source: Server (live connection)');
  } on Exception catch (e) {
    debugPrint('⚠️ Firestore connection test WARNING: $e');
    // لا نوقف التطبيق، فقط تحذير
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('\n🚀 ===== Elajtech App Initialization Started =====\n');

  // 🔑 مؤقت: طباعة SHA-256 للـ Zoom Marketplace
  // احذف هذا السطر بعد الحصول على المفتاح
  await _printSHA256Fingerprint();

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

      // ✅ تفعيل Firebase App Check للحماية من الطلبات غير المصرح بها
      // في وضع Debug: نستخدم Debug Provider للسماح بالاختبار
      // في وضع Release: نستخدم Play Integrity للحماية الكاملة

      // ⚠️ TEMPORARILY DISABLED - App Check تم تعطيله مؤقتاً
      /*
      try {
        if (defaultTargetPlatform == TargetPlatform.android) {
          await FirebaseAppCheck.instance.activate(
            androidProvider: kDebugMode
                ? AndroidProvider.debug
                : AndroidProvider.playIntegrity,
          );

          if (kDebugMode) {
            debugPrint(
              '✅ Firebase App Check activated (DEBUG MODE - Android)',
            );

            // 🔑 طباعة الـ Debug Token بشكل صريح لتسجيله في Firebase Console
            try {
              final appCheckToken = await FirebaseAppCheck.instance.getToken(
                true,
              );
              print('');
              print(
                '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',
              );
              print(
                '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',
              );
              print('YOUR FIREBASE DEBUG TOKEN IS:');
              print('$appCheckToken');
              print(
                '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',
              );
              print(
                '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',
              );
              print('');
              print('📌 خطوات التسجيل:');
              print('   1. افتح Firebase Console -> App Check');
              print('   2. اختر التطبيق -> Manage debug tokens');
              print('   3. الصق التوكن أعلاه');
              print('');
            } on Exception catch (tokenError) {
              debugPrint('⚠️ Could not get App Check token: $tokenError');
            }

            // 🔑 نسخة احتياطية: طباعة التوكن بعد 3 ثوانٍ
            Future<void>.delayed(const Duration(seconds: 3), () async {
              try {
                final delayedToken = await FirebaseAppCheck.instance.getToken(
                  true,
                );
                print('');
                print('💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎');
                print('💎 SUCCESS! YOUR DEBUG TOKEN:');
                print('💎 $delayedToken');
                print('💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎💎');
                print('');
              } on Exception catch (e) {
                print('⚠️ Delayed Token Fetch Failed: $e');
              }
            });
          } else {
            debugPrint(
              '✅ Firebase App Check activated (Play Integrity - Android)',
            );
          }
        } else {
          debugPrint('ℹ️ App Check skipped - not on Android');
        }
      } on Exception catch (appCheckError) {
        debugPrint('⚠️ App Check activation warning: $appCheckError');
        // Continue even if App Check fails (for development)
      }
      */
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

    // 📞 إضافة FCM Handler للمكالمات الواردة
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📨 FCM Message received: ${message.data}');

      // التحقق من نوع الرسالة
      if (message.data['type'] == 'incoming_call') {
        debugPrint('📞 Incoming VoIP call detected');

        // استخراج البيانات مع type casting صحيح
        final doctorName = message.data['doctorName']?.toString() ?? 'طبيب';
        final appointmentId = message.data['appointmentId']?.toString() ?? '';
        final agoraToken = message.data['agoraToken']?.toString();
        final agoraChannelName = message.data['agoraChannelName']?.toString();
        final agoraUidStr = message.data['agoraUid']?.toString() ?? '0';
        final agoraUid = int.tryParse(agoraUidStr) ?? 0;

        // عرض شاشة المكالمة الواردة
        // Intentionally not awaited - FCM message handler runs in background
        unawaited(
          getIt<VoIPCallService>().showIncomingCall(
            callerName: doctorName,
            callerAvatar: '', // لا يوجد صورة في FCM data
            appointmentId: appointmentId,
            agoraToken: agoraToken,
            agoraChannelName: agoraChannelName,
            agoraUid: agoraUid,
          ),
        );
      }
    });
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
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper>
    with WidgetsBindingObserver {
  bool _isCheckingPendingCall = true;
  bool _hasPendingCall = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_checkPendingCall());

    // 🛡️ التحقق من أذونات المكالمات عند تشغيل التطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(PermissionsService.checkAndRequestPermissions(context));
    });
  }

  @override
  void dispose() {
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
    final appointmentId = await getIt<VoIPCallService>().cleanupAfterCall();

    if (appointmentId != null && appointmentId.isNotEmpty && mounted) {
      final user = ref.read(authProvider).user;
      if (user == null) return;

      if (user.userType == UserType.doctor) {
        // 🛑 للطبيب: طلب تأكيد إنهاء الجلسة
        await _showDoctorSessionEndDialog(appointmentId);
      } else {
        // ✅ للمريض: إنهاء الموعد تلقائياً
        await ref
            .read(appointmentsProvider.notifier)
            .completeAppointment(appointmentId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنهاء المكالمة وتسجيل الموعد كمكتمل'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    }
  }

  /// نافذة تأكيد انتهاء الجلسة للطبيب
  Future<void> _showDoctorSessionEndDialog(String appointmentId) async {
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

              // حفظ messenger قبل async gap
              final messenger = ScaffoldMessenger.of(context);

              // تحديث الحالة إلى مكتمل
              await ref
                  .read(appointmentsProvider.notifier)
                  .completeAppointment(appointmentId);

              // حفظ messenger قبل async gap
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('تم تسجيل الجلسة كمكتملة'),
                    backgroundColor: AppColors.success,
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
      final pendingCallData = getIt<VoIPCallService>().pendingCallData;

      if (pendingCallData != null && pendingCallData.agoraChannelName != null) {
        debugPrint(
          '📞 Found pending call, will navigate to Agora screen after auth check',
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
    final pendingCallData = getIt<VoIPCallService>().pendingCallData;
    if (pendingCallData?.agoraChannelName == null) return;

    try {
      debugPrint('🎥 Navigating to Agora call screen');
      debugPrint('   Channel: ${pendingCallData!.agoraChannelName}');
      debugPrint('   Appointment: ${pendingCallData.appointmentId}');

      // TODO: Navigate to AgoraVideoCallScreen when it's created
      // For now, just log that we would navigate
      debugPrint('⚠️ Navigation to Agora screen not yet implemented');
    } on Exception catch (e) {
      debugPrint('❌ Error navigating to Agora call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // مراقبة حالة المصادقة
    final authState = ref.watch(authProvider);

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
      return const LoginScreen();
    }

    // 4. حالة سباق: مسجل ولكن بيانات المستخدم لم تحمل بعد → شاشة التحميل
    if (authState.user == null) {
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
    final userType = authState.user!.userType;
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

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services,
            size: 80,
            color: AppColors.primary,
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 16),
          Text(
            'جاري التحميل...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    ),
  );
}
