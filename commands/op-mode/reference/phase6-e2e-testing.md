# Phase 6: E2E Browser Testing Protocol

> Reference file for OP Mode v4.0. Loaded on-demand, not part of core SKILL.md.
> See main SKILL.md for when to reference this file.

---

**OPTIONAL -- This protocol requires `agent-browser` to be installed. Use when browser-based validation is needed (UI changes, user journeys, responsive layout). Skip for backend-only or API-only changes where unit/integration tests suffice.**

## Overview

Phase 6 uses `agent-browser` (Anthropic CLI) for interactive browser testing. It replaces Playwright MCP with a token-efficient accessibility tree approach.

**Token cost:** ~385 chars/snapshot vs ~4,127 chars (Playwright). **93% savings.**

---

## 6.0 Pre-Flight Check

```bash
# Verify agent-browser is installed
which agent-browser || npm install -g agent-browser

# Verify platform (Linux/WSL/macOS only -- no native Windows)
uname -s  # Must return Linux or Darwin

# If missing system deps (Chromium headless):
# Ubuntu/Debian: sudo apt-get install -y chromium-browser
# macOS: brew install chromium
```

---

## 6.1 Parallel Research Sub-Agents (Before Testing)

Launch 3 sub-agents in parallel to build testing context.

### Sub-Agent A: Structure Mapper

Maps the application structure for E2E testing:
1. Read all HTML files -- identify pages, sections, navigation flows
2. List every user journey (e.g., login -> dashboard -> create item -> verify)
3. Identify all interactive elements: forms, buttons, modals, dropdowns, tabs
4. Document the app startup command and base URL
5. Document any auth requirements

**Output format:**
```
## Pages
- {page}: {URL path} -- {key interactive elements}

## User Journeys
1. {journey_name}: {step1} -> {step2} -> {step3} -> {expected_outcome}

## Auth Flow
- Method: {cookie/token/session}
- Login endpoint: {path}
- Test credentials: {how to obtain}

## Startup
- Command: {command}
- Ready signal: {what to look for in logs}
- Base URL: {url}
```

### Sub-Agent B: Schema & Data Mapper

Documents the database schema and data flows for E2E validation:
1. Read all migration files -- build table/column inventory
2. Identify which tables get written during key user actions
3. Document expected DB state after each user journey
4. Find the DB connection method

**Output format:**
```
## Key Tables for Validation
| Table | Written By | Key Columns | Expected After Action |

## DB Connection
- Type: {PostgreSQL/MySQL/SQLite}
- Connection: {env var or config path}
- Query tool: psql / mysql / sqlite3

## Validation Queries
For each user journey, provide a SQL query to verify the action took effect.
```

### Sub-Agent C: Bug Hunter (Pre-Test)

Scans the codebase for potential bugs BEFORE E2E testing:
1. Unhandled error paths in route handlers
2. Missing form validations (frontend and backend)
3. Race conditions in async flows
4. Hardcoded values that should be configurable
5. Console.error or TODO/FIXME/HACK comments
6. Missing null checks on DB query results

**Output format:**
```
## Potential Issues (prioritized)
| # | File | Line | Issue | Severity | Likely to Surface in E2E? |
```

**Wait for all 3 sub-agents to complete.** Merge their outputs into `.uop/sessions/{id}/VALIDATION.md`.

---

## 6.2 Application Startup & Browser Launch

```bash
# Start the application (command from Sub-Agent A research)
cd backend && node src/server.js &  # OR npm start &
APP_PID=$!

# Wait for ready signal
sleep 3

# Verify app is running
curl -s http://localhost:3000/health || curl -s http://localhost:3000 || echo "APP NOT READY"

# Open browser via agent-browser
agent-browser open http://localhost:3000

# Take initial snapshot to confirm load
agent-browser snapshot -i
# Expected: Accessibility tree with page elements and @eN references
```

### Generic Auth Flow (If App Requires Login)

```bash
agent-browser snapshot -i
# Find email/username input (@eN), password input (@eM), submit button (@eK)
agent-browser fill @eN "test@example.com"
agent-browser fill @eM "testpassword"
agent-browser click @eK
agent-browser wait --load networkidle
agent-browser snapshot -i
# Verify: dashboard or home page loaded
```

---

## 6.3 Create Test Task List

Based on Sub-Agent A's user journeys and Sub-Agent C's bug list:

```markdown
## E2E Test Tasks

### Core Journeys
- [ ] J1: {journey_name} -- {steps}
- [ ] J2: {journey_name} -- {steps}

### Bug Verification (from Sub-Agent C)
- [ ] B1: Verify {potential_bug} does/doesn't manifest
- [ ] B2: ...

### Responsive Testing
- [ ] R1: Mobile (375x812) -- key pages render correctly
- [ ] R2: Tablet (768x1024) -- layout adapts
- [ ] R3: Desktop (1440x900) -- full layout

### Data Integrity
- [ ] D1: After {action}, verify DB state with query from Sub-Agent B
- [ ] D2: ...
```

