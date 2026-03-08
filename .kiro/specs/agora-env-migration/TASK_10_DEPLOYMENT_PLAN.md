# Task 10 Deployment Plan: Deploy to Production

**Date**: 2026-02-14  
**Spec**: Agora Environment Migration  
**Task**: Task 10 - Deploy to production  
**Status**: Ready for Execution

---

## ⚠️ CRITICAL: Deployment Prerequisites

Before starting Task 10, ensure:

- ✅ **All previous tasks complete** (Tasks 1-9)
- ✅ **All tests passing** (81/81 verification tests + 661+ Flutter tests)
- ✅ **No breaking changes** (verified in Task 9)
- ✅ **Backup plan ready** (rollback procedure documented)
- ✅ **Team notified** (deployment window communicated)

---

## Overview

Task 10 deploys the Agora environment migration to production. This is a **low-risk deployment** because:

1. **Zero breaking changes** (verified in Task 9)
2. **Only configuration source changed** (functions.config() → process.env)
3. **Same values, different source** (credentials unchanged)
4. **Backward compatible** (no Flutter changes required)
5. **Quick rollback** (< 5 minutes if needed)

---

## Task 10.1: Pre-Deployment Verification

**Objective**: Verify all prerequisites before deployment

**Time Estimate**: 15-20 minutes

### Step 1: Verify .env File Exists

**Location**: `functions/.env`

**Commands**:
```bash
# Navigate to functions directory
cd functions

# Check if .env file exists
ls -la .env

# Expected output: -rw-r--r-- 1 user user XXX bytes .env
```

**Verification Checklist**:
- [ ] File exists at `functions/.env`
- [ ] File is readable
- [ ] File has appropriate permissions (not world-readable)

**If file doesn't exist**:
```bash
# Copy from .env.example
cp .env.example .env

# Edit with real credentials
nano .env  # or code .env
```

---

### Step 2: Verify .env Contains Correct Credentials

**Commands**:
```bash
# View .env file (CAREFUL - contains secrets!)
cat .env

# Or use grep to check specific variables
grep "AGORA_APP_ID" .env
grep "AGORA_APP_CERTIFICATE" .env
```

**Expected Content**:
```bash
# Agora Configuration
AGORA_APP_ID=your_actual_app_id_here
AGORA_APP_CERTIFICATE=your_actual_certificate_here
```

**Verification Checklist**:
- [ ] `AGORA_APP_ID` is present
- [ ] `AGORA_APP_ID` is NOT a placeholder (not "your_agora_app_id_here")
- [ ] `AGORA_APP_ID` matches production Agora project
- [ ] `AGORA_APP_CERTIFICATE` is present
- [ ] `AGORA_APP_CERTIFICATE` is NOT a placeholder
- [ ] `AGORA_APP_CERTIFICATE` is 32 characters long
- [ ] No extra spaces or quotes around values

**⚠️ CRITICAL**: Verify these are the SAME credentials currently used in `firebase functions:config:get`:

```bash
# Get current production credentials
firebase functions:config:get agora

# Expected output:
# {
#   "agora": {
#     "app_id": "abc123...",
#     "app_certificate": "xyz789..."
#   }
# }

# Compare with .env file values
# They MUST match exactly!
```

**If credentials don't match**:
```bash
# Update .env with correct values
nano .env

# Verify again
cat .env
```

---

### Step 3: Verify .env is NOT Committed to Git

**Commands**:
```bash
# Check git status
git status

# Check if .env is tracked
git ls-files | grep "\.env$"

# Check .gitignore
cat .gitignore | grep "\.env"
```

**Expected Results**:
- ✅ `git status` does NOT show `.env` as modified or untracked
- ✅ `git ls-files | grep "\.env$"` returns NOTHING (file not tracked)
- ✅ `.gitignore` contains `.env` entry

**Verification Checklist**:
- [ ] `.env` is NOT in `git status` output
- [ ] `.env` is NOT tracked by git
- [ ] `.gitignore` contains `.env` entry
- [ ] `.env.example` IS tracked (should be in git)

**If .env is tracked or staged**:
```bash
# Remove from staging
git reset HEAD .env

# Add to .gitignore if not present
echo ".env" >> .gitignore
echo ".env.local" >> .gitignore
echo ".env.*.local" >> .gitignore
echo "!.env.example" >> .gitignore

# Verify .env is now ignored
git status
```

---

### Step 4: Run All Tests One Final Time

**Objective**: Ensure all tests still pass before deployment

