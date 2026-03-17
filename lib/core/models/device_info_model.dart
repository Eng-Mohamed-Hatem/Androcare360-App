import 'package:flutter/foundation.dart';

/// Represents device information for technical troubleshooting.
///
/// This model stores comprehensive device and system information that is
/// attached to call logs and error reports. It helps identify device-specific
/// issues and optimize the application for different platforms.
///
/// **Usage:**
/// Device information is collected by DeviceInfoService and attached to
/// call logs for debugging purposes. It includes platform details, hardware
/// specifications, and network connectivity information.
///
/// **Usage Example:**
/// ```dart
/// final deviceInfo = DeviceInfoModel(
///   platform: 'android',
///   deviceModel: 'Samsung Galaxy S21',
///   manufacturer: 'Samsung',
///   osVersion: 'Android 13',
///   appVersion: '1.0.0',
///   appBuildNumber: '1',
///   connectionType: 'wifi',
///   screenResolution: '1080x2400',
///   availableMemoryMB: 4096,
/// );
/// ```
@immutable
class DeviceInfoModel {
  /// Creates a DeviceInfoModel instance.
  ///
  /// All fields are required except availableMemoryMB which is optional.
  const DeviceInfoModel({
    required this.platform,
    required this.deviceModel,
    required this.manufacturer,
    required this.osVersion,
    required this.appVersion,
    required this.appBuildNumber,
    required this.connectionType,
    required this.screenResolution,
    this.availableMemoryMB,
  });

  /// Creates a DeviceInfoModel from JSON data.
  ///
  /// This factory constructor parses JSON data and creates a DeviceInfoModel
  /// instance with proper type conversions.
  ///
  /// Parameters:
  /// - [json]: Map containing device information data
  ///
  /// Returns a fully initialized DeviceInfoModel instance.
  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) {
    return DeviceInfoModel(
      platform: json['platform'] as String,
      deviceModel: json['deviceModel'] as String,
      manufacturer: json['manufacturer'] as String,
      osVersion: json['osVersion'] as String,
      appVersion: json['appVersion'] as String,
      appBuildNumber: json['appBuildNumber'] as String,
      connectionType: json['connectionType'] as String,
      availableMemoryMB: json['availableMemoryMB'] as int?,
      screenResolution: json['screenResolution'] as String,
    );
  }

  /// Platform identifier ('android' or 'ios')
  final String platform;

  /// Device model name (e.g., 'Samsung Galaxy S21', 'iPhone 13 Pro')
  final String deviceModel;

  /// Device manufacturer (e.g., 'Samsung', 'Apple')
  final String manufacturer;

  /// Operating system version (e.g., 'Android 13', 'iOS 16.5')
  final String osVersion;

  /// Application version (e.g., '1.0.0')
  final String appVersion;

  /// Application build number for tracking specific builds
  final String appBuildNumber;

  /// Network connection type ('wifi', 'mobile', 'none')
  final String connectionType;

  /// Available device memory in megabytes (optional)
  final int? availableMemoryMB;

  /// Screen resolution (e.g., '1080x2400')
  final String screenResolution;

  /// Converts this DeviceInfoModel to JSON format for Firestore storage.
  ///
  /// Returns a `Map<String, dynamic>` containing all device information.
  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'deviceModel': deviceModel,
      'manufacturer': manufacturer,
      'osVersion': osVersion,
      'appVersion': appVersion,
      'appBuildNumber': appBuildNumber,
      'connectionType': connectionType,
      'availableMemoryMB': availableMemoryMB,
      'screenResolution': screenResolution,
    };
  }

  /// Creates a copy of this DeviceInfoModel with the specified fields replaced.
  ///
  /// Useful for updating device information when conditions change
  /// (e.g., network connection type).
  ///
  /// Returns a new DeviceInfoModel instance with updated fields.
  DeviceInfoModel copyWith({
    String? platform,
    String? deviceModel,
    String? manufacturer,
    String? osVersion,
    String? appVersion,
    String? appBuildNumber,
    String? connectionType,
    int? availableMemoryMB,
    String? screenResolution,
  }) {
    return DeviceInfoModel(
      platform: platform ?? this.platform,
      deviceModel: deviceModel ?? this.deviceModel,
      manufacturer: manufacturer ?? this.manufacturer,
      osVersion: osVersion ?? this.osVersion,
      appVersion: appVersion ?? this.appVersion,
      appBuildNumber: appBuildNumber ?? this.appBuildNumber,
      connectionType: connectionType ?? this.connectionType,
      availableMemoryMB: availableMemoryMB ?? this.availableMemoryMB,
      screenResolution: screenResolution ?? this.screenResolution,
    );
  }

  @override
  String toString() {
    return 'DeviceInfoModel(platform: $platform, deviceModel: $deviceModel, '
        'manufacturer: $manufacturer, osVersion: $osVersion, '
        'appVersion: $appVersion, connectionType: $connectionType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceInfoModel &&
        other.platform == platform &&
        other.deviceModel == deviceModel &&
        other.manufacturer == manufacturer &&
        other.osVersion == osVersion &&
        other.appVersion == appVersion &&
        other.appBuildNumber == appBuildNumber &&
        other.connectionType == connectionType &&
        other.availableMemoryMB == availableMemoryMB &&
        other.screenResolution == screenResolution;
  }

  @override
  int get hashCode {
    return Object.hash(
      platform,
      deviceModel,
      manufacturer,
      osVersion,
      appVersion,
      appBuildNumber,
      connectionType,
      availableMemoryMB,
      screenResolution,
    );
  }
}
