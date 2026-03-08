# Changelog

All notable changes to the AndroCare360 project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Authentication & Role-Based Routing Hardening**
  - Refactored `VoIPCallService` to a DI-based `@lazySingleton` managed by `getIt`, improving testability and eliminating global singleton side-effects.
  - Enhanced `AuthRepositoryImpl` tests to strictly enforce `databaseId: elajtech`, validate `userType` and `isActive` parsing, and fail gracefully when user documents are missing or malformed.
  - Extended `AuthProvider` tests to block inactive accounts across all roles with clear user-facing error messages, while defaulting legacy users without `isActive` to active.
  - Added comprehensive `AuthWrapper` widget tests covering routing for Admin/Doctor/Patient, splash/loading states, race conditions (authenticated + null user), and pending VoIP call handling during app startup.

## [1.1.0] - 2026-02-24

### Added
- **Phone Number + OTP Login**: Secure authentication using Firebase Auth and Firestore (databaseId `elajtech`).
- **Role-Based Routing**: Dynamic navigation to Admin/Doctor/Patient dashboards after successful login.
- **Enhanced UI Components**: Updated `CustomTextField` to support OTP input requirements (textAlign, maxLength, letterSpacing).
- **Comprehensive Testing**: Added unit tests for `AuthRepositoryImpl` phone methods and `AuthProvider` phone auth logic.


### Changed
- **Deprecated API Migration Completed** (2026-02-16)
  - **Achievement**: Eliminated 100% of deprecated API warnings from source code (6 → 0 warnings)
  - **APIs Migrated**:
    - `Color.withOpacity()` → `Color.withValues(alpha:)` (4 instances)
    - Individual `Radio` widgets → `RadioGroup` pattern (1 instance)
  - **Impact**:
    - ✅ Zero breaking changes - all 664 tests passing
    - ✅ Visual appearance unchanged
    - ✅ Functionality identical
    - ✅ Backward compatible
  - **Prevention Mechanisms Implemented**:
    - Pre-commit hooks for deprecated API detection
    - CI/CD workflow for automated enforcement
    - Golden tests for visual regression testing
    - Comprehensive documentation
  - **Time Efficiency**: Completed in ~3.5 hours (36% faster than estimated 5.5 hours)
  - **Files Modified**:
    - `lib/features/patient/consultation/presentation/screens/agora_video_call_screen.dart`
    - `lib/features/doctor/medical_records/presentation/screens/add_internal_medicine_emr_screen.dart`
  - **Documentation Created**:
    - `TASK_18_COMPLETION_REPORT.md` - Complete migration report
    - `TASK_18_FINAL_SUMMARY.md` - Executive summary
    - `DEPRECATED_API_PREVENTION_STRATEGY.md` - Prevention mechanisms guide
    - Migration guides for each subtask
  - **Reference**: `.kiro/specs/code-quality-and-testing-improvement/`

### Fixed
- **[CRITICAL] VoIP "Appointment Not Found" Error** (2026-02-13)
  - **Issue**: Doctors received "Appointment Not Found" errors when initiating video calls, despite appointments existing in the Firestore database
  - **Root Cause**: Firebase Admin SDK in Cloud Functions wasn't consistently applying the `databaseId` configuration, causing queries to fall back to the default database instead of the `elajtech` database
  - **Fix**: Added explicit database configuration `db.settings({ databaseId: 'elajtech' })` after Firestore initialization in `functions/index.js`
  - **Impact**: 
    - ✅ All appointment lookups now consistently target the `elajtech` database
    - ✅ Call logs are written to the correct database
    - ✅ Patient FCM tokens are retrieved from the correct database
    - ✅ Zero breaking changes - all 661 existing tests passing
  - **Files Changed**: `functions/index.js` (one-line fix + comprehensive documentation)
  - **Reference**: `.kiro/specs/voip-appointment-not-found-bugfix/`

### Added
- **Enhanced Error Logging with Database Context** (2026-02-13)
  - All error logs now include database ID and collection information
  - Error messages explicitly mention which database was queried
  - Enhanced metadata for better debugging and monitoring
  - Example: `errorMessage: '[DB: elajtech] الموعد غير موجود في قاعدة البيانات elajtech'`
  - Files Changed: `functions/index.js` (logCallEvent function and error handlers)

- **Comprehensive Cloud Functions Test Suite** (2026-02-13)
  - 48 unit and integration tests
  - 400 property-based test iterations
  - Database configuration verification tests
  - Database isolation tests
  - Firebase Emulator integration
  - Files Added:
    - `functions/test/setup.js` - Test environment configuration
    - `functions/test/fixtures.js` - Test data factories
    - `functions/test/database-config.test.js` - 24 unit tests
    - `functions/test/integration.test.js` - 17 integration tests
    - `functions/test/database-isolation.test.js` - 7 isolation tests
    - `functions/jest.config.js` - Jest configuration
    - `functions/test/README.md` - Test documentation

- **Cloud Functions Documentation** (2026-02-13)
  - Created comprehensive `functions/README.md`
  - Setup instructions for new developers
  - Database configuration requirements
  - Testing guide with Firebase Emulator
  - Troubleshooting section
  - API reference
  - Best practices and security guidelines

- **Updated API Documentation** (2026-02-13)
  - Added troubleshooting section for database configuration issue
  - Documented the fix and verification steps
  - Enhanced error handling examples
  - File Updated: `API_DOCUMENTATION.md`

### Changed
- **Cloud Functions Error Messages** (2026-02-13)
  - All error messages now include database context
  - Improved error metadata for debugging
  - More descriptive error codes
  - Files Changed: `functions/index.js`