#### 4.1: Run Cloud Functions Tests

**Commands**:
```bash
cd functions

# Run all tests
npm test

# Expected: All tests pass
```

**Expected Results**:
```
Test Suites: 6 passed, 6 total
Tests:       81 passed, 81 total
Snapshots:   0 total
Time:        XX.XXXs
```

**Verification Checklist**:
- [ ] All 81 verification tests pass
- [ ] No test failures
- [ ] No test errors
- [ ] No warnings about missing environment variables

**If tests fail**:
1. Review test output
2. Fix any issues
3. Re-run tests
4. DO NOT proceed to deployment until all tests pass

---

#### 4.2: Run Flutter Tests (Optional but Recommended)

**Commands**:
```bash
# Navigate to project root
cd ..

# Run Flutter tests
flutter test

# Expected: All 661+ tests pass
```

**Expected Results**:
```
All tests passed!
```

**Verification Checklist**:
- [ ] All Flutter tests pass
- [ ] No new test failures
- [ ] No regressions

**Note**: This is optional because the migration doesn't affect Flutter code, but it's good practice to verify.

---

### Step 5: Verify Firebase Project Configuration

**Commands**:
```bash
# Check current Firebase project
firebase use

# Expected output: Active Project: elajtech (elajtech)

# List all projects
firebase projects:list

# Verify elajtech project exists
```

**Verification Checklist**:
- [ ] Current project is `elajtech`
- [ ] Project ID matches production
- [ ] You have deployment permissions

**If wrong project**:
```bash
# Switch to elajtech project
firebase use elajtech

# Verify
firebase use
```

---

### Step 6: Pre-Deployment Checklist

Before proceeding to deployment, verify:

**Environment**:
- [ ] `.env` file exists in `functions/` directory
- [ ] `.env` contains correct production credentials
- [ ] `.env` credentials match current `functions:config:get` values
- [ ] `.env` is NOT committed to git
- [ ] `.gitignore` contains `.env` entry

**Testing**:
- [ ] All 81 Cloud Functions tests pass
- [ ] All 661+ Flutter tests pass (optional)
- [ ] No test failures or errors

**Configuration**:
- [ ] Firebase project is `elajtech`
- [ ] You have deployment permissions
- [ ] Team is notified of deployment

**Backup**:
- [ ] Current functions code is committed to git
- [ ] Rollback procedure is documented
- [ ] You know how to revert if needed

**If all checks pass**: ✅ Proceed to Task 10.2

**If any check fails**: ❌ STOP and resolve issues before proceeding

---

## Task 10.2: Deploy Functions

**Objective**: Deploy Cloud Functions to production

**Time Estimate**: 5-10 minutes

**⚠️ CRITICAL**: This step deploys to production. Ensure all pre-deployment checks passed.

### Step 1: Switch to Production Project

**Commands**:
```bash
# Ensure you're in the project root
cd /path/to/androcare360

# Switch to elajtech project
firebase use elajtech

# Verify
firebase use
```

**Expected Output**:
```
Now using alias elajtech (elajtech)
Active Project: elajtech (elajtech)
```

**Verification**:
- [ ] Current project is `elajtech`
- [ ] Project ID is correct

---

### Step 2: Deploy Cloud Functions

**Commands**:
```bash
# Deploy ONLY functions (not hosting, firestore rules, etc.)
firebase deploy --only functions

# This will:
# 1. Build functions
# 2. Upload to Firebase
# 3. Deploy to production
# 4. Show deployment progress
```

**Expected Output**:
```
=== Deploying to 'elajtech'...

i  deploying functions
i  functions: ensuring required API cloudfunctions.googleapis.com is enabled...
i  functions: ensuring required API cloudbuild.googleapis.com is enabled...
✔  functions: required API cloudfunctions.googleapis.com is enabled
✔  functions: required API cloudbuild.googleapis.com is enabled
i  functions: preparing codebase default for deployment
i  functions: packaged /path/to/functions (XX.XX KB) for uploading
✔  functions: functions folder uploaded successfully
i  functions: updating Node.js 18 function startAgoraCall(europe-west1)...
i  functions: updating Node.js 18 function endAgoraCall(europe-west1)...
i  functions: updating Node.js 18 function completeAppointment(europe-west1)...
✔  functions[startAgoraCall(europe-west1)] Successful update operation.
✔  functions[endAgoraCall(europe-west1)] Successful update operation.
✔  functions[completeAppointment(europe-west1)] Successful update operation.

✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/elajtech/overview
```

