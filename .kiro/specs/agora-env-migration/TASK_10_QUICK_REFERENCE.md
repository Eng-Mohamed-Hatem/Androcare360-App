# Task 10 Quick Reference: Deploy to Production

**Quick deployment checklist and commands for Task 10**

---

## Pre-Flight Checklist

Before starting deployment:

- [ ] All previous tasks complete (Tasks 1-9)
- [ ] All 81 verification tests passing
- [ ] .env file exists with real credentials
- [ ] .env NOT committed to git
- [ ] Team notified
- [ ] Rollback procedure ready

---

## Task 10.1: Pre-Deployment Verification

### Quick Commands

```bash
# 1. Check .env file exists
cd functions
ls -la .env

# 2. Verify .env contents (CAREFUL - contains secrets!)
cat .env

# 3. Verify .env not in git
git status | grep .env
git ls-files | grep "\.env$"  # Should return nothing

# 4. Run all tests
npm test

# 5. Verify Firebase project
firebase use
```

### Expected Results

✅ `.env` file exists  
✅ Contains real credentials (not placeholders)  
✅ NOT tracked by git  
✅ All 81 tests pass  
✅ Current project is `elajtech`

---

## Task 10.2: Deploy Functions

### Deployment Commands

```bash
# 1. Switch to production project
firebase use elajtech

# 2. Deploy functions
firebase deploy --only functions

# 3. Monitor logs (in another terminal)
firebase functions:log --only startAgoraCall
```

### Expected Output

```
✔  functions[startAgoraCall(europe-west1)] Successful update operation.
✔  functions[endAgoraCall(europe-west1)] Successful update operation.
✔  functions[completeAppointment(europe-west1)] Successful update operation.

✔  Deploy complete!
```

---

## Task 10.3: Verify Deployment

### Verification Commands

```bash
# 1. List deployed functions
firebase functions:list

# 2. Check function logs
firebase functions:log --only startAgoraCall --limit 50
firebase functions:log --only endAgoraCall --limit 50
firebase functions:log --only completeAppointment --limit 50

# 3. Check for configuration errors
firebase functions:log --limit 100 | grep -i "error\|missing\|not configured"
```

### What to Look For

✅ All 3 functions listed and active  
✅ No configuration errors in logs  
✅ No "credentials not configured" errors  
✅ Functions execute successfully

---

## Rollback Procedure (If Needed)

### Quick Rollback Commands

```bash
# 1. Revert to previous commit
git log --oneline | head -10
git checkout <previous-commit-hash>

# 2. Redeploy previous version
firebase deploy --only functions

# 3. Verify rollback
firebase functions:log --limit 50
```

**Rollback Time**: < 5 minutes

---

## Common Issues

### Issue: "Credentials not configured"

**Solution**:
```bash
# Verify .env file
cat functions/.env

# Redeploy
firebase deploy --only functions
```

### Issue: Deployment fails

**Solution**:
```bash
# Check Firebase project
firebase use

# Verify permissions
firebase projects:list

# Check .env file exists
ls -la functions/.env
```

### Issue: Functions inactive

**Solution**:
```bash
# Check logs
firebase functions:log --limit 50

# Redeploy
firebase deploy --only functions
```

---

## Success Criteria

Task 10 complete when:

- ✅ All 3 functions deployed
- ✅ No deployment errors
- ✅ No configuration errors in logs
- ✅ Functions active in console
- ✅ Functions execute successfully

---

## Time Estimate

- Pre-deployment: 15-20 min
- Deployment: 5-10 min
- Verification: 10-15 min

**Total**: 30-45 minutes

---

## Next Steps

After Task 10:
1. Mark Task 10 complete
2. Proceed to Task 11 (monitoring)
3. Monitor for 1 hour
4. Document any issues

---

## Important Links

- Firebase Console: https://console.firebase.google.com/project/elajtech/functions
- Deployment Plan: TASK_10_DEPLOYMENT_PLAN.md
- Rollback Procedure: See TASK_10_DEPLOYMENT_PLAN.md

---

**Risk Level**: LOW  
**Rollback Available**: YES (< 5 minutes)  
**Breaking Changes**: ZERO (verified in Task 9)
