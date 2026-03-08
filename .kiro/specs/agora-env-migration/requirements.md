# Requirements Document: Agora System Migration to Modern .env Environment

## Introduction

This document specifies the requirements for migrating the Agora token generation system from Firebase's legacy `functions.config()` to modern `.env` environment variables. This migration aligns with Firebase 2026 standards, improves security, and simplifies configuration management while maintaining backward compatibility and database isolation.

## Glossary

- **functions.config()**: Legacy Firebase Functions configuration method (deprecated in Firebase 2026)
- **process.env**: Modern Node.js environment variable access pattern
- **.env File**: Environment configuration file for local development and deployment
- **Agora_Token**: JWT token required to join Agora video channels (1-hour expiration)
- **AGORA_APP_ID**: Public identifier for Agora application
- **AGORA_APP_CERTIFICATE**: Secret key for generating secure Agora tokens
- **Cloud_Functions**: Firebase Cloud Functions (v2) deployed in europe-west1 region
- **Elajtech_Database**: The custom Firestore database with ID 'elajtech' used by AndroCare360
- **Database_Isolation**: Ensuring all Firestore operations target only the 'elajtech' database

## Requirements

### Requirement 1: Environment Variable Migration

**User Story:** As a developer, I want to use modern `.env` configuration for Agora credentials, so that the system complies with Firebase 2026 standards and simplifies deployment.

#### Acceptance Criteria

1. WHEN the generateAgoraToken function is invoked, THE function SHALL read AGORA_APP_ID from process.env.AGORA_APP_ID
2. WHEN the generateAgoraToken function is invoked, THE function SHALL read AGORA_APP_CERTIFICATE from process.env.AGORA_APP_CERTIFICATE
3. THE system SHALL NOT use functions.config().agora for any configuration access
4. THE .env file SHALL contain AGORA_APP_ID and AGORA_APP_CERTIFICATE variables
5. THE .env file SHALL be listed in .gitignore to prevent credential exposure

### Requirement 2: Configuration Validation

**User Story:** As a system administrator, I want comprehensive validation of environment variables, so that configuration errors are detected early and provide clear error messages.

#### Acceptance Criteria

1. WHEN AGORA_APP_ID is undefined or empty, THE system SHALL throw an HttpsError with code 'failed-precondition'
2. WHEN AGORA_APP_CERTIFICATE is undefined or empty, THE system SHALL throw an HttpsError with code 'failed-precondition'
3. WHEN configuration validation fails, THE error message SHALL be prefixed with '[DB: elajtech]'
4. WHEN configuration validation fails, THE error SHALL be logged to call_logs collection with database context
5. THE validation SHALL occur before any token generation attempt

### Requirement 3: Error Handling Enhancement

**User Story:** As a developer, I want enhanced error messages for configuration issues, so that I can quickly diagnose and resolve deployment problems.

#### Acceptance Criteria

1. WHEN AGORA_APP_ID is missing, THE error message SHALL state "AGORA_APP_ID environment variable is not configured"
2. WHEN AGORA_APP_CERTIFICATE is missing, THE error message SHALL state "AGORA_APP_CERTIFICATE environment variable is not configured"
3. WHEN both variables are missing, THE error message SHALL list both missing variables
4. THE error messages SHALL include guidance on how to configure the .env file
5. THE error logs SHALL include metadata about the configuration check

### Requirement 4: Database Isolation Preservation

**User Story:** As a system administrator, I want to ensure database isolation is maintained during migration, so that all Firestore operations continue to target the 'elajtech' database exclusively.

#### Acceptance Criteria

1. WHEN any Cloud Function executes, ALL Firestore queries SHALL target databaseId: 'elajtech'
2. THE db.settings({ databaseId: 'elajtech' }) configuration SHALL remain unchanged
3. WHEN logging call events, THE logs SHALL be written to the 'elajtech' database
4. WHEN querying appointments, THE queries SHALL target the 'elajtech' database
5. WHEN querying users, THE queries SHALL target the 'elajtech' database

### Requirement 5: Backward Compatibility

**User Story:** As a developer, I want the migration to maintain API compatibility, so that no Flutter application changes are required.

#### Acceptance Criteria

