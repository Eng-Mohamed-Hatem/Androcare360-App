/// Unit tests for AdminNotifier
///
/// Tests the provider-level logic for admin panel operations:
/// - createDoctor: success → state transitions → loadDoctors called
/// - updateDoctorProfile: success / failure state transitions
/// - setAccountStatus: success → both lists refreshed
/// - StateError guard: expired session shows Arabic error instead of crashing
///
/// Run with:
/// ```bash
/// flutter test test/unit/providers/admin_notifier_test.dart --reporter expanded
/// ```
library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/admin/domain/repositories/admin_repository.dart';
import 'package:elajtech/features/admin/presentation/providers/admin_provider.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mock_auth_repository.dart';
import 'admin_notifier_test.mocks.dart';

@GenerateMocks([AdminRepository])
void main() {
  // ── Fixtures ──────────────────────────────────────────────────────────────

  final adminUser = UserModel(
    id: 'admin-001',
    fullName: 'Admin User',
    email: 'admin@clinic.com',
    userType: UserType.admin,
    createdAt: DateTime(2024),
  );

  final newDoctor = UserModel(
    id: '',
    fullName: 'Dr. Sara Ali',
    email: 'sara.ali@test.com',
    userType: UserType.doctor,
    specializations: ['نساء وتوليد'],
    clinicName: 'عيادة نور',
    createdAt: DateTime(2024),
  );

  final existingDoctor = newDoctor.copyWith(id: 'doc-001');

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Builds a [ProviderContainer] with the given logged-in user (or null for
  /// no session) and a mock [AdminRepository].
  ///
  /// Uses [MockAuthRepository] (hand-written mock that returns the given user)
  /// so that [AuthNotifier] initialises correctly without GetIt / Firebase.
  ProviderContainer makeContainer({
    required MockAdminRepository mockRepo,
    UserModel? loggedInUser,
  }) {
    final container = ProviderContainer(
      overrides: [
        adminRepositoryProvider.overrideWithValue(mockRepo),
        // Override authProvider with an AuthNotifier backed by a fake repo
        // that immediately resolves to `loggedInUser` (or no-user if null).
        authProvider.overrideWith(
          (ref) =>
              AuthNotifier(MockAuthRepository(currentUser: loggedInUser))
                ..state = AuthState(
                  user: loggedInUser,
                  isAuthenticated: loggedInUser != null,
                ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // StateError guard — expired / null admin session
  // ══════════════════════════════════════════════════════════════════════════

  group('AdminNotifier - StateError guard (expired session)', () {
    late MockAdminRepository mockRepo;

    setUp(() {
      mockRepo = MockAdminRepository();
    });

    test(
      'createDoctor shows Arabic error when no admin user in session',
      () async {
        final container = makeContainer(
          mockRepo: mockRepo,
        );

        await container
            .read(adminProvider.notifier)
            .createDoctor(
              doctor: newDoctor,
              password: 'Test@1234',
            );

        final state = container.read(adminProvider);
        expect(state.isActionLoading, isFalse);
        expect(state.error, isNotNull);
        expect(
          state.error,
          contains('انتهت الجلسة'),
          reason: 'Should show Arabic session error, not crash',
        );
        // Repository must NOT be called
        verifyNever(
          mockRepo.createDoctor(
            doctor: anyNamed('doctor'),
            password: anyNamed('password'),
            adminId: anyNamed('adminId'),
            adminName: anyNamed('adminName'),
          ),
        );
      },
    );

    test('updateDoctorProfile shows Arabic error when no admin user', () async {
      final container = makeContainer(
        mockRepo: mockRepo,
      );

      await container
          .read(adminProvider.notifier)
          .updateDoctorProfile(
            updatedDoctor: existingDoctor,
            previousDoctor: existingDoctor,
          );

      final state = container.read(adminProvider);
      expect(state.error, contains('انتهت الجلسة'));
      verifyNever(
        mockRepo.updateDoctorProfile(
          updatedDoctor: anyNamed('updatedDoctor'),
          previousDoctor: anyNamed('previousDoctor'),
          adminId: anyNamed('adminId'),
          adminName: anyNamed('adminName'),
        ),
      );
    });

    test('setAccountStatus shows Arabic error when no admin user', () async {
      final container = makeContainer(
        mockRepo: mockRepo,
      );

      await container
          .read(adminProvider.notifier)
          .setAccountStatus(
            targetUserId: 'doc-001',
            isActive: false,
          );

      final state = container.read(adminProvider);
      expect(state.error, contains('انتهت الجلسة'));
      verifyNever(
        mockRepo.setAccountStatus(
          targetUserId: anyNamed('targetUserId'),
          isActive: anyNamed('isActive'),
          adminId: anyNamed('adminId'),
          adminName: anyNamed('adminName'),
        ),
      );
    });

    test('shows session error when user is a non-admin type', () async {
      final patientUser = adminUser.copyWith(
        id: 'patient-001',
        userType: UserType.patient,
      );
      final container = makeContainer(
        mockRepo: mockRepo,
        loggedInUser: patientUser,
      );

      await container
          .read(adminProvider.notifier)
          .createDoctor(
            doctor: newDoctor,
            password: 'Test@1234',
          );

      // Should show session error, not crash
      final state = container.read(adminProvider);
      expect(state.error, contains('انتهت الجلسة'));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // createDoctor — with valid admin session
  // ══════════════════════════════════════════════════════════════════════════

  group('AdminNotifier - createDoctor (valid session)', () {
    late MockAdminRepository mockRepo;

    setUp(() {
      mockRepo = MockAdminRepository();
      // Default stubs for list refresh calls
      when(mockRepo.getAllDoctors()).thenAnswer((_) async => const Right([]));
      when(mockRepo.getAllPatients()).thenAnswer((_) async => const Right([]));
    });

    test(
      'success: isActionLoading=false, no error, loadDoctors called',
      () async {
        when(
          mockRepo.createDoctor(
            doctor: anyNamed('doctor'),
            password: anyNamed('password'),
            adminId: anyNamed('adminId'),
            adminName: anyNamed('adminName'),
          ),
        ).thenAnswer((_) async => const Right(unit));

        final container = makeContainer(
          mockRepo: mockRepo,
          loggedInUser: adminUser,
        );

        await container
            .read(adminProvider.notifier)
            .createDoctor(
              doctor: newDoctor,
              password: 'Test@1234',
            );

        final state = container.read(adminProvider);
        expect(state.isActionLoading, isFalse);
        expect(state.error, isNull);

        // Verify repo was called with admin's credentials
        verify(
          mockRepo.createDoctor(
            doctor: anyNamed('doctor'),
            password: anyNamed('password'),
            adminId: adminUser.id,
            adminName: adminUser.fullName,
          ),
        ).called(1);

        // Doctor list must refresh after success
        verify(mockRepo.getAllDoctors()).called(greaterThanOrEqualTo(1));
      },
    );

    test(
      'failure: state.error contains Arabic message, isActionLoading=false',
      () async {
        when(
          mockRepo.createDoctor(
            doctor: anyNamed('doctor'),
            password: anyNamed('password'),
            adminId: anyNamed('adminId'),
            adminName: anyNamed('adminName'),
          ),
        ).thenAnswer(
          (_) async => const Left(ServerFailure('فشل إنشاء حساب الطبيب')),
        );

        final container = makeContainer(
          mockRepo: mockRepo,
          loggedInUser: adminUser,
        );

        await container
            .read(adminProvider.notifier)
            .createDoctor(
              doctor: newDoctor,
              password: 'Test@1234',
            );

        final state = container.read(adminProvider);
        expect(state.isActionLoading, isFalse);
        expect(state.error, isNotNull);
        expect(state.error, contains('فشل'));
      },
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // setAccountStatus — refreshes both lists
  // ══════════════════════════════════════════════════════════════════════════

  group('AdminNotifier - setAccountStatus (valid session)', () {
    late MockAdminRepository mockRepo;

    setUp(() {
      mockRepo = MockAdminRepository();
      when(mockRepo.getAllDoctors()).thenAnswer((_) async => const Right([]));
      when(mockRepo.getAllPatients()).thenAnswer((_) async => const Right([]));
    });

    test('success: refreshes both doctors and patients lists', () async {
      when(
        mockRepo.setAccountStatus(
          targetUserId: anyNamed('targetUserId'),
          isActive: anyNamed('isActive'),
          adminId: anyNamed('adminId'),
          adminName: anyNamed('adminName'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      final container = makeContainer(
        mockRepo: mockRepo,
        loggedInUser: adminUser,
      );

      await container
          .read(adminProvider.notifier)
          .setAccountStatus(
            targetUserId: 'doc-001',
            isActive: false,
          );

      // Both lists must be refreshed so UI badge updates immediately
      verify(mockRepo.getAllDoctors()).called(greaterThanOrEqualTo(1));
      verify(mockRepo.getAllPatients()).called(greaterThanOrEqualTo(1));
    });

    test('failure: state.error is set, isActionLoading=false', () async {
      when(
        mockRepo.setAccountStatus(
          targetUserId: anyNamed('targetUserId'),
          isActive: anyNamed('isActive'),
          adminId: anyNamed('adminId'),
          adminName: anyNamed('adminName'),
        ),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('فشل تغيير الحالة')),
      );

      final container = makeContainer(
        mockRepo: mockRepo,
        loggedInUser: adminUser,
      );

      await container
          .read(adminProvider.notifier)
          .setAccountStatus(
            targetUserId: 'doc-001',
            isActive: false,
          );

      final state = container.read(adminProvider);
      expect(state.error, isNotNull);
      expect(state.isActionLoading, isFalse);
    });
  });
}
