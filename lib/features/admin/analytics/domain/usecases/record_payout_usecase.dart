import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/repositories/payout_export_repository.dart';
import 'package:injectable/injectable.dart';

/// حالة استخدام تسجيل صرف المستحقات — records a payout disbursement (admin-only).
@lazySingleton
class RecordPayoutUseCase {
  const RecordPayoutUseCase(this._repository);

  final PayoutExportRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String doctorId,
    required double amount,
    String? note,
  }) => _repository.recordPayout(
    doctorId: doctorId,
    amount: amount,
    note: note,
  );
}
