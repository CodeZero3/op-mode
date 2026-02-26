# OP Mode Iteration Limit Protocol

## Overview

This protocol defines how OP Mode handles repeated failures during implementation. The goal is to prevent infinite loops while ensuring issues are properly tracked and escalated.

---

## Attempt Limits

### Maximum Attempts Per Issue: **3** (Previously 4)

**Attempt 1:** Apply the most obvious fix based on the error message.

**Attempt 2:** Step back. Re-read the error. Check if the fix attempt changed the error or just moved it. Try a different approach.

**Attempt 3:** This is the last attempt. If this fails, **STOP**.

---

## After 3 Failed Attempts — MANDATORY STOP

**DO NOT attempt a 4th fix.** Instead:

### 1. Frame it as architectural:

"This is not a bug. This is an architectural problem that requires a different approach."

### 2. Document what was tried:

| Attempt | What Was Tried | Result |
|---------|---------------|--------|
| 1 | {description} | {error} |
| 2 | {description} | {error} |
| 3 | {description} | {error} |

### 3. Present to user with options:

- **Option A:** Redesign the approach (go back to Phase 3)
- **Option B:** Defer this item and continue with other tasks
- **Option C:** Escalate to human developer with handoff package

### 4. Log to `.uop/sessions/{id}/ISSUES.md`:

```markdown
Status: BLOCKED_ARCHITECTURAL
Attempts: 3/3
Pattern: {what class of problem this is}
```

---

## Circular Fix Detection

If the current fix attempt is **>70% similar to a previous attempt** (same files, same lines, same type of change) → **STOP IMMEDIATELY**.

Do not count this as an attempt. Flag it:

```
"I'm going in circles. The same fix keeps being tried and reverted.
This needs a fundamentally different approach."
```

---

## The Key Mindset Shift

**3 failures on the same issue means:**

- The error message is misleading, OR
- The root cause is deeper than the symptom, OR
- The architecture doesn't support what you're trying to do

**In ALL three cases, more patching makes it worse.**

---

## Attempt Flow (Updated for 3-Failure Stop)

```
┌─────────────────────────────────────────────────────────────┐
│                     ATTEMPT 1                                │
│  Try initial solution based on error analysis                │
└────────────────────────┬────────────────────────────────────┘
                         │ Failed
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     ATTEMPT 2                                │
│  Step back and try a different approach                      │
│  - Different algorithm or pattern                            │
│  - Different library or method                               │
│  - Restructured logic                                        │
│  Check: Did the error change or just move?                   │
└────────────────────────┬────────────────────────────────────┘
                         │ Failed
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     ATTEMPT 3 (FINAL)                        │
│  Consult subagent team for fresh perspective                 │
│  - bug-hunter: Root cause analysis                           │
│  - reviewer: Architecture/logic review                       │
│  - Apply team recommendation                                 │
│  Check for circular fix (>70% similarity to previous)        │
└────────────────────────┬────────────────────────────────────┘
                         │ Failed
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                ARCHITECTURAL STOP (NO ATTEMPT 4)             │
│  1. Frame as architectural problem                           │
│  2. Document all 3 attempts                                  │
│  3. Present options A/B/C to user                            │
│  4. Log as BLOCKED_ARCHITECTURAL                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Attempt Documentation

### Issue Entry Format

```markdown
### ISSUE-{ID}: {Title}

