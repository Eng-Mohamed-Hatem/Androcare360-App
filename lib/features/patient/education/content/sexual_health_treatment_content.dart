import 'package:elajtech/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class TreatmentInfo {
  const TreatmentInfo({
    required this.id,
    required this.title,
    required this.englishTitle,
    required this.summary,
    required this.tag,
    required this.icon,
    required this.color,
    required this.howItWorks,
    required this.useCases,
    required this.precautions,
    required this.sessionInfo,
    required this.expectedOutcome,
    required this.faqs,
  });

  final String id;
  final String title;
  final String englishTitle;
  final String summary;
  final String tag;
  final IconData icon;
  final Color color;
  final List<String> howItWorks;
  final List<String> useCases;
  final List<String> precautions;
  final List<String> sessionInfo;
  final List<String> expectedOutcome;
  final List<TreatmentFaq> faqs;
}

class TreatmentFaq {
  const TreatmentFaq({required this.question, required this.answer});

  final String question;
  final String answer;
}

const sexualHealthEducationDisclaimer =
    'هذه المعلومات لأغراض تثقيفية ولا تغني عن تقييم الطبيب المختص. تختلف ملاءمة العلاج ونتائجه من مريض لآخر.';

const sexualHealthTreatments = <TreatmentInfo>[
  TreatmentInfo(
    id: 'shockwave',
    title: 'العلاج بالموجات التصادمية',
    englishTitle: 'Shockwave Therapy - AndroWave',
    summary:
        'خيار غير جراحي قد يساعد بعض حالات ضعف الانتصاب المرتبطة بتدفق الدم بعد تقييم الطبيب.',
    tag: 'غير جراحي',
    icon: Icons.graphic_eq_rounded,
    color: AppColors.sexualHealth,
    howItWorks: [
      'يعتمد على إرسال موجات صوتية منخفضة الشدة إلى الأنسجة لتحفيز تكوين أوعية دموية جديدة وتحسين تدفق الدم.',
      'يُستخدم داخل العيادة ويستغرق وقتًا قصيرًا في كل جلسة.',
    ],
    useCases: [
      'ضعف الانتصاب الناتج عن قصور التروية الدموية.',
      'الحالات الخفيفة إلى المتوسطة حسب تقييم الطبيب.',
    ],
    precautions: [
      'اضطرابات النزف.',
      'وجود التهابات أو أورام أو إصابات نشطة في المنطقة.',
      'المرضى الذين يتناولون مميعات الدم يحتاجون إلى مراجعة الطبيب قبل البدء.',
    ],
    sessionInfo: [
      'عادة 6-9 جلسات.',
      'غالبًا جلستان أسبوعيًا حسب الخطة العلاجية.',
      'مدة الجلسة تقريبًا 15-20 دقيقة.',
    ],
    expectedOutcome: [
      'قد يظهر التحسن تدريجيًا خلال أسابيع.',
      'الاستجابة تختلف بين المرضى بحسب السبب وشدة الحالة.',
    ],
    faqs: [
      TreatmentFaq(
        question: 'هل يناسب جميع المرضى؟',
        answer:
            'لا، يحدد الطبيب ملاءمته بناءً على سبب ضعف الانتصاب والحالة الصحية العامة.',
      ),
      TreatmentFaq(
        question: 'متى تظهر النتيجة؟',
        answer:
            'عادة يكون التحسن تدريجيًا خلال الأسابيع التالية للجلسات وليس بشكل فوري.',
      ),
    ],
  ),
  TreatmentInfo(
    id: 'prp',
    title: 'حقن PRP',
    englishTitle: 'PRP Injection - Andro PRP',
    summary:
        'إجراء داخل العيادة يعتمد على البلازما الغنية بالصفائح الدموية المأخوذة من دم المريض.',
    tag: 'إجراء داخل العيادة',
    icon: Icons.vaccines_outlined,
    color: Colors.deepOrange,
    howItWorks: [
      'يتم سحب عينة من دم المريض ثم فصل البلازما الغنية بالصفائح الدموية وحقنها بواسطة الطبيب.',
      'الهدف هو دعم تجدد الأنسجة وتحسين البيئة الوعائية في المنطقة عند اختيار هذا العلاج للحالة المناسبة.',
    ],
    useCases: [
      'بعض حالات ضعف الانتصاب الخفيف إلى المتوسط.',
      'قد يُستخدم كخيار داعم مع علاجات أخرى عندما يرى الطبيب ذلك مناسبًا.',
    ],
    precautions: [
      'اضطرابات تخثر الدم.',
      'وجود التهابات موضعية.',
      'بعض أمراض الدم أو الحالات التي تتطلب تقييمًا خاصًا قبل الإجراء.',
    ],
    sessionInfo: [
      'عدد الجلسات يختلف حسب الحالة.',
      'غالبًا ما تكون الخطة بين 3-4 جلسات وفق تقييم الطبيب.',
      'مدة الجلسة تقريبًا 30-45 دقيقة.',
    ],
    expectedOutcome: [
      'قد يتحسن الأداء الجنسي تدريجيًا خلال أسابيع.',
      'النتائج متفاوتة بين المرضى ولا يمكن ضمان استجابة موحدة للجميع.',
    ],
    faqs: [
      TreatmentFaq(
        question: 'لماذا تم استخدام اسم PRP بدلًا من إبرة الفحولة؟',
        answer:
            'لأن PRP هو الاسم الطبي الأدق، ويمكن للطبيب توضيح طبيعة الإجراء بلغة أبسط أثناء الاستشارة.',
      ),
      TreatmentFaq(
        question: 'هل يمكن استخدامه مع علاجات أخرى؟',
        answer:
            'قد يحدث ذلك في بعض الحالات، لكن القرار يعتمد على تقييم الطبيب وخطة العلاج الكاملة.',
      ),
    ],
  ),
  TreatmentInfo(
    id: 'implant',
    title: 'الدعامة الذكرية',
    englishTitle: 'Penile Prosthesis - Andro Prosthesis',
    summary:
        'حل جراحي يُلجأ إليه في حالات محددة عندما لا تكون العلاجات المحافظة كافية أو مناسبة.',
    tag: 'حل جراحي',
    icon: Icons.health_and_safety_outlined,
    color: Colors.indigo,
    howItWorks: [
      'يتم زرع جهاز طبي داخل القضيب جراحيًا ليساعد على حدوث انتصاب عند الحاجة.',
      'يوجد أكثر من نوع، والطبيب يحدد النوع الأنسب بحسب الحالة والتوقعات العلاجية.',
    ],
    useCases: [
      'حالات ضعف الانتصاب الشديدة.',
      'فشل العلاجات الدوائية أو غير الجراحية أو عدم ملاءمتها للحالة.',
    ],
    precautions: [
      'عدم ملاءمة الحالة الصحية للجراحة.',
      'وجود التهابات نشطة.',
      'عدم القدرة على التعامل مع الجهاز أو اتباع تعليمات ما بعد الإجراء.',
    ],
    sessionInfo: [
      'مدة الإجراء عادة من ساعة إلى ساعتين حسب الحالة.',
      'يتم تحديد طريقة التخدير وخطة المتابعة بواسطة الفريق الطبي.',
      'تحتاج الحالة إلى متابعة بعد الإجراء للتأكد من التعافي والتدريب على الاستخدام إذا لزم الأمر.',
    ],
    expectedOutcome: [
      'قد يوفر انتصابًا فعالًا عند الاستخدام في الحالات المناسبة.',
      'يرتبط مستوى الرضا عادة بحسن اختيار الحالة والالتزام بالمتابعة الطبية.',
    ],
    faqs: [
      TreatmentFaq(
        question: 'هل الجراحة هي الخطوة الأولى للعلاج؟',
        answer:
            'غالبًا لا، وتُناقش عادة بعد تقييم العلاجات الأخرى ومدى ملاءمتها للحالة.',
      ),
      TreatmentFaq(
        question: 'هل أحتاج إلى متابعة بعد العملية؟',
        answer:
            'نعم، المتابعة جزء أساسي من العلاج لتقييم التعافي والتأكد من الاستخدام الصحيح عند الحاجة.',
      ),
    ],
  ),
  TreatmentInfo(
    id: 'traditional',
    title: 'الطرق التقليدية',
    englishTitle: 'Conventional Methods - Andro Conventional',
    summary:
        'تشمل الخيارات المحافظة مثل الأدوية الفموية، الحقن الموضعي، وبعض الأجهزة المساعدة.',
    tag: 'أدوية وأجهزة',
    icon: Icons.medication_outlined,
    color: Colors.teal,
    howItWorks: [
      'تشمل الأدوية الفموية مثل مثبطات PDE5 التي قد تساعد على تحسين تدفق الدم في بعض الحالات.',
      'قد تشمل كذلك الحقن الموضعي أو أجهزة الشفط وفق ما يقرره الطبيب.',
      'لكل خيار طريقة استخدام مختلفة وموانع استعمال خاصة به.',
    ],
    useCases: [
      'غالبًا تكون البداية مع الخيارات المحافظة في عدد كبير من الحالات.',
      'قد تناسب المرضى الذين يحتاجون إلى علاج تدريجي قبل الانتقال إلى خيارات أكثر تقدمًا.',
    ],
    precautions: [
      'بعض الأدوية قد لا تناسب مرضى القلب أو من يتناولون أدوية معينة.',
      'الحقن الموضعي والأجهزة تحتاج إلى شرح طبي صحيح قبل الاستخدام.',
      'عدم الاستجابة أو وجود آثار جانبية يتطلب إعادة تقييم الخطة العلاجية.',
    ],
    sessionInfo: [
      'لا توجد خطة واحدة ثابتة، لأن التفاصيل تختلف حسب نوع العلاج المستخدم.',
      'الطبيب يحدد الجرعة أو طريقة الاستخدام أو عدد الزيارات اللازمة.',
    ],
    expectedOutcome: [
      'قد تحقق بعض الحالات تحسنًا جيدًا مع هذه الطرق.',
      'إذا لم تكن النتيجة كافية فقد يناقش الطبيب الانتقال إلى خيارات أخرى.',
    ],
    faqs: [
      TreatmentFaq(
        question: 'هل الطرق التقليدية تكفي دائمًا؟',
        answer:
            'ليس دائمًا، فذلك يعتمد على سبب المشكلة وشدتها واستجابة المريض للعلاج.',
      ),
      TreatmentFaq(
        question: 'متى يتم التفكير في خيارات أخرى؟',
        answer:
            'عند عدم وجود استجابة كافية أو وجود موانع أو صعوبة في الاستمرار على العلاج الحالي.',
      ),
    ],
  ),
];
