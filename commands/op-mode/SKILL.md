---
name: op-mode
description: Orchestration Protocol - Unified GSD + RLM + Subagent workflow with MCP integration
argument-hint: "<task-description>"
allowed-tools: [Read, Glob, Grep, Bash, Task, TodoWrite, Write, Edit, WebFetch, WebSearch, mcp__plugin_supabase_supabase__*, mcp__plugin_stripe_stripe__*, mcp__plugin_playwright_playwright__*]
---

# OP Mode: Orchestration Protocol

**Unified workflow combining GSD planning, RLM analysis, Subagent execution, and MCP integration.**

---

## ⛔ GATE 0: REQUIRED READING (BEFORE ANYTHING ELSE)

**You MUST read these files before starting ANY work. This is non-negotiable.**

### Step 0.1: Read Skill Files (Based on Task Type)

```
╔════════════════════════════════════════════════════════════════════════════╗
║  SKILL FILES - READ BEFORE IMPLEMENTATION                                   ║
╠════════════════════════════════════════════════════════════════════════════╣
║                                                                             ║
║  UI/Frontend Work:                                                          ║
║  □ Read: /mnt/skills/public/frontend-design/SKILL.md                       ║
║                                                                             ║
║  Document Generation:                                                       ║
║  □ Read: /mnt/skills/public/docx/SKILL.md                                  ║
║  □ Read: /mnt/skills/public/pdf/SKILL.md                                   ║
║  □ Read: /mnt/skills/public/xlsx/SKILL.md                                  ║
║  □ Read: /mnt/skills/public/pptx/SKILL.md                                  ║
║                                                                             ║
╚════════════════════════════════════════════════════════════════════════════╝
```

### Step 0.2: Read Core Subagent Files (ALWAYS)

```
╔════════════════════════════════════════════════════════════════════════════╗
║  SUBAGENT FILES - READ THESE BEFORE PHASE 2                                 ║
╠════════════════════════════════════════════════════════════════════════════╣
║                                                                             ║
║  ALWAYS READ (Every Session):                                               ║
║  □ .claude/CLAUDE_CODE_TRAINING_GUIDE.md      ← Project standards           ║
║  □ .claude/subagents/coordinator.md            ← Workflow coordination      ║
║  □ CLAUDE.md (if exists in project root)       ← Project-specific rules     ║
║                                                                             ║
║  PLANNING PHASE:                                                            ║
║  □ .claude/subagents/prd-generator.md          ← Requirements gathering     ║
║  □ .claude/subagents/task-generator.md         ← Task breakdown             ║
║                                                                             ║
║  IMPLEMENTATION PHASE:                                                      ║
║  □ .claude/subagents/implementation-processor.md ← Code execution           ║
║                                                                             ║
╚════════════════════════════════════════════════════════════════════════════╝
```

### Step 0.3: Read GSD Agent Files (Workflow Methodology)

```
╔════════════════════════════════════════════════════════════════════════════╗
║  GSD AGENT FILES - WORKFLOW PATTERNS & METHODOLOGY                          ║
╠════════════════════════════════════════════════════════════════════════════╣
║                                                                             ║
║  CORE GSD (Read for every session):                                         ║
║  □ .claude/agents/gsd-executor.md           ← Deviation rules, auto-fix     ║
║  □ .claude/agents/gsd-debugger.md           ← Scientific debugging method   ║
║  □ .claude/agents/gsd-planner.md            ← Planning methodology          ║
║  □ .claude/agents/gsd-verifier.md           ← Verification patterns         ║
║                                                                             ║
║  RESEARCH & ANALYSIS (When investigating):                                  ║
║  □ .claude/agents/gsd-codebase-mapper.md    ← Understanding codebase        ║
║  □ .claude/agents/gsd-phase-researcher.md   ← Phase-specific research       ║
║  □ .claude/agents/gsd-project-researcher.md ← Project context research      ║
║  □ .claude/agents/gsd-research-synthesizer.md ← Synthesizing findings       ║
║                                                                             ║
║  PLANNING & VALIDATION:                                                     ║
║  □ .claude/agents/gsd-plan-checker.md       ← Validating plans              ║
║  □ .claude/agents/gsd-integration-checker.md ← Integration validation       ║
║  □ .claude/agents/gsd-roadmapper.md         ← Roadmap planning              ║
║                                                                             ║
╚════════════════════════════════════════════════════════════════════════════╝
```

### Step 0.4: Read Reviewer Files (Based on Change Type)