**Deployment Progress Monitoring**:
- Watch for "Successful update operation" for each function
- Note any warnings or errors
- Deployment typically takes 2-5 minutes

---

### Step 3: Monitor Deployment Logs

**During Deployment**:
```bash
# In another terminal, monitor logs in real-time
firebase functions:log --only startAgoraCall

# Watch for:
# - Function initialization
# - Configuration loading
# - Any errors or warnings
```

**What to Look For**:
- ✅ Functions initialize successfully
- ✅ No "credentials not configured" errors
- ✅ No "missing environment variables" errors
- ✅ No deployment failures

**If you see errors**:
1. Note the error message
2. Check if deployment completed
3. Proceed to verification step
4. If critical, prepare for rollback

---

### Step 4: Verify Deployment Completes Successfully

**Commands**:
```bash
# Check deployment status
firebase deploy --only functions

# If already deployed, it will show:
# "Functions are up to date"
```

**Verification Checklist**:
- [ ] Deployment completed without errors
- [ ] All 3 functions deployed successfully
- [ ] No warnings about configuration
- [ ] Deployment logs show success

**Expected Deployment Summary**:
```
✔  functions[startAgoraCall(europe-west1)] Successful update operation.
✔  functions[endAgoraCall(europe-west1)] Successful update operation.
✔  functions[completeAppointment(europe-west1)] Successful update operation.

✔  Deploy complete!
```

---

### Step 5: Deployment Checklist

After deployment, verify:

**Deployment Status**:
- [ ] `firebase deploy --only functions` completed successfully
- [ ] All 3 functions deployed
- [ ] No deployment errors
- [ ] No configuration warnings

**Function Status**:
- [ ] startAgoraCall deployed to europe-west1
- [ ] endAgoraCall deployed to europe-west1
- [ ] completeAppointment deployed to europe-west1

**Logs**:
- [ ] No errors in deployment logs
- [ ] No "credentials not configured" errors
- [ ] Functions initialized successfully

**If all checks pass**: ✅ Proceed to Task 10.3

**If any check fails**: ❌ Review errors and consider rollback

---

## Task 10.3: Verify Deployment

**Objective**: Verify functions are working correctly in production

**Time Estimate**: 10-15 minutes

### Step 1: Check Firebase Console for Function Status

**Instructions**:
1. Open Firebase Console: https://console.firebase.google.com/project/elajtech/functions
2. Navigate to Functions section
3. Verify all 3 functions are listed and active

**Expected View**:
```
Functions List:
┌─────────────────────┬──────────────┬────────┬─────────────┐
│ Name                │ Region       │ Status │ Last Deploy │
├─────────────────────┼──────────────┼────────┼─────────────┤
│ startAgoraCall      │ europe-west1 │ Active │ Just now    │
│ endAgoraCall        │ europe-west1 │ Active │ Just now    │
│ completeAppointment │ europe-west1 │ Active │ Just now    │
└─────────────────────┴──────────────┴────────┴─────────────┘
```

**Verification Checklist**:
- [ ] All 3 functions are listed
- [ ] All functions show "Active" status
- [ ] All functions deployed to europe-west1
- [ ] Deployment timestamp is recent (within last 10 minutes)
- [ ] No error indicators

**If functions show errors**:
1. Click on function name to view details
2. Check error message
3. Review logs
4. Consider rollback if critical

---

### Step 2: Verify All 3 Functions Deployed

**Commands**:
```bash
# List deployed functions
firebase functions:list

# Expected output:
# ┌─────────────────────┬──────────────┬─────────┐
# │ Function            │ Region       │ Runtime │
# ├─────────────────────┼──────────────┼─────────┤
# │ startAgoraCall      │ europe-west1 │ nodejs18│
# │ endAgoraCall        │ europe-west1 │ nodejs18│
# │ completeAppointment │ europe-west1 │ nodejs18│
# └─────────────────────┴──────────────┴─────────┘
```

**Verification Checklist**:
- [ ] startAgoraCall is listed
- [ ] endAgoraCall is listed
- [ ] completeAppointment is listed
- [ ] All functions in europe-west1 region
- [ ] All functions using Node.js 18 runtime

---

### Step 3: Check Function Logs

**Commands**:
```bash
# Check startAgoraCall logs
firebase functions:log --only startAgoraCall --limit 50

# Check endAgoraCall logs
firebase functions:log --only endAgoraCall --limit 50

# Check completeAppointment logs
firebase functions:log --only completeAppointment --limit 50
```

