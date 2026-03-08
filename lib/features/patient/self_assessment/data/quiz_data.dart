import 'package:elajtech/features/patient/self_assessment/data/models/quiz_models.dart';

class QuizData {
  static const String prematureEjaculationQuizId = 'pe_quiz_001';
  static const String ipssQuizId = 'ipss_quiz_001';
  static const String iief5QuizId = 'iief5_quiz_001';
  static const String adamQuizId = 'adam_quiz_001';

  static const QuizModel prematureEjaculationQuiz = QuizModel(
    id: prematureEjaculationQuizId,
    title: 'تقييم سرعة القذف',
    description:
        'يرجى قراءة كل سؤال واختيار الإجابة التي تعبّر عن حالتك خلال الفترة الماضية. لا توجد إجابات صحيحة أو خاطئة، وإنما المطلوب وصف تجربتك العامة.',
    questions: [
      QuestionModel(
        id: 1,
        text: 'ما مدى صعوبة تأخير القذف لديك؟',
        options: [
          OptionModel(text: 'ليست صعبة إطلاقاً', score: 0),
          OptionModel(text: 'صعبة قليلاً', score: 1),
          OptionModel(text: 'متوسطة الصعوبة', score: 2),
          OptionModel(text: 'صعبة جداً', score: 3),
          OptionModel(text: 'صعبة للغاية', score: 4),
        ],
      ),
      QuestionModel(
        id: 2,
        text: 'هل تقذف قبل أن ترغب في ذلك؟',
        options: [
          OptionModel(text: '(0%) أبداً أو نادراً جداً', score: 0),
          OptionModel(text: '(25%) أقل من نصف المرات', score: 1),
          OptionModel(text: '(50%) حوالي نصف المرات', score: 2),
          OptionModel(text: '(75%) أكثر من نصف المرات', score: 3),
          OptionModel(text: '(100%) دائماً أو تقريباً دائماً', score: 4),
        ],
      ),
      QuestionModel(
        id: 3,
        text: 'هل تقذف بعد تحفيز بسيط جداً؟',
        options: [
          OptionModel(text: 'أبداً', score: 0),
          OptionModel(text: 'قليلاً', score: 1),
          OptionModel(text: 'بشكل متوسط', score: 2),
          OptionModel(text: 'كثيراً', score: 3),
          OptionModel(text: 'دائماً', score: 4),
        ],
      ),
      QuestionModel(
        id: 4,
        text: 'هل تشعر بالإحباط بسبب القذف قبل الوقت الذي ترغب فيه؟',
        options: [
          OptionModel(text: 'لا أشعر إطلاقاً بالإحباط', score: 0),
          OptionModel(text: 'أشعر بإحباط بسيط', score: 1),
          OptionModel(text: 'إحباط متوسط', score: 2),
          OptionModel(text: 'إحباط كبير', score: 3),
          OptionModel(text: 'إحباط شديد جداً', score: 4),
        ],
      ),
      QuestionModel(
        id: 5,
        text: 'ما مدى قلقك من أن وقت القذف لديك لا يُرضي شريكتك؟',
        options: [
          OptionModel(text: 'لست قلقاً إطلاقاً', score: 0),
          OptionModel(text: 'قلق قليلاً', score: 1),
          OptionModel(text: 'قلق متوسط', score: 2),
          OptionModel(text: 'قلق جداً', score: 3),
          OptionModel(text: 'قلق بشدة بالغة', score: 4),
        ],
      ),
    ],
  );

