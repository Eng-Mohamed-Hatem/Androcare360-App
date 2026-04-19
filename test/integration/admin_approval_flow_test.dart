@TestOn('vm')
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/data/repositories/admin_approval_repository_impl.dart';
import 'package:elajtech/shared/models/user_model.dart';
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
    late AdminApprovalRepositoryImpl approvalRepository;

    setUp(() async {
      await FirebaseEmulatorHelper.setupEmulator();
      await FirebaseEmulatorHelper.clearFirestore();
      await FirebaseEmulatorHelper.signOutTestUser();

      firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: FirebaseEmulatorHelper.databaseId,
      );
      approvalRepository = AdminApprovalRepositoryImpl(firestore);
    });

    tearDown(() async {
      await FirebaseEmulatorHelper.cleanup();
    });

    test(
      'approves one pending doctor, rejects another, and updates visibility state',
      () async {
        const approvedDoctorId = 'doctor_approved';
        const rejectedDoctorId = 'doctor_rejected';

        await _seedPendingDoctor(
          firestore,
          doctorId: approvedDoctorId,
          email: _uniqueEmail('approval-approved'),
          fullName: 'Dr Approved Candidate',
          specialty: 'عيادة الأمراض المزمنة',
        );
        await _seedPendingDoctor(
          firestore,
          doctorId: rejectedDoctorId,
          email: _uniqueEmail('approval-rejected'),
          fullName: 'Dr Rejected Candidate',
          specialty: 'عيادة الباطنة وطب الأسرة',
        );

        final pendingBeforeAction = await approvalRepository
            .getPendingDoctors();
        expect(pendingBeforeAction.isRight(), isTrue);
        final pendingIds = pendingBeforeAction
            .getOrElse(() => const [])
            .map((doctor) => doctor.doctorId)
            .toSet();
        expect(
          pendingIds,
          containsAll(<String>{approvedDoctorId, rejectedDoctorId}),
        );

        final approveResult = await approvalRepository.approveDoctor(
          doctorId: approvedDoctorId,
          adminId: 'admin_a',
          adminName: 'Admin A',
        );
        expect(approveResult.isRight(), isTrue);

        final rejectResult = await approvalRepository.rejectDoctor(
          doctorId: rejectedDoctorId,
          adminId: 'admin_a',
          adminName: 'Admin A',
        );
        expect(rejectResult.isRight(), isTrue);

        final approvedSnapshot = await firestore
            .collection('users')
            .doc(approvedDoctorId)
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
            .doc(rejectedDoctorId)
            .get();
        expect(rejectedSnapshot.exists, isFalse);

        final pendingAfterAction = await approvalRepository.getPendingDoctors();
        expect(pendingAfterAction.isRight(), isTrue);
        final remainingPendingIds = pendingAfterAction
            .getOrElse(() => const [])
            .map((doctor) => doctor.doctorId)
            .toSet();
        expect(remainingPendingIds.contains(approvedDoctorId), isFalse);
        expect(remainingPendingIds.contains(rejectedDoctorId), isFalse);

        final visibleDoctors = await firestore
            .collection('users')
            .where('userType', isEqualTo: 'doctor')
            .where('isApproved', isEqualTo: true)
            .where('isActive', isEqualTo: true)
            .get();
        final visibleDoctorIds = visibleDoctors.docs
            .map((doc) => doc.id)
            .toList();
        expect(visibleDoctorIds, contains(approvedDoctorId));
        expect(visibleDoctorIds, isNot(contains(rejectedDoctorId)));
      },
    );
  });
}

Future<void> _seedPendingDoctor(
  FirebaseFirestore firestore, {
  required String doctorId,
  required String email,
  required String fullName,
  required String specialty,
}) {
  final doctor = UserModel(
    id: doctorId,
    email: email,
    fullName: fullName,
    userType: UserType.doctor,
    phoneNumber: '+201234567890',
    specialty: specialty,
    isActive: false,
    createdAt: DateTime.now(),
  );

  return firestore.collection('users').doc(doctorId).set(doctor.toJson());
}

String _uniqueEmail(String prefix) {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  return '$prefix-$timestamp@example.com';
}
