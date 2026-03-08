import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/usecases/update_package_service_usage_usecase.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late UpdatePackageServiceUsageUseCase usecase;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    usecase = UpdatePackageServiceUsageUseCase(fakeFirestore);
  });

  const tPatientId = 'patient_1';
  const tPatientPackageId = 'pp_1';
  const tClinicId = 'clinic_1';
  const tPackageId = 'pkg_1';
  const tServiceId = 'service_A';

  test(
    'happy path: increments usedCount and does NOT increment usedServicesCount if below quantity',
    () async {
      // arrange
      // Clinic package
      await fakeFirestore
          .collection('clinics')
          .doc(tClinicId)
          .collection('packages')
          .doc(tPackageId)
          .set({
            'services': [
              {'serviceId': tServiceId, 'quantity': 3}, // Wants 3 to complete
            ],
          });

      // Patient package
      final ppRef = fakeFirestore
          .collection('patients')
          .doc(tPatientId)
          .collection('packages')
          .doc(tPatientPackageId);

      await ppRef.set({
        'clinicId': tClinicId,
        'packageId': tPackageId,
        'usedServicesCount': 0,
        'servicesUsage': [
          {'serviceId': tServiceId, 'usedCount': 1},
        ],
      });

      // act
      final result = await usecase(
        patientId: tPatientId,
        patientPackageId: tPatientPackageId,
        serviceId: tServiceId,
      );

      // assert
      expect(result, const Right<Failure, Unit>(unit));

      final snapshot = await ppRef.get();
      final data = snapshot.data()!;
      expect(data['usedServicesCount'], 0); // 2 is still < 3

      final usages = List<Map<String, dynamic>>.from(
        (data['servicesUsage'] as Iterable<dynamic>?) ?? [],
      );
      expect(usages.length, 1);
      expect(usages[0]['serviceId'], tServiceId);
      expect(usages[0]['usedCount'], 2);
      expect(usages[0]['lastUsedAt'], isNotNull);
    },
  );

  test(
    'increments usedCount and INCREMENTS usedServicesCount if reaches quantity',
    () async {
      // arrange
      await fakeFirestore
          .collection('clinics')
          .doc(tClinicId)
          .collection('packages')
          .doc(tPackageId)
          .set({
            'services': [
              {'serviceId': tServiceId, 'quantity': 3},
            ],
          });

      final ppRef = fakeFirestore
          .collection('patients')
          .doc(tPatientId)
          .collection('packages')
          .doc(tPatientPackageId);

      await ppRef.set({
        'clinicId': tClinicId,
        'packageId': tPackageId,
        'usedServicesCount': 0,
        'servicesUsage': [
          {'serviceId': tServiceId, 'usedCount': 2}, // Next use -> 3 >= 3
        ],
      });

      // act
      final result = await usecase(
        patientId: tPatientId,
        patientPackageId: tPatientPackageId,
        serviceId: tServiceId,
      );

      // assert
      expect(result, const Right<Failure, Unit>(unit));

      final snapshot = await ppRef.get();
      final data = snapshot.data()!;
      expect(data['usedServicesCount'], 1); // REACHED quantity

      final usages = List<Map<String, dynamic>>.from(
        (data['servicesUsage'] as Iterable<dynamic>?) ?? [],
      );
      expect(usages[0]['usedCount'], 3);
    },
  );

  test('Failure if patient package not found', () async {
    // act
    final result = await usecase(
      patientId: 'unknown',
      patientPackageId: 'unknown_pp',
      serviceId: tServiceId,
    );

    // assert
    expect(result.fold((l) => l, (r) => r), isA<ServerFailure>());
    expect(
      (result.fold((l) => l, (r) => r) as ServerFailure).message,
      contains('PatientPackageNotFound'),
    );
  });

  test('Failure if original package not found', () async {
    // arrange
    final ppRef = fakeFirestore
        .collection('patients')
        .doc(tPatientId)
        .collection('packages')
        .doc(tPatientPackageId);

    await ppRef.set({
      'clinicId': tClinicId,
      'packageId': 'unknown_package',
      'usedServicesCount': 0,
    });

    // act
    final result = await usecase(
      patientId: tPatientId,
      patientPackageId: tPatientPackageId,
      serviceId: tServiceId,
    );

    // assert
    expect(result.fold((l) => l, (r) => r), isA<ServerFailure>());
    expect(
      (result.fold((l) => l, (r) => r) as ServerFailure).message,
      contains('OriginalPackageNotFound'),
    );
  });
}
