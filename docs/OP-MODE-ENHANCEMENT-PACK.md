# OP Mode Enhancement Pack v1.0

> **Purpose:** Seven targeted upgrades to OP Mode v2.1.0, each solving a real problem Romeo has hit during Heartbeat AI development. These are drop-in patches — each section says exactly where it goes in `commands/op-mode/SKILL.md`.
>
> **How to apply:** Work through each enhancement in order. Enhancements 1-3 modify Gate 0 / Phase 0. Enhancements 4-5 modify Phases 5-6. Enhancements 6-7 are new utility systems that plug into the `.uop/` memory layer.

---

## Enhancement 1: Gate 0 Light Mode Bypass

### Problem it solves
Running 7 phases for a one-line CSS fix wastes 10 minutes and thousands of tokens. You've said it yourself — OP Mode is overkill for small stuff.

### Where it goes
**INSERT** at the very top of Gate 0, before Step 0.1 (Read Skill Files). This becomes the first decision OP Mode makes.

### The patch

```markdown
### Step 0.0: Task Sizing (Light Mode Check)

Before loading any skill files, assess the incoming task:

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

If LIGHT MODE:
  → Log task to .uop/sessions/{id}/PROGRESS_STATE.md as "LIGHT MODE"
  → Skip Phases 1-4
  → Go directly to Phase 5 (Implementation)
  → Run Phase 6 (Validation) — still mandatory, even for quick fixes
  → Run Phase 7 (Final Report) — abbreviated format (3 lines max)

If FULL MODE:
  → Continue to Step 0.1 as normal
```

---

## Enhancement 2: TDD Enforcement in Phase 5

### Problem it solves
Heartbeat AI has zero automated tests. Every code change is a gamble. When you have multiple SaaS products, this doesn't scale — you can't manually verify everything across every app every time.

### Where it goes
**INSERT** at the beginning of Phase 5 (Implementation), before any code is written.

### The patch

```markdown
### 5.0 Test-First Gate (Mandatory)

Before writing ANY implementation code, you MUST:

#### Step 1: Write the failing test

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

#### Step 2: Verify the test fails (RED)

npm test -- --testPathPattern="{test_file}"

# Expected: FAIL
# If the test PASSES before you write code → your test is wrong
# A passing test that doesn't test anything is worse than no test

#### Step 3: Write the minimum code to pass (GREEN)

# Now implement. Write ONLY enough code to make the test pass.
# Do not add "nice to have" features. Do not optimize.
# YAGNI: You Aren't Gonna Need It.

#### Step 4: Verify the test passes

npm test -- --testPathPattern="{test_file}"

# Expected: PASS
# If FAIL → fix the code, not the test (unless the test has a bug)

#### Step 5: Refactor (if needed)

# Clean up the code. The test protects you from breaking anything.
# Run the test again after any cleanup.

#### When TDD is NOT required (Light Mode exceptions):
# - Config changes (env vars, package.json metadata)
# - Documentation-only changes
# - CSS-only visual tweaks (use screenshot validation instead)
# - One-line bug fixes where the bug is already covered by existing test

#### Test file naming convention:
# {source-filename}.test.js  (unit tests)
# {feature-name}.e2e.js      (end-to-end tests)

#### Minimum coverage per feature:
# 1 happy path test          (the thing works as intended)
# 1 edge case test           (boundary condition or empty state)
# 1 error handling test      (what happens when input is bad)
```

---

## Enhancement 3: 3-Failure Architectural Stop Rule

### Problem it solves
When the AI tries to fix something 4 times and fails, the problem isn't the fix — it's the approach. Recognizing this earlier saves tokens, time, and frustration.

### Where it goes
**REPLACE** the iteration limit in your `reference/iteration-protocol.md`. Change from 4 attempts to 3, and update the framing.

### The patch

