# Design Document: Agora System Migration to Modern .env Environment

## Overview

This document outlines the technical design for migrating the Agora token generation system from Firebase's legacy `functions.config()` to modern `.env` environment variables. The migration maintains full backward compatibility, preserves database isolation, and enhances error handling while aligning with Firebase 2026 standards.

## Design Principles

1. **Minimal Change**: Modify only the configuration access pattern, not the core logic
2. **Fail-Fast**: Detect configuration errors early with clear error messages
3. **Database Isolation**: Maintain strict targeting of 'elajtech' database
4. **Backward Compatibility**: No changes to API contracts or response formats
5. **Security First**: Follow best practices for credential management

## Architecture

### Current Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ generateAgoraToken()                                        │
│                                                             │
│  1. Read config: functions.config().agora.app_id          │
│  2. Read config: functions.config().agora.app_certificate │
│  3. Validate configuration                                 │
│  4. Generate token using RtcTokenBuilder                   │
│  5. Return token                                           │
└─────────────────────────────────────────────────────────────┘
```

### New Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ generateAgoraToken()                                        │
│                                                             │
│  1. Read env: process.env.AGORA_APP_ID                    │
│  2. Read env: process.env.AGORA_APP_CERTIFICATE           │
│  3. Validate configuration (enhanced)                      │
│  4. Generate token using RtcTokenBuilder                   │
│  5. Return token                                           │
└─────────────────────────────────────────────────────────────┘
```

**Key Changes**:
- Configuration source: `functions.config()` → `process.env`
- Enhanced validation with detailed error messages
- Database context in all error messages

## Component Design

### 1. generateAgoraToken Function Refactoring

#### Current Implementation

```javascript
function generateAgoraToken(channelName, uid, role = 'publisher', expirationTime = 3600) {
  const appId = functions.config().agora.app_id;
  const appCertificate = functions.config().agora.app_certificate;

  if (!appId || !appCertificate) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Agora App ID or Certificate not configured'
    );
  }
  
  // ... token generation logic
}
```

#### New Implementation

```javascript
/**
 * دالة توليد Agora Token
 * 
 * Generate Agora RTC token using modern environment variable configuration.
 * Reads credentials from process.env instead of functions.config().
 * 
 * تُستخدم لإنشاء رمز مصادقة آمن ومؤقت لـ Agora RTC
 * تقرأ بيانات الاعتماد من متغيرات البيئة (process.env)
 * 
 * @param {string} channelName - اسم القناة (Channel Name)
 * @param {number} uid - معرّف المستخدم الفريد (User ID)
 * @param {string} role - دور المستخدم ('publisher' أو 'subscriber')
 * @param {number} expirationTime - وقت انتهاء الصلاحية بالثواني (افتراضي: 3600)
 * @returns {string} - Agora Token
 * @throws {functions.https.HttpsError} - If environment variables are not configured
 */
function generateAgoraToken(channelName, uid, role = 'publisher', expirationTime = 3600) {
  // ✅ MODERN CONFIGURATION: Read from environment variables
  // قراءة بيانات الاعتماد من متغيرات البيئة
  const appId = process.env.AGORA_APP_ID;
  const appCertificate = process.env.AGORA_APP_CERTIFICATE;

  // ✅ ENHANCED VALIDATION: Detailed error messages with database context
  // التحقق المحسّن: رسائل خطأ مفصلة مع سياق قاعدة البيانات
  if (!appId || !appCertificate) {
    const missingVars = [];
    if (!appId) missingVars.push('AGORA_APP_ID');
    if (!appCertificate) missingVars.push('AGORA_APP_CERTIFICATE');
    
    const errorMessage = `[DB: elajtech] Agora credentials not configured. Missing environment variables: ${missingVars.join(', ')}. ` +
                        'Please ensure your .env file contains these variables.';
    
    throw new functions.https.HttpsError(
      'failed-precondition',
      errorMessage
    );
  }

  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTime;

  // تحديد الدور (Publisher = 1, Subscriber = 2)
  const agoraRole = role === 'publisher' ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;

  // توليد الـ Token
  const token = RtcTokenBuilder.buildTokenWithUid(
    appId,
    appCertificate,
    channelName,
    uid,
    agoraRole,
    privilegeExpiredTs
  );

  return token;
}
```

**Design Rationale**:
- **process.env Access**: Direct, standard Node.js pattern
- **Enhanced Validation**: Lists specific missing variables
- **Database Context**: All errors prefixed with `[DB: elajtech]`
- **Helpful Guidance**: Error message includes setup instructions
- **Bilingual Documentation**: Arabic and English comments

### 2. Error Handling Enhancement

#### Error Message Design

**Pattern**: `[DB: elajtech] {Error Description}. {Guidance}`

**Examples**:

