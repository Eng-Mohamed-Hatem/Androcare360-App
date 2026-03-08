# Task 11 Monitoring Plan: Monitor Production Deployment

**Date**: 2026-02-14  
**Spec**: Agora Environment Migration  
**Task**: Task 11 - Monitor production deployment  
**Status**: Ready for Execution

---

## Overview

Task 11 monitors the production deployment for 1 hour after deployment to ensure:
- Functions execute successfully
- Token generation works correctly
- Video calls initiate properly
- Database isolation is maintained

**Monitoring Period**: 1 hour after deployment  
**Start Time**: 2026-02-14 23:44:35 (deployment verification complete)  
**End Time**: 2026-02-15 00:44:35

---

## Monitoring Objectives

### Primary Objectives
1. ✅ Verify functions execute without errors
2. ✅ Verify token generation works correctly
3. ✅ Verify video calls initiate successfully
4. ✅ Verify database isolation maintained

### Success Criteria
- ✅ No configuration errors in logs
- ✅ No "credentials not configured" errors
- ✅ No "missing environment variables" errors
- ✅ All function invocations successful
- ✅ All logs written to elajtech database
- ✅ Error messages include database context

---

## Task 11.1: Monitor Function Execution

**Objective**: Verify functions execute successfully in production

**Duration**: 1 hour  
**Priority**: HIGH

### Monitoring Steps

#### Step 1: Check Firebase Console for Function Invocations

**Instructions**:
1. Open Firebase Console: https://console.firebase.google.com/project/elajtech-fc804/functions
2. Navigate to Functions section
3. Click on each function to view metrics

**What to Monitor**:
- **Invocation Count**: Number of times function was called
- **Error Rate**: Percentage of failed invocations
- **Execution Time**: Average execution duration
- **Memory Usage**: Average memory consumption

**Expected Metrics**:
```
startAgoraCall:
- Invocations: 0+ (depends on user activity)
- Error Rate: 0%
- Execution Time: < 5 seconds
- Memory Usage: < 128 MB

endAgoraCall:
- Invocations: 0+ (depends on user activity)
- Error Rate: 0%
- Execution Time: < 2 seconds
- Memory Usage: < 64 MB

completeAppointment:
- Invocations: 0+ (depends on user activity)
- Error Rate: 0%
- Execution Time: < 2 seconds
- Memory Usage: < 64 MB
```

**Verification Checklist**:
- [ ] All functions show 0% error rate
- [ ] No timeout errors
- [ ] Execution times within expected range
- [ ] Memory usage within limits

---

#### Step 2: Monitor Function Logs in Real-Time

**Commands**:
```bash
# Monitor all function logs in real-time
firebase functions:log

# Or monitor specific function
firebase functions:log --only startAgoraCall

# Filter for errors only
firebase functions:log | grep -i "error"

# Filter for configuration errors
firebase functions:log | grep -i "credentials\|missing\|not configured"
```

**What to Look For**:

**✅ Good Signs**:
- Function execution started/completed messages
- Successful token generation
- No error messages
- Normal execution flow

**❌ Bad Signs**:
- "Agora credentials not configured" errors
- "Missing environment variables" errors
- Function execution failures
- Timeout errors
- Memory limit exceeded errors

**Monitoring Schedule**:
- **0-15 minutes**: Check every 5 minutes
- **15-30 minutes**: Check every 10 minutes
- **30-60 minutes**: Check every 15 minutes

**Verification Checklist**:
- [ ] No configuration errors in logs
- [ ] No "credentials not configured" errors
- [ ] No "missing environment variables" errors
- [ ] Functions execute successfully
- [ ] No timeout errors

---

#### Step 3: Verify Functions Execute Successfully

**Test Scenarios**:

**Scenario 1: Natural Traffic** (Preferred)
- Wait for real users to initiate video calls
- Monitor logs for successful execution
- Verify no errors occur

**Scenario 2: Manual Test** (If no natural traffic)
- Use Flutter app to initiate test video call
- Monitor function execution
- Verify successful completion

