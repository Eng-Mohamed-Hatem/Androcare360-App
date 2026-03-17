import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/data/repositories/admin_approval_repository.dart';
import 'package:elajtech/core/domain/entities/doctor_application_action_result.dart';
import 'package:elajtech/core/domain/entities/pending_doctor_list_item.dart';
import 'package:elajtech/core/domain/usecases/approve_doctor_usecase_impl.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFirebaseFunctions extends Fake implements FirebaseFunctions {
  _FakeFirebaseFunctions(this.callable);

  final HttpsCallable callable;
  String? lastCallableName;

  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    lastCallableName = name;
    return callable;
  }
}

class _FakeHttpsCallable extends Fake implements HttpsCallable {
  _FakeHttpsCallable(this.onCall);

  final Future<void> Function(dynamic parameters) onCall;
  dynamic lastParameters;

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    lastParameters = parameters;
    await onCall(parameters);
    return _FakeHttpsCallableResult<T>(null as T);
  }
}

class _FakeHttpsCallableResult<T> extends Fake
    implements HttpsCallableResult<T> {
  _FakeHttpsCallableResult(this._data);

  final T _data;

  @override
  T get data => _data;
}

class _FakeAdminApprovalRepository implements AdminApprovalRepository {
  _FakeAdminApprovalRepository({
    required this.approveResult,
  });

  final Either<Failure, DoctorApplicationActionResult> approveResult;
  String? approvedDoctorId;
  String? approvedByAdminId;
  String? approvedByAdminName;

  @override
  Future<Either<Failure, DoctorApplicationActionResult>> approveDoctor({
    required String doctorId,
    required String adminId,
    required String adminName,
  }) async {
    approvedDoctorId = doctorId;
    approvedByAdminId = adminId;
    approvedByAdminName = adminName;
    return approveResult;
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
  }) {
    throw UnimplementedError();
  }
}

void main() {
  group('ApproveDoctorUseCase', () {
    test('calls repository approveDoctor with the target doctor id', () async {
      final repository = _FakeAdminApprovalRepository(
        approveResult: right(
          const DoctorApplicationActionResult(
            status: DoctorApplicationActionStatus.approved,
            message: 'ok',
          ),
        ),
      );
      final useCase = ApproveDoctorUseCaseImpl(
        repository,
        _FakeFirebaseFunctions(_FakeHttpsCallable((_) async {})),
      );

      final result = await useCase(
        doctorId: 'doctor_123',
        adminId: 'admin_1',
        adminName: 'Admin One',
      );

      expect(result.isRight(), isTrue);
      expect(repository.approvedDoctorId, 'doctor_123');
      expect(repository.approvedByAdminId, 'admin_1');
      expect(repository.approvedByAdminName, 'Admin One');
    });

    test('returns repository failure when approval fails', () async {
      final repository = _FakeAdminApprovalRepository(
        approveResult: left(const ServerFailure('approval failed')),
      );
      final useCase = ApproveDoctorUseCaseImpl(
        repository,
        _FakeFirebaseFunctions(_FakeHttpsCallable((_) async {})),
      );

      final result = await useCase(
        doctorId: 'doctor_456',
        adminId: 'admin_2',
        adminName: 'Admin Two',
      );

      expect(result.isLeft(), isTrue);
      expect(
        result.fold((failure) => failure.message, (_) => ''),
        'approval failed',
      );
      expect(repository.approvedDoctorId, 'doctor_456');
    });

    test('triggers doctor approval email after successful approval', () async {
      final repository = _FakeAdminApprovalRepository(
        approveResult: right(
          const DoctorApplicationActionResult(
            status: DoctorApplicationActionStatus.approved,
            message: 'approved',
          ),
        ),
      );
      final callable = _FakeHttpsCallable((_) async {});
      final functions = _FakeFirebaseFunctions(callable);
      final useCase = ApproveDoctorUseCaseImpl(repository, functions);

      final result = await useCase(
        doctorId: 'doctor_789',
        adminId: 'admin_3',
        adminName: 'Admin Three',
      );

      expect(result.isRight(), isTrue);
      expect(functions.lastCallableName, 'sendDoctorApprovalEmail');
      expect(callable.lastParameters, {'doctorId': 'doctor_789'});
    });

    test('does not fail approval when doctor approval email throws', () async {
      final repository = _FakeAdminApprovalRepository(
        approveResult: right(
          const DoctorApplicationActionResult(
            status: DoctorApplicationActionStatus.approved,
            message: 'approved',
          ),
        ),
      );
      final callable = _FakeHttpsCallable((_) async {
        throw FirebaseFunctionsException(
          code: 'internal',
          message: 'mail failed',
        );
      });
      final functions = _FakeFirebaseFunctions(callable);
      final useCase = ApproveDoctorUseCaseImpl(repository, functions);

      final result = await useCase(
        doctorId: 'doctor_999',
        adminId: 'admin_4',
        adminName: 'Admin Four',
      );

      expect(result.isRight(), isTrue);
      expect(functions.lastCallableName, 'sendDoctorApprovalEmail');
    });
  });
}
