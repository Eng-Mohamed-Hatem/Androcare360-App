@echo off
REM Setup script for git hooks (Windows)
REM
REM This script configures git to use the custom hooks in .githooks/
REM
REM Usage:
REM   .githooks\setup.bat

echo Setting up git hooks...

REM Check if git is initialized
if not exist ".git" (
  echo Error: Git repository not initialized
  echo    Run 'git init' first
  exit /b 1
)

REM Configure git to use .githooks directory
git config core.hooksPath .githooks

echo Git hooks configured successfully
echo.
echo Hooks installed:
echo   - pre-commit: Checks for deprecated API usage
echo.
echo To test the hook:
echo   1. Make a change to a file in lib/
echo   2. Stage the change: git add lib/your-file.dart
echo   3. Try to commit: git commit -m "test"
echo.
echo The hook will prevent commits with deprecated API warnings.
