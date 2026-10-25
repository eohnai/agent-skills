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
| `Needs: <spec>, <spec>` | Specs that must finish first. Until they do, a spec with no ticked tasks shows `waiting on <spec>` |

A spec is **finished** when it has `Status: dropped`, or `Status: done` with every task ticked. All tasks ticked without the line is not finished, because its merge request may still be open. `done` with unticked tasks is not finished either, until the user settles it.

The script also reads `notes/*-roadmap.md` (see `plan-feature`). The board lists each roadmap's area with the `` - `<slice>`: `` lines under its `## Slices` heading, in roadmap order, under a row that says how many of its slices are finished. A finished slice (`Status: done` or `dropped`) is crossed off. A slice with no spec yet gets a `no spec yet` row, and the Total row counts them. Specs in no roadmap come after, under **Other specs**.

## Show the board

Run from the project root and show its output:

```bash
bash <this skill's directory>/scripts/progress.sh
```

It prints the board (Status, Due, Done, Left, Blocked, Next task), then a list of blocked tasks with reasons, then open and blocked counts per owner if any tasks have `@owners`. Finished specs in no roadmap, and roadmap areas whose slices are all finished, get no row. They are listed on one line under the board. The Total row counts their done tasks, but not their open or blocked ones, because nobody will do those. Add `--all` to show them as rows, when the user asks about finished work.

Then add two or three lines of commentary, most urgent first:

1. Anything `OVERDUE` or marked ⚠ (due within 7 days), with how many tasks are left.
2. Blocked tasks: what each is waiting on, and whether anything can unblock it.
3. Specs flagged `all ticked` or `(but N unticked)` that need the user's decision.
4. Roadmap slices with `no spec yet`, if nothing else in the area is left to start.

Derived statuses: `not started`, `waiting on <spec>`, `in progress`, `blocked (all open tasks)`, `all ticked`, `no tasks`, and `no spec yet` for roadmap slices. An explicit `Status:` line wins. Done or dropped specs are never shown as overdue.

## Update progress

- **A task got finished:** tick its checkbox (`- [x]`). Only tick work that exists in the code.
- **A task is blocked:** add `(blocked: <reason>)` to it; remove that when it's unblocked.
- **A spec is blocked or dropped:** add or edit its `Status:` line, with the reason for blocked.
- **Done:** `all ticked` is not done. `next-task` adds `Status: done` as the last commit on the spec's branch, so the default branch shows it once the merge request merges. Otherwise, set it only when the user says they're satisfied with the result. If they haven't said so, ask. Specs that need this one stay `waiting on` it until then.
- **Deadlines and owners:** add `Due:` or `@name` only when the user gives them; don't guess.
- **New work:** add `- [ ]` tasks to the relevant spec. Don't track tasks anywhere else.

Do not commit; the user commits.
