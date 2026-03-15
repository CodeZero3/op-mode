# OP Mode Authority Matrix

## Decision Authority Reference

This document defines who has authority to make decisions during OP Mode execution.

---

## Subagent Team Authority (Auto-Decide)

These decisions are made autonomously by the subagent team without user intervention:

### Technical Implementation
- Choice of algorithm or data structure
- Variable naming conventions
- Code organization within files
- Import ordering and structure
- TypeScript type definitions
- Error handling patterns (within established conventions)

### Bug Fixes During Implementation
- Fixing syntax errors introduced during work
- Correcting logical errors found during testing
- Resolving type mismatches
- Fixing broken imports or references
- Addressing test failures caused by implementation

### Performance Optimization
- Query optimization (within existing schema)
- Component memoization decisions
- Bundle size optimizations
- Caching strategy implementation
- Lazy loading decisions

### Code Quality
- Refactoring for readability
- DRY principle application
- Adding missing error handling
- Improving type safety
- Adding inline documentation

### Dependency Decisions
- Choosing between similar utility libraries
- Updating dependency versions (minor/patch)
- Adding development dependencies
- Removing unused dependencies

---

## User Authority (Pause Required)

These decisions require pausing implementation and queuing for user approval:

### Design/UX Changes
- Layout modifications not in original plan
- Color or styling changes
- Component placement adjustments
- Navigation flow changes
- User interaction pattern changes
- Accessibility approach changes

### Scope Changes
- Adding features not in original PRD
- Removing planned features
- Changing feature behavior significantly
- Expanding to additional user types
- Adding new data models

### Architecture Deviations
- Changing database schema structure
- Modifying API endpoint design
- Switching state management approach
- Changing authentication flow
- Modifying data flow patterns

### Decision Tree Conflicts
- When new information contradicts approved decision
- When implementation reveals decision was wrong
- When external constraint requires approach change
- When security concern requires architecture change

### External Integration Changes
- Adding new third-party services
- Changing payment flow structure
- Modifying email/notification patterns
- Adding new MCP integrations

---

## Escalation Triggers

Immediately pause and present to user when:

1. **Security Vulnerability Found**
   - Critical security issue in existing code
   - Implementation would introduce vulnerability
   - User data at risk

2. **Breaking Change Required**
   - Would break existing user workflows
   - Would invalidate existing data
   - Would require user migration

3. **Cost Implication**
   - Would significantly increase API costs
   - Would require infrastructure upgrade
   - Would affect billing structure

4. **Legal/Compliance Concern**
   - HIPAA consideration
   - GDPR implication
   - Terms of service conflict

---

## Decision Logging Requirements

### Auto-Decisions Must Log:
```markdown
| Timestamp | Decision | Category | Rationale |
|-----------|----------|----------|-----------|
| {time} | {what} | Technical | {why} |
```

### Paused Decisions Must Queue:
```markdown
## Queued for User Approval

### {Decision Title}
- **Category**: {Design|Scope|Architecture|Conflict}
- **Current Plan**: {what_was_planned}
- **Proposed Change**: {what_we_want_to_do}
- **Reason**: {why_change_needed}
- **Impact**: {what_this_affects}
- **Recommendation**: {our_suggestion}
```

---

## Quick Reference

| Category | Authority | Action |
|----------|-----------|--------|
| Code style | Subagent | Auto |
| Bug fix | Subagent | Auto |
| Performance | Subagent | Auto |
| Refactor | Subagent | Auto |
| UI layout | User | Pause |
| New feature | User | Pause |
| Schema change | User | Pause |
| Security issue | User | Pause |
| Cost change | User | Pause |

---

## Gray Zone — Resolved Rulings

Scenarios that fall between auto-decide and ask-Romeo, with explicit rulings:

| Scenario | Authority | Rationale |
|----------|-----------|-----------|
| Adding npm package (utility, <5KB) | Auto | Small utils are trivial, easily reversible |
| Adding npm package (>5KB or native deps) | Ask | Affects bundle size, security surface, build |
| Retry/backoff logic changes | Auto | Implementation detail, not behavior change |
| Caching strategy (in-memory) | Auto | No infra change, reversible |
| Caching strategy (Redis/external) | Ask | New infrastructure dependency |
| Telemetry/analytics toggles | Ask | Affects data collection, privacy implications |
| Environment variable additions (non-secret) | Auto | Operational config |
| Environment variable additions (secret/credential) | Ask | Secrets need secure handling + Railway setup |
| Log level changes | Auto | Operational, not behavioral |
| Error message text (internal/dev-facing) | Auto | No user impact |
| Error message text (user-visible) | Ask | UX impact |
| SDK version major bump | Ask | Breaking changes possible |
| SDK version minor/patch bump | Auto | Non-breaking by semver convention |
| Adding a new Inngest function (cron) | Ask | Affects background job scheduling |
| Adding a new Inngest function (event-triggered) | Auto if pattern exists | Follow established patterns |
| Modifying RLS policies | Ask | Security-critical, always review |
| Adding indexes | Auto | Performance improvement, non-destructive |
| Dropping indexes | Ask | Could affect query performance |

---

## When Romeo Is Unavailable

If a decision requires Romeo and he hasn't responded within the session:

1. **Document the decision** needed in PLAN.md under `## Queued for Approval`
2. **Continue with the SAFER option** (less scope, no new deps, no schema changes)
3. **Flag at session close**: "N decision(s) pending Romeo approval" in FINAL_REPORT
4. **Never** choose the riskier path just to avoid blocking — the safer path protects Romeo's codebase

```markdown
## Queued for Approval

### {Decision Title}
- **Category**: {category from table above}
- **Options**: A) {safer option — CHOSEN} | B) {preferred but needs approval}
- **Chose A because**: Romeo unavailable, A is reversible
- **Status**: PENDING — revisit next session
```