  static const QuizModel ipssQuiz = QuizModel(
    id: ipssQuizId,
    title: 'استبيان الأعراض البولية الدولي (IPSS)',
    description:
        'يرجى قراءة كل سؤال وتحديد الإجابة الأنسب التي تصف حالتك خلال الشهر الماضي.',
    questions: [
      QuestionModel(
        id: 1,
        text:
            'الإفراغ غير الكامل: خلال الشهر الماضي، كم مرة شعرت بعدم تفريغ المثانة تماماً بعد التبول؟',
        options: _ipssOptions,
      ),
      QuestionModel(
        id: 2,
        text:
            'تكرار التبول: خلال الشهر الماضي، كم مرة احتجت للتبول مرة أخرى خلال ساعتين من آخر مرة تبولت فيها؟',
        options: _ipssOptions,
      ),
      QuestionModel(
        id: 3,
        text:
            'التقطع: خلال الشهر الماضي، كم مرة لاحظت أن تدفق البول يتوقف ويبدأ عدة مرات أثناء التبول؟',
        options: _ipssOptions,
      ),
      QuestionModel(
        id: 4,
        text:
            'الإلحاح البولي: خلال الشهر الماضي، كم مرة وجدت صعوبة في تأجيل التبول عندما تشعر بالحاجة؟',
        options: _ipssOptions,
      ),
      QuestionModel(
        id: 5,
        text:
            'ضعف تيار البول: خلال الشهر الماضي، كم مرة لاحظت أن تيار البول لديك ضعيف؟',
        options: _ipssOptions,
      ),
      QuestionModel(
        id: 6,
        text:
            'الدفع أو الكبس للتبول: خلال الشهر الماضي، كم مرة اضطررت إلى الدفع أو الكبس لبدء التبول؟',
        options: _ipssOptions,
      ),
      QuestionModel(
        id: 7,
        text:
            'التبول الليلي (Nocturia): خلال الشهر الماضي، كم مرة في الغالب تستيقظ أثناء الليل للتبول (من وقت النوم حتى الصباح)؟',
        options: [
          OptionModel(text: 'لا شيء', score: 0),
          OptionModel(text: 'مرة واحدة', score: 1),
          OptionModel(text: 'مرتين', score: 2),
          OptionModel(text: 'ثلاث مرات', score: 3),
          OptionModel(text: 'أربع مرات', score: 4),
          OptionModel(text: 'خمس مرات أو أكثر', score: 5),
        ],
      ),
      QuestionModel(
        id: 8,
        text:
            'جودة الحياة بسبب الأعراض البولية: إذا كان عليك أن تقضي بقية حياتك بحالتك البولية الحالية، فكيف سيكون شعورك حيال ذلك؟',
        options: [
          OptionModel(text: 'مسرور جداً', score: 0),
          OptionModel(text: 'مسرور', score: 1),
          OptionModel(text: 'راضٍ أغلب الوقت', score: 2),
          OptionModel(text: 'متردد بين الرضا وعدم الرضا', score: 3),
          OptionModel(text: 'غير راضٍ أغلب الوقت', score: 4),
          OptionModel(text: 'غير راضٍ', score: 5),
          OptionModel(text: 'يائس جداً', score: 6),
        ],
      ),
    ],
  );

  static const List<OptionModel> _ipssOptions = [
    OptionModel(text: 'أبداً', score: 0),
    OptionModel(text: 'أقل من مرة واحدة من كل خمس مرات', score: 1),
    OptionModel(text: 'أقل من نصف المرات', score: 2),
    OptionModel(text: 'حوالي نصف المرات', score: 3),
    OptionModel(text: 'أكثر من نصف المرات', score: 4),
    OptionModel(text: 'دائماً تقريباً', score: 5),
  ];

  static const QuizModel iief5Quiz = QuizModel(
    id: iief5QuizId,
    title: 'استبيان التقييم الدولي للانتصاب (IIEF-5)',
    description:
        'يرجى قراءة كل سؤال واختيار الإجابة الأنسب لك خلال الأسابيع الأربعة الماضية.',
    questions: [
      QuestionModel(
        id: 1,
        text:
            'خلال الشهر الماضي، كم مرة تمكنت من الحصول على انتصاب عند التحفيز الجنسي؟',
        options: _iiefOptions,
      ),
      QuestionModel(
        id: 2,
        text:
            'خلال الشهر الماضي، عندما حصلت على انتصاب، كم مرة كان كافياً للإيلاج؟',
        options: _iiefOptions,
      ),
      QuestionModel(
        id: 3,
        text:
            'خلال الشهر الماضي، كم مرة تمكنت من الحفاظ على الانتصاب بعد الإيلاج؟',
        options: _iiefOptions,
      ),
      QuestionModel(
        id: 4,
        text:
            'خلال الشهر الماضي، كم مرة كان الحفاظ على الانتصاب حتى نهاية الجماع؟',
        options: _iiefOptions,
      ),
      QuestionModel(
        id: 5,
        text:
            'خلال الشهر الماضي، كيف تقيم ثقتك في قدرتك على تحقيق الانتصاب والمحافظة عليه؟',
        options: _iiefOptions,
      ),
    ],
  );

