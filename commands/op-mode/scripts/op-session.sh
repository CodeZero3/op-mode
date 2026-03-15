#!/usr/bin/env bash
# op-session.sh — OP Mode session lifecycle automation
# Usage:
#   op-session.sh start <slug>              Start a new session
#   op-session.sh end <id> <STATUS> <summary>  Close a session
#   op-session.sh audit                     Find orphans/phantoms
#   op-session.sh status                    Show current session state
#   op-session.sh recover                   Fix crashed/orphaned sessions
#   op-session.sh force-close               Non-interactive cleanup of stale sessions

set -euo pipefail

# Project root (adjust if script moves)
PROJECT_ROOT="$(cd "$(dirname "$0")/../../../../" && pwd)"
SESSIONS_DIR="$PROJECT_ROOT/.uop/sessions"
INDEX_FILE="$PROJECT_ROOT/.uop/INDEX.md"
ARCHIVE_FILE="$PROJECT_ROOT/.uop/INDEX-ARCHIVE.md"
CURRENT_SESSION_FILE="$SESSIONS_DIR/CURRENT_SESSION"
LOCK_FILE="$SESSIONS_DIR/.session.lock"
LOCK_TTL_SECONDS=3600  # 1 hour — auto-clear stale locks

# ── Locking ──────────────────────────────────────────────────────────────────

acquire_lock() {
  # Check for stale lock (older than LOCK_TTL_SECONDS)
  if [[ -d "$LOCK_FILE" ]]; then
    local lock_time
    if [[ -f "$LOCK_FILE/timestamp" ]]; then
      lock_time="$(cat "$LOCK_FILE/timestamp")"
      local now
      now="$(date +%s)"
      local age=$(( now - lock_time ))
      if [[ $age -gt $LOCK_TTL_SECONDS ]]; then
        echo "WARNING: Stale lock detected (${age}s old). Auto-clearing."
        rm -rf "$LOCK_FILE"
      else
        echo "ERROR: Another session operation is in progress (lock age: ${age}s)"
        echo "If this is stale, remove it: rm -rf $LOCK_FILE"
        exit 1
      fi
    else
      # Lock dir exists but no timestamp — treat as stale
      echo "WARNING: Lock without timestamp found. Auto-clearing."
      rm -rf "$LOCK_FILE"
    fi
  fi

  if ! mkdir "$LOCK_FILE" 2>/dev/null; then
    echo "ERROR: Failed to acquire session lock"
    exit 1
  fi
  date +%s > "$LOCK_FILE/timestamp"
  trap 'rm -rf "$LOCK_FILE"' EXIT
}

# ── Auto-commit ──────────────────────────────────────────────────────────────

auto_commit_if_dirty() {
  local session_id="$1"
  local summary="$2"
  local op_mode_root
  op_mode_root="$(cd "$(dirname "$0")/../../../" && pwd)"

  # Only commit if this is a git repo
  if [[ ! -d "$op_mode_root/.git" ]]; then
    return 0
  fi

  (
    cd "$op_mode_root"
    local changes
    changes="$(git status --porcelain 2>/dev/null)"
    if [[ -z "$changes" ]]; then
      echo "  op-mode repo: clean — no commit needed"
      return 0
    fi

    local file_count
    file_count="$(echo "$changes" | wc -l | tr -d ' ')"
    echo "  op-mode repo: $file_count file(s) changed — committing..."
    git add -A
    git commit -m "session($session_id): $summary" \
               -m "Auto-committed by op-session.sh end" \
               -m "Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>" \
      2>&1 | sed 's/^/    /'
    echo "  op-mode repo: committed"
  ) || echo "  WARNING: op-mode auto-commit failed (non-fatal)"
}

# ── Commands ─────────────────────────────────────────────────────────────────

