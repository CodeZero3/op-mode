# OP Mode Session Template

## Session Initialization

When starting a new OP Mode session, create this structure:

```
.uop/sessions/{session-id}/
├── PLAN.md
├── DECISION_TREE.md
├── ISSUES.md
├── MCP_LOG.md
└── VALIDATION.md
```

---

## PLAN.md Template

```markdown
# OP Mode Plan - {Session ID}

**Created**: {timestamp}
**Task**: {original_task_description}
**Complexity**: {SIMPLE|MEDIUM|COMPLEX}

## Summary

{2-3 sentence overview}

## Approach

1. {step_1}
2. {step_2}
3. {step_3}

## Files Affected

| File | Action | Description |
|------|--------|-------------|
| {path} | CREATE/MODIFY/DELETE | {what_changes} |

## Dependencies

- {dependency_1}
- {dependency_2}

## RLM Context

### Relevant History
{patterns_or_decisions_from_history}

### Potential Conflicts
{any_historical_issues_to_watch}

## Approval Status

- [ ] User Approved
- [ ] Approved With Modifications: {modifications}

---

**Approved By**: {user}
**Approved At**: {timestamp}
```

---

## DECISION_TREE.md Template

```markdown
# Decision Tree - {Session ID}

**Session**: {session_id}
**Created**: {timestamp}

## Baseline Decisions

Decisions made during planning, approved by user:

| ID | Decision | Rationale | Status |
|----|----------|-----------|--------|
| D1 | {decision_1} | {why_1} | APPROVED |
| D2 | {decision_2} | {why_2} | APPROVED |

## Implementation Decisions

Decisions made during autonomous implementation:

| ID | Decision | Category | Authority | Timestamp |
|----|----------|----------|-----------|-----------|
| D3 | {decision} | Technical | Auto | {time} |

## Queued for User

Decisions requiring user approval:

### {Decision Title}
- **ID**: D{n}
- **Category**: {Design|Scope|Architecture}
- **Current Plan**: {what_was_planned}
- **Proposed**: {what_we_want}
- **Reason**: {why}
- **Impact**: {effects}
- **Status**: PENDING

## Change History

| Timestamp | Decision | From | To | Reason | Validated |
|-----------|----------|------|----|--------|-----------|
| {time} | D1 | {old} | {new} | {why} | Auto/User |

## Decision Links

Cross-reference to issues and implementation:

| Decision | Related Issues | Files Affected |
|----------|---------------|----------------|
| D1 | ISSUE-001 | src/file.ts |
```

---

## ISSUES.md Template

```markdown
# Issues Log - {Session ID}

**Session**: {session_id}
**Last Updated**: {timestamp}

## Summary

| Status | Count |
|--------|-------|
| Resolved | {n} |
| Active | {n} |
| Escalated | {n} |
| Known Issues | {n} |

## Active Issues

### ISSUE-{ID}: {Title}

**Status**: ATTEMPTING (2/4)
**Blocking**: YES | NO
**Category**: BUG | INTEGRATION | LOGIC | PERFORMANCE
**Decision Link**: D{n}
**Assigned**: {agent}

#### Attempts

**Attempt 1** - {timestamp}
- Approach: {description}
- Result: FAILED
- Error: {error}

**Attempt 2** - {timestamp}
- Approach: {description}
- Result: FAILED
- Learnings: {insights}

---

## Resolved Issues

### ISSUE-{ID}: {Title}

**Resolved**: {timestamp}
**Resolution**: {what_fixed_it}
**Attempts**: {n}
**Solver**: {agent_name}

---

## Known Issues (Continuing)

### ISSUE-{ID}: {Title}

**Status**: KNOWN_ISSUE
**Blocking**: NO
**Workaround**: {description}
**Logged To**: Linear #{id} | GitHub #{id}
**Impact**: {description}
```

---

## MCP_LOG.md Template

```markdown
# MCP Interaction Log - {Session ID}

**Session**: {session_id}
**Started**: {timestamp}

## Tags Index

Quick scan reference:

| Tag | Count | Last Used |
|-----|-------|-----------|
| DB-READ | {n} | {time} |
| DB-WRITE | {n} | {time} |
| UI-CHECK | {n} | {time} |

## Interactions

### {timestamp}

**[{TAG}]** `{tool_name}`

**Input Summary**:
{condensed_input}

**Result Summary**:
{condensed_result}

**Context**:
{why_this_was_called}

---

### {timestamp}

**[{TAG}]** `{tool_name}`

...

## Session Summary

| Tool Category | Calls | Success | Failed |
|---------------|-------|---------|--------|
| Supabase | {n} | {n} | {n} |
| Stripe | {n} | {n} | {n} |
| Playwright | {n} | {n} | {n} |
| Context7 | {n} | {n} | {n} |
```

---

## VALIDATION.md Template

```markdown
# Validation Report - {Session ID}

**Session**: {session_id}
**Completed**: {timestamp}

## Test Results

### Generated Tests

| Test Name | Type | Status | Duration |
|-----------|------|--------|----------|
| {test_1} | Happy Path | PASS | {ms} |
| {test_2} | Edge Case | PASS | {ms} |
| {test_3} | Edge Case | PASS | {ms} |

### Existing Tests

| Suite | Passed | Failed | Skipped |
|-------|--------|--------|---------|
| Unit | {n} | {n} | {n} |
| Integration | {n} | {n} | {n} |
| E2E | {n} | {n} | {n} |

## Build Validation

- [ ] TypeScript compilation: PASS
- [ ] Lint check: PASS
- [ ] Build successful: PASS

## Visual Validation

### Screenshots

{screenshot_descriptions_or_links}

### Browser Console

- [ ] No errors
- [ ] No warnings (or acceptable warnings listed)

### Responsive Check

| Breakpoint | Status |
|------------|--------|
| Mobile (375px) | PASS |
| Tablet (768px) | PASS |
| Desktop (1280px) | PASS |

## Pre-Return Checklist

- [ ] All generated tests pass
- [ ] No TypeScript errors
- [ ] No linting errors
- [ ] UI renders correctly
- [ ] No console errors
- [ ] Decision tree updated
- [ ] Issues documented
- [ ] MCP log complete

## Final Status

**READY FOR USER REVIEW**
```

---

## INDEX.md Update Template

When session completes, update `.uop/INDEX.md`:

```markdown
## Recent Sessions

| Session | Date | Task | Status | Key Learnings |
|---------|------|------|--------|---------------|
| {id} | {date} | {task} | Complete | {learnings} |

## Pattern Updates

| Pattern | Source Session | Description |
|---------|----------------|-------------|
| {name} | {session_id} | {what_learned} |

## Decision Precedents

| Area | Decision | Session | Rationale |
|------|----------|---------|-----------|
| {area} | {decision} | {id} | {why} |
```