```
╔════════════════════════════════════════════════════════════════════════════╗
║  CODE REVIEWER FILES - READ BEFORE MAKING CHANGES                           ║
╠════════════════════════════════════════════════════════════════════════════╣
║                                                                             ║
║  Bug Fixes:                                                                 ║
║  □ .claude/subagents/coding/bug-hunter.md      ← Root cause analysis        ║
║                                                                             ║
║  API/Backend Changes:                                                       ║
║  □ .claude/subagents/coding/backend-reviewer.md ← API/DB patterns           ║
║                                                                             ║
║  UI/Component Changes:                                                      ║
║  □ .claude/subagents/coding/frontend-reviewer.md ← React/UI patterns        ║
║                                                                             ║
║  Auth/Security Changes:                                                     ║
║  □ .claude/subagents/coding/security-analyzer.md ← RLS/Auth patterns        ║
║                                                                             ║
║  Performance Work:                                                          ║
║  □ .claude/subagents/coding/performance-optimizer.md ← Optimization         ║
║                                                                             ║
╚════════════════════════════════════════════════════════════════════════════╝
```

### Step 0.5: Routing Table - Which Files to Read

| Task Type | Skill File | GSD Agents | Primary Reviewer | Secondary Reviewer |
|-----------|------------|------------|------------------|--------------------|
| UI/Component | frontend-design/SKILL.md | gsd-executor, gsd-verifier | frontend-reviewer.md | security-analyzer.md |
| API/Endpoint | - | gsd-executor, gsd-verifier | backend-reviewer.md | security-analyzer.md |
| Database/Schema | - | gsd-executor, gsd-planner | backend-reviewer.md | security-analyzer.md |
| Bug Fix | - | gsd-debugger, gsd-verifier | bug-hunter.md | (area-specific) |
| Auth/RLS | - | gsd-executor, gsd-verifier | security-analyzer.md | backend-reviewer.md |
| Performance | - | gsd-executor, gsd-verifier | performance-optimizer.md | backend-reviewer.md |
| Full Feature | frontend-design/SKILL.md | ALL GSD agents | ALL reviewers | ALL reviewers |
| Investigation | - | gsd-codebase-mapper, gsd-research-synthesizer | bug-hunter.md | - |

### Step 0.6: Confirm Reading (MANDATORY)

Before proceeding to GATE 1, you MUST output:

```markdown
## OP Mode Session: Files Read Confirmation

### Project Context
- [x] .claude/CLAUDE_CODE_TRAINING_GUIDE.md
- [x] .claude/subagents/coordinator.md
- [ ] CLAUDE.md (not found / found and read)

### Skill Files (for this task)
- [x] /mnt/skills/public/frontend-design/SKILL.md

### GSD Agent Files (for this task)
- [x] .claude/agents/gsd-executor.md
- [x] .claude/agents/gsd-debugger.md
- [x] .claude/agents/gsd-verifier.md
- [x] .claude/agents/gsd-planner.md

### Subagent Files (for this task)
- [x] .claude/subagents/prd-generator.md
- [x] .claude/subagents/task-generator.md
- [x] .claude/subagents/coding/frontend-reviewer.md
- [x] .claude/subagents/coding/security-analyzer.md

### RLM Index
- [x] .uop/INDEX.md

**All required files read. Ready to proceed with: {task_description}**
```

**If you have NOT output this confirmation, STOP and read the files first.**

---

## ⛔ CRITICAL: HARD GATES

**These gates are NON-NEGOTIABLE. You CANNOT skip them regardless of task urgency.**

### GATE 1: Session Initialization (After GATE 0 Complete)

You MUST complete these steps before analyzing the task:

```
□ TodoWrite initialized with 7-phase template
□ Read .uop/INDEX.md (create if missing)
□ Create session folder: .uop/sessions/{session-id}/
□ Initialize DECISION_TREE.md in session folder
□ Initialize MCP_LOG.md in session folder
```

**STOP. Do not proceed until all boxes are checked.**

---

### GATE 2: RLM Query (Before Planning)

**⛔ You CANNOT proceed to planning without querying RLM history first.**

You MUST query these RLM locations and document findings:

