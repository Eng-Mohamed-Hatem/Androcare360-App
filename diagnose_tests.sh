# في مجلد المشروع الرئيسي
cat > diagnose_tests.sh << 'EOF'
#!/bin/bash

# FCM Service Tests Diagnostic & Fix Script
echo "════════════════════════════════════════════════════════════════"
echo "  🔍 FCM Service Tests - Diagnostic & Fix"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Step 1: Find test file
echo "[1/8] 🔍 Searching for test file..."
TEST_FILE=$(find test -name "fcm_service_test_task8.dart" 2>/dev/null | head -n 1)

if [ -z "$TEST_FILE" ]; then
    echo "❌ Test file not found!"
    exit 1
else
    echo "✅ Found: $TEST_FILE"
fi
echo ""

# Step 2: Check test file structure
echo "[2/8] 📄 Checking test file structure..."
if grep -q "void main()" "$TEST_FILE"; then
    echo "✅ main() function exists"
else
    echo "❌ No main() function!"
fi

TEST_COUNT=$(grep -c "test(" "$TEST_FILE" 2>/dev/null || echo "0")
echo "✅ Found $TEST_COUNT test cases"
echo ""

# Step 3: Check imports
echo "[3/8] 📦 Checking imports..."
if grep -q "import 'package:flutter_test/flutter_test.dart';" "$TEST_FILE"; then
    echo "✅ Correct flutter_test import"
else
    echo "⚠️  Missing flutter_test import"
fi

if grep -q "@GenerateMocks" "$TEST_FILE"; then
    echo "✅ Uses @GenerateMocks (needs build_runner)"
    NEEDS_MOCKS=true
else
    echo "ℹ️  No @GenerateMocks found"
    NEEDS_MOCKS=false
fi
echo ""

# Step 4: Check dependencies
echo "[4/8] 📋 Checking dependencies..."
grep -q "mockito:" pubspec.yaml && echo "✅ mockito" || echo "⚠️  mockito missing"
grep -q "build_runner:" pubspec.yaml && echo "✅ build_runner" || echo "⚠️  build_runner missing"
echo ""

# Step 5: Clean and rebuild
echo "[5/8] 🧹 Cleaning build artifacts..."
flutter clean > /dev/null 2>&1
rm -rf .dart_tool/test/
find . -name "*.mocks.dart" -delete 2>/dev/null
echo "✅ Cleaned"
echo ""

# Step 6: Get dependencies
echo "[6/8] 📦 Getting dependencies..."
flutter pub get
echo ""

# Step 7: Generate mocks (if needed)
if [ "$NEEDS_MOCKS" = true ]; then
    echo "[7/8] ⚙️  Generating mocks..."
    flutter pub run build_runner build --delete-conflicting-outputs
    echo ""
else
    echo "[7/8] ⏭️  Skipping mock generation"
    echo ""
fi

# Step 8: Run tests
echo "[8/8] 🧪 Running tests..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

flutter test "$TEST_FILE" --reporter expanded 2>&1 | tee test_results.txt

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check results
if grep -q "All tests passed!" test_results.txt; then
    PASSED=$(grep -o "+[0-9]*" test_results.txt | tail -1 | grep -o "[0-9]*")
    echo ""
    echo "✅ SUCCESS: All $PASSED tests passed!"
    echo ""
    exit 0
elif grep -q "Some tests failed" test_results.txt; then
    echo ""
    echo "❌ FAILED: Some tests failed"
    echo "Check test_results.txt for details"
    echo ""
    exit 1
else
    echo ""
    echo "⚠️  Unknown result - check test_results.txt"
    echo ""
    exit 2
fi
EOF

# جعل السكريبت قابل للتنفيذ
chmod +x diagnose_tests.sh

echo "✅ السكريبت جاهز!"