**What to Look For**:

**✅ Good Signs**:
- Function initialization messages
- No error messages
- No "credentials not configured" errors
- No "missing environment variables" errors

**❌ Bad Signs**:
- "Agora credentials not configured" errors
- "Missing environment variables" errors
- Function execution failures
- Timeout errors

**Example Good Log**:
```
2026-02-14T10:30:00.000Z - Function execution started
2026-02-14T10:30:00.100Z - Function execution took 100 ms, finished with status code: 200
```

**Example Bad Log**:
```
2026-02-14T10:30:00.000Z - Error: [DB: elajtech] Agora credentials not configured. Missing environment variables: AGORA_APP_ID
```

---

### Step 4: Verify No Configuration Errors

**Objective**: Ensure environment variables are loaded correctly

**Commands**:
```bash
# Check recent logs for configuration errors
firebase functions:log --limit 100 | grep -i "error\|missing\|not configured"

# If no output, configuration is correct
# If output shows errors, investigate
```

**Verification Checklist**:
- [ ] No "credentials not configured" errors
- [ ] No "missing environment variables" errors
- [ ] No "AGORA_APP_ID" missing errors
- [ ] No "AGORA_APP_CERTIFICATE" missing errors
- [ ] Functions execute successfully

**Common Configuration Errors**:

**Error 1**: "Missing environment variables: AGORA_APP_ID"
- **Cause**: .env file not deployed or not loaded
- **Solution**: Verify .env file exists in functions/ directory
- **Action**: Redeploy with correct .env file

**Error 2**: "Agora credentials not configured"
- **Cause**: Environment variables empty or undefined
- **Solution**: Check .env file contents
- **Action**: Update .env and redeploy

**Error 3**: "Invalid token"
- **Cause**: Wrong credentials in .env file
- **Solution**: Verify credentials match production
- **Action**: Update .env with correct credentials and redeploy

---

### Step 5: Test Function Execution (Optional but Recommended)

**Objective**: Verify functions work correctly with real requests

**⚠️ CAUTION**: This will trigger real function executions in production

**Option 1: Monitor Existing Traffic**

Wait for natural traffic and monitor logs:
```bash
# Watch logs in real-time
firebase functions:log --only startAgoraCall

# Wait for a doctor to initiate a video call
# Verify function executes successfully
```

**Option 2: Test with Firebase Console**

1. Open Firebase Console
2. Navigate to Functions
3. Click on `startAgoraCall`
4. Click "Test function" (if available)
5. Provide test data
6. Verify execution succeeds

**Option 3: Test with Flutter App (Recommended)**

1. Open Flutter app in debug mode
2. Sign in as a doctor
3. Navigate to an appointment
4. Click "Start Video Call"
5. Monitor function logs
6. Verify call initiates successfully

**What to Verify**:
- [ ] Function executes without errors
- [ ] Agora token generated successfully
- [ ] No configuration errors in logs
- [ ] Video call initiates correctly
- [ ] Patient receives notification

---

### Step 6: Deployment Verification Checklist

After deployment, verify:

**Firebase Console**:
- [ ] All 3 functions listed and active
- [ ] Functions deployed to europe-west1
- [ ] No error indicators
- [ ] Deployment timestamp recent

**Function Logs**:
- [ ] No configuration errors
- [ ] No "credentials not configured" errors
- [ ] No "missing environment variables" errors
- [ ] Functions execute successfully

**Function Execution** (if tested):
- [ ] startAgoraCall generates tokens successfully
- [ ] endAgoraCall updates appointments correctly
- [ ] completeAppointment marks appointments as completed
- [ ] No errors in execution logs

**If all checks pass**: ✅ Task 10 COMPLETE

**If any check fails**: ❌ Investigate and consider rollback

---

## Rollback Procedure

If deployment fails or critical errors are detected, follow this rollback procedure:

### Quick Rollback (< 5 minutes)

**Step 1: Revert Code Changes**
```bash
# Find the commit before migration
git log --oneline | head -10

# Revert to previous commit
git checkout <previous-commit-hash>

# Or revert specific files
git checkout HEAD~1 functions/index.js
```

**Step 2: Redeploy Previous Version**
```bash
# Deploy previous version
firebase deploy --only functions

# Monitor deployment
firebase functions:log --only startAgoraCall
```

**Step 3: Verify Rollback**
```bash
# Check function logs
firebase functions:log --limit 50

# Verify no errors
# Verify functions work correctly
```