**Verification Checklist**:
- [ ] At least 1 successful function invocation (if traffic exists)
- [ ] No errors during execution
- [ ] Functions complete within expected time
- [ ] Correct response returned

---

#### Step 4: Monitor for Configuration Errors

**Commands**:
```bash
# Check for configuration errors every 15 minutes
firebase functions:log --limit 100 | grep -i "error\|missing\|not configured"

# Check for specific error patterns
firebase functions:log --limit 100 | grep -i "AGORA_APP_ID\|AGORA_APP_CERTIFICATE"

# Check for database errors
firebase functions:log --limit 100 | grep -i "database\|firestore\|elajtech"
```

**Error Patterns to Watch For**:

**Configuration Errors**:
```
❌ [DB: elajtech] Agora credentials not configured
❌ Missing environment variables: AGORA_APP_ID
❌ Missing environment variables: AGORA_APP_CERTIFICATE
❌ Cannot read properties of undefined (reading 'app_id')
```

**Database Errors**:
```
❌ Database not found: elajtech
❌ Collection not found
❌ Permission denied
```

**Verification Checklist**:
- [ ] No configuration errors detected
- [ ] No environment variable errors
- [ ] No database errors
- [ ] All errors (if any) are expected/handled

---

### Task 11.1 Success Criteria

Task 11.1 is complete when:
- ✅ Functions execute without configuration errors
- ✅ No "credentials not configured" errors
- ✅ No "missing environment variables" errors
- ✅ Error rate is 0% (or within acceptable limits)
- ✅ Execution times within expected range

---

## Task 11.2: Monitor Token Generation

**Objective**: Verify Agora tokens are generated successfully

**Duration**: 1 hour  
**Priority**: HIGH

### Monitoring Steps

#### Step 1: Check Function Logs for Token Generation

**Commands**:
```bash
# Monitor startAgoraCall logs specifically
firebase functions:log --only startAgoraCall

# Check recent token generation attempts
firebase functions:log --only startAgoraCall --limit 50

# Filter for token-related messages
firebase functions:log --only startAgoraCall | grep -i "token\|agora"
```

**What to Look For**:

**✅ Successful Token Generation**:
```
Function execution started
Generating Agora token for channel: channel_apt_123_1234567890
Token generated successfully
Function execution completed
```

**❌ Failed Token Generation**:
```
Error generating Agora token
Agora credentials not configured
Missing environment variables: AGORA_APP_ID
Invalid token parameters
```

**Verification Checklist**:
- [ ] Token generation attempts logged
- [ ] No "credentials not configured" errors
- [ ] No "missing environment variables" errors
- [ ] Tokens generated successfully
- [ ] No token validation errors

---

#### Step 2: Verify No "Credentials Not Configured" Errors

**Commands**:
```bash
# Check for credential errors
firebase functions:log --limit 200 | grep -i "credentials not configured"

# Check for missing variable errors
firebase functions:log --limit 200 | grep -i "missing environment variables"

# Check for AGORA-specific errors
firebase functions:log --limit 200 | grep -i "AGORA_APP_ID\|AGORA_APP_CERTIFICATE"
```

**Expected Result**: No output (no errors)

**If Errors Found**:
1. Note the error message
2. Check .env file exists: `ls -la functions/.env`
3. Verify .env contents: `cat functions/.env`
4. Consider redeployment if critical

**Verification Checklist**:
- [ ] No "credentials not configured" errors
- [ ] No "missing environment variables" errors
- [ ] No AGORA_APP_ID errors
- [ ] No AGORA_APP_CERTIFICATE errors

---

#### Step 3: Verify Tokens Generated Successfully

**Test Methods**:

**Method 1: Monitor Natural Traffic**
- Wait for real video call attempts
- Check logs for successful token generation
- Verify tokens are valid (no "invalid token" errors from Agora)

**Method 2: Manual Test** (If no natural traffic)
- Use Flutter app to initiate test video call
- Monitor startAgoraCall logs
- Verify token generated and returned
- Verify video call connects successfully

