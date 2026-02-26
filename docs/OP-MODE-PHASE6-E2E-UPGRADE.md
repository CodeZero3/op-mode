# OP Mode Phase 6 Upgrade: E2E Agent-Browser Validation

> **Purpose:** Replace the current Playwright-based Phase 6 (Post-Implementation Validation) with a comprehensive agent-browser E2E testing workflow adapted from Cole Medin's skill. This is a drop-in replacement for the existing Phase 6 section in `commands/op-mode/SKILL.md`.
>
> **Why:** agent-browser returns compact accessibility tree snapshots (~385 chars) vs Playwright MCP's full DOM (~4,127 chars) — a **93% token reduction** per interaction. For Heartbeat AI's 9,312-line dashboard, this is the difference between burning context on DOM noise and keeping tokens for actual reasoning.

---

## How to Apply

**In your `commands/op-mode/SKILL.md`:**

1. Find `## Phase 6: Post-Implementation Validation`
2. Replace everything from that header through the `**All boxes MUST be checked before proceeding to Phase 7.**` line
3. Paste the replacement below
4. Phase 7 (Final Report) stays unchanged

---

## Replacement: Phase 6 — Post-Implementation Validation (E2E Agent-Browser)

```markdown
## Phase 6: Post-Implementation Validation (E2E Agent-Browser)

> This phase uses `agent-browser` (Vercel Labs CLI) for interactive browser testing.
> It replaces Playwright MCP with a token-efficient accessibility tree approach.
> Token cost: ~385 chars/snapshot vs ~4,127 chars (Playwright). 93% savings.

---

### 6.0 Pre-Flight Check

# Verify agent-browser is installed
which agent-browser || npm install -g agent-browser

# Verify platform (Linux/WSL/macOS only — no native Windows)
uname -s  # Must return Linux or Darwin

# If missing system deps (Chromium headless):
# Ubuntu/Debian: sudo apt-get install -y chromium-browser
# macOS: brew install chromium

---

### 6.1 Parallel Research Sub-Agents (Before Testing)

Launch 3 sub-agents in parallel to build testing context:

#### Sub-Agent A: Structure Mapper

Task(
  subagent_type="general-purpose",
  prompt="Map the application structure for E2E testing.

  Research:
  1. Read all HTML files — identify pages, sections, navigation flows
  2. List every user journey (e.g., login → dashboard → create appointment → verify)
  3. Identify all interactive elements: forms, buttons, modals, dropdowns, tabs
  4. Document the app startup command (e.g., `node src/server.js`)
  5. Document the base URL and any auth requirements

  Output format:
  ## Pages
  - {page}: {URL path} — {key interactive elements}

  ## User Journeys
  1. {journey_name}: {step1} → {step2} → {step3} → {expected_outcome}

  ## Auth Flow
  - Method: {cookie/token/session}
  - Login endpoint: {path}
  - Test credentials: {how to obtain}

  ## Startup
  - Command: {command}
  - Ready signal: {what to look for in logs}
  - Base URL: {url}"
)

#### Sub-Agent B: Schema & Data Mapper

Task(
  subagent_type="general-purpose",
  prompt="Document the database schema and data flows for E2E validation.

  Research:
  1. Read all migration files — build table/column inventory
  2. Identify which tables get written during key user actions
  3. Document expected DB state after each user journey
  4. Find the DB connection method (env var, config file)

  Output format:
  ## Key Tables for Validation
  | Table | Written By | Key Columns | Expected After Action |

  ## DB Connection
  - Type: {PostgreSQL/SQLite}
  - Connection: {env var or config path}
  - Query tool: psql / sqlite3

  ## Validation Queries
  For each user journey, provide a SQL query to verify the action took effect."
)

#### Sub-Agent C: Bug Hunter (Pre-Test)

Task(
  subagent_type="general-purpose",
  prompt="Scan the codebase for potential bugs BEFORE E2E testing.

  Check for:
  1. Unhandled error paths in route handlers
  2. Missing form validations (frontend and backend)
  3. Race conditions in async flows
  4. Hardcoded values that should be configurable
  5. Console.error or TODO/FIXME/HACK comments
  6. Missing null checks on DB query results

  Output format:
  ## Potential Issues (prioritized)
  | # | File | Line | Issue | Severity | Likely to Surface in E2E? |

  Focus on issues that would manifest during browser interaction."
)

Wait for all 3 sub-agents to complete. Merge their outputs into the session's
`.uop/sessions/{id}/VALIDATION.md` file.

---

### 6.2 Application Startup & Browser Launch

# Start the application (command from Sub-Agent A research)
# Example for Heartbeat AI:
cd backend && node src/server.js &
APP_PID=$!

# Wait for ready signal
sleep 3

# Verify app is running
curl -s http://localhost:3000/health/ready || echo "APP NOT READY — check logs"

# Open browser via agent-browser
agent-browser open http://localhost:3000

# Take initial snapshot to confirm load
agent-browser snapshot -i

# Expected: Accessibility tree with page elements and @eN references
# If login page: proceed to auth flow below

#### Auth Flow (Heartbeat AI Specific)

# If app requires login:
agent-browser snapshot -i
# Find email input (@eN), password input (@eM), submit button (@eK)
agent-browser fill @eN "test@heartbeatai.com"
agent-browser fill @eM "testpassword"
agent-browser click @eK
agent-browser wait --load networkidle
agent-browser snapshot -i
# Verify: dashboard or home page loaded

---

### 6.3 Create Test Task List

Based on Sub-Agent A's user journeys and Sub-Agent C's bug list,
generate a test task list:

## E2E Test Tasks

### Core Journeys
- [ ] J1: {journey_name} — {steps}
- [ ] J2: {journey_name} — {steps}
- [ ] ...

### Bug Verification (from Sub-Agent C)
- [ ] B1: Verify {potential_bug} does/doesn't manifest
- [ ] B2: ...

### Responsive Testing
- [ ] R1: Mobile (375×812) — key pages render correctly
- [ ] R2: Tablet (768×1024) — layout adapts
- [ ] R3: Desktop (1440×900) — full layout

### Data Integrity
- [ ] D1: After {action}, verify DB state with query from Sub-Agent B
- [ ] D2: ...

---

### 6.4 Execute User Journey Tests

For each journey task, follow this exact cycle:

#### Step 1: Snapshot & Orient

agent-browser snapshot -i
# Read the accessibility tree. Identify target elements by @eN refs.
# DO NOT guess element refs — always snapshot first.

#### Step 2: Interact

# Click navigation, buttons, links:
agent-browser click @eN

# Fill form fields:
agent-browser fill @eN "value"

# Select dropdowns:
agent-browser select @eN "option_value"

# Press keys (e.g., Enter, Escape, Tab):
agent-browser press Enter

# Wait for page to settle after any interaction:
agent-browser wait --load networkidle

#### Step 3: Capture Evidence

# Screenshot after each significant interaction:
mkdir -p /tmp/e2e-screenshots/{journey_name}
agent-browser screenshot /tmp/e2e-screenshots/{journey_name}/step-{N}.png

# Check for console errors:
agent-browser errors
# If errors found → document in ISSUES.md, attempt fix

# Check console logs for relevant output:
agent-browser console

#### Step 4: Visual Analysis

# Read the screenshot to verify:
Read(/tmp/e2e-screenshots/{journey_name}/step-{N}.png)

# Check:
# - Layout renders correctly (no overlap, no missing elements)
# - Data displays as expected (correct values, correct order)
# - Interactive state is correct (active tab, selected item, open modal)
# - No error messages visible
# - Loading states resolved

#### Step 5: Database Validation (After Data-Modifying Actions)

# After creates, updates, deletes — verify DB state:
# Use query from Sub-Agent B's validation queries

# PostgreSQL (Heartbeat AI):
psql "$DATABASE_URL" -c "SELECT id, status, created_at FROM {table} ORDER BY created_at DESC LIMIT 3;"

# Verify:
# - Record exists with expected values
# - Timestamps are recent
# - Foreign keys resolve correctly
# - RLS policies don't block the query (test with tenant context)

#### Step 6: Fix-in-Place (If Issues Found)

# If a test step reveals a bug:
# 1. Document the issue
echo "## Issue: {description}" >> .uop/sessions/{id}/ISSUES.md
echo "- Journey: {journey_name}, Step: {N}" >> .uop/sessions/{id}/ISSUES.md
echo "- Screenshot: /tmp/e2e-screenshots/{journey_name}/step-{N}.png" >> .uop/sessions/{id}/ISSUES.md

# 2. Fix the code (if within iteration budget — max 4 attempts per OP Mode rules)
# 3. Restart app if needed
# 4. Re-test the same step
# 5. Capture confirmation screenshot: step-{N}-fixed.png

#### Repeat Steps 1-6 for every journey step, then move to next journey.

---

### 6.5 Responsive Testing

After all journeys pass, test key pages at 3 viewports:

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

# Verify each screenshot:
# - No horizontal scroll on mobile
# - Navigation collapses/hamburger on mobile
# - Tables adapt (scroll or stack) on small screens
# - Modals don't overflow viewport
# - Text remains readable (no truncation)

#### Browser Cleanup (After All Journeys + Responsive Tests)

# Close the browser session
agent-browser close

# Stop the application server
kill $APP_PID 2>/dev/null || true

---

### 6.6 Mandatory Test Generation (Preserved from Original)

For every implementation, also generate unit/integration tests:

1. Happy Path Test     — Primary use case works
2. Edge Case Test #1   — Boundary condition
3. Edge Case Test #2   — Error handling / empty state

Task(
  subagent_type="general-purpose",
  prompt="Generate tests for: {implemented_feature}\n\nRequired:\n- 1 happy path\n- 2 edge cases\n\nContext:\n{feature_requirements}"
)

# Run generated tests
npm test -- --testPathPattern="{feature_test_pattern}"

---

### 6.7 Self-Test Checklist (MANDATORY before Phase 7)

## Pre-Return Checklist

### E2E Browser Validation
- [ ] All user journeys executed and screenshotted
- [ ] No unresolved console errors (`agent-browser errors` returns clean)
- [ ] All data-modifying actions verified against DB
- [ ] Responsive testing passed at 3 viewports (mobile/tablet/desktop)
- [ ] All Sub-Agent C bugs either confirmed fixed or documented as acceptable

### Code Quality (Preserved)
- [ ] All generated unit tests pass
- [ ] No TypeScript/lint errors (`npm run build` / `npm run lint`)
- [ ] No console errors in browser

### Documentation (Preserved)
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

**All boxes MUST be checked before proceeding to Phase 7.**
```

