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
