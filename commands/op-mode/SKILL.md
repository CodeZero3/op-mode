---
name: op-mode
description: "OP Mode v4.1 — Intelligent Orchestration with Knowledge Feedback Loop"
argument-hint: "<task-description>"
allowed-tools: [Read, Glob, Grep, Bash, Task, TodoWrite, Write, Edit, WebFetch, WebSearch]
---

# OP Mode v4.1: Intelligent Orchestration

OP Mode is not just task orchestration. It is a knowledge system with three layers:

1. **VAULT** (`memory/*.md`) — Ground truth. Human-readable, git-tracked. The canonical source for all project knowledge.
2. **PINECONE** (`romeo-personal-os` index) — Semantic index over the vault. Enables task-relevant retrieval via `scripts/query-pinecone.js`. 91+ vectors across 3 namespaces (lessons, decisions, projects).
3. **NOTEBOOKLM** (8 notebooks) — Product-specific knowledge assets. Copy, SEO, pricing, competitor intel. Query before writing marketing/product content.

**The feedback loop:**
- Every session READS from all three layers (Phase 1)
- Every session WRITES BACK to at least one layer (Phase 7)
- This is how the system gets smarter with every session

**Key scripts:**
```bash
node scripts/query-pinecone.js "{query}"              # Semantic search (5 seconds, mandatory)
node scripts/graduate.js --lesson "..."                # Embed new knowledge to Pinecone
node scripts/graduate.js --file memory/{file}.md       # Re-index a memory file
notebooklm use {id} && notebooklm ask "query"          # Query product knowledge
```

---

## Section 1: Task Sizing

Before loading any context, classify the incoming task using the **decision tree**:

```
TASK SIZING DECISION TREE (follow top-to-bottom, take first match):

  Is it documentation/comments only (no code logic)?
  └─ YES → LIGHT MODE (no tests needed)

  Is it a SINGLE FILE change?
  └─ YES → Does it require architectural decisions?
       └─ NO  → LIGHT MODE
       └─ YES → FULL MODE

  Are there MULTIPLE units that are each independent (no cross-deps)?
  └─ YES → Is success measurable by a single metric?
       └─ YES → LOOP MODE
       └─ NO  → FULL MODE

  ELSE → FULL MODE

  WHEN IN DOUBT → Full Mode. Better to over-plan than break.
```

**Log the sizing decision** to PLAN.md before proceeding:
```markdown
## Sizing
{MODE} — {1-line rationale}
Example: LIGHT — single-file CSS fix, no judgment calls
Example: FULL — 4 files, new Inngest function, DB migration needed
```

**Mode details:**

| Mode | Phases | When |
|------|--------|------|
| **LIGHT** | 4-5 + 7 (skip planning/approval) | Single-file, known root cause, docs-only, no architectural decisions |
| **FULL** | All 7 phases | Multi-file, schema changes, auth/RLS/security, external integrations, ambiguous scope, OR single-file with architectural decisions |
| **LOOP** | Batch iterations + UNIFY | Parallelizable independent units, single success metric, no cross-unit deps |

**LOOP MODE workflow:**
1. Gates 1-2 apply (session init + knowledge load). Gate 3 (plan approval) applies to the loop definition, not each iteration.
2. Define: metric, iterations, revert threshold
3. Each iteration: fresh agent, fleet.json context only
4. Log results to resource.md (compound learning)
5. Post-loop: UNIFY all outputs for consistency

**MANDATORY for ALL modes** — Pinecone query before touching any file:
```bash
node scripts/query-pinecone.js "{task_area}"
node scripts/query-pinecone.js "{primary_file_being_touched}"
```
If any result scores > 0.5, read that context before proceeding.

**For marketing/copy/SEO tasks**, also query the relevant NotebookLM notebook:
```bash
notebooklm use {notebook_id}
notebooklm ask "{query about the task}"
```

Notebook registry is in CLAUDE.md under "NotebookLM Notebooks."

**Fallback if Pinecone is unreachable:**
1. Log the failure to PLAN.md: `Pinecone query failed: {error}`
2. Read `memory/INDEX.md` + relevant topic file manually (the vault IS the ground truth)
3. Proceed — but flag in PLAN.md: `Gate 2 partial — Pinecone unavailable, vault-only context loaded`
4. Do NOT skip context loading entirely

