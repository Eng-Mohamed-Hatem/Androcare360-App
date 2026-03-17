import 'package:dartz/dartz.dart';
import 'package:elajtech/core/domain/entities/doctor_application_action_result.dart';
import 'package:elajtech/core/domain/entities/pending_doctor_list_item.dart';
import 'package:elajtech/core/domain/usecases/approve_doctor_usecase.dart';
import 'package:elajtech/core/domain/usecases/get_pending_doctors_usecase.dart';
import 'package:elajtech/core/domain/usecases/reject_doctor_usecase.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/core/presentation/providers/admin_approval_provider.dart';
import 'package:elajtech/core/presentation/screens/admin_approval_screen.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../mocks/mock_auth_repository.dart';

class _FakeGetPendingDoctorsUseCase implements GetPendingDoctorsUseCase {
  _FakeGetPendingDoctorsUseCase(this.result);

  final Either<Failure, List<PendingDoctorListItem>> result;
  int callCount = 0;

  @override
  Future<Either<Failure, List<PendingDoctorListItem>>> call() async {
    callCount++;
    return result;
  }
}

class _FakeApproveDoctorUseCase implements ApproveDoctorUseCase {
  _FakeApproveDoctorUseCase(this.result);

  final Either<Failure, DoctorApplicationActionResult> result;
  String? approvedDoctorId;
  String? approvedByAdminId;
  String? approvedByAdminName;

  @override
  Future<Either<Failure, DoctorApplicationActionResult>> call({
    required String doctorId,
    required String adminId,
    required String adminName,
  }) async {
    approvedDoctorId = doctorId;
    approvedByAdminId = adminId;
    approvedByAdminName = adminName;
    return result;
  }
}

class _FakeRejectDoctorUseCase implements RejectDoctorUseCase {
  _FakeRejectDoctorUseCase(this.result);

  final Either<Failure, DoctorApplicationActionResult> result;
  String? rejectedDoctorId;
  String? rejectedByAdminId;
  String? rejectedByAdminName;

  @override
  Future<Either<Failure, DoctorApplicationActionResult>> call({
    required String doctorId,
    required String adminId,
    required String adminName,
  }) async {
    rejectedDoctorId = doctorId;
    rejectedByAdminId = adminId;
    rejectedByAdminName = adminName;
    return result;
  }
}

UserModel _adminUser() {
  return UserModel(
    id: 'admin_1',
    email: 'admin@example.com',
    fullName: 'System Admin',
    userType: UserType.admin,
    createdAt: DateTime(2026, 3, 15),
  );
}

PendingDoctorListItem _pendingDoctor({
  required String id,
  required String name,
}) {
  return PendingDoctorListItem(
    doctorId: id,
    fullName: name,
    phoneNumber: '+201234567890',
    specialty: 'عيادة الأمراض المزمنة',
    createdAt: DateTime(2026, 3, 14, 10, 30),
    email: '$id@example.com',
  );
}