**Status**: ATTEMPTING | ESCALATED | RESOLVED | KNOWN_ISSUE
**Blocking**: YES | NO
**Category**: BUG | INTEGRATION | LOGIC | PERFORMANCE | TYPE
**Assigned**: {agent_or_user}
**Decision Link**: {D#}

#### Attempts

**Attempt 1** - {timestamp}
- Approach: {what_was_tried}
- Result: {outcome}
- Error: {error_message_if_any}

**Attempt 2** - {timestamp}
- Approach: {alternative_approach}
- Result: {outcome}
- Learnings: {what_we_learned}

**Attempt 3** - {timestamp}
- Team Consulted: {which_reviewers}
- Recommendation: {their_suggestion}
- Result: {outcome}

**Attempt 4** - {timestamp}
- Full Team Input: {collective_recommendation}
- Result: {outcome}

#### Escalation (if reached)
- **Linear Issue**: {url_if_created}
- **Classification**: BLOCKING | NON-BLOCKING
- **Workaround**: {if_available}
- **Impact**: {what_this_affects}
```

---

## Blocking vs Non-Blocking

### BLOCKING Issues

Criteria:
- Prevents core feature from working
- Blocks user workflow completion
- Creates data integrity risk
- Security vulnerability

Action:
1. Stop implementation immediately
2. Log to Linear with "urgent" priority
3. Prepare escalation report
4. Present to user with options

### NON-BLOCKING Issues

Criteria:
- Edge case failure only
- Cosmetic issue
- Non-critical path affected
- Workaround available

Action:
1. Log as known issue
2. Document workaround
3. Log to Linear with "medium" priority
4. Continue implementation
5. Include in final report

---

## Linear Integration

### When Available

```javascript
// Create issue in Linear
mcp__linear__create_issue({
  title: `OP Mode: ${issue_summary}`,
  description: escalation_report,
  labels: ["op-mode", category, blocking ? "urgent" : "backlog"],
  priority: blocking ? 1 : 3,
  project: current_project_id
})
```

### Issue Template

```markdown
## OP Mode Escalation

### Issue Summary
{one_line_description}

### Context
- Session: {session_id}
- Task: {original_task}
- Phase: {current_phase}

### Attempts Made
1. {attempt_1_summary}
2. {attempt_2_summary}
3. {attempt_3_summary}
4. {attempt_4_summary}

### Error Details
```
{error_output}
```

### Root Cause Hypothesis
{analysis_of_likely_cause}

### Files Involved
- {file_1}
- {file_2}

### Recommended Next Steps
1. {step_1}
2. {step_2}

### Workaround (if available)
{workaround_description}
```

### When Linear Not Available

1. Log to `.uop/sessions/{session-id}/ISSUES.md`
2. Add to project's issue tracking (GitHub Issues, etc.)
3. Include prominently in final report

---

## Subagent Team Consultation

### At Attempt 3

Consult relevant reviewers based on issue type:

| Issue Type | Primary Reviewer | Secondary |
|------------|------------------|-----------|
| Logic bug | bug-hunter | backend-reviewer |
| UI issue | bug-hunter | frontend-reviewer |
| API error | backend-reviewer | bug-hunter |
| State issue | frontend-reviewer | bug-hunter |
| Performance | performance-opt | backend-reviewer |
| Security | security-analyzer | backend-reviewer |

### Consultation Format

```
Task(
  subagent_type="{reviewer}",
  prompt="Review failing implementation:

Issue: {description}
Attempts Made:
1. {attempt_1}
2. {attempt_2}

Error:
{error_details}

Files:
{relevant_files}

Question: What is the root cause and recommended fix?"
)
```

---

## Recovery Actions

### After Escalation

If BLOCKING:
1. Revert to last working state
2. Document what was attempted
3. Present clear options to user:
   - Continue with workaround
   - Pause for manual fix
   - Reduce scope

If NON-BLOCKING:
1. Document known issue
2. Implement workaround if available
3. Continue with remaining tasks
4. Track for future resolution

---

## Metrics Tracking

Track for session summary:

```markdown
## Iteration Metrics

| Metric | Value |
|--------|-------|
| Total Issues Encountered | {n} |
| Resolved on Attempt 1 | {n} |
| Resolved on Attempt 2 | {n} |
| Resolved on Attempt 3 | {n} |
| Resolved on Attempt 4 | {n} |
| Escalated | {n} |
| Blocking Issues | {n} |
| Known Issues (continuing) | {n} |
```

---

## Quick Reference

| Attempt | Action | Who |
|---------|--------|-----|
| 1 | Initial solution | Implementation |
| 2 | Alternative approach | Implementation |
| 3 | Team consultation | Subagent Team |
| 4 | Full team recommendation | All Reviewers |
| 5+ | ESCALATE | Linear → User |
