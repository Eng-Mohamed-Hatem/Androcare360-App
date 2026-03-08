# Deprecated API Prevention Strategy

**Version:** 1.0  
**Last Updated:** 2026-02-16  
**Status:** Active

---

## Overview

This document outlines the strategy and mechanisms in place to prevent deprecated APIs from being reintroduced into the AndroCare360 codebase after the successful completion of Task 18 (Deprecated API Migration).

### Current Status

✅ **Source Code:** Zero deprecated warnings (as of 2026-02-16)  
✅ **Prevention Mechanisms:** Implemented  
✅ **Documentation:** Complete

---

## Prevention Mechanisms

### 1. Pre-Commit Hooks 🔒

**Location:** `.githooks/pre-commit`

**Purpose:** Prevent commits that introduce deprecated API warnings in source code.

**How It Works:**
1. Runs automatically before each commit
2. Analyzes staged Dart files in `lib/` directory
3. Checks for `deprecated_member_use` warnings
4. Blocks commit if deprecated APIs are detected

**Setup:**

```bash
# For Unix/Linux/macOS
bash .githooks/setup.sh

# For Windows
.githooks\setup.bat
```

**Manual Setup:**

```bash
# Configure git to use custom hooks directory
git config core.hooksPath .githooks

# Make hook executable (Unix/Linux/macOS only)
chmod +x .githooks/pre-commit
```

**Testing the Hook:**

```bash
# 1. Make a change that introduces a deprecated API
# 2. Stage the change
git add lib/your-file.dart

# 3. Try to commit
git commit -m "test commit"

# Expected: Commit blocked with error message
```

**Bypassing the Hook (Emergency Only):**

```bash
# Use --no-verify flag (not recommended!)
git commit --no-verify -m "emergency fix"
```

---

### 2. CI/CD Enforcement 🤖

**Location:** `.github/workflows/deprecated-api-check.yml`

**Purpose:** Automated checks on every push and pull request to ensure no deprecated APIs are merged.

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Changes to `lib/**/*.dart` or `pubspec.yaml`

**Workflow Steps:**
1. Checkout code
2. Setup Flutter (version 3.27.0+)
3. Get dependencies
4. Run `flutter analyze lib/`
5. Check for `deprecated_member_use` warnings
6. Fail build if warnings found
7. Upload analysis results as artifact
8. Comment on PR with details (if failed)

**Viewing Results:**

```bash
# GitHub Actions tab → Deprecated API Check workflow
# - Green checkmark: ✅ No deprecated APIs
# - Red X: ❌ Deprecated APIs detected
```

**Artifacts:**
- Analysis results saved for 30 days
- Download from GitHub Actions → Workflow run → Artifacts

---

### 3. Golden Tests 📸

**Location:** `test/golden/`

**Purpose:** Visual regression testing to ensure API migrations don't change UI appearance.

**Coverage:**
- Agora video call screen (waiting room, controls, appointment info)
- Future: Add more screens as needed

**Running Golden Tests:**

```bash
# Run golden tests
flutter test test/golden/

# Update golden files (after intentional UI changes)
flutter test --update-goldens test/golden/
```

**When to Use:**
1. **After API Migration:** Verify no visual changes
2. **Before Merging:** Ensure UI consistency
3. **Design Updates:** Update goldens after intentional changes

**Golden Files Location:**
```
test/golden/goldens/
├── agora_video_call_screen_waiting_room.png
├── agora_video_call_screen_controls.png
└── agora_video_call_screen_appointment_info.png
```

**Best Practices:**
- Review diffs carefully before updating goldens
- Commit golden files to version control
- Run on consistent platform (CI/CD recommended)

---

### 4. Documentation 📚

**Migration Guides:**
- `TASK_18_COMPLETION_REPORT.md` - Complete migration report
- `TASK_18_SUBTASK_18.1_COMPLETION.md` - withOpacity migration
- `TASK_18_SUBTASK_18.2_COMPLETION.md` - Radio migration
- `test/golden/README.md` - Golden tests guide

**Quick Reference:**

| Deprecated API | Current API | Example |
|----------------|-------------|---------|
| `Color.withOpacity(0.5)` | `Color.withValues(alpha: 0.5)` | `Colors.white.withValues(alpha: 0.1)` |
| `Radio(groupValue:, onChanged:)` | `RadioGroup(groupValue:, onChanged:, child:)` | See TASK_18_SUBTASK_18.2_COMPLETION.md |

---

## Monitoring & Maintenance

### Regular Checks

**Weekly:**
- Review CI/CD workflow results
- Check for any bypassed commits (`--no-verify`)

**Monthly:**
- Run full analyzer check: `flutter analyze`
- Review Flutter changelog for new deprecations
- Update prevention mechanisms if needed

**Quarterly:**
- Review and update golden tests
- Update documentation
- Train team on prevention mechanisms

### Metrics to Track

| Metric | Target | Current |
|--------|--------|---------|
| Deprecated warnings in source code | 0 | 0 ✅ |
| Pre-commit hook success rate | 100% | N/A (not yet tracked) |
| CI/CD check pass rate | 100% | N/A (not yet tracked) |
| Golden test pass rate | 100% | N/A (not yet tracked) |

