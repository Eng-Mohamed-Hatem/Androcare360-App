import 'package:elajtech/features/admin/analytics/domain/usecases/get_doctor_analytics_detail_usecase.dart';
import 'package:elajtech/features/admin/analytics/domain/usecases/get_specialty_breakdown_usecase.dart';
import 'package:elajtech/features/admin/analytics/presentation/screens/doctor_analytics_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  testWidgets('renders appointment, financial, and performance sections', (
    tester,
  ) async {
    final repository = FakeAnalyticsRepository(detail: testDoctor());
    final period = testPeriod();

    await tester.pumpWidget(
      MaterialApp(
        home: DoctorAnalyticsDetailScreen(
          doctorId: 'doctor-1',
          doctorName: 'د. أحمد',
          periodStart: period.start,
          periodEnd: period.end,
          getDetailUseCase: GetDoctorAnalyticsDetailUseCase(repository),
          getSpecialtyBreakdownUseCase: GetSpecialtyBreakdownUseCase(
            repository,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('إحصائيات الحجوزات'), findsOneWidget);
    expect(find.text('الملخص المالي'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('نقطة الأداء'), findsOneWidget);
    expect(find.textContaining('بيانات غير كافية'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('توزيع نوع الخدمة'), findsOneWidget);
    expect(find.textContaining('استشارة فيديو'), findsOneWidget);
  });
}