cmd_start() {
  acquire_lock

  local slug="$1"
  local date_suffix
  date_suffix="$(date +%Y%m%d)"
  local session_id="${slug}-${date_suffix}"
  local session_dir="$SESSIONS_DIR/$session_id"

  # Check if session already exists
  if [[ -d "$session_dir" ]]; then
    echo "ERROR: Session directory already exists: $session_dir"
    echo "Use a different slug or resume the existing session."
    exit 1
  fi

  # Check for stale CURRENT_SESSION
  if [[ -f "$CURRENT_SESSION_FILE" ]]; then
    local current
    current="$(cat "$CURRENT_SESSION_FILE" | tr -d '[:space:]')"
    if [[ "$current" != "none" && "$current" != "" ]]; then
      echo "WARNING: Previous session still open: $current"
      echo "Consider closing it first with: op-session.sh end $current SUPERSEDED \"superseded by $session_id\""
    fi
  fi

  # Create session directory + PLAN.md with canonical section ordering
  mkdir -p "$session_dir"
  cat > "$session_dir/PLAN.md" << 'PLAN_EOF'
# Session Plan

## Objective
<!-- What are we building/fixing? -->

## Sizing
<!-- MODE — 1-line rationale -->

## Gate Log
### Gate 1: Session Initialized
- [ ] `op-session.sh start` ran → session ID:
- [ ] CURRENT_SESSION set → verified

### Gate 2: Knowledge Loaded
- [ ] Pinecone query: "" → top score: | hit:
- [ ] INDEX.md read → overdue items:
- [ ] Topic file loaded: memory/
- [ ] NotebookLM:

### Gate 3: Plan Approved (Full Mode only)
- [ ] User said: "" at

## Tasks
<!-- Numbered task list with checkboxes -->
- [ ] Task 1
- [ ] Task 2

## Files to Modify
<!-- file_path — what changes -->

## Decisions
<!-- Log decisions inline as they're made -->

## Scope Changes
<!-- Document any additions/removals from original plan -->

## Validation
<!-- Test results, health checks, Codex self-assessment -->

## Graduation
<!-- Lesson text + status (completed/deferred) -->

## UNIFY
<!-- Planned vs actual reconciliation -->
PLAN_EOF

  # Update CURRENT_SESSION
  echo "$session_id" > "$CURRENT_SESSION_FILE"

  echo "Session started: $session_id"
  echo "  Directory: $session_dir"
  echo "  PLAN.md created (edit with your plan)"
  echo "  CURRENT_SESSION updated"
}

cmd_end() {
  acquire_lock

  local session_id="$1"
  local status="${2:-COMPLETE}"
  local summary="${3:-No summary provided}"
  local session_dir="$SESSIONS_DIR/$session_id"

  # Verify session exists
  if [[ ! -d "$session_dir" ]]; then
    echo "ERROR: Session directory not found: $session_dir"
    exit 1
  fi

  # Check PLAN.md exists and is non-empty
  if [[ ! -s "$session_dir/PLAN.md" ]]; then
    echo "WARNING: PLAN.md is empty or missing in $session_dir"
  fi

  # Clear CURRENT_SESSION
  echo "none" > "$CURRENT_SESSION_FILE"

  # Append to INDEX.md
  local date_str
  date_str="$(date +%Y-%m-%d)"
  local index_entry="- **Session ${session_id}**: ✅ ${status} (${date_str}) — ${summary}"

  # Find the insertion point (after "### Recent Completed Sessions" line)
  if grep -q "### Recent Completed Sessions" "$INDEX_FILE"; then
    # Insert after the header line
    sed -i '' "/### Recent Completed Sessions/a\\
${index_entry}" "$INDEX_FILE"
  else
    # Append to end if header not found
    echo "" >> "$INDEX_FILE"
    echo "$index_entry" >> "$INDEX_FILE"
  fi

  auto_commit_if_dirty "$session_id" "$summary"

  echo "Session closed: $session_id ($status)"
  echo "  CURRENT_SESSION cleared"
  echo "  INDEX.md updated"
}

