import 'package:elajtech/features/patient/self_assessment/data/models/quiz_models.dart';

class QuizData {
  static const String prematureEjaculationQuizId = 'pe_quiz_001';
  static const String ipssQuizId = 'ipss_quiz_001';
  static const String iief5QuizId = 'iief5_quiz_001';
  static const String adamQuizId = 'adam_quiz_001';
  static const String maleFertilityDelayQuizId = 'male_fertility_delay_001';
  static const String stiExposureRiskQuizId = 'sti_exposure_risk_001';

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

  static const List<OptionModel> _yesNoRiskOptions = [
    OptionModel(text: 'لا', score: 0),
    OptionModel(text: 'غير متأكد', score: 1),
    OptionModel(text: 'نعم', score: 2),
  ];

  static const List<OptionModel> _yesNoHighRiskOptions = [
    OptionModel(text: 'لا', score: 0),
    OptionModel(text: 'نعم', score: 3),
  ];

  static const List<OptionModel> _willingnessOptions = [
    OptionModel(text: 'نعم', score: 0),
    OptionModel(text: 'ربما', score: 1),
    OptionModel(text: 'لا', score: 2),
  ];

  static const QuizModel maleFertilityDelayQuiz = QuizModel(
    id: maleFertilityDelayQuizId,
    title: 'تقييم تأخر الإنجاب عند الرجل',
    description:
        'تقييم شخصي يساعدك على مراجعة عوامل قد تؤثر في خصوبة الرجل. هذا التقييم تثقيفي ولا يُعد تشخيصاً، لكنه قد يساعدك في معرفة متى يكون من المناسب استشارة الطبيب.',
    questions: [
      QuestionModel(
        id: 1,
        text: 'ما الفئة العمرية الأقرب لك؟',
        options: [
          OptionModel(text: 'أقل من 25 سنة', score: 0),
          OptionModel(text: '25 - 34 سنة', score: 0),
          OptionModel(text: '35 - 39 سنة', score: 1),
          OptionModel(text: '40 - 44 سنة', score: 2),
          OptionModel(text: '45 سنة أو أكثر', score: 3),
        ],
      ),
      QuestionModel(
        id: 2,
        text: 'منذ متى تحاول الإنجاب دون نجاح؟',
        options: [
          OptionModel(text: 'أقل من سنة', score: 0),
          OptionModel(text: '1 - 2 سنة', score: 1),
          OptionModel(text: '3 - 5 سنوات', score: 2),
          OptionModel(text: 'أكثر من 5 سنوات', score: 3),
        ],
      ),
      QuestionModel(
        id: 3,
        text: 'ما نوع تأخر الإنجاب لديك؟',
        options: [
          OptionModel(text: 'أولي (لم يحدث حمل من قبل)', score: 2),
          OptionModel(text: 'ثانوي (حدث حمل سابقاً)', score: 1),
        ],
      ),
      QuestionModel(
        id: 4,
        text: 'كم مرة يحدث الجماع عادة خلال الأسبوع؟',
        options: [
          OptionModel(text: 'أقل من مرة واحدة', score: 2),
          OptionModel(text: '1 - 2 مرات', score: 1),
          OptionModel(text: '3 - 4 مرات', score: 0),
          OptionModel(text: 'أكثر من 4 مرات', score: 0),
        ],
      ),
      QuestionModel(
        id: 5,
        text: 'هل تعاني من ضعف في الانتصاب يؤثر على العلاقة الزوجية؟',
        options: [
          OptionModel(text: 'لا', score: 0),
          OptionModel(text: 'أحياناً', score: 2),
          OptionModel(text: 'غالباً', score: 3),
        ],
      ),
      QuestionModel(
        id: 6,
        text: 'هل تعاني من سرعة القذف؟',
        options: [
          OptionModel(text: 'لا', score: 0),
          OptionModel(text: 'أحياناً', score: 1),
          OptionModel(text: 'نعم بشكل متكرر', score: 2),
        ],
      ),
      QuestionModel(
        id: 7,
        text: 'هل تعاني من انخفاض الرغبة الجنسية؟',
        options: [
          OptionModel(text: 'لا', score: 0),
          OptionModel(text: 'بشكل خفيف', score: 1),
          OptionModel(text: 'بشكل واضح أو متكرر', score: 2),
        ],
      ),
      QuestionModel(
        id: 8,
        text: 'هل لديك مشكلة في خروج السائل المنوي أو تشك بوجود قذف غير طبيعي؟',
        options: _yesNoRiskOptions,
      ),
      QuestionModel(
        id: 9,
        text: 'هل سبق أن عانيت من التهاب الخصية بعد النكاف؟',
        options: _yesNoHighRiskOptions,
      ),
      QuestionModel(
        id: 10,
        text: 'هل تم تشخيصك سابقاً بدوالي الخصية؟',
        options: _yesNoHighRiskOptions,
      ),
      QuestionModel(
        id: 11,
        text: 'هل سبق أن تعرضت لإصابة أو ضربة في الخصية؟',
        options: _yesNoRiskOptions,
      ),
      QuestionModel(
        id: 12,
        text: 'هل كانت لديك خصية معلقة في الطفولة؟',
        options: _yesNoHighRiskOptions,
      ),
      QuestionModel(
        id: 13,
        text: 'هل تعاني من السكري؟',
        options: _yesNoRiskOptions,
      ),
      QuestionModel(
        id: 14,
        text: 'هل تعاني من ارتفاع ضغط الدم أو تتناول علاجاً دائماً له؟',
        options: _yesNoRiskOptions,
      ),
      QuestionModel(
        id: 15,
        text: 'هل سبق أن أجريت عملية فتق إربي أو جراحة في منطقة العانة؟',
        options: _yesNoRiskOptions,
      ),
      QuestionModel(
        id: 16,
        text: 'هل سبق أن أجريت جراحة في الخصية أو كيس الصفن؟',
        options: _yesNoHighRiskOptions,
      ),
      QuestionModel(
        id: 17,
        text: 'هل سبق إجراء ربط للقنوات المنوية أو جراحة لإعادة توصيلها؟',
        options: _yesNoHighRiskOptions,
      ),
      QuestionModel(
        id: 18,
        text: 'ما وضع التدخين لديك حالياً؟',
        options: [
          OptionModel(text: 'لا أدخن', score: 0),
          OptionModel(text: 'مدخن سابق', score: 1),
          OptionModel(text: 'مدخن حالياً', score: 2),
        ],
      ),
      QuestionModel(
        id: 19,
        text: 'هل تتناول الكحول أو المواد المخدرة؟',
        options: [
          OptionModel(text: 'لا', score: 0),
          OptionModel(text: 'أحياناً', score: 1),
          OptionModel(text: 'نعم بشكل متكرر', score: 2),
        ],
      ),
      QuestionModel(
        id: 20,
        text:
            'هل تتعرض لحرارة مرتفعة بشكل متكرر (ساونا، حمامات ساخنة، بيئة عمل حارة)؟',
        options: [
          OptionModel(text: 'نادراً', score: 0),
          OptionModel(text: 'أحياناً', score: 1),
          OptionModel(text: 'نعم بشكل متكرر', score: 2),
        ],
      ),
      QuestionModel(
        id: 21,
        text:
            'هل تستخدم اللابتوب على الفخذ لفترات طويلة أو تجلس لفترات طويلة في حرارة عالية؟',
        options: _yesNoRiskOptions,
      ),
      QuestionModel(
        id: 22,
        text:
            'هل تتعرض في عملك لإشعاع أو مواد كيميائية أو معادن ثقيلة أو مبيدات؟',
        options: [
          OptionModel(text: 'لا', score: 0),
          OptionModel(text: 'لست متأكداً', score: 1),
          OptionModel(text: 'نعم', score: 2),
        ],
      ),
      QuestionModel(
        id: 23,
        text: 'هل سبق إجراء تحليل للسائل المنوي؟',
        options: [
          OptionModel(text: 'لا', score: 1),
          OptionModel(text: 'نعم وكانت النتيجة طبيعية', score: 0),
          OptionModel(text: 'نعم وكانت النتيجة غير طبيعية', score: 3),
          OptionModel(text: 'نعم لكنني لا أعرف النتيجة', score: 1),
        ],
      ),
      QuestionModel(
        id: 24,
        text: 'إذا سبق تحليل السائل المنوي، فما أقرب وصف قيل لك؟',
        options: [
          OptionModel(text: 'لم أجر التحليل أو لا ينطبق', score: 0),
          OptionModel(text: 'قلة في العدد أو ضعف الحركة أو تشوهات', score: 2),
          OptionModel(
            text: 'انعدام الحيوانات المنوية أو قلة شديدة جداً',
            score: 3,
          ),
        ],
      ),
      QuestionModel(
        id: 25,
        text: 'هل سبق لك مراجعة مركز خصوبة أو عقم؟',
        options: _yesNoRiskOptions,
      ),
      QuestionModel(
        id: 26,
        text:
            'هل سبق الخضوع لمحاولة تلقيح داخل الرحم أو أطفال أنابيب أو حقن مجهري دون حدوث حمل؟',
        options: [
          OptionModel(text: 'لا', score: 0),
          OptionModel(text: 'نعم، مرة أو مرتين', score: 2),
          OptionModel(text: 'نعم، أكثر من مرتين', score: 3),
        ],
      ),
      QuestionModel(
        id: 27,
        text:
            'هل لدى الزوجة عامل معروف قد يؤثر في الإنجاب مثل ضعف التبويض أو انسداد القنوات أو بطانة الرحم المهاجرة؟',
        options: _yesNoRiskOptions,
      ),
      QuestionModel(
        id: 28,
        text:
            'هل أنت مستعد لمناقشة خيارات علاج الخصوبة مع الطبيب إذا أوصى بها؟',
        options: _willingnessOptions,
      ),
    ],
  );

