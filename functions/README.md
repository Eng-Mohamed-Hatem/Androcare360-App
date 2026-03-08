# AndroCare360 Cloud Functions

This directory contains Firebase Cloud Functions for the AndroCare360 telemedicine platform.

## Overview

The Cloud Functions handle backend operations for video call management, including:
- Agora token generation
- Video call initiation and termination
- Appointment completion workflow
- VoIP notifications to patients
- Call event logging and monitoring

## Critical Configuration

### ⚠️ Database Configuration Requirement

**CRITICAL**: All Cloud Functions MUST use the `elajtech` custom Firestore database.

The Firebase Admin SDK requires explicit database configuration to ensure all queries target the correct database:

```javascript
// ✅ CORRECT - Required configuration
admin.initializeApp({
  databaseId: 'elajtech',
});

const db = admin.firestore();
db.settings({ databaseId: 'elajtech' }); // ✅ CRITICAL LINE
```

**Why This Is Required**:
- The `databaseId` in `initializeApp()` doesn't always propagate to Firestore operations
- Without `db.settings()`, queries may fall back to the default database
- This causes "Appointment Not Found" errors even when appointments exist

**Reference**: See the VoIP Appointment Not Found Bugfix spec for full details.

### Region Configuration

All functions are deployed in the **europe-west1** region:

```javascript
exports.functionName = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    // Function implementation
  });
```

## Modern Environment Configuration

### Overview

As of **2026-02-14**, AndroCare360 Cloud Functions use modern `.env` environment variables for configuration instead of Firebase's legacy `functions.config()` system.

**Benefits of .env Approach**:
- ✅ **Industry Standard**: Follows the widely-adopted 12-factor app methodology
- ✅ **Better Security**: Credentials stored in local files, not in Firebase config
- ✅ **Easier Development**: Simple file-based configuration for local development
- ✅ **Version Control Friendly**: .env.example provides template without exposing secrets
- ✅ **Future-Proof**: Aligns with Firebase 2026+ best practices
- ✅ **Simpler Deployment**: No need for separate `firebase functions:config:set` commands

**Migration from functions.config()**:

The legacy `functions.config()` approach is deprecated. If you're migrating from the old system:

| Legacy Approach | Modern Approach |
|----------------|-----------------|
| `firebase functions:config:set agora.app_id="..."` | Add `AGORA_APP_ID=...` to `.env` file |
| `firebase functions:config:get` | View `.env` file contents |
| `functions.config().agora.app_id` | `process.env.AGORA_APP_ID` |

**Backward Compatibility**: The system automatically falls back to `functions.config()` if `.env` variables are not set, ensuring zero downtime during migration.

## Setup Instructions

### Prerequisites

- Node.js (v18 or later)
- Firebase CLI (`npm install -g firebase-tools`)
- Firebase project access (elajtech)
- Agora App ID and Certificate (see Step 4.2 for how to obtain)

### Installation

1. **Install Dependencies**
   ```bash
   cd functions
   npm install
   ```

2. **Login to Firebase**
   ```bash
   firebase login
   ```

3. **Select Project**
   ```bash
   firebase use elajtech
   ```

