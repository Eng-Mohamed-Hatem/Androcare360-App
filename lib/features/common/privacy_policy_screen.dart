import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('سياسة الخصوصية'), centerTitle: true),
    body: const Markdown(
      data: _privacyPolicyContent,
    ),
  );

  static const String _privacyPolicyContent = '''
# Terms & Privacy Policy – AndroCare360 Health App

## الشروط والأحكام – تطبيق أندروكير360 للصحة

### 1. Purpose | الغرض
The app provides general health information and tele-consultation services related to men’s health and wellness. It is not a substitute for in-person medical examination.
يُقدّم التطبيق معلومات عامة وخدمات استشارة عن بُعد تخص صحة الرجال وعافيتهم، ولا يُعتبر بديلاً عن الفحص الطبي المباشر.

### 2. Medical Disclaimer | إخلاء المسؤولية الطبية
All advice given through the app is for educational and guidance purposes only. Always consult a licensed physician before taking or stopping any medication.
جميع النصائح المقدمة عبر التطبيق هي لأغراض تثقيفية وإرشادية فقط، وعلاجية ويجب دائمًا استشارة طبيب مرخّص قبل تناول أو إيقاف أي دواء.

### 3. User Responsibility | مسؤولية المستخدم
Users must provide accurate personal and health information. The company is not responsible for incorrect data or misuse of services.
يجب على المستخدم إدخال بيانات شخصية وصحية دقيقة، ولا تتحمل الشركة مسؤولية أي خطأ في المعلومات أو سوء استخدام للخدمة.

### 4. Privacy | الخصوصية
All user information is treated as confidential and handled according to privacy laws. No data will be shared without consent.
تُعامل جميع بيانات المستخدم بسرية تامة وفقًا لأنظمة الخصوصية، ولا يتم مشاركتها دون موافقة المستخدم.

### 5. Limitations of Service | حدود الخدمة
Online consultations are limited to advice and guidance; emergency or urgent medical conditions should be directed to a hospital.
تقتصر الاستشارات عبر الإنترنت على النصائح والإرشادات فقط، أما الحالات الطارئة أو العاجلة فيجب التوجّه بها إلى المستشفى.

### 6. App Use & Ownership | استخدام التطبيق والملكية
All content, logos, and designs are the property of AndroCare Center. Users agree not to copy, resell, or misuse any part of the app.
جميع المحتويات والشعارات والتصاميم هي ملكٌ لمركز أندروكير، ويوافق المستخدم على عدم نسخها أو إعادة بيعها أو إساءة استخدامها.

### 7. Changes | التعديلات
The Center may update these terms at any time. Continued use of the app means acceptance of the new terms.
يحق للمركز تعديل هذه الشروط في أي وقت، ويُعتبر استمرار استخدام التطبيق قبولاً بالشروط الجديدة.

---

## سياسة الخصوصية – تطبيق أندروكير للصحة

### 8. Data Collection | جمع البيانات
The app collects limited personal and health information to provide better medical guidance and improve user experience.
يجمع التطبيق بعض المعلومات الشخصية والصحية بهدف تقديم إرشادات طبية أفضل وتحسين تجربة المستخدم.

### 9. Use of Information | استخدام المعلومات
All collected data is used only for healthcare services, appointment management, and communication with users.
تُستخدم البيانات المجمعة فقط لتقديم الخدمات الصحية، وتنظيم المواعيد، والتواصل مع المستخدمين.

### 10. Data Protection | حماية البيانات
Your information is securely stored and protected from unauthorized access, alteration, or disclosure.
تُخزّن معلوماتك بأمان ويتم حمايتها من أي وصول أو تعديل أو إفشاء غير مصرح به.

### 11. Sharing of Information | مشاركة المعلومات
We do not share your data with any third party except trusted healthcare partners or authorities as required by law.
لا تتم مشاركة بياناتك مع أي طرف ثالث إلا مع شركاء صحيين موثوقين أو جهات رسمية عند طلب القانون ذلك.

### 12. User Rights | حقوق المستخدم
You have the right to access, correct, or request deletion of your personal data at any time.
يحق لك الوصول إلى بياناتك الشخصية أو تصحيحها أو طلب حذفها في أي وقت.

### 13. Cookies & Analytics | ملفات تعريف الارتباط والتحليلات
The app may use cookies or analytic tools to enhance performance and understand usage trends.
قد يستخدم التطبيق ملفات تعريف الارتباط أو أدوات التحليل لتحسين الأداء وفهم أنماط الاستخدام.

### 14. Policy Updates | تحديث السياسة
We may update this Privacy Policy periodically. Continued use of the app means you accept the latest version.
قد نقوم بتحديث سياسة الخصوصية من حين لآخر، ويُعتبر استمرار استخدامك للتطبيق قبولًا بأحدث نسخة منها
''';
}