---

## Gate 0 Addition: Heartbeat AI Routing Entry

Add this row to the **Step 0.5 Routing Table** in Gate 0:

```markdown
| Heartbeat AI (Full Stack) | - | ALL GSD agents | backend-reviewer.md, security-analyzer.md | frontend-reviewer.md |
```

And add this block to **Step 0.1: Read Skill Files**:

```markdown
║  Heartbeat AI / E2E Testing:                                                ║
║  □ Read: docs/OP-MODE-PHASE6-E2E-UPGRADE.md                               ║
║  □ Read: .claude/skills/e2e-test/SKILL.md (if installed)                   ║
```

---

## Token Efficiency Analysis

### Per-Interaction Comparison

| Tool | Tokens per Snapshot | Tokens for 50-Step Journey | Annual (daily builds) |
|------|--------------------|--------------------------|-----------------------|
| **Playwright MCP** | ~4,127 chars (~1,030 tokens) | ~51,500 tokens | ~18.8M tokens |
| **agent-browser** | ~385 chars (~96 tokens) | ~4,800 tokens | ~1.75M tokens |
| **Savings** | **90.7% fewer** | **90.7% fewer** | **~17M tokens/year** |

### Full Phase 6 Token Budget

| Phase 6 Component | Playwright (Old) | Agent-Browser (New) | Savings |
|-------------------|-----------------|--------------------|---------|
| 3 parallel research sub-agents | N/A (didn't exist) | ~3,000 tokens | +3,000 (new cost) |
| App startup + auth | ~2,000 tokens | ~800 tokens | -1,200 |
| 5 journey tests × 10 steps each | ~51,500 tokens | ~4,800 tokens | -46,700 |
| Responsive testing (3 viewports × 5 pages) | ~15,450 tokens | ~1,440 tokens | -14,010 |
| DB validation queries | ~1,500 tokens | ~1,500 tokens | 0 (same) |
| Screenshot analysis | ~5,000 tokens | ~5,000 tokens | 0 (same) |
| Unit test generation | ~2,000 tokens | ~2,000 tokens | 0 (same) |
| **Phase 6 Total** | **~77,450 tokens** | **~18,540 tokens** | **-58,910 (76% savings)** |

### Context Window Impact

| Metric | Playwright | Agent-Browser |
|--------|-----------|---------------|
| Phase 6 % of 200K context | ~39% | ~9% |
| Remaining for Phases 1-5 + 7 | ~122K tokens | ~181K tokens |
| Risk of context overflow | HIGH (monolithic dashboard) | LOW |

### Cost Estimate (Claude Sonnet, $3/M input + $15/M output)

| Scenario | Playwright | Agent-Browser | Monthly Savings |
|----------|-----------|---------------|-----------------|
| 1 build/day | ~$7.80/mo | ~$1.90/mo | $5.90 |
| 5 builds/day (active sprint) | ~$39/mo | ~$9.50/mo | $29.50 |
| 20 builds/day (CI/CD) | ~$156/mo | ~$38/mo | $118.00 |

---

## Heartbeat AI Specific Adaptations

### 1. Auth Flow
Heartbeat AI uses httpOnly cookies + CSRF tokens. The agent-browser auth pattern:

```
agent-browser open http://localhost:3000
agent-browser snapshot -i
# Find login form elements
agent-browser fill @eN "test@email.com"
agent-browser fill @eM "password"
agent-browser click @eK  # Submit
agent-browser wait --load networkidle
# Cookie is set automatically — subsequent pages are authenticated
```

### 2. Multi-Tenant Context
All DB validation queries must include `WHERE tenant_id = '{test_tenant_id}'` to respect RLS boundaries. The test tenant ID should be sourced from env or the research sub-agent's output.

### 3. Demo Mode vs Live Mode
For the 9,312-line tenant dashboard, use demo/sample data. Never test against production Twilio/ElevenLabs APIs during E2E — mock those endpoints or use test mode credentials.

### 4. Voice/SMS Testing Boundary
agent-browser cannot test actual phone calls or SMS delivery. Voice/SMS E2E stops at verifying:
- Dashboard UI shows call/SMS records
- Webhook endpoint accepts POST payloads (use curl, not browser)
- DB records are created from mock webhook payloads

### 5. Monolithic Dashboard Strategy
The 9,312-line `wireframe-tenant-dashboard.html` has multiple sections behind nav tabs. Test strategy:
- Snapshot each nav tab separately (reduces per-snapshot noise)
- Test modals by clicking their trigger buttons, snapshotting the modal state
- Use `agent-browser get text` to extract specific data values for assertion

---

## Installation Checklist

- [ ] Install agent-browser: `npm install -g agent-browser`
- [ ] Verify Chromium headless is available
- [ ] Replace Phase 6 in `commands/op-mode/SKILL.md`
- [ ] Add Heartbeat AI routing entry to Gate 0
- [ ] Create `/tmp/e2e-screenshots/` directory structure
- [ ] Seed `.uop/` memory with test tenant ID and DB connection string
- [ ] Test with a simple journey first (login → dashboard → verify)

---

*Generated: February 26, 2026 | Heartbeat AI | OP Mode Phase 6 Upgrade*