```markdown
## Iteration Limits

### Maximum Attempts Per Issue: 3 (was 4)

**Attempt 1:** Apply the most obvious fix based on the error message.
**Attempt 2:** Step back. Re-read the error. Check if the fix attempt changed the error or just moved it. Try a different approach.
**Attempt 3:** This is the last attempt. If this fails, STOP.

### After 3 Failed Attempts — MANDATORY STOP

DO NOT attempt a 4th fix. Instead:

1. **Frame it as architectural:**
   "This is not a bug. This is an architectural problem that requires a different approach."

2. **Document what was tried:**
   | Attempt | What Was Tried | Result |
   |---------|---------------|--------|
   | 1 | {description} | {error} |
   | 2 | {description} | {error} |
   | 3 | {description} | {error} |

3. **Present to user with options:**
   - Option A: Redesign the approach (go back to Phase 3)
   - Option B: Defer this item and continue with other tasks
   - Option C: Escalate to human developer with handoff package

4. **Log to .uop/sessions/{id}/ISSUES.md:**
   Status: BLOCKED_ARCHITECTURAL
   Attempts: 3/3
   Pattern: {what class of problem this is}

### Circular Fix Detection

If the current fix attempt is >70% similar to a previous attempt
(same files, same lines, same type of change) → STOP IMMEDIATELY.
Do not count this as an attempt. Flag it:

"I'm going in circles. The same fix keeps being tried and reverted.
This needs a fundamentally different approach."

### The Key Mindset Shift

3 failures on the same issue means:
- The error message is misleading, OR
- The root cause is deeper than the symptom, OR
- The architecture doesn't support what you're trying to do

In ALL three cases, more patching makes it worse.
```

---

## Enhancement 4: Human Handoff Package Generator

### Problem it solves
You constantly write cursor prompts for your developer — like the Sprint 15 handoff, the MVP Phase 1 handoff, the ElevenLabs corrections. OP Mode should auto-generate these so you don't have to ask me every time.

### Where it goes
**NEW ACTION** — callable at any phase. Add as a utility command in the SKILL.md after Phase 7.

### The patch

```markdown
## Utility: Human Handoff Package

### When to trigger:
- User says "hand this off" or "create a prompt for my developer"
- Task is blocked and Option C (escalate to human) is chosen
- User wants to continue work in a different tool (Cursor, Windsurf, etc.)

### Auto-generate: .uop/handoffs/handoff-{task-id}.md

Template:

---
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
{Example: "Steps 4b, 4c, and 7 reference Retell AI — replace with ElevenLabs"}
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
---

### Rules:
- ALWAYS include Correction Notes even if empty ("None identified")
- File paths must be relative to project root
- Test commands must be copy-pasteable (no placeholders)
- If handing off a blocked task, include all 3 failed attempt details
```

---

## Enhancement 5: Checkpoint & Resume System

### Problem it solves
This is the #1 practical problem. You hit context compaction constantly — this very conversation is a resumed session. Every time context resets, state is lost. OP Mode should protect against this by auto-saving progress.

### Where it goes
**INSERT** between every phase boundary. Also add a **context pressure trigger** that fires proactively.

### The patch

```markdown
## System: Checkpoint & Resume

### How It Works

After EVERY phase completion, auto-write:

.uop/sessions/{id}/CHECKPOINT.md

Template:

---
# Checkpoint: Phase {N} Complete
# Timestamp: {ISO timestamp}
# Session: {id}
# Task: {one-line description}

## Completed Phases
- [x] Phase {1}: {summary — 1 sentence}
- [x] Phase {2}: {summary — 1 sentence}
- [ ] Phase {N+1}: {what's next}

## Current State
- Files modified: {list with paths}
- Tests status: {PASSING / FAILING / NOT_YET_WRITTEN}
- Blockers: {none or description}

## Resume Instructions
To continue this task in a new session:

1. Read this file: .uop/sessions/{id}/CHECKPOINT.md
2. Read the plan: .uop/sessions/{id}/PLAN.md
3. Read open issues: .uop/sessions/{id}/ISSUES.md
4. Current phase: Phase {N+1}
5. Next action: {exact next step — be specific}

## Quick Resume Prompt
Copy-paste this to start a new session:

"Resume OP Mode session {id}. Read .uop/sessions/{id}/CHECKPOINT.md
for full context. Current phase: {N+1}. Next action: {next step}."
---

### Context Pressure Auto-Save

When approaching context window limits (conversation feels long, multiple
large file reads, many tool calls), PROACTIVELY write a checkpoint even
if mid-phase:

.uop/sessions/{id}/EMERGENCY_CHECKPOINT.md

This includes everything above PLUS:
- Exact line being worked on
- Partial implementation state
- "I was in the middle of: {description}"

### Resume Protocol (New Session)

When a session starts and finds .uop/sessions/{id}/CHECKPOINT.md:

1. Read the checkpoint file
2. Present to user: "Found checkpoint from {timestamp}. Task: {description}.
   Phase {N} was completed. Ready to continue with Phase {N+1}?"
3. If user confirms → skip to Phase {N+1} with checkpoint context
4. If user says "start fresh" → archive checkpoint to .uop/history/
```

