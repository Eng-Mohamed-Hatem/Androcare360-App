@TestOn('vm')
library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/data/repositories/admin_approval_repository.dart';
import 'package:elajtech/core/domain/entities/doctor_application_action_result.dart';
import 'package:elajtech/core/domain/entities/pending_doctor_list_item.dart';
import 'package:elajtech/core/domain/usecases/approve_doctor_usecase.dart';
import 'package:elajtech/core/domain/usecases/reject_doctor_usecase.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/core/presentation/providers/admin_approval_provider.dart';
import 'package:elajtech/core/presentation/screens/admin_approval_screen.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/mock_auth_repository.dart';

class _PerformanceAdminApprovalRepository implements AdminApprovalRepository {
  _PerformanceAdminApprovalRepository(this.doctors);

  final List<PendingDoctorListItem> doctors;
  int callCount = 0;

  @override
  Future<Either<Failure, List<PendingDoctorListItem>>> getPendingDoctors() async {
    callCount++;
    return Right(doctors);
  }

  @override
  Future<Either<Failure, DoctorApplicationActionResult>> approveDoctor({
    required String doctorId,
    required String adminId,
    required String adminName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, DoctorApplicationActionResult>> rejectDoctor({
    required String doctorId,
    required String adminId,
    required String adminName,
  }) async {
    throw UnimplementedError();
  }
}

class _NoopApproveDoctorUseCase implements ApproveDoctorUseCase {
  @override
  Future<Either<Failure, DoctorApplicationActionResult>> call({
    required String doctorId,
    required String adminId,
    required String adminName,
  }) async => right(
    const DoctorApplicationActionResult(
      status: DoctorApplicationActionStatus.approved,
      message: 'approved',
    ),
  );
}

class _NoopRejectDoctorUseCase implements RejectDoctorUseCase {
  @override
  Future<Either<Failure, DoctorApplicationActionResult>> call({
    required String doctorId,
    required String adminId,
    required String adminName,
  }) async => right(
    const DoctorApplicationActionResult(
      status: DoctorApplicationActionStatus.rejected,
      message: 'rejected',
    ),
  );
}

void main() {
  const runAdminApprovalPerformanceTests = bool.fromEnvironment(
    'RUN_ADMIN_APPROVAL_PERFORMANCE_TESTS',
  );

  if (!runAdminApprovalPerformanceTests) {
    group('Pending Doctor List Performance Tests', () {
      test(
        'skipped unless RUN_ADMIN_APPROVAL_PERFORMANCE_TESTS=true',
        () {},
        skip: 'Performance-focused UI test; enable explicitly when needed',
      );
    });
    return;
  }

  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pending Doctor List Performance Tests', () {
    testWidgets(
      'loads 150 pending doctors within 3 seconds and remains scrollable',
      (tester) async {
        final repository = _PerformanceAdminApprovalRepository(
          List<PendingDoctorListItem>.generate(
            150,
            (index) => PendingDoctorListItem(
              doctorId: 'doctor_$index',
              fullName: 'Dr Performance $index',
              phoneNumber: '+20123456${index.toString().padLeft(4, '0')}',
              specialty: 'عيادة الأمراض المزمنة',
              createdAt: DateTime(2026, 3, 15, 9, index % 60),
              email: 'doctor_$index@example.com',
            ),
            growable: false,
          ),
        );

        final adminUser = UserModel(
          id: 'admin_perf',
          email: 'admin@example.com',
          fullName: 'Admin Performance',
          userType: UserType.admin,
          createdAt: DateTime(2026, 3, 15),
        );

        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              adminApprovalRepositoryProvider.overrideWithValue(repository),
              approveDoctorUseCaseProvider.overrideWithValue(
                _NoopApproveDoctorUseCase(),
              ),
              rejectDoctorUseCaseProvider.overrideWithValue(
                _NoopRejectDoctorUseCase(),
              ),
              authProvider.overrideWith(
                (ref) =>
                    AuthNotifier(MockAuthRepository(currentUser: adminUser))
                      ..state = AuthState(
                        user: adminUser,
                        isAuthenticated: true,
                      ),
              ),
            ],
            child: MaterialApp(
              theme: ThemeData(useMaterial3: false),
              home: const AdminApprovalScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        stopwatch.stop();

        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 3)));
        expect(repository.callCount, 1);
        expect(find.text('Dr Performance 0'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('Dr Performance 149'),
          400,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        expect(find.text('Dr Performance 149'), findsOneWidget);
      },
    );
  });
}
