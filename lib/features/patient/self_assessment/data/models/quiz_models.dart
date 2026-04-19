class QuizModel {
  const QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
  });
  final String id;
  final String title;
  final String description;
  final List<QuestionModel> questions;
}

class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.text,
    required this.options,
  });
  final int id;
  final String text;
  final List<OptionModel> options;
}

class OptionModel {
  const OptionModel({required this.text, required this.score});
  final String text;
  final int score;
}

class QuizResultModel {
  // Store color as int to be serializable if needed

  const QuizResultModel({
    required this.score,
    required this.interpretation,
    required this.advice,
    required this.colorValue,
  });
  final int score;
  final String interpretation;
  final String advice;
  final int colorValue;
}

class AssessmentReferralContext {
  const AssessmentReferralContext({
    required this.referralSessionId,
    required this.assessmentId,
    required this.assessmentTitle,
    required this.resultBand,
    required this.rawScore,
    required this.referralTargetKey,
    required this.completedAt,
    required this.sourceScreen,
    this.patientId,
    this.specializationHints = const [],
  });

  static const String maleFertilityInfertilityProstateTargetKey =
      'male_fertility_infertility_prostate';

  final String referralSessionId;
  final String assessmentId;
  final String assessmentTitle;
  final String resultBand;
  final int rawScore;
  final String referralTargetKey;
  final DateTime completedAt;
  final String sourceScreen;
  final String? patientId;
  final List<String> specializationHints;

  bool get isHighPriority => resultBand == 'high';
  bool get isMediumPriority => resultBand == 'medium';
}
