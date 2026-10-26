---
name: record-decision
description: Use when a choice between approaches has been made or needs making on a project (library, architecture, data model, API shape, scope cut, tooling) or when the user says record, log, or write up this decision.
---

# Record Decision

## Overview

Capture why a choice was made, including the options rejected, so that later work and reports don't have to guess. A decision goes at the level it affects: the spec, the area, or the project.

## Is it a decision?

A decision is a choice between at least two options that were really considered. A plan, a task, or a check is not a decision. "Finish the dispatch refactor" and "verify the upload flow" are tasks, so they go in the spec's **Tasks**. A small call made without asking goes under **My calls** in the spec.

## Where

| It affects | Write it in |
|---|---|
| one spec | the spec's **Decisions** section |
| several specs in one area | the **Decisions** section of `specs/<area>/area.md` |
| more than one area, or the whole project (a library, the architecture, a convention every spec follows) | `DECISIONS.md` in the records folder |

The records folder is `./` if `./STATUS.md` exists, else `docs/`. Create `DECISIONS.md` if it's missing, with `# Decisions` as its first line.

In a spec or an area file, write the decision in 1 to 3 lines: what was chosen, what was rejected, and why.

```markdown
- **Store request expiry as a timestamp, not a Redis TTL.** A TTL can't be queried for "expiring soon". (2026-10-20)
```

When a second spec needs a decision from a spec's **Decisions**, move the line up a level: to the area file if both specs are in that area, else to `DECISIONS.md`. Leave a link in its place in the first spec, and add one to the second:

```markdown
- Request expiry is a timestamp: see [area decisions](area.md#decisions)
- Use JWT over server sessions: see [D3](../../DECISIONS.md#d3-use-jwt-over-server-sessions)
```

## DECISIONS.md entries

Each entry is a `##` section numbered `D<n>`, where n is one more than the highest number in the file. Add new entries at the end, and never renumber. The heading is a statement, so the link anchor reads well: `## D3: Use JWT over server sessions` → `DECISIONS.md#d3-use-jwt-over-server-sessions`.

```markdown
## D<n>: Title as a statement ("Use Postgres for storage")

- Status: proposed | accepted | superseded by D<m>
- Date: YYYY-MM-DD

**Context.** The problem or constraint that forced a choice. Facts only.

**Options.**
- **Option A**: what it is; pros; cons
- **Option B**: ...

**Decision.** What was chosen, in one or two sentences.

**Reasoning.** Why this option beat the others. Name the deciding factor.

**Consequences.** What this makes easier, what it makes harder, what would make us revisit it.
```

Keep an entry under half a page. Link specs or code instead of restating them.

## Rules

- **Reasoning comes from the user or the conversation.** If the reason for a choice isn't known, ask; don't invent one. Anything you infer yourself gets an `^[inferred]` marker.
- Include rejected options that were genuinely considered, even briefly. That is most of the value.
- Never rewrite an accepted decision. To change course in `DECISIONS.md`, add a new entry and set the old one's status to `superseded by D<m>`. Changing only that status line is allowed. To change course in a spec or an area file, add a new line and end the old one with `(replaced YYYY-MM-DD)`.
- If a decision is still open, write it in `DECISIONS.md` with `Status: proposed`, fill in Options, and write `**Decision.** Open.` In a spec or an area file, write the line as `**Open:** <the question>`. Either way, add a task to the spec that will settle it.

## Moving from decisions/

Older projects keep one file per decision in `decisions/NNNN-*.md`. When you find that folder, offer to move it into `DECISIONS.md`, and ask before moving anything. Moving it:

1. Make each file an entry in number order, keeping its number (`0003-jwt-over-sessions.md` → `## D3: Use JWT over server sessions`). Turn the file's `##` sections into the bold labels above, and change `superseded by 0007` to `superseded by D7`.
2. A file that only one spec or one area relies on can go in that spec's or area's **Decisions** instead, as 1 to 3 lines. Leave a gap in the numbers rather than renumbering.
3. Fix links to the old files (`grep -rn "decisions/"`), then `git rm -r decisions/`.

Do not commit; the user commits.
