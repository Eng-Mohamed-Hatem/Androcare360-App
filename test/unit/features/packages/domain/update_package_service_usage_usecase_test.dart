// test/unit/features/packages/domain/update_package_service_usage_usecase_test.dart
//
// Unit tests for [UpdatePackageServiceUsageUseCase] — T074.
// Covers:
// (a) increment usedCount
// (b) reaching quantity -> usedServicesCount incremented
// (c) partial use does NOT increment usedServicesCount
// (d) concurrent calls simulation (R3, R10 - transaction semantics).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/features/packages/domain/usecases/update_package_service_usage_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'update_package_service_usage_usecase_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
  MockSpec<Transaction>(),
  MockSpec<DocumentReference>(),
  MockSpec<DocumentSnapshot>(),
  MockSpec<CollectionReference>(),
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockTransaction mockTransaction;
  late UpdatePackageServiceUsageUseCase useCase;

  // PatientPackage refs
  late MockCollectionReference<Map<String, dynamic>> mockPatientsCollection;
  late MockDocumentReference<Map<String, dynamic>> mockPatientDoc;
  late MockCollectionReference<Map<String, dynamic>>
  mockPatientPackagesCollection;
  late MockDocumentReference<Map<String, dynamic>> mockPatientPackageDoc;

  // ClinicPackage refs
  late MockCollectionReference<Map<String, dynamic>> mockClinicsCollection;
  late MockDocumentReference<Map<String, dynamic>> mockClinicDoc;
  late MockCollectionReference<Map<String, dynamic>>
  mockClinicPackagesCollection;
  late MockDocumentReference<Map<String, dynamic>> mockClinicPackageDoc;

  // Snapshots
  late MockDocumentSnapshot<Map<String, dynamic>> mockPpSnapshot;
  late MockDocumentSnapshot<Map<String, dynamic>> mockPkgSnapshot;

  const patientId = 'pat_001';
  const patientPackageId = 'pp_001';
  const clinicId = 'andrology';
  const packageId = 'pkg_001';
  const serviceId = 'srv_1';

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockTransaction = MockTransaction();
    useCase = UpdatePackageServiceUsageUseCase(mockFirestore);

    mockPatientsCollection = MockCollectionReference();
    mockPatientDoc = MockDocumentReference();
    mockPatientPackagesCollection = MockCollectionReference();
    mockPatientPackageDoc = MockDocumentReference();

    mockClinicsCollection = MockCollectionReference();
    mockClinicDoc = MockDocumentReference();
    mockClinicPackagesCollection = MockCollectionReference();
    mockClinicPackageDoc = MockDocumentReference();

    mockPpSnapshot = MockDocumentSnapshot();
    mockPkgSnapshot = MockDocumentSnapshot();

    // Setup PatientPackage path
    when(
      mockFirestore.collection('patients'),
    ).thenReturn(mockPatientsCollection);
    when(mockPatientsCollection.doc(patientId)).thenReturn(mockPatientDoc);
    when(
      mockPatientDoc.collection('packages'),
    ).thenReturn(mockPatientPackagesCollection);
    when(
      mockPatientPackagesCollection.doc(patientPackageId),
    ).thenReturn(mockPatientPackageDoc);

    // Setup ClinicPackage path
    when(mockFirestore.collection('clinics')).thenReturn(mockClinicsCollection);
    when(mockClinicsCollection.doc(clinicId)).thenReturn(mockClinicDoc);
    when(
      mockClinicDoc.collection('packages'),
    ).thenReturn(mockClinicPackagesCollection);
    when(
      mockClinicPackagesCollection.doc(packageId),
    ).thenReturn(mockClinicPackageDoc);

    when(mockFirestore.runTransaction<void>(any)).thenAnswer((inv) async {
      final action =
          inv.positionalArguments[0] as Future<void> Function(Transaction);
      return action(mockTransaction);
    });

    // Mock gets
    when(
      mockTransaction.get(mockPatientPackageDoc),
    ).thenAnswer((_) async => mockPpSnapshot);
    when(
      mockTransaction.get(mockClinicPackageDoc),
    ).thenAnswer((_) async => mockPkgSnapshot);

    // Snapshot exists
    when(mockPpSnapshot.exists).thenReturn(true);
    when(mockPkgSnapshot.exists).thenReturn(true);

    // Stub transaction.update
    when(mockTransaction.update(any, any)).thenReturn(mockTransaction);
  });

  group('UpdatePackageServiceUsageUseCase', () {
    test(
      'a) increment usedCount (adds new usage item if none exists)',
      () async {
        when(mockPpSnapshot.data()).thenReturn({
          'clinicId': clinicId,
          'packageId': packageId,
          'servicesUsage': <Map<String, dynamic>>[],
        });
        when(mockPkgSnapshot.data()).thenReturn({
          'services': [
            {'serviceId': serviceId, 'quantity': 2},
          ],
        });

        final result = await useCase(
          patientId: patientId,
          patientPackageId: patientPackageId,
          serviceId: serviceId,
        );

        expect(result.isRight(), isTrue);

        final captured = verify(
          mockTransaction.update(mockPatientPackageDoc, captureAny),
        ).captured;
        final updates = captured.first as Map<String, dynamic>;

        final usages = updates['servicesUsage'] as List<dynamic>;
        expect(usages.length, 1);
        final firstUsage = usages[0] as Map<String, dynamic>;
        expect(firstUsage['serviceId'], serviceId);
        expect(firstUsage['usedCount'], 1); // incremented from 0 to 1
        expect(updates['usedServicesCount'], 0); // Need 2 to reach quantity
      },
    );

    test('c) partial use does NOT increment usedServicesCount', () async {
      when(mockPpSnapshot.data()).thenReturn({
        'clinicId': clinicId,
        'packageId': packageId,
        'servicesUsage': [
          {'serviceId': serviceId, 'usedCount': 1},
        ],
      });
      when(mockPkgSnapshot.data()).thenReturn({
        'services': [
          {'serviceId': serviceId, 'quantity': 3}, // target is 3
        ],
      });

      final result = await useCase(
        patientId: patientId,
        patientPackageId: patientPackageId,
        serviceId: serviceId,
      );

      expect(result.isRight(), isTrue);

      final captured = verify(
        mockTransaction.update(mockPatientPackageDoc, captureAny),
      ).captured;
      final updates = captured.first as Map<String, dynamic>;

      final usages = updates['servicesUsage'] as List<dynamic>;
      final firstUsage = usages[0] as Map<String, dynamic>;
      expect(firstUsage['usedCount'], 2); // 1 -> 2
      expect(updates['usedServicesCount'], 0); // 2 < 3, still 0
    });

    test('b) reaching quantity -> usedServicesCount incremented', () async {
      when(mockPpSnapshot.data()).thenReturn({
        'clinicId': clinicId,
        'packageId': packageId,
        'servicesUsage': [
          {'serviceId': serviceId, 'usedCount': 1},
        ],
      });
      when(mockPkgSnapshot.data()).thenReturn({
        'services': [
          {'serviceId': serviceId, 'quantity': 2}, // target is 2
        ],
      });

      final result = await useCase(
        patientId: patientId,
        patientPackageId: patientPackageId,
        serviceId: serviceId,
      );

      expect(result.isRight(), isTrue);

      final captured = verify(
        mockTransaction.update(mockPatientPackageDoc, captureAny),
      ).captured;
      final updates = captured.first as Map<String, dynamic>;

      final usages = updates['servicesUsage'] as List<dynamic>;
      final firstUsage = usages[0] as Map<String, dynamic>;
      expect(firstUsage['usedCount'], 2); // 1 -> 2
      expect(
        updates['usedServicesCount'],
        1,
      ); // 2 reached 2 -> counts as 1 completed service
    });

    test(
      'd) simulate two concurrent calls for the same service (R3, R10)',
      () async {
        // We simulate concurrency by mocking runTransaction state.
        // Since it's inside runTransaction, the usecase relies on Firestore's locks.
        // We verify that the logic executes twice inside the transaction wrapper
        // and doesn't read/write outside of it.

        when(mockPpSnapshot.data()).thenReturn({
          'clinicId': clinicId,
          'packageId': packageId,
          'servicesUsage': <Map<String, dynamic>>[],
        });
        when(mockPkgSnapshot.data()).thenReturn({
          'services': [
            {'serviceId': serviceId, 'quantity': 2},
          ],
        });

        // Execute concurrently
        await Future.wait([
          useCase(
            patientId: patientId,
            patientPackageId: patientPackageId,
            serviceId: serviceId,
          ),
          useCase(
            patientId: patientId,
            patientPackageId: patientPackageId,
            serviceId: serviceId,
          ),
        ]);

        // Verify that runTransaction was called twice
        verify(mockFirestore.runTransaction<void>(any)).called(2);

        // Verify that 'get' and 'update' were invoked on the Transaction specifically,
        // confirming commit-once semantics via Firestore.
        verify(mockTransaction.get(mockPatientPackageDoc)).called(2);
        verify(mockTransaction.update(mockPatientPackageDoc, any)).called(2);

        // Verify no direct update on CollectionReference/DocumentRefs
        verifyNever(mockPatientPackageDoc.update(any));
      },
    );
  });
}
