# Enhancement 13: Security Hardening Checklist

> **Purpose:** Mandatory security audit gate for Phase 2 (Planning). Prevents the most common SaaS vulnerability: users giving themselves premium access, unlimited rate limits, or admin privileges through application-layer filtering gaps.
>
> **Real Vulnerability Pattern:** BizPilot (and Heartbeat AI) stored `subscription_tier`, `usage_counters`, and `overage_charges` in the `tenants` table with NO RLS policies. Application-level endpoint filtering excluded these fields from PATCH requests, but that's a thin wall — one missing WHERE clause or misplaced permission check and users bypass it entirely. The pattern repeats across Supabase, Firebase, and any app mixing user-modifiable and admin-only data in shared tables.
>
> **How to Apply:** When a task touches **auth, RLS, database schema, billing, API endpoints, rate limiting, or user roles**, this checklist gates Phase 2 (Planning). If any checklist item is UNCLEAR or UNCOVERED, the task cannot move to Phase 3 (Implementation). The gate forces architecture decisions early, not at code-review time.

---

## Where It Goes

**INSERT into Phase 2 (Planning)** as a mandatory gate after Step 2.1 (RLM Query). Name it:

```
Phase 2.2: Security Hardening Checklist Gate
```

Run BEFORE creating the PRD or architecture plan.

---

## The Checklist

### Scope: Which Tasks Trigger This Gate?

Check the task against these criteria. If **ANY** match, run the full checklist:

- [ ] Task touches user authentication, roles, or permissions
- [ ] Task modifies or creates database tables
- [ ] Task adds or modifies RLS policies
- [ ] Task touches billing, subscription, or payment data
- [ ] Task creates or modifies API endpoints (especially PATCH/POST/DELETE)
- [ ] Task implements rate limiting or budget caps
- [ ] Task allows users to modify their own profile/account data
- [ ] Task involves admin-only features or data

**If NONE match:** Skip this gate, continue to Phase 2.3 normally.

**If ANY match:** You MUST work through the full checklist before proceeding.

---

### Part 1: RLS (Row-Level Security) Audit

**Goal:** Ensure sensitive data cannot be modified by unauthorized users.

#### 1.1: Sensitive Data Inventory

For EVERY table involved in this task, answer:

| Table | What sensitive data does it store? | Who should be able to READ it? | Who should be able to WRITE it? | Who should be able to DELETE it? |
|-------|------------------------------------|---------------------------------|---------------------------------------|---------------------------------------|
| {name} | {list: subscription_tier, usage_count, is_admin, ...} | {tenant users / admins only / never} | {admins only / never / users can modify specific fields} | {admins only / never} |

**Example (VULNERABLE pattern):**
| tenants | subscription_tier, usage_counters, overage_charges, ai_access_enabled | Admins only | Application layer filters PATCH | Admins only |

**Example (SECURE pattern):**
| tenants | subscription_tier, usage_counters, overage_charges, ai_access_enabled | Admins only (RLS policy) | Admins only (RLS policy) | Admins only (RLS policy) |
| tenant_profiles | name, email, phone, preferences | Tenant users (RLS: tenant_id match) | Tenant users (RLS: own row only) | Admins only |

#### 1.2: RLS Policy Validation

For EACH sensitive table, verify:

- [ ] **RLS is ENABLED on the table**
  ```sql
  SELECT tablename FROM pg_tables
  WHERE rls = true AND tablename = '{table}';
  ```
  If empty result → RLS is disabled. FAIL. Fix it:
  ```sql
  ALTER TABLE {table} ENABLE ROW LEVEL SECURITY;
  ```

- [ ] **Separate policies exist for SELECT, INSERT, UPDATE, DELETE**
  ```sql
  SELECT polname, qual, with_check FROM pg_policies
  WHERE tablename = '{table}';
  ```
  Do NOT rely on a single "does it all" policy. Each operation should have its own policy.

