import 'package:dartz/dartz.dart';
import 'package:elajtech/core/data/repositories/admin_approval_repository.dart';
import 'package:elajtech/core/domain/entities/pending_doctor_list_item.dart';
import 'package:elajtech/core/domain/usecases/get_pending_doctors_usecase.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Get Pending Doctors Use Case implementation
///
/// This use case retrieves all pending doctor registrations
/// that are awaiting admin approval. It returns a list of
/// simplified doctor items for the admin UI.
///
/// **Arabic**: حالة استخدام جلب الأطباء المعلقين
/// **English**: Use case implementation for retrieving pending doctors
///
/// **Business Rules:**
/// - Only admins can view pending doctors (role-based access control)
/// - Returns doctors where userType='doctor' and isApproved=false
/// - Results are ordered by createdAt (newest first)
/// - Returns simplified PendingDoctorListItem view model
/// - All operations are logged in debug mode
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final useCase = getIt<GetPendingDoctorsUseCase>();
/// ```
///
/// **Usage Example:**
/// ```dart
/// final useCase = getIt<GetPendingDoctorsUseCase>();
/// final result = await useCase.call();
/// result.fold(
///   (failure) => showError(failure.message),
///   (doctors) => displayPendingDoctors(doctors),
/// );
/// ```
@LazySingleton(as: GetPendingDoctorsUseCase)
class GetPendingDoctorsUseCaseImpl implements GetPendingDoctorsUseCase {
  /// Creates a GetPendingDoctorsUseCaseImpl instance with injected dependencies.
  ///
  /// Parameters:
  /// - [_repository]: Admin approval repository
  GetPendingDoctorsUseCaseImpl(
    this._repository,
  );

  /// Admin approval repository
  final AdminApprovalRepository _repository;

  @override
  Future<Either<Failure, List<PendingDoctorListItem>>> call() async {
    if (kDebugMode) {
      debugPrint(
        '📲 [GetPendingDoctorsUseCase] Fetching pending doctors',
      );
    }

    final result = await _repository.getPendingDoctors();

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint(
            '❌ [GetPendingDoctorsUseCase] Fetch failed: ${failure.message}',
          );
        }
      },
      (doctors) {
        if (kDebugMode) {
          debugPrint(
            '✅ [GetPendingDoctorsUseCase] Found ${doctors.length} pending doctors',
          );
        }
      },
    );

    return result;
  }
}