**Fallback if NotebookLM is unreachable:**
1. Log the failure to PLAN.md: `NotebookLM unavailable: {error}`
2. Check if CLAUDE.md has the needed info (pricing, positioning, etc.)
3. Proceed with vault-only context
4. Flag in PLAN.md: `NotebookLM unavailable — verify copy accuracy post-session`

---

## Section 2: Session Lifecycle

### Starting a Session

```bash
bash op-mode/commands/op-mode/scripts/op-session.sh start "{slug}"
```

This creates `.uop/sessions/{slug-YYYYMMDD}/`, sets CURRENT_SESSION, creates PLAN.md template.

### During a Session

- PLAN.md is the ONLY working document. Decisions, progress, scope changes — all go inline.
- Mark tasks done with checkboxes as you complete them.
- If about to work on something NOT in PLAN.md, STOP and ask: "This is not in the plan — add or defer?"

### Closing a Session (MANDATORY)

```bash
bash op-mode/commands/op-mode/scripts/op-session.sh end "{session-id}" "COMPLETE" "one-line summary"
```

This clears CURRENT_SESSION and appends to `.uop/INDEX.md`.

### Resuming

If CURRENT_SESSION is non-empty and not "none", read that session's PLAN.md and offer to resume:

```
I found an open session: {session-id}
Task: {description from PLAN.md}
Status: {last checked task}

Options:
A) Resume from where we left off (recommended)
B) Start fresh (archives the session)
C) Review PLAN.md before deciding
```

### Auditing

```bash
bash op-mode/commands/op-mode/scripts/op-session.sh audit
```

---

## Section 3: Hard Gates

Three gates. Cannot proceed past each without satisfying the condition.
**Each gate requires a proof entry in PLAN.md** under `## Gate Log` before advancing.

### GATE 1: Session Initialized

- `op-session.sh start` has been run
- CURRENT_SESSION is set to this session ID
- PLAN.md exists in the session directory

**Proof format:**
```markdown
## Gate Log
### Gate 1: Session Initialized
- [x] `op-session.sh start` ran → session ID: {id}
- [x] CURRENT_SESSION set → verified
```

### GATE 2: Knowledge Loaded

- Pinecone queried for task area (mandatory, even Light Mode)
- `memory/INDEX.md` read — Open Loops checked for overdue items
- Vault context loaded (CLAUDE.md + relevant topic file from `memory/`)
- If product task: relevant NotebookLM notebook identified

**Proof format (record actual results, not just "done"):**
```markdown
### Gate 2: Knowledge Loaded
- [x] Pinecone query: "{query}" → top score: {score} | hit: {source}
- [x] INDEX.md read → overdue items: {none | list}
- [x] Topic file loaded: memory/{file}.md
- [x] NotebookLM: {skipped — not a product task | queried notebook {id}}
```

### GATE 3: Plan Approved (Full Mode only)

- User has explicitly approved the plan before implementation begins
- This is a USER TOUCHPOINT — present the plan and wait for approval
- Do NOT proceed without the word "approved" (or equivalent confirmation)

**Proof format:**
```markdown
### Gate 3: Plan Approved
- [x] User said: "{approval text}" at {timestamp}
```

---

## Section 4: Phases 1-3 — Init, Plan, Approve

### Phase 1: Initialization

**1.1 Assess complexity** based on files touched, DB changes, security impact:
```
SIMPLE:   Single file, clear scope         -> Light Mode candidate
MEDIUM:   2-5 files, defined boundaries    -> Full Mode
COMPLEX:  6+ files, cross-cutting concerns -> Full Mode, consider TDD
```

**1.2 Load memory:**
```bash
# Always read first
Read memory/INDEX.md
# Scan Open Loops for overdue items
# Load relevant topic file based on task area
Read memory/{relevant-topic}.md
```

**1.3 Run Pinecone queries** (results inform planning):
```bash
node scripts/query-pinecone.js "{task_area}"
node scripts/query-pinecone.js "{primary_file_or_service}"
```
Review results. If score > 0.5 on any hit, read that context before proceeding.

**1.4 If marketing/copy/SEO task**, query NotebookLM:
```bash
notebooklm use {id}
notebooklm ask "{query}"
```

**1.5 Read `.uop/INDEX.md`** recent sessions for relevant context and patterns.

### Phase 2: Planning (Full Mode only)

**2.1 Generate task breakdown** with numbered steps.

**2.2 Write BDD acceptance criteria** for each task:
```
AC-{N}: Given {precondition}, When {action}, Then {expected result}
```

