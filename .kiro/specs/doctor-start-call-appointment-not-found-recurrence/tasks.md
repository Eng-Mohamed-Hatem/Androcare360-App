# Implementation Plan: Doctor Start Call "Appointment Not Found" Recurrence Bugfix

## Overview

This task list implements a systematic diagnostic-first approach to fix the recurring "Appointment Not Found" error when doctors attempt to initiate video calls. The workflow follows the bug condition methodology:

1. **Diagnostic Phase** - Identify the root cause through comprehensive logging and testing
2. **Exploration Phase** - Write tests BEFORE fix to understand the bug (Fault Condition)
3. **Preservation Phase** - Write tests for non-buggy behavior (Preservation Requirements)
4. **Implementation Phase** - Apply fixes based on diagnostic results
5. **Validation Phase** - Verify fix works and doesn't break anything

---

## Phase 1: Diagnostic Implementation

### Task 1: Implement Diagnostic Infrastructure

- [x] 1.1 Add version tracking to Cloud Functions
  - Add `FUNCTIONS_VERSION` constant at top of `functions/index.js`
  - Add `DEPLOYED_AT` timestamp constant
  - Add `DATABASE_CONFIG_FIX_PRESENT` flag
  - Add initialization logging for version and database config
  - _Requirements: Investigation 1_

- [x] 1.2 Create getFunctionsVersion endpoint
  - Implement `getFunctionsVersion` Cloud Function in `functions/index.js`
  - Return version, deployedAt, databaseId, hasDatabaseConfigFix, timestamp
  - Deploy to europe-west1 region
  - _Requirements: Investigation 1_

- [x] 1.3 Add Flutter version verification service
  - Create `verifyCloudFunctionsVersion()` function in Flutter app
  - Call `getFunctionsVersion` endpoint on app startup
  - Log version information to debug console
  - Add warning if databaseId is not 'elajtech'
  - _Requirements: Investigation 1_

- [x] 1.4 Implement AppointmentId tracing in Flutter
  - Add logging in `doctor_appointments_screen.dart` before `startVideoCall`
  - Query Firestore to get actual document ID
  - Log both `widget.appointment.id` and `firestoreDoc.id`
  - Log comparison result and flag mismatches
  - _Requirements: Investigation 2_

- [x] 1.5 Implement AppointmentId tracing in Cloud Functions
  - Add comprehensive logging in `startAgoraCall` function
  - Log received appointmentId, type, and length
  - Log document path being queried
  - Log document exists status and actual document ID
  - If not found, query all doctor appointments and log IDs for comparison
  - _Requirements: Investigation 2_

- [x] 1.6 Add database configuration verification logging
  - Log initial `db._settings` state before configuration
  - Log initial databaseId value
  - Add try-catch around `db.settings()` call
  - Log success or error from configuration attempt
  - Log final `db._settings` state after configuration
  - Log final databaseId value
  - Add critical error if databaseId is not 'elajtech'
  - _Requirements: Investigation 3_

- [x] 1.7 Create database verification helper function
  - Implement `verifyDatabaseConfig(operationName)` function
  - Log current databaseId before each Firestore query
  - Log error if databaseId is not 'elajtech'
  - Return boolean indicating correct configuration
  - _Requirements: Investigation 3_

- [x] 1.8 Add Firestore instance tracking
  - Add `DB_INSTANCE_ID` constant with random identifier
  - Log instance ID at creation
  - Log instance ID with each query
  - Search codebase for multiple `admin.firestore()` calls
  - _Requirements: Investigation 4_

- [x] 1.9 Add conditional configuration evaluation logging
  - Log evaluation of `!db._settings || !db._settings.databaseId` condition
  - Log whether condition is true or false
  - Log whether configuration is applied or skipped
  - Log existing databaseId if configuration is skipped
  - _Requirements: Investigation 5_

- [x] 1.10 Deploy diagnostic version to production
  - Run `firebase deploy --only functions`
  - Verify deployment in Firebase Console
  - Check Cloud Functions logs for initialization messages
  - Request doctors to attempt call initiation
  - Monitor logs in real-time
  - _Requirements: Investigation 1-5_

---

## Phase 2: Bug Condition Exploration