Widget _buildWidget({
  required GetPendingDoctorsUseCase getPendingDoctorsUseCase,
  required ApproveDoctorUseCase approveDoctorUseCase,
  required RejectDoctorUseCase rejectDoctorUseCase,
  UserModel? currentUser,
}) {
  final user = currentUser ?? _adminUser();

  return ProviderScope(
    overrides: [
      getPendingDoctorsUseCaseProvider.overrideWithValue(
        getPendingDoctorsUseCase,
      ),
      approveDoctorUseCaseProvider.overrideWithValue(approveDoctorUseCase),
      rejectDoctorUseCaseProvider.overrideWithValue(rejectDoctorUseCase),
      authProvider.overrideWith(
        (ref) =>
            AuthNotifier(MockAuthRepository(currentUser: user))
              ..state = AuthState(
                user: user,
                isAuthenticated: true,
              ),
      ),
    ],
    child: MaterialApp(
      theme: ThemeData(useMaterial3: false),
      home: AdminApprovalScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdminApprovalScreen', () {
    testWidgets('shows pending doctors with approve and reject actions', (
      tester,
    ) async {
      final getPendingDoctorsUseCase = _FakeGetPendingDoctorsUseCase(
        right([
          _pendingDoctor(id: 'doctor_1', name: 'Dr. Ahmed Ali'),
          _pendingDoctor(id: 'doctor_2', name: 'Dr. Sara Hassan'),
        ]),
      );

      await tester.pumpWidget(
        _buildWidget(
          getPendingDoctorsUseCase: getPendingDoctorsUseCase,
          approveDoctorUseCase: _FakeApproveDoctorUseCase(
            right(
              const DoctorApplicationActionResult(
                status: DoctorApplicationActionStatus.approved,
                message: 'تمت الموافقة على الطبيب بنجاح.',
              ),
            ),
          ),
          rejectDoctorUseCase: _FakeRejectDoctorUseCase(
            right(
              const DoctorApplicationActionResult(
                status: DoctorApplicationActionStatus.rejected,
                message: 'تم رفض الطبيب وحذف الطلب.',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dr. Ahmed Ali'), findsOneWidget);
      expect(find.text('Dr. Sara Hassan'), findsOneWidget);
      expect(find.text('موافقة'), findsNWidgets(2));
      expect(find.text('رفض'), findsNWidgets(2));
      expect(getPendingDoctorsUseCase.callCount, 1);
    });

    testWidgets('approves a doctor and removes it from the pending list', (
      tester,
    ) async {
      final approveDoctorUseCase = _FakeApproveDoctorUseCase(
        right(
          const DoctorApplicationActionResult(
            status: DoctorApplicationActionStatus.approved,
            message: 'تمت الموافقة على الطبيب بنجاح.',
          ),
        ),
      );

      await tester.pumpWidget(
        _buildWidget(
          getPendingDoctorsUseCase: _FakeGetPendingDoctorsUseCase(
            right([
              _pendingDoctor(id: 'doctor_1', name: 'Dr. Ahmed Ali'),
            ]),
          ),
          approveDoctorUseCase: approveDoctorUseCase,
          rejectDoctorUseCase: _FakeRejectDoctorUseCase(
            right(
              const DoctorApplicationActionResult(
                status: DoctorApplicationActionStatus.rejected,
                message: 'تم رفض الطبيب وحذف الطلب.',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('موافقة'));
      await tester.pumpAndSettle();

      expect(approveDoctorUseCase.approvedDoctorId, 'doctor_1');
      expect(approveDoctorUseCase.approvedByAdminId, 'admin_1');
      expect(find.text('Dr. Ahmed Ali'), findsNothing);
      expect(find.text('تمت الموافقة على الطبيب بنجاح.'), findsOneWidget);
    });

    testWidgets(
      'rejects a doctor after confirmation and removes it from the list',
      (
        tester,
      ) async {
        final rejectDoctorUseCase = _FakeRejectDoctorUseCase(
          right(
            const DoctorApplicationActionResult(
              status: DoctorApplicationActionStatus.rejected,
              message: 'تم رفض الطبيب وحذف الطلب.',
            ),
          ),
        );

        await tester.pumpWidget(
          _buildWidget(
            getPendingDoctorsUseCase: _FakeGetPendingDoctorsUseCase(
              right([
                _pendingDoctor(id: 'doctor_1', name: 'Dr. Ahmed Ali'),
              ]),
            ),
            approveDoctorUseCase: _FakeApproveDoctorUseCase(
              right(
                const DoctorApplicationActionResult(
                  status: DoctorApplicationActionStatus.approved,
                  message: 'تمت الموافقة على الطبيب بنجاح.',
                ),
              ),
            ),
            rejectDoctorUseCase: rejectDoctorUseCase,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('رفض'));
        await tester.pumpAndSettle();
        expect(
          find.text(
            'هل أنت متأكد من رفض هذا الطبيب؟ سيتم حذف الطلب من النظام.',
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('رفض').last);
        await tester.pumpAndSettle();

        expect(rejectDoctorUseCase.rejectedDoctorId, 'doctor_1');
        expect(rejectDoctorUseCase.rejectedByAdminId, 'admin_1');
        expect(find.text('Dr. Ahmed Ali'), findsNothing);
        expect(find.text('تم رفض الطبيب وحذف الطلب.'), findsOneWidget);
      },
    );

    testWidgets('shows admin-only guard for non-admin users', (tester) async {
      final patient = UserModel(
        id: 'patient_1',
        email: 'patient@example.com',
        fullName: 'Patient User',
        userType: UserType.patient,
        createdAt: DateTime(2026, 3, 15),
      );

      await tester.pumpWidget(
        _buildWidget(
          currentUser: patient,
          getPendingDoctorsUseCase: _FakeGetPendingDoctorsUseCase(
            right(const []),
          ),
          approveDoctorUseCase: _FakeApproveDoctorUseCase(
            right(
              const DoctorApplicationActionResult(
                status: DoctorApplicationActionStatus.approved,
                message: 'تمت الموافقة على الطبيب بنجاح.',
              ),
            ),
          ),
          rejectDoctorUseCase: _FakeRejectDoctorUseCase(
            right(
              const DoctorApplicationActionResult(
                status: DoctorApplicationActionStatus.rejected,
                message: 'تم رفض الطبيب وحذف الطلب.',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('هذه الشاشة متاحة للمسؤول فقط.'), findsOneWidget);
    });
  });
}