  static const QuizModel stiExposureRiskQuiz = QuizModel(
    id: stiExposureRiskQuizId,
    title: 'تقييم مخاطر التعرض للعدوى المنقولة جنسياً',
    description:
        'تقييم شخصي سري يساعدك على مراجعة بعض عوامل التعرض والأعراض التي قد تستدعي مناقشة الطبيب. هذا التقييم تثقيفي ولا يُعد تشخيصاً أو بديلاً عن الفحوصات الطبية.',
    questions: [
      QuestionModel(
        id: 1,
        text: 'ما الفئة العمرية الأقرب لك؟',
        options: [
          OptionModel(text: 'أقل من 25 سنة', score: 1),
          OptionModel(text: '25 - 34 سنة', score: 1),
          OptionModel(text: '35 - 44 سنة', score: 0),
          OptionModel(text: '45 سنة أو أكثر', score: 0),
        ],
      ),
      QuestionModel(
        id: 2,
        text: 'كم عدد الشركاء الجنسيين خلال آخر 12 شهراً؟',
        options: [
          OptionModel(text: 'شريك واحد', score: 0),
          OptionModel(text: '2 - 3 شركاء', score: 2),
          OptionModel(text: 'أكثر من 3', score: 3),
          OptionModel(text: 'أفضل عدم الإجابة', score: 1),
        ],
      ),
      QuestionModel(
        id: 3,
        text: 'هل يحدث الجماع أحياناً أو غالباً دون استخدام واقٍ ذكري؟',
        options: [
          OptionModel(text: 'لا', score: 0),
          OptionModel(text: 'أحياناً', score: 2),
          OptionModel(text: 'غالباً أو دائماً', score: 3),
        ],
      ),
      QuestionModel(
        id: 4,
        text: 'هل لديك شريك جنسي جديد خلال آخر 6 أشهر؟',
        options: _yesNoRiskOptions,
      ),
      QuestionModel(
        id: 5,
        text: 'هل سبق تشخيصك بمرض أو عدوى منقولة جنسياً؟',
        options: [
          OptionModel(text: 'لا', score: 0),
          OptionModel(text: 'غير متأكد', score: 1),
          OptionModel(text: 'نعم', score: 3),
        ],
      ),
      QuestionModel(
        id: 6,
        text:
            'هل شريكك الحالي أو السابق مصاب أو مشتبه بإصابته بعدوى منقولة جنسياً؟',
        options: [
          OptionModel(text: 'لا', score: 0),
          OptionModel(text: 'غير متأكد', score: 2),
          OptionModel(text: 'نعم', score: 3),
        ],
      ),
      QuestionModel(
        id: 7,
        text: 'هل تعاني حالياً من إفرازات غير طبيعية من القضيب؟',
        options: _yesNoHighRiskOptions,
      ),
      QuestionModel(
        id: 8,
        text: 'هل تعاني من حرقة أثناء التبول؟',
        options: _yesNoRiskOptions,
      ),
      QuestionModel(
        id: 9,
        text: 'هل لديك تقرحات أو بثور في الأعضاء التناسلية؟',
        options: _yesNoHighRiskOptions,
      ),
      QuestionModel(
        id: 10,
        text: 'هل تعاني من حكة أو تهيج أو طفح جلدي في المنطقة التناسلية؟',
        options: _yesNoRiskOptions,
      ),
      QuestionModel(
        id: 11,
        text: 'هل تعاني من ألم في الخصيتين أو ألم أثناء الجماع؟',
        options: _yesNoRiskOptions,
      ),
      QuestionModel(
        id: 12,
        text: 'هل تعاني من حمى أو تضخم في الغدد اللمفاوية مع هذه الأعراض؟',
        options: _yesNoRiskOptions,
      ),
      QuestionModel(
        id: 13,
        text:
            'هل ظهر طفح جلدي عام في الجسم أو التهاب حلق بعد ممارسة الجنس الفموي؟',
        options: _yesNoRiskOptions,
      ),
      QuestionModel(
        id: 14,
        text: 'هل سبق تشخيصك بفيروس نقص المناعة أو التهاب الكبد B أو C؟',
        options: [
          OptionModel(text: 'لا', score: 0),
          OptionModel(text: 'أفضل عدم الإجابة', score: 1),
          OptionModel(text: 'نعم', score: 3),
        ],
      ),
      QuestionModel(
        id: 15,
        text: 'هل سبق أن أجريت فحوصات للأمراض المنقولة جنسياً؟',
        options: [
          OptionModel(text: 'أبداً', score: 2),
          OptionModel(text: 'أجريتها منذ أكثر من سنة', score: 1),
          OptionModel(text: 'أجريتها خلال آخر سنة', score: 0),
          OptionModel(text: 'لست متأكداً', score: 1),
        ],
      ),
      QuestionModel(
        id: 16,
        text: 'هل تلقيت لقاح التهاب الكبد B؟',
        options: [
          OptionModel(text: 'نعم', score: 0),
          OptionModel(text: 'لا', score: 1),
          OptionModel(text: 'لست متأكداً', score: 1),
        ],
      ),
      QuestionModel(
        id: 17,
        text: 'هل تلقيت لقاح فيروس الورم الحليمي HPV إذا كان موصى به لك؟',
        options: [
          OptionModel(text: 'نعم', score: 0),
          OptionModel(text: 'لا', score: 1),
          OptionModel(text: 'لا أعرف', score: 1),
        ],
      ),
      QuestionModel(
        id: 18,
        text: 'هل توافق على إجراء فحوصات أو تحاليل إذا أوصى الطبيب بذلك؟',
        options: _willingnessOptions,
      ),
      QuestionModel(
        id: 19,
        text: 'هل تشعر بالراحة لمناقشة الأعراض أو المخاطر مع الطبيب بشكل سري؟',
        options: _willingnessOptions,
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
    } else if (quizId == maleFertilityDelayQuizId) {
      return _getMaleFertilityDelayResults(answers);
    } else if (quizId == stiExposureRiskQuizId) {
      return _getStiExposureRiskResults(answers);
    }
    return [];
  }

  static String getStandardRecommendation(String quizId) {
    if (quizId == maleFertilityDelayQuizId || quizId == stiExposureRiskQuizId) {
      return 'بناءً على إجاباتك، نوصي بحجز موعد مع أحد أطبائنا المختصين.';
    }

    return 'إذا كانت الأعراض مؤثرة عليك أو مستمرة، فقد تستفيد من مناقشتها مع الطبيب المختص.';
  }

  static String getDisclaimer(String quizId) {
    if (quizId == maleFertilityDelayQuizId || quizId == stiExposureRiskQuizId) {
      return 'هذا التقييم أداة تثقيفية ولا يُعد تشخيصاً طبياً. التشخيص النهائي والخطة العلاجية يحددهما الطبيب بعد التقييم السريري والفحوصات اللازمة.';
    }

    return 'هذا التقييم للاستخدام التثقيفي ولا يغني عن التقييم الطبي المباشر.';
  }

  static String getBookingTitle(String quizId) {
    if (quizId == maleFertilityDelayQuizId) {
      return 'احجز موعداً مع طبيب خصوبة الرجال';
    }

    if (quizId == stiExposureRiskQuizId) {
      return 'احجز موعداً مع طبيب مختص';
    }

    return 'حجز موعد مع الطبيب';
  }

  static String getBookingScreenTitle(String quizId) {
    if (quizId == maleFertilityDelayQuizId) {
      return 'اختر طبيب خصوبة الرجال';
    }

    if (quizId == stiExposureRiskQuizId) {
      return 'اختر الطبيب المناسب';
    }

    return 'اختر الطبيب';
  }

  static List<String> getSpecializationHints(String quizId) {
    if (quizId == maleFertilityDelayQuizId) {
      return const ['طب الذكورة', 'تأخر الإنجاب', 'العقم'];
    }

    if (quizId == stiExposureRiskQuizId) {
      return const ['الأمراض الجنسية المعدية', 'طب الذكورة', 'جراحة مسالك'];
    }

    return const [];
  }

  static int getRawScore(Map<int, int> answers) {
    var totalScore = 0;
    answers.forEach((_, val) => totalScore += val);
    return totalScore;
  }

  static String getResultBand(String quizId, Map<int, int> answers) {
    if (quizId == stiExposureRiskQuizId) {
      return getStiExposureRiskBand(answers);
    }

    return 'standard';
  }

  static String getStiExposureRiskBand(Map<int, int> answers) {
    final totalScore = getRawScore(answers);
    final hasUrgentSymptoms =
        answers[6] == 3 || answers[7] == 3 || answers[9] == 3;

    if (hasUrgentSymptoms || totalScore > 14) {
      return 'high';
    }

    if (totalScore > 6) {
      return 'medium';
    }

    return 'low';
  }

  static String getBookingSupportingText(String quizId, Map<int, int> answers) {
    if (quizId != stiExposureRiskQuizId) {
      return 'إذا رغبت في مناقشة الأعراض أو متابعة التقييم، يمكنك حجز موعد مع الطبيب المختص.';
    }

    switch (getStiExposureRiskBand(answers)) {
      case 'high':
        return 'نوصي بحجز موعد مع الطبيب المختص في أقرب فرصة مناسبة، خاصة عند استمرار الأعراض.';
      case 'medium':
        return 'يفضل مناقشة هذه النتيجة مع الطبيب المختص لتحديد الفحوصات أو الخطوات التالية.';
      default:
        return 'يمكنك حجز موعد سري مع الطبيب المختص للاطمئنان أو مناقشة أي تعرض حديث.';
    }
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

  static List<QuizResultModel> _getMaleFertilityDelayResults(
    Map<int, int> answers,
  ) {
    var totalScore = 0;
    answers.forEach((_, val) => totalScore += val);

    String interpretation;
    String advice;
    int colorValue;

    if (totalScore <= 10) {
      interpretation = 'ملخص التقييم الشخصي لخصوبة الرجل';
      advice =
          'إجاباتك لا تشير إلى عدد كبير من العوامل المعروفة، لكن تأخر الإنجاب قد يتأثر بعدة أسباب لدى الرجل أو الزوجة. من المفيد مناقشة التاريخ الصحي ونتائج التحاليل - إن وُجدت - مع الطبيب المختص.';
      colorValue = 0xFF26A69A;
    } else if (totalScore <= 22) {
      interpretation = 'هناك عوامل تستحق مناقشتها مع المختص';
      advice =
          'تظهر في إجاباتك بعض العوامل التي قد تستحق تقييماً سريرياً، مثل نمط الحياة أو التاريخ المرضي أو نتائج الفحوصات السابقة. يمكن للطبيب أن يحدد إن كانت هناك حاجة لتحاليل إضافية أو خطة متابعة.';
      colorValue = 0xFFFFA726;
    } else {
      interpretation = 'من المناسب مراجعة مختص في خصوبة الرجال';
      advice =
          'تشير إجاباتك إلى وجود أكثر من عامل قد يؤثر في خصوبة الرجل أو يستدعي تقييماً طبياً أوضح. تجهيز أي نتائج سابقة مثل تحليل السائل المنوي أو العلاجات السابقة قد يساعد الطبيب في الزيارة.';
      colorValue = 0xFFEF5350;
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

  static List<QuizResultModel> _getStiExposureRiskResults(
    Map<int, int> answers,
  ) {
    var totalScore = 0;
    answers.forEach((_, val) => totalScore += val);

    String interpretation;
    String advice;
    int colorValue;

    if (totalScore <= 6) {
      interpretation = 'ملخص التقييم الشخصي للعدوى المنقولة جنسياً';
      advice =
          'إجاباتك لا تعكس عدداً كبيراً من عوامل الخطر المعلنة، ومع ذلك قد توجد بعض العدوى المنقولة جنسياً دون أعراض واضحة. إذا كانت لديك أي مخاوف أو تعرض حديث فمن الأفضل مناقشة الأمر مع الطبيب.';
      colorValue = 0xFF26A69A;
    } else if (totalScore <= 14) {
      interpretation = 'توجد عوامل أو أعراض تستحق التقييم';
      advice =
          'تشير إجاباتك إلى وجود بعض عوامل التعرض أو الأعراض التي تستحق مناقشتها مع الطبيب بشكل سري. قد يوصي الطبيب بفحوصات مناسبة حسب الأعراض والتاريخ الصحي.';
      colorValue = 0xFFFFA726;
    } else {
      interpretation = 'من المناسب مراجعة الطبيب في أقرب فرصة مناسبة';
      advice =
          'تشير إجاباتك إلى وجود عوامل أو أعراض متعددة قد تحتاج إلى تقييم طبي وفحوصات موجهة. لا يعني ذلك وجود تشخيص مؤكد، لكنه يجعل من المناسب ترتيب موعد مع طبيب مختص.';
      colorValue = 0xFFEF5350;
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
}
