import 'package:elajtech/features/admin/analytics/presentation/widgets/patient_retention_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  testWidgets('renders retention percentage when sufficient data exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: PatientRetentionWidget(
              retention: testPatientRetention(
                rate: 0.3,
                totalUniquePatients: 100,
                returningPatients: 30,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('معدل الاحتفاظ بالمرضى'), findsOneWidget);
    expect(find.text('30.0% من 100 مرضى'), findsOneWidget);
    expect(find.text('مرضى عائدون: 30'), findsOneWidget);
  });

  testWidgets('renders insufficient-data message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: PatientRetentionWidget(
              retention: testPatientRetention(
                rate: 0,
                totalUniquePatients: 3,
                returningPatients: 0,
                hasSufficientData: false,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('غير متوفر — بيانات غير كافية'), findsOneWidget);
  });
}
