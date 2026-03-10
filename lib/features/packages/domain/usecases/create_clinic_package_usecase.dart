import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:elajtech/core/auth/clinic_access_resolver.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/core/constants/currency_constants.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart';
import 'package:injectable/injectable.dart';

/// Parameters for creating a new clinic package.
class CreatePackageParams {
  const CreatePackageParams({
    required this.clinicId,
    required this.category,
    required this.name,
    required this.shortDescription,
    required this.services,
    required this.validityDays,
    required this.price,
    required this.currency,
    required this.type,
    required this.status,
    required this.isFeatured,
    this.description,
    this.termsAndConditions,
    this.discountPercentage,
    this.displayOrder,
  });
  final String clinicId;
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
  final int? displayOrder;
  final bool isFeatured;
}

/// Use case for creating a clinic package.
///
/// **English**: Validates fields, computes derived booleans, computes displayOrder,
/// and saves via repository. Only allowed if user has access to clinic.
///
/// **Arabic**: يتحقق من الحقول والصلاحيات قبل إنشاء باقة عيادة جديدة.
@lazySingleton
class CreateClinicPackageUseCase {
  CreateClinicPackageUseCase(this._accessResolver);

  final ClinicAccessResolver _accessResolver;

  Future<Either<Failure, String>> call({
    required PackageRepository repository,
    required CreatePackageParams params,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[CreateClinicPackageUseCase] Triggered for clinic: ${params.clinicId}',
      );
    }

    // 1. Check clinic access
    final allowed = await _accessResolver.getAllowedClinics();
    if (!allowed.contains(params.clinicId)) {
      if (kDebugMode) {
        debugPrint(
          '[CreateClinicPackageUseCase] ACCESS DENIED: ${params.clinicId} not in $allowed',
        );
      }
      return const Left(
        ClinicUnavailableFailure('ليس لديك صلاحية لإضافة باقة في هذه العيادة.'),
      );
    }

    // 2. Validate fields per data-model.md §3.2
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
      if (s.displayName.trim().isEmpty || s.displayName.trim().length > 200) {
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
      return const Left(ServerFailure('نسبة الخصم يجب أن تكون بين 0 و 99.99'));
    }
    if (params.displayOrder != null && params.displayOrder! < 1) {
      return const Left(ServerFailure('ترتيب العرض يجب أن يكون 1 أو أكثر.'));
    }
    if (params.currency != CurrencyConstants.defaultCurrency) {
      return const Left(
        ServerFailure(
          'العملة يجب أن تكون ${CurrencyConstants.defaultCurrency}',
        ),
      );
    }

    // 3. Compute displayOrder default (last+1)
    var order = params.displayOrder ?? 1;
    if (params.displayOrder == null) {
      final packagesEither = await repository.listClinicPackagesForAdmin(
        clinicId: params.clinicId,
        limit: 100, // get a batch to find max
      );
      packagesEither.fold(
        (l) {}, // ignore failure, keep default 1
        (packages) {
          final categoryPackages = packages.where(
            (p) => p.category == params.category,
          );
          if (categoryPackages.isNotEmpty) {
            final maxOrder = categoryPackages
                .map((p) => p.displayOrder)
                .reduce((a, b) => a > b ? a : b);
            order = maxOrder + 1;
          }
        },
      );
    }

    // 4. Create entity
    // The model layer uses serverTimestamp() during serialization for updatedAt
    // but we pass DateTime.now() to satisfy the entity.
    final now = DateTime.now();
    final entity = PackageEntity.fromType(
      id: '', // Empty ID, repository will auto-generate
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
      displayOrder: order,
      isFeatured: params.isFeatured,
      createdAt: now,
      updatedAt: now,
      termsAndConditions: params.termsAndConditions?.trim(),
      discountPercentage: params.discountPercentage,
    );

    // 5. Write
    return repository.createPackage(entity);
  }
}