4. **Configure Agora Credentials**

   **Step 4.1: Create .env File**
   
   Copy the example template to create your local configuration:
   
   ```bash
   cd functions
   cp .env.example .env
   ```

   **Step 4.2: Obtain Agora Credentials**
   
   1. Log in to [Agora Console](https://console.agora.io/)
   2. Navigate to your project (or create a new one)
   3. Go to **Project Management** → **Project Settings**
   4. Copy the following credentials:
      - **App ID**: Public identifier (visible in project list)
      - **App Certificate**: Secret key (click "Enable" if not already enabled)

   **Step 4.3: Edit .env File**
   
   Open `functions/.env` in your text editor and replace the placeholder values:
   
   ```bash
   # Before (placeholders)
   AGORA_APP_ID=your_agora_app_id_here
   AGORA_APP_CERTIFICATE=your_agora_app_certificate_here
   
   # After (your actual credentials)
   AGORA_APP_ID=a1b2c3d4e5f6g7h8i9j0
   AGORA_APP_CERTIFICATE=1234567890abcdef1234567890abcdef
   ```

   **Step 4.4: Verify Configuration**
   
   Ensure your `.env` file is properly configured:
   
   ```bash
   # Check that .env file exists
   ls -la functions/.env
   
   # Verify .env is NOT tracked by git (should not appear in git status)
   git status
   
   # Run configuration validation test
   npm test -- env-config.test.js
   ```

   **Example .env File Structure**:
   
   ```bash
   # ============================================
   # Agora RTC Configuration
   # ============================================
   
   # Agora App ID (Public identifier)
   AGORA_APP_ID=a1b2c3d4e5f6g7h8i9j0
   
   # Agora App Certificate (Secret key)
   AGORA_APP_CERTIFICATE=1234567890abcdef1234567890abcdef
   ```

   **⚠️ IMPORTANT**: Never commit the `.env` file to version control! It contains sensitive credentials.

### Local Development

#### Using Firebase Emulator

1. **Start Emulators**
   ```bash
   firebase emulators:start
   ```

2. **Run Tests**
   ```bash
   cd functions
   npm test
   ```

3. **Run Tests with Coverage**
   ```bash
   npm run test:coverage
   ```

#### Emulator Ports

- Firestore: `localhost:8080`
- Auth: `localhost:9099`
- Functions: `localhost:5001`

## Testing

### Test Structure

```
functions/test/
├── setup.js                    # Test environment configuration
├── fixtures.js                 # Test data factories
├── database-config.test.js     # Database configuration tests (24 tests)
├── integration.test.js         # Integration tests (17 tests)
└── database-isolation.test.js  # Database isolation tests (7 tests)
```

### Running Tests

```bash
# Run all tests
npm test

# Run specific test file
npm test -- database-config.test.js

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm run test:coverage
```

### Test Requirements

- **Java 21+** required for Firebase Emulator
- All tests use Firebase Emulator (no production data)
- Tests verify database configuration correctness
- Property-based tests run 100 iterations per property

### Expected Test Results

- **Unit Tests**: 24 tests
- **Integration Tests**: 17 tests
- **Isolation Tests**: 7 tests
- **Property Tests**: 400 iterations (4 properties × 100 each)
- **Total**: 48 tests + 400 property test scenarios

## Deployment

### Pre-Deployment Checklist

- [ ] All tests passing (`npm test`)
- [ ] Code reviewed and approved
- [ ] Syntax verified (`node -c index.js`)
- [ ] Flutter tests passing (627+ tests)
- [ ] Documentation updated

### Deploy to Staging

```bash
firebase use elajtech-staging
firebase deploy --only functions
```

### Deploy to Production

```bash
firebase use elajtech
firebase deploy --only functions
```

### Monitor Deployment

```bash
# Watch real-time logs
firebase functions:log

# Watch specific function
firebase functions:log --only startAgoraCall
```

### Rollback (If Needed)

```bash
# Revert to previous version
git checkout <previous-commit>
firebase deploy --only functions
```

## Cloud Functions API

### startAgoraCall

Initiates a video call session by generating Agora tokens and notifying the patient.

**Endpoint**: `startAgoraCall`  
**Region**: europe-west1  
**Authentication**: Required (Firebase Auth)

**Request**:
```javascript
{
  appointmentId: string,  // Required
  doctorId: string,       // Required
  deviceInfo: object      // Optional
}
```

**Response**:
```javascript
{
  success: boolean,
  message: string,
  agoraChannelName: string,
  agoraToken: string,
  agoraUid: number
}
```

**Error Codes**:
- `unauthenticated`: User not authenticated
- `invalid-argument`: Missing required parameters
- `not-found`: Appointment not found in elajtech database
- `permission-denied`: User not authorized to start this call

### endAgoraCall

Marks the end of a video call session.

**Endpoint**: `endAgoraCall`  
**Region**: europe-west1  
**Authentication**: Required

**Request**:
```javascript
{
  appointmentId: string  // Required
}
```

**Response**:
```javascript
{
  success: boolean,
  message: string
}
```

### completeAppointment

Marks an appointment as completed after the consultation.

**Endpoint**: `completeAppointment`  
**Region**: europe-west1  
**Authentication**: Required

**Request**:
```javascript
{
  appointmentId: string,  // Required
  doctorId: string        // Required
}
```

**Response**:
```javascript
{
  success: boolean,
  message: string
}
```

## Troubleshooting

### "Appointment Not Found" Error

**Symptom**: Function returns "not-found" error even though appointment exists.

**Cause**: Database configuration not applied correctly.

**Solution**: Verify `db.settings({ databaseId: 'elajtech' })` is present in `index.js`.

### "NOT_FOUND" Function Error

**Symptom**: Function not found when called from Flutter app.

**Cause**: Wrong region specified in Flutter app.

**Solution**: Ensure Flutter app uses `region: 'europe-west1'`:
```dart
final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
```

### Token Generation Failed

**Symptom**: `failed-precondition` error about Agora credentials.

**Cause**: Agora App ID or Certificate not configured in `.env` file.

**Solution**: Create and configure `.env` file:
```bash
# Create .env from template
cd functions
cp .env.example .env

# Edit .env and add your credentials
# AGORA_APP_ID=your_actual_app_id
# AGORA_APP_CERTIFICATE=your_actual_certificate

# Verify configuration
npm test -- env-config.test.js
```

**Legacy Solution** (if using functions.config()):
```bash
firebase functions:config:set agora.app_id="YOUR_APP_ID"
firebase functions:config:set agora.app_certificate="YOUR_CERTIFICATE"
```

### Environment Variable Configuration Issues

#### Missing .env File

**Symptom**: 
```
Error: [DB: elajtech] Agora credentials not configured. 
Missing environment variables: AGORA_APP_ID, AGORA_APP_CERTIFICATE. 
Please ensure your .env file contains these variables.
```

**Cause**: The `.env` file doesn't exist or is not in the correct location.

**Solution**:

1. **Check if .env file exists**:
   ```bash
   ls -la functions/.env
   ```

2. **If missing, create from template**:
   ```bash
   cd functions
   cp .env.example .env
   ```

3. **Edit .env and add your credentials**:
   ```bash
   # Open in your text editor
   nano .env  # or code .env, vim .env, etc.
   
   # Add your actual credentials
   AGORA_APP_ID=your_actual_app_id
   AGORA_APP_CERTIFICATE=your_actual_certificate
   ```

4. **Verify configuration**:
   ```bash
   npm test -- env-config.test.js
   ```

#### Missing AGORA_APP_ID

**Symptom**:
```
Error: [DB: elajtech] Agora credentials not configured. 
Missing environment variables: AGORA_APP_ID.
```

**Cause**: `AGORA_APP_ID` is not set in `.env` file or is empty.

**Solution**:

1. **Open .env file**:
   ```bash
   cat functions/.env
   ```

2. **Verify AGORA_APP_ID is present and not empty**:
   ```bash
   # ❌ WRONG - Empty or placeholder
   AGORA_APP_ID=
   AGORA_APP_ID=your_agora_app_id_here
   
   # ✅ CORRECT - Actual value
   AGORA_APP_ID=a1b2c3d4e5f6g7h8i9j0
   ```

3. **Get App ID from Agora Console**:
   - Log in to [Agora Console](https://console.agora.io/)
   - Navigate to Project Management
   - Copy App ID from project list

4. **Update .env and test**:
   ```bash
   npm test -- env-config.test.js
   ```

#### Missing AGORA_APP_CERTIFICATE

**Symptom**:
```
Error: [DB: elajtech] Agora credentials not configured. 
Missing environment variables: AGORA_APP_CERTIFICATE.
```

**Cause**: `AGORA_APP_CERTIFICATE` is not set in `.env` file or is empty.

**Solution**:

1. **Open .env file**:
   ```bash
   cat functions/.env
   ```

2. **Verify AGORA_APP_CERTIFICATE is present and not empty**:
   ```bash
   # ❌ WRONG - Empty or placeholder
   AGORA_APP_CERTIFICATE=
   AGORA_APP_CERTIFICATE=your_agora_app_certificate_here
   
   # ✅ CORRECT - Actual value
   AGORA_APP_CERTIFICATE=1234567890abcdef1234567890abcdef
   ```

3. **Get App Certificate from Agora Console**:
   - Log in to [Agora Console](https://console.agora.io/)
   - Navigate to Project Settings
   - Enable App Certificate if not already enabled
   - Copy App Certificate (keep it secret!)

4. **Update .env and test**:
   ```bash
   npm test -- env-config.test.js
   ```

#### .env File Not Loaded

**Symptom**: Functions work locally but fail in production with missing credentials error.

**Cause**: `.env` file is only loaded in local development. Production requires different configuration.

**Solution**:

**For Local Development**:
```bash
# .env file is automatically loaded by Node.js
cd functions
npm test
```

**For Firebase Emulator**:
```bash
# .env file is automatically loaded
firebase emulators:start
```

**For Production Deployment**:
```bash
# Option 1: Use Firebase Functions secrets (recommended)
firebase functions:secrets:set AGORA_APP_ID
firebase functions:secrets:set AGORA_APP_CERTIFICATE

# Option 2: Use legacy functions.config() (deprecated)
firebase functions:config:set agora.app_id="YOUR_APP_ID"
firebase functions:config:set agora.app_certificate="YOUR_CERTIFICATE"

# Deploy
firebase deploy --only functions
```

#### Verifying Configuration

**How to Verify .env Configuration is Working**:

1. **Run Configuration Tests**:
   ```bash
   cd functions
   npm test -- env-config.test.js
   ```

   Expected output:
   ```
   PASS  test/env-config.test.js
     Environment Variable Configuration
       ✓ generateAgoraToken succeeds with valid environment variables
       ✓ generateAgoraToken throws error when AGORA_APP_ID is missing
       ✓ generateAgoraToken throws error when AGORA_APP_CERTIFICATE is missing
       ✓ error message includes database context [DB: elajtech]
   
   Test Suites: 1 passed, 1 total
   Tests:       8 passed, 8 total
   ```

2. **Test Token Generation Manually**:
   ```javascript
   // In Node.js REPL or test script
   require('dotenv').config();
   const { generateAgoraToken } = require('./index');
   
   const token = generateAgoraToken('test_channel', 12345);
   console.log('Token generated:', token);
   ```

3. **Check Environment Variables are Loaded**:
   ```bash
   # In functions directory
   node -e "require('dotenv').config(); console.log('AGORA_APP_ID:', process.env.AGORA_APP_ID ? 'SET' : 'NOT SET');"
   ```

4. **Verify .env is in .gitignore**:
   ```bash
   # .env should NOT appear in git status
   git status
   
   # Verify .gitignore contains .env
   grep -r "\.env" .gitignore
   ```

#### Local Development Setup

**Complete Local Development Setup Checklist**:

- [ ] Node.js v18+ installed (`node --version`)
- [ ] Firebase CLI installed (`firebase --version`)
- [ ] Java 21+ installed for emulator (`java -version`)
- [ ] Project dependencies installed (`npm install`)
- [ ] `.env` file created from `.env.example`
- [ ] Agora credentials added to `.env`
- [ ] `.env` is in `.gitignore`
- [ ] Configuration tests pass (`npm test -- env-config.test.js`)
- [ ] Firebase emulator starts successfully (`firebase emulators:start`)
- [ ] All tests pass (`npm test`)

**Quick Setup Script**:

```bash
#!/bin/bash
# Quick setup script for local development

# Navigate to functions directory
cd functions

# Install dependencies
npm install

# Create .env from template
if [ ! -f .env ]; then
  cp .env.example .env
  echo "✅ Created .env file from template"
  echo "⚠️  Please edit .env and add your Agora credentials"
else
  echo "✅ .env file already exists"
fi

# Verify .env is in .gitignore
if grep -q "\.env" ../.gitignore; then
  echo "✅ .env is in .gitignore"
else
  echo "⚠️  Adding .env to .gitignore"
  echo "functions/.env" >> ../.gitignore
fi

# Run configuration tests
echo "Running configuration tests..."
npm test -- env-config.test.js

echo ""
echo "Setup complete! Next steps:"
echo "1. Edit functions/.env and add your Agora credentials"
echo "2. Run 'firebase emulators:start' to start local development"
echo "3. Run 'npm test' to verify everything works"
```

Save this as `functions/setup-local-dev.sh` and run:
```bash
chmod +x functions/setup-local-dev.sh
./functions/setup-local-dev.sh
```

### Tests Timeout

**Symptom**: Tests fail with "Exceeded timeout of 10000 ms".

**Cause**: Firebase Emulator not running or Java version < 21.

**Solution**:
1. Install Java 21+: `java -version`
2. Start emulator: `firebase emulators:start`
3. Run tests in another terminal: `npm test`

### Database Isolation Test Fails

**Symptom**: "The default Firebase app already exists" error.

**Cause**: Multiple Firebase Admin initializations.

**Solution**: Use named app instance in isolation tests:
```javascript
admin.initializeApp({ databaseId: 'elajtech' }, 'isolation-test-app');
```

## Call Monitoring

### Call Logs Collection

All call events are logged to the `call_logs` collection in the `elajtech` database:

```javascript
{
  eventType: 'call_attempt' | 'call_started' | 'call_error' | 'call_ended',
  appointmentId: string,
  userId: string,
  timestamp: Timestamp,
  errorCode?: string,
  errorMessage?: string,
  stackTrace?: string,
  deviceInfo?: object,
  metadata: {
    databaseId: 'elajtech',
    collectionName: 'call_logs',
    // ... additional context
  }
}
```

### Enhanced Error Logging

All error messages now include database context:

```javascript
errorMessage: '[DB: elajtech] الموعد غير موجود في قاعدة البيانات elajtech'
metadata: {
  databaseId: 'elajtech',
  queriedDatabase: 'elajtech',
  queriedCollection: 'appointments',
  queriedDocumentId: 'apt_123'
}
```

### Querying Call Logs

```javascript
// Get all error logs
const errorLogs = await db.collection('call_logs')
  .where('eventType', '==', 'call_error')
  .orderBy('timestamp', 'desc')
  .limit(100)
  .get();

// Get logs for specific appointment
const appointmentLogs = await db.collection('call_logs')
  .where('appointmentId', '==', 'apt_123')
  .orderBy('timestamp', 'asc')
  .get();
```

## Best Practices

### Database Access

✅ **DO**:
- Always use the injected `db` instance
- Verify database configuration in tests
- Include database context in error logs

❌ **DON'T**:
- Create new Firestore instances without database configuration
- Assume default database is correct
- Skip database configuration in tests

### Error Handling

✅ **DO**:
- Log all errors with full context
- Include database ID in error metadata
- Use typed exceptions (`functions.https.HttpsError`)

❌ **DON'T**:
- Throw generic errors without context
- Skip error logging
- Expose sensitive information in error messages

### Testing

✅ **DO**:
- Test with Firebase Emulator
- Verify database configuration in tests
- Run property-based tests with 100+ iterations

❌ **DON'T**:
- Test against production database
- Skip database isolation tests
- Assume configuration works without testing

## Security

### Token Security

- Agora tokens expire after 1 hour
- Tokens are generated server-side only
- Never expose App Certificate in client code

### Authentication

- All functions require Firebase Auth
- User ID verified against appointment data
- Permission checks before sensitive operations

### Data Access

- Firestore security rules enforce access control
- Functions validate user permissions
- Call logs are write-only (prevent tampering)

### Environment Variable Security

#### .env File Protection

**Critical Security Rules**:

1. **Never Commit .env Files**
   
   The `.env` file contains sensitive credentials and must NEVER be committed to version control.
   
   ```bash
   # ✅ CORRECT - .env is in .gitignore
   functions/.env
   functions/.env.local
   functions/.env.*.local
   
   # ✅ CORRECT - .env.example is tracked (no secrets)
   !functions/.env.example
   ```

2. **Verify .gitignore Configuration**
   
   Before committing any changes, verify `.env` is properly ignored:
   
   ```bash
   # Check git status - .env should NOT appear
   git status
   
   # If .env appears, add it to .gitignore immediately
   echo "functions/.env" >> .gitignore
   git add .gitignore
   git commit -m "chore: add .env to .gitignore"
   ```

3. **Remove .env from Git History (If Accidentally Committed)**
   
   If you accidentally committed `.env`, remove it from git history:
   
   ```bash
   # Remove from current commit
   git rm --cached functions/.env
   git commit -m "chore: remove .env from version control"
   
   # If already pushed, contact team lead immediately
   # The credentials must be rotated (see Credential Rotation below)
   ```

#### Credential Rotation

**When to Rotate Credentials**:

- ✅ Immediately if `.env` was accidentally committed to git
- ✅ Immediately if credentials were exposed in logs or error messages
- ✅ Every 90 days as a security best practice
- ✅ When a team member with access leaves the project
- ✅ After any suspected security breach

**How to Rotate Credentials**:

1. **Generate New Credentials in Agora Console**
   - Log in to [Agora Console](https://console.agora.io/)
   - Navigate to Project Settings
   - Click "Regenerate" for App Certificate
   - Copy new App Certificate

2. **Update .env File**
   ```bash
   # Edit functions/.env
   AGORA_APP_CERTIFICATE=new_certificate_here
   ```

3. **Deploy Updated Configuration**
   ```bash
   firebase deploy --only functions
   ```

4. **Verify Deployment**
   ```bash
   # Test token generation
   npm test -- env-config.test.js
   
   # Monitor function logs for errors
   firebase functions:log --only startAgoraCall
   ```

5. **Revoke Old Credentials**
   - In Agora Console, disable the old certificate
   - Monitor for any errors indicating old credentials in use

#### Production Deployment Security

**For Production Environments**:

1. **Use Firebase Hosting Environment Variables** (Recommended)
   
   For production deployments, use Firebase's secure environment variable storage:
   
   ```bash
   # Set production credentials (one-time setup)
   firebase functions:secrets:set AGORA_APP_ID
   firebase functions:secrets:set AGORA_APP_CERTIFICATE
   ```

2. **Restrict Access to .env Files**
   
   On production servers, ensure `.env` files have restricted permissions:
   
   ```bash
   chmod 600 functions/.env  # Read/write for owner only
   ```

3. **Audit Access Logs**
   
   Regularly review who has access to production credentials:
   
   ```bash
   # List Firebase project members
   firebase projects:list
   
   # Review IAM permissions
   # Go to Firebase Console → Project Settings → Users and Permissions
   ```

#### Development Team Guidelines

**For Team Members**:

- ✅ **DO**: Keep your local `.env` file secure and private
- ✅ **DO**: Use `.env.example` as a template for new team members
- ✅ **DO**: Request credentials from team lead via secure channel (not email/Slack)
- ✅ **DO**: Delete local `.env` when leaving the project
- ❌ **DON'T**: Share `.env` file contents via email, Slack, or any messaging platform
- ❌ **DON'T**: Screenshot or copy `.env` contents to documentation
- ❌ **DON'T**: Store `.env` in cloud storage (Dropbox, Google Drive, etc.)

**For Team Leads**:

- ✅ **DO**: Provide credentials via secure password manager (1Password, LastPass, etc.)
- ✅ **DO**: Rotate credentials when team members leave
- ✅ **DO**: Maintain audit log of who has access to credentials
- ✅ **DO**: Review Firebase project permissions quarterly

## Support

For questions or issues:

1. Check this README
2. Review [API_DOCUMENTATION.md](../API_DOCUMENTATION.md)
3. Check [CONTRIBUTING.md](../CONTRIBUTING.md)
4. Review call logs in Firestore
5. Contact development team

## Version History

- **2026-02-14**: Migrated to modern .env environment variables
- **2026-02-14**: Added comprehensive .env setup and troubleshooting documentation
- **2026-02-14**: Enhanced security best practices for credential management
- **2026-02-13**: Database configuration fix implemented
- **2026-02-13**: Enhanced error logging with database context
- **2026-02-13**: Comprehensive test suite added

---

**Last Updated**: 2026-02-14  
**Maintained by**: AndroCare360 Development Team
