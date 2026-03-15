# RLM Save Protocol

> Reference file for OP Mode v4.0. Loaded on-demand, not part of core SKILL.md.
> See main SKILL.md for when to reference this file.

---

## Purpose

RLM (Recursive Learning Memory) updates are MANDATORY at the end of every OP Mode session. This file contains the exact file formats for patterns, decisions, and issues, the save requirements checklist, the decision tree management protocol, and the confirmation format required in the Phase 7 Final Report.

A session without RLM saves is INCOMPLETE.

---

## What MUST Be Saved to RLM

```
PATTERNS (Save to .uop/history/patterns/):
[ ] Any new coding pattern discovered
[ ] Any successful approach that could be reused
[ ] Any anti-pattern identified (what NOT to do)

DECISIONS (Save to .uop/history/decisions/):
[ ] All decisions from DECISION_TREE.md
[ ] Why each decision was made
[ ] What alternatives were considered

ISSUES (Save to .uop/history/issues/):
[ ] Any issue encountered and how it was resolved
[ ] Root cause analysis
[ ] Prevention strategies for future

INDEX (Update .uop/INDEX.md):
[ ] Add pointers to new patterns
[ ] Add pointers to significant decisions
[ ] Update "Recent Sessions" section
```

---

## File Formats

### Pattern File: `.uop/history/patterns/{pattern-name}.md`

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

### Decision File: `.uop/history/decisions/{decision-id}.md`

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

### Issue File: `.uop/history/issues/{issue-id}.md`

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

---

## Decision Tree Management

### Decision Tree Format (Session-Level)

The decision tree is a living document maintained throughout the session at `.uop/sessions/{session-id}/DECISION_TREE.md`.

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

### Initialization (Phase 2)

Create the decision tree during Phase 2 planning:

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

### Change Detection

When implementation reveals a decision needs to change:

1. **Log the change** to DECISION_TREE.md (mandatory)
2. **Assess impact:**
   - If scope or UX changes: PAUSE, queue for user validation
   - If purely technical: auto-approve and log
3. **Update the decision entry** with new status, timestamp, and reason

### Rules

- Every decision MUST be logged. Undocumented decisions don't exist.
- Do NOT proceed to Phase 3 without DECISION_TREE.md created.
- Changes that affect scope or UX require user approval.
- Technical decisions can be auto-approved but must still be logged.

---

## Automatic Update Triggers

RLM saves should happen at these points:

| Event | What to Store | Where |
|-------|---------------|-------|
| Phase complete | Phase summary + key decisions | `sessions/{id}/` |
| Issue resolved | Problem + solution + root cause | `history/issues/` |
| Decision made | Decision + rationale + context | `history/decisions/` |
| Pattern discovered | Pattern + examples + when to use | `history/patterns/` |
| User guidance received | Extracted decisions and patterns | `history/` + `DECISION_TREE.md` |
| Session complete | All session learnings | All of the above |

### On Session Complete (Mandatory)

```
1. save_patterns_to_history()
2. save_decisions_to_history()
3. save_issues_to_history()
4. update_index_with_session_summary()
```

### On User Guidance (Immediate)

When the user provides guidance mid-session:
1. Extract decisions and patterns from the guidance
2. Save decisions to both DECISION_TREE.md and history
3. Save patterns to history
4. Refresh INDEX.md

---

## Phase 7 Confirmation Format (MANDATORY)

Your Phase 7 Final Report MUST include this section:

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

If you have NOT saved to RLM, the session is INCOMPLETE. Do not present the Final Report without completing RLM saves first.

---

## Pinecone Graduation (Light Mode + Full Mode)

In addition to file-based RLM saves, graduate key learnings to Pinecone for vector search:

```bash
node scripts/graduate.js --lesson "{concise lesson description}"
```

This is mandatory for:
- Light Mode sessions (Phase 7 abbreviated)
- Any new pattern that future sessions should discover via semantic search
- Cross-reference vectors for multi-notebook video ingestion (see url-router.md)

Pinecone graduation supplements, but does NOT replace, the file-based RLM saves above.
