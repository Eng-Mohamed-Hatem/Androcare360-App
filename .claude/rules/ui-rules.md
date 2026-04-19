---
paths:
  - "lib/features/**/presentation/**/*.dart"
  - "lib/shared/**/*.dart"
---
# UI & Presentation Layer Rules

## Directionality
- App global direction is RTL (Arabic)
- ALWAYS wrap English content in clinic forms with:
  `Directionality(textDirection: TextDirection.ltr, child: ...)`
- Ensures input fields, checkboxes, and alignment display correctly

## Phone Number Validation
- Input fields for phone: validate against E.164 format
- Regex: `r'^\+\d{8,15}$'`
- Show inline error if format is wrong before allowing submission

## Widget Performance
- Use `const` constructors wherever possible
- Keep `build()` lightweight — no expensive operations inside
- Break large widgets into smaller, reusable sub-widgets
- Use `ListView.builder` for any list that could grow

## State Management (Riverpod)
- In build: `ref.watch(provider)` for reactive UI
- In callbacks/event handlers: `ref.read(provider)` only
- Always handle all 3 states: loading, error, data
- Use `AsyncValue.when()` for clean state handling

## Error Display to User
- ALL Firestore/network errors → show user-friendly Arabic message
- NEVER show raw exception messages or stack traces to users
- Use localized strings from ARB files

## Deprecated APIs — Zero Tolerance
- NEVER: `Color.withOpacity(x)` → USE: `Color.withValues(alpha: x)`
- NEVER: deprecated `Radio(groupValue:, onChanged:)` → USE: `RadioGroup`
- After any UI change: run `flutter analyze` — zero deprecated_member_use warnings allowed
