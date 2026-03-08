# Implementation Plan: Apply .gitattributes LF policy

**Branch**: `chore/normalize-line-endings` | **Date**: 2026-03-08 | **Spec**: [.specify/specs/normalize-line-endings/spec.md](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/.specify/specs/normalize-line-endings/spec.md)
**Input**: Feature specification from `.specify/specs/normalize-line-endings/spec.md`

## Summary

The primary requirement is to normalize line endings to LF across the Flutter app. This will be achieved by creating/updating the `.gitattributes` file in the repository root with an explicit LF policy for key text files (Dart, YAML, Markdown, JSON).

## Technical Context

- **Language/Version**: Dart/Flutter
- **Primary Dependencies**: Git
- **Project Type**: Flutter mobile app (AndroCare)
- **Constraints**: Must ensure that existing files are handled correctly by the new policy.

## Constitution Check

- [x] **Architecture Check**: N/A (Project configuration)
- [x] **Security Check**: N/A
- [x] **Testing Check**: Included verification steps using git commands.
- [x] **Spec Kit Check**: This feature follows the Specify → Plan → Tasks walkthrough.

## Project Structure

### Documentation (this feature)

```text
.specify/specs/normalize-line-endings/
├── spec.md              # Feature specification
├── plan.md              # This file
└── tasks.md             # Task list
```

## Proposed Changes

### Configuration

#### [NEW/MODIFY] [.gitattributes](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/.gitattributes)

Create or update `.gitattributes` with the following rules:

```text
* text=auto

*.dart text eol=lf
*.yaml text eol=lf
*.yml  text eol=lf
*.md   text eol=lf
*.json text eol=lf
```

## Verification Plan

### Automated Tests

- Verify the policy is applied to target file types:
  ```bash
  git check-attr eol -- lib/main.dart
  git check-attr eol -- pubspec.yaml
  ```
  Expected output for both: `eol: lf`

### Manual Verification

- Inspect the `.gitattributes` file to ensure correct content.

---

<div dir="rtl">

# خطة التنفيذ: تطبيق سياسة .gitattributes LF

الهدف هو توحيد نهايات الأسطر إلى LF عبر تطبيق Flutter بالكامل لضمان التناسق ومنع مشاكل الدمج الناتجة عن اختلاف أنظمة التشغيل.

**الخلاصة**:
سيتم تحقيق المتطلب الأساسي عن طريق إنشاء أو تحديث ملف `.gitattributes` في جذر المشروع مع سياسة LF واضحة للملفات النصية الأساسية (Dart, YAML, Markdown, JSON).

## التغييرات المقترحة

### الإعدادات

#### [إنشاء/تعديل] [.gitattributes](file:///c:/Users/moham/Desktop/androcare/elajtech/elajtech/.gitattributes)

تحديث ملف `.gitattributes` بالقواعد التالية:

```text
* text=auto

*.dart text eol=lf
*.yaml text eol=lf
*.yml  text eol=lf
*.md   text eol=lf
*.json text eol=lf
```

## خطة التحقق

### الاختبارات المؤتمتة

- التحقق من تطبيق السياسة على أنواع الملفات المستهدفة:
  ```bash
  git check-attr eol -- lib/main.dart
  git check-attr eol -- pubspec.yaml
  ```
  النتيجة المتوقعة: `eol: lf`

### التحقق اليدوي

- فحص محتوى ملف `.gitattributes` للتأكد من صحته.
- إضافة الملف وتوثيقه، والتحقق من عدم حدوث تغييرات غير متوقعة في الملفات الثنائية.

</div>
