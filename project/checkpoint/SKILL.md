---
name: checkpoint
description: Use when ending a work session, after finishing a meaningful chunk of work, before switching tasks, or when the user says checkpoint, save progress, wrap up, or update status.
---

# Checkpoint

## Overview

Write down where the project stands so the next session (yours or an agent's) can pick it up cold. Record judgment and evidence; derive everything else.

## Finding the records

Same rule as `ketchup`: `./STATUS.md` → records folder is `.`; else `./docs/STATUS.md` → `docs/`. If neither exists, ask whether this is a workspace (create at root) or a single repo (create in `docs/`), then create STATUS.md from the template below.

## Steps

1. Review what happened this session: the conversation, `git status`, `git diff --stat`, and commits since STATUS.md last changed (`git log -1 --format=%cI -- STATUS.md` gives the time).
2. Update STATUS.md to match the template. Rewrite **Now**, **Next**, and **Blockers** so they are current. Don't add to the old text. Keep **Next** to at most 5 actions. Facts about the code don't go in Next. Put them in the spec or a code comment. Put a fact in the repo's `AGENTS.md` or `CLAUDE.md` only if every session needs it, like a test command or a port, because agents load that file every session.
3. **Failed checks**: if a check failed or couldn't run, add it to **Blockers** with the exact command and the error. Don't record checks that passed. A ticked task already says its check passed, and the spec's **Verify** section holds the commands. A finished spec keeps its final results in its own **Results** section (see `next-task`). Never write in **Now** that tests pass without a command run this session.
4. **Progress**: tick off the tasks completed this session in the specs themselves (see the `progress` skill for the convention). Tick a task only if its check passed this session. Then run the `progress` script. If anything is overdue or due within a week, say so in **Now**. Don't copy the board or the task list into STATUS.md, because a copy goes stale. `ketchup` runs the script again each session.
5. **Stale records**: if a spec or older note contradicts the code, list it under Blockers as `Stale: <file>: <what the code actually does>`. Change the spec only if the user agrees.
6. If a choice between approaches was made this session and isn't recorded (in the spec's **Decisions** section or in `decisions/`), say so and offer to run `record-decision`.
7. Show the user a short summary of what changed in STATUS.md. Do not commit; the user commits.

## STATUS.md template

```markdown
# Status

## Now
What is being worked on and its current state (2–4 lines).

## Next
1. Concrete next action (file or command to start from)
2. ...

## Blockers
- None
```

Git keeps what got done: each task is its own commit, and `git log -p -- STATUS.md` shows every earlier version of this file.

## Common mistakes

- Writing intentions as progress in **Now** ("implemented X" when X was only started).
- Copying the spec's task list into STATUS.md, where it goes stale.
- Recording checks that passed. Old results look like they still hold after the code has changed, and every session reads them.
- Keeping Verification, Progress, or Log sections from the old template. Move any failed check or open question to Blockers or Next, then delete those sections.
- Writing notes about the code in Next. They belong in the spec or the code.
