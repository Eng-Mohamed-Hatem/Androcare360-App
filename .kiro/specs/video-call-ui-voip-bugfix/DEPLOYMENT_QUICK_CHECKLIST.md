# Production Deployment - Quick Checklist

**Task 21.1 - Video Call UI and VoIP Notification Bugfixes**

---

## ⚡ Quick Start

### Pre-Flight Check (5 minutes)

```bash
# 1. Run tests
flutter test
# ✅ Expected: All 664+ tests passing

# 2. Run analyzer
flutter analyze
# ✅ Expected: No issues found

# 3. Check deprecated APIs
flutter analyze lib/ | grep deprecated_member_use
# ✅ Expected: No output

# 4. Verify builds
flutter build apk --release
flutter build ios --release
# ✅ Expected: Both succeed
```

---

## 🚀 Deploy Cloud Functions (10 minutes)

```bash
# 1. Test functions
cd functions
npm test
# ✅ Expected: All 48 tests passing

# 2. Verify project
firebase use
# ✅ Expected: elajtech

# 3. Deploy
firebase deploy --only functions --project elajtech
# ✅ Expected: 3 functions deployed successfully

# 4. Verify
firebase functions:list --project elajtech
# ✅ Expected: startAgoraCall, endAgoraCall, completeAppointment

# 5. Monitor logs
firebase functions:log --project elajtech
# ✅ Look for: [DB: elajtech] in logs
```

---

## 📱 Deploy Android (30 minutes)

```bash
# 1. Update version in pubspec.yaml
# Increment: 1.0.0+1 -> 1.0.1+2

# 2. Build
flutter build appbundle --release
# ✅ Expected: app-release.aab created

# 3. Test on device
flutter install --release
# ✅ Verify: App works, video calls connect

# 4. Upload to Play Console
# - Go to play.google.com/console
# - Upload app-release.aab
# - Add release notes
# - Start with 10% rollout
```

---

## 🍎 Deploy iOS (60 minutes)

```bash
# 1. Update version in pubspec.yaml (same as Android)

# 2. Build
flutter build ios --release
# ✅ Expected: Runner.app created

# 3. Archive in Xcode
# - Open ios/Runner.xcworkspace
# - Product > Archive
# - Distribute to App Store

# 4. Submit in App Store Connect
# - Go to appstoreconnect.apple.com
# - Create new version
# - Add release notes
# - Enable phased release
# - Submit for review
```

---

## 📊 Monitor (24 hours)

### Hour 0-1: Immediate Check

```bash
# Watch logs
firebase functions:log --project elajtech

# ✅ Look for:
# - Successful call initiations
# - [DB: elajtech] in all logs
# - VoIP notifications sent
# - No "Appointment Not Found" errors
```

### Hour 1-6: Active Monitoring

**Check every 2 hours:**

1. **VoIP Success Rate** (Firebase Console > Firestore > call_logs)
   - Filter: `eventType == 'voip_notification_sent'`
   - Target: > 95%

2. **Call Success Rate** (Firebase Console > Firestore > call_logs)
   - Filter: `eventType == 'call_started'`
   - Target: > 90%

3. **App Crashes** (Play Console / App Store Connect)
   - Target: < 0.5%

4. **Error Logs** (Firebase Console > Firestore > call_logs)
   - Filter: `eventType == 'call_error'`
   - Target: < 5%

### Hour 6-24: Continuous Monitoring

**Check every 6 hours:**

- [ ] Run manual end-to-end test
- [ ] Verify all metrics in target ranges
- [ ] Review user feedback
- [ ] Update stakeholders

---

## 🔄 Rollback (If Needed)

### Cloud Functions Rollback (5 minutes)

```bash
# 1. Get previous commit
git log --oneline functions/index.js

# 2. Checkout previous version
git checkout <previous-hash> functions/index.js

# 3. Deploy
firebase deploy --only functions --project elajtech

# 4. Verify
firebase functions:log --project elajtech
```

### Android Rollback (30 minutes)

1. Go to Play Console
2. Production > Releases
3. Click "Halt rollout"
4. Previous version becomes active

### iOS Rollback (2-4 hours)

1. Go to App Store Connect
2. Click "Remove from Sale"
3. Submit previous version for expedited review
4. Contact Apple Developer Support

---

## ✅ Success Criteria

After 24 hours, verify:

- [ ] VoIP notification success rate > 95%
- [ ] Call initiation success rate > 90%
- [ ] Patient join rate > 90% (within 60s)
- [ ] App crash rate < 0.5%
- [ ] No critical bugs reported
- [ ] No rollback required

---

## 📞 Emergency Contacts

**On-Call Engineer:** [TO BE FILLED]  
**Team Lead:** [TO BE FILLED]  
**Firebase Support:** firebase.google.com/support

---

## 📝 Post-Deployment

After successful 24-hour period:

1. [ ] Update CHANGELOG.md with deployment date
2. [ ] Mark Task 21.1 as complete
3. [ ] Notify stakeholders of success
4. [ ] Document any issues encountered
5. [ ] Archive deployment logs

---

**For detailed instructions, see:** `PRODUCTION_DEPLOYMENT_GUIDE.md`
