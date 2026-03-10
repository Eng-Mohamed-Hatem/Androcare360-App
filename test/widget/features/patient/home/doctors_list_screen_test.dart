import 'package:elajtech/core/constants/specialty_constants.dart';
import 'package:elajtech/features/patient/home/presentation/screens/doctors_list_screen.dart';
import 'package:elajtech/features/patient/home/presentation/widgets/doctor_card.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/shared/providers/registered_doctors_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final doctors = [
    UserModel(
      id: 'doc1',
      fullName: 'د. محمد ذكورة',
      email: 'doc1@test.com',
      userType: UserType.doctor,
      specializations: ['ذكورة'],
      createdAt: DateTime.now(),
    ),
    UserModel(
      id: 'doc2',
      fullName: 'د. أحمد عقم',
      email: 'doc2@test.com',
      userType: UserType.doctor,
      specializations: ['عقم'],
      createdAt: DateTime.now(),
    ),
    UserModel(
      id: 'doc3',
      fullName: 'د. علي باطنة',
      email: 'doc3@test.com',
      userType: UserType.doctor,
      specializations: ['باطنة'],
      createdAt: DateTime.now(),
    ),
    UserModel(
      id: 'doc4',
      fullName: 'د. سارة تغذية',
      email: 'doc4@test.com',
      userType: UserType.doctor,
      specializations: ['تغذية'],
      createdAt: DateTime.now(),
    ),
  ];

  Widget createTestWidget({String? category}) {
    return ProviderScope(
      overrides: [
        doctorsListProvider.overrideWithValue(AsyncValue.data(doctors)),
      ],
      child: MaterialApp(
        home: DoctorsListScreen(category: category),
      ),
    );
  }

  group('DoctorsListScreen Filtering Tests', () {
    testWidgets(
      'Filters doctors correctly for Andrology clinic (fuzzy matching)',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(category: SpecialtyConstants.andrologyClinic),
        );
        await tester.pumpAndSettle();

        // Should find doc1 and doc2
        expect(find.text('د. محمد ذكورة'), findsOneWidget);
        expect(find.text('د. أحمد عقم'), findsOneWidget);

        // Should NOT find doc3 or doc4
        expect(find.text('د. علي باطنة'), findsNothing);
        expect(find.text('د. سارة تغذية'), findsNothing);
      },
    );

    testWidgets('Filters doctors correctly for Nutrition clinic', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(category: SpecialtyConstants.nutritionClinic),
      );
      await tester.pumpAndSettle();

      expect(find.text('د. سارة تغذية'), findsOneWidget);
      expect(find.text('د. محمد ذكورة'), findsNothing);
    });

    testWidgets('Shows all doctors when no category is provided', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(DoctorCard), findsNWidgets(4));
    });

    testWidgets('Shows empty state when no doctors match', (tester) async {
      await tester.pumpWidget(createTestWidget(category: 'تخصص غير موجود'));
      await tester.pumpAndSettle();

      expect(find.text('لا يوجد أطباء مطابقين للبحث'), findsOneWidget);
    });
  });
}