cmd_status() {
  echo "=== OP Mode Session Status ==="
  echo ""

  # Current session
  echo "--- Current Session ---"
  if [[ -f "$CURRENT_SESSION_FILE" ]]; then
    local current
    current="$(cat "$CURRENT_SESSION_FILE" | tr -d '[:space:]')"
    if [[ "$current" == "none" || "$current" == "" ]]; then
      echo "  No active session"
    else
      echo "  Active: $current"
      if [[ -d "$SESSIONS_DIR/$current" ]]; then
        # Show task progress from PLAN.md
        local done total
        done="$(grep -c '^\- \[x\]' "$SESSIONS_DIR/$current/PLAN.md" 2>/dev/null || true)"
        total="$(grep -c '^\- \[' "$SESSIONS_DIR/$current/PLAN.md" 2>/dev/null || true)"
        done="${done:-0}"
        total="${total:-0}"
        echo "  Tasks: $done/$total complete"
        local has_final="NO"
        [[ -f "$SESSIONS_DIR/$current/FINAL_REPORT.md" ]] && has_final="YES"
        echo "  FINAL_REPORT: $has_final"
      else
        echo "  WARNING: Directory missing!"
      fi
    fi
  else
    echo "  CURRENT_SESSION file missing"
  fi
  echo ""

  # Last 3 completed sessions from INDEX.md
  echo "--- Recent Completed ---"
  if [[ -f "$INDEX_FILE" ]]; then
    grep -m 3 '^\- \*\*Session' "$INDEX_FILE" 2>/dev/null || echo "  (none found)"
  else
    echo "  INDEX.md not found"
  fi
  echo ""

  # Lock status
  echo "--- Lock ---"
  if [[ -d "$LOCK_FILE" ]]; then
    if [[ -f "$LOCK_FILE/timestamp" ]]; then
      local lock_time
      lock_time="$(cat "$LOCK_FILE/timestamp")"
      local now
      now="$(date +%s)"
      echo "  LOCKED (age: $(( now - lock_time ))s)"
    else
      echo "  LOCKED (no timestamp — possibly stale)"
    fi
  else
    echo "  Unlocked"
  fi
}

cmd_recover() {
  echo "=== OP Mode Session Recovery ==="
  echo ""

  if [[ ! -f "$CURRENT_SESSION_FILE" ]]; then
    echo "No CURRENT_SESSION file — nothing to recover."
    return
  fi

  local current
  current="$(cat "$CURRENT_SESSION_FILE" | tr -d '[:space:]')"

  if [[ "$current" == "none" || "$current" == "" ]]; then
    echo "No active session — nothing to recover."
    return
  fi

  echo "Found open session: $current"

  if [[ ! -d "$SESSIONS_DIR/$current" ]]; then
    echo "  Directory MISSING — clearing stale CURRENT_SESSION"
    echo "none" > "$CURRENT_SESSION_FILE"
    echo "  RECOVERED: CURRENT_SESSION reset to 'none'"
    return
  fi

  if [[ -f "$SESSIONS_DIR/$current/FINAL_REPORT.md" ]]; then
    echo "  Session has FINAL_REPORT — was completed but not closed"
    echo "  Auto-closing as COMPLETE..."
    # Clear CURRENT_SESSION
    echo "none" > "$CURRENT_SESSION_FILE"
    # Add to INDEX
    local date_str
    date_str="$(date +%Y-%m-%d)"
    local index_entry="- **Session ${current}**: ✅ RECOVERED (${date_str}) — auto-closed from recovery"
    if grep -q "### Recent Completed Sessions" "$INDEX_FILE" 2>/dev/null; then
      sed -i '' "/### Recent Completed Sessions/a\\
${index_entry}" "$INDEX_FILE"
    else
      echo "" >> "$INDEX_FILE"
      echo "$index_entry" >> "$INDEX_FILE"
    fi
    echo "  RECOVERED: Session closed, INDEX.md updated"
    return
  fi

  # Session is genuinely open — show state and let user decide
  echo "  Session is genuinely open (no FINAL_REPORT)"
  local done
  done="$(grep -c '^\- \[x\]' "$SESSIONS_DIR/$current/PLAN.md" 2>/dev/null || echo 0)"
  local total
  total="$(grep -c '^\- \[[ x]\]' "$SESSIONS_DIR/$current/PLAN.md" 2>/dev/null || echo 0)"
  echo "  Tasks: $done/$total complete"
  echo ""
  echo "Options:"
  echo "  A) Resume: read PLAN.md and continue"
  echo "  B) Close as ABANDONED: op-session.sh end $current ABANDONED \"abandoned — recovered\""
  echo "  C) Close as COMPLETE:  op-session.sh end $current COMPLETE \"completed — recovered\""
}

