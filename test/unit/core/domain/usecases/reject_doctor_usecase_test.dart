import 'package:dartz/dartz.dart';
import 'package:elajtech/core/data/repositories/admin_approval_repository.dart';
import 'package:elajtech/core/domain/entities/doctor_application_action_result.dart';
import 'package:elajtech/core/domain/entities/pending_doctor_list_item.dart';
import 'package:elajtech/core/domain/usecases/reject_doctor_usecase_impl.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdminApprovalRepository implements AdminApprovalRepository {
  _FakeAdminApprovalRepository({
    required this.rejectResult,
  });

  final Either<Failure, DoctorApplicationActionResult> rejectResult;
  String? rejectedDoctorId;
  String? rejectedByAdminId;
  String? rejectedByAdminName;

  @override
  Future<Either<Failure, DoctorApplicationActionResult>> approveDoctor({
    required String doctorId,
    required String adminId,
    required String adminName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<PendingDoctorListItem>>> getPendingDoctors() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, DoctorApplicationActionResult>> rejectDoctor({
    required String doctorId,
    required String adminId,
    required String adminName,
  }) async {
    rejectedDoctorId = doctorId;
    rejectedByAdminId = adminId;
    rejectedByAdminName = adminName;
    return rejectResult;
  }
}

void main() {
  group('RejectDoctorUseCase', () {
    test('calls repository rejectDoctor with the target doctor id', () async {
      final repository = _FakeAdminApprovalRepository(
        rejectResult: right(
          const DoctorApplicationActionResult(
            status: DoctorApplicationActionStatus.rejected,
            message: 'deleted',
          ),
        ),
      );
      final useCase = RejectDoctorUseCaseImpl(repository);

      final result = await useCase(
        doctorId: 'doctor_123',
        adminId: 'admin_1',
        adminName: 'Admin One',
      );

      expect(result.isRight(), isTrue);
      expect(repository.rejectedDoctorId, 'doctor_123');
      expect(repository.rejectedByAdminId, 'admin_1');
      expect(repository.rejectedByAdminName, 'Admin One');
    });

    test('returns repository failure when rejection fails', () async {
      final repository = _FakeAdminApprovalRepository(
        rejectResult: left(const ServerFailure('delete failed')),
      );
      final useCase = RejectDoctorUseCaseImpl(repository);

      final result = await useCase(
        doctorId: 'doctor_456',
        adminId: 'admin_2',
        adminName: 'Admin Two',
      );

      expect(result.isLeft(), isTrue);
      expect(
        result.fold((failure) => failure.message, (_) => ''),
        'delete failed',
      );
      expect(repository.rejectedDoctorId, 'doctor_456');
    });
  });
}
