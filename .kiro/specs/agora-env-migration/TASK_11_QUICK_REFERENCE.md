# Task 11 Quick Reference: Monitor Production Deployment

**Quick monitoring checklist and commands for Task 11**

---

## Monitoring Period

**Duration**: 1 hour  
**Start Time**: After deployment verification complete  
**Frequency**: Check every 5-15 minutes

---

## Quick Commands

### Monitor Function Logs

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
```

---

## Quick Checks

### Every 5-15 Minutes

```bash
# 1. Check for errors
firebase functions:log --limit 50 | grep -i "error"

# 2. Check for configuration errors
firebase functions:log --limit 50 | grep -i "credentials\|missing"

# 3. Check function status
firebase functions:list
```

**Expected**: No errors, all functions active

---

## Firebase Console Checks

### Function Metrics

1. Open: https://console.firebase.google.com/project/elajtech-fc804/functions
2. Check each function:
   - Invocation count
   - Error rate (should be 0%)
   - Execution time
   - Memory usage

---

### Firestore Checks

1. Open: https://console.firebase.google.com/project/elajtech-fc804/firestore
2. Select database: **elajtech**
3. Check `call_logs` collection
4. Verify recent logs (if traffic exists)

---

## What to Look For

### ✅ Good Signs

- No errors in logs
- Functions execute successfully
- Error rate 0%
- Logs written to elajtech database
- Error messages include `[DB: elajtech]`

### ❌ Bad Signs

- "Credentials not configured" errors
- "Missing environment variables" errors
- High error rate (> 5%)
- Logs in default database
- Missing database context

---

## Monitoring Schedule

### 0-15 minutes
- Check logs every 5 minutes
- Monitor Firebase Console
- Check for configuration errors

### 15-30 minutes
- Check logs every 10 minutes
- Monitor call_logs collection
- Verify database isolation

### 30-45 minutes
- Check logs every 10 minutes
- Monitor video call flow
- Check for errors

### 45-60 minutes
- Check logs every 15 minutes
- Final verification
- Document observations

---

## Issue Response

### Configuration Errors

```bash
# Check .env file
ls -la functions/.env
cat functions/.env

# Redeploy if needed
firebase deploy --only functions
```

### Database Issues

```bash
# Check database configuration
grep -n "databaseId" functions/index.js

# Verify elajtech database
firebase firestore:databases:list
```

---

## Success Criteria

Task 11 complete when:

- ✅ 1 hour monitoring period completed
- ✅ No configuration errors
- ✅ Functions execute successfully
- ✅ Database isolation maintained
- ✅ Documentation complete

---

## Quick Firestore Queries

### Check Recent Logs

```javascript
// In Firebase Console > Firestore > elajtech database
db.collection('call_logs')
  .where('timestamp', '>=', deploymentTime)
  .orderBy('timestamp', 'desc')
  .limit(50)
```

### Check Error Logs

```javascript
db.collection('call_logs')
  .where('eventType', '==', 'call_error')
  .where('timestamp', '>=', deploymentTime)
  .orderBy('timestamp', 'desc')
  .limit(50)
```

---

## Documentation

Create monitoring log: `TASK_11_MONITORING_LOG.md`

**Log Format**:
```markdown
## [Time] Check
- Checked function logs - [Result]
- Checked Firebase Console - [Result]
- Checked call_logs collection - [Result]
- Issues: [None/Details]
```

---

## Time Estimate

- **Monitoring**: 1 hour
- **Documentation**: 15 minutes
- **Total**: ~1 hour 15 minutes

---

## Important Links

- Firebase Console: https://console.firebase.google.com/project/elajtech-fc804
- Functions: https://console.firebase.google.com/project/elajtech-fc804/functions
- Firestore: https://console.firebase.google.com/project/elajtech-fc804/firestore

---

## Next Steps

After Task 11:
1. Complete monitoring period
2. Document observations
3. Create monitoring report
4. Mark Task 11 complete
5. Proceed to Task 12

---

**Risk Level**: LOW (monitoring only)  
**No Code Changes**: Monitoring only, no deployment

