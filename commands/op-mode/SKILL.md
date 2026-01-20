---
name: op-mode
description: Orchestration Protocol - Unified GSD + RLM + Subagent workflow with MCP integration
argument-hint: "<task-description>"
allowed-tools: [Read, Glob, Grep, Bash, Task, TodoWrite, Write, Edit, WebFetch, WebSearch, mcp__plugin_supabase_supabase__*, mcp__plugin_stripe_stripe__*, mcp__plugin_playwright_playwright__*]
---

# OP Mode: Orchestration Protocol

**Unified workflow combining GSD planning, RLM analysis, Subagent execution, and MCP integration.**

## Core Principles

1. **Two User Touchpoints Only**: Plan Approval + Final Validation
2. **Autonomous Implementation**: Subagent team handles technical decisions
3. **RLM as Active Partner**: Queries history, participates in planning
4. **Living Documentation**: Auto-updates with every decision
5. **Iteration Limits**: 4 attempts max, then escalate

---

## Memory Structure

```
.uop/
├── INDEX.md                    # 500 token quick reference (RLM scans first)
├── sessions/
│   └── {session-id}/
│       ├── PLAN.md             # Approved plan
│       ├── DECISION_TREE.md    # Living decisions document
│       ├── ISSUES.md           # Issue tracking with solutions
│       ├── MCP_LOG.md          # Tagged MCP interactions
│       └── VALIDATION.md       # Test results and final report
├── history/
│   ├── decisions/              # Past decision summaries
│   ├── issues/                 # Resolved issue patterns
│   └── patterns/               # Learned codebase patterns
└── summaries/
    └── {topic}.md              # 1000 token topic summaries
```

### Tiered Memory Protocol

| Tier | Token Budget | When to Load |
|------|--------------|--------------|
| INDEX | 500 | Always first - contains pointers |
| SUMMARY | 1000 each | When INDEX indicates relevance |
| DETAIL | On demand | Only for active implementation |

---

## Context Window Management (Harvard Protocol)

### Core Principle: Fresh Context + External Memory

**The main Claude instance should operate with minimal context.**
RLM serves as external memory - storing, retrieving, and summarizing information so the main agent can work efficiently.

### Why Fresh Context Matters

1. **Reduced hallucination** - Less old context = fewer conflicting signals
2. **Better focus** - Current task gets full attention
3. **Faster responses** - Smaller context = faster processing
4. **Cleaner decisions** - No stale assumptions bleeding through

### Context Budget Rules

| Content Type | Keep in Context | Offload to RLM |
|--------------|-----------------|----------------|
| Current task description | YES | - |
| Active file being edited | YES | - |
| Current phase/status | YES | - |
| Approved plan summary | YES (compressed) | Full plan in .uop/ |
| Historical decisions | NO | .uop/history/decisions/ |
| Past issues/solutions | NO | .uop/history/issues/ |
| Codebase patterns | NO | .uop/history/patterns/ |
| MCP interaction details | NO | .uop/sessions/MCP_LOG.md |
| Completed task details | NO | Session files |

### Store-Before-Clear Protocol

Before any context-heavy operation completes, **always store first**:

```python
def complete_phase(phase_name, results):
    # 1. STORE to RLM memory
    write_to_session_file(f".uop/sessions/{session_id}/{phase_name}.md", results)

    # 2. UPDATE INDEX with pointer
    update_index(f"Phase {phase_name} complete - see sessions/{session_id}/")

    # 3. COMPRESS for carry-forward
    summary = compress_to_summary(results, max_tokens=200)

    # 4. CLEAR detailed context (implicit - just don't reference it)
    return summary  # Only summary carries forward
```

### RLM as Memory Manager

RLM's role in context management:

```
┌─────────────────────────────────────────────────────────────┐
│                    MAIN CLAUDE AGENT                         │
│  • Current task focus                                        │
│  • Active decisions                                          │
│  • Minimal context (~2000 tokens working memory)            │
└────────────────────────┬────────────────────────────────────┘
                         │
        Store ↓          │           ↑ Retrieve
                         │
┌────────────────────────┴────────────────────────────────────┐
│                    RLM MEMORY LAYER                          │
│  .uop/                                                       │
│  ├── INDEX.md          ← Always check first                 │
│  ├── sessions/         ← Current work state                 │
│  ├── history/          ← Past patterns & decisions          │
│  └── summaries/        ← Compressed topic knowledge         │
└─────────────────────────────────────────────────────────────┘
```