```
╔════════════════════════════════════════════════════════════════════════════╗
║  RLM MEMORY QUERIES - MANDATORY BEFORE PHASE 2                              ║
╠════════════════════════════════════════════════════════════════════════════╣
║                                                                             ║
║  ALWAYS QUERY (Every Session):                                              ║
║  □ .uop/INDEX.md                    ← Quick reference, load first          ║
║                                                                             ║
║  QUERY FOR HISTORICAL CONTEXT:                                              ║
║  □ .uop/history/patterns/           ← What patterns exist for this area?   ║
║  □ .uop/history/decisions/          ← What past decisions affect this?     ║
║  □ .uop/history/issues/             ← What problems occurred before?       ║
║                                                                             ║
║  CHECK FOR EXISTING SUMMARIES:                                              ║
║  □ .uop/summaries/{topic}.md        ← Compressed knowledge on topic        ║
║                                                                             ║
║  DOCUMENT IN SESSION:                                                       ║
║  □ Write findings to .uop/sessions/{session-id}/RLM_CONTEXT.md             ║
║                                                                             ║
╚════════════════════════════════════════════════════════════════════════════╝
```

### RLM Query Output (MANDATORY)

Before proceeding to Phase 2, you MUST output:

```markdown
## RLM Query Results

### INDEX.md Summary
- {key_pointers_found}

### Relevant Patterns Found
- Pattern: {pattern_name} - {brief_description}
- Pattern: {pattern_name} - {brief_description}

### Relevant Past Decisions
- Decision D{X}: {decision_summary}
- Decision D{X}: {decision_summary}

### Known Issues in This Area
- Issue: {issue_summary} - Resolution: {how_it_was_fixed}

### Summaries Loaded
- {topic}.md: {key_points}

### RLM Context Saved To
- .uop/sessions/{session-id}/RLM_CONTEXT.md

**RLM query complete. Proceeding to Phase 2 with historical context.**
```

**If you skip RLM queries, your plan will repeat past mistakes. STOP and query.**

**If .uop/ folder doesn't exist, CREATE IT with proper structure before proceeding.**

---

### GATE 3: Subagent Consultation (Before ANY Code Change)

You MUST route changes through reviewers before applying:

```
For EVERY file modification:
□ Identify relevant reviewer(s) from routing table
□ Generate patch proposal (do NOT apply yet)
□ Get reviewer assessment
□ Log decision in DECISION_TREE.md
□ THEN apply the change
```

**Routing Table:**
| Change Type | Primary Reviewer | Secondary |
|-------------|------------------|-----------|
| API/Backend | backend-reviewer | security-analyzer |
| UI/Component | frontend-reviewer | frontend-designer |
| Database | backend-reviewer | security-analyzer |
| Bug fix | bug-hunter | (area-specific) |
| Auth/Security | security-analyzer | backend-reviewer |

**NEVER apply code changes without reviewer consultation. STOP and consult.**

---

### GATE 4: MCP Logging (Every Tool Call)

You MUST log every MCP interaction:

```
After EVERY MCP tool call:
□ Log to .uop/sessions/{session-id}/MCP_LOG.md
□ Use format: [timestamp] [TAG] tool_name
□ Include: Input summary, Result summary, Context
```

**Tags:** DB-READ, DB-WRITE, DB-SCHEMA, PAY-READ, PAY-WRITE, UI-NAV, UI-CHECK, UI-ACTION

**If you don't log MCP calls, you lose audit trail. STOP and log.**

---

### GATE 5: Decision Tree Updates (Every Decision)

You MUST update decision tree for every choice:

```
When ANY decision is made:
□ Add entry to DECISION_TREE.md
□ Include: ID, Decision, Rationale, Status
□ Link related decisions
□ Note if change from original plan
```

**Decisions without documentation don't exist. STOP and document.**

---

## Pre-Flight Checklist (Before Every Session)

**Print this checklist and mark items as you complete them:**

```
╔══════════════════════════════════════════════════════════════╗
║  OP MODE PRE-FLIGHT CHECKLIST                                 ║
╠══════════════════════════════════════════════════════════════╣
║  □ 1. TodoWrite initialized with 7 phases                    ║
║  □ 2. .uop/INDEX.md read (or created)                        ║
║  □ 3. Session folder created                                  ║
║  □ 4. DECISION_TREE.md initialized                           ║
║  □ 5. MCP_LOG.md initialized                                  ║
║  □ 6. RLM history queried                                     ║
║  □ 7. Relevant subagent files identified                     ║
╠══════════════════════════════════════════════════════════════╣
║  ALL BOXES MUST BE CHECKED BEFORE PHASE 2                    ║
╚══════════════════════════════════════════════════════════════╝
```

---

## Workflow Enforcement Rules

### Rule 1: No File Writes Without Review
```
IF action == "Write" OR action == "Edit":
    STOP
    CHECK: Has reviewer been consulted?
    IF NO: Consult reviewer first
    IF YES: Proceed with logged decision
```

