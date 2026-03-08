import 'package:elajtech/core/services/token_refresh_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mocks.mocks.dart';

void main() {
  late TokenRefreshService tokenRefreshService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    tokenRefreshService = TokenRefreshService(mockFirebaseAuth);
  });

  group('TokenRefreshService - Force Refresh Token', () {
    test('should refresh token successfully when user is logged in', () async {
      // Arrange
      const testToken = 'test-token-12345';
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken(true)).thenAnswer((_) async => testToken);

      // Act
      final result = await tokenRefreshService.forceRefreshToken();

      // Assert
      expect(result, true);
      verify(mockFirebaseAuth.currentUser).called(1);
      verify(mockUser.getIdToken(true)).called(1);
    });

    test('should return false when no user is logged in', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await tokenRefreshService.forceRefreshToken();

      // Assert
      expect(result, false);
      verify(mockFirebaseAuth.currentUser).called(1);
      verifyNever(mockUser.getIdToken(any));
    });

    test('should return false when token refresh fails', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken(true)).thenThrow(Exception('Network error'));

      // Act
      final result = await tokenRefreshService.forceRefreshToken();

      // Assert
      expect(result, false);
      verify(mockFirebaseAuth.currentUser).called(1);
      verify(mockUser.getIdToken(true)).called(1);
    });

    test('should handle FirebaseAuthException gracefully', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken(true)).thenThrow(
        FirebaseAuthException(
          code: 'network-request-failed',
          message: 'Network error',
        ),
      );

      // Act
      final result = await tokenRefreshService.forceRefreshToken();

      // Assert
      expect(result, false);
      verify(mockUser.getIdToken(true)).called(1);
    });
  });

  group('TokenRefreshService - Get Fresh Token', () {
    test('should return fresh token when user is logged in', () async {
      // Arrange
      const testToken = 'fresh-token-67890';
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken(true)).thenAnswer((_) async => testToken);

      // Act
      final result = await tokenRefreshService.getFreshToken();

      // Assert
      expect(result, testToken);
      verify(mockFirebaseAuth.currentUser).called(1);
      verify(mockUser.getIdToken(true)).called(1);
    });

    test('should return null when no user is logged in', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await tokenRefreshService.getFreshToken();

      // Assert
      expect(result, null);
      verify(mockFirebaseAuth.currentUser).called(1);
      verifyNever(mockUser.getIdToken(any));
    });

    test('should return null when token is empty', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken(true)).thenAnswer((_) async => '');

      // Act
      final result = await tokenRefreshService.getFreshToken();

      // Assert
      expect(result, null);
      verify(mockUser.getIdToken(true)).called(1);
    });

    test('should return null when token is null', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken(true)).thenAnswer((_) async => null);

      // Act
      final result = await tokenRefreshService.getFreshToken();

      // Assert
      expect(result, null);
      verify(mockUser.getIdToken(true)).called(1);
    });

    test('should return null when token refresh fails', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(
        mockUser.getIdToken(true),
      ).thenThrow(Exception('Token refresh failed'));

      // Act
      final result = await tokenRefreshService.getFreshToken();

      // Assert
      expect(result, null);
      verify(mockUser.getIdToken(true)).called(1);
    });

    test('should handle network errors gracefully', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken(true)).thenThrow(
        FirebaseAuthException(
          code: 'network-request-failed',
          message: 'A network error occurred',
        ),
      );

      // Act
      final result = await tokenRefreshService.getFreshToken();

      // Assert
      expect(result, null);
      verify(mockUser.getIdToken(true)).called(1);
    });
  });

  group('TokenRefreshService - Validate and Refresh Token', () {
    test('should return true when token is valid', () async {
      // Arrange
      const validToken = 'valid-token-abc123';
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken()).thenAnswer((_) async => validToken);

      // Act
      final result = await tokenRefreshService
          .validateAndRefreshTokenIfNeeded();

      // Assert
      expect(result, true);
      verify(mockFirebaseAuth.currentUser).called(1);
      verify(mockUser.getIdToken()).called(1);
      verifyNever(mockUser.getIdToken(true)); // Should not force refresh
    });

    test('should return false when no user is logged in', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await tokenRefreshService
          .validateAndRefreshTokenIfNeeded();

      // Assert
      expect(result, false);
      verify(mockFirebaseAuth.currentUser).called(1);
      verifyNever(mockUser.getIdToken(any));
    });

    test('should force refresh when token is empty', () async {
      // Arrange
      const refreshedToken = 'refreshed-token-xyz';
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken()).thenAnswer((_) async => '');
      when(mockUser.getIdToken(true)).thenAnswer((_) async => refreshedToken);

      // Act
      final result = await tokenRefreshService
          .validateAndRefreshTokenIfNeeded();

      // Assert
      expect(result, true);
      verify(mockUser.getIdToken()).called(1);
      verify(mockUser.getIdToken(true)).called(1); // Force refresh called
    });

    test('should force refresh when token is null', () async {
      // Arrange
      const refreshedToken = 'refreshed-token-def';
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken()).thenAnswer((_) async => null);
      when(mockUser.getIdToken(true)).thenAnswer((_) async => refreshedToken);

      // Act
      final result = await tokenRefreshService
          .validateAndRefreshTokenIfNeeded();

      // Assert
      expect(result, true);
      verify(mockUser.getIdToken()).called(1);
      verify(mockUser.getIdToken(true)).called(1);
    });

    test('should attempt force refresh when validation fails', () async {
      // Arrange
      const refreshedToken = 'refreshed-after-error';
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken()).thenThrow(Exception('Validation error'));
      when(mockUser.getIdToken(true)).thenAnswer((_) async => refreshedToken);

      // Act
      final result = await tokenRefreshService
          .validateAndRefreshTokenIfNeeded();

      // Assert
      expect(result, true);
      verify(mockUser.getIdToken()).called(1);
      verify(mockUser.getIdToken(true)).called(1);
    });

    test('should return false when both validation and refresh fail', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken()).thenThrow(Exception('Validation error'));
      when(mockUser.getIdToken(true)).thenThrow(Exception('Refresh error'));

      // Act
      final result = await tokenRefreshService
          .validateAndRefreshTokenIfNeeded();

      // Assert
      expect(result, false);
      verify(mockUser.getIdToken()).called(1);
      verify(mockUser.getIdToken(true)).called(1);
    });

    test('should handle FirebaseAuthException during validation', () async {
      // Arrange
      const refreshedToken = 'refreshed-token-ghi';
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken()).thenThrow(
        FirebaseAuthException(
          code: 'user-token-expired',
          message: 'Token expired',
        ),
      );
      when(mockUser.getIdToken(true)).thenAnswer((_) async => refreshedToken);

      // Act
      final result = await tokenRefreshService
          .validateAndRefreshTokenIfNeeded();

      // Assert
      expect(result, true);
      verify(mockUser.getIdToken()).called(1);
      verify(mockUser.getIdToken(true)).called(1);
    });
  });

  group('TokenRefreshService - Get Current User ID', () {
    test('should return user ID when user is logged in', () {
      // Arrange
      const testUserId = 'user-123-abc';
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(testUserId);

      // Act
      final result = tokenRefreshService.getCurrentUserId();

      // Assert
      expect(result, testUserId);
      verify(mockFirebaseAuth.currentUser).called(1);
      verify(mockUser.uid).called(1);
    });

    test('should return null when no user is logged in', () {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = tokenRefreshService.getCurrentUserId();

      // Assert
      expect(result, null);
      verify(mockFirebaseAuth.currentUser).called(1);
      verifyNever(mockUser.uid);
    });
  });

  group('TokenRefreshService - Is User Logged In', () {
    test('should return true when user is logged in', () {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act
      final result = tokenRefreshService.isUserLoggedIn();

      // Assert
      expect(result, true);
      verify(mockFirebaseAuth.currentUser).called(1);
    });

    test('should return false when no user is logged in', () {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = tokenRefreshService.isUserLoggedIn();

      // Assert
      expect(result, false);
      verify(mockFirebaseAuth.currentUser).called(1);
    });
  });

  group('TokenRefreshService - Error Handling', () {
    test('should handle multiple consecutive refresh attempts', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(
        mockUser.getIdToken(true),
      ).thenAnswer((_) async => 'token-attempt-1');

      // Act
      final result1 = await tokenRefreshService.forceRefreshToken();
      final result2 = await tokenRefreshService.forceRefreshToken();
      final result3 = await tokenRefreshService.forceRefreshToken();

      // Assert
      expect(result1, true);
      expect(result2, true);
      expect(result3, true);
      verify(mockUser.getIdToken(true)).called(3);
    });

    test('should handle token refresh timeout', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken(true)).thenThrow(
        FirebaseAuthException(
          code: 'timeout',
          message: 'Request timeout',
        ),
      );

      // Act
      final result = await tokenRefreshService.forceRefreshToken();

      // Assert
      expect(result, false);
      verify(mockUser.getIdToken(true)).called(1);
    });

    test('should handle user-disabled error', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken(true)).thenThrow(
        FirebaseAuthException(
          code: 'user-disabled',
          message: 'User account has been disabled',
        ),
      );

      // Act
      final result = await tokenRefreshService.getFreshToken();

      // Assert
      expect(result, null);
      verify(mockUser.getIdToken(true)).called(1);
    });

    test('should handle user-not-found error', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken(true)).thenThrow(
        FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not found',
        ),
      );

      // Act
      final result = await tokenRefreshService.getFreshToken();

      // Assert
      expect(result, null);
      verify(mockUser.getIdToken(true)).called(1);
    });
  });

  group('TokenRefreshService - Edge Cases', () {
    test('should handle very long token strings', () async {
      // Arrange
      final longToken = 'a' * 10000; // Very long token
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken(true)).thenAnswer((_) async => longToken);

      // Act
      final result = await tokenRefreshService.getFreshToken();

      // Assert
      expect(result, longToken);
      expect(result?.length, 10000);
    });

    test('should handle rapid successive calls', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken(true)).thenAnswer((_) async => 'rapid-token');

      // Act - Make multiple rapid calls
      final results = await Future.wait([
        tokenRefreshService.forceRefreshToken(),
        tokenRefreshService.forceRefreshToken(),
        tokenRefreshService.forceRefreshToken(),
        tokenRefreshService.forceRefreshToken(),
        tokenRefreshService.forceRefreshToken(),
      ]);

      // Assert
      expect(results.every((r) => r), true);
      verify(mockUser.getIdToken(true)).called(5);
    });

    test('should handle user logout during token refresh', () async {
      // Arrange - First call returns user, second returns null
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act
      final result1 = tokenRefreshService.isUserLoggedIn();

      // Arrange - User logs out
      when(mockFirebaseAuth.currentUser).thenReturn(null);
      final result2 = tokenRefreshService.isUserLoggedIn();

      // Assert
      expect(result1, true);
      expect(result2, false);
    });
  });
}