---

## Enhancement 6: Failure Mode Journal

### Problem it solves
The `kb-sync.js` import path bug (`../db` instead of `../utils/db`) was solved once. But if the same *class* of mistake happens in another file next month, nobody remembers the fix. The journal creates institutional memory for error patterns.

### Where it goes
**NEW FILE** in the `.uop/` memory system. Referenced during Phase 5 (Implementation) and Phase 6 (Validation).

### The patch

```markdown
## System: Failure Mode Journal

### File: .uop/failures.md

### When to write an entry:
- After fixing any bug during Implementation (Phase 5)
- After any validation failure in Phase 6
- After any 3-attempt escalation
- After any production incident

### Entry format:

---
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
---

### How the journal is used:

#### During Phase 5 (Implementation):
Before writing code that touches a file, check failures.md for entries
matching that file or category. If a known failure pattern exists,
apply the prevention rule proactively.

#### During Phase 6 (Validation):
If a test fails, check failures.md BEFORE attempting a fix.
If the failure matches a known pattern → apply known fix immediately
(does not count toward the 3-attempt limit).

#### Periodic Review:
Every 5 sessions, scan failures.md for clusters. If 3+ entries share
a category, flag it: "Recurring {CATEGORY} issues suggest a systemic
problem. Consider architectural fix."

### Starter entries for Heartbeat AI:

### F-001: Wrong import path in kb-sync.js
**Category:** IMPORT_PATH
**Symptom:** Module not found: ../db
**Root cause:** File was in services/ but db utility lived in utils/db
**Fix:** Changed import from ../db to ../utils/db
**Prevention:** Always check actual directory structure before writing imports.
Fastify project convention: utilities live in src/utils/, not src/.

### F-002: Retell references after ElevenLabs migration
**Category:** CONFIG
**Symptom:** Stale Retell API endpoints in cursor prompts and config
**Root cause:** Migration to ElevenLabs didn't update all documentation
**Fix:** Grep for "retell" across all docs and replace with ElevenLabs equivalents
**Prevention:** After any service migration, run project-wide search for old
service name in: code, docs, env vars, cursor prompts, and test fixtures.
```

---

## Enhancement 7: Change Tracking (Diff Summaries)

### Problem it solves
When the AI modifies a 9,312-line file, you can't meaningfully review a git diff. You need a human-readable summary of what changed and why — especially for handoffs and learning.

### Where it goes
**INSERT** into Phase 5 (Implementation), after any file modification. Auto-generated, not manual.

### The patch

```markdown
### Implementation Change Log

After EVERY file modification during Phase 5, auto-append to:

.uop/sessions/{id}/CHANGES.md

Entry format:

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
{Example: "Added phone number validation so customers can't book
appointments with invalid numbers, which was causing SMS delivery failures."}

**What could break:**
{Honest assessment — what other parts of the system might be affected}
{If nothing: "Low risk — isolated change with no downstream dependencies."}

**Test covering this change:**
{test file and test name, or "NONE — needs test" if TDD was skipped}
---

### Rules:
- EVERY file modification gets an entry. No exceptions.
- "What changed" must be understandable by someone who doesn't code.
- "Why" must reference the business need, not the technical implementation.
- Risk level HIGH triggers automatic human review before Phase 7.
- Changes with "NONE — needs test" are flagged in the Phase 6 checklist.

### Summary at Phase 7:

In the Final Report, include a CHANGES SUMMARY:

## Changes Summary
- Total files modified: {N}
- HIGH risk changes: {N} ← if > 0, recommend human review
- Changes without tests: {N} ← if > 0, flag as tech debt
- Lines added: {N}
- Lines removed: {N}
- Lines modified: {N}
```

---

## Installation Order

Apply these in this order for minimal disruption:

| # | Enhancement | What to Modify | Effort |
|---|-------------|----------------|--------|
| 1 | Gate 0 Light Mode | Add Step 0.0 to SKILL.md | 5 min |
| 2 | 3-Failure Stop | Replace iteration-protocol.md | 5 min |
| 3 | Checkpoint & Resume | Add between phases in SKILL.md + .uop/ template | 15 min |
| 4 | Failure Mode Journal | Create .uop/failures.md + add references in Phases 5-6 | 10 min |
| 5 | TDD Gate | Insert Phase 5.0 in SKILL.md | 10 min |
| 6 | Change Tracking | Insert into Phase 5 + Phase 7 summary | 10 min |
| 7 | Human Handoff | Add utility section after Phase 7 | 10 min |

