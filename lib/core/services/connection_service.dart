/// Connection Service - خدمة إدارة الاتصال
///
/// توفر هذه الخدمة مراقبة حالة الاتصال بالإنترنت،
/// وتنبيهات عند تغيير حالة الاتصال.
library;

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// خدمة إدارة الاتصال
///
/// تراقب هذه الخدمة حالة الاتصال بالإنترنت،
/// وتنبه التطبيق عند تغيير حالة الاتصال.
class ConnectionService {
  factory ConnectionService() => _instance;

  ConnectionService._internal();

  static final ConnectionService _instance = ConnectionService._internal();

  static ConnectionService get instance => _instance;

  static final _connectivity = Connectivity();
  static final _connectionController = StreamController<bool>.broadcast();

  /// تيار حالة الاتصال
  ///
  /// يُرسل true عند وجود اتصال، false عند عدم وجوده
  static Stream<bool> get onConnectionChange => _connectionController.stream;

  /// حالة الاتصال الحالية
  static bool _isConnected = true;
  static bool get isConnected => _isConnected;

  /// نوع الاتصال الحالي
  static ConnectivityResult? _currentConnectivity;
  static ConnectivityResult? get currentConnectivity => _currentConnectivity;

  /// تيار تفصيلي لتغييرات الاتصال
  static final _connectivityController =
      StreamController<ConnectivityResult>.broadcast();
  static Stream<ConnectivityResult> get onConnectivityChange =>
      _connectivityController.stream;

  /// تهيئة خدمة الاتصال
  ///
  /// يجب استدعاء هذه الدالة مرة واحدة عند بدء التطبيق
  /// في main.dart قبل أي عمليات تعتمد على الاتصال.
  static Future<void> initialize() async {
    // التحقق من الاتصال الأولي
    final result = await _connectivity.checkConnectivity();
    _currentConnectivity = result;
    _isConnected = result != ConnectivityResult.none;
    _connectionController.add(_isConnected);

    print(
      '🔌 Connection status: ${_isConnected ? "Connected" : "Disconnected"}',
    );
    print('📡 Connection type: ${_currentConnectivity?.name ?? "Unknown"}');

    // الاستماع لتغييرات الاتصال
    _connectivity.onConnectivityChanged.listen((result) {
      _currentConnectivity = result;
      final wasConnected = _isConnected;
      _isConnected = result != ConnectivityResult.none;

      print(
        '🔌 Connection changed: ${_isConnected ? "Connected" : "Disconnected"}',
      );
      print('📡 Connection type: ${result.name}');

      // إرسال التغيير فقط إذا تغيرت الحالة
      if (wasConnected != _isConnected) {
        _connectionController.add(_isConnected);
      }

      _connectivityController.add(result);
    });
  }

  /// التحقق من وجود اتصال بالإنترنت
  ///
  /// يُرجع true إذا كان هناك اتصال، false خلا ذلك
  static Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } on Exception catch (e) {
      print('❌ Error checking connection: $e');
      return false;
    }
  }

  /// إعادة التحقق من الاتصال
  ///
  /// [retries] عدد مرات إعادة المحاولة (افتراضي: 3)
  /// [delay] التأخير بين المحاولات بالمللي ثانية (افتراضي: 1000)
  ///
  /// يُحاول إعادة التحقق من الاتصال عدة مرات
  static Future<bool> retryCheckConnection({
    int retries = 3,
    int delay = 1000,
  }) async {
    for (var i = 0; i < retries; i++) {
      final isConnected = await checkConnection();
      if (isConnected) return true;

      print('⏳ Retry ${i + 1}/$retries: No connection');

      if (i < retries - 1) {
        await Future<void>.delayed(Duration(milliseconds: delay));
      }
    }

    return false;
  }

  /// إغلاق خدمة الاتصال
  ///
  /// يجب استدعاء هذه الدالة عند إغلاق التطبيق
  static void dispose() {
    // Intentionally not awaited - cleanup happens in background
    unawaited(_connectionController.close());
    unawaited(_connectivityController.close());
  }

  /// الحصول على اسم نوع الاتصال
  ///
  /// يُرجع اسم وصفي لنوع الاتصال الحالي
  static String getConnectionTypeName() {
    if (_currentConnectivity == null) return 'غير معروف';

    switch (_currentConnectivity!) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'شبكة الهاتف';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'أخرى';
      case ConnectivityResult.none:
        return 'غير متصل';
    }
  }

  /// التحقق من وجود اتصال سريع
  ///
  /// يُرجع الحالة الحالية دون انتظار
  static bool get isQuickConnected => _isConnected;

  /// التحقق من اتصال Wi-Fi
  ///
  /// يُرجع true إذا كان الاتصال عبر Wi-Fi
  static bool get isWifiConnected =>
      _currentConnectivity == ConnectivityResult.wifi;

  /// التحقق من اتصال شبكة الهاتف
  ///
  /// يُرجع true إذا كان الاتصال عبر شبكة الهاتف
  static bool get isMobileConnected =>
      _currentConnectivity == ConnectivityResult.mobile;
}