**Verification Checklist**:
- [ ] At least 1 successful token generation (if traffic exists)
- [ ] Token format is correct (JWT string)
- [ ] Token includes all required fields
- [ ] No "invalid token" errors from Agora
- [ ] Video calls connect successfully

---

#### Step 4: Compare Token Generation with Pre-Migration

**Objective**: Verify tokens are identical to pre-migration

**Verification**:
- Token format unchanged (JWT string)
- Token length unchanged (~200-300 characters)
- Token structure unchanged (header.payload.signature)
- Token expiration unchanged (1 hour)

**Note**: We verified this in Task 9, but monitor for any unexpected changes

**Verification Checklist**:
- [ ] Token format matches pre-migration
- [ ] Token length within expected range
- [ ] Token structure correct
- [ ] Token expiration correct (1 hour)

---

### Task 11.2 Success Criteria

Task 11.2 is complete when:
- ✅ Tokens generated successfully
- ✅ No "credentials not configured" errors
- ✅ No "missing environment variables" errors
- ✅ Token format matches pre-migration
- ✅ Video calls connect successfully (if tested)

---

## Task 11.3: Monitor Video Call Initiation

**Objective**: Verify video calls initiate successfully

**Duration**: 1 hour  
**Priority**: HIGH

### Monitoring Steps

#### Step 1: Check call_logs Collection for call_attempt Events

**Firestore Query**:
```javascript
// In Firebase Console > Firestore > elajtech database
db.collection('call_logs')
  .where('eventType', '==', 'call_attempt')
  .where('timestamp', '>=', deploymentTime)
  .orderBy('timestamp', 'desc')
  .limit(50)
```

**What to Look For**:
- **call_attempt** events logged
- **appointmentId** present
- **userId** present (doctor ID)
- **deviceInfo** present
- **timestamp** recent (within monitoring period)

**Expected Document Structure**:
```javascript
{
  id: "uuid",
  appointmentId: "apt_123",
  userId: "doctor_456",
  eventType: "call_attempt",
  timestamp: Timestamp,
  deviceInfo: {
    platform: "android",
    deviceModel: "Samsung Galaxy S21",
    osVersion: "Android 13",
    // ...
  },
  metadata: {
    databaseId: "elajtech"
  }
}
```

**Verification Checklist**:
- [ ] call_attempt events logged
- [ ] All required fields present
- [ ] Timestamps within monitoring period
- [ ] Device info collected correctly
- [ ] Metadata includes databaseId: 'elajtech'

---

#### Step 2: Verify call_started Events Logged

**Firestore Query**:
```javascript
// In Firebase Console > Firestore > elajtech database
db.collection('call_logs')
  .where('eventType', '==', 'call_started')
  .where('timestamp', '>=', deploymentTime)
  .orderBy('timestamp', 'desc')
  .limit(50)
```

**What to Look For**:
- **call_started** events logged
- **appointmentId** matches call_attempt
- **userId** present
- **channelName** present
- **agoraUid** present

**Expected Document Structure**:
```javascript
{
  id: "uuid",
  appointmentId: "apt_123",
  userId: "doctor_456",
  eventType: "call_started",
  timestamp: Timestamp,
  metadata: {
    channelName: "channel_apt_123_1234567890",
    agoraUid: 12345,
    databaseId: "elajtech"
  }
}
```

**Verification Checklist**:
- [ ] call_started events logged
- [ ] Events match call_attempt events
- [ ] Channel names present
- [ ] Agora UIDs present
- [ ] Metadata includes databaseId: 'elajtech'

---

#### Step 3: Monitor for call_error Events

**Firestore Query**:
```javascript
// In Firebase Console > Firestore > elajtech database
db.collection('call_logs')
  .where('eventType', '==', 'call_error')
  .where('timestamp', '>=', deploymentTime)
  .orderBy('timestamp', 'desc')
  .limit(50)
```

**What to Look For**:

**✅ No Errors** (Expected):
- Query returns 0 documents
- No call_error events logged

**❌ Errors Found** (Investigate):
- call_error events present
- Error messages indicate configuration issues
- Error messages indicate token generation failures