**2.3 Ask 3-5 structured discovery questions** if requirements are ambiguous:
- What is the scope boundary?
- What are the success metrics?
- What constraints exist?
- What dependencies?
- What risks?

**2.4 Identify** files to modify, tests to write, migrations needed.

**2.5 Flag** if task is suitable for Loop Mode (stateless batch) vs standard sequential.

**2.6 Check Pinecone results** — do any past lessons apply to this plan?

**2.7 Write plan** to session's PLAN.md with the **canonical section order** (do not rearrange):
```markdown
## Objective
{what we are building and why}

## Sizing
{MODE} — {1-line rationale}

## Gate Log
### Gate 1: Session Initialized
### Gate 2: Knowledge Loaded
### Gate 3: Plan Approved

## Tasks
- [ ] Task 1: {description}
  AC-1: Given X, When Y, Then Z
- [ ] Task 2: {description}
  AC-2: Given X, When Y, Then Z

## Files to Modify
- {file_path} — {what changes}

## Decisions
(populated during implementation)

## Scope Changes
(populated if scope changes mid-implementation)

## Validation
(populated after Phase 6 — includes Codex self-assessment if MEDIUM task)

## Graduation
(populated at Phase 7 — lesson text + status)

## UNIFY
(populated at Phase 7 — planned vs actual reconciliation)
```

### Phase 3: Plan Approval (USER TOUCHPOINT)

Present to Romeo:
- Summary of approach
- Files to be modified
- Key decisions and trade-offs
- Knowledge hits from Pinecone/NotebookLM (if any scored > 0.5)
- Estimated complexity (SIMPLE / MEDIUM / COMPLEX)
- Acceptance criteria

See `templates/plan-approval.md` for full presentation format.

Wait for explicit approval before Phase 4. Do NOT proceed without it.

**User response handling:**
- **Approved**: Proceed to Phase 4
- **Modifications**: Update plan, re-present key changes
- **Rejected**: Archive session, end workflow

---

## Section 5: Phases 4-5 — Implementation

### Phase 4: Living Plan Execution

Mark each PLAN.md task with a checkbox as completed:
```markdown
- [x] Task 1 — vault config created
- [x] Task 2 — ROMEO-PROFILE frontmatter added
- [ ] Task 3 — /context-load skill  <-- currently here
```

Log decisions inline in PLAN.md under "## Decisions" section.
If scope changes mid-implementation, add to "## Scope Changes" section.

**No side quests.** If tempted to fix something unrelated, add it to Sprint Backlog or defer.

**Authority Matrix** — what you can auto-decide vs must ask Romeo:

| Auto-Decide | Ask Romeo |
|-------------|-----------|
| Variable names, file structure | New dependencies |
| Test strategy, error messages | DB schema changes |
| Import organization | Pricing/billing changes |
| Code formatting, refactoring | Security policy changes |
| Internal implementation details | External API choices |
| Log messages, comments | Scope additions beyond plan |

Full matrix: `reference/authority-matrix.md`

### Phase 5: Implementation Quality

**TDD gate (COMPLEX tasks):**
1. Write test first (RED) — test MUST fail
2. Implement minimal code to pass (GREEN)
3. Refactor if needed — tests MUST still pass

**For SIMPLE/MEDIUM tasks:** implement then write tests.

**Minimum test coverage per feature:**
- 1 happy path test (the thing works as intended)
- 1 edge case test (boundary condition or empty state)
- 1 error handling test (what happens when input is bad)

**Attempt tracking — max 3 attempts per issue:**

```
Attempt 1: Try solution
    | Failed
Attempt 2: Try alternative approach
    | Failed
Attempt 3: Fresh perspective, different strategy
    | Failed
STOP. Escalate to Romeo with:
  - What was tried (all 3 approaches)
  - What failed and why
  - Recommended next step
```

See `reference/iteration-protocol.md` for full escalation format.

**Subagent delegation warnings:**

NEVER delegate to subagents:
- DB schema, RLS policy, or security code (~30% quality loss observed)
- Multi-file refactors requiring cross-file context
- Anything touching the column-mismatch table from CLAUDE.md

Use subagents for:
- Research, exploration, codebase discovery
- Test running, validation, health checks
- Independent content generation (Loop Mode tasks)

See `reference/subagent-quality-rules.md` for full rules.

---

## Section 6: Phase 6 — Validation

### Mandatory (all modes)

Run the test suite:
```bash
cd backend && npm test
```