### Rule 2: No Phase Skipping
```
Phase order is: 1 → 2 → 3 → 4 → 5 → 6 → 7
You CANNOT jump from Phase 2 to Phase 4
Each phase has exit criteria that MUST be met
```

### Rule 3: User Touchpoints Are Mandatory
```
Phase 3 (Plan Approval): MUST present to user, MUST wait for approval
Phase 7 (Final Report): MUST present to user, MUST wait for approval
These are NOT optional even for "simple" tasks
```

### Rule 4: Iteration Limits Are Hard
```
Attempt 1 → Attempt 2 → Attempt 3 (Team) → Attempt 4 (Final) → ESCALATE
You CANNOT try attempt 5, 6, 7...
After 4 failures: STOP, document, escalate
```

---

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

### ⛔ GATE CHECK: Did you complete Pre-Flight Checklist? If NO, go back.

### 1.1 Assess Complexity

```
SIMPLE:   Single file, clear scope      → Skip RLM deep scan
MEDIUM:   2-5 files, defined boundaries → RLM targeted scan
COMPLEX:  6+ files, cross-cutting       → Full RLM recursive analysis
```

### 1.2 Load Memory (MANDATORY - NO EXCEPTIONS)

**⛔ You CANNOT skip this step. RLM is your external memory.**

```bash
# STEP 1: Always start with INDEX
Read(.uop/INDEX.md)
# If .uop/INDEX.md doesn't exist, CREATE the .uop/ structure first

# STEP 2: Check for relevant summaries
if INDEX mentions related_topic:
    Read(.uop/summaries/{related_topic}.md)

# STEP 3: Check for active session state
if resuming_session:
    Read(.uop/sessions/{session-id}/PLAN.md)
    Read(.uop/sessions/{session-id}/DECISION_TREE.md)
```

**What to look for in INDEX.md:**
- Pointers to relevant patterns
- Active session references
- Known problem areas
- Recent decision summaries

**If INDEX.md is empty or missing:** This is a fresh project. Create the .uop/ structure:
```
.uop/
├── INDEX.md              # Create with basic template
├── sessions/             # Create empty folder
├── history/
│   ├── decisions/        # Create empty folder
│   ├── issues/           # Create empty folder
│   └── patterns/         # Create empty folder
└── summaries/            # Create empty folder
```

### 1.3 RLM Historical Query (MANDATORY for MEDIUM/COMPLEX tasks)

**⛔ For any task touching 2+ files, you MUST query history before planning.**

```
╔════════════════════════════════════════════════════════════════════════════╗
║  RLM HISTORICAL QUERY - ASK THESE QUESTIONS                                 ║
╠════════════════════════════════════════════════════════════════════════════╣
║                                                                             ║
║  1. "What patterns exist for {task_area}?"                                  ║
║     → Check: .uop/history/patterns/                                         ║
║                                                                             ║
║  2. "What past decisions affect {component}?"                               ║
║     → Check: .uop/history/decisions/                                        ║
║                                                                             ║
║  3. "What issues have occurred with {feature_area}?"                        ║
║     → Check: .uop/history/issues/                                           ║
║                                                                             ║
║  4. "Is there existing documentation on {topic}?"                           ║
║     → Check: .uop/summaries/                                                ║
║                                                                             ║
╚════════════════════════════════════════════════════════════════════════════╝
```

**You MUST document findings in `.uop/sessions/{session-id}/RLM_CONTEXT.md` before Phase 2.**

**If no relevant history exists:** Document "No prior patterns/decisions/issues found for {area}" - this is still valuable context.

---

## Phase 2: Planning (RLM Active Partner)

### ⛔ GATE CHECK: Did you query RLM history? If NO, go back to Phase 1.3.

### 2.1 Generate PRD

```
Task(
  subagent_type="prd-generator",
  prompt="Generate PRD for: {task_description}\n\nHistorical Context:\n{rlm_history_summary}"
)
```

### 2.2 RLM Planning Participation (MANDATORY)

**⛔ RLM MUST actively participate in planning. This is not optional.**

RLM actively participates by:

1. **Questioning assumptions** based on historical patterns
2. **Identifying conflicts** with past decisions
3. **Suggesting approaches** that worked before
4. **Flagging areas** that caused issues previously

