# Future Phases: Revised Metrics and Targets

## Overview

Based on lessons learned from Phase 2, this document proposes realistic metrics and targets for future phases of the testing improvement initiative.

## Phase 3: Repositories Coverage (Week 3)

### Service Classification

**Expected Types**: Mixed Services (business logic + Firestore)

**Repositories to Test**:
1. AuthRepository (47.6% → 75%)
2. DoctorRepository (61.8% → 75%)
3. NutritionEMRRepository (71.4% → 80%)
4. AppointmentRepository (81.6% → 85%)
5. PhysiotherapyEMRRepository (81% → 85%)

### Revised Targets

#### Realistic Coverage Targets
- ✅ **High-coverage repositories (80%+)**: 2 repositories
  - AppointmentRepository: 81.6% → 85%
  - PhysiotherapyEMRRepository: 81% → 85%

- ✅ **Medium-coverage repositories (75-80%)**: 2 repositories
  - AuthRepository: 47.6% → 75%
  - DoctorRepository: 61.8% → 75%
  - NutritionEMRRepository: 71.4% → 80%

#### Success Metrics
| Metric | Target | Rationale |
|--------|--------|-----------|
| Repositories at 75%+ | 5/5 | Realistic for mixed services |
| New tests created | ~150 | Based on Phase 2 experience |
| Test pass rate | 100% | Maintain quality |
| Documentation | Complete | Essential for Firestore operations |
| Integration guides | 1 per repo | Guide future testing |

#### Lines to Cover
- **Total Target**: ~100 lines (realistic, not 755)
- **AuthRepository**: ~30 lines
- **DoctorRepository**: ~10 lines
- **NutritionEMRRepository**: ~20 lines
- **AppointmentRepository**: ~10 lines
- **PhysiotherapyEMRRepository**: ~5 lines

### Testing Strategy

#### What to Test (Unit Tests)
✅ Business logic methods
✅ Data validation
✅ Error handling
✅ Model transformations
✅ Parameter validation

#### What to Document (Not Unit Test)
📋 Firestore operations
📋 Query patterns
📋 Transaction handling
📋 Integration test scenarios

#### What to Skip
❌ Firestore SDK calls (platform-dependent)
❌ Network operations
❌ Firebase Auth integration

### Daily Breakdown

**Day 1: AuthRepository + DoctorRepository** (8 hours)
- AuthRepository: 47.6% → 75% (~30 lines, ~40 tests)
- DoctorRepository: 61.8% → 75% (~10 lines, ~20 tests)
- Expected: 60 tests, 40 lines covered

**Day 2: NutritionEMRRepository** (4 hours)
- NutritionEMRRepository: 71.4% → 80% (~20 lines, ~30 tests)
- Expected: 30 tests, 20 lines covered

**Day 3: AppointmentRepository + PhysiotherapyEMRRepository** (8 hours)
- AppointmentRepository: 81.6% → 85% (~10 lines, ~30 tests)
- PhysiotherapyEMRRepository: 81% → 85% (~5 lines, ~20 tests)
- Expected: 50 tests, 15 lines covered

**Total**: 140 tests, ~75 lines covered

## Phase 4: Providers/Controllers Coverage (Week 4)

### Service Classification

**Expected Types**: Pure Dart Services (state management)

**Providers to Test**:
1. AuthProvider
2. AppointmentProvider
3. DoctorProvider
4. PatientProvider
5. ChatProvider

### Revised Targets

#### Realistic Coverage Targets
- ✅ **All providers at 85%+**: 5/5 providers
- ✅ **High-quality state tests**: Comprehensive
- ✅ **Edge case coverage**: Complete

#### Success Metrics
| Metric | Target | Rationale |
|--------|--------|-----------|
| Providers at 85%+ | 5/5 | Pure Dart, highly testable |
| New tests created | ~200 | State management needs thorough testing |
| Test pass rate | 100% | Maintain quality |
| State coverage | Complete | All states tested |
| Edge cases | Complete | All scenarios covered |

#### Lines to Cover
- **Total Target**: ~400 lines
- **Per Provider**: ~80 lines average

### Testing Strategy

#### What to Test (Unit Tests)
✅ State initialization
✅ State transitions
✅ Loading states
✅ Error states
✅ Success states
✅ Edge cases
✅ Async operations
✅ State persistence

#### What to Mock
✅ Repositories
✅ Services
✅ External dependencies

### Daily Breakdown

**Day 1-2: AuthProvider + AppointmentProvider** (16 hours)
- AuthProvider: 0% → 85% (~80 tests)
- AppointmentProvider: 0% → 85% (~80 tests)
- Expected: 160 tests

**Day 3: DoctorProvider + PatientProvider** (8 hours)
- DoctorProvider: 0% → 85% (~40 tests)
- PatientProvider: 0% → 85% (~40 tests)
- Expected: 80 tests

