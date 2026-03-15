# OP Mode Session Template

## Session Initialization

When starting a new OP Mode session, `op-session.sh start` creates:

```
.uop/sessions/{session-id}/
├── PLAN.md          ← Living document (plan + gates + decisions + progress + validation + graduation + UNIFY)
└── FINAL_REPORT.md  ← Written at session close (summary + learnings + graduations)
```

**Retired files (do NOT create these):** DECISION_TREE.md, ISSUES.md, MCP_LOG.md, VALIDATION.md, CHANGES.md, HEARTBEAT.md, PROGRESS_STATE.md, RLM_CONTEXT.md, EMERGENCY_SAVE.md

---

## PLAN.md Template (Canonical Section Order)

```markdown
# OP Mode Plan - {Session ID}

**Created**: {timestamp}
**Task**: {original_task_description}
**Complexity**: {SIMPLE|MEDIUM|COMPLEX}

## Objective

{2-3 sentence overview of what we are building/fixing and why}

## Sizing

{LIGHT|FULL|LOOP} — {1-line rationale}

## Gate Log

### Gate 1: Session Initialized
- [x] `op-session.sh start` ran → session ID: {id}
- [x] CURRENT_SESSION set → verified

### Gate 2: Knowledge Loaded
- [x] Pinecone query: "{query}" → top score: {score} | hit: {source}
- [x] INDEX.md read → overdue items: {none | list}
- [x] Topic file loaded: memory/{file}.md
- [x] NotebookLM: {skipped — not a product task | queried notebook {id}}

### Gate 3: Plan Approved (Full Mode only)
- [x] User said: "{approval text}" at {timestamp}

## Tasks

- [ ] Task 1: {description}
  AC-1: Given X, When Y, Then Z
- [ ] Task 2: {description}
  AC-2: Given X, When Y, Then Z

## Files to Modify

| File | Action | Description |
|------|--------|-------------|
| {path} | CREATE/MODIFY/DELETE | {what_changes} |

## Decisions

<!-- Log decisions inline as they're made -->
| Timestamp | Decision | Category | Rationale |
|-----------|----------|----------|-----------|

## Scope Changes

<!-- Document any additions/removals from original plan -->

## Validation

<!-- Test results, health checks, Codex self-assessment -->
- [ ] Test suite: {count} passing
- [ ] Health endpoints: 200 OK
- [ ] Schema check: no drift

### Codex Self-Assessment (MEDIUM task)
1. Multiple files touched? {YES/NO}
2. Logic changes? {YES/NO}
3. Judgment calls? {YES/NO}
4. Non-obvious? {YES/NO}
→ Decision: {RUN|SKIP}

## Graduation

<!-- Lesson text + status -->
Lesson: "{lesson text}"
Status: {completed | deferred — reason}

## UNIFY

<!-- Planned vs actual reconciliation -->
| Task | Status |
|------|--------|
| Task 1 from plan | Done |
| Task 2 from plan | Deferred — reason |
```

---

## INDEX.md Update Template

When session completes, `op-session.sh end` auto-appends:

```markdown
- **Session {id}**: ✅ {STATUS} ({date}) — {summary}
```