**Error Document Structure**:
```javascript
{
  id: "uuid",
  appointmentId: "apt_123",
  userId: "doctor_456",
  eventType: "call_error",
  timestamp: Timestamp,
  errorCode: "configuration_error",
  errorMessage: "Agora credentials not configured",
  stackTrace: "...",
  deviceInfo: { ... },
  metadata: {
    databaseId: "elajtech"
  }
}
```

**Verification Checklist**:
- [ ] No call_error events (or within acceptable limits)
- [ ] No configuration errors
- [ ] No token generation errors
- [ ] All errors (if any) are expected/handled

---

#### Step 4: Verify Video Call Flow End-to-End

**Complete Flow**:
1. **call_attempt** logged (doctor initiates call)
2. **call_started** logged (doctor joins channel)
3. **call_started** logged (patient joins channel)
4. **call_ended** logged (call terminates)

**Verification**:
- [ ] Complete flow logged for at least 1 call (if traffic exists)
- [ ] All events have matching appointmentId
- [ ] Timestamps are sequential
- [ ] No errors between events

---

### Task 11.3 Success Criteria

Task 11.3 is complete when:
- ✅ call_attempt events logged correctly
- ✅ call_started events logged correctly
- ✅ No call_error events (or within acceptable limits)
- ✅ Complete video call flow verified (if traffic exists)
- ✅ All events include database context

---

## Task 11.4: Verify Database Isolation

**Objective**: Verify all logs written to elajtech database

**Duration**: 1 hour  
**Priority**: HIGH

### Monitoring Steps

#### Step 1: Check call_logs Collection in elajtech Database

**Firebase Console**:
1. Open Firebase Console: https://console.firebase.google.com/project/elajtech-fc804/firestore
2. Select database: **elajtech** (NOT default)
3. Navigate to **call_logs** collection
4. Verify documents exist

**Verification**:
- [ ] elajtech database selected
- [ ] call_logs collection exists
- [ ] Documents present (if traffic exists)
- [ ] Documents have recent timestamps

**⚠️ CRITICAL**: Ensure you're viewing the **elajtech** database, NOT the default database

---

#### Step 2: Verify All Logs Written to Correct Database

**Query Recent Logs**:
```javascript
// In Firebase Console > Firestore > elajtech database
db.collection('call_logs')
  .where('timestamp', '>=', deploymentTime)
  .orderBy('timestamp', 'desc')
  .limit(100)
```

**What to Verify**:
- All logs have `metadata.databaseId: 'elajtech'`
- All logs are in elajtech database (not default)
- No logs missing database context

**Verification Checklist**:
- [ ] All logs in elajtech database
- [ ] All logs have metadata.databaseId field
- [ ] metadata.databaseId value is 'elajtech'
- [ ] No logs in default database

---

#### Step 3: Verify Error Messages Include Database Context

**Check Error Logs**:
```bash
# Check function logs for error messages
firebase functions:log --limit 200 | grep -i "error"

# Check for database context in errors
firebase functions:log --limit 200 | grep -i "\[DB: elajtech\]"
```

**Expected Error Format**:
```
[DB: elajtech] Error message here
[DB: elajtech] Agora credentials not configured
[DB: elajtech] Appointment not found in database elajtech
```

**Verification Checklist**:
- [ ] All error messages include `[DB: elajtech]` prefix
- [ ] Error messages reference correct database
- [ ] No errors reference default database
- [ ] Database context consistent across all errors

---

#### Step 4: Verify Appointment Queries Target elajtech

**Check Appointment Operations**:

**Firestore Console**:
1. Navigate to elajtech database
2. Check appointments collection
3. Verify recent updates (if traffic exists)

**Function Logs**:
```bash
# Check for appointment-related operations
firebase functions:log --only startAgoraCall | grep -i "appointment"

# Check for database references
firebase functions:log | grep -i "elajtech\|database"
```

**Verification Checklist**:
- [ ] Appointment queries use elajtech database
- [ ] Appointment updates logged correctly
- [ ] No references to default database
- [ ] All operations include database context

---

#### Step 5: Verify User Queries Target elajtech

**Check User Operations**:

