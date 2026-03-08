# Phase 2: Critical Path Coverage - Kickoff Guide

## 🎯 Phase Status
- **Phase 1**: ✅ COMPLETE (384/384 tests passing)
- **Phase 2**: 🚀 READY TO START
- **Current Coverage**: 12.58%
- **Phase 2 Target**: 60%+ overall coverage
- **Final Target**: 85%

---

## 📊 Quick Coverage Summary

### 🔴 CRITICAL - Zero Coverage (Must Fix First)
| Service | Current | Target | Lines Needed | Priority |
|---------|---------|--------|--------------|----------|
| TokenRefreshService | 0% | 85% | 31 | 🔴 Critical |
| FirebaseAuthService | 0% | 85% | 13 | 🔴 Critical |
| AuthProvider | 0.6% | 70% | 110 | 🔴 Critical |
| CallMonitoringService | 0.3% | 85% | 247 | 🔴 Critical |

### 🟡 HIGH PRIORITY - Low Coverage (<30%)
| Service | Current | Target | Lines Needed | Priority |
|---------|---------|--------|--------------|----------|
| VoIPCallService | 12.2% | 85% | 185 | 🟡 High |
| AgoraService | 16.9% | 85% | 193 | 🟡 High |
| FCMService | 3.4% | 85% | 71 | 🟡 High |
| NotificationService | 10.3% | 85% | 22 | 🟡 High |
| AuthRepository | 47.6% | 85% | 61 | 🟡 High |

### 🟢 GOOD COVERAGE - Maintain (>70%)
| Component | Current | Status |
|-----------|---------|--------|
| UserRepository | 100% | ✅ Complete |
| PhysiotherapyEMRModel | 97.4% | ✅ Excellent |
| UserModel | 97.6% | ✅ Excellent |
| AppointmentRepository | 81.6% | ✅ Good |
| PhysiotherapyEMRRepository | 81% | ✅ Good |

---

## 🗓️ Week 2 Plan: Core Services Coverage

### Day 1-2: Zero Coverage Services (14 hours)
**Priority**: 🔴 CRITICAL

#### Task 1: TokenRefreshService (4 hours)
```bash
# Create test file
test/unit/services/token_refresh_service_test.dart
```
**Focus**:
- Token expiry detection
- Refresh logic
- Error recovery
- Firebase Auth integration

**Test Cases**:
1. Should detect expired tokens
2. Should refresh token successfully
3. Should handle refresh failures
4. Should retry on network errors
5. Should update token in storage

#### Task 2: FirebaseAuthService (3 hours)
```bash
# Enable skipped tests
test/unit/services/firebase_auth_service_test.dart
```
**Focus**:
- Static auth methods
- User getters
- Auth state stream
- Session management

**Test Cases**:
1. Should return current user
2. Should return current user ID
3. Should check if logged in
4. Should stream auth state changes
5. Should handle null user

---

### Day 3: CallMonitoringService (8 hours)
**Priority**: 🔴 CRITICAL (Highest Impact - 247 lines)

```bash
# Expand existing test
test/unit/services/call_monitoring_service_test.dart
```

**Focus**:
- Call event logging
- Firestore writes
- Device info collection
- Error handling

**Test Cases**:
1. Should log call start event
2. Should log call end event
3. Should log call error event
4. Should collect device info
5. Should write to Firestore
6. Should handle Firestore errors
7. Should retry failed writes
8. Should validate call data
9. Should handle missing appointment ID
10. Should handle missing user ID

---

### Day 4: VoIP & Notifications (9 hours)

#### Task 1: VoIPCallService (6 hours)
```bash
# Expand existing test
test/unit/services/voip_call_service_test.dart
```
**Focus**:
- Incoming call handling
- Accept/decline flows
- CallKit integration
- Notification display