- [ ] **Users cannot UPDATE sensitive columns**
  Critical check: Can a user modify these without admin role?
  - subscription_tier
  - is_admin
  - rate_limit
  - usage_*
  - overage_charges
  - budget_cap
  - ai_access_enabled

  Example VULNERABLE UPDATE policy:
  ```sql
  CREATE POLICY "users_can_update_own_tenant" ON tenants
    FOR UPDATE USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
  ```
  This allows users to UPDATE ANY column, including subscription_tier.

  Example SECURE approach:
  ```sql
  -- Move sensitive columns to SEPARATE table with admin-only RLS
  ALTER TABLE tenant_billing_config ENABLE ROW LEVEL SECURITY;

  CREATE POLICY "billing_admins_only" ON tenant_billing_config
    FOR ALL USING (
      auth.uid() IN (
        SELECT user_id FROM tenant_admins
        WHERE tenant_id = tenant_billing_config.tenant_id
      )
    );
  ```

- [ ] **Role-based columns are in separate admin-only tables**
  If subscription_tier, is_admin, or rate_limit appears in a user-readable table:
  - FAIL. Move them to a separate table.
  - Apply RLS so only admins (or a service role) can write to it.
  - Example: Create `tenant_billing_tiers` (separate from `tenants`), not a column in `tenants`.

#### 1.3: RLS Testing Template

Before Phase 3, write an RLS test that proves users can't bypass the policy:

```sql
-- Test 1: User can READ their own data
SELECT * FROM tenants WHERE tenant_id = 'user-tenant-id'; -- Should return 1 row

-- Test 2: User CANNOT READ other tenant's data
SELECT * FROM tenants WHERE tenant_id = 'other-tenant-id'; -- Should return 0 rows

-- Test 3: User CANNOT UPDATE subscription_tier
UPDATE tenants SET subscription_tier = 'premium'
WHERE tenant_id = 'user-tenant-id'; -- Should fail: permission denied

-- Test 4: User CANNOT UPDATE ai_access_enabled
UPDATE tenants SET ai_access_enabled = true
WHERE tenant_id = 'user-tenant-id'; -- Should fail: permission denied

-- Test 5: Admin CAN update subscription_tier (via service role or admin policy)
-- (Test with admin user/role)
UPDATE tenants SET subscription_tier = 'premium'
WHERE tenant_id = 'user-tenant-id'; -- Should succeed for admin
```

**Test execution:**
```bash
# As regular user:
psql $DATABASE_URL -c "SET app.current_tenant_id = 'user-id'; SELECT * FROM tenants;"

# As admin/service role:
psql $DATABASE_URL -c "UPDATE tenants SET subscription_tier = 'premium' WHERE tenant_id = 'user-id';"
```

---

### Part 2: Rate Limit Integrity

**Goal:** Prevent users from raising their own rate limits or deleting them entirely.

#### 2.1: Rate Limit Storage Audit

Question: Where is the rate limit stored?

- [ ] Option A: In a table with RLS (GOOD)
  - Column: `rate_limit_per_minute` (or similar)
  - Table has RLS → users can READ their own, ADMINS ONLY UPDATE
  - Proceed to 2.2

- [ ] Option B: In a table without RLS (CRITICAL ISSUE)
  - Example: `tenants.rate_limit_per_minute` with no RLS on tenants table
  - BLOCKED. Cannot proceed to Phase 3 without fixing.
  - Action: Enable RLS on the table, create admin-only UPDATE policy

- [ ] Option C: In a configuration file or cache (RISK)
  - Example: Rate limit stored in Redis cache with user-modifiable key
  - RISKY. Proceed only if cache is admin-populated and refreshed server-side
  - Action: Document the refresh mechanism; verify cache cannot be written by user endpoints

- [ ] Option D: Rate limit doesn't exist (CRITICAL ISSUE)
  - Users could call AI endpoints unlimited times
  - BLOCKED. Must implement rate limiting before proceeding.
  - Minimum: Per-tenant limit at application layer + per-IP limit at infrastructure layer

#### 2.2: Per-Account Rate Limiting