**Total effort: ~65 minutes of editing your SKILL.md and reference docs.**

---

## What OP Mode Looks Like After All Enhancements

```
Gate 0: Step 0.0 (Light Mode Check) → Steps 0.1-0.5 (unchanged)
Phase 1: Session Init (unchanged)
Phase 2: RLM Query (unchanged)
Phase 3: Planning (unchanged)
Phase 4: Plan Approval — User Touchpoint 1 (unchanged)
Phase 5: Implementation
  → 5.0 TDD Gate (NEW — write test first)
  → 5.1-N Implementation (unchanged)
  → Auto: Change Tracking after every file modification (NEW)
  → Auto: Failure Journal check before touching known-failure files (NEW)
  → Iteration limit: 3 attempts, architectural stop (UPDATED)
Phase 6: E2E Agent-Browser Validation (ALREADY UPGRADED — Phase 6 E2E doc)
Phase 7: Final Report — User Touchpoint 2
  → Changes Summary included (NEW)
  → Checkpoint cleared on completion (NEW)

Utilities (callable anytime):
  → Human Handoff Package Generator (NEW)
  → Checkpoint & Resume System (NEW — auto-fires between phases)

.uop/ Memory (expanded):
  → sessions/{id}/CHECKPOINT.md (NEW)
  → sessions/{id}/CHANGES.md (NEW)
  → failures.md (NEW — project-level, persists across sessions)
  → handoffs/handoff-{task-id}.md (NEW — on demand)
```

---

*Generated: February 26, 2026 | OP Mode Enhancement Pack v1.0 | Heartbeat AI*

---
---

# Enhancement Pack v1.1 — Additional Upgrades

> **Context:** After v1.0, Romeo asked to go deeper — find every edge case that would help a no-code developer get through real situations. These 5 additions address problems that actually happened during Heartbeat AI development: stale docs surviving for weeks, migration numbering conflicts, skills that never get triggered, context compaction losing critical state, and needing OP Mode to work across multiple SaaS products.

---

## Enhancement 8: Checkpoint & Resume v2 (Strengthened)

### Why v1 isn't enough
Enhancement 5 writes checkpoints between phases. But the real problem is harder: context compaction happens MID-PHASE (not between phases), and when you say "continue from where you left off," the compaction summary often drops critical details like which files were half-modified, what the current error was, and what approach was being tried.

### Where it goes
**REPLACE** Enhancement 5's checkpoint patch entirely with this expanded version.

### The patch

```markdown
## System: Checkpoint & Resume v2

### 1. Phase-Boundary Checkpoints (same as v1)

After EVERY phase completion, auto-write:
.uop/sessions/{id}/CHECKPOINT.md
(Template unchanged from v1)

### 2. Heartbeat Checkpoints (NEW — mid-phase)

Every 10 tool calls during Phase 5 (Implementation) or Phase 6 (Validation),
auto-write a lightweight heartbeat:

.uop/sessions/{id}/HEARTBEAT.md

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

### 3. Emergency Pre-Compaction Save (NEW — auto-triggered)

OP Mode should write an emergency checkpoint when ANY of these signals appear:
- Conversation has exceeded 40 tool calls
- Multiple large files (>500 lines) have been read in this session
- The user says "continue from where you left off" (implies prior compaction)
- Session has been running for more than 30 minutes of active work

When triggered, write:

.uop/sessions/{id}/EMERGENCY_SAVE.md

---
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
---

### 4. Auto-Resume Detection (NEW — session start behavior)

When OP Mode starts a new session, BEFORE doing anything else:

1. Check: Does .uop/sessions/ contain any non-archived checkpoints?
2. If YES:
   a. Find the most recent CHECKPOINT.md, HEARTBEAT.md, or EMERGENCY_SAVE.md
   b. Read it silently
   c. Present to user:

   "I found a checkpoint from {timestamp}.
   Task: {description}
   Status: Phase {N}, {what was happening}

   Options:
   A) Resume from checkpoint (recommended)
   B) Start fresh (archives the checkpoint)
   C) Review checkpoint before deciding"

3. If user picks A → load checkpoint context, skip to the right phase
4. If user picks B → move checkpoint to .uop/history/archived/
5. If user picks C → display checkpoint contents, then ask A or B

### 5. Session Continuity Rules

These rules MUST be followed in every resumed session:

- DO NOT re-read files that were already read in the previous session
  (the checkpoint tells you what was read)
- DO NOT re-plan unless the user explicitly asks
- DO NOT re-run successful tests (only re-run failed or new tests)
- DO re-read the PLAN.md (it's compact and keeps you aligned)
- DO re-read ISSUES.md (you need to know what's still open)
- Start work within 2 tool calls of resuming. Not 10. Not 20. TWO.
  (Read checkpoint → read plan → start working)
```