---

## 6.4 Execute User Journey Tests

For each journey task, follow this exact cycle:

### Step 1: Snapshot & Orient

```bash
agent-browser snapshot -i
# Read the accessibility tree. Identify target elements by @eN refs.
# DO NOT guess element refs -- always snapshot first.
```

### Step 2: Interact

```bash
agent-browser click @eN          # Click navigation, buttons, links
agent-browser fill @eN "value"   # Fill form fields
agent-browser select @eN "option_value"  # Select dropdowns
agent-browser press Enter         # Press keys (Enter, Escape, Tab)
agent-browser wait --load networkidle    # Wait for page to settle
```

### Step 3: Capture Evidence

```bash
mkdir -p /tmp/e2e-screenshots/{journey_name}
agent-browser screenshot /tmp/e2e-screenshots/{journey_name}/step-{N}.png

# Check for console errors:
agent-browser errors
# If errors found -> document in ISSUES.md, attempt fix

# Check console logs:
agent-browser console
```

### Step 4: Visual Analysis

```bash
Read(/tmp/e2e-screenshots/{journey_name}/step-{N}.png)

# Verify:
# - Layout renders correctly (no overlap, no missing elements)
# - Data displays as expected (correct values, correct order)
# - Interactive state is correct (active tab, selected item, open modal)
# - No error messages visible
# - Loading states resolved
```

### Step 5: Database Validation (After Data-Modifying Actions)

```bash
# Use query from Sub-Agent B's validation queries
psql "$DATABASE_URL" -c "SELECT id, status, created_at FROM {table} ORDER BY created_at DESC LIMIT 3;"

# Verify:
# - Record exists with expected values
# - Timestamps are recent
# - Foreign keys resolve correctly
# - If RLS enabled: add tenant context to WHERE clause
```

### Step 6: Fix-in-Place (If Issues Found)

```bash
# 1. Document the issue in ISSUES.md
# 2. Fix the code (if within iteration budget -- max 3 attempts)
# 3. Restart app if needed
# 4. Re-test the same step
# 5. Capture confirmation screenshot: step-{N}-fixed.png
```

**Repeat Steps 1-6 for every journey step, then move to next journey.**

---

## 6.5 Responsive Testing

After all journeys pass, test key pages at 3 viewports:

```bash
# Mobile
agent-browser set viewport 375 812
agent-browser open {page_url}
agent-browser wait --load networkidle
agent-browser screenshot /tmp/e2e-screenshots/responsive/mobile-{page}.png

# Tablet
agent-browser set viewport 768 1024
agent-browser open {page_url}
agent-browser wait --load networkidle
agent-browser screenshot /tmp/e2e-screenshots/responsive/tablet-{page}.png

# Desktop
agent-browser set viewport 1440 900
agent-browser open {page_url}
agent-browser wait --load networkidle
agent-browser screenshot /tmp/e2e-screenshots/responsive/desktop-{page}.png
```

**Verify each screenshot:**
- No horizontal scroll on mobile
- Navigation collapses/hamburger on mobile
- Tables adapt (scroll or stack) on small screens
- Modals don't overflow viewport
- Text remains readable (no truncation)

### Browser Cleanup

```bash
agent-browser close
kill $APP_PID 2>/dev/null || true
```

---

## 6.6 Mandatory Unit Test Generation

For every implementation, also generate unit/integration tests:
1. **Happy Path Test** -- Primary use case works
2. **Edge Case Test #1** -- Boundary condition
3. **Edge Case Test #2** -- Error handling / empty state

```bash
npm test -- --testPathPattern="{feature_test_pattern}"
```

---

## 6.7 Self-Test Checklist (MANDATORY before Phase 7)

```markdown
## Pre-Return Checklist

### E2E Browser Validation
- [ ] All user journeys executed and screenshotted
- [ ] No unresolved console errors (agent-browser errors returns clean)
- [ ] All data-modifying actions verified against DB
- [ ] Responsive testing passed at 3 viewports (mobile/tablet/desktop)
- [ ] All Sub-Agent C bugs either confirmed fixed or documented as acceptable

### Code Quality
- [ ] All generated unit tests pass
- [ ] No TypeScript/lint errors (npm run build / npm run lint)
- [ ] No console errors in browser

### Documentation
- [ ] Decision tree updated
- [ ] Issues documented with solutions
- [ ] MCP log complete
- [ ] Screenshots saved to /tmp/e2e-screenshots/

### Summary Stats
- Journeys tested: {N}
- Screenshots captured: {N}
- Issues found: {N}
- Issues fixed inline: {N}
- Issues deferred: {N}
- DB validations passed: {N}
```

**All boxes MUST be checked before proceeding to Phase 7.**
