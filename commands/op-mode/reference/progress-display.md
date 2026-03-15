# Progress Display Protocol

> Reference file for OP Mode v4.0. Loaded on-demand, not part of core SKILL.md.
> See main SKILL.md for when to reference this file.

---

## Purpose

Every OP Mode response MUST include a progress indicator. Users must NEVER lose track of where they are in the workflow. This file contains the visual templates, hierarchy rules, and anti-patterns for progress display.

---

## The Golden Rule

```
EVERY RESPONSE = PROGRESS BAR + CURRENT TASK + REMAINING ITEMS

No exceptions. No "I'll update later." EVERY. SINGLE. RESPONSE.
```

---

## Progress Bar Formats

### Compact (for mid-work updates)

```
[||||___] Phase 4/7 | Task 3/8 | Implementing user auth
```

### Standard (for task transitions)

```
--------------------------------------------------------------------
PROGRESS: ||||||||||||________ 57% | Phase 4/7 | Task 3/8
   Current: Implementing user authentication endpoint
   Next up: Add input validation
--------------------------------------------------------------------
```

### Full Dashboard (for phase transitions & user touchpoints)

```
+========================================================================+
|  OP MODE PROGRESS DASHBOARD                                            |
+========================================================================+
|  Session: op-2026-01-22-001                                            |
|  Goal: {original_task_description}                                     |
+========================================================================+
|                                                                        |
|  OVERALL PROGRESS                                                      |
|  ||||||||||||||||__________ Phase 4 of 7 (Implementation)              |
|                                                                        |
+========================================================================+
|  PHASE STATUS                        |  CURRENT TASK BREAKDOWN         |
|  ----------------------------------- |  ----------------------------- |
|  [x] 1. Initialization               |  Phase 4 Tasks:                |
|  [x] 2. Planning                     |  [x] 4.1 Create API route      |
|  [x] 3. Plan Approval                |  [x] 4.2 Add database query    |
|  [>] 4. Implementation  <- HERE      |  [>] 4.3 Implement auth <- NOW |
|  [ ] 5. Issue Resolution             |  [ ] 4.4 Add validation        |
|  [ ] 6. Validation                   |  [ ] 4.5 Error handling        |
|  [ ] 7. Final Report                 |  [ ] 4.6 Write tests           |
+========================================================================+
|  REMAINING WORK SUMMARY                                                |
|  - Current phase: 4 tasks remaining                                    |
|  - After this phase: 3 phases (Issues -> Validation -> Report)         |
|  - Known blockers: None                                                |
+========================================================================+
```

---

## Hierarchical Task Expansion

When tasks are broken down, the todo list MUST show the hierarchy.

### Initial (Phase-level only)

```
TodoWrite([
  { content: "Phase 1: Initialization", status: "completed" },
  { content: "Phase 2: Planning", status: "completed" },
  { content: "Phase 3: Plan Approval [USER]", status: "completed" },
  { content: "Phase 4: Implementation", status: "in_progress" },
  { content: "Phase 5: Issue Resolution", status: "pending" },
  { content: "Phase 6: Validation", status: "pending" },
  { content: "Phase 7: Final Report [USER]", status: "pending" }
])
```

### Expanded (When entering a phase -- shows sub-tasks)

```
TodoWrite([
  { content: "Phase 1: Initialization", status: "completed" },
  { content: "Phase 2: Planning", status: "completed" },
  { content: "Phase 3: Plan Approval [USER]", status: "completed" },
  { content: "Phase 4: Implementation (6 tasks)", status: "in_progress" },
  { content: "  |-- 4.1 Create API route", status: "completed" },
  { content: "  |-- 4.2 Add database query", status: "completed" },
  { content: "  |-- 4.3 Implement auth check", status: "in_progress" },
  { content: "  |-- 4.4 Add input validation", status: "pending" },
  { content: "  |-- 4.5 Error handling", status: "pending" },
  { content: "  |-- 4.6 Write unit tests", status: "pending" },
  { content: "Phase 5: Issue Resolution", status: "pending" },
  { content: "Phase 6: Validation", status: "pending" },
  { content: "Phase 7: Final Report [USER]", status: "pending" }
])
```

### Deep Expansion (When sub-task has sub-steps)

```
TodoWrite([
  ...
  { content: "  |-- 4.3 Implement auth check", status: "in_progress" },
  { content: "      |-- 4.3.1 Add middleware", status: "completed" },
  { content: "      |-- 4.3.2 Verify JWT token", status: "in_progress" },
  { content: "      |-- 4.3.3 Check permissions", status: "pending" },
  ...
])
```

---

## Mandatory Progress Output Rules

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

## "Remaining Items" Summary (ALWAYS Include)

At the end of every response, include a remaining items count:

**Standard:**
```
-----------------------------------------------------------
Remaining: 4 tasks in current phase | 3 phases after this | 0 blockers
-----------------------------------------------------------
```

**Compact:**
```
[Remaining: 4 tasks | 3 phases | 0 blockers]
```

---

## Context Preservation Across Messages

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

## Progress Tracking State File

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

## Anti-Patterns (NEVER DO THESE)

| NEVER | ALWAYS |
|-------|--------|
| Skip progress in a response | Include at least compact progress |
| Say "continuing..." without context | Show where you are + what's next |
| Complete tasks without updating | Update TodoWrite immediately |
| Hide remaining work | Show remaining count |
| Forget hierarchical position | Show parent task context |
| Assume user remembers | Restore context every response |