---

## Enhancement 9: Doc Freshness Scanner

### Problem it solves
You have 85+ docs in /docs. After the ElevenLabs migration, at least 3 documents still referenced Retell for weeks. Nobody caught it until I manually reviewed them. This scanner catches stale references automatically.

### Where it goes
**NEW UTILITY** — runs at session start (Gate 0) or on-demand. Also fires automatically before any Human Handoff (Enhancement 4).

### The patch

```markdown
## Utility: Doc Freshness Scanner

### When it runs:
- Automatically at the start of any FULL MODE session (Gate 0, after Step 0.0)
- Automatically before generating a Human Handoff Package
- On-demand when user says "check my docs" or "are my docs current?"

### What it does:

#### Step 1: Build doc inventory
Scan /docs for all .md files. For each:
- Filename
- Last modified date (from git or filesystem)
- Age in days

#### Step 2: Staleness check
Flag any doc older than 30 days as STALE.
Flag any doc older than 90 days as VERY_STALE.

#### Step 3: Contradiction scan
For each doc, check for references to:
- Deprecated services (scan for known deprecated terms)
- Changed API endpoints
- Renamed files or moved paths
- Old migration numbers that no longer exist

Known deprecated terms for Heartbeat AI:
- "retell" → should be "elevenlabs"
- "per-character billing" → should be "per-minute billing"
- (Add project-specific terms to .uop/deprecated-terms.json)

#### Step 4: Report to user

## Doc Freshness Report

### Stale Docs (>30 days since update)
| Doc | Age | Contradiction Found? |
|-----|-----|---------------------|
| {filename} | {N} days | {YES: "references Retell" / NO} |

### Contradictions Found
| Doc | Line | Issue | Suggested Fix |
|-----|------|-------|---------------|
| {file} | {line} | Contains "{old_term}" | Replace with "{new_term}" |

### Recommended Actions
1. UPDATE: {list of docs that need content updates}
2. ARCHIVE: {list of docs that are fully obsolete}
3. OK: {count of docs that are current}

### Maintaining the scanner:
When any service migration or major refactor happens, add the old term
to .uop/deprecated-terms.json:

{
  "deprecated": [
    {"old": "retell", "new": "elevenlabs", "date": "2025-12-15"},
    {"old": "per-character billing", "new": "per-minute billing", "date": "2025-12-15"}
  ]
}
```

---

## Enhancement 10: Skill Auto-Discovery

### Problem it solves
You created a git workflow skill. It never gets used because nothing tells OP Mode it exists. The same will happen with the E2E skill, the TDD gate, and any future skills unless there's an auto-discovery system.

### Where it goes
**MODIFY Gate 0 Step 0.1** to auto-scan for skills instead of relying on a hardcoded list.

### The patch

```markdown
### Step 0.1: Skill Discovery (REPLACES hardcoded skill list)

Instead of a static list of skill files, OP Mode now SCANS for skills:

#### Auto-scan locations (check all, in order):
1. .claude/skills/         ← project-level custom skills
2. .claude/commands/       ← installed OP Mode commands
3. .skills/skills/         ← Cowork/plugin skills
4. .local-plugins/         ← marketplace plugins

#### For each skill found:
Read the SKILL.md (first 50 lines only — just the description/triggers section).
Build a runtime skill manifest:

.uop/skill-manifest.json

{
  "skills": [
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

#### Skill matching during execution:
At the start of EACH phase, check the skill manifest:
- Does any skill's trigger keywords match the current task?
- Does any skill have phase_affinity matching the current phase?

If YES → Load that skill's SKILL.md and follow its instructions
If MULTIPLE match → Load all, in order of phase_affinity relevance

#### Example:
User says: "commit the changes and push"
→ Matches trigger "commit" → loads disciplined-git-workflow
→ No full OP Mode phases needed → Light Mode + skill execution

User starts Phase 6 (Validation):
→ e2e-test has phase_affinity "Phase 6" → auto-loaded
→ agent-browser testing runs automatically

#### Refresh cadence:
- Rescan on first session of the day
- Rescan if user says "I installed a new skill" or "check for new skills"
- Cache the manifest otherwise (don't rescan every session)
```

