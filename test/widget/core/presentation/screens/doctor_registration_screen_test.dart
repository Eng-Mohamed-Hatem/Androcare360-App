import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/auth/domain/models/phone_verification_data.dart';
import 'package:elajtech/features/auth/domain/repositories/auth_repository.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/register/presentation/screens/doctor_register_screen.dart';
import 'package:elajtech/shared/constants/clinic_types.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturingAuthRepository implements AuthRepository {
  _CapturingAuthRepository({required this.signUpResult});

  final Either<Failure, UserModel> signUpResult;
  Map<String, Object?>? lastSignUpArgs;
  int signOutCallCount = 0;

  @override
  Stream<firebase.User?> get authStateChanges => const Stream.empty();

  @override
  Future<Either<Failure, UserModel>> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
    String? phoneNumber,
    String? licenseNumber,
    List<String>? specializations,
    String? clinicType,
    String? clinicName,
    String? clinicAddress,
    List<String>? consultationTypes,
    String? username,
  }) async {
    lastSignUpArgs = <String, Object?>{
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'specializations': specializations,
      'consultationTypes': consultationTypes,
      'username': username,
    };
    return signUpResult;
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    signOutCallCount++;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async =>
      const Left(ServerFailure('No user logged in'));

  @override
  Future<Either<Failure, UserModel>> signIn({
    required String email,
    required String password,
  }) async => const Left(ServerFailure('Not used in this test'));

  @override
  Future<Either<Failure, Unit>> resetPassword(String email) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> deleteAccount() async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> updateUser(UserModel user) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> changePassword(String newPassword) async =>
      const Right(unit);

  @override
  Future<Either<Failure, PhoneVerificationData>> verifyPhoneNumber({
    required String phoneNumber,
  }) async =>
      const Right(PhoneVerificationData(verificationId: 'verification-id'));

  @override
  Future<Either<Failure, UserModel>> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async => const Left(ServerFailure('Not used in this test'));

  @override
  Future<Either<Failure, PhoneVerificationData>> verifyPhoneNumberForLinking({
    required String phoneNumber,
  }) async => const Right(PhoneVerificationData(verificationId: 'linking-id'));

  @override
  Future<Either<Failure, UserModel>> linkPhoneToCurrentUser({
    required String verificationId,
    required String smsCode,
  }) async => const Left(ServerFailure('Not used in this test'));

  @override
  Future<Either<Failure, String>> startSignUpWithEmailAndPhone({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String? username,
  }) async => const Right('signup-id');

  @override
  Future<Either<Failure, UserModel>> confirmSignUpAndCreateProfile({
    required String verificationId,
    required String smsCode,
  }) async => const Left(ServerFailure('Not used in this test'));
}

Widget _buildWidget(_CapturingAuthRepository repository) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith((ref) => AuthNotifier(repository)),
    ],
    child: MaterialApp(
      theme: ThemeData(useMaterial3: false),
      home: const DoctorRegisterScreen(),
    ),
  );
}

Finder _fieldAt(int index) => find.byType(TextFormField).at(index);
Finder get _registerButton =>
    find.widgetWithText(ElevatedButton, AppStrings.doctorRegister);

Future<void> _fillRequiredFields(WidgetTester tester) async {
  await tester.enterText(_fieldAt(0), 'Dr Test');
  await tester.enterText(_fieldAt(1), '+201234567890');
  await tester.enterText(_fieldAt(2), 'doctor@example.com');
  await tester.enterText(_fieldAt(3), 'LIC-123');
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(
    find.text(ClinicTypes.arabicLabel(ClinicTypes.values.first)).last,
  );
  await tester.pumpAndSettle();
  await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
  await tester.pumpAndSettle();
  await tester.tap(find.text('استشارة فيديو (أونلاين)'));
  await tester.pumpAndSettle();
  await tester.enterText(_fieldAt(4), 'doctor_test');
  await tester.enterText(_fieldAt(5), 'password123');
  await tester.enterText(_fieldAt(6), 'password123');
  await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(Checkbox).last);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DoctorRegisterScreen', () {
    testWidgets('supports switching clinic type from predefined options', (
      tester,
    ) async {
      final repository = _CapturingAuthRepository(
        signUpResult: Right(
          UserModel(
            id: 'doctor_pending',
            email: 'doctor@example.com',
            fullName: 'Dr Test',
            userType: UserType.doctor,
            createdAt: DateTime(2026, 3, 15),
          ),
        ),
      );

      await tester.pumpWidget(_buildWidget(repository));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      final firstClinicType = ClinicTypes.arabicLabel(ClinicTypes.values.first);
      final secondClinicType = ClinicTypes.arabicLabel(ClinicTypes.values[1]);
      expect(find.text(firstClinicType), findsWidgets);

      await tester.tap(find.text(firstClinicType).last);
      await tester.pumpAndSettle();
      expect(find.text(firstClinicType), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(secondClinicType).last);
      await tester.pumpAndSettle();

      expect(find.text(secondClinicType), findsOneWidget);
      expect(find.text(firstClinicType), findsNothing);
    });

    testWidgets('submits doctor registration through auth provider', (
      tester,
    ) async {
      final repository = _CapturingAuthRepository(
        signUpResult: Right(
          UserModel(
            id: 'doctor_pending',
            email: 'doctor@example.com',
            fullName: 'Dr Test',
            userType: UserType.doctor,
            phoneNumber: '+201234567890',
            username: 'doctor_test',
            clinicType: ClinicTypes.values.first,
            specializations: <String>[
              ClinicTypes.arabicLabel(ClinicTypes.values.first),
            ],
            isApproved: false,
            isActive: false,
            createdAt: DateTime(2026, 3, 15),
          ),
        ),
      );

      await tester.pumpWidget(_buildWidget(repository));
      await _fillRequiredFields(tester);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(_registerButton);
      await tester.pumpAndSettle();

      expect(repository.lastSignUpArgs?['email'], 'doctor@example.com');
      expect(repository.lastSignUpArgs?['phoneNumber'], '+201234567890');
      expect(repository.lastSignUpArgs?['userType'], UserType.doctor);
      expect(
        repository.lastSignUpArgs?['specializations'],
        <String>[ClinicTypes.arabicLabel(ClinicTypes.values.first)],
      );
      expect(repository.lastSignUpArgs?['consultationTypes'], <String>[
        'video',
      ]);
      expect(repository.signOutCallCount, 1);
    });
  });
}