- [ ] 2. Write bug condition exploration tests (BEFORE implementing fix)
  - **Property 1: Fault Condition** - Appointment Retrieval Failure
  - **CRITICAL**: These tests MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the tests or the code when they fail**
  - **NOTE**: These tests encode the expected behavior - they will validate the fix when they pass after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bug exists and identify root cause
  - **Scoped PBT Approach**: Test specific scenarios for each hypothesis

  - [ ] 2.1 Test Hypothesis 1: Deployment Issue
    - **Property 1: Fault Condition** - Deployed Version Verification
    - Create test that calls `getFunctionsVersion` endpoint
    - Assert `hasDatabaseConfigFix` is true
    - Assert `databaseId` is 'elajtech'
    - Run test against production
    - **EXPECTED OUTCOME**: Test FAILS if deployed version is outdated (confirms Hypothesis 1)
    - Document counterexample: version number, databaseId value
    - _Requirements: 1.1, 1.2, Investigation 1_

  - [ ] 2.2 Test Hypothesis 2: AppointmentId Mismatch
    - **Property 1: Fault Condition** - AppointmentId Consistency
    - Create test appointment in Firestore with known ID
    - Retrieve appointment via Flutter repository
    - Assert `appointment.id` matches Firestore `doc.id`
    - Query Cloud Functions with appointment.id
    - Assert appointment is found
    - Run test on unfixed code
    - **EXPECTED OUTCOME**: Test FAILS if IDs don't match (confirms Hypothesis 2)
    - Document counterexample: Flutter ID vs Firestore ID
    - _Requirements: 1.2, Investigation 2_

  - [ ] 2.3 Test Hypothesis 3: Database Configuration Ineffective
    - **Property 1: Fault Condition** - Runtime Database Configuration
    - Create JavaScript test in `functions/test/`
    - Assert `db._settings.databaseId` equals 'elajtech' at initialization
    - Create test appointment in elajtech database
    - Query appointment using configured db instance
    - Assert appointment is found
    - Run test on unfixed code
    - **EXPECTED OUTCOME**: Test FAILS if database config not applied (confirms Hypothesis 3)
    - Document counterexample: actual databaseId value
    - _Requirements: 1.3, Investigation 3_

  - [ ] 2.4 Test Hypothesis 4: Multiple Firestore Instances
    - **Property 1: Fault Condition** - Single Instance Verification
    - Create JavaScript test to check instance uniqueness
    - Call `admin.firestore()` multiple times
    - Assert all calls return same instance
    - Assert all instances have databaseId 'elajtech'
    - Run test on unfixed code
    - **EXPECTED OUTCOME**: Test FAILS if multiple instances exist (confirms Hypothesis 4)
    - Document counterexample: number of instances, their configurations
    - _Requirements: 1.4, Investigation 4_

  - [ ] 2.5 Test Hypothesis 5: Conditional Configuration Logic
    - **Property 1: Fault Condition** - Configuration Application
    - Create JavaScript test to verify conditional logic
    - Mock different initial states of `db._settings`
    - Test condition evaluation for each state
    - Assert configuration is applied in all cases
    - Run test on unfixed code
    - **EXPECTED OUTCOME**: Test FAILS if condition prevents configuration (confirms Hypothesis 5)
    - Document counterexample: initial state that prevents configuration
    - _Requirements: 1.5, Investigation 5_

  - [ ] 2.6 Analyze diagnostic results and confirm root cause
    - Review all test failures
    - Review production logs from diagnostic deployment
    - Identify which hypothesis is confirmed
    - Document root cause in bug report
    - Determine which fixes to implement
    - _Requirements: All investigations_

---

## Phase 3: Preservation Property Tests

