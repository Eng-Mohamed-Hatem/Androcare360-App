import 'package:elajtech/features/patient/self_assessment/data/quiz_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuizData new assessments', () {
    test('male fertility delay result bands stay stable', () {
      final low = QuizData.getResults(QuizData.maleFertilityDelayQuizId, const {
        1: 0,
        2: 0,
      }).first;
      final high = QuizData.getResults(
        QuizData.maleFertilityDelayQuizId,
        const {1: 3, 2: 3, 5: 3, 10: 3, 16: 3, 17: 3, 23: 3, 24: 3},
      ).first;

      expect(low.interpretation, 'ملخص التقييم الشخصي لخصوبة الرجل');
      expect(high.interpretation, 'من المناسب مراجعة مختص في خصوبة الرجال');
    });

    test('sti exposure result bands stay stable', () {
      final low = QuizData.getResults(QuizData.stiExposureRiskQuizId, const {
        3: 0,
        4: 0,
      }).first;
      final high = QuizData.getResults(QuizData.stiExposureRiskQuizId, const {
        2: 3,
        3: 3,
        5: 3,
        7: 3,
        9: 3,
      }).first;

      expect(low.interpretation, 'ملخص التقييم الشخصي للعدوى المنقولة جنسياً');
      expect(
        high.interpretation,
        'من المناسب مراجعة الطبيب في أقرب فرصة مناسبة',
      );
    });
  });
}
