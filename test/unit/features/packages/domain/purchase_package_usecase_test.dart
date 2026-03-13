// test/unit/features/packages/domain/purchase_package_usecase_test.dart
//
// Unit tests for [PurchasePackageUseCase].
// Uses MockPaymentService implementing PackagePaymentAdapter (R6).
// Covers: happy path, duplicate guard (ACTIVE & PENDING), EXPIRED/COMPLETED
// → new purchase allowed, PaymentFailure, NetworkFailure.

import 'package:dartz/dartz.dart';

import 'package:elajtech/features/packages/domain/adapters/package_payment_adapter.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/patient_package_repository.dart';
import 'package:elajtech/features/packages/domain/usecases/purchase_package_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'purchase_package_usecase_test.mocks.dart';

@GenerateMocks([PatientPackageRepository, PackagePaymentAdapter])
void main() {
  late MockPatientPackageRepository mockPatientPackageRepo;
  late MockPackagePaymentAdapter mockPaymentAdapter;
  late PurchasePackageUseCase useCase;

  const patientId = 'uid_patient_001';
  const packageId = 'pkg_001';
  const clinicId = 'andrology';
  const txnId = 'TXN_20260307_001';

  final now = DateTime(2026, 3, 7);

  // ── Sample package ─────────────────────────────────────────────────────────
  final samplePackage = PackageEntity(
    id: packageId,
    clinicId: clinicId,
    category: PackageCategory.andrologyInfertilityProstate,
    name: 'باقة الخصوبة',
    shortDescription: 'وصف',
    services: const [
      PackageServiceItem(
        serviceId: 'svc_1',
        serviceType: ServiceType.lab,
        displayName: 'تحليل',
      ),
      PackageServiceItem(
        serviceId: 'svc_2',
        serviceType: ServiceType.visit,
        displayName: 'كشف',
      ),
    ],
    validityDays: 90,
    price: 1200,
    currency: 'SAR',
    packageType: PackageType.physicalOnly,
    status: PackageStatus.active,
    displayOrder: 1,
    isFeatured: false,
    createdAt: now,
    updatedAt: now,
    includesVideoConsultation: false,
    includesPhysicalVisit: true,
  );

  // ── Helper to build a PatientPackageEntity with a given status ─────────────
  PatientPackageEntity makePatientPackage(PatientPackageStatus status) {
    return PatientPackageEntity(
      id: 'pp_001',
      patientId: patientId,
      packageId: packageId,
      packageName: 'Test Package',
      clinicId: clinicId,
      category: PackageCategory.andrologyInfertilityProstate,
      status: status,
      purchaseDate: now,
      expiryDate: now.add(const Duration(days: 90)),
      totalServicesCount: 2,
      usedServicesCount: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() {
    mockPatientPackageRepo = MockPatientPackageRepository();
    mockPaymentAdapter = MockPackagePaymentAdapter();
    useCase = PurchasePackageUseCase(
      patientPackageRepository: mockPatientPackageRepo,
      paymentAdapter: mockPaymentAdapter,
    );
  });

  group('PurchasePackageUseCase', () {
    // ── T031-a: happy path ───────────────────────────────────────────────────
    test(
      'happy path: returns Right(patientPackageId) after successful payment',
      () async {
        // No existing ACTIVE/PENDING record
        when(
          mockPatientPackageRepo.findActiveOrPendingByPackageId(
            patientId: patientId,
            packageId: packageId,
          ),
        ).thenAnswer((_) async => const Right(null));

        // Payment succeeds
        when(
          mockPaymentAdapter.initiatePayment(
            amount: samplePackage.price,
            currency: samplePackage.currency,
            packageRef: samplePackage.id,
          ),
        ).thenAnswer(
          (_) async => const Right(
            PaymentSuccess(
              transactionId: txnId,
              amount: 1200,
              currency: 'EGP',
            ),
          ),
        );

        // Firestore write succeeds
        when(
          mockPatientPackageRepo.createPatientPackage(
            patientId: patientId,
            packageId: packageId,
            packageName: anyNamed('packageName'),
            clinicId: clinicId,
            status: PatientPackageStatus.active,
            purchaseDate: anyNamed('purchaseDate'),
            expiryDate: anyNamed('expiryDate'),
            totalServicesCount: 2,
            packageServices: anyNamed('packageServices'),
            servicesUsageInit: anyNamed('servicesUsageInit'),
            paymentTransactionId: txnId,
            category: anyNamed('category'),
            isTestPurchase: anyNamed('isTestPurchase'),
            description: anyNamed('description'),
            shortDescription: anyNamed('shortDescription'),
            validityDays: anyNamed('validityDays'),
          ),
        ).thenAnswer((_) async => const Right('pp_new_001'));

        final result = await useCase(
          PurchasePackageParams(patientId: patientId, package: samplePackage),
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected success'),
          (id) => expect(id, 'pp_new_001'),
        );

        // Verify createPatientPackage WAS called with correct status and non-null txn
        verify(
          mockPatientPackageRepo.createPatientPackage(
            patientId: patientId,
            packageId: packageId,
            packageName: anyNamed('packageName'),
            clinicId: clinicId,
            status: PatientPackageStatus.active,
            purchaseDate: anyNamed('purchaseDate'),
            expiryDate: anyNamed('expiryDate'),
            totalServicesCount: 2,
            packageServices: anyNamed('packageServices'),
            servicesUsageInit: anyNamed('servicesUsageInit'),
            paymentTransactionId: txnId,
            category: anyNamed('category'),
            isTestPurchase: anyNamed('isTestPurchase'),
            description: anyNamed('description'),
            shortDescription: anyNamed('shortDescription'),
            validityDays: anyNamed('validityDays'),
          ),
        ).called(1);
      },
    );

    // ── T031-b: PackageAlreadyActiveFailure (ACTIVE record found) ────────────
    test(
      'returns PackageAlreadyActiveFailure when ACTIVE record already exists',
      () async {
        when(
          mockPatientPackageRepo.findActiveOrPendingByPackageId(
            patientId: patientId,
            packageId: packageId,
          ),
        ).thenAnswer(
          (_) async => Right(makePatientPackage(PatientPackageStatus.active)),
        );

        final result = await useCase(
          PurchasePackageParams(patientId: patientId, package: samplePackage),
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f, isA<PackageAlreadyActiveFailure>()),
          (_) => fail('Expected failure'),
        );
        // Payment MUST NOT be called
        verifyNever(
          mockPaymentAdapter.initiatePayment(
            amount: anyNamed('amount'),
            currency: anyNamed('currency'),
            packageRef: anyNamed('packageRef'),
          ),
        );
      },
    );

    // ── T031-c: PackageAlreadyActiveFailure (PENDING record found) ────────────
    test(
      'returns PackageAlreadyActiveFailure when PENDING record already exists',
      () async {
        when(
          mockPatientPackageRepo.findActiveOrPendingByPackageId(
            patientId: patientId,
            packageId: packageId,
          ),
        ).thenAnswer(
          (_) async => Right(makePatientPackage(PatientPackageStatus.pending)),
        );

        final result = await useCase(
          PurchasePackageParams(patientId: patientId, package: samplePackage),
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f, isA<PackageAlreadyActiveFailure>()),
          (_) => fail('Expected failure'),
        );
      },
    );

    // ── T031-d: EXPIRED/COMPLETED → new purchase allowed ─────────────────────
    test(
      'allows new purchase when existing record is EXPIRED',
      () async {
        when(
          mockPatientPackageRepo.findActiveOrPendingByPackageId(
            patientId: patientId,
            packageId: packageId,
          ),
        ).thenAnswer((_) async => const Right(null)); // no ACTIVE/PENDING found

        when(
          mockPaymentAdapter.initiatePayment(
            amount: anyNamed('amount'),
            currency: anyNamed('currency'),
            packageRef: anyNamed('packageRef'),
          ),
        ).thenAnswer(
          (_) async => const Right(
            PaymentSuccess(
              transactionId: txnId,
              amount: 1200,
              currency: 'EGP',
            ),
          ),
        );

        when(
          mockPatientPackageRepo.createPatientPackage(
            patientId: anyNamed('patientId'),
            packageId: anyNamed('packageId'),
            packageName: anyNamed('packageName'),
            clinicId: anyNamed('clinicId'),
            status: anyNamed('status'),
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
        ).thenAnswer((_) async => const Right('pp_new_002'));

        final result = await useCase(
          PurchasePackageParams(patientId: patientId, package: samplePackage),
        );

        expect(result.isRight(), isTrue);
      },
    );

    // ── T031-e: PaymentFailure ────────────────────────────────────────────────
    test('returns PaymentFailure when gateway declines', () async {
      when(
        mockPatientPackageRepo.findActiveOrPendingByPackageId(
          patientId: patientId,
          packageId: packageId,
        ),
      ).thenAnswer((_) async => const Right(null));

      when(
        mockPaymentAdapter.initiatePayment(
          amount: anyNamed('amount'),
          currency: anyNamed('currency'),
          packageRef: anyNamed('packageRef'),
        ),
      ).thenAnswer((_) async => const Left(PaymentFailure()));

      final result = await useCase(
        PurchasePackageParams(patientId: patientId, package: samplePackage),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<PaymentFailure>()),
        (_) => fail('Expected failure'),
      );
      verifyNever(
        mockPatientPackageRepo.createPatientPackage(
          patientId: anyNamed('patientId'),
          packageId: anyNamed('packageId'),
          packageName: anyNamed('packageName'),
          clinicId: anyNamed('clinicId'),
          status: anyNamed('status'),
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
      );
    });

    // ── T031-f: NetworkFailure ────────────────────────────────────────────────
    test(
      'returns NetworkFailure when findActiveOrPendingByPackageId fails',
      () async {
        when(
          mockPatientPackageRepo.findActiveOrPendingByPackageId(
            patientId: patientId,
            packageId: packageId,
          ),
        ).thenAnswer((_) async => const Left(NetworkFailure()));

        final result = await useCase(
          PurchasePackageParams(patientId: patientId, package: samplePackage),
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f, isA<NetworkFailure>()),
          (_) => fail('Expected failure'),
        );
        // Payment and Firestore MUST NOT be called
        verifyNever(
          mockPaymentAdapter.initiatePayment(
            amount: anyNamed('amount'),
            currency: anyNamed('currency'),
            packageRef: anyNamed('packageRef'),
          ),
        );
      },
    );
  });
}
