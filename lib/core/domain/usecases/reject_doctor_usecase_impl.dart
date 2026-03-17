import 'package:dartz/dartz.dart';
import 'package:elajtech/core/data/repositories/admin_approval_repository.dart';
import 'package:elajtech/core/domain/entities/doctor_application_action_result.dart';
import 'package:elajtech/core/domain/usecases/reject_doctor_usecase.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Reject Doctor Use Case implementation
///
/// This use case handles rejecting pending doctor registrations.
/// It permanently deletes the doctor's user document and all
/// related registration data.
///
/// **Arabic**: حالة استخدام رفض الأطباء
/// **English**: Use case implementation for rejecting doctor registrations
///
/// **Business Rules:**
/// - Only admins can reject doctors (role-based access control)
/// - Rejected doctors are permanently deleted from Firestore
/// - Rejected doctors cannot log in or access the system
/// - Rejected doctors must register again as new users
/// - All operations are logged in debug mode
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final useCase = getIt<RejectDoctorUseCase>();
/// ```
///
/// **Usage Example:**
/// ```dart
/// final useCase = getIt<RejectDoctorUseCase>();
/// final result = await useCase.call('doctor_123');
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showRejectionSuccess(),
/// );
/// ```
@LazySingleton(as: RejectDoctorUseCase)
class RejectDoctorUseCaseImpl implements RejectDoctorUseCase {
  /// Creates a RejectDoctorUseCaseImpl instance with injected dependencies.
  ///
  /// Parameters:
  /// - [_repository]: Admin approval repository
  RejectDoctorUseCaseImpl(
    this._repository,
  );

  /// Admin approval repository
  final AdminApprovalRepository _repository;

  @override
  Future<Either<Failure, DoctorApplicationActionResult>> call({
    required String doctorId,
    required String adminId,
    required String adminName,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '📲 [RejectDoctorUseCase] Rejecting doctor: $doctorId',
      );
    }

    final result = await _repository.rejectDoctor(
      doctorId: doctorId,
      adminId: adminId,
      adminName: adminName,
    );

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint(
            '❌ [RejectDoctorUseCase] Rejection failed: ${failure.message}',
          );
        }
      },
      (actionResult) {
        if (kDebugMode) {
          debugPrint(
            '✅ [RejectDoctorUseCase] Result: ${actionResult.status.name}',
          );
        }
      },
    );

    return result;
  }
}