```
╔════════════════════════════════════════════════════════════════════════════╗
║  RLM PLANNING REVIEW - MUST COMPLETE BEFORE TASK LIST                       ║
╠════════════════════════════════════════════════════════════════════════════╣
║                                                                             ║
║  □ Review PRD against .uop/history/patterns/                               ║
║    → Does this conflict with established patterns?                          ║
║                                                                             ║
║  □ Review PRD against .uop/history/decisions/                              ║
║    → Does this contradict past decisions?                                   ║
║                                                                             ║
║  □ Review PRD against .uop/history/issues/                                 ║
║    → Are we about to repeat a past mistake?                                 ║
║                                                                             ║
║  □ Document conflicts/risks in session PLAN.md                             ║
║                                                                             ║
╚════════════════════════════════════════════════════════════════════════════╝
```

### RLM Planning Output (MANDATORY)

Before generating task list, you MUST output:

```markdown
## RLM Planning Review

### Pattern Conflicts
- [ ] No conflicts found / [X] Conflicts identified:
  - {pattern} conflicts with {proposed_approach}

### Decision Conflicts
- [ ] No conflicts found / [X] Conflicts identified:
  - Decision D{X} conflicts with {proposed_approach}

### Risk Flags from Past Issues
- [ ] No risks found / [X] Risks identified:
  - Past issue "{issue}" suggests risk of {problem}

### RLM Recommendations
- Approach: {recommended_approach_based_on_history}
- Avoid: {anti-patterns_from_past_issues}

**RLM review complete. Proceeding with task generation.**
```

**If RLM identifies conflicts, you MUST address them before proceeding.**

### 2.3 Generate Task List

```
Task(
  subagent_type="task-generator",
  prompt="Convert PRD to tasks:\n{prd_content}\n\nRLM Insights:\n{rlm_planning_insights}"
)
```

### 2.4 Decision Tree Initialization (MANDATORY)

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

**Do NOT proceed to Phase 3 without DECISION_TREE.md created.**

---

## Phase 3: Plan Approval (USER TOUCHPOINT 1)

### ⛔ THIS IS MANDATORY. You CANNOT skip user approval.

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

**WAIT for user response. Do NOT proceed without explicit approval.**

---

## Phase 4: Autonomous Implementation

### ⛔ GATE CHECK: Did user approve plan in Phase 3? If NO, do not proceed.

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
    # ⛔ GATE: Consult reviewer BEFORE implementation
    reviewers = identify_reviewers(task)
    for reviewer in reviewers:
        assessment = consult_reviewer(reviewer, task)
        log_to_decision_tree(assessment)

    # Execute implementation
    result = Task(
        subagent_type="implementation-processor",
        prompt=f"Implement: {task}\nContext: {decision_tree}\nReviewer Input: {assessment}"
    )

    # ⛔ GATE: Log MCP interactions
    log_mcp_calls(result.mcp_calls)

    # Run code review
    reviews = parallel_review(result.files_changed)

    # Handle review findings
    for finding in reviews:
        if finding.severity == "CRITICAL":
            apply_fix(finding)  # Auto-fix
            log_to_decision_tree(finding, "AUTO-FIX")
        elif finding.type in ["DESIGN", "UX", "SCOPE"]:
            queue_for_user(finding)  # Pause
        else:
            apply_fix(finding)  # Auto-fix
            log_to_decision_tree(finding, "AUTO-FIX")

    # Update documentation (MANDATORY)
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
│ Auto-Fix & Log  │ ← MUST log to DECISION_TREE.md
└─────────────────┘
```

---

## Phase 5: Iteration Limit Protocol

### 5.1 Attempt Tracking (MANDATORY)

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

### 5.2 Escalation Protocol (HARD LIMIT: 4 ATTEMPTS)

```
Attempt 1: Try solution
    ↓ Failed
Attempt 2: Try alternative approach
    ↓ Failed
Attempt 3: Consult subagent team for fresh perspective
    ↓ Failed
Attempt 4: Final attempt with team recommendation
    ↓ Failed
ESCALATE: ⛔ STOP HERE. No attempt 5.
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

### 6.4 Self-Test Checklist (MANDATORY before Phase 7)

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

**All boxes MUST be checked before proceeding to Phase 7.**

---

## Phase 7: Final Validation (USER TOUCHPOINT 2)

### ⛔ THIS IS MANDATORY. You CANNOT skip final report.

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

### RLM Updates Made
- Patterns saved: {list}
- Decisions logged: {list}
- Issues documented: {list}