1. **Missing AGORA_APP_ID**:
   ```
   [DB: elajtech] Agora credentials not configured. Missing environment variables: AGORA_APP_ID. 
   Please ensure your .env file contains these variables.
   ```

2. **Missing Both Variables**:
   ```
   [DB: elajtech] Agora credentials not configured. Missing environment variables: AGORA_APP_ID, AGORA_APP_CERTIFICATE. 
   Please ensure your .env file contains these variables.
   ```

3. **Token Generation Failure** (existing, enhanced):
   ```javascript
   await logCallEvent({
     eventType: 'call_error',
     appointmentId: appointmentId,
     userId: doctorId,
     errorCode: 'token_generation_failed',
     errorMessage: '[DB: elajtech] ' + tokenError.message,
     stackTrace: tokenError.stack,
     deviceInfo: deviceInfo || null,
     metadata: {
       databaseId: 'elajtech',
       missingVariables: missingVars, // If applicable
     },
   });
   ```

### 3. Configuration File Structure

#### .env File (Production)

```env
# ============================================
# Agora RTC Configuration
# ============================================
# These credentials are used to generate secure tokens for video calls.
# NEVER commit this file to version control.
#
# To obtain these credentials:
# 1. Log in to Agora Console: https://console.agora.io/
# 2. Navigate to your project
# 3. Copy App ID and App Certificate
#
# For more information, see functions/README.md

AGORA_APP_ID=f9ff6f5ab52c43d0ab7ba76fcee25dbf
AGORA_APP_CERTIFICATE=a6a7a0d5934041e3843743a929929a27
```

#### .env.example File (Template)

```env
# ============================================
# Agora RTC Configuration (Example)
# ============================================
# Copy this file to .env and replace with your actual credentials.
#
# To obtain these credentials:
# 1. Log in to Agora Console: https://console.agora.io/
# 2. Navigate to your project
# 3. Copy App ID and App Certificate
#
# For more information, see functions/README.md

AGORA_APP_ID=your_agora_app_id_here
AGORA_APP_CERTIFICATE=your_agora_app_certificate_here
```

#### .gitignore Update

```gitignore
# Environment variables (contains secrets)
.env
.env.local
.env.*.local

# Keep example file for documentation
!.env.example
```

### 4. Database Isolation Verification

**No Changes Required** - Database isolation is already correctly implemented:

```javascript
// Existing configuration (UNCHANGED)
admin.initializeApp({
  databaseId: 'elajtech',
});

const db = admin.firestore();
db.settings({ databaseId: 'elajtech' }); // ✅ CRITICAL FIX (from previous bugfix)
```

**Verification Points**:
1. ✅ All `db.collection()` calls use the configured `db` instance
2. ✅ All error logs include `databaseId: 'elajtech'` in metadata
3. ✅ All error messages prefixed with `[DB: elajtech]`
4. ✅ No direct `admin.firestore()` calls without database configuration

### 5. Testing Strategy

#### Unit Tests for Configuration Validation

```javascript
// functions/test/env-config.test.js

describe('Environment Variable Configuration', () => {
  let originalEnv;

  beforeEach(() => {
    // Save original environment
    originalEnv = { ...process.env };
  });

  afterEach(() => {
    // Restore original environment
    process.env = originalEnv;
  });

  test('generateAgoraToken succeeds with valid environment variables', () => {
    process.env.AGORA_APP_ID = 'test_app_id';
    process.env.AGORA_APP_CERTIFICATE = 'test_certificate';

    const token = generateAgoraToken('test_channel', 12345);
    expect(token).toBeDefined();
    expect(typeof token).toBe('string');
  });

  test('generateAgoraToken throws error when AGORA_APP_ID is missing', () => {
    delete process.env.AGORA_APP_ID;
    process.env.AGORA_APP_CERTIFICATE = 'test_certificate';

    expect(() => {
      generateAgoraToken('test_channel', 12345);
    }).toThrow('AGORA_APP_ID');
  });

  test('generateAgoraToken throws error when AGORA_APP_CERTIFICATE is missing', () => {
    process.env.AGORA_APP_ID = 'test_app_id';
    delete process.env.AGORA_APP_CERTIFICATE;

    expect(() => {
      generateAgoraToken('test_channel', 12345);
    }).toThrow('AGORA_APP_CERTIFICATE');
  });

  test('generateAgoraToken throws error when both variables are missing', () => {
    delete process.env.AGORA_APP_ID;
    delete process.env.AGORA_APP_CERTIFICATE;

    expect(() => {
      generateAgoraToken('test_channel', 12345);
    }).toThrow(/AGORA_APP_ID.*AGORA_APP_CERTIFICATE/);
  });

  test('error message includes database context', () => {
    delete process.env.AGORA_APP_ID;

    expect(() => {
      generateAgoraToken('test_channel', 12345);
    }).toThrow('[DB: elajtech]');
  });
});
```