### When to Query RLM (Retrieve)

| Trigger | RLM Query |
|---------|-----------|
| Starting new task | "What patterns exist for {task_area}?" |
| Hitting unexpected error | "Have we seen {error_type} before?" |
| Making architectural decision | "What past decisions affect {component}?" |
| Before implementing feature | "What issues occurred with similar features?" |
| Context feels stale | "Summarize current session state" |

### When to Store to RLM

| Event | What to Store | Where |
|-------|---------------|-------|
| Phase complete | Phase summary + key decisions | sessions/{id}/ |
| Issue resolved | Problem + solution + root cause | history/issues/ |
| Decision made | Decision + rationale + context | history/decisions/ |
| Pattern discovered | Pattern + examples + when to use | history/patterns/ |
| MCP interaction | Tagged summary | sessions/{id}/MCP_LOG.md |

### Session Handoff Protocol

For long tasks that may exceed context or require breaks:

```markdown
## Session Handoff - {session_id}

### Current State
- **Phase**: 4 (Implementation)
- **Task**: 3 of 5 complete
- **Active Issue**: None

### What's Done
- [x] API endpoint created
- [x] Database migration applied
- [x] UI component built

### What's Next
- [ ] Wire up frontend
- [ ] Code review pass

### Key Context to Restore
- Using React Query for data fetching (Decision D3)
- Auth token stored in httpOnly cookie (Decision D1)

### Files Modified This Session
- src/api/users.ts (new)
- src/components/UserList.tsx (new)
- prisma/migrations/xxx (new)

### Resume Command
Read .uop/sessions/{session_id}/PLAN.md and continue from Task 4
```

### Context Refresh Points

Force a context refresh (re-read from RLM) at these points:

1. **Start of each phase** - Fresh start with only relevant context
2. **After 10+ tool calls** - Accumulated context may be stale
3. **After any user input** - User guidance may change direction
4. **When stuck (2+ failed attempts)** - Fresh perspective needed
5. **Before final validation** - Clean context for review

### Compression Rules

When carrying information forward, compress aggressively:

| Original | Compressed |
|----------|------------|
| Full PRD (2000 tokens) | "PRD approved: Add OAuth with Google/GitHub, store in profiles table, redirect to /dashboard" (30 tokens) |
| Code review findings (1500 tokens) | "Review: 3 issues fixed (type safety, missing null check, unused import)" (15 tokens) |
| MCP log (1000 tokens) | "MCP: 5 DB queries, 2 schema checks, all successful" (10 tokens) |

### Anti-Patterns to Avoid

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Keeping full PRD in context | Wastes tokens, stale info | Store in .uop, keep 1-line summary |
| Re-reading same file repeatedly | Inefficient, fills context | Read once, store key facts |
| Carrying forward error traces | Noise, confusion | Log to ISSUES.md, clear from context |
| Not storing before phase change | Lost work on context reset | Always store-then-clear |
| Querying RLM for current task | Unnecessary overhead | RLM = history, not current state |

---

## Phase 1: Initialization

### 1.1 Assess Complexity

```
SIMPLE:   Single file, clear scope      → Skip RLM deep scan
MEDIUM:   2-5 files, defined boundaries → RLM targeted scan
COMPLEX:  6+ files, cross-cutting       → Full RLM recursive analysis
```

### 1.2 Load Memory

```bash
# Always start with INDEX
Read(.uop/INDEX.md)

# Check for relevant history
if INDEX mentions related_topic:
    Read(.uop/summaries/{related_topic}.md)
```

### 1.3 RLM Historical Query

For MEDIUM/COMPLEX tasks, RLM queries:

```
Question: "What patterns, decisions, and issues relate to {task_area}?"
Sources:
  - .uop/history/decisions/
  - .uop/history/issues/
  - .uop/history/patterns/
```

