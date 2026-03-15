# Subagent Quality Rules

> Reference file for OP Mode v4.0. Loaded on-demand, not part of core SKILL.md.
> See main SKILL.md for when to reference this file.

---

## Purpose

Subagents (spawned via the Agent/Task tool) are stateless -- they do NOT share the parent context window. This creates a quality gap, especially for database-heavy, security-sensitive, or cross-file work. This file consolidates all subagent-related rules: required reading before delegation, the quality gate, the reviewer pipeline, and known accuracy loss areas.

---

## Subagent Quality Gate (Section 5.1a)

Subagents for IMPLEMENTATION produce approximately **70% quality** vs in-session work (PAUL framework finding). The accuracy loss comes from subagents not having access to: column name gotchas, RLS policies, schema conventions, and session-level decisions.

### Safe for Subagents

- Research, exploration, codebase discovery
- Test running, validation, health checks
- Independent content generation (Loop Mode tasks)
- Structure mapping (Phase 6 Sub-Agent A)
- Bug scanning (Phase 6 Sub-Agent C)

### Avoid Delegating to Subagents

- Database queries (column name gotchas -- see table below)
- Multi-file refactors (cross-file context needed)
- Security-sensitive code (RLS, auth, billing)
- Any code touching `tenant_billing`, `admin_audit_log`, or auth middleware

### Mandatory Context When Delegating Implementation

When you MUST delegate implementation to a subagent, ALWAYS include these in the prompt:

1. **The column-mismatch table** from MEMORY.md / CLAUDE.md:

| Table | Actual Column | NOT This |
|-------|--------------|----------|
| tenants | `name` | `business_name` |
| tenants | `subscription_status` | `status` |
| tenants | NO `domain` column | `domain` |
| users | `is_active` (boolean) | `status` (varchar) |
| services | `price_cents` (integer) | `price` (decimal) |
| services | `category_id` (uuid FK) | `category` (varchar) |
| staff | Table: `staff_members` | `staff` |
| staff | `name` (single field) | `first_name`/`last_name` |
| customers | `name` (single field) | `first_name`/`last_name` |
| customers | `tier` | `customer_tier` |
| customers | `total_spent_cents` | `total_spent` |
| appointments | `appointment_date` (date) | `date_time` (timestamptz) |
| appointments | `start_time` (time) + `end_time` (time) | embedded in date_time |
| reviews | `reviewer_response` | `owner_response` |
| campaigns | `body` (text, NOT NULL) | `message` |
| campaigns | `channel` (varchar, NOT NULL) | (must always be provided) |

2. **Active RLS policies** for affected tables
3. **Schema gotchas** for the specific tables being touched
4. **Session decisions** from DECISION_TREE.md that affect the implementation

---

## Required File Reading Before Phase 2

Before planning begins, the orchestrator MUST read these subagent definition files to understand capabilities and constraints.

### Always Read (Every Session)

| File | Purpose |
|------|---------|
| `.claude/CLAUDE_CODE_TRAINING_GUIDE.md` | Project standards |
| `.claude/subagents/coordinator.md` | Workflow coordination |
| `CLAUDE.md` (project root) | Project-specific rules |

### Planning Phase

| File | Purpose |
|------|---------|
| `.claude/subagents/prd-generator.md` | Requirements gathering |
| `.claude/subagents/task-generator.md` | Task breakdown |

### Implementation Phase

| File | Purpose |
|------|---------|
| `.claude/subagents/implementation-processor.md` | Code execution |

---

## Code Reviewer Pipeline

Every code change MUST be routed through the appropriate reviewer before being applied. This is Gate 3 in the main SKILL.md.

### Reviewer Routing Table

| Change Type | Primary Reviewer | Secondary Reviewer |
|-------------|------------------|--------------------|
| API/Backend | `backend-reviewer.md` | `security-analyzer.md` |
| UI/Component | `frontend-reviewer.md` | `frontend-designer` |
| Database | `backend-reviewer.md` | `security-analyzer.md` |
| Bug fix | `bug-hunter.md` | (area-specific) |
| Auth/Security | `security-analyzer.md` | `backend-reviewer.md` |
| Performance | `performance-optimizer.md` | `backend-reviewer.md` |

### Full Task Type Routing

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

### Review Pipeline Flow

```
Code Change
    |
    +---> frontend-reviewer   -> UI/UX issues
    +---> backend-reviewer    -> Logic/API issues
    +---> security-analyzer   -> Security vulnerabilities
    +---> performance-opt     -> Performance issues
    +---> bug-hunter          -> Defects
    |
    v
Merge Findings
    |
    +-- PAUSE? --> Design/UX/Scope -> Queue for User
    |
    | No
    v
Auto-Fix & Log  <- MUST log to DECISION_TREE.md
```

### Reviewer File Locations

| Reviewer | Path |
|----------|------|
| Bug Hunter | `.claude/subagents/coding/bug-hunter.md` |
| Backend Reviewer | `.claude/subagents/coding/backend-reviewer.md` |
| Frontend Reviewer | `.claude/subagents/coding/frontend-reviewer.md` |
| Security Analyzer | `.claude/subagents/coding/security-analyzer.md` |
| Performance Optimizer | `.claude/subagents/coding/performance-optimizer.md` |

---

## GSD Agent Files

The GSD agents provide the methodology backbone. These are read at session start (Step 0.3).

### Core GSD (Read for every session)

| File | Purpose |
|------|---------|
| `.claude/agents/gsd-executor.md` | Deviation rules, auto-fix patterns |
| `.claude/agents/gsd-debugger.md` | Scientific debugging method |
| `.claude/agents/gsd-planner.md` | Planning methodology |
| `.claude/agents/gsd-verifier.md` | Verification patterns |

### Research & Analysis (When investigating)

| File | Purpose |
|------|---------|
| `.claude/agents/gsd-codebase-mapper.md` | Understanding codebase |
| `.claude/agents/gsd-phase-researcher.md` | Phase-specific research |
| `.claude/agents/gsd-project-researcher.md` | Project context research |
| `.claude/agents/gsd-research-synthesizer.md` | Synthesizing findings |

### Planning & Validation

| File | Purpose |
|------|---------|
| `.claude/agents/gsd-plan-checker.md` | Validating plans |
| `.claude/agents/gsd-integration-checker.md` | Integration validation |
| `.claude/agents/gsd-roadmapper.md` | Roadmap planning |

---

## Per-Phase Model Selection

Use the right model for each subagent to balance speed, quality, and cost:

| Phase | Recommended Model | Rationale |
|-------|-------------------|-----------|
| Phase 1 (Research/Context) | `model: "haiku"` | Fast codebase scanning, low cost |
| Phase 2 (Planning) | `model: "sonnet"` (default), `model: "opus"` for complex | Good planning at moderate cost |
| Phase 3 (Approval) | N/A (human gate) | No model cost |
| Phase 5 (Implementation) | Always Opus (default) | Code quality is non-negotiable |
| Phase 6 (Validation) | `model: "sonnet"` for test runners, Opus for debugging | Tests are mechanical; debugging needs depth |
| Phase 7 (Reporting) | `model: "haiku"` | Summaries are formulaic |

When spawning Agent tool calls, pass the `model` parameter:
```
Agent(subagent_type="Explore", model="haiku", prompt="...")
Agent(subagent_type="Plan", model="sonnet", prompt="...")
```

Default (no model specified) inherits the parent model. Only override when the phase recommends a lighter model.