---
**Ready for your review and approval.**
```

---

## MCP Logging Protocol

### ⛔ EVERY MCP call MUST be logged. No exceptions.

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

### ⛔ Every decision MUST be logged. Undocumented decisions don't exist.

### Change Detection

When implementation reveals decision needs to change:

```python
def handle_decision_change(old_decision, new_decision, reason):
    # Log the change (MANDATORY)
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

**⛔ RLM updates are MANDATORY at session end. You CANNOT complete a session without updating RLM.**

### What MUST Be Saved to RLM

```
╔════════════════════════════════════════════════════════════════════════════╗
║  RLM SAVE REQUIREMENTS - MANDATORY BEFORE SESSION COMPLETE                  ║
╠════════════════════════════════════════════════════════════════════════════╣
║                                                                             ║
║  PATTERNS (Save to .uop/history/patterns/):                                ║
║  □ Any new coding pattern discovered                                        ║
║  □ Any successful approach that could be reused                             ║
║  □ Any anti-pattern identified (what NOT to do)                            ║
║                                                                             ║
║  DECISIONS (Save to .uop/history/decisions/):                              ║
║  □ All decisions from DECISION_TREE.md                                      ║
║  □ Why each decision was made                                               ║
║  □ What alternatives were considered                                        ║
║                                                                             ║
║  ISSUES (Save to .uop/history/issues/):                                    ║
║  □ Any issue encountered and how it was resolved                           ║
║  □ Root cause analysis                                                      ║
║  □ Prevention strategies for future                                         ║
║                                                                             ║
║  INDEX (Update .uop/INDEX.md):                                             ║
║  □ Add pointers to new patterns                                             ║
║  □ Add pointers to significant decisions                                    ║
║  □ Update "Recent Sessions" section                                        ║
║                                                                             ║
╚════════════════════════════════════════════════════════════════════════════╝
```

### RLM Save Format

**For Patterns (.uop/history/patterns/{pattern-name}.md):**
```markdown
# Pattern: {Pattern Name}

## When to Use
{description_of_when_this_applies}

## Implementation
{code_or_approach}

## Examples
- {example_1}
- {example_2}

## Anti-Patterns (What NOT to Do)
- {anti_pattern_1}

## Source Session
- Session: {session-id}
- Date: {date}
```

**For Decisions (.uop/history/decisions/{decision-id}.md):**
```markdown
# Decision: {Decision Title}

## Context
{what_prompted_this_decision}

## Decision
{what_was_decided}

## Rationale
{why_this_was_chosen}

## Alternatives Considered
- {alternative_1}: {why_rejected}
- {alternative_2}: {why_rejected}

## Impact
{what_this_affects}

## Source Session
- Session: {session-id}
- Date: {date}
```

**For Issues (.uop/history/issues/{issue-id}.md):**
```markdown
# Issue: {Issue Title}

## Problem
{what_went_wrong}

## Root Cause
{why_it_happened}

## Solution
{how_it_was_fixed}

## Prevention
{how_to_avoid_in_future}

## Source Session
- Session: {session-id}
- Date: {date}
```

### Automatic Update Triggers

```python
def on_session_complete():
    # MANDATORY: Save all session learnings
    save_patterns_to_history()
    save_decisions_to_history()
    save_issues_to_history()
    update_index_with_session_summary()

def on_user_guidance(guidance):
    # Extract and save immediately
    decisions = extract_decisions(guidance)
    patterns = extract_patterns(guidance)

    for decision in decisions:
        save_to_decision_tree(decision)
        save_to_history_decisions(decision)

    for pattern in patterns:
        save_to_history_patterns(pattern)

    refresh_index()
```

### RLM Update Confirmation (MANDATORY in Final Report)

Your Phase 7 Final Report MUST include:

```markdown
### RLM Updates Made

**Patterns Saved:**
- .uop/history/patterns/{pattern-1}.md - {description}
- .uop/history/patterns/{pattern-2}.md - {description}

**Decisions Logged:**
- .uop/history/decisions/{decision-1}.md - {summary}

**Issues Documented:**
- .uop/history/issues/{issue-1}.md - {summary}

**INDEX.md Updated:**
- [x] Added pointers to new patterns
- [x] Added session summary
```

**If you have NOT saved to RLM, the session is INCOMPLETE.**

---

## Integration Points

### GSD Integration

OP Mode leverages GSD for:
- **Deviation Rules**: Auto-fix bugs, ask about architecture
- **Checkpoint Protocol**: Verify before continuing
- **Atomic Commits**: One logical change per commit

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

## Progress Display Protocol

### ⛔ CRITICAL: ALWAYS-VISIBLE PROGRESS (NON-NEGOTIABLE)