**Firestore Console**:
1. Navigate to elajtech database
2. Check users collection
3. Verify FCM token retrieval (if traffic exists)

**Function Logs**:
```bash
# Check for user-related operations
firebase functions:log --only startAgoraCall | grep -i "user\|patient"

# Check for FCM token retrieval
firebase functions:log | grep -i "fcm\|token"
```

**Verification Checklist**:
- [ ] User queries use elajtech database
- [ ] FCM token retrieval works correctly
- [ ] No references to default database
- [ ] All operations include database context

---

### Task 11.4 Success Criteria

Task 11.4 is complete when:
- ✅ All logs written to elajtech database
- ✅ All logs include metadata.databaseId: 'elajtech'
- ✅ All error messages include `[DB: elajtech]` prefix
- ✅ Appointment queries target elajtech
- ✅ User queries target elajtech
- ✅ No operations reference default database

---

## Monitoring Schedule

### Hour 1: Intensive Monitoring

**0-15 minutes** (High Frequency):
- Check function logs every 5 minutes
- Monitor Firebase Console metrics
- Check for configuration errors
- Verify token generation

**15-30 minutes** (Medium Frequency):
- Check function logs every 10 minutes
- Monitor call_logs collection
- Verify database isolation
- Check for errors

**30-45 minutes** (Medium Frequency):
- Check function logs every 10 minutes
- Monitor video call flow
- Verify complete end-to-end flow
- Check for errors

**45-60 minutes** (Low Frequency):
- Check function logs every 15 minutes
- Final verification of all metrics
- Document any observations
- Prepare final report

---

## Monitoring Commands Reference

### Quick Commands

```bash
# Monitor all logs in real-time
firebase functions:log

# Monitor specific function
firebase functions:log --only startAgoraCall

# Check for errors
firebase functions:log --limit 200 | grep -i "error"

# Check for configuration errors
firebase functions:log --limit 200 | grep -i "credentials\|missing\|not configured"

# Check for database context
firebase functions:log --limit 200 | grep -i "\[DB: elajtech\]"

# Check recent logs
firebase functions:log --limit 50

# Check function list
firebase functions:list
```

### Firestore Queries

```javascript
// call_attempt events
db.collection('call_logs')
  .where('eventType', '==', 'call_attempt')
  .where('timestamp', '>=', deploymentTime)
  .orderBy('timestamp', 'desc')
  .limit(50)

// call_started events
db.collection('call_logs')
  .where('eventType', '==', 'call_started')
  .where('timestamp', '>=', deploymentTime)
  .orderBy('timestamp', 'desc')
  .limit(50)

// call_error events
db.collection('call_logs')
  .where('eventType', '==', 'call_error')
  .where('timestamp', '>=', deploymentTime)
  .orderBy('timestamp', 'desc')
  .limit(50)

// All recent logs
db.collection('call_logs')
  .where('timestamp', '>=', deploymentTime)
  .orderBy('timestamp', 'desc')
  .limit(100)
```

---

## Issue Response Plan

### Issue 1: Configuration Errors Detected

**Symptoms**:
- "Credentials not configured" errors in logs
- "Missing environment variables" errors

**Response**:
1. Verify .env file exists: `ls -la functions/.env`
2. Check .env contents: `cat functions/.env`
3. Verify credentials are correct
4. Redeploy if needed: `firebase deploy --only functions`
5. Monitor for 15 minutes after redeployment

---

### Issue 2: Token Generation Failures

**Symptoms**:
- Token generation errors in logs
- "Invalid token" errors from Agora
- Video calls fail to connect

**Response**:
1. Check function logs for error details
2. Verify AGORA_APP_ID is correct
3. Verify AGORA_APP_CERTIFICATE is correct
4. Compare with Agora console credentials
5. Redeploy if credentials incorrect

---

### Issue 3: Database Isolation Issues

**Symptoms**:
- Logs written to default database
- Missing database context in errors
- Appointment/user queries fail

**Response**:
1. Check functions/index.js for database configuration
2. Verify `db.settings({ databaseId: 'elajtech' })` is present
3. Check all `db.collection()` calls use configured `db` instance
4. Redeploy if configuration incorrect

