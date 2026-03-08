# Golden Tests

Golden tests (also known as snapshot tests) capture visual snapshots of widgets to detect unintended UI changes.

## Purpose

Golden tests are particularly useful for:
- **API Migration Verification**: Ensure visual appearance unchanged after migrating deprecated APIs
- **Visual Regression Detection**: Catch unintended UI changes
- **Cross-Platform Consistency**: Verify UI looks the same across platforms
- **Design Review**: Provide visual diffs for code reviews

## Setup

### Install golden_toolkit

Add to `pubspec.yaml`:

```yaml
dev_dependencies:
  golden_toolkit: ^0.15.0
```

Then run:

```bash
flutter pub get
```

### Load Fonts

Golden tests require fonts to be loaded. This is handled automatically in test setup.

## Running Golden Tests

### Generate/Update Golden Files

When creating new golden tests or after intentional UI changes:

```bash
# Update all golden files
flutter test --update-goldens test/golden/

# Update specific test file
flutter test --update-goldens test/golden/agora_video_call_screen_golden_test.dart
```

### Run Golden Tests

To verify UI hasn't changed:

```bash
# Run all golden tests
flutter test test/golden/

# Run specific test file
flutter test test/golden/agora_video_call_screen_golden_test.dart
```

### View Golden Files

Golden files are stored in:
```
test/golden/goldens/
├── agora_video_call_screen_waiting_room.png
├── agora_video_call_screen_controls.png
└── agora_video_call_screen_appointment_info.png
```

## When to Update Goldens

✅ **Update goldens when:**
- Creating new golden tests
- Making intentional UI changes
- Migrating deprecated APIs (to verify no visual changes)
- Updating design system (colors, fonts, spacing)

❌ **Don't update goldens when:**
- Tests fail unexpectedly (investigate first!)
- You're not sure why the visual changed
- The change wasn't intentional

## Best Practices

### 1. Review Diffs Carefully

Before updating goldens, review the visual diffs:

```bash
# Run tests to see failures
flutter test test/golden/

# Check the diff images in test/failures/
# Compare with golden files in test/golden/goldens/
```

### 2. Use Descriptive Names

```dart
// ✅ Good - describes what's being tested
await screenMatchesGolden(tester, 'login_screen_with_error_message');

// ❌ Bad - too generic
await screenMatchesGolden(tester, 'test1');
```

### 3. Test Specific States

Create separate golden tests for different UI states:

```dart
testGoldens('waiting room UI', (tester) async { ... });
testGoldens('active call UI', (tester) async { ... });
testGoldens('error state UI', (tester) async { ... });
```

### 4. Use Consistent Device Sizes

```dart
// Use standard device sizes for consistency
await tester.pumpWidgetBuilder(
  widget,
  surfaceSize: const Size(375, 667), // iPhone SE
);
```

### 5. Commit Golden Files

Golden files should be committed to version control:

```bash
git add test/golden/goldens/
git commit -m "Add golden tests for video call screen"
```

## Platform Considerations

⚠️ **Important:** Golden tests are platform-specific!

- Golden files generated on macOS may differ from Windows/Linux
- Font rendering varies across platforms
- Run golden tests on the same platform consistently

**Recommendation:** Use CI/CD to generate and compare goldens on a consistent platform.

## CI/CD Integration

Golden tests can be integrated into CI/CD:

```yaml
# .github/workflows/golden-tests.yml
- name: Run Golden Tests
  run: flutter test test/golden/

- name: Upload Golden Failures
  if: failure()
  uses: actions/upload-artifact@v4
  with:
    name: golden-test-failures
    path: test/failures/
```

## Troubleshooting

### Test Fails with "Golden file not found"

**Solution:** Generate the golden file:

```bash
flutter test --update-goldens test/golden/your_test.dart
```

### Test Fails with Visual Differences

**Solution:**

1. Check the diff images in `test/failures/`
2. If the change is intentional, update goldens:
   ```bash
   flutter test --update-goldens test/golden/
   ```
3. If the change is unintentional, fix the code

### Fonts Not Rendering Correctly

**Solution:** Ensure fonts are loaded in test setup:

```dart
setUpAll(() async {
  await loadAppFonts();
});
```

### Platform-Specific Differences

**Solution:** Run tests on the same platform consistently, or use CI/CD with a fixed platform.

## Example: Verifying API Migration

After migrating `withOpacity()` to `withValues(alpha:)`:

```bash
# 1. Run golden tests to verify no visual changes
flutter test test/golden/agora_video_call_screen_golden_test.dart

# 2. If tests pass: ✅ No visual changes (good!)
# 3. If tests fail: Review diffs carefully
#    - If visual change is unintended: Fix the migration
#    - If visual change is expected: Update goldens
```

## Resources

- [golden_toolkit Documentation](https://pub.dev/packages/golden_toolkit)
- [Flutter Golden Tests Guide](https://docs.flutter.dev/cookbook/testing/widget/golden-files)
- [Visual Regression Testing Best Practices](https://flutter.dev/docs/testing/overview#visual-testing)

---

**Last Updated:** 2026-02-16  
**Maintained by:** AndroCare360 Development Team