---

## Team Guidelines

### For Developers

**Before Committing:**
1. Run `flutter analyze lib/` locally
2. Fix any deprecated warnings
3. Run tests: `flutter test`
4. Commit (pre-commit hook will verify)

**When Adding New Code:**
1. Use current APIs (check Flutter documentation)
2. Avoid deprecated APIs (IDE will show warnings)
3. If unsure, check migration guides

**If Pre-Commit Hook Fails:**
1. Review the error message
2. Check which file has deprecated API
3. Refer to migration guides
4. Fix the issue
5. Try committing again

**Never:**
- Use `--no-verify` to bypass hooks (except emergencies)
- Ignore deprecated warnings
- Update goldens without reviewing diffs

### For Code Reviewers

**PR Review Checklist:**
- [ ] CI/CD checks passing (green checkmark)
- [ ] No deprecated API warnings
- [ ] Golden tests passing (if UI changes)
- [ ] Migration patterns followed (if API changes)

**If CI/CD Fails:**
1. Review the analysis results artifact
2. Request changes from author
3. Don't merge until fixed

### For Team Leads

**Responsibilities:**
1. Ensure hooks are set up for all team members
2. Monitor CI/CD workflow results
3. Update prevention mechanisms as needed
4. Train new team members

**When Flutter Updates:**
1. Check Flutter changelog for new deprecations
2. Plan migration if needed
3. Update prevention mechanisms
4. Communicate to team

---

## Troubleshooting

### Pre-Commit Hook Not Running

**Symptoms:** Commits succeed even with deprecated APIs

**Solutions:**

1. **Check hook configuration:**
   ```bash
   git config core.hooksPath
   # Expected: .githooks
   ```

2. **Re-run setup:**
   ```bash
   bash .githooks/setup.sh  # Unix/Linux/macOS
   .githooks\setup.bat      # Windows
   ```

3. **Check hook is executable (Unix/Linux/macOS):**
   ```bash
   ls -la .githooks/pre-commit
   # Should show: -rwxr-xr-x
   ```

4. **Verify git is initialized:**
   ```bash
   ls -la .git
   # Should exist
   ```

### CI/CD Check Not Running

**Symptoms:** Workflow doesn't trigger on push/PR

**Solutions:**

1. **Check workflow file exists:**
   ```bash
   ls -la .github/workflows/deprecated-api-check.yml
   ```

2. **Verify branch names match:**
   - Workflow triggers on `main` and `develop`
   - Update if your branches are named differently

3. **Check GitHub Actions is enabled:**
   - GitHub repo → Settings → Actions → Allow all actions

### Golden Tests Failing

**Symptoms:** Golden tests fail with visual differences

**Solutions:**

1. **Review diff images:**
   ```bash
   # Check test/failures/ directory
   ls test/failures/
   ```

2. **If change is intentional:**
   ```bash
   flutter test --update-goldens test/golden/
   git add test/golden/goldens/
   git commit -m "Update golden files after UI change"
   ```

3. **If change is unintentional:**
   - Investigate the code change
   - Fix the issue
   - Re-run tests

4. **Platform differences:**
   - Run tests on same platform consistently
   - Use CI/CD for consistent environment

---

## Future Enhancements

### Planned Improvements

1. **Automated Metrics Dashboard**
   - Track deprecated warning trends
   - Monitor hook bypass attempts
   - Visualize CI/CD pass rates

2. **IDE Integration**
   - Real-time deprecated API detection
   - Quick-fix suggestions
   - Migration pattern snippets

3. **Automated Migration Tools**
   - Scripts to auto-migrate common patterns
   - Batch update tools
   - Validation scripts

4. **Enhanced Golden Tests**
   - More screen coverage
   - Automated golden generation
   - Visual diff reports in PRs

### Contribution

To improve prevention mechanisms:

1. Identify gaps or issues
2. Propose improvements
3. Implement and test
4. Update documentation
5. Train team

---

## References

### Internal Documentation

- [TASK_18_COMPLETION_REPORT.md](TASK_18_COMPLETION_REPORT.md) - Complete migration report
- [TASK_18_IMPLEMENTATION_PLAN.md](.kiro/specs/code-quality-and-testing-improvement/TASK_18_IMPLEMENTATION_PLAN.md) - Implementation plan
- [test/golden/README.md](test/golden/README.md) - Golden tests guide

### External Resources

- [Flutter Deprecation Policy](https://docs.flutter.dev/release/breaking-changes)
- [Git Hooks Documentation](https://git-scm.com/docs/githooks)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Golden Toolkit](https://pub.dev/packages/golden_toolkit)

---

## Contact

For questions or issues with prevention mechanisms:

- **Technical Issues:** Check troubleshooting section above
- **Process Questions:** Contact team lead
- **Suggestions:** Create an issue or PR

---

**Document Version:** 1.0  
**Last Updated:** 2026-02-16  
**Next Review:** 2026-05-16 (Quarterly)  
**Maintained by:** AndroCare360 Development Team
