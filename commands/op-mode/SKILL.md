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

### Step 0.0: Task Sizing (Light Mode Check)

Before loading any skill files, assess the incoming task:

```
╔══════════════════════════════════════════════════════════════════╗
║  TASK SIZING — Is this a full OP Mode task or a quick fix?      ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  LIGHT MODE (Skip to Phase 5 → 6 → 7):                         ║
║  ✓ Single-file change (typo, CSS tweak, config update)          ║
║  ✓ Bug fix where root cause is already known                    ║
║  ✓ Adding a comment, log statement, or environment variable     ║
║  ✓ Task can be described in one sentence                        ║
║  ✓ No architectural decisions needed                            ║
║  ✓ Estimated effort: under 15 minutes                           ║
║                                                                  ║
║  FULL MODE (Run all 7 phases):                                  ║
║  ✓ New feature or endpoint                                      ║
║  ✓ Multi-file changes                                           ║
║  ✓ Database schema changes                                      ║
║  ✓ Anything touching auth, RLS, or security                     ║
║  ✓ Integration with external services                           ║
║  ✓ Anything the developer can't fully describe in one sentence  ║
║                                                                  ║
║  WHEN IN DOUBT → Full Mode. Better to over-plan than break.    ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

**If LIGHT MODE:**
  → Log task to .uop/sessions/{id}/PROGRESS_STATE.md as "LIGHT MODE"
  → Skip Phases 1-4
  → Go directly to Phase 5 (Implementation)
  → Run Phase 6 (Validation) — still mandatory, even for quick fixes
  → Run Phase 7 (Final Report) — abbreviated format (3 lines max)

**If FULL MODE:**
  → Continue to Step 0.1 as normal

**Auto: Doc Freshness Scanner runs in Full Mode** (see Utilities section)

---

### Step 0.1: Skill Discovery (Auto-Scan System)

Instead of a static list of skill files, OP Mode now SCANS for skills dynamically:

#### Auto-scan locations (check all, in order):
1. `.claude/skills/` ← project-level custom skills
2. `.claude/commands/` ← installed OP Mode commands
3. `.skills/skills/` ← Cowork/plugin skills
4. `.local-plugins/` ← marketplace plugins

#### For each skill found:
Read the SKILL.md (first 50 lines only — just the description/triggers section).
Build a runtime skill manifest:

**`.uop/skill-manifest.json`**

```json
{
  "skills": [
    {
      "name": "frontend-design",
      "path": "/mnt/skills/public/frontend-design/SKILL.md",
      "triggers": ["ui", "frontend", "component", "design", "interface"],
      "auto_invoke": false,
      "phase_affinity": ["Phase 5"]
    },
    {
      "name": "disciplined-git-workflow",
      "path": ".claude/skills/disciplined-git-workflow/SKILL.md",
      "triggers": ["commit", "branch", "merge", "git", "version control"],
      "auto_invoke": false,
      "phase_affinity": ["Phase 5", "between Phase 5-6"]
    },
    {
      "name": "e2e-test",
      "path": ".claude/skills/e2e-test/SKILL.md",
      "triggers": ["test", "validate", "browser", "e2e", "visual check"],
      "auto_invoke": true,
      "phase_affinity": ["Phase 6"]
    }
  ],
  "last_scan": "2026-02-26T10:30:00Z"
}
```

#### Skill matching during execution:
At the start of EACH phase, check the skill manifest:
- Does any skill's trigger keywords match the current task?
- Does any skill have phase_affinity matching the current phase?

**If YES** → Load that skill's SKILL.md and follow its instructions
**If MULTIPLE match** → Load all, in order of phase_affinity relevance

#### Example:
```
User says: "commit the changes and push"
→ Matches trigger "commit" → loads disciplined-git-workflow
→ No full OP Mode phases needed → Light Mode + skill execution

