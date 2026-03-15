# URL Router -- YouTube ANALYZE-FIRST Flow

> Reference file for OP Mode v4.0. Loaded on-demand, not part of core SKILL.md.
> See main SKILL.md for when to reference this file.

---

## Purpose

This is the URL routing logic that runs in Step 0.0a, **before Task Sizing**. It detects when a user pastes a bare URL (no accompanying task description) and routes it through the appropriate ingestion flow. Currently, YouTube URLs are the primary route; future routes (GitHub PRs, Notion docs, Google Docs) can be added.

## When This Applies

- User input is **only** a URL with no other task text
- The URL matches a YouTube pattern: `youtube.com/watch`, `youtu.be/`, `youtube.com/shorts/`
- If the input contains a URL **plus** a task description, this flow does NOT apply -- the URL is noted as context material and normal Task Sizing proceeds

---

## URL Detection Router

```
1. INPUT IS ONLY A URL (no other task text):
   -> YouTube URL? Continue to ANALYZE-FIRST flow below.

2. INPUT IS URL + TASK DESCRIPTION:
   -> Note the URL as context material
   -> Fall through to Step 0.0 (Task Sizing) normally

3. NO URL DETECTED:
   -> Fall through immediately
```

---

## YouTube ANALYZE-FIRST Flow (v3.3.2)

When a bare YouTube URL is detected, do NOT immediately ask "which notebook?" Instead, follow this 5-step process.

### STEP 1: Scratchpad Analysis

- Extract video ID from the URL (the `v=` parameter or `youtu.be/` path)
- Fetch metadata via YouTube oEmbed (fast, clean JSON, ~800 bytes):
  ```
  WebFetch: https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={VIDEO_ID}&format=json
  ```
  Returns: `title`, `author_name` (channel), `thumbnail_url`
- Do NOT fetch the full YouTube page (1MB+ of HTML, unreliable parsing)
- Do NOT fall back to web search or Perplexity for basic metadata -- oEmbed is authoritative
- From the title + channel name, produce a 2-3 sentence summary of what the video likely covers
- Identify the key topics/domains (e.g., "SEO strategy", "AI agents", "salon marketing")

### STEP 2: Notebook Alignment

Cross-reference the identified topics against ALL registered notebooks (from CLAUDE.md):

| ID | Notebook | Domain |
|----|----------|--------|
| `72e9d26f` | BizPilot -- AI Receptionist Platform | Product copy, SEO, pricing, verticals |
| `a5b4c9e0` | BrightBadge -- Daycare Attendance Platform | Childcare, safety, parent flows |
| `fbb3fc76` | Claude Operations & AI Engineering | Agent patterns, Claude features, AI ops |
| `daebedb5` | SEO & Web Intelligence | Website trends, ranking, Core Web Vitals |
| `b8fd338d` | SMB Customer Intelligence | Reddit/FB sentiment, competitor gaps, leads |
| `f34ff6ce` | Financial Intelligence | Market trends, pricing benchmarks, revenue |
| `21650c08` | Media & Content Creation | YouTube/IG strategy, AI video workflow |

Rules:
- Determine the **primary notebook** (best single fit)
- Flag any **secondary notebooks** where specific segments/nuggets could also apply
- If NO notebook is a strong fit, recommend creating a new one with a suggested name and scope

### STEP 3: Present Recommendation (MANDATORY -- always show this)

```
Video Analysis:
-> "{video title}" by {channel}
-> Content: {2-3 sentence summary of what the video covers}

Notebooks (adding to ALL that apply):
-> Primary: {notebook name} ({id}) -- {why this is the best fit}
-> Secondary: {notebook name} ({id}) -- {which segments/topics overlap}
   {additional notebooks if applicable}

Source budget: {notebook}: {current}/{limit} sources
              {notebook}: {current}/{limit} sources

-> Adding to {N} notebooks. Confirm, or adjust?
```

If no good fit:
```
-> No strong notebook match. Suggest creating:
  "{Proposed Notebook Name}" -- for {scope description}
  Create new notebook, or pick an existing one?
```

### STEP 4: Multi-Notebook Sourcing + Cross-Reference

After confirmation, add the source to ALL identified notebooks (not just one):

```bash
# For EACH confirmed notebook:
notebooklm use <notebook_id>
notebooklm source add "<url>"
```

Then graduate a cross-reference vector to Pinecone:
```bash
node scripts/graduate.js --lesson "VIDEO: {title} | Added to notebooks: {id1} ({name1}), {id2} ({name2}), {id3} ({name3}) | Topics: {comma-separated key topics} | URL: {youtube_url}"
```

This Pinecone vector creates connective tissue -- when querying any of those topics later, the vector database knows which notebooks contain relevant material and prevents information silos.

**Source Budget Rules:**
- Check `memory/notebooklm.md` for current source counts before adding
- Free tier: 50 sources/notebook. Warn at 40+. Block at 50.
- After adding, update the source count in `memory/notebooklm.md`
- If a notebook is near capacity, suggest: merge related sources into a single doc, or archive older low-value sources

### STEP 5: Debrief + Actionable Insights

After sourcing is complete, DO NOT just stop. Query the notebooks you just added to and surface actionable takeaways:

```bash
# For EACH notebook the video was added to:
notebooklm use <notebook_id>
notebooklm ask "Based on the newly added source '{video title}', what are the top 2-3 actionable insights or ideas that could improve our system/product/strategy?"
```

Present a consolidated debrief:
```
Ingestion complete -- {N} notebooks updated, Pinecone cross-ref graduated.

Actionable insights from this video:
-> [{notebook name}]: {insight 1} | {insight 2}
-> [{notebook name}]: {insight 1} | {insight 2}
-> [{notebook name}]: {insight 1}

Want to act on any of these? Pick one and I'll spin up a full OP Mode session for it.
Or say "done" to close out.
```

---

## Exit Behavior

- **If Romeo picks an insight** -> transition into normal OP Mode flow (Step 0.0 Task Sizing) with the selected insight as the task description. The video context is already loaded -- no cold start.
- **If Romeo says "done"** -> end cleanly. No further phases.

## Key Principle

Knowledge has no single home. A video about "AI automation for SMBs" belongs in the AI Ops notebook AND the BizPilot notebook AND the SMB Intelligence notebook. Multi-notebook sourcing + Pinecone cross-referencing ensures nothing gets siloed and Claude can always find the connection. But ingestion without reflection is wasted -- always surface what's actionable.

## URL Pattern Detection (Extensibility)

- YouTube: `youtube.com/watch`, `youtu.be/`, `youtube.com/shorts/`
- Future routes (add here as needed): GitHub PRs (`github.com/.../pull/`), Notion docs (`notion.so/`), Google Docs
