---
name: plan-feature
description: Use when the user wants to start a new feature, assignment, or chunk of work and needs it turned into a spec with tasks, or says plan this, write a spec, or break this down, before any code is written.
disable-model-invocation: true
---

# Plan Feature

## Overview

Turn an idea into a spec the other project skills can track: what's being built and why, what "done" means, the choices made along the way, and a task list where each task fits one work session. Writes the spec and any decision records; writes no code.

The usual failure is planning what you assume the user wants. Find out what they actually want first, and mark every guess as yours.

## Finding the records

Same rule as `ketchup`: `./STATUS.md` → records folder is `.`; else `./docs/STATUS.md` → `docs/`. If neither exists, ask whether this is a workspace (records at root) or a single repo (records in `docs/`), then create STATUS.md there from the `checkpoint` template with this feature under **Now**. The other skills find the records folder by its STATUS.md, so a `specs/` folder without one is invisible to them. Create `specs/` if missing.

## Steps

1. **Size it.** If the request is a small, clear change (one area of the code, nothing to decide), say so and suggest doing it directly. A spec is for work that takes more than one session.
2. **Read first.** Skim the code and any existing spec the feature touches, so questions and tasks match what's already there. If the feature touches code that neither you nor the user understands yet (several files, services, or layers), use `how` on that area first. If `specs/<name>.md` or `specs/<name>/` exists, update it instead of starting over: add tasks, never untick or delete done ones.
3. **Ask what's missing.** If the request already says what it does and how to check it, ask the remaining items in one message. If it's vague, ask one question per message, starting with an open one ("Walk me through when you'd use this"); when the user says "you pick", propose something concrete. Cover:
   - What it does, from the user's point of view, and why now.
   - Done when: observable checks ("`pytest tests/auth` passes", "logging in with a wrong password shows an error"), not "works well".
   - Out of scope, including anything that would make it a failure even if it technically works.
   - Due date and owners, only if the user wants them tracked.
4. **Play it back.** Summarize the goal, done-when checks, and out-of-scope in a few lines, label your guesses as guesses, and ask what's wrong or missing. Write tasks only after the user confirms.
5. **Surface real choices.** For each choice between approaches (library, data model, API shape, where logic lives), lay out the options with one pro and one con each and let the user pick. Then **REQUIRED:** use `record-decision` to write it, with the user's reasoning. If they want to defer, record it as `proposed` and add a task to settle it. When the choice is about the shape of the code (which module owns the data, how the parts call each other), draft two designs that differ in structure, not only in details, before you compare them. Skip this when one shape is clearly right. Small calls that don't need a record (a file location, a default value) go under **My calls** in the spec, so the user can check them.
6. **Write the tasks.** Each task:
   - starts with a verb and names something checkable ("Add `/login` endpoint returning a JWT", not "auth stuff");
   - fits one session: one area of the code, verifiable on its own. If a task needs "and then", split it;
   - is ordered so earlier tasks unblock later ones;
   - gets `@owner` or `(blocked: reason)` only when known.
7. **Check the tasks against the spec.** Every Done-when check is covered by at least one task, and no task does work outside the Goal. Add or cut tasks until both hold.
8. **Write the spec** using the template below, then show the user the task list and ask if anything is missing or mis-sized. No task starts until they approve it.
9. **Hand off.** Suggest starting the first task with `next-task`, ideally in a fresh session.

## Spec template

```markdown
# <Feature name>

Due: YYYY-MM-DD

## Goal
What this does, for whom, and why, in 2–3 sentences.

## Done when
- Observable check 1
- Observable check 2

## Out of scope
- ...

## Decisions
- [0003: Use JWT over server sessions](../decisions/0003-jwt-over-sessions.md)

## My calls
- Choices made without asking, for the user to check

## Tasks
- [ ] First task
- [ ] Second task @alex
```

Drop the `Due:` line if there's no deadline. Use plain `-` bullets everywhere except **Tasks**: the `progress` script counts every `- [ ]` in the file as a task. Leave out `Status:`; `progress` derives it from the checkboxes until someone marks the spec blocked, dropped, or done.

## Common mistakes

- Writing the implementation steps for every task now. Step-by-step planning happens per task in `next-task`, when the code it builds on exists.
- Tasks too big to finish and verify in one session ("Build the backend").
- "Done when" criteria nobody can check.
- Presenting your own assumptions as things the user said.

Do not commit; the user commits.
