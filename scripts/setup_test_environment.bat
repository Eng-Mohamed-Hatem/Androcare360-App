@echo off
REM ##########################################################################
REM AndroCare360 Test Environment Setup Script (Windows)
REM 
REM This script automates the complete test environment setup:
REM 1. Checks prerequisites
REM 2. Installs dependencies
REM 3. Checks Firebase Emulator (if using emulator)
REM 4. Creates test accounts (doctors & patients)
REM 5. Creates test appointments
REM 6. Verifies the setup
REM
REM Usage:
REM   scripts\setup_test_environment.bat [emulator|dev|prod]
REM
REM Example:
REM   scripts\setup_test_environment.bat emulator
REM
REM ##########################################################################

setlocal enabledelayedexpansion

REM Parse environment argument
set ENVIRONMENT=%1
if "%ENVIRONMENT%"=="" set ENVIRONMENT=emulator

REM Validate environment
if not "%ENVIRONMENT%"=="emulator" if not "%ENVIRONMENT%"=="dev" if not "%ENVIRONMENT%"=="prod" (
    echo [91m❌ Invalid environment. Use: emulator, dev, or prod[0m
    exit /b 1
)

echo [94m╔════════════════════════════════════════════════════════════╗[0m
echo [94m║     AndroCare360 Test Environment Setup                   ║[0m
echo [94m║     Environment: %ENVIRONMENT%                                        ║[0m
echo [94m╚════════════════════════════════════════════════════════════╝[0m
echo.

REM ##########################################################################
REM Step 1: Check Prerequisites
REM ##########################################################################

echo [93m[1/6] Checking Prerequisites...[0m

REM Check Flutter
where flutter >nul 2>&1
if errorlevel 1 (
    echo [91m❌ Flutter not found. Please install Flutter first.[0m
    exit /b 1
)
echo [92m✅ Flutter installed[0m

REM Check Firebase CLI (only for emulator)
if "%ENVIRONMENT%"=="emulator" (
    where firebase >nul 2>&1
    if errorlevel 1 (
        echo [91m❌ Firebase CLI not found. Please install: npm install -g firebase-tools[0m
        exit /b 1
    )
    echo [92m✅ Firebase CLI installed[0m
)

REM Check Dart
where dart >nul 2>&1
if errorlevel 1 (
    echo [91m❌ Dart not found[0m
    exit /b 1
)
echo [92m✅ Dart installed[0m

echo.

REM ##########################################################################
REM Step 2: Install Dependencies
REM ##########################################################################

echo [93m[2/6] Installing Flutter Dependencies...[0m
flutter pub get
echo [92m✅ Dependencies installed[0m
echo.

REM ##########################################################################
REM Step 3: Check Firebase Emulator (if using emulator)
REM ##########################################################################

if "%ENVIRONMENT%"=="emulator" (
    echo [93m[3/6] Checking Firebase Emulator...[0m
    
    curl -s http://localhost:4000 >nul 2>&1
    if errorlevel 1 (
        echo [91m❌ Firebase Emulator is not running![0m
        echo [93mPlease start the emulator in another terminal:[0m
        echo   [94mfirebase emulators:start[0m
        echo.
        echo [93mThen run this script again.[0m
        exit /b 1
    )
    
    echo [92m✅ Firebase Emulator is running[0m
) else (
    echo [93m[3/6] Skipping Emulator (using %ENVIRONMENT%)[0m
)

echo.

REM ##########################################################################
REM Step 4: Create Test Accounts
REM ##########################################################################

echo [93m[4/6] Creating Test Accounts...[0m
dart scripts\create_test_accounts.dart --environment %ENVIRONMENT%

if errorlevel 1 (
    echo [91m❌ Failed to create test accounts[0m
    exit /b 1
)

echo [92m✅ Test accounts created successfully[0m
echo.

REM Wait for Firestore to sync
echo [93m⏳ Waiting for Firestore to sync...[0m
timeout /t 2 /nobreak >nul
echo.

REM ##########################################################################
REM Step 5: Create Test Appointments
REM ##########################################################################

echo [93m[5/6] Creating Test Appointments...[0m
dart scripts\create_test_appointments.dart --environment %ENVIRONMENT%

if errorlevel 1 (
    echo [91m❌ Failed to create test appointments[0m
    exit /b 1
)

echo [92m✅ Test appointments created successfully[0m
echo.

REM ##########################################################################
REM Step 6: Verify Setup
REM ##########################################################################

echo [93m[6/6] Verifying Test Environment...[0m
dart scripts\verify_test_environment.dart --environment %ENVIRONMENT%

if errorlevel 1 (
    echo [91m❌ Verification failed. Please review errors above.[0m
    exit /b 1
)

echo.
echo [92m╔════════════════════════════════════════════════════════════╗[0m
echo [92m║  🎉 Test Environment Setup Complete!                      ║[0m
echo [92m╚════════════════════════════════════════════════════════════╝[0m
echo.

if "%ENVIRONMENT%"=="emulator" (
    echo [94m📋 Quick Access Links:[0m
    echo   - Firestore UI: http://localhost:4000/firestore
    echo   - Auth UI: http://localhost:4000/auth
    echo   - Functions Logs: http://localhost:4000/logs
    echo.
)

echo [94m📝 Test Credentials:[0m
echo   Doctors: doctor.test1@androcare360.test (password: TestDoctor123!)
echo   Patients: patient.test1@androcare360.test (password: TestPatient123!)
echo.
echo [92m✅ Ready to proceed with testing![0m

endlocal
