import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart';
import 'package:injectable/injectable.dart';

/// Parameters for updating a clinic package.
class UpdatePackageParams {
  const UpdatePackageParams({
    required this.clinicId,
    required this.packageId,
    required this.loadedAt,
    required this.category,
    required this.name,
    required this.shortDescription,
    this.description,
    required this.services,
    required this.validityDays,
    this.termsAndConditions,
    required this.price,
    required this.currency,
    this.discountPercentage,
    required this.type,
    required this.status,
    required this.displayOrder,
    required this.isFeatured,
  });
  final String clinicId;
  final String packageId;
  final DateTime? loadedAt; // REQUIRED parameter (R1)
  final PackageCategory category;
  final String name;
  final String shortDescription;
  final String? description;
  final List<PackageServiceItem> services;
  final int validityDays;
  final String? termsAndConditions;
  final double price;
  final String currency;
  final double? discountPercentage;
  final PackageType type;
  final PackageStatus status;
  final int displayOrder;
  final bool isFeatured;
}

/// Use case for updating a clinic package.
///
/// **English**: Validates optimistic concurrency (loadedAt), validates fields,
/// recomputes derived booleans, and saves via repository.
///
/// **Arabic**: يتحقق من التعديل المتزامن وصحة الحقول قبل التحديث.
@lazySingleton
class UpdateClinicPackageUseCase {
  UpdateClinicPackageUseCase();

  Future<Either<Failure, Unit>> call({
    required PackageRepository repository,
    required UpdatePackageParams params,
  }) async {
    // 1. (R1) Optimistic Concurrency check - early exit
    if (params.loadedAt == null) {
      return const Left(StaleDataFailure());
    }

    // 2. Read current updatedAt from Firestore
    final currentEntityOr = await repository.getPackageById(
      clinicId: params.clinicId,
      packageId: params.packageId,
    );

    return currentEntityOr.fold(
      Left.new,
      (currentEntity) async {
        // 3. Compare updatedAt safely
        if (!currentEntity.updatedAt.isAtSameMomentAs(params.loadedAt!)) {
          return const Left(StaleDataFailure());
        }

        // 4. Validate fields
        final trimmedName = params.name.trim();
        if (trimmedName.isEmpty || trimmedName.length > 200) {
          return const Left(
            ServerFailure('الاسم مطلوب ولا يمكن أن يتجاوز 200 حرف.'),
          );
        }
        final trimmedShortDesc = params.shortDescription.trim();
        if (trimmedShortDesc.isEmpty || trimmedShortDesc.length > 500) {
          return const Left(
            ServerFailure('الوصف المختصر مطلوب ولا يمكن أن يتجاوز 500 حرف.'),
          );
        }
        if (params.description != null && params.description!.length > 3000) {
          return const Left(
            ServerFailure('الوصف التفصيلي لا يمكن أن يتجاوز 3000 حرف.'),
          );
        }
        if (params.services.isEmpty || params.services.length > 30) {
          return const Left(
            ServerFailure('يجب إضافة خدمة واحدة على الأقل، وبحد أقصى 30 خدمة.'),
          );
        }
        for (final s in params.services) {
          if (s.displayName.trim().isEmpty ||
              s.displayName.trim().length > 200) {
            return const Left(
              ServerFailure('اسم الخدمة مطلوب ولا يمكن أن يتجاوز 200 حرف.'),
            );
          }
        }
        if (params.validityDays < 1 || params.validityDays > 3650) {
          return const Left(
            ServerFailure('مدة الصلاحية يجب أن تكون بين يوم و 3650 يوم.'),
          );
        }
        if (params.price <= 0 || params.price > 999999.99) {
          return const Left(
            ServerFailure('السعر يجب أن يكون أكبر من صفر وأقل من 999999.99'),
          );
        }
        if (params.discountPercentage != null &&
            (params.discountPercentage! < 0 ||
                params.discountPercentage! > 99.99)) {
          return const Left(
            ServerFailure('نسبة الخصم يجب أن تكون بين 0 و 99.99'),
          );
        }
        if (params.displayOrder < 1) {
          return const Left(
            ServerFailure('ترتيب العرض يجب أن يكون 1 أو أكثر.'),
          );
        }
        if (params.currency != 'EGP') {
          return const Left(ServerFailure('العملة يجب أن تكون EGP'));
        }

        // 5. Update Entity
        final updatedEntity = PackageEntity.fromType(
          id: params.packageId,
          clinicId: params.clinicId,
          category: params.category,
          name: trimmedName,
          shortDescription: trimmedShortDesc,
          description: params.description?.trim(),
          services: params.services,
          validityDays: params.validityDays,
          price: params.price,
          currency: params.currency,
          type: params.type,
          status: params.status,
          displayOrder: params.displayOrder,
          isFeatured: params.isFeatured,
          createdAt: currentEntity.createdAt, // Preserve original
          updatedAt: DateTime.now(), // New updatedAt
          termsAndConditions: params.termsAndConditions?.trim(),
          discountPercentage: params.discountPercentage,
        );

        // 6. Write
        return repository.updatePackage(updatedEntity);
      },
    );
  }
}
