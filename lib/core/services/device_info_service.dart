import 'dart:io';
import 'dart:ui' as ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:elajtech/core/models/device_info_model.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Device Info Service - Device Information Collection
///
/// Collects comprehensive device and application information for debugging,
/// analytics, and call monitoring purposes.
///
/// **Key Features:**
/// - Device hardware information (model, manufacturer, OS version)
/// - Application version and build number
/// - Network connectivity type detection
/// - Screen resolution information
/// - Information caching to avoid repeated reads
///
/// **Platform Support:**
/// - Android: Full device info including manufacturer and Android version
/// - iOS: Device model, iOS version, and Apple manufacturer
///
/// **Caching Strategy:**
/// - Device info is cached after first read
/// - Connection type is refreshed on each call (as it may change)
/// - Cache can be manually cleared if needed
///
/// **Dependency Injection:**
/// This service uses the Singleton pattern for global access.
///
/// Example usage:
/// ```dart
/// // Get complete device information
/// final deviceInfo = await DeviceInfoService().getDeviceInfo();
/// print('Device: ${deviceInfo.deviceModel}');
/// print('OS: ${deviceInfo.osVersion}');
/// print('App Version: ${deviceInfo.appVersion}');
///
/// // Get specific information
/// final model = await DeviceInfoService().getDeviceModel();
/// final connection = await DeviceInfoService().getConnectionType();
/// ```
class DeviceInfoService {
  /// Singleton pattern
  factory DeviceInfoService() => _instance;
  DeviceInfoService._internal();
  static final DeviceInfoService _instance = DeviceInfoService._internal();

  /// Device info plugin
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Connectivity plugin
  final Connectivity _connectivity = Connectivity();

  /// Cached device info
  DeviceInfoModel? _cachedDeviceInfo;

  /// Cached package info
  PackageInfo? _cachedPackageInfo;

