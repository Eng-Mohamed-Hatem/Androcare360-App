import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/patient/appointments/presentation/screens/select_doctor_for_appointment_screen.dart';
import 'package:elajtech/features/patient/home/presentation/screens/patient_home_screen.dart';
import 'package:elajtech/features/patient/self_assessment/data/models/quiz_models.dart';
import 'package:elajtech/features/patient/self_assessment/data/quiz_data.dart';
import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    required this.quiz,
    required this.answers,
    super.key,
  });
  final QuizModel quiz;
  final Map<int, int> answers;

  @override
  Widget build(BuildContext context) {
    // Get result based on score strategy
    final result = QuizData.getResults(quiz.id, answers).first;
    final color = Color(result.colorValue);

    // Score to display in the circle
    final displayScore = result.score;
    // Determine max score based on quiz type
    final maxScore = quiz.id == QuizData.prematureEjaculationQuizId
        ? 20
        : quiz.id == QuizData.iief5QuizId
        ? 25
        : quiz.id == QuizData.adamQuizId
        ? 10
        : 35;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Score Indicator
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: displayScore / maxScore.toDouble(),
                        strokeWidth: 12,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$displayScore',
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'من $maxScore',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Result Title
              Text(
                result.interpretation,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Result Advice
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 32, color: color),
                    const SizedBox(height: 16),
                    Text(
                      result.advice,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Actions
              // Show booking button if score is high enough
              // For PE: >= 9. For IPSS: >= 8 (Moderate/Severe)
              if (_shouldShowBookingButton(quiz.id, displayScore)) ...[
                ElevatedButton(
                  onPressed: () async {
                    // Navigate to Book Appointment
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            const SelectDoctorForAppointmentScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'حجز موعد مع الطبيب',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              OutlinedButton(
                onPressed: () async {
                  await Navigator.pushAndRemoveUntil<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const PatientHomeScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'العودة للرئيسية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _shouldShowBookingButton(String quizId, int score) {
    if (quizId == QuizData.prematureEjaculationQuizId) {
      return score >= 9;
    } else if (quizId == QuizData.ipssQuizId) {
      return score >= 8; // Moderate or Severe
    } else if (quizId == QuizData.iief5QuizId) {
      return score < 22; // Anything less than 22 (Normal) needs attention
    } else if (quizId == QuizData.adamQuizId) {
      // For ADAM, logic is complex (Q1 or Q7 or >3 Yes).
      // Since we pass 'score' which is just the count, we need to pass answers to be accurate.
      // However, we calculated 'Interpretation' and 'Color' in QuizData based on the same logic.
      // If Color is Red (0xFFF44336), it's Positive.
      // Let's rely on the widget.answers to re-check specific questions if needed,
      // OR simpler: check if the calculated result suggests it.
      // But _shouldShowBookingButton currently only takes score.
      // Let's re-calculate logic here using widget.answers which is available in the class scope.

      final isQ1Yes = answers[1] == 1;
      final isQ7Yes = answers[7] == 1;
      final isMoreThan3Yes = score > 3;
      return isQ1Yes || isQ7Yes || isMoreThan3Yes;
    }
    return false;
  }
}