User starts Phase 6 (Validation):
→ e2e-test has phase_affinity "Phase 6" → auto-loaded
→ agent-browser testing runs automatically
```

#### Refresh cadence:
- Rescan on first session of the day
- Rescan if user says "I installed a new skill" or "check for new skills"
- Cache the manifest otherwise (don't rescan every session)

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

### Phase 1.0: Project Scoping (Multi-Project Support)

When OP Mode starts, determine which project we're in:

#### Detection method (in order):
1. Check for `.uop/project.json` in current directory
2. Check for `package.json` → read "name" field
3. Check for `.git` → read remote URL
4. Ask user: "Which project is this?"

#### Project config: `.uop/project.json`

```json
{
  "project_name": "my-project",
  "project_type": "saas",
  "created": "2026-01-15",
  "tech_stack": {
    "backend": "node",
    "database": "postgresql",
    "frontend": "react",
    "additional": ["redis", "stripe"]
  },
  "conventions": {
    "migration_prefix": "timestamp",
    "route_pattern": "src/routes/{resource}.js",
    "service_pattern": "src/services/{resource}.js",
    "test_pattern": "tests/{type}/{resource}.test.js"
  },
  "deprecated_services": [],
  "security_requirements": ["auth", "csrf"],
  "custom_rules": [
    "Example: All API endpoints must have JSON schema validation",
    "Example: Database queries must use parameterized statements"
  ]
}
```

#### How scoping works:
- All `.uop/` paths are relative to the project root
- Failure journal entries are tagged with `project_name`
- Checkpoint resume only shows checkpoints for the CURRENT project
- Deprecated terms scanner reads from this project's config
- Skill manifest is project-scoped (different projects may use different skills)

#### New project setup:
If `.uop/project.json` doesn't exist, OP Mode creates it interactively:

```
"I don't see a project config. Let me set one up:
1. What's this project called?
2. What's the tech stack? (I can auto-detect from package.json)
3. Any project-specific rules I should know?"
```

This only happens once per project. After that, OP Mode knows where it is.

---

### Phase 1.0.5: Auto-Resume Detection

**When OP Mode starts a new session, BEFORE doing anything else:**

1. **Check**: Does `.uop/sessions/` contain any non-archived checkpoints?
2. **If YES**:
   a. Find the most recent `CHECKPOINT.md`, `HEARTBEAT.md`, or `EMERGENCY_SAVE.md`
   b. Read it silently
   c. Present to user:

```
"I found a checkpoint from {timestamp}.
Task: {description}
Status: Phase {N}, {what was happening}

Options:
A) Resume from checkpoint (recommended)
B) Start fresh (archives the checkpoint)
C) Review checkpoint before deciding"
```

3. **If user picks A** → load checkpoint context, skip to the right phase
4. **If user picks B** → move checkpoint to `.uop/history/archived/`
5. **If user picks C** → display checkpoint contents, then ask A or B

#### Session Continuity Rules

These rules MUST be followed in every resumed session:

- **DO NOT** re-read files that were already read in the previous session (the checkpoint tells you what was read)
- **DO NOT** re-plan unless the user explicitly asks
- **DO NOT** re-run successful tests (only re-run failed or new tests)
- **DO** re-read the `PLAN.md` (it's compact and keeps you aligned)
- **DO** re-read `ISSUES.md` (you need to know what's still open)
- **Start work within 2 tool calls of resuming.** Not 10. Not 20. TWO. (Read checkpoint → read plan → start working)

---

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

## Phase 5: Implementation

### Phase 5.0: Test-First Gate (Mandatory TDD)

Before writing ANY implementation code, you MUST:

#### Step 1: Write the failing test

```bash
# Create test file for the feature being implemented
# Test file goes next to the source file or in a /tests directory

# Example structure:
# src/routes/appointments.js  →  tests/routes/appointments.test.js
# src/services/booking.js     →  tests/services/booking.test.js

# The test MUST:
# - Describe the expected behavior in plain English
# - Call the function/endpoint that doesn't exist yet
# - Assert the expected output
# - FAIL when you run it (because the code doesn't exist)
```

#### Step 2: Verify the test fails (RED)

```bash
npm test -- --testPathPattern="{test_file}"

# Expected: FAIL
# If the test PASSES before you write code → your test is wrong
# A passing test that doesn't test anything is worse than no test
```

#### Step 3: Write the minimum code to pass (GREEN)

```bash
# Now implement. Write ONLY enough code to make the test pass.
# Do not add "nice to have" features. Do not optimize.
# YAGNI: You Aren't Gonna Need It.
# DRY: Don't Repeat Yourself (but only after you have duplication — not before)
```

#### Step 4: Verify the test passes

```bash
npm test -- --testPathPattern="{test_file}"