---

## Enhancement 11: Multi-Project Scope Isolation

### Problem it solves
You're building multiple SaaS products. OP Mode needs to work across all of them without Heartbeat AI-specific assumptions leaking into your next project. The `.uop/` directory, failure journal, deprecated terms — all need to be project-scoped.

### Where it goes
**MODIFY Phase 1 (Session Init)** to detect and scope the current project.

### The patch

```markdown
### Phase 1.0: Project Scoping (NEW — before existing Phase 1)

When OP Mode starts, determine which project we're in:

#### Detection method (in order):
1. Check for .uop/project.json in current directory
2. Check for package.json → read "name" field
3. Check for .git → read remote URL
4. Ask user: "Which project is this?"

#### Project config: .uop/project.json

{
  "project_name": "heartbeat-ai",
  "project_type": "saas",
  "created": "2025-09-01",
  "tech_stack": {
    "backend": "fastify",
    "database": "postgresql-neon",
    "frontend": "vanilla-html-css-js",
    "voice": "elevenlabs",
    "sms": "twilio"
  },
  "conventions": {
    "migration_prefix": "three-digit-sequential",
    "route_pattern": "src/routes/{resource}.js",
    "service_pattern": "src/services/{resource}.js",
    "test_pattern": "tests/{type}/{resource}.test.js"
  },
  "deprecated_services": ["retell"],
  "security_requirements": ["rls", "csrf", "httponly-cookies"],
  "custom_rules": [
    "All DB queries must include tenant_id for RLS",
    "Voice endpoints use ElevenLabs Conversational AI (per-minute billing)",
    "Frontend is a single HTML file — test tabs individually"
  ]
}

#### How scoping works:
- All .uop/ paths are relative to the project root
- Failure journal entries are tagged with project_name
- Checkpoint resume only shows checkpoints for the CURRENT project
- Deprecated terms scanner reads from this project's config
- Skill manifest is project-scoped (different projects may use different skills)

#### New project setup:
If .uop/project.json doesn't exist, OP Mode creates it interactively:

"I don't see a project config. Let me set one up:
1. What's this project called?
2. What's the tech stack? (I can auto-detect from package.json)
3. Any project-specific rules I should know?"

This only happens once per project. After that, OP Mode knows where it is.
```

---

## Enhancement 12: "Explain What You Did" Mode

### Problem it solves
You're learning as you go. When the AI implements a feature, you see the final report but don't understand WHY certain decisions were made or HOW the code works. This creates a dangerous gap: you own code you can't maintain.

### Where it goes
**ADD to Phase 7 (Final Report)** as an optional section that activates when the user asks or when OP Mode detects a novice-level session.

### The patch

```markdown
## Phase 7 Addition: Learning Summary (Optional)

### When to include:
- User says "explain what you did" or "teach me" or "what should I understand?"
- Session involved a pattern the user hasn't seen before
  (new architecture pattern, new library, new DB concept)
- Always included in the first 3 sessions of a new project

### Template:

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

- **Webhook Verification:** When ElevenLabs sends call data to your server,
  it signs the request with a secret. Your server checks that signature to
  make sure the request actually came from ElevenLabs and not an attacker.
  This is the HMAC-SHA256 check in the webhook route.

### Decisions I Made (and why)
| What I Decided | Why | What The Alternative Was |
|----------------|-----|------------------------|
| {decision} | {plain English reasoning} | {what I didn't do and why} |

### If You Need To Change This Later
{1-2 sentences about what to look for and what's safe to modify vs what's fragile}

Example: "The webhook route is safe to modify — just make sure you keep the
HMAC verification at the top. If you remove it, anyone could send fake call
data to your server."

### Files To Understand
| File | What It Does | Read This If You Need To... |
|------|-------------|---------------------------|
| {path} | {plain English} | {scenario when you'd touch it} |
```

---