**Step 4: Restore functions.config() (if needed)**
```bash
# Verify current config
firebase functions:config:get agora

# If config is missing, restore it
firebase functions:config:set agora.app_id="YOUR_APP_ID"
firebase functions:config:set agora.app_certificate="YOUR_CERTIFICATE"

# Redeploy
firebase deploy --only functions
```

---

## Post-Deployment Actions

After successful deployment:

### 1. Update Task Status
```bash
# Mark Task 10 as complete in tasks.md
# Update status to [x] for all subtasks
```

### 2. Notify Team
- Inform team that deployment is complete
- Share deployment summary
- Provide monitoring instructions

### 3. Monitor for 1 Hour
- Watch function logs for errors
- Monitor video call success rate
- Check for any user reports

### 4. Document Deployment
- Record deployment time
- Note any issues encountered
- Document resolution steps

### 5. Proceed to Task 11
- Begin monitoring production deployment
- Track metrics and logs
- Verify database isolation

---

## Troubleshooting Guide

### Issue 1: Deployment Fails

**Symptoms**:
- `firebase deploy` command fails
- Error message about permissions or configuration

**Solutions**:
1. Verify Firebase project: `firebase use`
2. Check deployment permissions
3. Verify .env file exists
4. Check for syntax errors in functions/index.js
5. Review deployment logs

---

### Issue 2: Functions Show "Inactive" Status

**Symptoms**:
- Functions listed but show "Inactive" status in console
- Functions don't respond to requests

**Solutions**:
1. Check function logs for errors
2. Verify environment variables loaded
3. Redeploy functions
4. Check Firebase billing status

---

### Issue 3: Configuration Errors in Logs

**Symptoms**:
- "Credentials not configured" errors
- "Missing environment variables" errors

**Solutions**:
1. Verify .env file exists in functions/ directory
2. Check .env file contents
3. Verify credentials are correct
4. Redeploy functions
5. If persistent, rollback and investigate

---

### Issue 4: Token Generation Fails

**Symptoms**:
- "Invalid token" errors
- Video calls fail to start
- Agora connection errors

**Solutions**:
1. Verify AGORA_APP_ID is correct
2. Verify AGORA_APP_CERTIFICATE is correct
3. Check credentials match Agora console
4. Verify token generation algorithm unchanged
5. Review Task 9 verification results

---

## Success Criteria

Task 10 is complete when:

**Deployment**:
- ✅ All 3 functions deployed successfully
- ✅ No deployment errors
- ✅ Functions active in Firebase Console

**Configuration**:
- ✅ No configuration errors in logs
- ✅ Environment variables loaded correctly
- ✅ Credentials working correctly

**Functionality**:
- ✅ Functions execute successfully
- ✅ Tokens generated correctly
- ✅ Video calls work correctly
- ✅ No user-facing issues

**Verification**:
- ✅ All verification checks passed
- ✅ Logs show no errors
- ✅ Team notified

---

## Time Estimates

- **Task 10.1**: 15-20 minutes (pre-deployment verification)
- **Task 10.2**: 5-10 minutes (deployment)
- **Task 10.3**: 10-15 minutes (verification)

**Total**: 30-45 minutes

---

## Next Steps

After Task 10 completion:

1. ✅ Mark Task 10 as complete
2. ⏭️ Proceed to Task 11 (Monitor production deployment)
3. 📊 Begin 1-hour monitoring period
4. 📝 Document any issues or observations

---

**Plan Created**: 2026-02-14  
**Ready for Execution**: ✅ YES  
**Risk Level**: LOW (zero breaking changes verified)  
**Rollback Time**: < 5 minutes  
**Estimated Duration**: 30-45 minutes

---

## Important Notes

⚠️ **Before Deployment**:
- Verify all pre-deployment checks pass
- Ensure .env file contains correct credentials
- Confirm team is notified
- Have rollback procedure ready

✅ **During Deployment**:
- Monitor deployment logs
- Watch for errors
- Note deployment time
- Verify successful completion

📊 **After Deployment**:
- Verify functions active
- Check logs for errors
- Test function execution
- Monitor for 1 hour
- Proceed to Task 11

🔄 **If Issues Occur**:
- Follow troubleshooting guide
- Consider rollback if critical
- Document issues and resolution
- Notify team

---

**This deployment is LOW RISK because**:
- Zero breaking changes (verified in Task 9)
- Only configuration source changed
- Same credentials, different source
- Backward compatible
- Quick rollback available