# Expected: PASS
# If FAIL → fix the code, not the test (unless the test has a bug)
```

#### Step 5: Refactor (if needed)

```bash
# Clean up the code. The test protects you from breaking anything.
# Run the test again after any cleanup.
```

#### When TDD is NOT required (Light Mode exceptions):
- Config changes (env vars, package.json metadata)
- Documentation-only changes
- CSS-only visual tweaks (use screenshot validation instead)
- One-line bug fixes where the bug is already covered by existing test

#### Test file naming convention:
- `{source-filename}.test.js` (unit tests)
- `{feature-name}.e2e.js` (end-to-end tests)

#### Minimum coverage per feature:
- 1 happy path test (the thing works as intended)
- 1 edge case test (boundary condition or empty state)
- 1 error handling test (what happens when input is bad)

---

### Phase 5.0.5: Pre-Implementation Hooks

#### Hook 1: Check Failure Journal

Before touching a file, check `.uop/failures.md` for known failure patterns:

```bash
# If the file or category matches a past failure:
# → Apply the prevention rule proactively
# → Add a comment in code referencing the failure pattern
```

See **Utility: Failure Mode Journal** (below) for journal format.

#### Hook 2: Auto-Append Change Log

After EVERY file modification, auto-append to `.uop/sessions/{id}/CHANGES.md`:

```markdown
---
### Change {N}: {file_path}
**Time:** {timestamp}
**Type:** {ADD | MODIFY | DELETE}
**Lines affected:** {line range or "new file"}
**Risk level:** {LOW | MEDIUM | HIGH}

**What changed (plain English):**
{2-3 sentences explaining the change as if talking to a non-developer}

**Why:**
{The business reason, not the technical reason}

**What could break:**
{Honest assessment — what other parts of the system might be affected}

**Test covering this change:**
{test file and test name, or "NONE — needs test" if TDD was skipped}
---
```

**Rules:**
- EVERY file modification gets an entry. No exceptions.
- "What changed" must be understandable by someone who doesn't code.
- "Why" must reference the business need, not the technical implementation.
- Risk level HIGH triggers automatic human review before Phase 7.
- Changes with "NONE — needs test" are flagged in the Phase 6 checklist.

#### Hook 3: Heartbeat Checkpoints

Every **10 tool calls** during implementation, write a lightweight snapshot to `.uop/sessions/{id}/HEARTBEAT.md`:

```markdown
---
# Heartbeat: {timestamp}
# Session: {id}
# Phase: {current_phase}
# Tool calls since last heartbeat: {count}

## I am currently:
{1 sentence — what the AI is doing right now}

## Working on file:
{file_path} (lines {range})

## Current approach:
{2-3 sentences — what strategy is being used}

## Iteration state:
- Attempt {N} of 3 on: {current issue}
- Last error: {error message or "none"}

## Files modified since last checkpoint:
{list with paths}

## Next step if interrupted:
{exact next action — specific enough to resume cold}
---
```

This ensures session recovery even if context window compaction happens mid-implementation.

---

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

## Phase 6: Post-Implementation Validation (E2E Agent-Browser)

> This phase uses `agent-browser` (Anthropic CLI) for interactive browser testing.
> It replaces Playwright MCP with a token-efficient accessibility tree approach.
> Token cost: ~385 chars/snapshot vs ~4,127 chars (Playwright). **93% savings**.

---

### 6.0 Pre-Flight Check

```bash
# Verify agent-browser is installed
which agent-browser || npm install -g agent-browser

# Verify platform (Linux/WSL/macOS only — no native Windows)
uname -s  # Must return Linux or Darwin