---

## Phase 2: Planning (RLM Active Partner)

### 2.1 Generate PRD

```
Task(
  subagent_type="prd-generator",
  prompt="Generate PRD for: {task_description}\n\nHistorical Context:\n{rlm_history_summary}"
)
```

### 2.2 RLM Planning Participation

RLM actively participates by:

1. **Questioning assumptions** based on historical patterns
2. **Identifying conflicts** with past decisions
3. **Suggesting approaches** that worked before
4. **Flagging areas** that caused issues previously

```
# RLM Planning Query
Question: "Review this PRD against codebase patterns. What conflicts, risks, or relevant precedents exist?"
Depth: 2
Chunks: Targeted to affected areas
```

### 2.3 Generate Task List

```
Task(
  subagent_type="task-generator",
  prompt="Convert PRD to tasks:\n{prd_content}\n\nRLM Insights:\n{rlm_planning_insights}"
)
```

### 2.4 Decision Tree Initialization

Create `.uop/sessions/{session-id}/DECISION_TREE.md`:

```markdown
# Decision Tree - {Session ID}

## Baseline Decisions
| ID | Decision | Rationale | Status |
|----|----------|-----------|--------|
| D1 | {decision} | {why} | APPROVED |

## Change Log
| Timestamp | Decision ID | Change | Trigger | Requires PRD |
|-----------|-------------|--------|---------|--------------|
```

---

## Phase 3: Plan Approval (USER TOUCHPOINT 1)

### Present to User

```markdown
## OP Mode Plan Approval Request

### Task Summary
{one_paragraph_summary}

### Approach
{bulleted_approach}

### Files Affected
- {file_path} - {what_changes}

### Key Decisions Made
| Decision | Rationale |
|----------|-----------|
| {D1} | {why} |

### Estimated Complexity
{SIMPLE|MEDIUM|COMPLEX} - {justification}

### RLM Historical Notes
{relevant_patterns_or_warnings}

---
**Approve to proceed?** (Modifications will be autonomous until Final Validation)
```

### User Response Handling

- **Approved**: Proceed to Phase 4
- **Modifications**: Update plan, re-present key changes
- **Rejected**: Archive session, end workflow

---

## Phase 4: Autonomous Implementation

### 4.1 Authority Matrix

| Decision Type | Authority | Action |
|---------------|-----------|--------|
| Technical implementation | Subagent Team | Auto-decide, log |
| Bug fixes during work | Subagent Team | Auto-fix, log |
| Performance optimization | Subagent Team | Auto-optimize, log |
| New dependency | Subagent Team | Evaluate, decide, log |
| Design/UX change | **PAUSE** | Queue for user |
| Scope expansion | **PAUSE** | Queue for user |
| Architecture deviation | **PAUSE** | Queue for user |
| Decision tree conflict | **PAUSE** | Queue for user |

### 4.2 Implementation Loop

```python
for task in task_list:
    # Execute implementation
    result = Task(
        subagent_type="implementation-processor",
        prompt=f"Implement: {task}\nContext: {decision_tree}"
    )

    # Run code review
    reviews = parallel_review(result.files_changed)

    # Handle review findings
    for finding in reviews:
        if finding.severity == "CRITICAL":
            apply_fix(finding)  # Auto-fix
        elif finding.type in ["DESIGN", "UX", "SCOPE"]:
            queue_for_user(finding)  # Pause
        else:
            apply_fix(finding)  # Auto-fix

    # Update documentation
    update_decision_tree(task.decisions)
    update_issues(task.issues)
```

### 4.3 Code Review Pipeline

```
┌─────────────┐
│ Code Change │
└──────┬──────┘
       │
       ├──► frontend-reviewer   → UI/UX issues
       ├──► backend-reviewer    → Logic/API issues
       ├──► security-analyzer   → Security vulnerabilities
       ├──► performance-opt     → Performance issues
       └──► bug-hunter          → Defects
       │
       ▼
┌─────────────────┐
│ Merge Findings  │
└────────┬────────┘
         │
    ┌────┴────┐
    │ PAUSE?  │──► Design/UX/Scope → Queue for User
    └────┬────┘
         │ No
         ▼
┌─────────────────┐
│ Auto-Fix & Log  │
└─────────────────┘
```