Verify rate limits are enforced at the APPLICATION layer:

- [ ] **Every AI endpoint checks user's rate limit BEFORE calling the AI provider**
  ```javascript
  // GOOD: Check rate limit FIRST
  async function callElevenLabs(tenantId, phoneNumber) {
    const limit = await getTenanRateLimitCalls(tenantId);
    const used = await getTenanUsedCalls(tenantId);

    if (used >= limit) {
      throw new Error('Rate limit exceeded');
    }

    // Only THEN call ElevenLabs
    const response = await elevenLabsClient.call(phoneNumber);
    await incrementTenanUsedCalls(tenantId);
    return response;
  }
  ```

  ```javascript
  // BAD: Check rate limit AFTER
  async function callElevenLabs(tenantId, phoneNumber) {
    const response = await elevenLabsClient.call(phoneNumber); // CHARGE FIRST
    const used = await getTenanUsedCalls(tenantId);
    if (used >= limit) {
      throw new Error('Rate limit exceeded'); // TOO LATE — already charged
    }
    return response;
  }
  ```

- [ ] **Rate limit check is ATOMIC with the API call**
  - Use a transaction or atomic operation so two simultaneous requests can't both slip through
  - Example: Increment counter → check against limit (not the other way around)

#### 2.3: Per-IP Rate Limiting (DDoS Protection)

- [ ] **Infrastructure layer has IP-based rate limiting**
  - Cloudflare, AWS WAF, or similar: limit requests per IP per minute
  - Prevents one attacker from hammering your API
  - Recommended: 100 requests per IP per minute (adjust based on your app)

- [ ] **If no infrastructure rate limiting:** At least database rate limiting exists
  - Document: "No IP-based rate limiting. Relying on per-account limits only."
  - Risk: One compromised account could DoS your AI provider
  - Remediation: Add Cloudflare or AWS WAF before going to production

#### 2.4: Rate Limit Kill Switch

- [ ] **Per-tenant AI access toggle (admin-only column)**
  ```sql
  ALTER TABLE tenants ADD COLUMN ai_access_enabled BOOLEAN DEFAULT true;

  CREATE POLICY "billing_team_controls_ai_access" ON tenants
    FOR UPDATE USING (
      current_setting('app.role') = 'admin'
      OR current_setting('app.role') = 'billing'
    );
  ```

- [ ] **Every AI endpoint checks the toggle BEFORE processing**
  ```javascript
  if (!tenant.ai_access_enabled) {
    throw new Error('AI access disabled for this account');
  }
  ```

- [ ] **Kill switch is triggered automatically when spending exceeds budget cap**
  - (See Part 3 below)

---

### Part 3: Budget Cap Safety Net

**Goal:** Prevent runaway AI costs from bankrupting a tenant.

#### 3.1: Hard Budget Cap at AI Provider Level

- [ ] **Does your OpenAI / Anthropic / ElevenLabs account have a spending cap?**
  - OpenAI: https://platform.openai.com/account/billing/limits
  - Anthropic: Account settings → spending limits
  - ElevenLabs: Account settings → usage limits
  - Log into each provider's console and verify. Screenshot the setting.
  - If you set a cap of $500/month and a tenant goes rogue, you're protected at the account level.

#### 3.2: Per-Tenant Spending Cap with Auto-Shutoff

- [ ] **Do you track spending per tenant?**
  - Create table: `tenant_spending_tracker` with columns:
    - `tenant_id` (FK)
    - `month` (YYYY-MM)
    - `estimated_cost` (sum of API calls × pricing)
    - `budget_cap` (user-set or admin-set limit)