cmd_force_close() {
  acquire_lock

  echo "=== Force Close ==="

  if [[ ! -f "$CURRENT_SESSION_FILE" ]]; then
    echo "No CURRENT_SESSION file — nothing to close."
    return
  fi

  local current
  current="$(cat "$CURRENT_SESSION_FILE" | tr -d '[:space:]')"

  if [[ "$current" == "none" || "$current" == "" ]]; then
    echo "No active session — nothing to close."
    return
  fi

  echo "Force-closing session: $current"
  echo "none" > "$CURRENT_SESSION_FILE"

  # Add to INDEX
  local date_str
  date_str="$(date +%Y-%m-%d)"
  local index_entry="- **Session ${current}**: ⚠️ FORCE-CLOSED (${date_str}) — non-interactive cleanup"
  if grep -q "### Recent Completed Sessions" "$INDEX_FILE" 2>/dev/null; then
    sed -i '' "/### Recent Completed Sessions/a\\
${index_entry}" "$INDEX_FILE"
  else
    echo "" >> "$INDEX_FILE"
    echo "$index_entry" >> "$INDEX_FILE"
  fi

  auto_commit_if_dirty "$current" "force-closed session"

  echo "  CURRENT_SESSION cleared"
  echo "  INDEX.md updated (marked FORCE-CLOSED)"
}

