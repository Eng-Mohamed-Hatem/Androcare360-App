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
