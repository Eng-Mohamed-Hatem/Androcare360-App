import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/auth/domain/repositories/auth_repository.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/repositories/patient_package_repository.dart';
import 'package:elajtech/features/packages/presentation/providers/my_packages_provider.dart';
import 'package:elajtech/features/packages/presentation/providers/packages_provider.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepo implements AuthRepository {
  /// Returns a future that never completes so that AuthNotifier's
  /// _checkCurrentUser() does not fire a state change that would
  /// invalidate myPackagesProvider mid-build and cause test timeouts.
  @override
  Future<Either<Failure, UserModel>> getCurrentUser() {
    return Completer<Either<Failure, UserModel>>().future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initialState) : super(_FakeAuthRepo()) {
    state = _initialState;
  }
  final AuthState _initialState;

  @override
  Future<void> startPhoneVerification(String p) async {}
}

class _FakePurchasePackageNotifier extends StateNotifier<PurchaseNotifierState>
    implements PurchasePackageNotifier {
  _FakePurchasePackageNotifier() : super(const PurchaseNotifierState());

  @override
  Future<void> purchase(PackageEntity package) async {}

  @override
  void reset() {}
}

class _TrackingPatientPackageRepository implements PatientPackageRepository {
  _TrackingPatientPackageRepository(this.response);

  String? requestedPatientId;
  final List<PatientPackageEntity> response;

  @override
  Future<Either<Failure, List<PatientPackageEntity>>> getPatientPackages({
    required String patientId,
  }) async {
    requestedPatientId = patientId;
    return Right(response);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('uses authenticated user uid to load only that patient packages', () async {
    final repo = _TrackingPatientPackageRepository(const []);
    getIt.registerSingleton<PatientPackageRepository>(repo);

    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(
          (ref) => _FakeAuthNotifier(
            AuthState(
              user: UserModel(
                id: 'patient_uid_123',
                email: 'p@test.com',
                fullName: 'Patient',
                userType: UserType.patient,
                createdAt: DateTime(2026, 3, 13),
              ),
              isAuthenticated: true,
            ),
          ),
        ),
        purchasePackageProvider.overrideWith(
          (ref) => _FakePurchasePackageNotifier(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(myPackagesProvider.future);

    expect(repo.requestedPatientId, 'patient_uid_123');
  });

  test('returns empty list when no authenticated user exists', () async {
    final repo = _TrackingPatientPackageRepository(
      [
        PatientPackageEntity(
          id: 'pp_1',
          patientId: 'other',
          packageId: 'pkg',
          packageName: 'x',
          clinicId: 'andrology',
          category: PackageCategory.andrologyInfertilityProstate,
          status: PatientPackageStatus.active,
          purchaseDate: DateTime(2026, 3, 13),
          expiryDate: DateTime(2026, 4, 13),
          totalServicesCount: 1,
          usedServicesCount: 0,
          createdAt: DateTime(2026, 3, 13),
          updatedAt: DateTime(2026, 3, 13),
        ),
      ],
    );
    getIt.registerSingleton<PatientPackageRepository>(repo);

    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(
          (ref) => _FakeAuthNotifier(AuthState()),
        ),
        purchasePackageProvider.overrideWith(
          (ref) => _FakePurchasePackageNotifier(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(myPackagesProvider.future);

    expect(result, isEmpty);
    expect(repo.requestedPatientId, isNull);
  });
}