- [ ] 3. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Non-Call-Initiation Behavior
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-buggy inputs
  - Write property-based tests capturing observed behavior patterns
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (confirms baseline behavior to preserve)

  - [ ] 3.1 Preservation test: Appointment listing
    - **Property 2: Preservation** - Appointment Listing Unchanged
    - Observe: Create 10 test appointments in Firestore
    - Observe: Query appointments via Flutter repository
    - Observe: All 10 appointments are retrieved correctly
    - Write property-based test: For all appointment queries, all appointments are returned
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test PASSES (confirms baseline behavior)
    - _Requirements: 3.1, 3.2, 3.3_

  - [ ] 3.2 Preservation test: endAgoraCall function
    - **Property 2: Preservation** - Call Ending Unchanged
    - Observe: Create appointment with callStartedAt timestamp
    - Observe: Call `endAgoraCall` function
    - Observe: callEndedAt timestamp is set correctly
    - Write property-based test: For all call end requests, callEndedAt is set
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test PASSES (confirms baseline behavior)
    - _Requirements: 3.4, 3.6_

  - [ ] 3.3 Preservation test: completeAppointment function
    - **Property 2: Preservation** - Appointment Completion Unchanged
    - Observe: Create appointment with status 'scheduled'
    - Observe: Call `completeAppointment` function
    - Observe: Status changes to 'completed', completedAt is set
    - Write property-based test: For all completion requests, status and timestamp are updated
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test PASSES (confirms baseline behavior)
    - _Requirements: 3.5, 3.6_

  - [ ] 3.4 Preservation test: Flutter Firestore queries
    - **Property 2: Preservation** - Flutter Queries Unchanged
    - Observe: Create appointment using Flutter Firestore instance
    - Observe: Query appointment using same instance
    - Observe: Appointment is retrieved correctly
    - Write property-based test: For all Flutter queries, correct database is used
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test PASSES (confirms baseline behavior)
    - _Requirements: 3.3_

  - [ ] 3.5 Preservation test: Call logs writing
    - **Property 2: Preservation** - Call Logs Unchanged
    - Observe: Write test event to call_logs collection
    - Observe: Query call_logs to verify event was written
    - Observe: Event exists in elajtech database
    - Write property-based test: For all log writes, logs are written to correct database
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test PASSES (confirms baseline behavior)
    - _Requirements: 3.6_

  - [ ] 3.6 Preservation test: Existing unit tests
    - **Property 2: Preservation** - All Tests Pass
    - Run all 664+ existing unit tests
    - Verify all tests pass on UNFIXED code
    - Document any failures (should be none)
    - **EXPECTED OUTCOME**: All tests PASS (confirms no pre-existing issues)
    - _Requirements: 3.9_

---

## Phase 4: Fix Implementation