- [ ] **Does your system auto-shutoff when spending approaches the cap?**
  ```javascript
  async function checkBudgetBefore(tenantId) {
    const spending = await getTenanMonthlySpending(tenantId);
    const cap = await getTenanBudgetCap(tenantId);
    const threshold = cap * 0.80; // Alert at 80%

    if (spending >= threshold) {
      // Trigger kill switch
      await updateTenant(tenantId, { ai_access_enabled: false });

      // Notify admins
      await sendAlert({
        to: tenant.billing_email,
        subject: 'AI Access Disabled: Budget Cap Exceeded',
        body: `Your account has reached 80% of its $${cap} budget cap.
               AI features have been disabled to prevent overages.
               Contact support to increase your cap.`
      });

      return false; // Reject the API call
    }

    return true; // Proceed
  }
  ```

- [ ] **Does the spending tracker receive updates from all AI providers?**
  - Example: Every ElevenLabs webhook increments `tenant_spending_tracker.estimated_cost`
  - Example: Every OpenAI token-counting query logs to `tenant_spending_tracker`
  - Verify this is PUSH (provider → your system), not PULL (your system → provider)
  - If you only check the provider's API once per day, you could overshoot by 24 hours of calls

#### 3.3: Budget Cap Alerts

- [ ] **Alerts fire at 50%, 75%, 90%, and 100% of cap**
  - 50%: Informational email ("You've used half your budget")
  - 75%: Warning email ("Budget cap approaching")
  - 90%: Urgent warning ("AI access will be disabled at 100%")
  - 100%: Kill switch + blocking email

- [ ] **Alert recipients are configurable by tenant**
  - Who gets notified: billing_email, admin_emails, optional cc_emails
  - Verified in tenant config table

#### 3.4: Maximum Damage Assessment

Complete this sentence:
> "If a user somehow bypassed ALL rate limits, killed the budget cap toggle, and maxed out my AI provider, the worst-case damage in 1 hour would be: **$XXX**"

If that number is > $500, you need additional controls:
- Reduce per-call limits
- Add human-approval workflows for large requests
- Use AI provider's rate limiting (in addition to your own)

---

### Part 4: Frontend Security

**Goal:** Prevent API keys, secrets, and authentication tokens from leaking to the client.

#### 4.1: API Keys in Frontend Code

- [ ] **Grep your frontend code for API keys**
  ```bash
  grep -r "sk_" src/          # OpenAI secret keys
  grep -r "ELEVENLABS_KEY" src/
  grep -r "secret" src/       # Generic secrets
  grep -r "password" src/     # Passwords
  grep -r "api_key" src/      # All API keys
  ```
  If ANY results → FAIL. Remove keys from frontend immediately.

- [ ] **Grep your git history for deleted keys**
  ```bash
  git log -p -S "sk_" -- '*' | head -100
  ```
  If keys were ever committed (even deleted): Rotate them on all providers.

#### 4.2: AI Calls Routed Through Backend

- [ ] **Frontend NEVER calls OpenAI / Anthropic / ElevenLabs directly**
  - Frontend should NOT have `OPENAI_API_KEY` or similar in environment variables
  - Frontend calls your backend endpoint: `POST /api/v1/ai/chat`
  - Backend verifies user has permission, deducts from rate limit, THEN calls OpenAI
  - Pseudo-code:
    ```javascript
    // GOOD: Backend acts as a proxy
    async function POST_api_ai_chat(req, res) {
      const { tenantId, message } = req.body;

      // Rate limit check (application layer)
      const ok = await checkBudgetBefore(tenantId);
      if (!ok) return res.status(429).json({ error: 'Budget exceeded' });

      // Call OpenAI with BACKEND's API key
      const response = await openai.createChatCompletion({
        model: 'gpt-4',
        messages: [{ role: 'user', content: message }]
      });

      // Track spending
      await logSpending(tenantId, response.usage.total_tokens);

      return res.json({ text: response.choices[0].text });
    }
    ```

#### 4.3: Environment Variables Secured

- [ ] **All secrets are in `.env` (local), not in version control**
  - `.env` is in `.gitignore`
  - Verify: `git ls-files | grep ".env"` returns nothing