**Every single response MUST include a progress indicator.** This is not optional. Users must NEVER lose track of where they are in the workflow.

### The Golden Rule

```
╔════════════════════════════════════════════════════════════════════════════╗
║  EVERY RESPONSE = PROGRESS BAR + CURRENT TASK + REMAINING ITEMS            ║
║                                                                             ║
║  No exceptions. No "I'll update later." EVERY. SINGLE. RESPONSE.           ║
╚════════════════════════════════════════════════════════════════════════════╝
```

---

### Progress Bar Formats (Use Appropriate Size)

**Compact (for mid-work updates):**
```
⟦■■■■□□□⟧ Phase 4/7 │ Task 3/8 │ Implementing user auth
```

**Standard (for task transitions):**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 PROGRESS: ████████████░░░░░░░░ 57% │ Phase 4/7 │ Task 3/8
   Current: Implementing user authentication endpoint
   Next up: Add input validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Full Dashboard (for phase transitions & user touchpoints):**
```
╔══════════════════════════════════════════════════════════════════════════╗
║  OP MODE PROGRESS DASHBOARD                                               ║
╠══════════════════════════════════════════════════════════════════════════╣
║  Session: op-2026-01-22-001                                               ║
║  Goal: {original_task_description}                                        ║
╠══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║  OVERALL PROGRESS                                                         ║
║  ████████████████░░░░░░░░░░░░░░  Phase 4 of 7  (Implementation)          ║
║                                                                           ║
╠══════════════════════════════════════════════════════════════════════════╣
║  PHASE STATUS                           │  CURRENT TASK BREAKDOWN         ║
║  ──────────────────────────────────     │  ─────────────────────────────  ║
║  [✓] 1. Initialization                  │  Phase 4 Tasks:                 ║
║  [✓] 2. Planning                        │  [✓] 4.1 Create API route       ║
║  [✓] 3. Plan Approval                   │  [✓] 4.2 Add database query     ║
║  [→] 4. Implementation  ← YOU ARE HERE  │  [→] 4.3 Implement auth  ← NOW  ║
║  [ ] 5. Issue Resolution                │  [ ] 4.4 Add validation         ║
║  [ ] 6. Validation                      │  [ ] 4.5 Error handling         ║
║  [ ] 7. Final Report                    │  [ ] 4.6 Write tests            ║
║                                         │                                  ║
╠══════════════════════════════════════════════════════════════════════════╣
║  REMAINING WORK SUMMARY                                                   ║
║  • Current phase: 4 tasks remaining                                       ║
║  • After this phase: 3 phases (Issues → Validation → Report)             ║
║  • Known blockers: None                                                   ║
╚══════════════════════════════════════════════════════════════════════════╝
```

---

### Hierarchical Task Expansion

When tasks are broken down, the todo list MUST show the hierarchy:

**Initial (Phase-level only):**
```
TodoWrite([
  { content: "Phase 1: Initialization", status: "completed", activeForm: "Initializing" },
  { content: "Phase 2: Planning", status: "completed", activeForm: "Planning" },
  { content: "Phase 3: Plan Approval [USER]", status: "completed", activeForm: "Awaiting approval" },
  { content: "Phase 4: Implementation", status: "in_progress", activeForm: "Implementing" },
  { content: "Phase 5: Issue Resolution", status: "pending", activeForm: "Resolving issues" },
  { content: "Phase 6: Validation", status: "pending", activeForm: "Validating" },
  { content: "Phase 7: Final Report [USER]", status: "pending", activeForm: "Final report" }
])
```

**Expanded (When entering Phase 4 - shows sub-tasks):**
```
TodoWrite([
  { content: "Phase 1: Initialization", status: "completed", activeForm: "Initializing" },
  { content: "Phase 2: Planning", status: "completed", activeForm: "Planning" },
  { content: "Phase 3: Plan Approval [USER]", status: "completed", activeForm: "Awaiting approval" },
  { content: "Phase 4: Implementation (6 tasks)", status: "in_progress", activeForm: "Implementing" },
  { content: "  └─ 4.1 Create API route", status: "completed", activeForm: "Creating API route" },
  { content: "  └─ 4.2 Add database query", status: "completed", activeForm: "Adding database query" },
  { content: "  └─ 4.3 Implement auth check", status: "in_progress", activeForm: "Implementing auth check" },
  { content: "  └─ 4.4 Add input validation", status: "pending", activeForm: "Adding validation" },
  { content: "  └─ 4.5 Error handling", status: "pending", activeForm: "Adding error handling" },
  { content: "  └─ 4.6 Write unit tests", status: "pending", activeForm: "Writing tests" },
  { content: "Phase 5: Issue Resolution", status: "pending", activeForm: "Resolving issues" },
  { content: "Phase 6: Validation", status: "pending", activeForm: "Validating" },
  { content: "Phase 7: Final Report [USER]", status: "pending", activeForm: "Final report" }
])
```