  static const List<OptionModel> _iiefOptions = [
    OptionModel(text: 'أبداً', score: 1),
    OptionModel(text: 'نادراً', score: 2),
    OptionModel(text: 'أحياناً', score: 3),
    OptionModel(text: 'غالباً', score: 4),
    OptionModel(text: 'دائماً', score: 5),
  ];

  static const QuizModel adamQuiz = QuizModel(
    id: adamQuizId,
    title: 'استبيان نقص هرمون الذكورة (ADAM)',
    description:
        'يُستخدم هذا الاستبيان لتحديد الأعراض المحتملة الناتجة عن انخفاض مستوى هرمون التستوستيرون.',
    questions: [
      QuestionModel(
        id: 1,
        text: 'هل تعاني من انخفاض في الرغبة الجنسية (الدافع الجنسي)؟',
        options: _yesNoOptions,
      ),
      QuestionModel(
        id: 2,
        text: 'هل تشعر بانخفاض في مستوى الطاقة والنشاط؟',
        options: _yesNoOptions,
      ),
      QuestionModel(
        id: 3,
        text: 'هل لاحظت ضعفاً في القوة أو القدرة على التحمل؟',
        options: _yesNoOptions,
      ),
      QuestionModel(
        id: 4,
        text: 'هل فقدت شيئاً من طولك في الفترة الأخيرة؟',
        options: _yesNoOptions,
      ),
      QuestionModel(
        id: 5,
        text: 'هل تشعر بانخفاض في متعة الحياة أو الإحساس بالسعادة؟',
        options: _yesNoOptions,
      ),
      QuestionModel(
        id: 6,
        text: 'هل تشعر بالحزن أو العصبية أو المزاج السيئ؟',
        options: _yesNoOptions,
      ),
      QuestionModel(
        id: 7,
        text: 'هل أصبحت الانتصابات لديك أقل قوة من قبل؟',
        options: _yesNoOptions,
      ),
      QuestionModel(
        id: 8,
        text: 'هل لاحظت تراجعاً في قدرتك على ممارسة الرياضة؟',
        options: _yesNoOptions,
      ),
      QuestionModel(
        id: 9,
        text: 'هل تميل إلى النوم بعد تناول العشاء؟',
        options: _yesNoOptions,
      ),
      QuestionModel(
        id: 10,
        text: 'هل لاحظت انخفاضاً في أدائك أو إنتاجيتك في العمل مؤخراً؟',
        options: _yesNoOptions,
      ),
    ],
  );

  static const List<OptionModel> _yesNoOptions = [
    OptionModel(text: 'نعم', score: 1),
    OptionModel(text: 'لا', score: 0),
  ];

  static List<QuizResultModel> getResults(
    String quizId,
    Map<int, int> answers,
  ) {
    if (quizId == prematureEjaculationQuizId) {
      return _getPeResults(answers);
    } else if (quizId == ipssQuizId) {
      return _getIpssResults(answers);
    } else if (quizId == iief5QuizId) {
      return _getIief5Results(answers);
    } else if (quizId == adamQuizId) {
      return _getAdamResults(answers);
    }
    return [];
  }

  static List<QuizResultModel> _getPeResults(Map<int, int> answers) {
    var score = 0;
    answers.forEach((_, val) => score += val);

    if (score <= 8) {
      return [
        QuizResultModel(
          score: score,
          interpretation: 'طبيعي (لا يوجد اضطراب سرعة القذف)',
          advice: 'نتيجتك طبيعية ولا تدعو للقلق.',
          colorValue: 0xFF4CAF50, // Green
        ),
      ];
    } else if (score <= 10) {
      return [
        QuizResultModel(
          score: score,
          interpretation: 'مشكوك فيه (قد توجد علامات أولية)',
          advice: 'يمكنك حجز موعد للاطمئنان.',
          colorValue: 0xFFFF9800, // Orange
        ),
      ];
    } else {
      return [
        QuizResultModel(
          score: score,
          interpretation: 'سرعة قذف مؤكدة سريرياً',
          advice: 'يمكنك حجز موعد.',
          colorValue: 0xFFF44336, // Red
        ),
      ];
    }
  }