---

### Issue 4: High Error Rate

**Symptoms**:
- Error rate > 5%
- Multiple call_error events
- User reports of failures

**Response**:
1. Identify error pattern from logs
2. Check if errors are configuration-related
3. Check if errors are Agora-related
4. Consider rollback if critical
5. Document errors for investigation

---

## Success Criteria

Task 11 is complete when:

**Function Execution**:
- ✅ Functions execute without configuration errors
- ✅ Error rate is 0% (or < 5% for non-critical errors)
- ✅ Execution times within expected range

**Token Generation**:
- ✅ Tokens generated successfully
- ✅ No "credentials not configured" errors
- ✅ Token format matches pre-migration

**Video Call Initiation**:
- ✅ call_attempt events logged correctly
- ✅ call_started events logged correctly
- ✅ No critical call_error events

**Database Isolation**:
- ✅ All logs written to elajtech database
- ✅ All error messages include database context
- ✅ No operations reference default database

**Overall**:
- ✅ 1 hour monitoring period completed
- ✅ No critical issues detected
- ✅ All verification checks passed
- ✅ Documentation complete

---

## Documentation Requirements

### During Monitoring

Create monitoring log file: `TASK_11_MONITORING_LOG.md`

**Log Format**:
```markdown
# Task 11 Monitoring Log

**Start Time**: 2026-02-14 23:44:35
**End Time**: 2026-02-15 00:44:35

## Monitoring Timeline

### 23:44 - 23:59 (0-15 minutes)
- [23:45] Checked function logs - No errors
- [23:50] Checked Firebase Console - 0 invocations
- [23:55] Checked call_logs collection - No new logs

### 00:00 - 00:14 (15-30 minutes)
- [00:00] Checked function logs - No errors
- [00:10] Checked Firebase Console - 0 invocations

### 00:15 - 00:29 (30-45 minutes)
- [00:15] Checked function logs - No errors
- [00:25] Checked call_logs collection - No new logs

### 00:30 - 00:44 (45-60 minutes)
- [00:30] Checked function logs - No errors
- [00:40] Final verification - All checks passed

## Issues Detected
- None

## Observations
- No user traffic during monitoring period
- All functions healthy
- No configuration errors

## Conclusion
✅ Monitoring complete - No issues detected
```

---

### After Monitoring

Create final report: `TASK_11_MONITORING_REPORT.md`

**Report Sections**:
1. Executive Summary
2. Monitoring Results by Task
3. Issues Detected (if any)
4. Observations
5. Recommendations
6. Conclusion

---

## Time Estimate

- **Setup**: 5 minutes
- **Active Monitoring**: 1 hour
- **Documentation**: 15 minutes

**Total**: ~1 hour 20 minutes

---

## Next Steps After Task 11

1. ✅ Complete monitoring period (1 hour)
2. ✅ Document observations
3. ✅ Create monitoring report
4. ✅ Mark Task 11 as complete
5. ⏭️ Proceed to Task 12 (Final verification checkpoint)

---

## Important Notes

### If No User Traffic

**Expected Scenario**: No video calls during monitoring period

**What to Do**:
- Continue monitoring for full hour
- Check logs every 15 minutes
- Verify no configuration errors
- Document "no traffic" observation
- Mark monitoring as complete

**Note**: Lack of traffic is NOT a failure. The migration is successful if:
- No configuration errors detected
- Functions are healthy and ready
- All verification checks passed

---

### If User Traffic Exists

**Expected Scenario**: Users initiate video calls during monitoring

**What to Do**:
- Monitor each call closely
- Verify token generation successful
- Verify call_logs events logged
- Verify database isolation maintained
- Document successful calls

**Note**: Even 1 successful call is sufficient to verify the migration works correctly.

---

**Plan Created**: 2026-02-14  
**Ready for Execution**: ✅ YES  
**Duration**: 1 hour monitoring + 20 minutes setup/documentation  
**Risk Level**: LOW (monitoring only, no code changes)

