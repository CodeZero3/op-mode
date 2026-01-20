# Final Report Template

Use this template when presenting the completion report to the user (User Touchpoint 2).

---

## Template

```markdown
## OP Mode Completion Report

### Task Completed
{original_task_description}

### Status: {SUCCESS | PARTIAL | ISSUES_NOTED}

---

### Implementation Summary

{2-3_paragraph_overview_of_what_was_built}

### Changes Made

| File | Type | Description |
|------|------|-------------|
| `{path/file.ts}` | MODIFIED | {what_changed} |
| `{path/new.ts}` | CREATED | {what_it_does} |
| `{path/old.ts}` | DELETED | {why_removed} |

### Test Results

#### Generated Tests
| Test | Type | Result |
|------|------|--------|
| `{test_name}` | Happy Path | PASS |
| `{test_name}` | Edge Case | PASS |
| `{test_name}` | Edge Case | PASS |

#### Existing Test Suites
| Suite | Passed | Failed |
|-------|--------|--------|
| Unit Tests | {n} | 0 |
| Integration | {n} | 0 |
| E2E | {n} | 0 |

### Build Verification

- TypeScript: PASS
- Lint: PASS
- Build: PASS

### Visual Validation

{For UI changes:}
**Screenshots captured at:**
- Desktop view: {description}
- Mobile view: {description}

**Browser Console**: Clean (no errors)

{For non-UI changes:}
N/A - No UI changes in this task

---

### Decisions Made During Implementation

| Decision | Category | Authority | Rationale |
|----------|----------|-----------|-----------|
| {D1} | Technical | Auto | {why} |
| {D2} | Technical | Auto | {why} |

{If any decisions were queued for user:}

**Decisions Made With Your Input:**
| Decision | Your Guidance | Outcome |
|----------|--------------|---------|
| {D3} | {what_you_said} | {how_implemented} |

---

### Issues Encountered

{If issues resolved:}

#### Resolved Issues
| Issue | Attempts | Resolution |
|-------|----------|------------|
| {issue} | 2 | {what_fixed_it} |

{If known issues remain:}

#### Known Issues (Non-Blocking)
| Issue | Workaround | Tracked In |
|-------|------------|------------|
| {issue} | {workaround} | Linear #{id} |

{If no issues:}

No issues encountered during implementation.

---

### Session Statistics

| Metric | Value |
|--------|-------|
| Total Tasks | {n} |
| Files Changed | {n} |
| Tests Generated | 3 |
| MCP Calls | {n} |
| Issues Encountered | {n} |
| Issues Resolved | {n} |
| Iteration Escalations | {n} |

---

### Documentation Updated

- [ ] Decision tree finalized
- [ ] Issues logged (if any)
- [ ] MCP interactions logged
- [ ] Patterns saved to history

---

### Ready for Your Review

All tests pass and the implementation is complete.

**Next Steps:**
1. Review the changes in your IDE
2. Test the feature manually if desired
3. Approve to close this session

**Questions?** Let me know if you'd like more detail on any aspect.
```

---

## Partial Success Template

When task is partially complete:

```markdown
## OP Mode Completion Report

### Task: {original_task}
### Status: PARTIAL

---

### Completed
- {what_was_completed}
- {tests_that_pass}

### Not Completed
| Item | Reason | Logged |
|------|--------|--------|
| {item} | {blocking_issue} | Linear #{id} |

### Blocking Issues

#### ISSUE-{ID}: {Title}
**Attempts**: 4 (escalated)
**Root Cause**: {analysis}
**Recommendation**: {suggested_path_forward}

### Options

1. **Accept Partial** - Use what's complete, track remaining
2. **Manual Fix** - You resolve the blocker, I continue
3. **Redesign** - New approach to avoid the issue

What would you like to do?
```

---

## Success with Known Issues Template

```markdown
## OP Mode Completion Report

### Task: {original_task}
### Status: SUCCESS (with known issues)

---

### Implementation Complete

{summary_of_what_works}

### Known Issues

These are non-blocking and won't affect primary functionality:

| Issue | Impact | Workaround | Tracking |
|-------|--------|------------|----------|
| {issue} | {minimal/edge case} | {how_to_work_around} | Linear #{id} |

### Recommendation

Proceed with deployment. Known issues are logged for future resolution and have workarounds in place.

**Approve?**
```

---

## Metrics Summary Block

Include in all final reports:

```markdown
### Performance Metrics

| Phase | Duration | Notes |
|-------|----------|-------|
| Planning | {time} | {note} |
| Implementation | {time} | {tasks_completed} |
| Review | {time} | {reviewers_used} |
| Testing | {time} | {tests_run} |
| Total | {time} | - |

### Token Efficiency

| Resource | Usage |
|----------|-------|
| Memory Tier Loads | {INDEX: n, SUMMARY: n, DETAIL: n} |
| RLM Queries | {n} |
| Cache Hits | {n} |
```
