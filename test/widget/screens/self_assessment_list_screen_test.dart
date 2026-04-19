import 'package:elajtech/features/patient/self_assessment/data/quiz_data.dart';
import 'package:elajtech/features/patient/self_assessment/presentation/screens/quiz_result_screen.dart';
import 'package:elajtech/features/patient/self_assessment/presentation/screens/quiz_screen.dart';
import 'package:elajtech/features/patient/self_assessment/presentation/screens/self_assessment_list_screen.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/shared/providers/registered_doctors_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SelfAssessment flow', () {
    testWidgets('shows the new sexual health assessments first', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: SelfAssessmentListScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('تقييم تأخر الإنجاب عند الرجل'), findsOneWidget);
      expect(
        find.text('تقييم مخاطر التعرض للعدوى المنقولة جنسياً'),
        findsOneWidget,
      );

      final fertilityTitle = find.text('تقييم تأخر الإنجاب عند الرجل');
      final stiTitle = find.text('تقييم مخاطر التعرض للعدوى المنقولة جنسياً');
      expect(
        tester.getTopLeft(fertilityTitle).dy,
        lessThan(tester.getTopLeft(stiTitle).dy),
      );
    });

    testWidgets('opens male fertility assessment quiz from list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: SelfAssessmentListScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('تقييم تأخر الإنجاب عند الرجل'));
      await tester.pumpAndSettle();

      expect(find.byType(QuizScreen), findsOneWidget);
      expect(find.text('ما الفئة العمرية الأقرب لك؟'), findsOneWidget);
    });

    testWidgets('shows standard recommendation for fertility result', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizResultScreen(
            quiz: QuizData.maleFertilityDelayQuiz,
            answers: {1: 2, 2: 3, 5: 2, 10: 3},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('بناءً على إجاباتك، نوصي بحجز موعد مع أحد أطبائنا المختصين.'),
        findsOneWidget,
      );
      expect(find.text('احجز موعداً مع طبيب خصوبة الرجال'), findsOneWidget);
      expect(find.byIcon(Icons.health_and_safety_outlined), findsOneWidget);
    });

    testWidgets('shows standard recommendation for STI result', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizResultScreen(
            quiz: QuizData.stiExposureRiskQuiz,
            answers: {2: 3, 3: 3, 7: 3, 9: 3},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('بناءً على إجاباتك، نوصي بحجز موعد مع أحد أطبائنا المختصين.'),
        findsOneWidget,
      );
      expect(
        find.text('احجز موعداً مع أطباء الذكورة والعقم والبروستات'),
        findsOneWidget,
      );
      expect(
        find.textContaining('العدوى المنقولة جنسياً'),
        findsWidgets,
      );
    });

    testWidgets('STI result routes to referral landing page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            doctorsListProvider.overrideWith(
              (ref) => const AsyncValue<List<UserModel>>.data(<UserModel>[]),
            ),
          ],
          child: const MaterialApp(
            home: QuizResultScreen(
              quiz: QuizData.stiExposureRiskQuiz,
              answers: {2: 3, 3: 3, 7: 3, 9: 3},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bookingCta = find.text(
        'احجز موعداً مع أطباء الذكورة والعقم والبروستات',
      );
      await tester.ensureVisible(bookingCta);
      await tester.pumpAndSettle();
      await tester.tap(bookingCta, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('التوصية الطبية المناسبة'), findsOneWidget);
      expect(find.text('المتابعة إلى حجز الموعد'), findsOneWidget);
    });
  });
}