  /// Get comprehensive device information
  ///
  /// Collects all device and application information including:
  /// - Platform (Android/iOS)
  /// - Device model and manufacturer
  /// - OS version
  /// - App version and build number
  /// - Network connection type
  /// - Screen resolution
  ///
  /// The result is cached after first read. Connection type is refreshed
  /// on each call as it may change.
  ///
  /// Returns: [DeviceInfoModel] with all device information
  ///
  /// Example:
  /// ```dart
  /// final info = await DeviceInfoService().getDeviceInfo();
  /// print('Running on ${info.deviceModel} with ${info.osVersion}');
  /// print('Connection: ${info.connectionType}');
  /// ```
  Future<DeviceInfoModel> getDeviceInfo() async {
    try {
      // إذا كانت المعلومات محفوظة مسبقاً، نعيدها مباشرة
      if (_cachedDeviceInfo != null) {
        // نحدث فقط نوع الاتصال لأنه قد يتغير
        final connectionType = await _getConnectionType();
        return _cachedDeviceInfo!.copyWith(connectionType: connectionType);
      }

      debugPrint('📱 جمع معلومات الجهاز...');

      // الحصول على معلومات التطبيق
      final packageInfo = await _getPackageInfo();

      String platform;
      String deviceModel;
      String manufacturer;
      String osVersion;
      String screenResolution;

      // جمع المعلومات حسب المنصة
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        platform = 'android';
        deviceModel = androidInfo.model;
        manufacturer = androidInfo.manufacturer;
        osVersion = 'Android ${androidInfo.version.release}';

        // دقة الشاشة - استخدام Flutter's Platform Dispatcher
        try {
          final view = ui.PlatformDispatcher.instance.views.first;
          final physicalSize = view.physicalSize;
          screenResolution =
              '${physicalSize.width.toInt()}x${physicalSize.height.toInt()}';
        } on Exception catch (e) {
          // في حالة فشل الحصول على دقة الشاشة
          debugPrint('⚠️ Failed to get screen resolution: $e');
          screenResolution = 'Android Device';
        }
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        platform = 'ios';
        deviceModel = iosInfo.utsname.machine;
        manufacturer = 'Apple';
        osVersion = 'iOS ${iosInfo.systemVersion}';

        // دقة الشاشة - نستخدم القيم الافتراضية لـ iOS
        screenResolution = 'iOS Device'; // يمكن تحسينها لاحقاً
      } else {
        // منصة غير مدعومة
        platform = 'unknown';
        deviceModel = 'Unknown';
        manufacturer = 'Unknown';
        osVersion = 'Unknown';
        screenResolution = 'Unknown';
      }

      // الحصول على نوع الاتصال
      final connectionType = await _getConnectionType();

      // إنشاء النموذج
      _cachedDeviceInfo = DeviceInfoModel(
        platform: platform,
        deviceModel: deviceModel,
        manufacturer: manufacturer,
        osVersion: osVersion,
        appVersion: packageInfo.version,
        appBuildNumber: packageInfo.buildNumber,
        connectionType: connectionType,
        screenResolution: screenResolution,
      );

      debugPrint('✅ تم جمع معلومات الجهاز: $_cachedDeviceInfo');

      return _cachedDeviceInfo!;
    } on Exception catch (e) {
      debugPrint('❌ خطأ في جمع معلومات الجهاز: $e');

      // في حالة الخطأ، نعيد معلومات افتراضية
      return DeviceInfoModel(
        platform: Platform.isAndroid ? 'android' : 'ios',
        deviceModel: 'Unknown',
        manufacturer: 'Unknown',
        osVersion: 'Unknown',
        appVersion: '0.0.0',
        appBuildNumber: '0',
        connectionType: 'unknown',
        screenResolution: 'Unknown',
      );
    }
  }

  /// Get package information
  ///
  /// Internal method to retrieve app version and build number.
  /// Result is cached after first read.
  ///
  /// Returns: [PackageInfo] with app version details
  Future<PackageInfo> _getPackageInfo() async {
    if (_cachedPackageInfo != null) {
      return _cachedPackageInfo!;
    }

    _cachedPackageInfo = await PackageInfo.fromPlatform();
    return _cachedPackageInfo!;
  }

  /// Get current connection type
  ///
  /// Detects the current network connection type.
  ///
  /// Returns one of: 'wifi', 'mobile', 'ethernet', 'none', 'unknown'
  ///
  /// This method handles both single and multiple connectivity results
  /// from the connectivity_plus package.
  Future<String> _getConnectionType() async {
    try {
      // جلب النتيجة من المكتبة
      final dynamic result = await _connectivity.checkConnectivity();

      // تحويل النتيجة دائماً إلى قائمة لضمان عمل contains
      List<ConnectivityResult> results;
      if (result is List<ConnectivityResult>) {
        results = result;
      } else if (result is ConnectivityResult) {
        results = [result];
      } else {
        return 'unknown';
      }

      // الآن سيعمل contains بدون أي أخطاء
      if (results.contains(ConnectivityResult.wifi)) {
        return 'wifi';
      } else if (results.contains(ConnectivityResult.mobile)) {
        return 'mobile';
      } else if (results.contains(ConnectivityResult.ethernet)) {
        return 'ethernet';
      } else if (results.contains(ConnectivityResult.none)) {
        return 'none';
      } else {
        return 'unknown';
      }
    } on Exception catch (e) {
      debugPrint('❌ خطأ في تحديد نوع الاتصال: $e');
      return 'unknown';
    }
  }

  /// Get device model only
  ///
  /// Convenience method to get just the device model.
  ///
  /// Returns: Device model string (e.g., 'SM-G991B', 'iPhone14,2')
  ///
  /// Example:
  /// ```dart
  /// final model = await DeviceInfoService().getDeviceModel();
  /// ```
  Future<String> getDeviceModel() async {
    final deviceInfo = await getDeviceInfo();
    return deviceInfo.deviceModel;
  }

  /// Get OS version only
  ///
  /// Convenience method to get just the operating system version.
  ///
  /// Returns: OS version string (e.g., 'Android 13', 'iOS 16.5')
  ///
  /// Example:
  /// ```dart
  /// final osVersion = await DeviceInfoService().getOSVersion();
  /// ```
  Future<String> getOSVersion() async {
    final deviceInfo = await getDeviceInfo();
    return deviceInfo.osVersion;
  }

  /// Get app version only
  ///
  /// Convenience method to get just the application version.
  ///
  /// Returns: App version string (e.g., '1.0.0')
  ///
  /// Example:
  /// ```dart
  /// final version = await DeviceInfoService().getAppVersion();
  /// ```
  Future<String> getAppVersion() async {
    final packageInfo = await _getPackageInfo();
    return packageInfo.version;
  }

  /// Get current connection type
  ///
  /// Public method to check the current network connection type.
  ///
  /// Returns: Connection type string ('wifi', 'mobile', 'ethernet', 'none', 'unknown')
  ///
  /// Example:
  /// ```dart
  /// final connection = await DeviceInfoService().getConnectionType();
  /// if (connection == 'none') {
  ///   print('No internet connection');
  /// }
  /// ```
  Future<String> getConnectionType() async {
    return _getConnectionType();
  }

  /// Clear cached information
  ///
  /// Clears all cached device and package information.
  /// Use this when you need to force a refresh of device information.
  ///
  /// Example:
  /// ```dart
  /// DeviceInfoService().clearCache();
  /// final freshInfo = await DeviceInfoService().getDeviceInfo();
  /// ```
  void clearCache() {
    _cachedDeviceInfo = null;
    _cachedPackageInfo = null;
    debugPrint('🧹 تم مسح cache معلومات الجهاز');
  }
}
