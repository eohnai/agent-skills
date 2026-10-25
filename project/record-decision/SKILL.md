---
name: record-decision
description: Use when a choice between approaches has been made or needs making on a project (library, architecture, data model, API shape, scope cut, tooling) or when the user says record, log, or write up this decision.
---

# Record Decision

## Overview

Capture why a choice was made, including the options rejected, so that later work and reports don't have to guess. It goes in the spec, unless it reaches further.

## Is it a decision?

A decision is a choice between at least two options that were really considered. A plan, a task, or a check is not a decision. "Finish the dispatch refactor" and "verify the upload flow" are tasks, so they go in the spec's **Tasks**. A small call made without asking goes under **My calls** in the spec.

## Where

Write it in the spec's **Decisions** section, in 1 to 3 lines: what was chosen, what was rejected, and why.

```markdown
- **Store request expiry as a timestamp, not a Redis TTL.** A TTL can't be queried for "expiring soon". (2026-10-20)
```

Write a file in `decisions/` instead, and link it from the spec's **Decisions** section, when:
- the choice is project-wide: a library, the architecture, a convention every spec follows;
- a second spec needs it. Move the line from the first spec to a file, and link it from both;
- it reverses an earlier file.

Files go in `decisions/` inside the records folder (`./` if `./STATUS.md` exists, else `docs/`). Create the folder if missing. Filename: `NNNN-short-kebab-title.md`, where NNNN is one more than the highest existing number, zero-padded to 4 digits (`0001-use-postgres.md`). One decision per file.

## File template

```markdown
# NNNN: Title as a statement ("Use Postgres for storage")

- Status: proposed | accepted | superseded by NNNN
- Date: YYYY-MM-DD

## Context
The problem or constraint that forced a choice. Facts only.

## Options
- **Option A**: what it is; pros; cons
- **Option B**: ...

## Decision
What was chosen, in one or two sentences.

## Reasoning
Why this option beat the others. Name the deciding factor.

## Consequences
What this makes easier, what it makes harder, what would make us revisit it.
```

## Rules

- **Reasoning comes from the user or the conversation.** If the reason for a choice isn't known, ask; don't invent one. Anything you infer yourself gets an `^[inferred]` marker.
- Include rejected options that were genuinely considered, even briefly. That is most of the value.
- Never rewrite an accepted decision. To change course in a file, write a new record and set the old one's status to `superseded by NNNN`. Changing only that status line is allowed. To change course in a spec, add a new line and end the old one with `(replaced YYYY-MM-DD)`.
- If a decision is still open, write it with `Status: proposed`, fill in Options, and leave Decision as `Open`. In a spec, write the line as `**Open:** <the question>` and add a task to settle it.
- Keep a file under a page. Link specs or code instead of restating them.

Do not commit; the user commits.
