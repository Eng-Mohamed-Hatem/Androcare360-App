/// Unit tests for ClinicAccessResolver — T090
///
/// Tests the role-based clinic access logic:
/// - ADMIN_GLOBAL claim → all 5 clinics
/// - ADMIN_CLINIC claim → only allowed clinics
/// - No claims → Firestore fallback → ADMIN_GLOBAL
/// - Unauthenticated → empty list
///
/// Uses mockito mocks for FirebaseAuth and FirebaseFirestore.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/auth/clinic_access_resolver.dart';
import 'package:elajtech/features/packages/data/constants/clinic_ids.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'clinic_access_resolver_test.mocks.dart';

@GenerateMocks([FirebaseAuth, FirebaseFirestore, User, IdTokenResult])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late ClinicAccessResolver resolver;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    resolver = ClinicAccessResolver(mockAuth, mockFirestore);
  });

  group('ClinicAccessResolver.getAllowedClinics', () {
    test(
      'ADMIN_GLOBAL claim returns all 5 clinic IDs',
      () async {
        final mockUser = MockUser();
        final mockToken = MockIdTokenResult();

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('uid_123');
        when(mockUser.getIdTokenResult()).thenAnswer(
          (_) async => mockToken,
        );
        when(mockToken.claims).thenReturn({'role': 'ADMIN_GLOBAL'});

        final result = await resolver.getAllowedClinics();

        expect(result.length, ClinicIds.all.length);
        expect(result, containsAll(ClinicIds.all));
      },
    );

    test(
      'ADMIN_CLINIC claim with allowedClinics returns only listed valid clinics',
      () async {
        final mockUser = MockUser();
        final mockToken = MockIdTokenResult();

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('uid_123');
        when(mockUser.getIdTokenResult()).thenAnswer(
          (_) async => mockToken,
        );
        when(mockToken.claims).thenReturn({
          'role': 'ADMIN_CLINIC',
          'allowedClinics': [ClinicIds.andrology, ClinicIds.nutrition],
        });

        final result = await resolver.getAllowedClinics();

        expect(result, containsAll([ClinicIds.andrology, ClinicIds.nutrition]));
        expect(result.length, 2);
      },
    );

    test(
      'ADMIN_CLINIC with an unknown clinicId filters it out',
      () async {
        final mockUser = MockUser();
        final mockToken = MockIdTokenResult();

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('uid_123');
        when(mockUser.getIdTokenResult()).thenAnswer(
          (_) async => mockToken,
        );
        when(mockToken.claims).thenReturn({
          'role': 'ADMIN_CLINIC',
          'allowedClinics': [ClinicIds.andrology, 'unknown_clinic_xyz'],
        });

        final result = await resolver.getAllowedClinics();

        expect(result, contains(ClinicIds.andrology));
        expect(result, isNot(contains('unknown_clinic_xyz')));
        expect(result.length, 1);
      },
    );

    test(
      'No authenticated user returns empty list',
      () async {
        when(mockAuth.currentUser).thenReturn(null);

        final result = await resolver.getAllowedClinics();

        expect(result, isEmpty);
      },
    );

    test(
      'No role claim falls back to Firestore; ADMIN_GLOBAL in Firestore → all clinics',
      () async {
        final mockUser = MockUser();
        final mockToken = MockIdTokenResult();
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();
        final mockCollection = MockCollectionReference();

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('user_123');
        when(mockUser.getIdTokenResult()).thenAnswer(
          (_) async => mockToken,
        );
        when(mockToken.claims).thenReturn(<String, dynamic>{});
        when(mockFirestore.collection('users')).thenReturn(mockCollection);
        when(mockCollection.doc('user_123')).thenReturn(mockDocRef);
        when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(mockDocSnapshot.exists).thenReturn(true);
        when(mockDocSnapshot.data()).thenReturn({'userType': 'ADMIN_GLOBAL'});

        final result = await resolver.getAllowedClinics();

        expect(result.length, ClinicIds.all.length);
      },
    );
    test(
      'Fallback to Firestore: "admin" (lowercase/normalized) → all clinics',
      () async {
        final mockUser = MockUser();
        final mockToken = MockIdTokenResult();
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();
        final mockCollection = MockCollectionReference();

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('user_456');
        when(mockUser.getIdTokenResult()).thenAnswer(
          (_) async => mockToken,
        );
        when(mockToken.claims).thenReturn(<String, dynamic>{});
        when(mockFirestore.collection('users')).thenReturn(mockCollection);
        when(mockCollection.doc('user_456')).thenReturn(mockDocRef);
        when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(mockDocSnapshot.exists).thenReturn(true);
        when(mockDocSnapshot.data()).thenReturn({'userType': 'admin'});

        final result = await resolver.getAllowedClinics();

        expect(result.length, ClinicIds.all.length);
        expect(result, containsAll(ClinicIds.all));
      },
    );

    test(
      'PATIENT role returns empty list (no clinic access)',
      () async {
        final mockUser = MockUser();
        final mockToken = MockIdTokenResult();

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('uid_123');
        when(mockUser.getIdTokenResult()).thenAnswer(
          (_) async => mockToken,
        );
        when(mockToken.claims).thenReturn({'role': 'PATIENT'});

        final result = await resolver.getAllowedClinics();

        expect(result, isEmpty);
      },
    );
  });

  group('ClinicAccessResolver.canAccessClinic', () {
    test(
      'returns true for allowed clinic',
      () async {
        final mockUser = MockUser();
        final mockToken = MockIdTokenResult();

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('uid_123');
        when(mockUser.getIdTokenResult()).thenAnswer(
          (_) async => mockToken,
        );
        when(mockToken.claims).thenReturn({'role': 'ADMIN_GLOBAL'});

        final result = await resolver.canAccessClinic(ClinicIds.andrology);

        expect(result, isTrue);
      },
    );

    test(
      'returns false when unauthenticated',
      () async {
        when(mockAuth.currentUser).thenReturn(null);

        final result = await resolver.canAccessClinic(ClinicIds.andrology);

        expect(result, isFalse);
      },
    );
  });
}

// Mockito mock classes needed by the test (generated types referenced above)
@GenerateNiceMocks([
  MockSpec<DocumentReference<Map<String, dynamic>>>(),
  MockSpec<DocumentSnapshot<Map<String, dynamic>>>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(),
])
// Reason: the helper exists only to anchor generated Mockito declarations.
// ignore: unused_element, generated mock declarations above require this anchor
void _unused() {}
