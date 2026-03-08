# database & coding.md

Rule description here...

## Guidelines

## Guidelines
قاعدة صارمة لمشروع 'elajtech': قاعدة بيانات Firestore المعتمدة ليست الافتراضية، بل تحمل المعرف databaseId: 'elajtech'. يمنع منعاً باتاً استخدام FirebaseFirestore.instance. يجب دائماً استخدام FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'elajtech') أو الاعتماد على النسخة المحقونة عبر GetIt."

قاعدة الـ Build Runner:

    "عند إضافة أي Repository أو Service جديد يستخدم @injectable أو @module أو @lazySingleton في مشروع 'elajtech'، يجب إبلاغ المستخدم بضرورة تشغيل أمر build_runner فوراً لتحديث الروابط."

قاعدة استقلالية العيادات (Clinic Isolation):

    "كل عيادة تخصصية (مثل التغذية أو العلاج الطبيعي) يجب أن يكون لها Model و Repository مستقل تماماً. لا تدمج منطق العيادات المختلفة في ملف واحد للحفاظ على مبدأ المسؤولية الموحدة (Single Responsibility)."

قاعدة اتجاه النص (LTR/RTL):

    "عند تصميم واجهات العيادات التي تحتوي على أسئلة باللغة الإنجليزية، يجب دائماً تغليف المحتوى بـ Directionality(textDirection: TextDirection.ltr) لضمان تنسيق الخانات والـ Checkboxes بشكل صحيح."