If backend changes, verify health endpoints:
```bash
curl -s https://api.mybizpilot.com/health
curl -s https://api.mybizpilot.com/health/ready
```

If UI changes: visual inspection, check responsive behavior.

If DB changes: verify migration applied:
```bash
node backend/scripts/check-schema.js
```

### Phase 6.1: Codex Cross-Model Audit

Uses OpenAI Codex CLI as a second-opinion validator. Different model = different blind spots caught.

**Trigger logic by task complexity:**

**COMPLEX tasks (security, architecture, multi-file logic) → MANDATORY**
- Runs automatically after tests pass. No skip. No ask.
- Profile: `--profile audit` (standard) or `--profile security` (if auth/RLS/billing/middleware touched)
- Any P0/P1 findings MUST be addressed before Phase 7
- Log results to PLAN.md "## Validation" section

**MEDIUM tasks (logic changes, new routes, refactoring) → SELF-ASSESSMENT + PROTEST**

Run this internal checklist and **log answers to PLAN.md `## Validation`**:
1. Did this touch multiple files?
2. Did this involve any logic changes?
3. Did I make any judgment calls on approach?
4. Was anything here non-obvious?

- If ANY answer is YES → auto-run `codex exec --profile quick` and report: "Running Codex audit — [reason]"
- If ALL answers are NO → PROTEST to Romeo:
  - State what was completed
  - List the self-assessment answers (all NO)
  - Explain WHY audit doesn't add value
  - Offer override: "Want me to run it anyway?"
  - If Romeo says yes → run it. No argument.

**Required PLAN.md log format:**
```markdown
### Codex Self-Assessment (MEDIUM task)
1. Multiple files touched? {YES/NO} — {detail if YES}
2. Logic changes? {YES/NO} — {detail if YES}
3. Judgment calls? {YES/NO} — {detail if YES}
4. Non-obvious? {YES/NO} — {detail if YES}
→ Decision: {RUN | SKIP (protested, Romeo accepted)}
→ Profile: {quick|audit|security} | Findings: {summary or "clean"}
```

**SIMPLE/Light tasks → SKIP (no protest needed)**
- Typos, CSS tweaks, config changes, env vars, single-line fixes

**Command pattern:**
```bash
codex exec --profile quick -s read-only --full-auto \
  "Review for bugs, security issues, logic errors: $(cat path/to/file.js)" 2>/dev/null
```

Full skill reference: `~/.claude/skills/codex/SKILL.md`

**If Codex CLI is unavailable** (not installed, network error, command fails):
1. Log to PLAN.md: `Codex audit skipped — CLI unavailable: {error}`
2. Perform manual review of the same checklist (bugs, security, logic errors)
3. Flag in FINAL_REPORT: "Codex audit deferred — manual review only"

### Phase 6.2: E2E Browser Testing (Optional, if agent-browser available)

See `reference/phase6-e2e-testing.md` for the full E2E browser testing protocol using `agent-browser`. This includes:
- Parallel research sub-agents (structure mapper, schema mapper, bug hunter)
- User journey execution with screenshot evidence
- Responsive testing at 3 viewports (375x812, 768x1024, 1440x900)
- Database validation queries after data-modifying actions

### Log validation results

Add results to PLAN.md under "## Validation" section:
```markdown
## Validation
- [x] Test suite: 694/694 passing
- [x] Health endpoints: 200 OK
- [x] Schema check: no drift
- [ ] Visual inspection: {notes}
```

---

## Section 7: Phase 7 — Knowledge Capture + Session Close

This is the brain's write-back cycle. NOT optional. Every session must complete this phase.

### Context Exhaustion Recovery

**Trigger:** Claude Code's context compression warnings (system notifies you when prior messages are being compressed — that IS the signal, not a percentage guess).

**When context compression fires, IMMEDIATELY:**
1. Run `/graduate` with whatever lesson exists so far (even partial)
2. Write PLAN.md checkpoint (tasks done, decisions made, current state)
3. Continue work — graduation is ALREADY DONE, Phase 7 pressure is relieved

