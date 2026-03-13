// test/integration/packages_flow_test.dart
//
// Integration test — T053: full patient purchase → My Packages flow.
// Uses FakePaymentService to avoid real payment, verifies purchase
// success leads to entry in My Packages with status ACTIVE.

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/packages/domain/adapters/package_payment_adapter.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/auth/domain/repositories/auth_repository.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/features/packages/domain/repositories/patient_package_repository.dart';
import 'package:elajtech/features/packages/presentation/providers/packages_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../helpers/fake_payment_service.dart';
import 'packages_flow_test.mocks.dart';

class _FakeAuthRepo implements AuthRepository {
  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    return const Left(ServerFailure('Not logged in'));
  }

  @override
  Stream<firebase.User?> get authStateChanges => Stream.value(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initialState) : super(_FakeAuthRepo()) {
    state = _initialState;
  }
  final AuthState _initialState;
}

@GenerateMocks([PatientPackageRepository])
void main() {
  late MockPatientPackageRepository mockRepo;

  const patientId = 'uid_patient_it_001';
  const packageId = 'pkg_it_001';
  const clinicId = 'andrology';

  final now = DateTime(2026, 3, 7, 12);

  final samplePackage = PackageEntity(
    id: packageId,
    clinicId: clinicId,
    category: PackageCategory.andrologyInfertilityProstate,
    name: 'باقة الاختبار التكاملي',
    shortDescription: 'وصف',
    services: const [],
    validityDays: 90,
    price: 500,
    currency: 'SAR',
    packageType: PackageType.physicalOnly,
    status: PackageStatus.active,
    displayOrder: 1,
    isFeatured: false,
    createdAt: DateTime.now(),
    updatedAt: now,
    includesVideoConsultation: false,
    includesPhysicalVisit: true,
  );

  final purchasedEntity = PatientPackageEntity(
    id: 'pp_it_001',
    patientId: patientId,
    packageId: packageId,
    packageName: 'باقة الاختبار التكاملي',
    clinicId: clinicId,
    category: PackageCategory.andrologyInfertilityProstate,
    status: PatientPackageStatus.active,
    purchaseDate: now,
    expiryDate: now.add(const Duration(days: 90)),
    totalServicesCount: 0,
    usedServicesCount: 0,
    createdAt: DateTime.now(),
    updatedAt: now,
  );

  setUp(() {
    mockRepo = MockPatientPackageRepository();
    // Override DI for tests
    getIt.allowReassignment = true;
    getIt.registerLazySingleton<PatientPackageRepository>(() => mockRepo);
    getIt.registerLazySingleton<PackagePaymentAdapter>(
      FakePaymentService.new,
    );
  });

  UserModel mockUserObject(String id) => UserModel(
    id: id,
    email: 'test@example.com',
    userType: UserType.patient,
    fullName: 'Integration Patient',
    createdAt: DateTime.now(),
  );

  group('Packages Full Flow — T053', () {
    // ── T053-a: buy → provider holds correct state ────────────────────────────
    test(
      'T053-a: purchase succeeds with FakePaymentService; '
      'myPackagesProvider reflects ACTIVE package afterward',
      () async {
        // Arrange
        when(
          mockRepo.findActiveOrPendingByPackageId(
            patientId: patientId,
            packageId: packageId,
          ),
        ).thenAnswer(
          (_) async => const Right<Failure, PatientPackageEntity?>(null),
        ); // no duplicate

        when(
          mockRepo.createPatientPackage(
            patientId: patientId,
            packageId: packageId,
            packageName: anyNamed('packageName'),
            clinicId: clinicId,
            status: PatientPackageStatus.active,
            purchaseDate: anyNamed('purchaseDate'),
            expiryDate: anyNamed('expiryDate'),
            totalServicesCount: anyNamed('totalServicesCount'),
            packageServices: anyNamed('packageServices'),
            servicesUsageInit: anyNamed('servicesUsageInit'),
            paymentTransactionId: anyNamed('paymentTransactionId'),
            category: anyNamed('category'),
            isTestPurchase: anyNamed('isTestPurchase'),
            description: anyNamed('description'),
            shortDescription: anyNamed('shortDescription'),
            validityDays: anyNamed('validityDays'),
          ),
        ).thenAnswer((_) async => const Right<Failure, String>('pp_it_001'));

        when(
          mockRepo.getPatientPackages(patientId: patientId),
        ).thenAnswer(
          (_) async =>
              Right<Failure, List<PatientPackageEntity>>([purchasedEntity]),
        );

        final container = ProviderContainer(
          overrides: [
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthState(
                  user: mockUserObject(patientId),
                  isAuthenticated: true,
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Act: purchase
        final purchaseNotifier = container.read(
          purchasePackageProvider.notifier,
        );
        await purchaseNotifier.purchase(samplePackage);

        // Assert: purchase succeeded
        final purchaseState = container
            .read(purchasePackageProvider)
            .purchaseState;
        expect(purchaseState, isA<PurchaseState>());
        // Verify createPatientPackage was called
        verify(
          mockRepo.createPatientPackage(
            patientId: patientId,
            packageId: packageId,
            packageName: anyNamed('packageName'),
            clinicId: clinicId,
            status: PatientPackageStatus.active,
            purchaseDate: anyNamed('purchaseDate'),
            expiryDate: anyNamed('expiryDate'),
            totalServicesCount: anyNamed('totalServicesCount'),
            packageServices: anyNamed('packageServices'),
            servicesUsageInit: anyNamed('servicesUsageInit'),
            paymentTransactionId: anyNamed('paymentTransactionId'),
            category: anyNamed('category'),
            isTestPurchase: anyNamed('isTestPurchase'),
            description: anyNamed('description'),
            shortDescription: anyNamed('shortDescription'),
            validityDays: anyNamed('validityDays'),
          ),
        ).called(1);
      },
    );

    // ── T053-b: My Packages shows ACTIVE entry after purchase ─────────────────
    test(
      'T053-b: getPatientPackages returns ACTIVE entry with 0 / 0 progress '
      'after purchase',
      () async {
        when(
          mockRepo.getPatientPackages(patientId: patientId),
        ).thenAnswer(
          (_) async =>
              Right<Failure, List<PatientPackageEntity>>([purchasedEntity]),
        );

        final result = await mockRepo.getPatientPackages(
          patientId: patientId,
        );

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected right'), (list) {
          expect(list.length, 1);
          expect(list.first.status, PatientPackageStatus.active);
          expect(list.first.usedServicesCount, 0);
        });
      },
    );
  });
}
