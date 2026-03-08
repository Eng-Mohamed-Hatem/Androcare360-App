@echo off
REM ===================================================
REM  Chat Feature Removal Script - elajtech Project
REM  تاريخ: 2026-01-18
REM  الغرض: حذف كامل وآمن لميزة المحادثات
REM ===================================================

echo.
echo ╔═════════════════════════════════════════════════════╗
echo ║   Chat Feature Removal Script - elajtech Project   ║
echo ╚═════════════════════════════════════════════════════╝
echo.

REM المرحلة 2: حذف البنية التحتية
echo [المرحلة 2] حذف مجلد Chat الرئيسي...
if exist "lib\features\patient\chat" (
    rmdir /s /q "lib\features\patient\chat"
    echo ✓ تم حذف lib\features\patient\chat
) else (
    echo ○ المجلد lib\features\patient\chat غير موجود
)

echo.
echo [المرحلة 2] حذف Models المشتركة...
if exist "lib\shared\models\chat_model.dart" (
    del /q "lib\shared\models\chat_model.dart"
    echo ✓ تم حذف lib\shared\models\chat_model.dart
) else (
    echo ○ الملف chat_model.dart غير موجود
)

echo.
echo [المرحلة 2] حذف Chat Services...
if exist "lib\core\services\chat_validation_service.dart" (
    del /q "lib\core\services\chat_validation_service.dart"
    echo ✓ تم حذف lib\core\services\chat_validation_service.dart
) else (
    echo ○ الملف chat_validation_service.dart غير موجود
)

echo.
echo [المرحلة 2] حذف ملفات الاختبار...
if exist "test\features\patient\chat" (
    rmdir /s /q "test\features\patient\chat"
    echo ✓ تم حذف test\features\patient\chat
) else (
    echo ○ المجلد test\features\patient\chat غير موجود
)

if exist "test\core\services\chat_validation_service_test.dart" (
    del /q "test\core\services\chat_validation_service_test.dart"
    echo ✓ تم حذف chat_validation_service_test.dart
) else (
    echo ○ الملف chat_validation_service_test.dart غير موجود
)

echo.
echo [المرحلة 2] حذف ملفات التوثيق...
if exist "plans\chat-module-test-plan.md" (
    del /q "plans\chat-module-test-plan.md"
    echo ✓ تم حذف chat-module-test-plan.md
) else (
    echo ○ الملف chat-module-test-plan.md غير موجود
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
echo ╔═════════════════════════════════════════════════════╗
echo ║            ✓ اكتمال المرحلة 2 بنجاح               ║
echo ╚═════════════════════════════════════════════════════╝
echo.
echo الخطوة التالية: تشغيل الأمر التالي لتطبيق باقي التعديلات:
echo   flutter clean
echo   flutter pub get
echo   dart run build_runner clean
echo   dart run build_runner build --delete-conflicting-outputs
echo.
pause
