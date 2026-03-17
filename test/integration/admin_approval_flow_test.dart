@TestOn('vm')
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/data/repositories/admin_approval_repository_impl.dart';
import 'package:elajtech/core/data/repositories/doctor_registration_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/firebase_emulator_helper.dart';

void main() {
  const runAdminApprovalIntegration = bool.fromEnvironment(
    'RUN_ADMIN_APPROVAL_INTEGRATION_TESTS',
  );

  if (!runAdminApprovalIntegration) {
    group('Admin Approval Flow Integration Tests', () {
      test(
        'skipped unless RUN_ADMIN_APPROVAL_INTEGRATION_TESTS=true',
        () {},
        skip: 'Requires Firebase emulators and integration setup',
      );
    });
    return;
  }

  TestWidgetsFlutterBinding.ensureInitialized();

  group('Admin Approval Flow Integration Tests', () {
    late FirebaseFirestore firestore;
    late FirebaseAuth auth;
    late DoctorRegistrationRepositoryImpl registrationRepository;
    late AdminApprovalRepositoryImpl approvalRepository;

    setUp(() async {
      await FirebaseEmulatorHelper.setupEmulator();
      await FirebaseEmulatorHelper.clearFirestore();
      await FirebaseEmulatorHelper.signOutTestUser();

      firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: FirebaseEmulatorHelper.databaseId,
      );
      auth = FirebaseAuth.instance;
      registrationRepository = DoctorRegistrationRepositoryImpl(
        auth,
        firestore,
      );
      approvalRepository = AdminApprovalRepositoryImpl(firestore);
    });

    tearDown(() async {
      await FirebaseEmulatorHelper.cleanup();
    });

    test(
      'registers pending doctors, approves one, rejects one, and updates visibility state',
      () async {
        final approvedEmail = _uniqueEmail('approval-approved');
        final rejectedEmail = _uniqueEmail('approval-rejected');

        final approvedRegistration = await registrationRepository
            .registerDoctor(
              fullName: 'Dr Approved Candidate',
              email: approvedEmail,
              phoneNumber: '+201234567890',
              specialty: 'عيادة الأمراض المزمنة',
            );
        expect(approvedRegistration.isRight(), isTrue);

        final approvedDoctorId = auth.currentUser?.uid;
        expect(approvedDoctorId, isNotNull);
        final approvedDoctorIdValue = approvedDoctorId!;

        final rejectedRegistration = await registrationRepository
            .registerDoctor(
              fullName: 'Dr Rejected Candidate',
              email: rejectedEmail,
              phoneNumber: '+201234567891',
              specialty: 'عيادة الباطنة وطب الأسرة',
            );
        expect(rejectedRegistration.isRight(), isTrue);

        final rejectedDoctorId = auth.currentUser?.uid;
        expect(rejectedDoctorId, isNotNull);
        final rejectedDoctorIdValue = rejectedDoctorId!;
        expect(rejectedDoctorIdValue, isNot(equals(approvedDoctorIdValue)));

        final pendingBeforeAction = await approvalRepository
            .getPendingDoctors();
        expect(pendingBeforeAction.isRight(), isTrue);
        final pendingIds = pendingBeforeAction
            .getOrElse(() => const [])
            .map((doctor) => doctor.doctorId)
            .toSet();
        expect(
          pendingIds,
          containsAll(<String>{approvedDoctorIdValue, rejectedDoctorIdValue}),
        );

        final approveResult = await approvalRepository.approveDoctor(
          doctorId: approvedDoctorIdValue,
          adminId: 'admin_a',
          adminName: 'Admin A',
        );
        expect(approveResult.isRight(), isTrue);

        final rejectResult = await approvalRepository.rejectDoctor(
          doctorId: rejectedDoctorIdValue,
          adminId: 'admin_a',
          adminName: 'Admin A',
        );
        expect(rejectResult.isRight(), isTrue);

        final approvedSnapshot = await firestore
            .collection('users')
            .doc(approvedDoctorIdValue)
            .get();
        expect(approvedSnapshot.exists, isTrue);
        final approvedData = approvedSnapshot.data();
        expect(approvedData, isNotNull);
        expect(approvedData!['userType'], 'doctor');
        expect(approvedData['isApproved'], isTrue);
        expect(approvedData['isActive'], isTrue);
        expect(approvedData['approvedAt'], isNotNull);
        expect(
          () => DateTime.parse(approvedData['approvedAt'] as String),
          returnsNormally,
        );

        final rejectedSnapshot = await firestore
            .collection('users')
            .doc(rejectedDoctorIdValue)
            .get();
        expect(rejectedSnapshot.exists, isFalse);

        final pendingAfterAction = await approvalRepository.getPendingDoctors();
        expect(pendingAfterAction.isRight(), isTrue);
        final remainingPendingIds = pendingAfterAction
            .getOrElse(() => const [])
            .map((doctor) => doctor.doctorId)
            .toSet();
        expect(remainingPendingIds.contains(approvedDoctorIdValue), isFalse);
        expect(remainingPendingIds.contains(rejectedDoctorIdValue), isFalse);

        final visibleDoctors = await firestore
            .collection('users')
            .where('userType', isEqualTo: 'doctor')
            .where('isApproved', isEqualTo: true)
            .where('isActive', isEqualTo: true)
            .get();
        final visibleDoctorIds = visibleDoctors.docs
            .map((doc) => doc.id)
            .toList();
        expect(visibleDoctorIds, contains(approvedDoctorIdValue));
        expect(visibleDoctorIds, isNot(contains(rejectedDoctorIdValue)));
      },
    );
  });
}

String _uniqueEmail(String prefix) {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  return '$prefix-$timestamp@example.com';
}