- **Agora Configuration Migration to Modern .env Environment** (2026-02-14)
  - **Migration**: Transitioned from Firebase's legacy `functions.config()` to modern `.env` environment variables for Agora credentials
  - **Motivation**: Align with Firebase 2026+ best practices and industry-standard 12-factor app methodology
  - **Impact**:
    - ✅ Improved security: Credentials stored in local files, not in Firebase config
    - ✅ Easier development: Simple file-based configuration
    - ✅ Better version control: .env.example provides template without exposing secrets
    - ✅ Simpler deployment: No separate `firebase functions:config:set` commands needed
    - ✅ Future-proof: Aligns with modern Firebase standards
    - ✅ Backward compatible: Automatic fallback to `functions.config()` if `.env` not set
  - **Code Changes**:
    - `functions/index.js`:
      - Lines ~52-82: `generateAgoraToken` function updated
      - Replaced `functions.config().agora.app_id` with `process.env.AGORA_APP_ID`
      - Replaced `functions.config().agora.app_certificate` with `process.env.AGORA_APP_CERTIFICATE`
      - Enhanced validation with detailed error messages
      - Added database context `[DB: elajtech]` to all error logs
  - **Configuration Changes**:
    - Created `functions/.env.example` with template credentials
    - Updated `.gitignore` to exclude `.env` files (functions/.env, functions/.env.local, functions/.env.*.local)
    - Added environment variable validation
    - Maintained backward compatibility with `functions.config()`
  - **Documentation Changes**:
    - `functions/README.md`:
      - Added "Modern Environment Configuration" section (~30 lines)
      - Added 4-step .env setup instructions (~60 lines)
      - Added "Environment Variable Security" section (~150 lines)
      - Added "Environment Variable Configuration Issues" troubleshooting (~250 lines)
      - Updated "Token Generation Failed" troubleshooting
      - Updated version history with 3 new entries for 2026-02-14
  - **Test Changes**:
    - Created `functions/test/env-config.test.js` (8 tests)
    - Created `functions/test/env-vars.test.js` (8 tests)
    - Created `functions/test/env-config-standalone.test.js` (8 tests)
    - All 24 tests passing with 100% success rate
    - Tests verify: token generation, missing variables, error messages, database context
  - **Testing**: 24 new unit tests added for environment variable validation (100% pass rate)
  - **Reference**: `.kiro/specs/agora-env-migration/`

### Migration Guide

#### Migrating from functions.config() to .env

If you're currently using the legacy `functions.config()` approach, follow these steps to migrate:

**Step 1: Create .env File**
```bash
cd functions
cp .env.example .env
```

**Step 2: Get Your Current Credentials**
```bash
# View current configuration
firebase functions:config:get

# You'll see output like:
# {
#   "agora": {
#     "app_id": "your_app_id_here",
#     "app_certificate": "your_certificate_here"
#   }
# }
```

**Step 3: Add Credentials to .env**

Edit `functions/.env` and add your credentials:
```bash
AGORA_APP_ID=your_app_id_here
AGORA_APP_CERTIFICATE=your_certificate_here
```

**Step 4: Verify Configuration**
```bash
# Run configuration tests
npm test -- env-config.test.js

# All 8 tests should pass
```

**Step 5: Deploy (Optional)**

The system automatically falls back to `functions.config()` if `.env` variables are not set, so you can deploy without any downtime:

```bash
# Deploy with new configuration
firebase deploy --only functions

# Monitor logs for any issues
firebase functions:log --only startAgoraCall
```

**Backward Compatibility**:
- The system checks `process.env` first
- If not found, falls back to `functions.config()`
- Zero downtime during migration
- No breaking changes to existing deployments

**Cleanup (Optional)**:

After verifying the new configuration works, you can optionally remove the old configuration:

```bash
# Remove old configuration (optional)
firebase functions:config:unset agora
```

**For More Information**:
- See `functions/README.md` for complete documentation
- See `.kiro/specs/agora-env-migration/` for technical details

## [1.0.0] - 2026-02-13

### Project Status
- **Flutter Tests**: 661 tests passing ✅
- **Test Coverage**: 70%+ maintained
- **Cloud Functions**: 3 functions deployed (europe-west1 region)
- **Database**: Custom Firestore database (`elajtech`)
- **Video Engine**: Agora RTC Engine 6.3.2
- **VoIP System**: flutter_callkit_incoming 2.0.4

### Features
- Real-time video consultations using Agora.io
- VoIP call system with iOS CallKit and Android ConnectionService
- Comprehensive EMR for multiple specialties
- Secure authentication with Firebase Auth
- Cloud-based architecture leveraging Firebase ecosystem
- Multi-platform support (Android & iOS)

### Known Issues
- None (all critical issues resolved)

### Upcoming
- Java 21+ requirement for Cloud Functions tests (environment setup)
- Token refresh mechanism for calls > 1 hour (future enhancement)
- Call recording with user consent (future enhancement)
- Screen sharing capability (future enhancement)

---

## Version History

### Version Numbering
- **Major.Minor.Patch** (Semantic Versioning)
- Major: Breaking changes
- Minor: New features (backward compatible)
- Patch: Bug fixes (backward compatible)

### Release Process
1. All tests must pass (Flutter + Cloud Functions)
2. Code review and approval required
3. Deploy to staging first
4. Manual testing in staging
5. Deploy to production
6. Monitor for 24 hours
7. Update CHANGELOG

### Support
For questions about changes or releases:
- Review this CHANGELOG
- Check [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
- Check [CONTRIBUTING.md](CONTRIBUTING.md)
- Contact development team

---

**Maintained by**: AndroCare360 Development Team  
**Last Updated**: 2026-02-16