---

## Phase 5: Iteration Limit Protocol

### 5.1 Attempt Tracking

```markdown
# .uop/sessions/{session-id}/ISSUES.md

## Active Issues

### ISSUE-001: {description}
- **Status**: ATTEMPTING (2/4)
- **Category**: {BUG|INTEGRATION|LOGIC|PERFORMANCE}
- **Blocking**: {YES|NO}
- **Attempts**:
  1. {approach_1} → {result}
  2. {approach_2} → {result}
- **Decision Link**: D3
- **Assigned**: {subagent_or_user}
```

### 5.2 Escalation Protocol

```
Attempt 1: Try solution
    ↓ Failed
Attempt 2: Try alternative approach
    ↓ Failed
Attempt 3: Consult subagent team for fresh perspective
    ↓ Failed
Attempt 4: Final attempt with team recommendation
    ↓ Failed
ESCALATE:
    - Log to Linear (if available)
    - Classify as BLOCKING or NON-BLOCKING
    - If BLOCKING: Stop, present to user
    - If NON-BLOCKING: Mark known issue, continue
```

### 5.3 Linear Integration (if available)

```
mcp__linear__create_issue({
  title: "OP Mode Escalation: {issue_summary}",
  description: {escalation_report},
  labels: ["op-mode-escalation", "{category}"],
  priority: {blocking ? "urgent" : "medium"}
})
```

### 5.4 Escalation Report Format

```markdown
## Escalation Report

### Issue
{one_line_summary}

### Attempts Made
1. **{approach_1}**: {outcome}
2. **{approach_2}**: {outcome}
3. **Team Consultation**: {recommendation} → {outcome}
4. **Final Attempt**: {outcome}

### Analysis
{root_cause_hypothesis}

### Impact
- **Blocking**: {YES|NO}
- **Affected Features**: {list}
- **Workaround Available**: {YES|NO} - {description}

### Recommendation
{suggested_path_forward}
```

---

## Phase 6: Post-Implementation Validation

### 6.1 Mandatory Test Generation

For every implementation:

```
1. Happy Path Test     - Primary use case works
2. Edge Case Test #1   - Boundary condition
3. Edge Case Test #2   - Error handling / empty state
```

```
Task(
  subagent_type="test-generator",
  prompt="Generate tests for: {implemented_feature}\n\nRequired:\n- 1 happy path\n- 2 edge cases\n\nContext:\n{feature_requirements}"
)
```

### 6.2 Test Execution

```bash
# Run generated tests
npm test -- --testPathPattern="{feature_test_pattern}"

# If UI changes, run Playwright
npx playwright test {feature_e2e_tests}
```

### 6.3 Visual Validation (UI Changes)

```
mcp__plugin_playwright_playwright__browser_navigate({ url: "{local_url}" })
mcp__plugin_playwright_playwright__browser_snapshot()

# Verify:
# - Layout renders correctly
# - Interactive elements work
# - No console errors
# - Responsive behavior (if applicable)
```

### 6.4 Self-Test Checklist

Before returning to user, verify:

```markdown
## Pre-Return Checklist

- [ ] All generated tests pass
- [ ] No TypeScript errors (`npm run build`)
- [ ] No linting errors (`npm run lint`)
- [ ] UI renders correctly (if applicable)
- [ ] No console errors in browser
- [ ] Decision tree updated
- [ ] Issues documented with solutions
- [ ] MCP log complete
```

---

## Phase 7: Final Validation (USER TOUCHPOINT 2)

### Present Final Report

