@TestOn('vm')
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/data/repositories/admin_approval_repository_impl.dart';
import 'package:elajtech/core/domain/entities/doctor_application_action_result.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/firebase_options.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/firebase_emulator_helper.dart';

void main() {
  const runConcurrentAdminActionsIntegration = bool.fromEnvironment(
    'RUN_ADMIN_APPROVAL_INTEGRATION_TESTS',
  );

  if (!runConcurrentAdminActionsIntegration) {
    group('Concurrent Admin Actions Integration Tests', () {
      test(
        'skipped unless RUN_ADMIN_APPROVAL_INTEGRATION_TESTS=true',
        () {},
        skip: 'Requires Firebase emulators and integration setup',
      );
    });
    return;
  }

  TestWidgetsFlutterBinding.ensureInitialized();

  group('Concurrent Admin Actions Integration Tests', () {
    late FirebaseApp adminAppA;
    late FirebaseApp adminAppB;
    late FirebaseApp seedApp;

    late FirebaseFirestore seedDb;
    late FirebaseFirestore adminDbA;
    late FirebaseFirestore adminDbB;

    late AdminApprovalRepositoryImpl approvalRepositoryA;
    late AdminApprovalRepositoryImpl approvalRepositoryB;

    setUp(() async {
      await _deleteNamedApps();
      await FirebaseEmulatorHelper.setupEmulator();
      await FirebaseEmulatorHelper.clearFirestore();
      await FirebaseEmulatorHelper.signOutTestUser();

      seedApp = await Firebase.initializeApp(
        name: 'admin-approval-seed',
        options: DefaultFirebaseOptions.currentPlatform,
      );
      adminAppA = await Firebase.initializeApp(
        name: 'admin-approval-admin-a',
        options: DefaultFirebaseOptions.currentPlatform,
      );
      adminAppB = await Firebase.initializeApp(
        name: 'admin-approval-admin-b',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      seedDb =
          FirebaseFirestore.instanceFor(
            app: seedApp,
            databaseId: FirebaseEmulatorHelper.databaseId,
          )..useFirestoreEmulator(
            FirebaseEmulatorHelper.firestoreHost,
            FirebaseEmulatorHelper.firestorePort,
          );
      adminDbA =
          FirebaseFirestore.instanceFor(
            app: adminAppA,
            databaseId: FirebaseEmulatorHelper.databaseId,
          )..useFirestoreEmulator(
            FirebaseEmulatorHelper.firestoreHost,
            FirebaseEmulatorHelper.firestorePort,
          );
      adminDbB =
          FirebaseFirestore.instanceFor(
            app: adminAppB,
            databaseId: FirebaseEmulatorHelper.databaseId,
          )..useFirestoreEmulator(
            FirebaseEmulatorHelper.firestoreHost,
            FirebaseEmulatorHelper.firestorePort,
          );

      approvalRepositoryA = AdminApprovalRepositoryImpl(adminDbA);
      approvalRepositoryB = AdminApprovalRepositoryImpl(adminDbB);
    });

    tearDown(() async {
      await FirebaseEmulatorHelper.cleanup();
      await _deleteNamedApps();
    });

    test(
      'simultaneous approve and reject requests allow only one successful outcome',
      () async {
        const doctorId = 'doctor_concurrent';
        await _seedPendingDoctor(seedDb, doctorId: doctorId);

        final results =
            await Future.wait<Either<Failure, DoctorApplicationActionResult>>([
              approvalRepositoryA.approveDoctor(
                doctorId: doctorId,
                adminId: 'admin_a',
                adminName: 'Admin A',
              ),
              approvalRepositoryB.rejectDoctor(
                doctorId: doctorId,
                adminId: 'admin_b',
                adminName: 'Admin B',
              ),
            ]);

        expect(results.every((result) => result.isRight()), isTrue);

        final statuses = results
            .map(
              (result) => result.fold(
                (_) => null,
                (actionResult) => actionResult.status,
              ),
            )
            .toSet();
        expect(
          statuses.contains(DoctorApplicationActionStatus.approved) ||
              statuses.contains(DoctorApplicationActionStatus.rejected),
          isTrue,
        );

        final doctorSnapshot = await seedDb
            .collection('users')
            .doc(doctorId)
            .get();

        if (doctorSnapshot.exists) {
          final data = doctorSnapshot.data();
          expect(data, isNotNull);
          expect(data!['isApproved'], isTrue);
          expect(data['isActive'], isTrue);
          expect(data['approvedAt'], isNotNull);
        } else {
          expect(doctorSnapshot.exists, isFalse);
        }

        final pendingAfterRace = await approvalRepositoryA.getPendingDoctors();
        expect(pendingAfterRace.isRight(), isTrue);
        final remainingPendingIds = pendingAfterRace
            .getOrElse(() => const [])
            .map((doctor) => doctor.doctorId)
            .toSet();
        expect(remainingPendingIds.contains(doctorId), isFalse);
      },
    );
  });
}

Future<void> _deleteNamedApps() async {
  const appNames = <String>{
    'admin-approval-seed',
    'admin-approval-admin-a',
    'admin-approval-admin-b',
  };

  for (final app
      in Firebase.apps.where((app) => appNames.contains(app.name)).toList()) {
    await app.delete();
  }
}

Future<void> _seedPendingDoctor(
  FirebaseFirestore firestore, {
  required String doctorId,
}) {
  final doctor = UserModel(
    id: doctorId,
    email: 'doctor.concurrent@example.com',
    fullName: 'Dr Concurrent Candidate',
    userType: UserType.doctor,
    phoneNumber: '+201234567892',
    specialty: 'عيادة السمنة والتغذية العلاجية',
    isActive: false,
    createdAt: DateTime.now(),
  );

  return firestore.collection('users').doc(doctorId).set(doctor.toJson());
}
