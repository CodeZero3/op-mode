# OP Mode - Orchestration Protocol for Claude Code

**Unified workflow combining GSD planning, RLM analysis, Subagent execution, and MCP integration.**

OP Mode is a Claude Code skill that provides an end-to-end orchestrated development workflow with only two user touchpoints: Plan Approval and Final Validation.

## Features

- **Two User Touchpoints Only** - Plan Approval + Final Validation (autonomous in between)
- **RLM as Active Partner** - Queries history, participates in planning decisions
- **Iteration Limits** - 4 attempts max per issue, then escalate to Linear/user
- **Auto-Testing** - Generates 1 happy path + 2 edge case tests
- **Visual Validation** - Playwright checks for UI changes
- **Progress Dashboard** - Persistent status display throughout session
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

## Progress Dashboard

OP Mode maintains a visible progress tracker throughout:

```
╔══════════════════════════════════════════════════════════════╗
║  OP MODE STATUS DASHBOARD                                     ║
╠══════════════════════════════════════════════════════════════╣
║  Session: op-2026-01-19-001                                   ║
║  Task: Add OAuth authentication                               ║
╠──────────────────────────────────────────────────────────────╣
║  OVERALL PROGRESS                                             ║
║  ████████████░░░░░░░░  Phase 4 of 7  (Implementation)        ║
╠──────────────────────────────────────────────────────────────╣
║  [✓] 1. Initialization                                        ║
║  [✓] 2. Planning                                              ║
║  [✓] 3. Plan Approval                                         ║
║  [→] 4. Implementation  ← YOU ARE HERE                        ║
║  [ ] 5. Issue Resolution                                      ║
║  [ ] 6. Validation                                            ║
║  [ ] 7. Final Report                                          ║
╚══════════════════════════════════════════════════════════════╝
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