# If missing system deps (Chromium headless):
# Ubuntu/Debian: sudo apt-get install -y chromium-browser
# macOS: brew install chromium
```

---

### 6.1 Parallel Research Sub-Agents (Before Testing)

Launch 3 sub-agents in parallel to build testing context:

#### Sub-Agent A: Structure Mapper

```
Task(
  subagent_type="general-purpose",
  prompt="Map the application structure for E2E testing.

  Research:
  1. Read all HTML files — identify pages, sections, navigation flows
  2. List every user journey (e.g., login → dashboard → create item → verify)
  3. Identify all interactive elements: forms, buttons, modals, dropdowns, tabs
  4. Document the app startup command (e.g., `npm start`, `node src/server.js`)
  5. Document the base URL and any auth requirements

  Output format:
  ## Pages
  - {page}: {URL path} — {key interactive elements}

  ## User Journeys
  1. {journey_name}: {step1} → {step2} → {step3} → {expected_outcome}

  ## Auth Flow
  - Method: {cookie/token/session}
  - Login endpoint: {path}
  - Test credentials: {how to obtain}

  ## Startup
  - Command: {command}
  - Ready signal: {what to look for in logs}
  - Base URL: {url}"
)
```

#### Sub-Agent B: Schema & Data Mapper

```
Task(
  subagent_type="general-purpose",
  prompt="Document the database schema and data flows for E2E validation.

  Research:
  1. Read all migration files — build table/column inventory
  2. Identify which tables get written during key user actions
  3. Document expected DB state after each user journey
  4. Find the DB connection method (env var, config file)

  Output format:
  ## Key Tables for Validation
  | Table | Written By | Key Columns | Expected After Action |

  ## DB Connection
  - Type: {PostgreSQL/MySQL/SQLite}
  - Connection: {env var or config path}
  - Query tool: psql / mysql / sqlite3

  ## Validation Queries
  For each user journey, provide a SQL query to verify the action took effect."
)
```

#### Sub-Agent C: Bug Hunter (Pre-Test)

```
Task(
  subagent_type="general-purpose",
  prompt="Scan the codebase for potential bugs BEFORE E2E testing.

  Check for:
  1. Unhandled error paths in route handlers
  2. Missing form validations (frontend and backend)
  3. Race conditions in async flows
  4. Hardcoded values that should be configurable
  5. Console.error or TODO/FIXME/HACK comments
  6. Missing null checks on DB query results

  Output format:
  ## Potential Issues (prioritized)
  | # | File | Line | Issue | Severity | Likely to Surface in E2E? |

  Focus on issues that would manifest during browser interaction."
)
```

Wait for all 3 sub-agents to complete. Merge their outputs into the session's `.uop/sessions/{id}/VALIDATION.md` file.

---

### 6.2 Application Startup & Browser Launch

```bash
# Start the application (command from Sub-Agent A research)
# Example generic patterns:
cd backend && node src/server.js &  # OR npm start &
APP_PID=$!

# Wait for ready signal
sleep 3

# Verify app is running
curl -s http://localhost:3000/health || curl -s http://localhost:3000 || echo "APP NOT READY"

# Open browser via agent-browser
agent-browser open http://localhost:3000

# Take initial snapshot to confirm load
agent-browser snapshot -i

# Expected: Accessibility tree with page elements and @eN references
# If login page: proceed to auth flow below
```

#### Generic Auth Flow (If App Requires Login)

```bash
# Snapshot to find login form elements
agent-browser snapshot -i

# Find email/username input (@eN), password input (@eM), submit button (@eK)
# Replace placeholders with actual test credentials
agent-browser fill @eN "test@example.com"
agent-browser fill @eM "testpassword"
agent-browser click @eK
agent-browser wait --load networkidle
agent-browser snapshot -i

# Verify: dashboard or home page loaded
```

---

### 6.3 Create Test Task List

Based on Sub-Agent A's user journeys and Sub-Agent C's bug list, generate a test task list:

```markdown
## E2E Test Tasks

### Core Journeys
- [ ] J1: {journey_name} — {steps}
- [ ] J2: {journey_name} — {steps}
- [ ] ...

### Bug Verification (from Sub-Agent C)
- [ ] B1: Verify {potential_bug} does/doesn't manifest
- [ ] B2: ...

### Responsive Testing
- [ ] R1: Mobile (375×812) — key pages render correctly
- [ ] R2: Tablet (768×1024) — layout adapts
- [ ] R3: Desktop (1440×900) — full layout

### Data Integrity
- [ ] D1: After {action}, verify DB state with query from Sub-Agent B
- [ ] D2: ...
```

---

### 6.4 Execute User Journey Tests

For each journey task, follow this exact cycle:

#### Step 1: Snapshot & Orient

```bash
agent-browser snapshot -i
# Read the accessibility tree. Identify target elements by @eN refs.
# DO NOT guess element refs — always snapshot first.
```

#### Step 2: Interact

```bash
# Click navigation, buttons, links:
agent-browser click @eN

# Fill form fields:
agent-browser fill @eN "value"

