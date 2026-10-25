---
name: plan-feature
description: Use when the user wants to start a new feature, assignment, or chunk of work and needs it turned into a spec with tasks, or says plan this, write a spec, or break this down, before any code is written.
disable-model-invocation: true
---

# Plan Feature

## Overview

Turn an idea into a spec the other project skills can track: what's being built and why, what "done" means, the choices made along the way, and a task list where each task fits one work session. It writes the spec and any decisions, but no code.

The usual failure is planning what you assume the user wants. Find out what they actually want first, and mark every guess as yours.

## The levels

| Level | What it is | Where it lives |
|---|---|---|
| Project | everything the records folder tracks | `STATUS.md` |
| Area | one service or workstream | `specs/<area>/area.md` |
| Spec | one feature: one branch, one merge request | `specs/<area>/<feature>.md` |
| Task | one session, one commit | a `- [ ]` line in the spec |

## What an area is

An area is one part of the project with its own code and its own list of specs. In a project made of services, each service is an area, such as `booking` or `matching`. In a single app, an area is a workstream, such as `baseline-detection` or `deployment`. Every spec belongs to one area. A small project can have just one area.

The area file, `specs/<area>/area.md`, says what the area owns and lists its specs in build order, including specs not written yet. Write it from `references/area-template.md`. It isn't a spec, so it has no tasks.

A spec that changes two areas belongs to the area that owns the result. Name the other area in its Goal.

## What a spec is

A spec is one feature: one change that can be reviewed and merged on its own. In git, it is one branch and one merge request, named after its area and file (`specs/booking/requests.md` → `feat/booking-requests`). For example, in a booking service, "a client requests a trainer" is one spec and "a trainer cancels a session" is another. The whole booking service is not one spec.

A spec:
- has its own Done-when checks, which pass when its last task is done;
- usually has 3 to 8 tasks;
- keeps its tasks in one repo where possible. A task in another repo gets a branch with the same name in that repo.

**Is it one feature?** Sort the Done-when checks into groups. Two checks are in the same group if one can't pass without the other's work. One group is one feature. More than one group is several features, and each gets its own spec. First unpack any check that bundles others ("every acceptance test in §10 passes") into the checks inside it.

## What a task is

A task is the smallest change that has its own test cycle and that a reviewer could reject while approving the task next to it. For example, "Add `POST /requests` with its 409 paths" is a task. "Add the requests table" is not, because nothing can check it alone, so it goes into the first task that needs the table.

A task:
- fits one session and ends with the tests passing, so it can be its own commit;
- touches at most 3 files and adds at most 3 functions or 5 test cases. If it needs more, or needs "and then", split it;
- includes the setup, config, and docs it needs, instead of leaving them to separate tasks.

## Finding the records

Same rule as `ketchup`: `./STATUS.md` → records folder is `.`; else `./docs/STATUS.md` → `docs/`. If neither exists, ask whether this is a workspace (records at root) or a single repo (records in `docs/`), then create STATUS.md there from the `checkpoint` template with this feature under **Now**. The other skills find the records folder by its STATUS.md, so a `specs/` folder without one is invisible to them. Create `specs/` if missing.

## Steps

1. **Size it.** If the request is a small, clear change (one area of the code, nothing to decide), say so and suggest doing it directly. A spec is for work that takes more than one session. If the request names a whole service, app, or assignment, say it is probably several features. Step 4 decides.
2. **Read first.** Skim the code and any existing spec the feature touches, so questions and tasks match what's already there. If the feature touches code that neither you nor the user understands yet (several files, services, or layers), use `how` on that part of the code first.

   Then find the area. If it isn't clear which area the feature belongs to, ask. If the area has no `area.md` yet, create one from `references/area-template.md`. If the user named no feature, write the next spec that the area file lists but that has no file yet. If `specs/<area>/<feature>.md` exists, update it instead of starting over: add tasks, never untick or delete done ones. If an existing spec holds more than one feature, offer to split it with `references/splitting.md`. If specs sit outside area folders, or `notes/*-roadmap.md` files exist, offer to move them with **Moving to areas** in `references/area-template.md`.
3. **Ask what's missing.** If the request already says what it does and how to check it, ask the remaining items in one message. If it's vague, ask one question per message, starting with an open one ("Walk me through when you'd use this"); when the user says "you pick", propose something concrete. Cover:
   - What it does, from the user's point of view, and why now.
   - Done when: observable checks ("`pytest tests/auth` passes", "logging in with a wrong password shows an error"), not "works well". At least one check runs the real thing (the app, an endpoint, an e2e suite), not only unit tests.
   - Out of scope, including anything that would make it a failure even if it technically works.
   - Constraints: platform limits and patterns the code must keep, if the code doesn't already show them.
   - Due date and owners, only if the user wants them tracked.
4. **Play it back.** Summarize the goal, done-when checks, and out-of-scope in a few lines, label your guesses as guesses, and ask what's wrong or missing. Sort the Done-when checks into groups (see **Is it one feature?**). If there is more than one group, read `references/splitting.md` and show the proposed specs too. Write tasks only after the user confirms.
5. **Surface real choices.** For each choice between approaches (library, data model, API shape, where logic lives), lay out the options with one pro and one con each and let the user pick. Then **REQUIRED:** use `record-decision` to write it, with the user's reasoning. It goes in this spec, unless `record-decision` says it needs a file. If they want to defer, record it as open, in the format `record-decision` gives, and add a task to settle it. When the choice is about the shape of the code (which module owns the data, how the parts call each other), draft two designs that differ in structure, not only in details, before you compare them. Skip this when one shape is clearly right. Small calls that don't need a record (a file location, a default value) go under **My calls** in the spec, so the user can check them.
6. **Write the tasks.** Each task fits **What a task is**, and:
   - starts with a verb and names something checkable ("Add `/login` endpoint returning a JWT", not "auth stuff");
   - is ordered so earlier tasks unblock later ones. Removal and refactoring that make the change easier come first: make the change easy, then make the easy change;
   - gets `@owner` or `(blocked: reason)` only when known.
7. **Check the tasks against the spec.** Every Done-when check is covered by at least one task, and no task does work outside the Goal. Add or cut tasks until both hold. If the spec now has more than about 8 tasks, step 4 missed a split, so go back to step 4.
8. **Write the spec** as `specs/<area>/<feature>.md` from `references/spec-template.md`, and add its line to the area file's **Specs** list if it isn't there. Then show the user the task list and ask if anything is missing or mis-sized. No task starts until they approve it.
9. **Hand off.** Suggest starting the first task with `next-task`, ideally in a fresh session. If the area file lists specs that have no file yet, name them, and say that running `plan-feature` again writes the next one.

## Common mistakes

- Writing the implementation steps for every task now. Step-by-step planning happens per task in `next-task`, when the code it builds on exists.
- One spec for a whole service or app. It becomes one branch with one merge request that is too big to review. A service is an area, with several specs.
- A spec outside an area folder. The board shows it under **No area**, apart from the specs it belongs with.
- A Done-when check that bundles many checks, so several features look like one.
- Tasks too big to finish and verify in one session ("Build the backend").
- Tasks too small to check alone ("Add the table", "Update the README").
- "Done when" criteria nobody can check.
- Presenting your own assumptions as things the user said.

Do not commit; the user commits.