#### Integration Tests

```javascript
// Verify token generation produces identical results
test('token generation produces consistent results', () => {
  process.env.AGORA_APP_ID = 'test_app_id';
  process.env.AGORA_APP_CERTIFICATE = 'test_certificate';

  const token1 = generateAgoraToken('channel', 12345, 'publisher', 3600);
  const token2 = generateAgoraToken('channel', 12345, 'publisher', 3600);

  // Tokens should be identical for same inputs at same timestamp
  expect(token1).toBe(token2);
});
```

## Documentation Updates

### 1. functions/README.md - New Section

```markdown
## Modern Environment Settings

### Overview

AndroCare360 Cloud Functions use environment variables for configuration management. This approach aligns with Firebase 2026 standards and provides better security and maintainability compared to the legacy `functions.config()` method.

### Setting Up Environment Variables

#### 1. Create .env File

In the `functions/` directory, create a `.env` file:

```bash
cd functions
cp .env.example .env
```

#### 2. Configure Agora Credentials

Edit the `.env` file and add your Agora credentials:

```env
AGORA_APP_ID=your_agora_app_id_here
AGORA_APP_CERTIFICATE=your_agora_app_certificate_here
```

**To obtain these credentials:**
1. Log in to [Agora Console](https://console.agora.io/)
2. Navigate to your project
3. Copy App ID and App Certificate

#### 3. Verify Configuration

The functions will automatically load environment variables from the `.env` file. If variables are missing, you'll see a clear error message:

```
[DB: elajtech] Agora credentials not configured. Missing environment variables: AGORA_APP_ID. 
Please ensure your .env file contains these variables.
```

### Security Best Practices

⚠️ **CRITICAL**: Never commit the `.env` file to version control!

- ✅ The `.env` file is listed in `.gitignore`
- ✅ Use `.env.example` for documentation (with placeholder values)
- ✅ Share credentials securely through encrypted channels
- ✅ Rotate credentials regularly

### Migration from functions.config()

If you're migrating from the legacy `functions.config()` approach:

**Old Method (Deprecated)**:
```bash
firebase functions:config:set agora.app_id="YOUR_APP_ID"
firebase functions:config:set agora.app_certificate="YOUR_CERTIFICATE"
```

**New Method (Recommended)**:
```bash
# Create .env file
echo "AGORA_APP_ID=YOUR_APP_ID" > functions/.env
echo "AGORA_APP_CERTIFICATE=YOUR_CERTIFICATE" >> functions/.env
```

### Deployment

The `.env` file is automatically deployed with your functions. Ensure it exists before deploying:

```bash
# Verify .env file exists
ls -la functions/.env

# Deploy functions
firebase deploy --only functions
```

### Troubleshooting

**Error: "Agora credentials not configured"**

1. Verify `.env` file exists in `functions/` directory
2. Check that variable names are correct (case-sensitive)
3. Ensure no extra spaces around `=` sign
4. Verify file is not empty

**Error: "ENOENT: no such file or directory, open '.env'"**

1. Create the `.env` file: `cp functions/.env.example functions/.env`
2. Add your credentials to the file

### Local Development

For local testing with Firebase Emulator:

```bash
# Start emulator (automatically loads .env)
firebase emulators:start

# Or with specific functions
firebase emulators:start --only functions
```

The emulator automatically loads environment variables from `.env` file.
```

### 2. CHANGELOG.md - New Entry

```markdown
## [Unreleased]

### Changed

#### Agora Configuration Migration to Modern .env Environment

**Date**: 2026-02-14

**Type**: Enhancement (Security & Future-Proofing)

**Description**:
Migrated Agora token generation configuration from Firebase's legacy `functions.config()` to modern `.env` environment variables. This change aligns with Firebase 2026 standards and improves security and maintainability.

**Changes**:
- ✅ Replaced `functions.config().agora` with `process.env` for credential access
- ✅ Enhanced configuration validation with detailed error messages
- ✅ Added `.env` file for environment variable management
- ✅ Created `.env.example` template for documentation
- ✅ Updated `.gitignore` to exclude `.env` file
- ✅ Enhanced error messages with database context (`[DB: elajtech]`)
- ✅ Updated documentation with modern configuration guide

**Benefits**:
- **Security**: Standard environment variable approach with better .gitignore support
- **Maintainability**: Simpler configuration management (single .env file)
- **Future-Proofing**: Aligns with Firebase 2026 recommended practices
- **Developer Experience**: Easier local development setup

**Migration Guide**:
1. Create `functions/.env` file from `functions/.env.example`
2. Add your Agora credentials to `.env` file
3. Deploy functions (`.env` is automatically deployed)
4. Old `functions.config()` values are no longer used

**Backward Compatibility**:
- ✅ No changes to API contracts or function signatures
- ✅ No changes required to Flutter application
- ✅ Token generation produces identical results
- ✅ All 661+ existing tests continue to pass

**Database Isolation**:
- ✅ All Firestore operations continue to target `databaseId: 'elajtech'`
- ✅ Database configuration unchanged from previous bugfix

**Reference**: `.kiro/specs/agora-env-migration/`
```

