import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/admin/domain/repositories/admin_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for toggling the active status (enabled/disabled) of a user account.
///
/// **English**: Wraps the repository call to enable or disable a user account
/// and logs the action to audit logs server-side via Cloud Functions.
///
/// **Arabic**: تغيير حالة تفعيل الحساب (تفعيل/تعطيل).
@lazySingleton
class TogglePatientActiveStatusUseCase {
  TogglePatientActiveStatusUseCase(this._repository);

  final AdminRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String targetUserId,
    required bool isActive,
    required String adminId,
    required String adminName,
  }) async {
    return _repository.setAccountStatus(
      targetUserId: targetUserId,
      isActive: isActive,
      adminId: adminId,
      adminName: adminName,
    );
  }
}