# Select dropdowns:
agent-browser select @eN "option_value"

# Press keys (e.g., Enter, Escape, Tab):
agent-browser press Enter

# Wait for page to settle after any interaction:
agent-browser wait --load networkidle
```

#### Step 3: Capture Evidence

```bash
# Screenshot after each significant interaction:
mkdir -p /tmp/e2e-screenshots/{journey_name}
agent-browser screenshot /tmp/e2e-screenshots/{journey_name}/step-{N}.png

# Check for console errors:
agent-browser errors
# If errors found → document in ISSUES.md, attempt fix

# Check console logs for relevant output:
agent-browser console
```

#### Step 4: Visual Analysis

```bash
# Read the screenshot to verify:
Read(/tmp/e2e-screenshots/{journey_name}/step-{N}.png)

# Check:
# - Layout renders correctly (no overlap, no missing elements)
# - Data displays as expected (correct values, correct order)
# - Interactive state is correct (active tab, selected item, open modal)
# - No error messages visible
# - Loading states resolved
```

#### Step 5: Database Validation (After Data-Modifying Actions)

```bash
# After creates, updates, deletes — verify DB state:
# Use query from Sub-Agent B's validation queries

# PostgreSQL example:
psql "$DATABASE_URL" -c "SELECT id, status, created_at FROM {table} ORDER BY created_at DESC LIMIT 3;"

# MySQL example:
mysql -u root -p -e "SELECT id, status, created_at FROM {table} ORDER BY created_at DESC LIMIT 3;"

# Verify:
# - Record exists with expected values
# - Timestamps are recent
# - Foreign keys resolve correctly
# - If RLS enabled: add tenant context to WHERE clause
```

#### Step 6: Fix-in-Place (If Issues Found)

```bash
# If a test step reveals a bug:
# 1. Document the issue
echo "## Issue: {description}" >> .uop/sessions/{id}/ISSUES.md
echo "- Journey: {journey_name}, Step: {N}" >> .uop/sessions/{id}/ISSUES.md
echo "- Screenshot: /tmp/e2e-screenshots/{journey_name}/step-{N}.png" >> .uop/sessions/{id}/ISSUES.md

# 2. Fix the code (if within iteration budget — max 3 attempts per OP Mode rules)
# 3. Restart app if needed
# 4. Re-test the same step
# 5. Capture confirmation screenshot: step-{N}-fixed.png
```

**Repeat Steps 1-6 for every journey step, then move to next journey.**

---

### 6.5 Responsive Testing

After all journeys pass, test key pages at 3 viewports:

```bash
# Mobile
agent-browser set viewport 375 812
agent-browser open {page_url}
agent-browser wait --load networkidle
agent-browser screenshot /tmp/e2e-screenshots/responsive/mobile-{page}.png

# Tablet
agent-browser set viewport 768 1024
agent-browser open {page_url}
agent-browser wait --load networkidle
agent-browser screenshot /tmp/e2e-screenshots/responsive/tablet-{page}.png

# Desktop
agent-browser set viewport 1440 900
agent-browser open {page_url}
agent-browser wait --load networkidle
agent-browser screenshot /tmp/e2e-screenshots/responsive/desktop-{page}.png

# Verify each screenshot:
# - No horizontal scroll on mobile
# - Navigation collapses/hamburger on mobile
# - Tables adapt (scroll or stack) on small screens
# - Modals don't overflow viewport
# - Text remains readable (no truncation)
```

#### Browser Cleanup (After All Journeys + Responsive Tests)

```bash
# Close the browser session
agent-browser close

# Stop the application server
kill $APP_PID 2>/dev/null || true
```

---

### 6.6 Mandatory Unit Test Generation (Preserved from v2.1.0)

For every implementation, also generate unit/integration tests:

1. **Happy Path Test** — Primary use case works
2. **Edge Case Test #1** — Boundary condition
3. **Edge Case Test #2** — Error handling / empty state

```
Task(
  subagent_type="general-purpose",
  prompt="Generate tests for: {implemented_feature}\n\nRequired:\n- 1 happy path\n- 2 edge cases\n\nContext:\n{feature_requirements}"
)
```

```bash
# Run generated tests
npm test -- --testPathPattern="{feature_test_pattern}"
```

---

### 6.7 Self-Test Checklist (MANDATORY before Phase 7)

```markdown
## Pre-Return Checklist

