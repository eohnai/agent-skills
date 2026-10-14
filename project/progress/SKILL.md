---
name: progress
description: Use when the user asks what's done, what's left, how far along a project is, for a progress board or task overview, or wants to mark a spec done, blocked, or dropped.
---

# Progress

## Overview

Show what's done and what's left per spec, derived from the checkboxes in the specs themselves. The board is computed, never hand-maintained, so it can't drift from the specs.

## Spec convention

Specs live in `specs/` inside the records folder (`./` if `./STATUS.md` exists, else `docs/`):

- `specs/<name>.md`, or a folder `specs/<name>/` of `.md` files (e.g. `spec.md` + `tasks.md`)
- Tasks are checkboxes: `- [ ] task` / `- [x] task`, grouped under any headings
- Optional `Status: <value>` line to record judgment the checkboxes can't show: `blocked: <reason>`, `dropped`, or `done`

## Show the board

Run the script from the project root and show its table:

```bash
bash <this skill's directory>/scripts/progress.sh
```

Then add one or two lines of commentary: what's closest to finished, and anything flagged `(but N unticked)` or `all ticked` that needs a decision.

Derived statuses: `not started`, `in progress`, `all ticked`, `no tasks`. An explicit `Status:` line wins.

## Update progress

- **A task got finished:** tick its checkbox in the spec (`- [x]`). Only tick work that exists in the code.
- **Blocked or dropped:** add or edit the spec's `Status:` line, with the reason for blocked.
- **Done:** `all ticked` is not done. Set `Status: done` only when the user says they're satisfied with the result. If they haven't said so, ask.
- **New work:** add `- [ ]` tasks to the relevant spec. Don't track tasks anywhere else.

Do not commit; the user commits.