## Implementation Checklist

### Phase 1: Code Changes
- [ ] Update `generateAgoraToken` function to use `process.env`
- [ ] Enhance error validation with detailed messages
- [ ] Add database context to all error messages
- [ ] Update function documentation (bilingual)

### Phase 2: Configuration Files
- [ ] Verify `.env` file exists with correct credentials
- [ ] Create `.env.example` template file
- [ ] Update `.gitignore` to exclude `.env`
- [ ] Verify `.env` is not committed to git

### Phase 3: Testing
- [ ] Create unit tests for environment variable validation
- [ ] Test error messages for missing variables
- [ ] Verify token generation produces identical results
- [ ] Run existing Flutter test suite (661+ tests)
- [ ] Verify database isolation maintained

### Phase 4: Documentation
- [ ] Add "Modern Environment Settings" section to functions/README.md
- [ ] Update CHANGELOG.md with migration details
- [ ] Document migration from functions.config()
- [ ] Add troubleshooting guide

### Phase 5: Deployment
- [ ] Verify `.env` file deployed with functions
- [ ] Deploy to production (europe-west1)
- [ ] Monitor function logs for configuration errors
- [ ] Verify token generation working correctly

## Risk Assessment

### Risk Level: **LOW**

**Rationale**:
1. ✅ Minimal code change (configuration access only)
2. ✅ No changes to token generation logic
3. ✅ No changes to API contracts
4. ✅ Backward compatible
5. ✅ Simple rollback procedure

### Potential Issues

| Issue | Likelihood | Impact | Mitigation |
|-------|-----------|--------|------------|
| .env file not deployed | Low | High | Verify file exists before deployment |
| Environment variables not loaded | Very Low | High | Enhanced error messages guide troubleshooting |
| Token generation differs | Very Low | High | Unit tests verify identical results |
| Database isolation broken | Very Low | High | Verification tests confirm isolation |

## Rollback Plan

If issues are detected after deployment:

```bash
# 1. Revert to previous version
git checkout <previous-commit>

# 2. Redeploy
firebase deploy --only functions

# 3. Verify rollback
firebase functions:log --only startAgoraCall
```

**Rollback Time**: < 5 minutes

## Success Criteria

### Deployment Success
- ✅ All functions deployed successfully
- ✅ No deployment errors
- ✅ Environment variables loaded correctly
- ✅ Token generation working

### Functional Validation
- ✅ Tokens generated successfully
- ✅ Video calls initiate correctly
- ✅ Error messages clear and helpful
- ✅ Database isolation maintained

### Quality Assurance
- ✅ All 661+ existing tests passing
- ✅ New unit tests passing
- ✅ Documentation complete
- ✅ No breaking changes

## Correctness Properties

### Property 1: Configuration Validation Completeness
**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5**

For all possible environment variable states:
- If AGORA_APP_ID is missing → Error lists AGORA_APP_ID
- If AGORA_APP_CERTIFICATE is missing → Error lists AGORA_APP_CERTIFICATE
- If both are missing → Error lists both variables
- If both are present → No error thrown

### Property 2: Token Generation Consistency
**Validates: Requirements 1.1, 1.2, 5.4**

For all valid inputs (channelName, uid, role, expirationTime):
- Token generated with process.env === Token generated with functions.config()
- Same inputs at same timestamp → Identical tokens
- Token format and structure unchanged

### Property 3: Database Isolation Preservation
**Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5**

For all Firestore operations:
- All queries target databaseId: 'elajtech'
- All logs written to 'elajtech' database
- No queries to default database
- Database configuration unchanged

### Property 4: Error Message Consistency
**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**

For all error conditions:
- All error messages prefixed with '[DB: elajtech]'
- Missing variables listed explicitly
- Guidance included in error message
- Error logged to call_logs with metadata

### Property 5: Backward Compatibility
**Validates: Requirements 5.1, 5.2, 5.3, 5.5**

For all API calls:
- Function signatures unchanged
- Response formats unchanged
- Client behavior unchanged
- All existing tests pass

## Conclusion

This design provides a comprehensive migration path from legacy `functions.config()` to modern `.env` environment variables. The approach is minimal, secure, and maintains full backward compatibility while enhancing error handling and aligning with Firebase 2026 standards.

**Key Achievements**:
- ✅ Modern configuration approach
- ✅ Enhanced error handling
- ✅ Maintained database isolation
- ✅ Zero breaking changes
- ✅ Comprehensive documentation