**If session crashes/context dies before Phase 7:**
- Next session reads PLAN.md (it's the checkpoint)
- Next session checks: does PLAN.md have a `## UNIFY` section?
  - NO → previous session didn't finish Phase 7
  - Run graduation for the completed work FIRST, then continue new work

**If `graduate.js` fails** (Pinecone down, network error, non-zero exit):
1. Log the failure and the lesson text to PLAN.md so it can be retried:
```markdown
## Graduation (DEFERRED — Pinecone unavailable)
Lesson: "{the lesson text}"
Status: Will retry next session
```
2. The lesson is NOT lost — it's in PLAN.md, which is git-tracked
3. Next session: search PLAN.md for `## Graduation (DEFERRED` and retry

### 7.1: UNIFY Gate (reconcile planned vs actual)

In PLAN.md, add a "## UNIFY" section:

```markdown
## UNIFY — Planned vs Actual
| Task | Status |
|------|--------|
| Task 1 from plan | Done |
| Task 2 from plan | Deferred — reason |
| Unplanned task X | Added — reason |
```

If scope expanded without prior approval, document why.
If acceptance criteria (AC-N) exist, verify each one passed.

### 7.2: /graduate — Capture New Knowledge (MANDATORY)

At minimum ONE of these must happen before session close:

```bash
# Option A: Quick lesson (one sentence -> embedded to Pinecone)
node scripts/graduate.js --lesson "Fastify additionalProperties:true required for dynamic response objects"

# Option B: Re-index an updated memory file
node scripts/graduate.js --file memory/architecture.md

# Option C: Explicitly state no new knowledge
# "No new knowledge — mechanical fix only" (document in FINAL_REPORT)
```

Also update relevant `memory/` files if insights affect:
- Architecture patterns -> `memory/architecture.md`
- Migration knowledge -> `memory/migrations.md`
- Active mission status -> `memory/ACTIVE-MISSIONS.md`
- Lessons learned -> CLAUDE.md "Lessons Learned" section

### 7.3: /emerge — Pattern Synthesis (Full Mode only)

Ask: "What patterns from this session have not been explicitly named?"

If a new pattern surfaces:
1. Create `.uop/history/patterns/{pattern-name}.md` with description + example
2. Update `memory/ROMEO-PROFILE.md` if it changes Romeo's decision patterns
3. Graduate it:
```bash
node scripts/graduate.js --lesson "{pattern name}: {description}"
```

### 7.4: NotebookLM Update (if applicable)

If session produced content, research, or competitive analysis relevant to a notebook:
```bash
notebooklm use {notebook-id}
notebooklm add-source --text "{insight or content}"
# OR
notebooklm add-source --url "{url}"
```

Note which notebook was updated in FINAL_REPORT.

### 7.5: Write FINAL_REPORT.md

Create `FINAL_REPORT.md` in the session directory. See `templates/final-report.md` for format.

Minimum content:
- **Objective**: What was the task
- **What was done**: Numbered list of completed steps
- **What was learned**: Key insights (even if "nothing new")
- **What was graduated**: Pinecone lessons, memory file updates, notebook additions
- **Next steps**: Deferred items, follow-up tasks, open questions

### 7.6: Close Session (MANDATORY — run this command)

```bash
bash op-mode/commands/op-mode/scripts/op-session.sh end "{session-id}" "COMPLETE" "one-line summary"
```

This automatically: clears CURRENT_SESSION, appends entry to `.uop/INDEX.md`,
and commits any pending op-mode changes to the op-mode repo (no push — Romeo decides when to push).

---

## Section 8: Session File Protocol

Each session creates exactly TWO files:
1. **PLAN.md** — Living document (plan + decisions + progress + scope changes + validation + UNIFY)
2. **FINAL_REPORT.md** — Written at close (summary + learnings + graduations)

**Retired files (do NOT create these):**
- ~~MCP_LOG.md~~ — removed (never populated)
- ~~DECISION_TREE.md~~ — merged into PLAN.md "## Decisions" section
- ~~CHANGES.md~~ — merged into PLAN.md progress tracking
- ~~HEARTBEAT.md~~ — replaced by PLAN.md checkbox tracking
- ~~PROGRESS_STATE.md~~ — replaced by PLAN.md
- ~~RLM_CONTEXT.md~~ — Pinecone query results reviewed inline, not stored
- ~~VALIDATION.md~~ — merged into PLAN.md "## Validation" section
- ~~EMERGENCY_SAVE.md~~ — PLAN.md IS the checkpoint

### PLAN.md is the checkpoint

If a session is interrupted:
- PLAN.md shows exactly which tasks are checked off
- The "## Decisions" section preserves all context
- A new session reads PLAN.md and resumes from the first unchecked task
- No separate checkpoint file is needed

---

## Section 9: URL Router

When the input is a bare URL with no task description, route it before task sizing.

**No URL detected**: fall through to Task Sizing immediately.
**URL + task description**: note the URL as context, fall through to Task Sizing.
**Bare URL only**: run the appropriate flow below.

### YouTube ANALYZE-FIRST Flow

See `reference/url-router.md` for the full 5-step protocol. Summary:

1. **Scratchpad Analysis** — fetch metadata via YouTube oEmbed:
   ```
   WebFetch: https://www.youtube.com/oembed?url={url}&format=json
   ```
   Extract title + channel. Produce 2-3 sentence summary of likely content.

2. **Notebook Alignment** — cross-reference topics against all registered notebooks (from CLAUDE.md). Identify primary + secondary notebooks.

3. **Present Recommendation** — show video analysis, notebook matches, source budgets. Ask to confirm.

4. **Multi-Notebook Sourcing** — add to ALL confirmed notebooks. Graduate a cross-reference vector to Pinecone:
   ```bash
   node scripts/graduate.js --lesson "VIDEO: {title} | Notebooks: {ids} | Topics: {topics} | URL: {url}"
   ```

5. **Debrief** — query each updated notebook for actionable insights. Offer to spin up a full OP Mode session for any selected insight.

**Source budget rules:**
- Free tier: 50 sources/notebook. Warn at 40+. Block at 50.
- After adding, update source count in `memory/notebooklm.md`.

---

## Section 10: Reference Index

**Reference files** (loaded on-demand when a specific phase needs them):

| File | Purpose |
|------|---------|
| `reference/authority-matrix.md` | Auto-decide vs ask Romeo decision table |
| `reference/iteration-protocol.md` | 3-attempt escalation, circular fix detection |
| `reference/url-router.md` | YouTube URL ANALYZE-FIRST flow (full 5-step protocol) |
| `reference/phase6-e2e-testing.md` | Full E2E browser protocol with agent-browser (OPTIONAL) |
| `reference/progress-display.md` | ASCII progress display templates |
| `reference/autonomous-ops-patterns.md` | Fleet/Loop Mode/agent patterns |
| `reference/subagent-quality-rules.md` | Subagent delegation warnings + reviewer pipeline |
| `reference/rlm-save-protocol.md` | RLM save formats for patterns/decisions/issues |

**Templates:**

| File | Purpose |
|------|---------|
| `templates/plan-approval.md` | Phase 3 plan presentation format |
| `templates/final-report.md` | Phase 7 report format |
| `templates/escalation-report.md` | 3-failure escalation format |
| `templates/session-init.md` | Session initialization format |

**Knowledge scripts:**

| Script | Purpose |
|--------|---------|
| `scripts/query-pinecone.js` | Semantic search over vault (mandatory before every task) |
| `scripts/graduate.js` | Embed knowledge to Pinecone (mandatory at session close) |
| `scripts/pinecone-setup.js` | Index creation (one-time setup) |
| `scripts/op-session.sh` | Session lifecycle (start/end/audit/status/recover/force-close) |

---

## Section 11: Skill Integration

OP Mode phases may trigger skills automatically. Current skill registry:

| Phase | Trigger Condition | Skill | Invocation |
|-------|-------------------|-------|------------|
| Phase 1 (Init) | Every session | context-load | Read INDEX.md + ROMEO-PROFILE.md |
| Phase 1 (Init) | Product/copy task | notebooklm | `notebooklm use {id} && notebooklm ask` |
| Phase 6 (Validate) | Backend deploy | db-health-check | Schema + migration + test validation |
| Phase 6 (Validate) | COMPLEX task | codex | `codex exec --profile audit` |
| Phase 6 (Validate) | Backend changes | railway-deploy | Pre-deploy checks + deploy + health verify |
| Phase 7 (Close) | Every session | graduate.js | Pinecone knowledge embedding |
| Phase 7 (Close) | Every session | op-session.sh | Auto-commit dirty op-mode files |
| Phase 7 (Close) | Full Mode | /emerge pattern | `.uop/history/patterns/` |
| On interrupt | User request | checkpoint | `memory/SESSION-CHECKPOINT.md` (vault file, not a session file) |

Skills are defined in `.claude/skills/` (project) and `~/.claude/skills/` (user).
Canonical trigger list: CLAUDE.md "Claude Code Skills" section.
If a skill trigger conflicts with OP Mode phase logic, OP Mode takes precedence.

**When a skill is deprecated**, remove its row from the table above and add to the retired list below.

### Retired Skills
_(none currently)_

---

**Begin OP Mode workflow when user provides task description.**