**Deep Expansion (When sub-task has sub-steps):**
```
TodoWrite([
  ...
  { content: "  └─ 4.3 Implement auth check", status: "in_progress", activeForm: "Implementing auth" },
  { content: "      └─ 4.3.1 Add middleware", status: "completed", activeForm: "Adding middleware" },
  { content: "      └─ 4.3.2 Verify JWT token", status: "in_progress", activeForm: "Verifying JWT" },
  { content: "      └─ 4.3.3 Check permissions", status: "pending", activeForm: "Checking permissions" },
  ...
])
```

---

### Mandatory Progress Output Rules

| Trigger | Required Output | Format |
|---------|-----------------|--------|
| **Every response** | Progress indicator | Compact minimum |
| **After 2+ tool calls** | Status update | Compact |
| **Task started** | Task announcement | Standard |
| **Task completed** | Completion + next | Standard |
| **Phase transition** | Full dashboard | Full Dashboard |
| **User touchpoint** | Full dashboard | Full Dashboard |
| **Issue encountered** | Dashboard + issue | Full + Issue Block |
| **Resuming work** | Full context restore | Full Dashboard |

---

### "Remaining Items" Summary (ALWAYS Include)

At the end of every response, include a quick remaining items count:

```
───────────────────────────────────────────────────────
📋 Remaining: 4 tasks in current phase │ 3 phases after this │ 0 blockers
───────────────────────────────────────────────────────
```

Or in compact form:
```
[Remaining: 4 tasks │ 3 phases │ 0 blockers]
```

---

### Context Preservation Across Messages

When work spans multiple messages, ALWAYS start with context restoration:

```markdown
## Resuming OP Mode Session

**Where we left off:**
- Phase: 4 (Implementation)
- Last completed: Task 4.2 (Add database query)
- Currently working on: Task 4.3 (Implement auth check)

**Full context:**
{Show Full Dashboard}

**Continuing with Task 4.3...**
```

---

### Progress Tracking State File

Maintain progress state in session folder for recovery:

```markdown
# .uop/sessions/{session-id}/PROGRESS_STATE.md

## Current Position
- Phase: 4
- Task: 4.3
- Sub-step: 4.3.2

## Completed Items
- [x] Phase 1: Initialization
- [x] Phase 2: Planning
- [x] Phase 3: Plan Approval
- [ ] Phase 4: Implementation
  - [x] 4.1 Create API route
  - [x] 4.2 Add database query
  - [ ] 4.3 Implement auth check
    - [x] 4.3.1 Add middleware
    - [ ] 4.3.2 Verify JWT token
    - [ ] 4.3.3 Check permissions
  - [ ] 4.4-4.6 (pending)
- [ ] Phase 5-7 (pending)

## Summary Counts
- Total phases: 7
- Completed phases: 3
- Current phase tasks: 6
- Completed in current: 2
- Remaining in current: 4
- Total remaining phases: 4

## Last Updated
{timestamp}
```

---

### Anti-Patterns (NEVER DO THESE)

| ❌ NEVER | ✅ ALWAYS |
|----------|-----------|
| Skip progress in a response | Include at least compact progress |
| Say "continuing..." without context | Show where you are + what's next |
| Complete tasks without updating | Update TodoWrite immediately |
| Hide remaining work | Show remaining count |
| Forget hierarchical position | Show parent task context |
| Assume user remembers | Restore context every response |

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

Every OP Mode session MUST:

1. ✓ Complete Pre-Flight Checklist before Phase 2
2. ✓ Query RLM history before planning
3. ✓ Get explicit plan approval from user
4. ✓ Consult reviewers before every code change
5. ✓ Log all MCP interactions with tags
6. ✓ Maintain decision tree throughout
7. ✓ Respect iteration limits (4 max)
8. ✓ Generate mandatory tests (1 happy + 2 edge)
9. ✓ Validate visually for UI changes
10. ✓ Present final report for user approval
11. ✓ Update RLM history for future sessions

**If any criteria is not met, the session is non-compliant.**

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

**Remember: Gates are not suggestions. They are requirements.**
