---
name: record-decision
description: Use when a choice between approaches has been made or needs making on a project (library, architecture, data model, API shape, scope cut, tooling) or when the user says record, log, or write up this decision.
---

# Record Decision

## Overview

Capture why a choice was made, including the options rejected, so that later work and reports don't have to guess. One decision per file.

## Where

`decisions/` inside the records folder (`./` if `./STATUS.md` exists, else `docs/`). Create the folder if missing.

Filename: `NNNN-short-kebab-title.md`, where NNNN is one more than the highest existing number, zero-padded to 4 digits (`0001-use-postgres.md`).

## Template

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
- Never rewrite an accepted decision. To change course, write a new record and set the old one's status to `superseded by NNNN`. Changing only that status line is allowed.
- If a decision is still open, write it with `Status: proposed`, fill in Options, and leave Decision as `Open`.
- Keep it under a page. Link specs or code instead of restating them.

Do not commit; the user commits.
