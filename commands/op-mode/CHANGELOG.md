# OP Mode Changelog

## v3.0.0 - 2026-02-26

### Major Upgrade: 12 Enhancements + E2E Agent-Browser + Multi-Project Scope

**Breaking Changes:** iteration limits reduced from 4 to 3 attempts, Phase 6 now uses `agent-browser` instead of Playwright MCP.

#### Major Changes

1. **Gate 0 Light Mode Bypass** - Skip Phases 1-4 for simple fixes (typos, CSS, config)
2. **Phase 6 Replaced** - agent-browser E2E testing (93% token reduction vs Playwright)
3. **Multi-Project Scope** - `.uop/project.json` enables per-project configuration
4. **3-Failure Architectural Stop** - Reduced from 4 attempts to 3, with circular fix detection
5. **Checkpoint & Resume v2** - Phase boundaries + heartbeat (every 10 tool calls) + emergency saves
6. **TDD Enforcement** - Phase 5.0 mandates red-green-refactor for all implementation

#### New Features

- **Skill Auto-Discovery** - Scans `.claude/skills/`, `.skills/`, `.local-plugins/` and builds runtime manifest
- **Failure Mode Journal** - Cross-session error memory in `.uop/failures.md`
- **Change Tracking** - Auto-append plain-English summaries to `.uop/sessions/{id}/CHANGES.md`
- **Human Handoff Package** - Generate `.uop/handoffs/handoff-{task-id}.md` for developer transitions
- **Doc Freshness Scanner** - Auto-detect stale references in `/docs` using `.uop/deprecated-terms.json`
- **Auto-Resume Detection** - Presents checkpoint options at session start
- **Learning Summaries** - Optional "Explain What You Did" section in Phase 7 reports
- **Heartbeat Checkpoints** - Lightweight mid-phase saves every 10 tool calls

#### Patterns Absorbed

- **obra/superpowers** - TDD (red-green-refactor), YAGNI/DRY principles, 3-failure stop
- **Cole Medin E2E skill** - Parallel research agents, agent-browser CLI, DB validation queries

#### Files Modified

- `commands/op-mode/SKILL.md` - 2,691 lines (+1,058 from v2.1.0, +75% growth)
- `commands/op-mode/reference/iteration-protocol.md` - 344 lines (3-attempt limit)

#### New Template Files (created at runtime in `.uop/`)

- `project.json` - Project identity, tech stack, conventions
- `skill-manifest.json` - Auto-discovered skills
- `deprecated-terms.json` - Stale reference terms
- `failures.md` - Error pattern journal
- `sessions/{id}/CHECKPOINT.md` - Phase boundary state
- `sessions/{id}/HEARTBEAT.md` - Mid-phase snapshot
- `sessions/{id}/EMERGENCY_SAVE.md` - Pre-compaction save
- `sessions/{id}/CHANGES.md` - Plain English change log
- `handoffs/handoff-{task-id}.md` - Developer handoff package

---

## v2.1.0 - 2026-01-22

### Enhanced: Always-Visible Progress Tracking

**New Feature:** Persistent in-response progress display that never lets you lose track.

#### What's New

- **Every Response Shows Progress** - No more wondering where you are
  - Compact format for mid-work updates
  - Standard format for task transitions
  - Full dashboard for phase transitions

- **Hierarchical Task Expansion** - See the breakdown as work gets detailed
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

- **Remaining Items Summary** - Always know what's left
  ```
  📋 Remaining: 4 tasks in current phase │ 3 phases after this │ 0 blockers
  ```

- **Context Preservation** - Every response restores context when resuming
- **Progress State File** - `.uop/sessions/{id}/PROGRESS_STATE.md` for recovery

#### Progress Display Formats

| Format | When Used | Example |
|--------|-----------|---------|
| Compact | Every response | `⟦■■■■□□□⟧ Phase 4/7 │ Task 3/8` |
| Standard | Task transitions | Full progress bar + current/next task |
| Dashboard | Phase transitions | Complete status with task breakdown |

#### Anti-Patterns Fixed

- ❌ Skipping progress in responses → ✅ Every response has progress
- ❌ "Continuing..." without context → ✅ Full context restoration
- ❌ Hiding remaining work → ✅ Always show remaining count
- ❌ Assuming user remembers → ✅ Restore context every time

---

## v2.0.0 - 2025-01-21

### Added: Status Line Progress Bar Integration

**New Feature:** Real-time progress bar display in Claude Code's terminal status line.

#### What's New

- **OP Mode Progress Bar** - Shows current phase progress (1-7) with phase name
  ```
  Opus 4 │OP █░░░░░░ 1/7 Init │ project-name ████░░░░░░ 40%
  ```

- **GSD Progress Bar** - Shows phase and plan progress when using GSD workflow
  ```
  Opus 4 │GSD ███░░░░ P2/4 (1/2 plans) │ project-name █████░░░░░ 55%
  ```

- **Color-coded progress**:
  - Blue: < 40% progress
  - Yellow: 40-70% progress
  - Cyan: 70-99% progress
  - Green: 100% complete

#### OP Mode Phases Displayed

| Phase | Name | Description |
|-------|------|-------------|
| 1 | Init | Initialization |
| 2 | Plan | Planning (RLM + PRD) |
| 3 | Approve | Plan Approval [USER] |
| 4 | Implement | Implementation |
| 5 | Issues | Issue Resolution |
| 6 | Validate | Validation & Testing |
| 7 | Report | Final Report [USER] |

#### Detection Logic

- **OP Mode**: Detects `.uop/sessions/` directory and parses TodoWrite phases
- **GSD Mode**: Detects `.planning/` directory and parses STATE.md + ROADMAP.md

#### Installation

The status line script is installed at:
```
~/.claude/hooks/statusline.js
```

Configuration in `~/.claude/settings.json`:
```json
{
  "statusLine": {
    "type": "command",
    "command": "node \"$HOME/.claude/hooks/statusline.js\""
  }
}
```

#### Files Added

- `hooks/statusline.js` - Enhanced status line with OP/GSD progress tracking

---

## v1.0.0 - 2025-01-19

### Initial Release

- Unified GSD + RLM + Subagent workflow
- 7-phase task lifecycle with gates
- RLM memory structure (.uop/)
- MCP integration logging
- Decision tree tracking
- Context window management (Harvard Protocol)
