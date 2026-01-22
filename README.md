# OP Mode - Orchestration Protocol for Claude Code

**Version 2.1.0** | [Changelog](commands/op-mode/CHANGELOG.md)

**Unified workflow combining GSD planning, RLM analysis, Subagent execution, and MCP integration.**

OP Mode is a Claude Code skill that provides an end-to-end orchestrated development workflow with only two user touchpoints: Plan Approval and Final Validation.

## What's New in v2.1.0

- **Always-Visible Progress** - Every response includes a progress indicator (non-negotiable)
- **Hierarchical Task Expansion** - See sub-tasks as work is broken down
- **Remaining Items Summary** - Always know what's left at a glance
- **Context Preservation** - Seamless resumption across messages

## Features

- **Two User Touchpoints Only** - Plan Approval + Final Validation (autonomous in between)
- **RLM as Active Partner** - Queries history, participates in planning decisions
- **Iteration Limits** - 4 attempts max per issue, then escalate to Linear/user
- **Auto-Testing** - Generates 1 happy path + 2 edge case tests
- **Visual Validation** - Playwright checks for UI changes
- **Always-Visible Progress** - Persistent progress in every response (v2.1.0)
- **Living Documentation** - Decision tree, issue tracking, MCP logs auto-updated
- **GSD Integration** - Deviation rules, checkpoint protocols, goal-backward analysis

## Installation

### Quick Install (Unix/macOS)

```bash
git clone https://github.com/YOUR_USERNAME/op-mode.git
cd op-mode
./install.sh
```

### Quick Install (Windows PowerShell)

```powershell
git clone https://github.com/YOUR_USERNAME/op-mode.git
cd op-mode
.\install.ps1
```

### Manual Installation

Copy the `commands/op-mode/` directory to `~/.claude/commands/`:

```bash
# Unix/macOS
cp -r commands/op-mode ~/.claude/commands/

# Windows
xcopy /E /I commands\op-mode %USERPROFILE%\.claude\commands\op-mode
```

## Usage

### Basic Usage

```
/op-mode Add user authentication with OAuth
```

### With Options

```
/op-mode Refactor the billing module --skip-rlm
/op-mode Add dark mode support --force-review
```

## Workflow Phases

| Phase | Description | User Touchpoint |
|-------|-------------|-----------------|
| 1. Initialization | Assess complexity, load memory | - |
| 2. Planning | RLM analysis, PRD generation, task breakdown | - |
| 3. Plan Approval | Present plan for user review | **USER** |
| 4. Implementation | Autonomous execution with code review | - |
| 5. Issue Resolution | Handle failures with 4-attempt limit | - |
| 6. Validation | Run tests, visual checks | - |
| 7. Final Report | Present completion report | **USER** |

## Progress Display (v2.1.0)

OP Mode maintains **always-visible progress** in every response. Three formats adapt to context:

### Compact (Every Response)
```
⟦■■■■□□□⟧ Phase 4/7 │ Task 3/8 │ Implementing user auth
```

### Standard (Task Transitions)
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 PROGRESS: ████████████░░░░░░░░ 57% │ Phase 4/7 │ Task 3/8
   Current: Implementing user authentication endpoint
   Next up: Add input validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Full Dashboard (Phase Transitions)
```
╔══════════════════════════════════════════════════════════════════════════╗
║  OP MODE PROGRESS DASHBOARD                                               ║
╠══════════════════════════════════════════════════════════════════════════╣
║  Session: op-2026-01-22-001                                               ║
║  Goal: Add OAuth authentication                                           ║
╠══════════════════════════════════════════════════════════════════════════╣
║  OVERALL PROGRESS                                                         ║
║  ████████████████░░░░░░░░░░░░░░  Phase 4 of 7  (Implementation)          ║
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
╠══════════════════════════════════════════════════════════════════════════╣
║  REMAINING WORK SUMMARY                                                   ║
║  • Current phase: 4 tasks remaining                                       ║
║  • After this phase: 3 phases (Issues → Validation → Report)             ║
║  • Known blockers: None                                                   ║
╚══════════════════════════════════════════════════════════════════════════╝
```

### Hierarchical Task Expansion

As tasks are broken down, you see the full hierarchy:
```
[✓] Phase 4: Implementation (6 tasks)
  └─ [✓] 4.1 Create API route
  └─ [✓] 4.2 Add database query
  └─ [→] 4.3 Implement auth check  ← NOW
      └─ [✓] 4.3.1 Add middleware
      └─ [→] 4.3.2 Verify JWT token  ← NOW
      └─ [ ] 4.3.3 Check permissions
  └─ [ ] 4.4-4.6 (pending)
```

### Remaining Items (Always Shown)
```
📋 Remaining: 4 tasks in current phase │ 3 phases after this │ 0 blockers
```

## Authority Matrix

During autonomous implementation:

| Decision Type | Authority | Action |
|---------------|-----------|--------|
| Technical implementation | Subagent Team | Auto-decide |
| Bug fixes | Subagent Team | Auto-fix |
| Performance optimization | Subagent Team | Auto-optimize |
| Design/UX change | **User** | Pause & ask |
| Scope expansion | **User** | Pause & ask |
| Architecture deviation | **User** | Pause & ask |

## Iteration Limits

OP Mode prevents infinite loops:

```
Attempt 1: Initial solution
    ↓ Failed
Attempt 2: Alternative approach
    ↓ Failed
Attempt 3: Subagent team consultation
    ↓ Failed
Attempt 4: Full team recommendation
    ↓ Failed
ESCALATE → Linear (if available) → User
```

## Memory Structure

OP Mode maintains session state in `.uop/`:

```
.uop/
├── INDEX.md                    # Quick reference (500 tokens)
├── sessions/
│   └── {session-id}/
│       ├── PLAN.md             # Approved plan
│       ├── DECISION_TREE.md    # Living decisions
│       ├── ISSUES.md           # Issue tracking
│       ├── MCP_LOG.md          # Tagged MCP interactions
│       ├── PROGRESS_STATE.md   # Progress tracking for recovery (v2.1.0)
│       └── VALIDATION.md       # Test results
├── history/
│   ├── decisions/              # Past decisions
│   ├── issues/                 # Resolved patterns
│   └── patterns/               # Learned patterns
└── summaries/
    └── {topic}.md              # Topic summaries
```

## File Structure

```
~/.claude/commands/op-mode/
├── SKILL.md                    # Main skill definition
├── CHANGELOG.md                # Version history (v2.1.0+)
├── reference/
│   ├── authority-matrix.md     # Decision authority rules
│   └── iteration-protocol.md   # Escalation flow
└── templates/
    ├── session-init.md         # Session file templates
    ├── plan-approval.md        # User Touchpoint 1
    ├── final-report.md         # User Touchpoint 2
    └── escalation-report.md    # Issue escalation
```

## Integration Points

### GSD (Get Shit Done)
- Deviation rules for auto-fix vs ask
- Checkpoint protocols
- Goal-backward analysis

### RLM-Coder
- Historical context queries
- Active planning participation
- Pattern recognition

### MCP Tools
- Supabase (database operations)
- Stripe (payment operations)
- Playwright (visual validation)
- Linear (issue escalation)

## Requirements

- **Claude Code** CLI installed and configured
- **Optional**: RLM-Coder skill for enhanced analysis
- **Optional**: GSD skill for project planning
- **Optional**: MCP servers (Supabase, Stripe, Playwright, Linear)

## Contributing

Contributions welcome! Please submit issues and pull requests.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Credits

Built on principles from:
- GSD (Get Shit Done) methodology
- RLM-Coder recursive analysis
- Claude Code subagent patterns