### E2E Browser Validation
- [ ] All user journeys executed and screenshotted
- [ ] No unresolved console errors (`agent-browser errors` returns clean)
- [ ] All data-modifying actions verified against DB
- [ ] Responsive testing passed at 3 viewports (mobile/tablet/desktop)
- [ ] All Sub-Agent C bugs either confirmed fixed or documented as acceptable

### Code Quality (Preserved from v2.1.0)
- [ ] All generated unit tests pass
- [ ] No TypeScript/lint errors (`npm run build` / `npm run lint`)
- [ ] No console errors in browser

### Documentation (Preserved from v2.1.0)
- [ ] Decision tree updated
- [ ] Issues documented with solutions
- [ ] MCP log complete
- [ ] Screenshots saved to /tmp/e2e-screenshots/

### Summary Stats
- Journeys tested: {N}
- Screenshots captured: {N}
- Issues found: {N}
- Issues fixed inline: {N}
- Issues deferred: {N}
- DB validations passed: {N}
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

### Changes Summary (from .uop/sessions/{id}/CHANGES.md)
- **Total files modified**: {N}
- **HIGH risk changes**: {N} ← if > 0, recommend human review
- **Changes without tests**: {N} ← if > 0, flag as tech debt
- **Lines added**: {N}
- **Lines removed**: {N}
- **Lines modified**: {N}

### RLM Updates Made
- Patterns saved: {list}
- Decisions logged: {list}
- Issues documented: {list}

---
**Ready for your review and approval.**
```

---

### Optional: Learning Summary (E-12)

**Include this section when:**
- User says "explain what you did" or "teach me" or "what should I understand?"
- Session involved a pattern the user hasn't seen before (new architecture, library, DB concept)
- First 3 sessions of a new project

```markdown
## What I Did & Why (Learning Summary)

