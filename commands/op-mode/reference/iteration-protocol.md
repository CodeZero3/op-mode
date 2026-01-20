# OP Mode Iteration Limit Protocol

## Overview

This protocol defines how OP Mode handles repeated failures during implementation. The goal is to prevent infinite loops while ensuring issues are properly tracked and escalated.

---

## Attempt Limits

| Issue Type | Max Attempts | Escalation Path |
|------------|--------------|-----------------|
| Bug fix | 4 | Linear → Subagent Team → User |
| Integration | 4 | Subagent Team → Linear → User |
| Logic error | 4 | Subagent Team → Linear → User |
| Performance | 3 | Subagent Team → User |
| Type error | 3 | Auto-resolve or skip |

---

## Attempt Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     ATTEMPT 1                                │
│  Try initial solution based on analysis                      │
└────────────────────────┬────────────────────────────────────┘
                         │ Failed
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     ATTEMPT 2                                │
│  Try alternative approach                                    │
│  - Different algorithm                                       │
│  - Different library                                         │
│  - Restructured logic                                        │
└────────────────────────┬────────────────────────────────────┘
                         │ Failed
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     ATTEMPT 3                                │
│  Consult subagent team                                       │
│  - bug-hunter: Root cause analysis                           │
│  - backend-reviewer: Logic review                            │
│  - frontend-reviewer: UI/state review                        │
│  - Apply team recommendation                                 │
└────────────────────────┬────────────────────────────────────┘
                         │ Failed
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     ATTEMPT 4                                │
│  Final attempt with full team input                          │
│  - All reviewers consulted                                   │
│  - Best collective recommendation applied                    │
└────────────────────────┬────────────────────────────────────┘
                         │ Failed
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     ESCALATE                                 │
│  1. Log to Linear (if available)                             │
│  2. Classify: BLOCKING or NON-BLOCKING                       │
│  3. Route based on classification                            │
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