```markdown
## OP Mode Completion Report

### Task Completed
{original_task_description}

### Implementation Summary
{what_was_built}

### Files Changed
| File | Change Type | Description |
|------|-------------|-------------|
| {path} | {ADD|MODIFY|DELETE} | {what} |

### Test Results
| Test | Type | Result |
|------|------|--------|
| {test_name} | Happy Path | PASS |
| {test_name} | Edge Case | PASS |
| {test_name} | Edge Case | PASS |

### Decisions Made During Implementation
| Decision | Rationale | Auto/Queued |
|----------|-----------|-------------|
| {D1} | {why} | Auto |

### Known Issues (if any)
| Issue | Status | Workaround |
|-------|--------|------------|
| {issue} | {status} | {workaround} |

### Visual Validation
{screenshot_or_description}

---
**Ready for your review and approval.**
```

---

## MCP Logging Protocol

### Log Format

```markdown
# .uop/sessions/{session-id}/MCP_LOG.md

## MCP Interaction Log

### Entry Format
```
[{timestamp}] [{TAG}] {tool_name}
  Input: {summarized_input}
  Result: {summarized_result}
  Context: {why_called}
```

### Tags
| Tag | Meaning |
|-----|---------|
| DB-READ | Supabase query |
| DB-WRITE | Supabase mutation |
| DB-SCHEMA | Schema inspection |
| PAY-READ | Stripe query |
| PAY-WRITE | Stripe mutation |
| UI-NAV | Playwright navigation |
| UI-CHECK | Playwright validation |
| UI-ACTION | Playwright interaction |
| DOCS | Documentation lookup |
| LINEAR | Issue tracking |

### Example

```
[2026-01-19T14:30:00] [DB-READ] list_tables
  Input: project_id=xxx, schemas=["public"]
  Result: 12 tables found
  Context: Initial schema discovery for feature planning

[2026-01-19T14:32:00] [DB-SCHEMA] execute_sql
  Input: SELECT column info for profiles table
  Result: 8 columns, RLS enabled
  Context: Understanding user profile structure
```

---

## Decision Tree Management

### Change Detection

When implementation reveals decision needs to change:

```python
def handle_decision_change(old_decision, new_decision, reason):
    # Log the change
    log_to_decision_tree(old_decision, new_decision, reason)

    # Assess impact
    impact = assess_impact(new_decision)

    if impact.scope_change or impact.ux_change:
        # Requires user validation
        queue_for_user({
            "type": "DECISION_CHANGE",
            "old": old_decision,
            "new": new_decision,
            "reason": reason,
            "may_require_new_prd": impact.significant
        })
    else:
        # Auto-approve technical decisions
        auto_approve(new_decision)
```

### Decision Tree Format

```markdown
# Decision Tree - Session {ID}

## Active Decisions

### D1: {Decision Title}
- **Status**: APPROVED | CHANGED | PENDING
- **Original**: {original_decision}
- **Current**: {current_decision}
- **Rationale**: {why}
- **Changed**: {timestamp} - {reason}
- **Impact**: {what_this_affects}

## Change History

| ID | From | To | Reason | Validated By |
|----|------|----|--------|--------------|
| D1 | {old} | {new} | {why} | Auto/User |
```

---

## RLM Auto-Update Protocol

When user provides guidance, RLM automatically updates:

1. **Decision Tree**: New decisions logged
2. **INDEX.md**: Pointers updated if new patterns
3. **history/patterns/**: New patterns saved
4. **Relevant summaries**: Topic summaries refreshed

```python
def on_user_guidance(guidance):
    # Extract decisions and patterns
    decisions = extract_decisions(guidance)
    patterns = extract_patterns(guidance)

    # Update decision tree
    for decision in decisions:
        update_decision_tree(decision)

    # Save patterns for future
    for pattern in patterns:
        save_pattern(pattern)

    # Refresh INDEX if significant
    if len(patterns) > 0:
        refresh_index()