cmd_audit() {
  echo "=== OP Mode Session Audit ==="
  echo ""

  # 1. Check CURRENT_SESSION
  echo "--- CURRENT_SESSION ---"
  if [[ -f "$CURRENT_SESSION_FILE" ]]; then
    local current
    current="$(cat "$CURRENT_SESSION_FILE" | tr -d '[:space:]')"
    if [[ "$current" == "none" || "$current" == "" ]]; then
      echo "OK: No active session"
    else
      if [[ -d "$SESSIONS_DIR/$current" ]]; then
        if [[ -f "$SESSIONS_DIR/$current/FINAL_REPORT.md" ]]; then
          echo "STALE: Points to '$current' which has a FINAL_REPORT (should be closed)"
        else
          echo "ACTIVE: $current (in progress)"
        fi
      else
        echo "BROKEN: Points to '$current' but directory doesn't exist"
      fi
    fi
  else
    echo "MISSING: CURRENT_SESSION file doesn't exist"
  fi
  echo ""

  # 2. Find orphaned directories (on disk but not in INDEX.md)
  echo "--- Orphaned Directories (on disk, not in INDEX.md) ---"
  local orphan_count=0
  for dir in "$SESSIONS_DIR"/*/; do
    [[ ! -d "$dir" ]] && continue
    local dirname
    dirname="$(basename "$dir")"
    # Skip special entries
    [[ "$dirname" == "CURRENT_SESSION" ]] && continue
    [[ "$dirname" == "current-session.txt" ]] && continue
    [[ "$dirname" == ".session.lock" ]] && continue

    if ! grep -q "$dirname" "$INDEX_FILE" 2>/dev/null && ! grep -q "$dirname" "$ARCHIVE_FILE" 2>/dev/null; then
      echo "  ORPHAN: $dirname"
      orphan_count=$((orphan_count + 1))
    fi
  done
  if [[ $orphan_count -eq 0 ]]; then
    echo "  OK: No orphaned directories"
  fi
  echo ""

  # 3. Find phantom INDEX entries (in INDEX.md but no directory)
  echo "--- Phantom INDEX Entries (in INDEX.md, no directory) ---"
  local phantom_count=0
  while IFS= read -r line; do
    # Extract session ID from lines like "- **Session some-id-here**:"
    if [[ "$line" =~ \*\*Session\ ([a-zA-Z0-9_-]+)\*\* ]]; then
      local sid="${BASH_REMATCH[1]}"
      if [[ ! -d "$SESSIONS_DIR/$sid" ]]; then
        echo "  PHANTOM: $sid (in INDEX.md but no directory)"
        phantom_count=$((phantom_count + 1))
      fi
    fi
  done < "$INDEX_FILE"
  if [[ $phantom_count -eq 0 ]]; then
    echo "  OK: No phantom entries"
  fi
  echo ""

  # 4. Empty session directories
  echo "--- Empty Session Directories ---"
  local empty_count=0
  for dir in "$SESSIONS_DIR"/*/; do
    [[ ! -d "$dir" ]] && continue
    local dirname
    dirname="$(basename "$dir")"
    [[ "$dirname" == "CURRENT_SESSION" ]] && continue
    [[ "$dirname" == ".session.lock" ]] && continue
    local file_count
    file_count="$(find "$dir" -maxdepth 1 -type f | wc -l | tr -d ' ')"
    if [[ "$file_count" -eq 0 ]]; then
      echo "  EMPTY: $dirname (0 files)"
      empty_count=$((empty_count + 1))
    fi
  done
  if [[ $empty_count -eq 0 ]]; then
    echo "  OK: No empty directories"
  fi
  echo ""

  # 5. Lock status
  echo "--- Lock Status ---"
  if [[ -d "$LOCK_FILE" ]]; then
    if [[ -f "$LOCK_FILE/timestamp" ]]; then
      local lock_time
      lock_time="$(cat "$LOCK_FILE/timestamp")"
      local now
      now="$(date +%s)"
      local age=$(( now - lock_time ))
      if [[ $age -gt $LOCK_TTL_SECONDS ]]; then
        echo "  STALE LOCK: ${age}s old (will auto-clear on next operation)"
      else
        echo "  ACTIVE LOCK: ${age}s old"
      fi
    else
      echo "  LOCK WITHOUT TIMESTAMP (stale)"
    fi
  else
    echo "  OK: No lock"
  fi
  echo ""

  # Summary
  local total=$((orphan_count + phantom_count + empty_count))
  echo "=== Summary ==="
  echo "  Orphans: $orphan_count | Phantoms: $phantom_count | Empty: $empty_count"
  if [[ $total -eq 0 ]]; then
    echo "  STATUS: CLEAN"
  else
    echo "  STATUS: $total issues found"
  fi
}

# Main dispatch
case "${1:-}" in
  start)
    [[ -z "${2:-}" ]] && echo "Usage: op-session.sh start <slug>" && exit 1
    cmd_start "$2"
    ;;
  end)
    [[ -z "${2:-}" ]] && echo "Usage: op-session.sh end <session-id> [STATUS] [summary]" && exit 1
    cmd_end "$2" "${3:-COMPLETE}" "${4:-No summary provided}"
    ;;
  audit)
    cmd_audit
    ;;
  status)
    cmd_status
    ;;
  recover)
    cmd_recover
    ;;
  force-close)
    cmd_force_close
    ;;
  *)
    echo "Usage: op-session.sh {start|end|audit|status|recover|force-close}"
    echo ""
    echo "Commands:"
    echo "  start <slug>                    Start a new session"
    echo "  end <id> [STATUS] [summary]     Close a session (STATUS: COMPLETE|SUPERSEDED|ABANDONED)"
    echo "  audit                           Find orphans, phantoms, stale state"
    echo "  status                          Show current session state + recent history"
    echo "  recover                         Fix crashed/orphaned sessions"
    echo "  force-close                     Non-interactive cleanup of stale CURRENT_SESSION"
    exit 1
    ;;
esac