- [ ] **Frontend env vars do NOT leak secrets**
  - Only expose vars that START with `PUBLIC_`
  - Example (good): `PUBLIC_API_URL=https://api.example.com`
  - Example (bad): `OPENAI_KEY=sk_live_...` (even if in .env, don't expose it)

- [ ] **Production env vars are set via CI/CD or hosting provider, not in code**
  - Railway: Set via UI, not in Dockerfile
  - Vercel: Set via `.env.local` in `.gitignore`, or via Vercel UI
  - Never hardcode production secrets

#### 4.4: CSRF Protection

- [ ] **All state-changing endpoints (POST, PATCH, DELETE) require CSRF tokens**
  ```javascript
  // GOOD: CSRF token validation
  async function POST_api_tenants_update(req, res) {
    const token = req.headers['x-csrf-token'];
    if (!verifyCSRFToken(token)) {
      return res.status(403).json({ error: 'CSRF token invalid' });
    }
    // Process request
  }
  ```

- [ ] **CSRF token is NOT visible in HTML or JavaScript**
  - Should be: HTTP-only cookie + verified via header
  - NOT: Hidden form input (vulnerable to XSS)
  - NOT: localStorage (vulnerable to XSS)

---

### Part 5: Admin Privilege Escalation

**Goal:** Prevent users from promoting themselves to admin or modifying their role.

#### 5.1: Role Column Security

- [ ] **User roles are stored in a SEPARATE table with RLS**
  - NOT in `users` table (if users can UPDATE their own profile)
  - Example: `user_roles(user_id, tenant_id, role)` with RLS
  ```sql
  CREATE TABLE user_roles (
    user_id UUID NOT NULL,
    tenant_id UUID NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('admin', 'user', 'viewer')),
    PRIMARY KEY (user_id, tenant_id)
  );

  ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

  -- Users can READ their own role
  CREATE POLICY "users_read_own_role" ON user_roles
    FOR SELECT USING (
      auth.uid() = user_id
      AND tenant_id = current_setting('app.current_tenant_id')::uuid
    );

  -- Users CANNOT UPDATE their own role
  CREATE POLICY "admins_only_write_roles" ON user_roles
    FOR UPDATE USING (
      auth.uid() IN (
        SELECT user_id FROM user_roles
        WHERE role = 'admin' AND tenant_id = tenant_id
      )
    );
  ```

- [ ] **is_admin flag is NOT in `users` table**
  - Move to `user_roles` or similar admin-only table
  - If `users.is_admin` exists and users can PATCH their profile → FAIL

#### 5.2: Dual-Layer Role Checking

- [ ] **Role is checked at BOTH database AND application layer**
  - Database layer: RLS prevents unauthorized queries
  - Application layer: Endpoint middleware validates role before executing
  ```javascript
  async function requireRole(requiredRole) {
    return async (req, res, next) => {
      const { userId, tenantId } = req.session;

      // Check in database
      const userRole = await getUserRole(userId, tenantId);
      if (!hasPermission(userRole, requiredRole)) {
        return res.status(403).json({ error: 'Forbidden' });
      }

      // Store in request context
      req.role = userRole;
      next();
    };
  }

  // Use in routes
  app.patch('/api/billing', requireRole('admin'), async (req, res) => {
    // Only reachable if role check passed
    // Double protection: RLS will also block if somehow role was spoofed
  });
  ```

#### 5.3: Admin Endpoint Protection

- [ ] **All admin endpoints are protected by role middleware**
  - PATCH /api/tenants/{id}/subscription_tier → requires 'admin'
  - DELETE /api/users/{id} → requires 'admin'
  - PATCH /api/users/{id}/role → requires 'admin'
  - No exceptions, no "but the RLS will catch it"

- [ ] **Audit log tracks all admin actions**
  ```javascript
  async function logAdminAction(userId, action, resource, change) {
    await db.table('admin_audit_log').insert({
      timestamp: new Date(),
      admin_user_id: userId,
      action,      // 'UPDATE', 'DELETE', 'CREATE'
      resource,    // 'subscription_tier', 'user_role', 'budget_cap'
      change,      // { before: 'user', after: 'admin' }
    });
  }
  ```

---

### Part 6: Kill Switch Implementation

**Goal:** Provide a single "off switch" for AI access when something goes wrong.

#### 6.1: Kill Switch Column

- [ ] **Table: `tenants` has column `ai_access_enabled` (BOOLEAN, default true)**
  ```sql
  ALTER TABLE tenants ADD COLUMN ai_access_enabled BOOLEAN DEFAULT true;
  ```

- [ ] **Column is admin-only writable**
  ```sql
  ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;

  CREATE POLICY "billing_toggle_ai_access" ON tenants
    FOR UPDATE USING (
      auth.uid() IN (
        SELECT user_id FROM user_roles
        WHERE role IN ('admin', 'billing')
        AND tenant_id = tenants.tenant_id
      )
    ) WITH CHECK (
      auth.uid() IN (
        SELECT user_id FROM user_roles
        WHERE role IN ('admin', 'billing')
        AND tenant_id = tenants.tenant_id
      )
    );
  ```

#### 6.2: Kill Switch Check

- [ ] **EVERY AI endpoint checks the toggle FIRST**
  ```javascript
  async function callAI(tenantId, request) {
    // Check 1: Kill switch
    const tenant = await getTenant(tenantId);
    if (!tenant.ai_access_enabled) {
      throw new Error('AI access is disabled for this account');
    }

    // Check 2: Rate limit
    const ok = await checkBudgetBefore(tenantId);
    if (!ok) throw new Error('Budget exceeded');

    // Only then: Call AI
    return await openai.createChatCompletion(request);
  }
  ```

#### 6.3: Auto-Triggering on Budget Exceed

- [ ] **When spending exceeds 100% of budget cap, kill switch auto-triggers**
  ```javascript
  async function processSpendingUpdate(tenantId, costInDollars) {
    const current = await getMonthlySpending(tenantId);
    const cap = await getBudgetCap(tenantId);

    if (current + costInDollars >= cap) {
      // Auto-disable AI
      await updateTenant(tenantId, { ai_access_enabled: false });

      // Notify admins
      await sendAlert({
        to: tenant.billing_email,
        subject: 'URGENT: Budget cap exceeded, AI access disabled',
        body: 'Your account has exceeded its monthly budget. AI features are disabled.'
      });
    }
  }
  ```

#### 6.4: Manual Kill Switch in Admin Dashboard

- [ ] **Admin UI has a toggle to disable/enable AI per tenant**
  - Location: `GET /admin/tenants/{id}` dashboard
  - Button: "Disable AI" (red) / "Enable AI" (green)
  - On click: `PATCH /api/admin/tenants/{id}` with `{ ai_access_enabled: false }`
  - Requires admin role + CSRF token

- [ ] **Toggling the kill switch logs an audit event**
  ```javascript
  async function toggleAIAccess(tenantId, enabled, adminUserId) {
    await updateTenant(tenantId, { ai_access_enabled: enabled });

    await logAdminAction(adminUserId, 'AI_ACCESS_TOGGLE', tenantId, {
      enabled,
      reason: 'admin_requested' // or 'budget_exceeded', 'security_incident'
    });
  }
  ```

---

## Failure Mode Journal Entry Template

When you find a security vulnerability (during this audit or later), log it with:

```markdown
### F-XXX: {Short description of vulnerability}

**Date:** {date}
**Category:** RLS | RATE_LIMIT | BUDGET_CAP | FRONTEND_SECRET | PRIVILEGE_ESCALATION | CSRF | KILL_SWITCH
**Severity:** CRITICAL | HIGH | MEDIUM | LOW
**Files affected:** {list of vulnerable files/tables}

**Vulnerability:**
{What's wrong. Explain like a security researcher.}
Example: "Users can UPDATE tenants.subscription_tier directly via PATCH /api/tenants/me because the endpoint filters out sensitive fields in code, but no RLS policy prevents the UPDATE at the database level. If application-layer filtering is ever removed or buggy, users gain access."

**Impact:**
{What an attacker could do}
Example: "A user could promote themselves from 'free' to 'premium' tier, gaining unlimited API calls and raising overage charges."

**Fix:**
{How to fix it}
Example: "Move subscription_tier to a separate table (tenant_billing) with RLS 'admins_only'. Application can still read it, but cannot modify it via endpoint."

**Prevention rule:**
{How to avoid this class of vulnerability in the future}
Example: "Any column that affects billing, features, or permissions MUST be:
1. In a separate table from user-modifiable data
2. Protected by RLS with explicit admin-only UPDATE policy
3. Never rely on application-layer field filtering
4. Test with regular user account to verify it CANNOT be modified"

**Test to prevent regression:**
{SQL or code test that catches this in the future}
Example: "Regular user attempts: UPDATE tenants SET subscription_tier='premium' WHERE tenant_id=...
Expected: PERMISSION DENIED (RLS blocks it)
Regression if: Query succeeds"
```

---

## Project.json Addition

Update `.uop/project.json` to include:

```json
{
  "security_requirements": [
    "rls_enabled_on_sensitive_tables",
    "no_user_updateable_billing_columns",
    "per_account_rate_limiting",
    "per_ip_rate_limiting",
    "budget_cap_with_auto_shutoff",
    "kill_switch_ai_access",
    "no_api_keys_in_frontend",
    "ai_calls_via_backend_only",
    "csrf_protection",
    "admin_role_separate_table",
    "dual_layer_role_checking",
    "audit_logging_admin_actions"
  ],
  "sensitive_tables": [
    "tenants",
    "user_roles",
    "tenant_billing",
    "tenant_spending_tracker",
    "admin_audit_log"
  ],
  "billing_sensitive_columns": [
    "subscription_tier",
    "rate_limit_per_minute",
    "budget_cap",
    "overage_charges",
    "usage_count",
    "ai_access_enabled"
  ]
}
```

---

## Quick SQL Template: Locking Down a Sensitive Table

Copy-paste this and fill in the blanks for any table storing billing or permission data:

```sql
-- ============================================================================
-- Securing {TABLE_NAME} with RLS
-- ============================================================================

-- Step 1: Enable RLS
ALTER TABLE {table} ENABLE ROW LEVEL SECURITY;

-- Step 2: Allow tenants to READ their own rows (but not sensitive columns)
CREATE POLICY "{table}_tenant_read" ON {table}
  FOR SELECT
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- Step 3: BLOCK all tenant UPDATES (only backend/admin can update)
CREATE POLICY "{table}_tenant_no_update" ON {table}
  FOR UPDATE
  USING (false); -- Reject all user update attempts

-- Step 4: Allow admin-only UPDATES
CREATE POLICY "{table}_admin_update" ON {table}
  FOR UPDATE
  USING (
    -- Only if current user is an admin for this tenant
    auth.uid() IN (
      SELECT user_id FROM user_roles
      WHERE role = 'admin' AND tenant_id = {table}.tenant_id
    )
  )
  WITH CHECK (
    auth.uid() IN (
      SELECT user_id FROM user_roles
      WHERE role = 'admin' AND tenant_id = {table}.tenant_id
    )
  );

-- Step 5: BLOCK all deletes
CREATE POLICY "{table}_no_delete" ON {table}
  FOR DELETE
  USING (false);

-- Step 6: Verify policies are in place
SELECT polname, qual FROM pg_policies WHERE tablename = '{table}';

-- Step 7: Test as regular user (should fail)
SET app.current_tenant_id = '550e8400-e29b-41d4-a716-446655440000';
UPDATE {table} SET {sensitive_column} = {new_value}
WHERE tenant_id = '550e8400-e29b-41d4-a716-446655440000';
-- Expected: ERROR: new row violates row-level security policy

-- Step 8: Test as admin (should succeed) — use service role or admin account
-- [in admin context]
UPDATE {table} SET {sensitive_column} = {new_value}
WHERE tenant_id = '550e8400-e29b-41d4-a716-446655440000';
-- Expected: UPDATE 1
```

---

## Checklist Summary

Before moving from Phase 2 to Phase 3, verify you can check ALL boxes:

### RLS (Part 1)
- [ ] Sensitive data inventory completed
- [ ] RLS enabled on all sensitive tables
- [ ] Separate policies for SELECT, INSERT, UPDATE, DELETE
- [ ] Users cannot UPDATE billing/permission columns
- [ ] Billing/permission data in separate admin-only tables
- [ ] RLS tests written and passing

### Rate Limiting (Part 2)
- [ ] Rate limits stored with RLS protection
- [ ] Per-account rate limiting implemented
- [ ] Rate limit checked BEFORE AI call
- [ ] Per-IP rate limiting at infrastructure layer
- [ ] Kill switch (ai_access_enabled) implemented
- [ ] Kill switch checked at start of every AI endpoint

### Budget Cap (Part 3)
- [ ] Hard cap set at AI provider level
- [ ] Per-tenant spending tracking implemented
- [ ] Auto-shutoff when cap exceeded
- [ ] Alerts at 50%, 75%, 90%, 100%
- [ ] Maximum 1-hour damage assessed and acceptable

### Frontend Security (Part 4)
- [ ] No API keys in frontend code
- [ ] No keys in git history
- [ ] AI calls routed through backend only
- [ ] Frontend env vars secured (no secrets)
- [ ] CSRF protection on all state-changing endpoints

### Admin Security (Part 5)
- [ ] Roles stored in separate table with RLS
- [ ] is_admin not in user-updateable table
- [ ] Role checked at database AND application layer
- [ ] All admin endpoints protected by middleware
- [ ] Audit log for admin actions

### Kill Switch (Part 6)
- [ ] Kill switch column exists with admin-only write
- [ ] Kill switch checked on every AI endpoint
- [ ] Kill switch auto-triggers on budget exceed
- [ ] Manual toggle in admin UI
- [ ] Kill switch actions logged to audit log

---

## How This Checklist Gates Phase 2

**If ALL checkboxes are checked:** ✅ APPROVED to proceed to Phase 3

**If ANY checklist item is unclear or shows a gap:**
1. Document the gap in `.uop/sessions/{id}/ISSUES.md`
2. Create a sub-task for Phase 3 to fix it
3. Note the severity: is it a BLOCKER (can't deploy) or a TODO (nice to have)?
4. Proceed to Phase 3 only if all BLOCKERS are resolved

**Example BLOCKER (cannot proceed):**
- No RLS on tenants table and users can UPDATE subscription_tier
- Fix: Enable RLS + add admin-only policy (1-2 hours)

**Example TODO (can proceed, fix later):**
- Audit logging not yet implemented
- Fix: Add admin_audit_log table + logging on admin endpoints
- Schedule: Next sprint or next deployment window

---

## Real-World Example: BizPilot Vulnerability

**Before this checklist:**
- `tenants` table stores `subscription_tier`, `usage_counters`, `overage_charges`
- `tenants` table has NO RLS
- PATCH /api/tenants/me endpoint filters out these fields in code
- Assumption: "Users can't modify billing data because we filter it"
- Reality: One missing WHERE clause → users bypass filter → chaos

**After this checklist:**
- `tenants` table has RLS enabled
- Separate table `tenant_billing_config` with admin-only UPDATE policy
- PATCH endpoint can't touch billing columns because RLS blocks it (database level)
- Application-layer filtering is now a second line of defense, not the only line
- Same outcome, but secure by architecture not assumption

---

## Maintenance

Every 6 months, review this checklist:
- [ ] Add new vulnerability patterns to the Failure Mode Journal
- [ ] Update SQL templates if your schema patterns change
- [ ] Add project-specific security rules to `.uop/project.json`
- [ ] Share the updated checklist with your team

---

*Generated: March 3, 2026 | OP Mode Enhancement 13: Security Hardening Checklist | BizPilot*