- [ ] 4. Implement fixes based on diagnostic results

  - [ ] 4.1 Fix 1: Ensure deployment (if Hypothesis 1 confirmed)
    - Add `FUNCTIONS_VERSION = '2.1.0'` constant to `functions/index.js`
    - Add `DEPLOYED_AT` timestamp constant
    - Add initialization logging
    - Keep `getFunctionsVersion` endpoint from diagnostic phase
    - Run `firebase deploy --only functions`
    - Verify deployment in Firebase Console
    - Call `getFunctionsVersion` from Flutter to verify
    - _Bug_Condition: deployedFunctionsVersion.hasDatabaseConfigFix = false_
    - _Expected_Behavior: Deployed version includes database config fix_
    - _Preservation: Other Cloud Functions continue to work_
    - _Requirements: 2.1, 2.8_

  - [ ] 4.2 Fix 2: Ensure AppointmentId consistency (if Hypothesis 2 confirmed)
    - Modify `AppointmentModel.fromJson()` in `lib/shared/models/appointment_model.dart`
    - Add optional `documentId` parameter to factory constructor
    - Use `documentId` if provided, otherwise fall back to `json['id']`
    - Add validation logging for ID mismatches
    - Update all repository methods to pass `doc.id` to `fromJson`
    - Add assertion in debug mode to verify ID consistency
    - _Bug_Condition: appointmentId ≠ firestoreDocumentId_
    - _Expected_Behavior: appointmentId = firestoreDocumentId_
    - _Preservation: Existing appointments continue to work_
    - _Requirements: 2.1, 2.2, 2.7_

  - [x] 4.3 Fix 3: Unconditional database configuration (if Hypothesis 3 or 5 confirmed)
    - Remove conditional check in `functions/index.js`
    - Apply `db.settings({ databaseId: 'elajtech' })` unconditionally
    - Wrap in try-catch to handle "already configured" errors
    - Add comprehensive logging before and after configuration
    - Add critical validation after configuration
    - Throw error if databaseId is not 'elajtech' after configuration
    - _Bug_Condition: actualDatabaseQueried ≠ 'elajtech'_
    - _Expected_Behavior: All queries target elajtech database_
    - _Preservation: Existing queries continue to work_
    - _Requirements: 2.2, 2.9_

  - [ ] 4.4 Fix 4: Prevent multiple Firestore instances (if Hypothesis 4 confirmed)
    - Ensure single `const db = admin.firestore()` declaration
    - Freeze db instance with `Object.freeze(db)`
    - Override `admin.firestore()` to return configured instance
    - Add warning logging if direct `admin.firestore()` is called
    - Add instance ID tracking for debugging
    - _Bug_Condition: queryUsesUnconfiguredInstance = true_
    - _Expected_Behavior: All queries use configured instance_
    - _Preservation: Existing queries continue to work_
    - _Requirements: 2.2, 2.9_

  - [ ] 4.5 Implement enhanced logging infrastructure
    - Add request ID generation for call tracking
    - Add comprehensive logging in `startAgoraCall` function
    - Log request data, database config, query details
    - Add enhanced error logging with diagnostic information
    - Log similar appointments when appointment not found
    - Add metadata to call_logs entries (requestId, databaseId, functionsVersion)
    - _Expected_Behavior: Comprehensive diagnostic information available_
    - _Preservation: Existing logging continues to work_
    - _Requirements: 2.10_

  - [ ] 4.6 Implement database query verification
    - Create `verifyDatabaseConfig(operationName)` helper function
    - Call before each Firestore query in Cloud Functions
    - Log current databaseId and operation name
    - Log error if databaseId is not 'elajtech'
    - Return boolean indicating correct configuration
    - _Expected_Behavior: All queries verified before execution_
    - _Preservation: Existing queries continue to work_
    - _Requirements: 2.9, 2.10_

  - [ ] 4.7 Implement monitoring metrics collection
    - Create `recordCallMetrics(data)` function
    - Write metrics to `call_metrics` collection
    - Include timestamp, date, hour, event type, success status
    - Include databaseId and functionsVersion in metrics
    - Call from `startAgoraCall` for all attempts
    - _Expected_Behavior: Metrics available for monitoring dashboard_
    - _Preservation: Existing functionality unaffected_
    - _Requirements: Success Criteria 1, 2_

  - [ ] 4.8 Add query interceptor for debugging (optional, debug mode only)
    - Create `createQueryInterceptor(db)` function
    - Intercept `collection()` and `doc()` calls
    - Log collection path and document ID for each query
    - Log current databaseId with each query
    - Enable only in emulator or when DEBUG_QUERIES=true
    - _Expected_Behavior: Detailed query logging in debug mode_
    - _Preservation: No impact on production performance_
    - _Requirements: 2.10_

  - [ ] 4.9 Verify bug condition exploration tests now pass
    - **Property 1: Expected Behavior** - Appointment Retrieval Success
    - **IMPORTANT**: Re-run the SAME tests from Phase 2 - do NOT write new tests
    - The tests from Phase 2 encode the expected behavior
    - When these tests pass, it confirms the expected behavior is satisfied
    - Run all exploration tests from Phase 2
    - **EXPECTED OUTCOME**: Tests PASS (confirms bug is fixed)
    - Document which tests now pass
    - _Requirements: Expected Behavior Properties from design_

  - [ ] 4.10 Verify preservation tests still pass
    - **Property 2: Preservation** - Non-Call-Initiation Behavior Unchanged
    - **IMPORTANT**: Re-run the SAME tests from Phase 3 - do NOT write new tests
    - Run all preservation tests from Phase 3
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Verify all 664+ existing tests still pass
    - Document any failures (should be none)
    - _Requirements: Preservation Requirements from design_

---

## Phase 5: Comprehensive Testing

