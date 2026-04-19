#!/bin/bash
# PostToolUse hook: runs dart format on every .dart file Claude edits

FILE_PATH=$(cat | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then exit 0; fi

if [[ "$FILE_PATH" =~ \.dart$ ]]; then
  dart format "$FILE_PATH" 2>/dev/null
  echo "✅ Formatted: $FILE_PATH"
fi

exit 0
