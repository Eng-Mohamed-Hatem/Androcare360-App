/// Widget tests for AdminDoctorDetailScreen form validation
///
/// Verifies:
/// - TC-04: Mandatory fields validation
/// - TC-05: Invalid email format validation
/// - TC-06: Weak password validation (min 6 chars)
///
/// Run with:
/// ```bash
/// flutter test test/widget/admin/admin_doctor_detail_screen_test.dart
/// ```
library;

import 'package:elajtech/features/auth/providers/auth_provider.dart';
import '../../fixtures/user_fixtures.dart';
import '../../mocks/mock_auth_repository.dart';
import 'package:elajtech/core/services/storage_service.dart';
import 'package:elajtech/features/admin/presentation/providers/admin_provider.dart';
import 'package:elajtech/features/admin/presentation/screens/admin_doctor_detail_screen.dart';
import 'package:elajtech/features/admin/domain/repositories/admin_repository.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'admin_doctor_detail_screen_test.mocks.dart';

@GenerateMocks([AdminRepository, StorageService])
void main() {
  late MockAdminRepository mockRepo;
  late MockStorageService mockStorage;
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockRepo = MockAdminRepository();
    mockStorage = MockStorageService();

    // Setup GetIt for testing
    final getIt = GetIt.instance;
    if (getIt.isRegistered<StorageService>()) {
      getIt.unregister<StorageService>();
    }
    getIt.registerSingleton<StorageService>(mockStorage);

    // Create mock repo with a logged-in admin by default
    mockAuthRepo = MockAuthRepository(currentUser: UserFixtures.createAdmin());
  });

  /// Helper to build the screen with mocked providers
  Widget createTestWidget({UserModel? doctor}) {
    return ProviderScope(
      overrides: [
        adminRepositoryProvider.overrideWithValue(mockRepo),
        authProvider.overrideWith(
          (ref) => AuthNotifier(mockAuthRepo)
            ..state = AuthState(
              user: mockAuthRepo.currentUser,
              isAuthenticated: mockAuthRepo.currentUser != null,
            ),
        ),
      ],
      child: MaterialApp(
        home: AdminDoctorDetailScreen(doctor: doctor),
      ),
    );
  }

  group('AdminDoctorDetailScreen - Form Validation', () {
    testWidgets('TC-04: shows error messages for empty required fields', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Ensure we can find the fields at all
      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));

      // Find submit button (matches 'إنشاء الحساب' in create mode)
      final submitBtn = find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.text('إنشاء الحساب'),
      );

      expect(submitBtn, findsOneWidget);

      // Scroll to button to avoid hit-test failure
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();

      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Check for error messages (Arabic)
      // Name, Email, Password are required in create mode
      expect(find.text('هذا الحقل مطلوب'), findsAtLeastNWidgets(3));
      verifyNever(
        mockRepo.createDoctor(
          doctor: anyNamed('doctor'),
          password: anyNamed('password'),
          adminId: anyNamed('adminId'),
          adminName: anyNamed('adminName'),
        ),
      );
    });

    testWidgets('TC-05: shows error for invalid email format', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Enter valid name but invalid email
      await tester.enterText(
        find.byKey(const ValueKey('fullNameField')),
        'Dr. Ahmed',
      );
      await tester.enterText(
        find.byKey(const ValueKey('emailField')),
        'not-an-email',
      );
      await tester.pump();

      final submitBtn = find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.text('إنشاء الحساب'),
      );
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('يرجى إدخال بريد إلكتروني صحيح'), findsOneWidget);
      verifyNever(
        mockRepo.createDoctor(
          doctor: anyNamed('doctor'),
          password: anyNamed('password'),
          adminId: anyNamed('adminId'),
          adminName: anyNamed('adminName'),
        ),
      );
    });

    testWidgets('TC-06: shows error for password < 6 characters', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.enterText(
        find.byKey(const ValueKey('fullNameField')),
        'Dr. Ahmed',
      );
      await tester.enterText(
        find.byKey(const ValueKey('emailField')),
        'ahmed@test.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('passwordField')),
        '12345',
      );
      await tester.pump();

      final submitBtn = find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.text('إنشاء الحساب'),
      );
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('يجب أن تكون 6 أحرف على الأقل'), findsOneWidget);
    });

    testWidgets('TC-06.1: validation passes when password is 6+ characters', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.enterText(
        find.byKey(const ValueKey('fullNameField')),
        'Dr. Ahmed',
      );
      await tester.enterText(
        find.byKey(const ValueKey('emailField')),
        'ahmed@test.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('passwordField')),
        'password123',
      );
      await tester.pump();

      final submitBtn = find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.text('إنشاء الحساب'),
      );
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Password error should NOT be visible
      expect(find.text('يجب أن تكون 6 أحرف على الأقل'), findsNothing);
    });
  });
}