## Updated Installation Order (v1.0 + v1.1 combined)

### v1.0 Core Enhancements (Install First)

| Enhancement | Name | What to Modify | Effort |
|-------------|------|----------------|--------|
| E-1 | Gate 0 Light Mode | Add Step 0.0 to SKILL.md | 5 min |
| E-2 | TDD Gate | Insert Phase 5.0 in SKILL.md | 10 min |
| E-3 | 3-Failure Stop | Replace iteration-protocol.md | 5 min |
| E-4 | Human Handoff | Add utility section after Phase 7 | 10 min |
| E-5 | ~~Checkpoint v1~~ | **SKIP — replaced by E-8 below** | — |
| E-6 | Failure Mode Journal | Create .uop/failures.md + add references | 10 min |
| E-7 | Change Tracking | Insert into Phase 5 + Phase 7 summary | 10 min |

### v1.1 Additional Enhancements (Install After v1.0)

| Enhancement | Name | What to Modify | Effort |
|-------------|------|----------------|--------|
| E-8 | Checkpoint & Resume v2 | Replaces E-5 entirely — expanded version | 20 min |
| E-9 | Doc Freshness Scanner | New utility + .uop/deprecated-terms.json | 10 min |
| E-10 | Skill Auto-Discovery | Replace Gate 0 Step 0.1 + .uop/skill-manifest.json | 15 min |
| E-11 | Multi-Project Scope | Modify Phase 1 + .uop/project.json | 15 min |
| E-12 | Explain What You Did | Add to Phase 7 template | 10 min |

**Total effort: ~120 minutes (2 hours) for the full v1.0 + v1.1 pack.**

---

## What OP Mode Looks Like After ALL Enhancements (v1.0 + v1.1)

```
Gate 0:
  → Step 0.0: Light Mode Check (v1.0)
  → Step 0.1: Skill Auto-Discovery (v1.1 — replaces hardcoded list)
  → Steps 0.2-0.5: (unchanged)
  → Auto: Doc Freshness Scanner (v1.1 — runs in Full Mode sessions)

Phase 1: Session Init
  → 1.0: Project Scoping (v1.1 — detects/creates .uop/project.json)
  → Auto-Resume Detection (v1.1 — checks for checkpoints)
  → 1.1-N: (unchanged)

Phase 2: RLM Query (unchanged)
Phase 3: Planning (unchanged)
Phase 4: Plan Approval — User Touchpoint 1 (unchanged)

Phase 5: Implementation
  → 5.0: TDD Gate (v1.0)
  → 5.1-N: Implementation (unchanged)
  → Auto: Change Tracking (v1.0)
  → Auto: Failure Journal check (v1.0)
  → Auto: Heartbeat checkpoint every 10 tool calls (v1.1)
  → Iteration limit: 3 attempts, architectural stop (v1.0)

Phase 6: E2E Agent-Browser Validation (Phase 6 E2E doc)
  → Auto: Skills with Phase 6 affinity loaded (v1.1)

Phase 7: Final Report — User Touchpoint 2
  → Changes Summary (v1.0)
  → Learning Summary / "Explain What You Did" (v1.1 — optional)
  → Checkpoint cleared on completion (v1.0)

Utilities (callable anytime):
  → Human Handoff Package Generator (v1.0)
  → Checkpoint & Resume v2 (v1.1 — heartbeats + emergency saves)
  → Doc Freshness Scanner (v1.1)

.uop/ Memory (full structure):
  → project.json (v1.1 — project identity + conventions)
  → skill-manifest.json (v1.1 — auto-discovered skills)
  → deprecated-terms.json (v1.1 — stale reference detection)
  → failures.md (v1.0 — cross-session error patterns)
  → sessions/{id}/
     → CHECKPOINT.md (v1.0)
     → HEARTBEAT.md (v1.1 — mid-phase state)
     → EMERGENCY_SAVE.md (v1.1 — pre-compaction)
     → PLAN.md (existing)
     → ISSUES.md (existing)
     → CHANGES.md (v1.0)
     → DECISION_TREE.md (existing)
     → MCP_LOG.md (existing)
     → PROGRESS_STATE.md (existing)
     → VALIDATION.md (existing)
  → handoffs/ (v1.0)
  → history/ (existing + archived checkpoints)
```

---

*Updated: February 26, 2026 | OP Mode Enhancement Pack v1.0 + v1.1 | Heartbeat AI*
