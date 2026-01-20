# Plan Approval Template

Use this template when presenting the plan to the user for approval (User Touchpoint 1).

---

## Template

```markdown
## OP Mode Plan Approval Request

### Task
{original_task_description}

### Complexity Assessment
**{SIMPLE | MEDIUM | COMPLEX}**
- {justification_for_complexity_rating}

### Approach Summary
{2-3_sentence_overview_of_what_will_be_built}

### Implementation Steps
1. **{Step 1 Title}**
   - {brief_description}
   - Files: {affected_files}

2. **{Step 2 Title}**
   - {brief_description}
   - Files: {affected_files}

3. **{Step 3 Title}**
   - {brief_description}
   - Files: {affected_files}

### Files Affected

| File | Action | What Changes |
|------|--------|--------------|
| `{path/to/file.ts}` | MODIFY | {description} |
| `{path/to/new.ts}` | CREATE | {description} |

### Key Decisions

| Decision | Rationale |
|----------|-----------|
| {D1: Decision title} | {Why this approach} |
| {D2: Decision title} | {Why this approach} |

### RLM Historical Context

{If relevant patterns or past decisions exist:}
- **Related Pattern**: {pattern_description}
- **Past Decision**: {relevant_decision_from_history}
- **Potential Risk**: {any_warnings_from_history}

{If no relevant history:}
- No directly relevant historical context found

### Estimated Scope

| Metric | Estimate |
|--------|----------|
| Files to modify | {n} |
| New files | {n} |
| Tests to generate | 3 (1 happy + 2 edge) |

### What Happens Next

If approved:
1. Implementation proceeds autonomously
2. Subagent team handles technical decisions
3. Code reviewers validate quality
4. Tests are generated and run
5. Visual validation for UI changes
6. Final report presented for your approval

You will only be contacted during implementation if:
- Design/UX decisions are needed
- Scope changes are discovered
- Architecture deviations required
- Decision conflicts arise

---

**Approve this plan?**

Options:
- **Yes** - Proceed with implementation
- **Yes, with modifications** - Specify what to change
- **No** - Cancel and discuss alternative approach
```

---

## Modification Handling

If user approves with modifications:

```markdown
### Modifications Acknowledged

| Original | Modified To |
|----------|-------------|
| {original_decision} | {new_decision} |

**Updated Plan Summary**:
{brief_summary_of_changes}

Proceeding with modified plan...
```

---

## Rejection Handling

If user rejects:

```markdown
### Plan Rejected

**Reason**: {user_provided_reason}

**Options**:
1. Discuss alternative approach
2. Provide more context for refined plan
3. Cancel OP Mode for this task

What would you like to do?
```

---

## Quick Approval for Simple Tasks

For SIMPLE complexity tasks, use condensed format:

```markdown
## OP Mode Quick Approval

**Task**: {task}
**Approach**: {one_line_approach}
**Files**: {list_of_files}
**Decisions**: {key_decisions}

Quick approve? (Y/N)
```
