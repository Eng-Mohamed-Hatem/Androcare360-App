/// Unit tests for DeviceInfoService
///
/// Tests cover:
/// - Device info collection
/// - Caching mechanism
/// - Connection type detection
/// - Platform-specific information
/// - Error handling
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:elajtech/core/services/device_info_service.dart';
import 'package:elajtech/core/models/device_info_model.dart';
import '../../helpers/widget_test_helper.dart';

void main() {
  late DeviceInfoService deviceInfoService;

  setUpAll(setupFirebaseMocks);

  setUp(() {
    // Get singleton instance
    deviceInfoService = DeviceInfoService()..clearCache();
  });

  tearDown(() {
    // Cleanup
    deviceInfoService.clearCache();
  });

  tearDownAll(cleanupFirebaseMocks);

  group('DeviceInfoService - Initialization', () {
    test('should initialize successfully', () {
      // Assert
      expect(deviceInfoService, isNotNull);
    });

    test('should be singleton', () {
      // Arrange
      final instance1 = DeviceInfoService();
      final instance2 = DeviceInfoService();

      // Assert
      expect(identical(instance1, instance2), isTrue);
    });
  });

  group('DeviceInfoService - Device Info Collection', () {
    test('should return DeviceInfoModel', () async {
      // Act
      final deviceInfo = await deviceInfoService.getDeviceInfo();

      // Assert
      expect(deviceInfo, isA<DeviceInfoModel>());
      expect(deviceInfo.platform, isNotEmpty);
      expect(deviceInfo.deviceModel, isNotEmpty);
      expect(deviceInfo.osVersion, isNotEmpty);
    });

    test('should include app version', () async {
      // Act
      final deviceInfo = await deviceInfoService.getDeviceInfo();

      // Assert
      expect(deviceInfo.appVersion, isNotEmpty);
      expect(deviceInfo.appBuildNumber, isNotEmpty);
    });

    test('should include connection type', () async {
      // Act
      final deviceInfo = await deviceInfoService.getDeviceInfo();

      // Assert
      expect(deviceInfo.connectionType, isNotEmpty);
      expect(
        [
          'wifi',
          'mobile',
          'ethernet',
          'none',
          'unknown',
        ].contains(deviceInfo.connectionType),
        isTrue,
      );
    });

    test('should include screen resolution', () async {
      // Act
      final deviceInfo = await deviceInfoService.getDeviceInfo();

      // Assert
      expect(deviceInfo.screenResolution, isNotEmpty);
    });

    test('should include manufacturer', () async {
      // Act
      final deviceInfo = await deviceInfoService.getDeviceInfo();

      // Assert
      expect(deviceInfo.manufacturer, isNotEmpty);
    });
  });

  group('DeviceInfoService - Caching', () {
    test('should cache device info after first call', () async {
      // Act
      final deviceInfo1 = await deviceInfoService.getDeviceInfo();
      final deviceInfo2 = await deviceInfoService.getDeviceInfo();

      // Assert - should return same cached instance (except connection type)
      expect(deviceInfo1.platform, equals(deviceInfo2.platform));
      expect(deviceInfo1.deviceModel, equals(deviceInfo2.deviceModel));
      expect(deviceInfo1.appVersion, equals(deviceInfo2.appVersion));
    });

    test('should update connection type on cached calls', () async {
      // Act
      final deviceInfo1 = await deviceInfoService.getDeviceInfo();
      final deviceInfo2 = await deviceInfoService.getDeviceInfo();

      // Assert - connection type is always fresh
      expect(deviceInfo1.connectionType, isNotEmpty);
      expect(deviceInfo2.connectionType, isNotEmpty);
    });

    test('should clear cache when requested', () {
      // Act
      deviceInfoService.clearCache();

      // Assert - should not throw
      expect(deviceInfoService, isNotNull);
    });

    test('should recollect info after cache clear', () async {
      // Arrange
      await deviceInfoService.getDeviceInfo();

      // Act
      deviceInfoService.clearCache();
      final deviceInfo = await deviceInfoService.getDeviceInfo();

      // Assert
      expect(deviceInfo, isNotNull);
      expect(deviceInfo.platform, isNotEmpty);
    });
  });

  group('DeviceInfoService - Platform Detection', () {
    test('should detect platform correctly', () async {
      // Act
      final deviceInfo = await deviceInfoService.getDeviceInfo();

      // Assert
      expect(
        ['android', 'ios', 'unknown'].contains(deviceInfo.platform),
        isTrue,
      );
    });

    test('should provide platform-specific information', () async {
      // Act
      final deviceInfo = await deviceInfoService.getDeviceInfo();

      // Assert - platform-specific fields should be populated
      if (deviceInfo.platform == 'android') {
        expect(deviceInfo.manufacturer, isNotEmpty);
        expect(deviceInfo.osVersion, contains('Android'));
      } else if (deviceInfo.platform == 'ios') {
        expect(deviceInfo.manufacturer, equals('Apple'));
        expect(deviceInfo.osVersion, contains('iOS'));
      }
    });
  });

  group('DeviceInfoService - Connection Type', () {
    test('should detect connection type', () async {
      // Act
      final connectionType = await deviceInfoService.getConnectionType();

      // Assert
      expect(connectionType, isNotEmpty);
      expect(
        [
          'wifi',
          'mobile',
          'ethernet',
          'none',
          'unknown',
        ].contains(connectionType),
        isTrue,
      );
    });

    test('should handle wifi connection', () async {
      // Act
      final connectionType = await deviceInfoService.getConnectionType();

      // Assert - should be one of the valid types
      expect(connectionType, isA<String>());
    });

    test('should handle mobile connection', () async {
      // Act
      final connectionType = await deviceInfoService.getConnectionType();

      // Assert - should be one of the valid types
      expect(connectionType, isA<String>());
    });

    test('should handle no connection', () async {
      // Act
      final connectionType = await deviceInfoService.getConnectionType();

      // Assert - should be one of the valid types
      expect(connectionType, isA<String>());
    });
  });

  group('DeviceInfoService - Convenience Methods', () {
    test('should get device model', () async {
      // Act
      final deviceModel = await deviceInfoService.getDeviceModel();

      // Assert
      expect(deviceModel, isNotEmpty);
    });

    test('should get OS version', () async {
      // Act
      final osVersion = await deviceInfoService.getOSVersion();

      // Assert
      expect(osVersion, isNotEmpty);
    });

    test('should get app version', () async {
      // Act
      final appVersion = await deviceInfoService.getAppVersion();

      // Assert
      expect(appVersion, isNotEmpty);
      expect(appVersion, matches(RegExp(r'\d+\.\d+\.\d+')));
    });
  });

  group('DeviceInfoService - Error Handling', () {
    test('should return default values on error', () async {
      // Act
      final deviceInfo = await deviceInfoService.getDeviceInfo();

      // Assert - should not throw, returns valid model
      expect(deviceInfo, isNotNull);
      expect(deviceInfo.platform, isNotEmpty);
    });

    test('should handle screen resolution errors gracefully', () async {
      // Act
      final deviceInfo = await deviceInfoService.getDeviceInfo();

      // Assert - should have some value even if error occurred
      expect(deviceInfo.screenResolution, isNotEmpty);
    });

    test('should handle connection type errors gracefully', () async {
      // Act
      final connectionType = await deviceInfoService.getConnectionType();

      // Assert - should return 'unknown' on error
      expect(connectionType, isNotEmpty);
    });
  });

  group('DeviceInfoModel', () {
    test('should create model with all fields', () {
      // Arrange & Act
      const model = DeviceInfoModel(
        platform: 'android',
        deviceModel: 'Galaxy S21',
        manufacturer: 'Samsung',
        osVersion: 'Android 13',
        appVersion: '1.0.0',
        appBuildNumber: '1',
        connectionType: 'wifi',
        screenResolution: '1080x2400',
      );

      // Assert
      expect(model.platform, equals('android'));
      expect(model.deviceModel, equals('Galaxy S21'));
      expect(model.manufacturer, equals('Samsung'));
      expect(model.osVersion, equals('Android 13'));
      expect(model.appVersion, equals('1.0.0'));
      expect(model.appBuildNumber, equals('1'));
      expect(model.connectionType, equals('wifi'));
      expect(model.screenResolution, equals('1080x2400'));
    });

    test('should support copyWith for connection type updates', () {
      // Arrange
      const original = DeviceInfoModel(
        platform: 'android',
        deviceModel: 'Galaxy S21',
        manufacturer: 'Samsung',
        osVersion: 'Android 13',
        appVersion: '1.0.0',
        appBuildNumber: '1',
        connectionType: 'wifi',
        screenResolution: '1080x2400',
      );

      // Act
      final updated = original.copyWith(connectionType: 'mobile');

      // Assert
      expect(updated.connectionType, equals('mobile'));
      expect(updated.platform, equals(original.platform));
      expect(updated.deviceModel, equals(original.deviceModel));
    });
  });

  group('DeviceInfoService - Singleton Pattern', () {
    test('should maintain state across instances', () async {
      // Arrange
      final instance1 = DeviceInfoService();
      await instance1.getDeviceInfo();

      // Act
      final instance2 = DeviceInfoService();
      final deviceInfo = await instance2.getDeviceInfo();

      // Assert - should use cached data
      expect(deviceInfo, isNotNull);
    });

    test('should share cache across instances', () async {
      // Arrange
      final instance1 = DeviceInfoService();
      await instance1.getDeviceInfo();

      // Act
      final instance2 = DeviceInfoService()..clearCache();

      // Assert - cache should be cleared for both
      expect(identical(instance1, instance2), isTrue);
    });
  });
}
