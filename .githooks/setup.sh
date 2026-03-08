#!/bin/bash
# Setup script for git hooks
#
# This script configures git to use the custom hooks in .githooks/
#
# Usage:
#   bash .githooks/setup.sh

echo "🔧 Setting up git hooks..."

# Check if git is initialized
if [ ! -d ".git" ]; then
  echo "❌ Error: Git repository not initialized"
  echo "   Run 'git init' first"
  exit 1
fi

# Configure git to use .githooks directory
git config core.hooksPath .githooks

# Make hooks executable
chmod +x .githooks/pre-commit

echo "✅ Git hooks configured successfully"
echo ""
echo "Hooks installed:"
echo "  - pre-commit: Checks for deprecated API usage"
echo ""
echo "To test the hook:"
echo "  1. Make a change to a file in lib/"
echo "  2. Stage the change: git add lib/your-file.dart"
echo "  3. Try to commit: git commit -m 'test'"
echo ""
echo "The hook will prevent commits with deprecated API warnings."