### The Big Picture
{1-2 paragraphs in plain English — what was built and why it matters,
as if explaining to a smart person who doesn't code}

### Key Concepts You Should Know
{3-5 concepts introduced or used, each in 2-3 sentences}

Example:
- **RLS (Row-Level Security):** This is how PostgreSQL hides data between
  tenants. Each row has a tenant_id, and the database automatically filters
  queries so Tenant A never sees Tenant B's data. You don't need to add
  WHERE clauses manually — the policy does it.

- **Webhook Verification:** When a service sends data to your server,
  it signs the request with a secret. Your server checks that signature to
  make sure the request actually came from the service and not an attacker.
  This is the HMAC-SHA256 check in webhook routes.

### Decisions I Made (and why)
| What I Decided | Why | What The Alternative Was |
|----------------|-----|------------------------|
| {decision} | {plain English reasoning} | {what I didn't do and why} |

### If You Need To Change This Later
{1-2 sentences about what to look for and what's safe to modify vs what's fragile}

Example: "The webhook route is safe to modify — just make sure you keep the
HMAC verification at the top. If you remove it, anyone could send fake
data to your server."

### Files To Understand
| File | What It Does | Read This If You Need To... |
|------|-------------|---------------------------|
| {path} | {plain English} | {scenario when you'd touch it} |
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
| UI-NAV | Browser navigation (agent-browser) |
| UI-CHECK | Browser validation (agent-browser) |
| UI-ACTION | Browser interaction (agent-browser) |
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

## Utilities & System Patterns

### Utility: Human Handoff Package Generator

#### When to trigger:
- User says "hand this off" or "create a prompt for my developer"
- Task is blocked and Option C (escalate to human) is chosen
- User wants to continue work in a different tool (Cursor, Windsurf, etc.)

#### Auto-generate: `.uop/handoffs/handoff-{task-id}.md`

```markdown
# Developer Handoff: {task_name}

## Status: {IN_PROGRESS | BLOCKED | READY_FOR_REVIEW}

## What This Task Is
{1-2 sentence plain English description}

## What's Been Done
{Numbered list of completed steps}

## What Still Needs Doing
{Numbered list of remaining steps — be specific with file paths}

## Key Files
| File | Role | Notes |
|------|------|-------|
| {path} | {what it does} | {any gotchas} |

## Correction Notes (IMPORTANT)
{Any known issues, wrong assumptions, or things to watch for}
{Example: "Steps 4b, 4c reference Service X — replace with Service Y"}
{Example: "Migration 037 may conflict with existing 037 — check numbering"}

## Environment Setup
- Node version: {version}
- Database: {connection info or env var name}
- Required env vars: {list}
- Start command: {command}

## Test Commands
{How to verify the work — specific commands, not vague instructions}

## Decisions Already Made
| Decision | Rationale |
|----------|-----------|
| {what was decided} | {why} |

## Known Issues / Risks
| Issue | Severity | Workaround |
|-------|----------|------------|
| {issue} | {HIGH/MED/LOW} | {workaround if any} |
```

**Rules:**
- ALWAYS include Correction Notes even if empty ("None identified")
- File paths must be relative to project root
- Test commands must be copy-pasteable (no placeholders)
- If handing off a blocked task, include all 3 failed attempt details

---

### System: Checkpoint & Resume v2

#### 1. Phase-Boundary Checkpoints

After EVERY phase completion, auto-write: `.uop/sessions/{id}/CHECKPOINT.md`

```markdown
# OP Mode Checkpoint
Session: {id}
Phase: {N} {phase_name}
Time: {ISO timestamp}

## Task
{full task description}

## What's Complete
{numbered list with file paths}

## What's Next
{next phase or next steps}

## Key Context to Restore
{critical decisions, patterns, or state that MUST be remembered}

## Files Modified This Session
{list with paths and change types}

## Resume Command
Read .uop/sessions/{id}/PLAN.md and continue from {next_step}
```

#### 2. Heartbeat Checkpoints (Mid-Phase)

Every **10 tool calls** during Phase 5 or Phase 6, auto-write: `.uop/sessions/{id}/HEARTBEAT.md`

```markdown
# Heartbeat: {timestamp}
# Session: {id}
# Phase: {current_phase}
# Tool calls since last heartbeat: {count}

## I am currently:
{1 sentence — what the AI is doing right now}

## Working on file:
{file_path} (lines {range})

## Current approach:
{2-3 sentences — what strategy is being used}

## Iteration state:
- Attempt {N} of 3 on: {current issue}
- Last error: {error message or "none"}

## Files modified since last checkpoint:
{list with paths}

## Next step if interrupted:
{exact next action — specific enough to resume cold}
```

#### 3. Emergency Pre-Compaction Save

Write this when ANY of these signals appear:
- Conversation has exceeded 40 tool calls
- Multiple large files (>500 lines) have been read in this session
- The user says "continue from where you left off" (implies prior compaction)
- Session has been running for more than 30 minutes of active work

Auto-write: `.uop/sessions/{id}/EMERGENCY_SAVE.md`

```markdown
# EMERGENCY SAVE: Context approaching limit
# Timestamp: {ISO timestamp}
# Session: {id}

## CRITICAL STATE (do not lose this):

### Task
{full task description — not abbreviated}

### What's done
{numbered list of completed steps with file paths}

### What's in progress
{exact current action — file, line range, approach}

### What's NOT done
{numbered list of remaining steps}

### Current errors/blockers
{exact error messages if any — copy verbatim, do not summarize}

### Key decisions made this session
| Decision | Rationale | Reversible? |
|----------|-----------|-------------|
| {decision} | {why} | {yes/no} |

### Files touched (with state)
| File | State | Notes |
|------|-------|-------|
| {path} | {CLEAN / MODIFIED / HALF-DONE / BROKEN} | {what's incomplete} |

### Resume prompt (copy-paste this into a new session):

"I'm resuming OP Mode session {id} after context compaction.

READ THESE FILES FIRST (in this order):
1. .uop/sessions/{id}/EMERGENCY_SAVE.md ← you are here
2. .uop/sessions/{id}/PLAN.md
3. .uop/sessions/{id}/ISSUES.md
4. .uop/sessions/{id}/CHANGES.md
5. .uop/sessions/{id}/HEARTBEAT.md

CURRENT STATE:
- Phase: {N}
- Current file: {path}
- Current approach: {approach}
- Next action: {exact next step}

DO NOT re-read the full codebase. DO NOT re-plan.
Pick up exactly where the last session stopped."
```

#### 4. Session Continuity Rules

These rules MUST be followed in every resumed session:

- **DO NOT** re-read files that were already read in the previous session (the checkpoint tells you what was read)
- **DO NOT** re-plan unless the user explicitly asks
- **DO NOT** re-run successful tests (only re-run failed or new tests)
- **DO** re-read the `PLAN.md` (it's compact and keeps you aligned)
- **DO** re-read `ISSUES.md` (you need to know what's still open)
- **Start work within 2 tool calls of resuming.** Not 10. Not 20. TWO. (Read checkpoint → read plan → start working)

---

### System: Failure Mode Journal

**File:** `.uop/failures.md`

#### When to write an entry:
- After fixing any bug during Implementation (Phase 5)
- After any validation failure in Phase 6
- After any 3-attempt escalation
- After any production incident

#### Entry format:

```markdown
### F-{number}: {Short description}
**Date:** {date}
**Category:** {IMPORT_PATH | DEPENDENCY | SCHEMA | RLS | CONFIG | LOGIC | ASYNC | TYPE}
**Files affected:** {paths}

**Symptom:**
{What the error looked like — exact error message if available}

**Root cause:**
{What was actually wrong — 1-2 sentences}

**Fix:**
{What was changed — be specific}

**Prevention rule:**
{How to avoid this class of error in the future}

**Example:**
"Always verify import paths match the actual directory structure.
Common pattern: ../db vs ../utils/db when utils/ subdirectory exists."
```

#### How the journal is used:

**During Phase 5 (Implementation):**
Before writing code that touches a file, check `failures.md` for entries matching that file or category. If a known failure pattern exists, apply the prevention rule proactively.

**During Phase 6 (Validation):**
If a test fails, check `failures.md` BEFORE attempting a fix. If the failure matches a known pattern → apply known fix immediately (does not count toward the 3-attempt limit).

**Periodic Review:**
Every 5 sessions, scan `failures.md` for clusters. If 3+ entries share a category, flag it: "Recurring {CATEGORY} issues suggest a systemic problem. Consider architectural fix."

#### Starter entry template (replace with project-specific examples):

```markdown
### F-001: Generic import path error
**Category:** IMPORT_PATH
**Symptom:** Module not found: ../module
**Root cause:** File was in subdirectory but import assumed flat structure
**Fix:** Changed import path to match actual directory structure
**Prevention:** Always check actual directory structure before writing imports.
```

---

### Utility: Doc Freshness Scanner

#### When it runs:
- Automatically at the start of any FULL MODE session (Gate 0, after Step 0.0)
- Automatically before generating a Human Handoff Package
- On-demand when user says "check my docs" or "are my docs current?"

#### What it does:

**Step 1: Build doc inventory**
Scan `/docs` for all `.md` files. For each:
- Filename
- Last modified date (from git or filesystem)
- Age in days

**Step 2: Staleness check**
- Flag any doc older than 30 days as **STALE**
- Flag any doc older than 90 days as **VERY_STALE**

**Step 3: Contradiction scan**
For each doc, check for references to:
- Deprecated services (scan for known deprecated terms from `.uop/deprecated-terms.json`)
- Changed API endpoints
- Renamed files or moved paths
- Old migration numbers that no longer exist

**Step 4: Report to user**

```markdown
## Doc Freshness Report

### Stale Docs (>30 days since update)
| Doc | Age | Contradiction Found? |
|-----|-----|---------------------|
| {filename} | {N} days | {YES: "references {old_service}" / NO} |

### Contradictions Found
| Doc | Line | Issue | Suggested Fix |
|-----|------|-------|---------------|
| {file} | {line} | Contains "{old_term}" | Replace with "{new_term}" |

### Recommended Actions
1. UPDATE: {list of docs that need content updates}
2. ARCHIVE: {list of docs that are fully obsolete}
3. OK: {count of docs that are current}
```

#### Maintaining the scanner:

When any service migration or major refactor happens, add the old term to `.uop/deprecated-terms.json`:

```json
{
  "deprecated": [
    {
      "old": "old-service-name",
      "new": "new-service-name",
      "date": "2026-02-15",
      "category": "service-migration"
    },
    {
      "old": "deprecated-api-pattern",
      "new": "current-api-pattern",
      "date": "2026-01-20",
      "category": "api-change"
    }
  ]
}
```

---

**Begin OP Mode workflow when user provides task description.**

**Remember: Gates are not suggestions. They are requirements.**