- [ ] 5. Execute comprehensive test suite

  - [ ] 5.1 Run unit tests
    - Test database configuration is applied correctly
    - Test appointmentId consistency in model
    - Test Firestore queries target correct database
    - Test error handling for invalid appointmentIds
    - Test logging captures diagnostic information
    - Test version endpoint returns correct information
    - All tests must pass
    - _Requirements: Success Criteria 3, 6_

  - [ ] 5.2 Run integration tests
    - Test full call flow: create → start → end → complete
    - Test call flow with Firestore emulator
    - Test error scenarios: invalid ID, missing appointment, wrong doctor
    - Test concurrent call initiations
    - Test call initiation after deployment
    - All tests must pass
    - _Requirements: Success Criteria 1, 7_

  - [ ] 5.3 Run property-based tests
    - Generate random appointmentIds and verify consistency
    - Generate random appointment data and verify CRUD operations
    - Generate random doctor/patient combinations and verify call flow
    - Test non-call-initiation operations across many scenarios
    - All tests must pass
    - _Requirements: Success Criteria 6, 7_

  - [ ] 5.4 Run existing test suite
    - Run all 664+ existing unit tests
    - Verify 100% pass rate
    - Document any failures and fix immediately
    - Run `flutter test --coverage`
    - Verify coverage maintained or improved
    - _Requirements: 3.9, Success Criteria 3, 6_

  - [ ] 5.5 Manual testing in staging (if available)
    - Deploy to staging environment
    - Create test appointment
    - Attempt call initiation as doctor
    - Verify success and check logs
    - Test error scenarios
    - Verify monitoring metrics
    - _Requirements: Success Criteria 1, 4_

---

## Phase 6: Production Deployment

- [ ] 6. Deploy to production with verification

  - [ ] 6.1 Pre-deployment checklist
    - [ ] All diagnostic tests pass and root cause identified
    - [ ] Appropriate fixes implemented based on diagnostic results
    - [ ] All unit tests pass (664+ tests)
    - [ ] Integration tests pass
    - [ ] Property-based tests pass
    - [ ] Code review completed
    - [ ] Documentation updated (CHANGELOG.md, API_DOCUMENTATION.md)
    - [ ] Rollback plan prepared
    - [ ] Monitoring dashboard ready
    - [ ] Stakeholders notified of deployment window
    - _Requirements: Deployment Plan_

  - [ ] 6.2 Deploy Cloud Functions to production
    - Run `cd functions && firebase deploy --only functions`
    - Monitor deployment progress
    - Verify deployment completes successfully
    - Check Firebase Console for deployment confirmation
    - _Requirements: 2.8, Deployment Plan Phase 2_

  - [ ] 6.3 Verify deployment
    - Call `getFunctionsVersion` endpoint from Flutter
    - Verify version matches expected version (2.1.0)
    - Verify `hasDatabaseConfigFix` is true
    - Verify `databaseId` is 'elajtech'
    - Check Cloud Functions logs for initialization messages
    - _Requirements: 2.8, Success Criteria 4_

  - [ ] 6.4 Monitor initial call attempts
    - Request doctors to attempt call initiation
    - Monitor `startAgoraCall` logs in real-time
    - Watch for "Appointment Not Found" errors
    - Verify successful call initiations
    - Check call_logs collection for error events
    - _Requirements: Success Criteria 1, 2_

  - [ ] 6.5 Verify success metrics (first 2 hours)
    - Query call_logs for success rate
    - Calculate: (successful calls / total attempts) * 100
    - Verify success rate ≥90%
    - Check for "appointment_not_found" errors
    - Verify error rate <10%
    - _Requirements: Success Criteria 1, 2_

---

## Phase 7: Post-Deployment Monitoring

- [ ] 7. Monitor and validate for 48-72 hours

  - [ ] 7.1 Set up monitoring queries
    - Create query for call initiation success rate
    - Create query for error distribution by error code
    - Create query for affected appointments
    - Create query for performance metrics
    - Schedule queries to run every hour
    - _Requirements: Post-Deployment Monitoring_

  - [ ] 7.2 Monitor success metrics (Day 1)
    - Track call initiation success rate every 4 hours
    - Track error rate by error code
    - Track number of affected doctors/appointments
    - Track average call initiation time
    - Document any issues or anomalies
    - _Requirements: Success Criteria 1, 2_

  - [ ] 7.3 Monitor success metrics (Day 2)
    - Continue tracking success rate every 4 hours
    - Verify success rate ≥95% for 24 consecutive hours
    - Verify error rate <5%
    - Review Cloud Functions logs for any errors
    - Collect doctor feedback
    - _Requirements: Success Criteria 1, 2, 7_

  - [ ] 7.4 Monitor success metrics (Day 3-7)
    - Track success rate daily
    - Verify sustained success rate ≥95%
    - Verify sustained error rate <5%
    - Review weekly metrics summary
    - Generate deployment report
    - _Requirements: Success Criteria 1, 2, 7_

  - [ ] 7.5 Create monitoring dashboard
    - Display real-time call initiation success rate
    - Display error rate trends over time
    - Display most common error codes
    - Display affected users count
    - Display performance metrics (latency, execution time)
    - Set up alert thresholds
    - _Requirements: Post-Deployment Monitoring_

  - [ ] 7.6 Collect and analyze user feedback
    - Request feedback from doctors
    - Document any reported issues
    - Track user satisfaction
    - Address any concerns promptly
    - _Requirements: Success Criteria 7_

