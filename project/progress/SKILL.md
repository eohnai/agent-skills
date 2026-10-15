---
name: progress
description: Use when the user asks what's done, what's left, what's due or overdue, what's blocked, who owns what, or how far along a project is, or wants to mark a spec done, blocked, or dropped or set a deadline.
---

# Progress

## Overview

Show what's done, what's left, what's due, and what's blocked per spec, derived from the specs themselves. The board is computed, never hand-maintained, so it can't drift from the specs.

## Spec convention

Specs live in `specs/` inside the records folder (`./` if `./STATUS.md` exists, else `docs/`), as `specs/<name>.md` or a folder `specs/<name>/` of `.md` files. Everything except the checkboxes is optional:

```markdown
Status: in progress
Due: 2026-11-20

- [x] JWT tokens
- [ ] rate limit login @alex (blocked: waiting for API key)
- [ ] login form @me
```

| Write | Meaning |
|---|---|
| `- [ ] task` / `- [x] task` | Open / done |
| `(blocked: reason)` in an open task | Blocked, with the reason |
| `@name` in a task | Owner (useful in group projects) |
| `Status: <value>` | Judgment the checkboxes can't show: `blocked: <reason>`, `dropped`, or `done` |
| `Due: YYYY-MM-DD` | Deadline. Must be this exact format to be checked |

## Show the board

Run from the project root and show its output:

```bash
bash <this skill's directory>/scripts/progress.sh
```

It prints the board (Status, Due, Done, Left, Blocked, Next task), then a list of blocked tasks with reasons, then open and blocked counts per owner if any tasks have `@owners`.

Then add two or three lines of commentary, most urgent first:

1. Anything `OVERDUE` or marked ⚠ (due within 7 days), with how many tasks are left.
2. Blocked tasks: what each is waiting on, and whether anything can unblock it.
3. Specs flagged `all ticked` or `(but N unticked)` that need the user's decision.

Derived statuses: `not started`, `in progress`, `blocked (all open tasks)`, `all ticked`, `no tasks`. An explicit `Status:` line wins. Done or dropped specs are never shown as overdue.

## Update progress

- **A task got finished:** tick its checkbox (`- [x]`). Only tick work that exists in the code.
- **A task is blocked:** add `(blocked: <reason>)` to it; remove that when it's unblocked.
- **A spec is blocked or dropped:** add or edit its `Status:` line, with the reason for blocked.
- **Done:** `all ticked` is not done. Set `Status: done` only when the user says they're satisfied with the result. If they haven't said so, ask.
- **Deadlines and owners:** add `Due:` or `@name` only when the user gives them; don't guess.
- **New work:** add `- [ ]` tasks to the relevant spec. Don't track tasks anywhere else.

Do not commit; the user commits.
