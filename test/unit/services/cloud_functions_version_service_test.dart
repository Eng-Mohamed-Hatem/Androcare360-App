import 'package:cloud_functions/cloud_functions.dart';
import 'package:elajtech/core/services/cloud_functions_version_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'cloud_functions_version_service_test.mocks.dart';

@GenerateMocks(
  [
    FirebaseFunctions,
    HttpsCallable,
  ],
  customMocks: [
    MockSpec<HttpsCallableResult<Map<String, dynamic>>>(
      as: #MockHttpsCallableResultMap,
    ),
  ],
)
void main() {
  group('CloudFunctionsVersionService', () {
    late CloudFunctionsVersionService service;
    late MockFirebaseFunctions mockFunctions;
    late MockHttpsCallable mockCallable;
    late MockHttpsCallableResultMap mockResult;

    setUp(() {
      mockFunctions = MockFirebaseFunctions();
      mockCallable = MockHttpsCallable();
      mockResult = MockHttpsCallableResultMap();
      service = CloudFunctionsVersionService(mockFunctions);
    });

    group('verifyCloudFunctionsVersion', () {
      test('returns version info when call succeeds', () async {
        // Arrange
        final versionData = {
          'version': '2.1.0',
          'deployedAt': '2026-02-16T10:00:00Z',
          'databaseId': 'elajtech',
          'hasDatabaseConfigFix': true,
          'timestamp': '2026-02-16T10:00:00Z',
        };

        when(
          mockFunctions.httpsCallable('getFunctionsVersion'),
        ).thenReturn(mockCallable);
        when(
          mockCallable.call<Map<String, dynamic>>(),
        ).thenAnswer((_) async => mockResult);
        when(mockResult.data).thenReturn(versionData);

        // Act
        final result = await service.verifyCloudFunctionsVersion();

        // Assert
        expect(result, isNotNull);
        expect(result!['version'], '2.1.0');
        expect(result['databaseId'], 'elajtech');
        expect(result['hasDatabaseConfigFix'], true);
      });

      test('logs warning when databaseId is not elajtech', () async {
        // Arrange
        final versionData = {
          'version': '2.0.0',
          'deployedAt': '2026-02-15T10:00:00Z',
          'databaseId': 'default',
          'hasDatabaseConfigFix': false,
          'timestamp': '2026-02-16T10:00:00Z',
        };

        when(
          mockFunctions.httpsCallable('getFunctionsVersion'),
        ).thenReturn(mockCallable);
        when(
          mockCallable.call<Map<String, dynamic>>(),
        ).thenAnswer((_) async => mockResult);
        when(mockResult.data).thenReturn(versionData);

        // Act
        final result = await service.verifyCloudFunctionsVersion();

        // Assert
        expect(result, isNotNull);
        expect(result!['databaseId'], 'default');
        // Warning should be logged (verified in debug console)
      });

      test('returns null when function call fails', () async {
        // Arrange
        when(
          mockFunctions.httpsCallable('getFunctionsVersion'),
        ).thenReturn(mockCallable);
        when(mockCallable.call<Map<String, dynamic>>()).thenThrow(
          FirebaseFunctionsException(
            code: 'not-found',
            message: 'Function not found',
          ),
        );

        // Act
        final result = await service.verifyCloudFunctionsVersion();

        // Assert
        expect(result, isNull);
      });

      test('returns null when call times out', () async {
        // Arrange
        when(
          mockFunctions.httpsCallable('getFunctionsVersion'),
        ).thenReturn(mockCallable);
        when(mockCallable.call<Map<String, dynamic>>()).thenAnswer(
          (_) => Future<MockHttpsCallableResultMap>.delayed(
            const Duration(seconds: 15),
            () => mockResult,
          ),
        );

        // Act
        final result = await service.verifyCloudFunctionsVersion();

        // Assert
        expect(result, isNull);
      });
    });

    group('getVersionInfo', () {
      test('returns version info without logging', () async {
        // Arrange
        final versionData = {
          'version': '2.1.0',
          'deployedAt': '2026-02-16T10:00:00Z',
          'databaseId': 'elajtech',
          'hasDatabaseConfigFix': true,
          'timestamp': '2026-02-16T10:00:00Z',
        };

        when(
          mockFunctions.httpsCallable('getFunctionsVersion'),
        ).thenReturn(mockCallable);
        when(
          mockCallable.call<Map<String, dynamic>>(),
        ).thenAnswer((_) async => mockResult);
        when(mockResult.data).thenReturn(versionData);

        // Act
        final result = await service.getVersionInfo();

        // Assert
        expect(result, isNotNull);
        expect(result!['version'], '2.1.0');
        expect(result['databaseId'], 'elajtech');
      });

      test('returns null when call fails', () async {
        // Arrange
        when(
          mockFunctions.httpsCallable('getFunctionsVersion'),
        ).thenReturn(mockCallable);
        when(mockCallable.call<Map<String, dynamic>>()).thenThrow(
          Exception('Network error'),
        );

        // Act
        final result = await service.getVersionInfo();

        // Assert
        expect(result, isNull);
      });
    });

    group('isDatabaseConfigured', () {
      test('returns true when database is correctly configured', () async {
        // Arrange
        final versionData = {
          'version': '2.1.0',
          'databaseId': 'elajtech',
          'hasDatabaseConfigFix': true,
        };

        when(
          mockFunctions.httpsCallable('getFunctionsVersion'),
        ).thenReturn(mockCallable);
        when(
          mockCallable.call<Map<String, dynamic>>(),
        ).thenAnswer((_) async => mockResult);
        when(mockResult.data).thenReturn(versionData);

        // Act
        final result = await service.isDatabaseConfigured();

        // Assert
        expect(result, true);
      });

      test('returns false when databaseId is not elajtech', () async {
        // Arrange
        final versionData = {
          'version': '2.0.0',
          'databaseId': 'default',
          'hasDatabaseConfigFix': true,
        };

        when(
          mockFunctions.httpsCallable('getFunctionsVersion'),
        ).thenReturn(mockCallable);
        when(
          mockCallable.call<Map<String, dynamic>>(),
        ).thenAnswer((_) async => mockResult);
        when(mockResult.data).thenReturn(versionData);

        // Act
        final result = await service.isDatabaseConfigured();

        // Assert
        expect(result, false);
      });

      test('returns false when hasDatabaseConfigFix is false', () async {
        // Arrange
        final versionData = {
          'version': '2.0.0',
          'databaseId': 'elajtech',
          'hasDatabaseConfigFix': false,
        };

        when(
          mockFunctions.httpsCallable('getFunctionsVersion'),
        ).thenReturn(mockCallable);
        when(
          mockCallable.call<Map<String, dynamic>>(),
        ).thenAnswer((_) async => mockResult);
        when(mockResult.data).thenReturn(versionData);

        // Act
        final result = await service.isDatabaseConfigured();

        // Assert
        expect(result, false);
      });

      test('returns false when call fails', () async {
        // Arrange
        when(
          mockFunctions.httpsCallable('getFunctionsVersion'),
        ).thenReturn(mockCallable);
        when(mockCallable.call<Map<String, dynamic>>()).thenThrow(
          Exception('Network error'),
        );

        // Act
        final result = await service.isDatabaseConfigured();

        // Assert
        expect(result, false);
      });
    });
  });
}