---

## Phase 8: Final Validation and Documentation

- [ ] 8. Checkpoint - Ensure all success criteria met

  - [ ] 8.1 Verify all success criteria
    - [ ] Call initiation success rate ≥95% for 48 consecutive hours
    - [ ] "Appointment Not Found" error rate <5% of total attempts
    - [ ] Database configuration verified (databaseId = 'elajtech')
    - [ ] AppointmentId consistency verified (Flutter IDs match Firestore IDs)
    - [ ] All 664+ existing tests pass without modifications
    - [ ] No critical bugs reported by doctors
    - [ ] No regressions in existing functionality
    - [ ] Deployment verified (correct version active)
    - _Requirements: Success Criteria 1-8_

  - [ ] 8.2 Update documentation
    - Update CHANGELOG.md with bugfix details
    - Update API_DOCUMENTATION.md if needed
    - Document root cause and fix in bug report
    - Document lessons learned
    - Update deployment procedures if needed
    - _Requirements: Constraints_

  - [ ] 8.3 Generate final deployment report
    - Summarize diagnostic findings
    - Document root cause confirmation
    - List all fixes implemented
    - Report final success metrics
    - Include user feedback summary
    - Document any issues encountered
    - Provide recommendations for future improvements
    - _Requirements: Deployment Plan Phase 3_

  - [ ] 8.4 Conduct post-mortem meeting
    - Review diagnostic process effectiveness
    - Discuss what went well
    - Discuss what could be improved
    - Document action items for future bugfixes
    - Share learnings with team
    - _Requirements: Communication Plan_

  - [ ] 8.5 Close bug ticket
    - Verify all acceptance criteria met
    - Update bug status to "Resolved"
    - Link to deployment report
    - Add final comments with resolution summary
    - Notify stakeholders of resolution
    - _Requirements: Success Criteria_

---

## Rollback Plan

If at any point success rate drops below 80% or critical issues are discovered:

- [ ] R.1 Execute immediate rollback
  - Run `firebase functions:rollback startAgoraCall`
  - Verify rollback in Firebase Console
  - Check logs to confirm old version is active
  - _Requirements: Rollback Procedure_

- [ ] R.2 Notify stakeholders
  - Inform development team of rollback
  - Notify doctors of temporary issue
  - Update status page
  - _Requirements: Communication Plan_

- [ ] R.3 Conduct post-rollback analysis
  - Review logs to identify rollback cause
  - Document issues encountered
  - Plan corrective actions
  - Schedule new deployment
  - _Requirements: Rollback Procedure_

---

## Notes

- **Diagnostic-First Approach**: Phases 1-2 focus on identifying the root cause before implementing fixes
- **Test-Driven**: Phases 2-3 write tests BEFORE implementing fixes to validate the fix works
- **Phased Deployment**: Phase 6 deploys in stages with verification at each step
- **Continuous Monitoring**: Phase 7 monitors for 48-72 hours to ensure stability
- **Rollback Ready**: Rollback plan prepared and tested before deployment

**Estimated Timeline**:
- Phase 1 (Diagnostic): 1-2 days
- Phase 2 (Exploration): 1 day
- Phase 3 (Preservation): 1 day
- Phase 4 (Implementation): 2-3 days
- Phase 5 (Testing): 1-2 days
- Phase 6 (Deployment): 1 day
- Phase 7 (Monitoring): 3-7 days
- Phase 8 (Documentation): 1 day

**Total**: 11-18 days

---

**Document Version**: 1.0.0  
**Created**: 2024-02-16  
**Status**: Ready for Execution
