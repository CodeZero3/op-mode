# Autonomous Ops Framework Patterns

> Reference file for OP Mode v4.0. Loaded on-demand, not part of core SKILL.md.
> See main SKILL.md for when to reference this file.

---

## Purpose

These patterns are **product-agnostic**. They apply to ANY product registered in `memory/fleet.json` -- BizPilot, BrightBadge, or future products. When building autonomous agents, always reference the fleet registry, never hardcode product names.

This file covers: the fleet registry model, Loop Mode execution, the auto-research optimization loop, agent fleet governance, CLI tool harnesses, GTM engineering pipelines, and how to onboard a new product into the autonomous framework.

---

## Fleet Registry

All autonomous agents read `memory/fleet.json` to discover products. New products are added there, and agents automatically pick them up.

```
memory/fleet.json -> defines products, health URLs, Sentry projects, skill dirs
```

The fleet registry is the **single source of truth** for product discovery. No agent should hardcode product names, health URLs, or Sentry project slugs.

---

## Loop Mode (from Task Sizing)

Loop Mode is a specialized execution mode for parallelizable, independently measurable tasks.

### When to Use Loop Mode

- Task is parallelizable (each unit is independent)
- Success is measurable by a single metric
- No cross-unit dependencies
- Examples: batch vertical pages, SEO meta rewrites, test generation, content drafts, ad creative variants

### Loop Mode Workflow

1. **Define:** metric, iterations, revert threshold
2. **Each iteration:** fresh agent, fleet.json context only
3. **Log results** to resource.md (compound learning)
4. **Post-loop:** UNIFY all outputs for consistency

### Platform Notes

- Claude Desktop `/schedule` can run Loop Mode indefinitely
- CLI `/loop` maxes out at ~3 days
- Use Desktop for perpetual loops (SEO monitoring, content optimization)

---

## Pattern 1: Auto-Research Loop (Challenger/Baseline)

A self-improving pipeline that optimizes any measurable metric without human intervention.

```
Prerequisites:
1. An OBJECTIVE METRIC (CTR, bounce rate, reply rate, etc.)
2. An API-ACCESSIBLE FACTOR to modify (copy, subject, layout)
3. A RESOURCE FILE for accumulated learnings (resource.md)

Loop:
1. Read BASELINE (current best version)
2. Read RESOURCE.md (what we've learned so far)
3. Generate CHALLENGER (AI-created variant)
4. Run both -> measure metric
5. Winner becomes new BASELINE
6. Log learnings -> RESOURCE.md
7. Repeat at defined cadence

Hosting: Inngest cron (default) -> GitHub Actions (24/7)
```

**Applies to:** Landing page copy, email subjects, ad creative, pricing page layout, onboarding flows -- ANY product.

### Resource.md: Compound Learning

The resource.md file is the accumulation of all learnings from loop iterations. Each iteration reads prior learnings before generating the next challenger, so the system gets smarter over time. Structure:

```markdown
# {Feature} Optimization Log

## Iteration 1 -- {date}
- Baseline: {description}
- Challenger: {what changed}
- Result: {metric before} -> {metric after}
- Learning: {what we concluded}

## Iteration 2 -- {date}
...
```

---

## Pattern 2: Agent Fleet with Governance

Autonomous agents that operate on a heartbeat schedule with human approval gates.

### Architecture

```
fleet.json   -> defines products
Inngest      -> orchestration + scheduling
ops-sms      -> alerting to Romeo
admin_audit_log -> cost + action tracking
kill switch     -> per-agent enable/disable
budget cap      -> per-agent spend limit
```

### Agent Types (product-agnostic)

| Agent | Cadence | What it does |
|-------|---------|--------------|
| SEO Monitor | Weekly | GSC data -> rank report |
| Content Drafter | Every 8h | NotebookLM -> draft queue |
| Lead Scraper | Weekly | Apify -> lead list |
| Competitor Watch | Monthly | Scrape -> price/feature delta |
| Uptime Guardian | Every 5min | Health check -> auto-alert |
| Review Responder | On event | New review -> draft reply |
| Error Triage | Daily | Sentry -> digest SMS |

### Governance Rules

1. No agent spends > $5 without human approval
2. All public-facing outputs -> review queue first
3. Kill switch per agent (extend `ai_access_enabled` pattern)
4. Cost logged to `admin_audit_log` per agent per run
5. Agents read `fleet.json` -- never hardcode product names

---

## Pattern 3: CLI-Anything Harness (Tool Extension)

Wrap any CLI tool into a Claude Code-controllable agent. Prefer direct CLI over MCP middlemen for speed.

### When to Build a Harness

- You use a CLI tool more than 3x in a session
- The tool has complex flags you keep looking up
- You want an agent to use it autonomously

### How

1. Point CLI-Anything at the tool's `--help` output
2. Generate the agent harness (markdown wrapper)
3. Place in `.claude/tools/{tool}-harness.md`
4. Claude Code can now use natural language to control it

### Existing Harnesses

- `notebooklm` CLI -> knowledge queries, source ingestion
- `railway` CLI -> deploy, logs, env vars

### Priority Candidates

- Keywords Everywhere API (SEO research)
- Google Search Console (rankings)
- Apify (scraping)
- sentry-cli (error triage)

---

## Pattern 4: GTM Engineering Pipeline (Programmatic Growth)

Automated go-to-market workflows that work for any product targeting SMBs.

### Stage 1: Keyword Foundation

- Keywords Everywhere API -> competitor "vs" keywords
- Generate comparison pages: "{product} vs {competitor}"
- AI search optimization (FAQ schema, direct-answer blocks)

### Stage 2: Vertical Landing Pages

- One page per target vertical (read from product config)
- Industry-specific copy from vertical blueprints
- Schema markup (FAQ, Product, Organization)

### Stage 3: Lead Scraping + Enrichment

- Apify Google Maps -> local businesses in target verticals
- Filter: no website OR outdated site = high-intent lead
- Enrich with owner name/email

### Stage 4: Foot-in-the-Door Audit

- Auto-scan prospect's website for issues
- Generate PDF: "Your Business Digital Health Score: 42/100"
- Send as free value -> conversion to paid

### Stage 5: Auto-Research Optimization

- Apply Pattern 1 to landing pages, emails, outreach copy
- Metric-driven, self-improving

All stages are product-agnostic -- swap product name + vertical config and the pipeline works for any SMB SaaS.

---

## GSD Integration Points

OP Mode leverages GSD for autonomous ops:

- **Deviation Rules**: Auto-fix bugs, auto-add critical functionality, ask about architectural changes
- **Checkpoint Protocol**: Verify state before phase transitions
- **Atomic Commits**: One logical change per commit

---

## Onboarding a New Product

When Romeo launches a new product:

1. **Add to `memory/fleet.json`** -- name, healthUrl, sentryProject, skillsDir
2. **Create vertical blueprints** (if applicable) -- `{product}/src/config/vertical-blueprints.js`
3. **Create NotebookLM notebook** -- `notebooklm create "{Product Name}"`, add sources
4. **Add mission** -- append to `memory/ACTIVE-MISSIONS.md`
5. **Agent fleet auto-discovers** -- agents read fleet.json, new product gets monitoring/SEO/alerts

No code changes needed in the agents themselves. The fleet registry is the single source of truth.