  static List<QuizResultModel> _getIpssResults(Map<int, int> answers) {
    // Determine score from Q1 to Q7 only
    var totalScore = 0;
    for (var i = 1; i <= 7; i++) {
      totalScore += answers[i] ?? 0;
    }

    // Quality of Life (Q8)
    // int qolScore = answers[8] ?? 0; // Not used for severity calculation

    // Logic:
    // 0-7: Mild
    // 8-19: Moderate
    // 20-35: Severe

    String interpretation;
    String advice;
    int colorValue;

    if (totalScore <= 7) {
      interpretation = 'أعراض خفيفة';
      advice =
          'الأعراض خفيفة وقد لا تحتاج لتدخل طبي عاجل. يُنصح بالمتابعة الدورية.';
      colorValue = 0xFF4CAF50; // Green
    } else if (totalScore <= 19) {
      interpretation = 'أعراض متوسطة';
      advice =
          'أعراضك متوسطة الشدة. يُفضل استشارة طبيب لتقييم الحالة وبدء العلاج المناسب.';
      colorValue = 0xFFFF9800; // Orange
    } else {
      interpretation = 'أعراض شديدة';
      advice =
          'أعراضك شديدة وتؤثر بشكل ملحوظ على حياتك. نوصي بشدة بحجز موعد عاجل مع الطبيب.';
      colorValue = 0xFFF44336; // Red
    }

    return [
      QuizResultModel(
        score: totalScore,
        interpretation: interpretation,
        advice: advice,
        colorValue: colorValue,
      ),
    ];
  }

  static List<QuizResultModel> _getIief5Results(Map<int, int> answers) {
    var totalScore = 0;
    answers.forEach((_, val) => totalScore += val);

    // Ranges:
    // 22-25: Normal
    // 17-21: Mild
    // 12-16: Mild to Moderate
    // 8-11: Moderate to Severe
    // 5-7: Severe

    String interpretation;
    String advice;
    int colorValue;

    if (totalScore >= 22) {
      interpretation = 'طبيعي';
      advice = 'وظيفة الانتصاب لديك طبيعية. حافظ على نمط حياة صحي.';
      colorValue = 0xFF4CAF50; // Green
    } else if (totalScore >= 17) {
      interpretation = 'ضعف بسيط';
      advice = 'هناك ضعف بسيط في الانتصاب. يُنصح باستشارة طبيب للاطمئنان.';
      colorValue = 0xFFCDDC39; // Lime
    } else if (totalScore >= 12) {
      interpretation = 'ضعف متوسط';
      advice = 'تعاني من ضعف متوسط. زيارة الطبيب مهمة للتقييم والعلاج.';
      colorValue = 0xFFFF9800; // Orange
    } else if (totalScore >= 8) {
      interpretation = 'ضعف متوسط إلى شديد';
      advice = 'النتيجة تشير إلى ضعف ملحوظ. نوصي بشدة بحجز موعد لبدء العلاج.';
      colorValue = 0xFFFF5722; // Deep Orange
    } else {
      interpretation = 'ضعف شديد';
      advice =
          'تعاني من ضعف شديد في الانتصاب. العلاج الطبي ضروري لتحسين الحالة.';
      colorValue = 0xFFF44336; // Red
    }

    return [
      QuizResultModel(
        score: totalScore,
        interpretation: interpretation,
        advice: advice,
        colorValue: colorValue,
      ),
    ];
  }

  static List<QuizResultModel> _getAdamResults(Map<int, int> answers) {
    var yesCount = 0;
    answers.forEach((_, val) => yesCount += val); // val is 1 for Yes, 0 for No

    final isQ1Yes = answers[1] == 1;
    final isQ7Yes = answers[7] == 1;
    final isMoreThan3Yes = yesCount > 3;

    // Positive if Q1 or Q7 is Yes, or >3 total Yes
    final isPositive = isQ1Yes || isQ7Yes || isMoreThan3Yes;

    return [
      QuizResultModel(
        score: yesCount, // Store raw count for display (e.g., 4/10)
        interpretation: isPositive
            ? 'احتمالية نقص هرمون الذكورة'
            : 'طبيعي (منخفض الاحتمالية)',
        advice: isPositive
            ? 'قد يكون لديك احتمال انخفاض في مستوى هرمون التستوستيرون. نوصي بحجز موعد مع الطبيب لإجراء الفحوصات اللازمة.'
            : 'الأعراض لا تشير بشكل قوي إلى نقص الهرمون، لكن حافظ على نمط حياة صحي.',
        colorValue: isPositive
            ? 0xFFF44336 // Red
            : 0xFF4CAF50, // Green
      ),
    ];
  }
}