1. WHEN the startAgoraCall function is invoked, THE function signature SHALL remain unchanged
2. WHEN tokens are generated, THE response format SHALL remain unchanged
3. WHEN the migration is deployed, ALL existing unit tests SHALL continue to pass (661+ tests)
4. THE token generation logic SHALL produce identical tokens for the same inputs
5. THE function behavior SHALL be identical from the client's perspective

### Requirement 6: Documentation Updates

**User Story:** As a developer, I want comprehensive documentation for the new configuration approach, so that I can set up and maintain the system correctly.

#### Acceptance Criteria

1. THE functions/README.md SHALL include a "Modern Environment Settings" section
2. THE documentation SHALL explain how to create and configure the .env file
3. THE documentation SHALL provide example .env file content (with placeholder values)
4. THE documentation SHALL explain the migration from functions.config() to process.env
5. THE CHANGELOG.md SHALL document this migration as a security and future-proofing enhancement

### Requirement 7: Security Best Practices

**User Story:** As a security engineer, I want the migration to follow security best practices, so that credentials are protected and not exposed in version control.

#### Acceptance Criteria

1. THE .env file SHALL be listed in .gitignore
2. THE .env.example file SHALL be created with placeholder values for documentation
3. THE documentation SHALL warn against committing actual credentials
4. THE error messages SHALL NOT expose actual credential values
5. THE logs SHALL NOT include actual credential values

### Requirement 8: Testing and Validation

**User Story:** As a quality assurance engineer, I want comprehensive testing for the migration, so that I can ensure the system works correctly with the new configuration approach.

#### Acceptance Criteria

1. THE test suite SHALL include unit tests for environment variable validation
2. THE test suite SHALL verify error messages for missing configuration
3. THE test suite SHALL verify token generation with process.env configuration
4. WHEN tests are executed, THE tests SHALL use mock environment variables
5. THE existing Flutter test suite SHALL pass without modifications (661+ tests)

## Special Requirements Guidance

### Environment Variable Configuration Pattern

The Cloud Functions implementation must use this pattern:

```javascript
// Read from process.env
const appId = process.env.AGORA_APP_ID;
const appCertificate = process.env.AGORA_APP_CERTIFICATE;

// Validate configuration
if (!appId || !appCertificate) {
  throw new functions.https.HttpsError(
    'failed-precondition',
    '[DB: elajtech] Agora credentials not configured. Missing: ' +
    (!appId ? 'AGORA_APP_ID ' : '') +
    (!appCertificate ? 'AGORA_APP_CERTIFICATE' : '')
  );
}
```

### .env File Structure

```env
# Agora RTC Configuration
AGORA_APP_ID=your_app_id_here
AGORA_APP_CERTIFICATE=your_app_certificate_here
```

### Critical Testing Requirements

- All changes must maintain the 661+ existing test pass rate
- Token generation must produce identical results
- Database isolation must be verified
- Configuration validation must be tested

### Deployment Considerations

- Cloud Functions must be redeployed to europe-west1 region
- .env file must be deployed with functions
- No changes required to Flutter application
- Zero downtime deployment possible

## Migration Benefits

### Security Improvements

1. **Standard Practice**: Aligns with industry-standard environment variable usage
2. **Version Control Safety**: .env files are naturally excluded from git
3. **Deployment Flexibility**: Easier to manage different credentials per environment

### Maintainability Improvements

1. **Simplified Configuration**: Single .env file instead of Firebase CLI commands
2. **Local Development**: Easier to set up local development environment
3. **Documentation**: More intuitive for new developers

### Future-Proofing

1. **Firebase 2026 Compliance**: Aligns with Firebase's recommended practices
2. **Deprecation Avoidance**: Moves away from legacy functions.config()
3. **Ecosystem Compatibility**: Standard approach works with other Node.js tools

## Non-Functional Requirements

### Performance

- Token generation performance must remain unchanged
- No additional latency introduced by environment variable access
- Configuration validation must complete in < 1ms

### Reliability

- Configuration errors must be detected at function initialization
- Clear error messages must guide troubleshooting
- Fallback mechanisms not required (fail-fast approach)

### Maintainability

- Code must be well-documented with bilingual comments (Arabic/English)
- Configuration approach must be consistent across all functions
- Error handling must follow existing patterns

