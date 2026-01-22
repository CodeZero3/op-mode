# OP Mode Changelog

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
