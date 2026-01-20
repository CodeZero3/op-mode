# Escalation Report Template

Use this template when an issue has reached 4 failed attempts and must be escalated.

---

## For Linear Integration

```markdown
## OP Mode Escalation: {Issue Title}

### Summary
{One line description of the issue}

### Context
- **Session**: {session_id}
- **Original Task**: {task_description}
- **Phase**: {current_phase}
- **Blocking**: {YES | NO}

### Issue Details

**Description**:
{Detailed description of what's failing}

**Expected Behavior**:
{What should happen}

**Actual Behavior**:
{What is happening instead}

### Attempts Made

#### Attempt 1 - {timestamp}
**Approach**: {description}
**Result**: FAILED
**Error**:
```
{error_output}
```
**Learning**: {what_we_learned}

#### Attempt 2 - {timestamp}
**Approach**: {alternative_approach}
**Result**: FAILED
**Error**:
```
{error_output}
```
**Learning**: {what_we_learned}

#### Attempt 3 - {timestamp}
**Team Consulted**: {bug-hunter, backend-reviewer, etc.}
**Their Analysis**: {what_team_found}
**Recommended Fix**: {their_suggestion}
**Result**: FAILED
**Error**:
```
{error_output}
```

#### Attempt 4 - {timestamp}
**Full Team Input**: {collective_recommendation}
**Result**: FAILED
**Final Error**:
```
{error_output}
```

### Root Cause Analysis

**Hypothesis**:
{Our best understanding of why this is failing}

**Evidence**:
- {supporting_evidence_1}
- {supporting_evidence_2}

**Uncertainty**:
{What we're not sure about}

### Files Involved

| File | Relevance |
|------|-----------|
| `{path/file.ts}` | {why_relevant} |
| `{path/file.ts}` | {why_relevant} |

### Environment

- Node Version: {version}
- Framework: {Next.js version, etc.}
- Database: {Supabase, etc.}
- Relevant Dependencies: {list}

### Workaround

{If available:}
**Available**: YES
**Description**: {how_to_work_around}
**Limitations**: {what_workaround_doesn't_cover}

{If not available:}
**Available**: NO
**Impact**: {what_this_blocks}

### Recommended Next Steps

1. {step_1}
2. {step_2}
3. {step_3}

### Labels

- `op-mode-escalation`
- `{category}` (bug, integration, performance, etc.)
- `{priority}` (urgent if blocking, medium otherwise)
```

---

## For User Presentation (Blocking)

```markdown
## Implementation Paused: Issue Escalation

### What Happened

While implementing **{task_description}**, I encountered an issue that I couldn't resolve after 4 attempts.

### The Issue

**{Issue Title}**

{2-3 sentence explanation in plain language}

### What I Tried

1. **{Approach 1}** - {brief result}
2. **{Approach 2}** - {brief result}
3. **Consulted team** - {bug-hunter, reviewers}. They suggested {suggestion}, but {result}
4. **Full team analysis** - {outcome}

### My Assessment

{1-2 sentences about root cause hypothesis}

### Impact

This issue **blocks** the following:
- {blocked_item_1}
- {blocked_item_2}

### Your Options

1. **Provide guidance** - If you have insight into this issue, I can try again
2. **Manual fix** - You resolve it, then I continue
3. **Reduce scope** - Remove the blocked feature from this session
4. **Escalate externally** - Log to Linear/GitHub for later resolution

**What would you like to do?**
```

---

## For User Presentation (Non-Blocking)

```markdown
## Note: Issue Logged as Known Issue

### Quick Summary

During implementation, I encountered an issue that I couldn't fully resolve. However, it's **non-blocking** and I've continued with the rest of the task.

### The Issue

**{Issue Title}**

{Brief explanation}

### Why It's Non-Blocking

- Primary functionality works
- Issue only affects: {edge_case_description}
- Workaround available: {workaround}

### What I Did

- Logged to Linear: #{issue_number}
- Documented workaround
- Continued with implementation

### FYI Only

No action needed from you right now. This will be tracked for future resolution.

{Continue with rest of implementation update}
```

---

## Linear Issue Labels

Use these labels when creating Linear issues:

| Label | When to Use |
|-------|-------------|
| `op-mode-escalation` | Always for OP Mode escalations |
| `blocking` | Issue blocks implementation |
| `non-blocking` | Issue doesn't block, workaround exists |
| `bug` | Defect in existing code |
| `integration` | Third-party or service integration issue |
| `logic` | Business logic error |
| `performance` | Performance-related issue |
| `type-error` | TypeScript/type system issue |
| `needs-investigation` | Root cause unclear |
| `has-workaround` | Workaround documented |

---

## Priority Mapping

| Situation | Linear Priority |
|-----------|-----------------|
| Blocking + No Workaround | Urgent (1) |
| Blocking + Has Workaround | High (2) |
| Non-Blocking + Affects UX | Medium (3) |
| Non-Blocking + Edge Case | Low (4) |
