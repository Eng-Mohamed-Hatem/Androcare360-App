import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/data/repositories/admin_approval_repository.dart';
import 'package:elajtech/core/domain/entities/doctor_application_action_result.dart';
import 'package:elajtech/core/domain/usecases/approve_doctor_usecase.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Approve Doctor Use Case implementation
///
/// This use case handles approving pending doctor registrations.
/// It updates the doctor's status to active and approved,
/// sets the approval timestamp, and triggers an email notification.
///
/// **Arabic**: حالة استخدام موافقة الأطباء مع تشغيل بريد التفعيل للطبيب.
/// **English**: Use case implementation for approving doctor registrations and triggering doctor email.
///
/// **Business Rules:**
/// - Only admins can approve doctors (role-based access control)
/// - Approved doctors become visible to patients
/// - Approved doctors can log in and access dashboard
/// - Cloud Functions calls use region `europe-west1`
/// - Email notification is non-blocking and logged on failure
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final useCase = getIt<ApproveDoctorUseCase>();
/// ```
///
/// **Usage Example:**
/// ```dart
/// final useCase = getIt<ApproveDoctorUseCase>();
/// final result = await useCase.call('doctor_123');
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showApprovalSuccess(),
/// );
/// ```
@LazySingleton(as: ApproveDoctorUseCase)
class ApproveDoctorUseCaseImpl implements ApproveDoctorUseCase {
  /// Creates an ApproveDoctorUseCaseImpl instance with injected dependencies.
  ApproveDoctorUseCaseImpl(
    this._repository,
    this._functions,
  );

  /// Admin approval repository
  final AdminApprovalRepository _repository;

  /// Firebase Functions instance configured for europe-west1.
  final FirebaseFunctions _functions;

  @override
  Future<Either<Failure, DoctorApplicationActionResult>> call({
    required String doctorId,
    required String adminId,
    required String adminName,
  }) async {
    if (kDebugMode) {
      debugPrint('📲 [ApproveDoctorUseCase] Approving doctor: $doctorId');
    }

    final repositoryResult = await _repository.approveDoctor(
      doctorId: doctorId,
      adminId: adminId,
      adminName: adminName,
    );

    if (repositoryResult.isLeft()) {
      final failure = repositoryResult.swap().getOrElse(() {
        return const ServerFailure('Unknown approval failure');
      });
      if (kDebugMode) {
        debugPrint(
          '❌ [ApproveDoctorUseCase] Approval failed: ${failure.message}',
        );
      }
      return Left(failure);
    }

    final actionResult = repositoryResult.getOrElse(
      () => const DoctorApplicationActionResult(
        status: DoctorApplicationActionStatus.alreadyRejected,
        message: 'Unexpected approval result',
      ),
    );

    if (kDebugMode) {
      debugPrint(
        '✅ [ApproveDoctorUseCase] Approval result: ${actionResult.status.name}',
      );
    }

    if (actionResult.status != DoctorApplicationActionStatus.approved) {
      return Right(actionResult);
    }

    try {
      if (kDebugMode) {
        debugPrint(
          '[ApproveDoctorUseCase] Calling sendDoctorApprovalEmail',
        );
        debugPrint('  - functionName: sendDoctorApprovalEmail');
        debugPrint('  - userId: $doctorId');
        debugPrint('  - patientId: N/A');
        debugPrint('  - appointmentId: N/A');
        debugPrint('  - permissionsState: approved_active');
      }

      await _functions.httpsCallable('sendDoctorApprovalEmail').call<void>({
        'doctorId': doctorId,
      });
    } on FirebaseFunctionsException catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [ApproveDoctorUseCase] sendDoctorApprovalEmail failed: $error',
        );
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    return Right(actionResult);
  }
}
