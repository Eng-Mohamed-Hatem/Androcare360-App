#!/bin/bash
# Stop hook: prevents Claude from declaring "done" if flutter analyze has issues
# Exit codes: 0 = pass, 2 = block + send error to Claude for self-correction

STOP_HOOK_ACTIVE=$(cat | jq -r '.stop_hook_active // false')

# Prevent infinite loop — if already retrying, let Claude stop
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

echo "🔍 Running flutter analyze..."
OUTPUT=$(flutter analyze 2>&1)
echo "$OUTPUT"

if echo "$OUTPUT" | grep -qE "error •|warning •|info •"; then
  echo "" >&2
  echo "❌ flutter analyze found issues — fix all errors/warnings/info before finishing!" >&2
  echo "Run: flutter analyze" >&2
  exit 2
fi

echo "✅ flutter analyze passed — no issues found"
exit 0