**Day 4: ChatProvider** (4 hours)
- ChatProvider: 0% → 85% (~60 tests)
- Expected: 60 tests

**Total**: 300 tests, ~400 lines covered

## Phase 5: Integration Tests (Week 5)

### Focus Areas

**Platform-Dependent Services** (from Phase 2):
1. NotificationService
2. AgoraService
3. FCMService
4. VoIPCallService
5. FirebaseAuthService

### Revised Targets

#### Integration Test Coverage
- ✅ **All platform services have integration tests**: 5/5
- ✅ **End-to-end flows tested**: Complete
- ✅ **Platform-specific tests**: Android + iOS

#### Success Metrics
| Metric | Target | Rationale |
|--------|--------|-----------|
| Integration test suites | 5 | One per service |
| End-to-end scenarios | ~20 | Critical flows |
| Platform coverage | Android + iOS | Both platforms |
| Device testing | Real devices | Actual behavior |
| Documentation | Complete | Setup and execution guides |

### Testing Strategy

#### Integration Test Scenarios

**NotificationService**:
1. Display local notification
2. Schedule notification
3. Cancel notification
4. Handle permissions

**AgoraService**:
1. Initialize engine
2. Join channel
3. Toggle audio/video
4. Switch camera
5. Handle network changes
6. Leave channel

**FCMService**:
1. Initialize FCM
2. Get FCM token
3. Receive foreground message
4. Receive background message
5. Handle incoming call
6. Subscribe to topics

**VoIPCallService**:
1. Show incoming call
2. Accept call
3. Decline call
4. Handle call timeout

**FirebaseAuthService**:
1. Sign up user
2. Sign in user
3. Sign out user
4. Reset password
5. Update profile

### Tools and Setup

#### Required Tools
- Firebase Test Lab
- Real Android devices
- Real iOS devices
- CI/CD pipeline

#### Setup Requirements
- Test Firebase project
- Test Agora account
- Test FCM configuration
- Test APNs certificates

### Daily Breakdown

**Day 1: Setup + NotificationService** (8 hours)
- Set up integration test framework
- Create NotificationService integration tests
- Expected: 5 integration tests

**Day 2: AgoraService + VoIPCallService** (8 hours)
- AgoraService integration tests
- VoIPCallService integration tests
- Expected: 10 integration tests

**Day 3: FCMService + FirebaseAuthService** (8 hours)
- FCMService integration tests
- FirebaseAuthService integration tests
- Expected: 10 integration tests

**Day 4: End-to-End Flows** (8 hours)
- Complete call flow (FCM → VoIP → Agora)
- Complete auth flow
- Expected: 5 end-to-end tests

**Total**: 30 integration tests

## Summary of Revised Metrics

### Phase 3: Repositories (Week 3)
- **Target**: 5 repositories at 75%+
- **Tests**: ~140 new tests
- **Lines**: ~75 lines covered
- **Time**: 20 hours

### Phase 4: Providers (Week 4)
- **Target**: 5 providers at 85%+
- **Tests**: ~300 new tests
- **Lines**: ~400 lines covered
- **Time**: 28 hours

### Phase 5: Integration (Week 5)
- **Target**: 5 integration test suites
- **Tests**: ~30 integration tests
- **Scenarios**: ~20 end-to-end flows
- **Time**: 32 hours

### Total for Phases 3-5
- **Tests**: ~470 new tests
- **Lines**: ~475 lines covered
- **Time**: 80 hours
- **Total Test Suite**: 489 → ~960 tests

## Key Principles for Future Phases

### 1. Classify Before Testing
Always classify services/repositories before setting targets:
- Pure Dart → 85%+ coverage
- Mixed → 60-80% coverage
- Platform-Dependent → Integration tests

### 2. Set Realistic Targets
Base targets on service type, not arbitrary numbers:
- Don't expect 85% for all services
- Consider platform dependencies
- Account for external SDKs

### 3. Focus on Value
Prioritize tests that provide value:
- Business logic tests
- Edge case coverage
- Error handling
- Integration scenarios

### 4. Document Everything
Every phase needs:
- Testing summary
- Integration guidelines
- Platform requirements
- Manual test scenarios

### 5. Measure Success Appropriately
Success metrics should match service type:
- Pure Dart: Coverage percentage
- Mixed: Business logic coverage + docs
- Platform-Dependent: Test comprehensiveness + integration tests

## Conclusion

These revised metrics reflect realistic expectations based on Phase 2 lessons learned:

✅ **Classify services before testing**
✅ **Set appropriate targets by type**
✅ **Focus on test quality over coverage percentage**
✅ **Invest in integration tests for platform-dependent services**
✅ **Document everything**

**Expected Outcome**: Phases 3-5 will add ~470 tests, bringing total from 489 to ~960 tests, with realistic coverage targets based on service types.
