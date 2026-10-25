---
name: next-task
description: Use when the user wants to work on the next task from a project's specs, says next task or do the next thing, or names a task from a spec to work on.
disable-model-invocation: true
---

# Next Task

## Overview

One session, one task: catch up, plan the task, do it, verify it, checkpoint. Keeping each session to a single task keeps the context small and forces the records to carry everything the next session needs.

```
fresh session → next-task → /clear → fresh session → next-task → ...
```

## Steps

1. **Catch up.** If `ketchup` hasn't run in this session, **REQUIRED:** use `ketchup`. If the project has no specs, suggest `plan-feature` first.
2. **Pick one task.** Pick the task the user named. If they named none, pick the board's next task from the spec `ketchup` pointed to. Skip blocked tasks. Skip specs whose `Needs:` specs haven't merged yet, unless the user wants to stack the branch (step 5). Confirm the pick with the user in one line before planning.
3. **Size check.** If the task can't be finished and verified in this session (several areas of the code, an unsettled design choice), propose splitting it into smaller `- [ ]` tasks in the spec and do only the first. Change the spec only if the user agrees. If the spec itself holds more than one feature (see `plan-feature`, **What a spec is**), say so and suggest splitting it with `plan-feature` before you start.
4. **Grind or hands-on?** If the task is repetitive and has a pass/fail check that can run every turn (make failing tests pass, migrate every caller of an API, fix all lint errors), offer to run it unattended as a `/goal`. If the user agrees, **REQUIRED:** use `make-goal` with this task as the aim, instead of the steps below; the goal checkpoints itself. When you hand over the goal block, tell the user to commit, `/clear`, and run `next-task` once the goal finishes. Anything needing judgment along the way (design, UI, choosing between approaches) stays hands-on.
5. **Plan in the chat**, short, and wait for the user's OK:
   - files to change and what changes in each;
   - names and signatures this task creates that later tasks in the spec will use. When the task adds new modules, types, or functions, sketch them first: the types and signatures with empty bodies, and one short example of how a caller uses them. If the caller example is awkward, change the sketch before writing code;
   - steps in order; if the project has tests, start with one that fails without the change;
   - how it will be verified: the exact command and the output that means it passed. Start from the spec's **Verify** section;
   - any choice between approaches: give the options and let the user pick, then **REQUIRED:** use `record-decision`.

   **One branch per spec, not per task.** Every task from a spec goes on one branch, named after the spec file (`specs/booking-requests.md` → `feat/booking-requests`), in whichever repo the task changes. Propose the branch with the plan, and switch to it or create it once the user OKs:
   - Already on it: stay, unless it has merged. Then create it again from the latest default branch.
   - Anywhere else: switch to it, or create it from the latest default branch. If a `Needs:` spec hasn't merged yet, create it from that spec's branch instead, so its merge request stacks on that one.
6. **Do the task**, and only this task. Anything else you notice (a bug, a missing task, a stale note): write it down and keep going. Don't fix it in this change.
7. **Verify** with the command from the plan and show the result. If it fails and the cause isn't obvious from the output, **REQUIRED:** use `debug-issue`; then rerun. If it can't pass this session, stop: mark the task `(blocked: reason)` or leave it open, and say why. If this was the spec's last open task, also run its **Verify** commands and every Done-when check you can run here.
8. **Checkpoint.** **REQUIRED:** use `checkpoint`. Tick the task only if verification passed. Offer to add what you noted along the way to the spec as new `- [ ]` tasks or to STATUS.md Blockers.
9. **Hand off.** Give the commands to commit this task on its own: one `git add` listing every changed file by path, including STATUS.md and the spec, and one `git commit -m "<type>: <task line>"` (`feat: add /login endpoint returning a JWT`, or `fix`, `refactor`, `test`, or `docs` when that fits the task better). Then tell them to `/clear` and run `next-task` again for the next task. You can't clear the session yourself. If that was the spec's last task and its checks passed, read `references/finishing.md` instead: it closes the spec on its branch and drafts the merge request. If the area's roadmap lists slices with no spec yet, suggest `plan-feature` for the next one.

## When to stop early

- The plan turns out wrong (the code isn't what the records said, the task depends on unfinished work): stop, tell the user, and checkpoint what you learned.
- The design fights the code. Signs: the same workaround appears in several places, many edge cases each need their own special branch, types need escape hatches (`any`, casts) to compile, or callers must know the internals to use it. Stop and say the design is wrong. Don't patch more code onto it. One awkward case is not enough, so look for a pattern.
- The same failure three times: stop and checkpoint with the error, instead of trying a fourth variation.

## Common mistakes

- Starting a second task because the first was quick. Checkpoint and hand off instead; the next session starts cleaner.
- Ticking a task that was written but not verified.
- Planning the whole feature again. The spec already has the tasks; plan only this one.

Do not commit; the user commits.
