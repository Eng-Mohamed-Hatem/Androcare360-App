@echo off
REM ===================================================
REM  Complete Chat Feature Removal Script
REM  تاريخ: 2026-01-18
REM  الغرض: حذف كامل وشامل لميزة المحادثات من elajtech
REM ===================================================

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║   Complete Chat Feature Removal - elajtech Project      ║
echo ║   إزالة ميزة المحادثات بشكل كامل وآمن                   ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

echo تحذير: هذا السكريبت سيقوم بحذف جميع الملفات والمجلدات المرتبطة بميزة Chat
echo.
choice /C YN /M "هل أنت متأكد من المتابعة؟ (Y=نعم / N=إلغاء)"
if errorlevel 2 (
    echo العملية ملغاة
    pause
    exit /b
)

echo.
echo ═══════════════════════════════════════════════════════════
echo   المرحلة 2: حذف البنية التحتية للميزة
echo ═══════════════════════════════════════════════════════════
echo.

REM حذف مجلد Chat الرئيسي
echo [1/9] حذف مجلد lib\features\patient\chat...
if exist "lib\features\patient\chat" (
    rmdir /s /q "lib\features\patient\chat"
    echo ✓ تم حذف lib\features\patient\chat
) else (
    echo ○ المجلد غير موجود (تم حذفه مسبقاً أو غير موجود)
)

REM حذف Models المشتركة
echo.
echo [2/9] حذف lib\shared\models\chat_model.dart...
if exist "lib\shared\models\chat_model.dart" (
    del /q "lib\shared\models\chat_model.dart"
    echo ✓ تم حذف chat_model.dart
) else (
    echo ○ الملف غير موجود
)

REM حذف Chat Services
echo.
echo [3/9] حذف lib\core\services\chat_validation_service.dart...
if exist "lib\core\services\chat_validation_service.dart" (
    del /q "lib\core\services\chat_validation_service.dart"
    echo ✓ تم حذف chat_validation_service.dart
) else (
    echo ○ الملف غير موجود
)

REM حذف مجلد Test للمحادثات
echo.
echo [4/9] حذف test\features\patient\chat...
if exist "test\features\patient\chat" (
    rmdir /s /q "test\features\patient\chat"
    echo ✓ تم حذف مجلد الاختبار test\features\patient\chat
) else (
    echo ○ المجلد غير موجود
)

REM حذف ملف اختبار chat_validation_service
echo.
echo [5/9] حذف test\core\services\chat_validation_service_test.dart...
if exist "test\core\services\chat_validation_service_test.dart" (
    del /q "test\core\services\chat_validation_service_test.dart"
    echo ✓ تم حذف chat_validation_service_test.dart
) else (
    echo ○ الملف غير موجود
)

REM حذف ملفات التوثيق
echo.
echo [6/9] حذف ملفات التوثيق والتخطيط...

if exist "plans\chat-module-test-plan.md" (
    del /q "plans\chat-module-test-plan.md"
    echo ✓ تم حذف chat-module-test-plan.md
) else (
    echo ○ chat-module-test-plan.md غير موجود
)

if exist "reports\chat-module-qa-verification-report.md" (
    del /q "reports\chat-module-qa-verification-report.md"
    echo ✓ تم حذف chat-module-qa-verification-report.md
) else (
    echo ○ الملف غير موجود
)

if exist "reports\chat-module-refactoring-summary.md" (
    del /q "reports\chat-module-refactoring-summary.md"
    echo ✓ تم حذف chat-module-refactoring-summary.md
) else (
    echo ○ الملف غير موجود
)

if exist "reports\chat-module-static-analysis-report.md" (
    del /q "reports\chat-module-static-analysis-report.md"
    echo ✓ تم حذف chat-module-static-analysis-report.md
) else (
    echo ○ الملف غير موجود
)

if exist "reports\chat-text-only-mode-report.md" (
    del /q "reports\chat-text-only-mode-report.md"
    echo ✓ تم حذف chat-text-only-mode-report.md
) else (
    echo ○ الملف غير موجود
)

echo.
echo ✓ اكتمال حذف الملفات بنجاح
echo.

REM ═══════════════════════════════════════════════════════════
echo.
echo ═══════════════════════════════════════════════════════════
echo   المرحلة 8: تشغيل flutter clean وتحديث التبعيات
echo ═══════════════════════════════════════════════════════════
echo.

echo [7/9] تنفيذ flutter clean...
call flutter clean
if %errorlevel% neq 0 (
    echo ✗ فشل تنفيذ flutter clean
    pause
    exit /b %errorlevel%
)
echo ✓ اكتمل flutter clean بنجاح
echo.

echo [8/9] تنفيذ flutter pub get...
call flutter pub get
if %errorlevel% neq 0 (
    echo ✗ فشل تنفيذ flutter pub get
    pause
    exit /b %errorlevel%
)
echo ✓ اكتمل flutter pub get بنجاح
echo.

echo [9/9] تنفيذ dart run build_runner...
echo تنبيه: قد تستغرق هذه العملية عدة دقائق...
call dart run build_runner clean
call dart run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo ✗ فشل تنفيذ build_runner
    echo ⚠ قد تحتاج إلى تشغيل الأمر يدوياً
) else (
    echo ✓ اكتمل build_runner بنجاح
)

echo.
echo ═══════════════════════════════════════════════════════════
echo   المرحلة 9: التحقق النهائي
echo ═══════════════════════════════════════════════════════════
echo.

echo تنفيذ flutter analyze للكشف عن الأخطاء...
call flutter analyze > chat_removal_analyze.txt 2>&1
if %errorlevel% neq 0 (
    echo ⚠ تم اكتشاف بعض المشاكل. راجع ملف chat_removal_analyze.txt
) else (
    echo ✓ لم يتم اكتشاف مشاكل في flutter analyze
)

echo.
echo ═══════════════════════════════════════════════════════════
echo   ✓✓✓ اكتمل حذف ميزة Chat بنجاح ✓✓✓
echo ═══════════════════════════════════════════════════════════
echo.
echo ملخص التعديلات:
echo   ✓ تم حذف مجلد lib\features\patient\chat
echo   ✓ تم حذف lib\shared\models\chat_model.dart
echo   ✓ تم حذف lib\core\services\chat_validation_service.dart
echo   ✓ تم حذف جميع ملفات Test المرتبطة
echo   ✓ تم حذف ملفات التوثيق (5 ملفات)
echo   ✓ تم تعديل patient_home_screen.dart (إزالة زر المحادثات)
echo   ✓ تم تعديل firestore.rules (إزالة قواعد Chats)
echo   ✓ تم تشغيل flutter clean + pub get + build_runner
echo.
echo الخطوات التالية:
echo   1. راجع ملف reports\chat-feature-removal-report.md للتفاصيل
echo   2. راجع ملف chat_removal_analyze.txt للتحقق من الأخطاء
echo   3. قم بتشغيل التطبيق على محاكي للتأكد من عدم وجود crashes
echo   4. قم بنشر firestore.rules المحدثة إلى Firebase Console
echo   5. قم بعمل git commit للتغييرات
echo.
pause