```

---

## Integration Points

### GSD Integration

OP Mode leverages GSD for:
- **Deviation Rules**: Auto-fix bugs, ask about architecture
- **Checkpoint Protocol**: Verify before continuing
- **Debug File Protocol**: Track issue status

### RLM-Coder Integration

OP Mode uses RLM for:
- **Historical Context**: Query past decisions/issues
- **Active Planning**: Participate in PRD review
- **Pattern Recognition**: Identify relevant precedents
- **Documentation Updates**: Maintain living docs

### Subagent Stack Integration

OP Mode coordinates:
- **PRD Generator**: Requirements gathering
- **Task Generator**: Task breakdown
- **Implementation Processor**: Code execution
- **Code Reviewers**: Quality gates

---

## Quick Reference

### Trigger OP Mode

```
/op-mode {task description}
```

### Manual Overrides

```
/op-mode {task} --skip-rlm      # Skip RLM analysis (simple tasks)
/op-mode {task} --force-review  # Force user review at each step
/op-mode {task} --no-tests      # Skip test generation (not recommended)
```

### Status Check

```
/op-mode status                 # Current session status
/op-mode issues                 # View active issues
/op-mode decisions              # View decision tree
```

---

## Success Criteria

Every OP Mode session must:

1. **Load memory efficiently** (INDEX first, then targeted)
2. **Get plan approval** before implementation
3. **Log all MCP interactions** with tags
4. **Maintain decision tree** throughout
5. **Respect iteration limits** (4 max)
6. **Generate mandatory tests** (1 happy + 2 edge)
7. **Validate visually** for UI changes
8. **Present final report** for user approval
9. **Update history** for future sessions

---

## Progress Display Protocol

### CRITICAL: Always Maintain Visible Progress

OP Mode MUST use TodoWrite to maintain a persistent, visible progress tracker that stays on screen throughout the session. This helps both Claude and user track where we are.

### Master Progress Template

At session start, initialize TodoWrite with the full phase outline:

```
TodoWrite([
  { content: "Phase 1: Initialization", status: "in_progress", activeForm: "Initializing OP Mode session" },
  { content: "Phase 2: Planning (RLM + PRD)", status: "pending", activeForm: "Planning with RLM analysis" },
  { content: "Phase 3: Plan Approval [USER]", status: "pending", activeForm: "Awaiting user plan approval" },
  { content: "Phase 4: Implementation", status: "pending", activeForm: "Implementing tasks autonomously" },
  { content: "Phase 5: Issue Resolution", status: "pending", activeForm: "Resolving implementation issues" },
  { content: "Phase 6: Validation & Testing", status: "pending", activeForm: "Validating and testing changes" },
  { content: "Phase 7: Final Report [USER]", status: "pending", activeForm: "Presenting final report for approval" }
])
```

### During Implementation: Expand to Show Sub-Tasks

When entering Phase 4, expand the todo list to show current task detail:

```
TodoWrite([
  { content: "Phase 1: Initialization", status: "completed", activeForm: "Initializing OP Mode session" },
  { content: "Phase 2: Planning (RLM + PRD)", status: "completed", activeForm: "Planning with RLM analysis" },
  { content: "Phase 3: Plan Approval [USER]", status: "completed", activeForm: "Awaiting user plan approval" },
  { content: "Phase 4: Implementation", status: "in_progress", activeForm: "Implementing tasks autonomously" },
  { content: "  └─ Task 1/5: Create API endpoint", status: "completed", activeForm: "Creating API endpoint" },
  { content: "  └─ Task 2/5: Add database migration", status: "in_progress", activeForm: "Adding database migration" },
  { content: "  └─ Task 3/5: Build UI component", status: "pending", activeForm: "Building UI component" },
  { content: "  └─ Task 4/5: Wire up frontend", status: "pending", activeForm: "Wiring up frontend" },
  { content: "  └─ Task 5/5: Code review pass", status: "pending", activeForm: "Running code review" },
  { content: "Phase 5: Issue Resolution", status: "pending", activeForm: "Resolving implementation issues" },
  { content: "Phase 6: Validation & Testing", status: "pending", activeForm: "Validating and testing changes" },
  { content: "Phase 7: Final Report [USER]", status: "pending", activeForm: "Presenting final report for approval" }
])
```

### Status Dashboard in User Prompts

When presenting to user (Plan Approval or Final Report), ALWAYS include status header:

```markdown
╔══════════════════════════════════════════════════════════════╗
║  OP MODE STATUS DASHBOARD                                     ║
╠══════════════════════════════════════════════════════════════╣
║  Session: {session_id}                                        ║
║  Task: {task_summary_short}                                   ║
╠──────────────────────────────────────────────────────────────╣
║  OVERALL PROGRESS                                             ║
║  ████████████░░░░░░░░  Phase 3 of 7  (Plan Approval)         ║
╠──────────────────────────────────────────────────────────────╣
║  Phase Status:                                                ║
║  [✓] 1. Initialization                                        ║
║  [✓] 2. Planning                                              ║
║  [→] 3. Plan Approval  ← YOU ARE HERE                         ║
║  [ ] 4. Implementation (0/5 tasks)                            ║
║  [ ] 5. Issue Resolution                                      ║
║  [ ] 6. Validation                                            ║
║  [ ] 7. Final Report                                          ║
╚══════════════════════════════════════════════════════════════╝
```

### Implementation Progress Dashboard

During implementation, when pausing for user input:

```markdown
╔══════════════════════════════════════════════════════════════╗
║  OP MODE - IMPLEMENTATION IN PROGRESS                         ║
╠══════════════════════════════════════════════════════════════╣
║  OVERALL: ██████████████░░░░░░  Phase 4 of 7                 ║
╠──────────────────────────────────────────────────────────────╣
║  CURRENT PHASE: Implementation                                ║
║  ████████████░░░░░░░░  Task 3 of 5                           ║
║                                                               ║
║  [✓] Task 1: Create API endpoint                              ║
║  [✓] Task 2: Add database migration                           ║
║  [→] Task 3: Build UI component  ← PAUSED                     ║
║  [ ] Task 4: Wire up frontend                                 ║
║  [ ] Task 5: Code review pass                                 ║
╠──────────────────────────────────────────────────────────────╣
║  PAUSE REASON: Design decision needed                         ║
╚══════════════════════════════════════════════════════════════╝
```

### Issue Tracking in Dashboard

When issues are being tracked:

```markdown
╔══════════════════════════════════════════════════════════════╗
║  OP MODE STATUS                                               ║
╠══════════════════════════════════════════════════════════════╣
║  OVERALL: ████████████████░░░░  Phase 5 of 7                 ║
╠──────────────────────────────────────────────────────────────╣
║  ISSUES:                                                      ║
║  [!] ISSUE-001: Type error in API (Attempt 2/4)              ║
║  [✓] ISSUE-002: Missing import (Resolved)                    ║
╠──────────────────────────────────────────────────────────────╣
║  Blocking: NO  |  Active Issues: 1  |  Resolved: 1           ║
╚══════════════════════════════════════════════════════════════╝
```

### Update Frequency Rules

| Event | Action |
|-------|--------|
| Phase transition | Update TodoWrite + show in output |
| Task started | Update TodoWrite with sub-task |
| Task completed | Mark complete, start next |
| Issue encountered | Add to issues display |
| Issue resolved | Update issues display |
| User prompt | Show full dashboard header |
| Every 3+ tool calls | Quick status line in output |

### Quick Status Line Format

For brief status updates during work:

```
[OP Mode] Phase 4 | Task 3/5 | Issues: 1 active | Progress: 65%
```

### Never Lose Track

If context gets long or complex:

1. **Re-read** `.uop/sessions/{session-id}/PLAN.md` for task list
2. **Check** TodoWrite current state
3. **Output** status dashboard before continuing
4. **Confirm** with user if unclear where we left off

---

## GSD Integration Details

OP Mode is built on GSD principles and directly leverages:

### From gsd-executor.md
- **Deviation Rules**:
  - Auto-fix: bugs, missing imports, type errors
  - Auto-add: critical functionality for goal
  - Ask: architectural changes, scope changes
- **Checkpoint Protocol**: Verify state before phase transitions
- **Atomic Commits**: One logical change per commit

### From gsd-debugger.md
- **Scientific Method**: Hypothesis → Test → Verify
- **Debug File Protocol**: Track issue status with timestamps
- **Verification Patterns**: Confirm fixes actually work

### From GSD Workflow
- **Goal-Backward Analysis**: Start from desired outcome
- **Phase Structure**: Clear entry/exit criteria
- **Documentation First**: Update docs as we go

---

**Begin OP Mode workflow when user provides task description.**