**Test Cases**:
1. Should handle incoming call
2. Should accept call successfully
3. Should decline call successfully
4. Should show CallKit UI
5. Should handle CallKit errors
6. Should cleanup after call
7. Should handle multiple calls
8. Should timeout inactive calls

#### Task 2: NotificationService (3 hours)
```bash
# Create test file
test/unit/services/notification_service_test.dart
```
**Focus**:
- Local notifications
- Scheduling
- Display

**Test Cases**:
1. Should initialize successfully
2. Should show notification
3. Should schedule notification
4. Should cancel notification
5. Should handle permission denied

---

### Day 5: Video & Push Notifications (11 hours)

#### Task 1: AgoraService (6 hours)
```bash
# Expand existing test
test/unit/services/agora_service_test.dart
```
**Focus**:
- Video/audio controls
- Network events
- Error recovery

**Test Cases**:
1. Should toggle video
2. Should toggle audio
3. Should switch camera
4. Should handle network quality changes
5. Should handle connection lost
6. Should reconnect automatically
7. Should handle remote user joined
8. Should handle remote user left

#### Task 2: FCMService (5 hours)
```bash
# Create test file
test/unit/services/fcm_service_test.dart
```
**Focus**:
- Push notification handling
- Token management
- Message routing

**Test Cases**:
1. Should initialize FCM
2. Should get FCM token
3. Should refresh token
4. Should handle foreground messages
5. Should handle background messages
6. Should route messages correctly
7. Should handle token refresh

---

## 🚀 Getting Started

### Step 1: Verify Phase 1 Complete
```bash
flutter test test/unit/ test/widget/ test/core/
```
Expected: 384/384 tests passing ✅

### Step 2: Generate Current Coverage
```bash
flutter test --coverage test/unit/ test/widget/ test/core/
```

### Step 3: Start with Day 1 Tasks
Begin with TokenRefreshService (highest priority, zero coverage)

---

## 📝 Testing Guidelines

### Mock Setup
Always use the test helpers:
```dart
import 'package:elajtech/test/helpers/widget_test_helper.dart';

void main() {
  setUpAll(() {
    setupFirebaseMocks();
  });
}
```

### Test Structure
```dart
group('ServiceName - Feature', () {
  test('should do something successfully', () {
    // Arrange
    // Act
    // Assert
  });
  
  test('should handle error case', () {
    // Arrange
    // Act
    // Assert
  });
});
```

### Coverage Verification
After each service:
```bash
flutter test --coverage test/unit/services/your_service_test.dart
```

---

## 📈 Success Metrics

### Week 2 Targets
- ✅ 7 services at 85%+ coverage
- ✅ ~755 lines covered
- ✅ All critical services tested
- ✅ Zero coverage services eliminated

### Daily Checkpoints
- Day 1: 2 services at 85% (44 lines)
- Day 2: Continue Day 1 tasks
- Day 3: 1 service at 85% (247 lines)
- Day 4: 2 services at 85% (207 lines)
- Day 5: 2 services at 85% (264 lines)

---

## 🎯 Next Steps

1. Review this kickoff guide
2. Verify Phase 1 completion (run tests)
3. Start with TokenRefreshService test creation
4. Follow the daily plan
5. Track progress daily
6. Report any blockers immediately

---

## 📚 Resources

- **Test Quick Reference**: `TEST_QUICK_REFERENCE.md`
- **Coverage Plan**: `coverage-improvement-plan.md`
- **Test Helpers**: `test/helpers/widget_test_helper.dart`
- **Mock Definitions**: `test/mocks/mocks.dart`

---

## ⚠️ Important Notes

1. **Focus on business logic** - Don't test simple getters/setters
2. **Mock external dependencies** - Firebase, Agora, CallKit, etc.
3. **Test error paths** - Error handling is critical
4. **Keep tests fast** - Use mocks, avoid real network calls
5. **Follow 2-attempt limit** - Don't spend too long fixing one test

---

**Ready to start? Let's achieve 85% coverage! 🚀**
