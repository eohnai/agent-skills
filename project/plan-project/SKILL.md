---
name: plan-project
description: Use when the user wants to set up a project's records, split a project into areas (services or workstreams), decide which specs an area needs and in what order, or move old specs and roadmaps into area folders.
disable-model-invocation: true
---

# Plan Project

## Overview

Plan the two top levels of a project: the project itself and its areas. For each area, write down what it owns and which specs it needs, in build order. This skill writes STATUS.md and the area files. It doesn't write specs, which is `plan-feature`'s job, and it doesn't write code.

## The levels

| Level | What it is | Where it lives | Planned with |
|---|---|---|---|
| Project | everything the records folder tracks | `STATUS.md` | `plan-project` |
| Area | one service or workstream | `specs/<area>/area.md` | `plan-project` |
| Spec | one feature: one branch, one merge request | `specs/<area>/<feature>.md` | `plan-feature` |
| Task | one session, one commit | a `- [ ]` line in the spec | `plan-feature`, done with `next-task` |

## What an area is

An area is one part of the project with its own code and its own list of specs. In a project made of services, each service is an area, such as `booking` or `matching`. In a single app, an area is a workstream with its own goal, such as `baseline-detection` or `deployment`. A small project can have just one area.

Split areas by who owns the code and what it is for, not by layer (frontend, backend, database). A feature usually cuts through every layer. Split by layer only when different people or repos own the layers.

Make an area only for work this project plans and builds. A service that another team owns isn't an area. Name it in the **Shared context** of the areas that depend on it.

## Finding the records

Same rule as `ketchup`: `./STATUS.md` → records folder is `.`; else `./docs/STATUS.md` → `docs/`. If neither exists, ask whether this is a workspace (records at root) or a single repo (records in `docs/`), then create STATUS.md there from the `checkpoint` template. The other skills find the records folder by its STATUS.md. Create `specs/` if missing.

## Steps

1. **Read first.** Read STATUS.md, the area files in `specs/`, and the layout of the code (`repos/`, top-level folders, services). Read any brief or team document the user points to. If specs sit directly in `specs/`, or `notes/*-roadmap.md` files exist, read `references/moving.md` and offer to move them first.
2. **Ask what's missing.** Ask in one message if most of it is clear, or one question per message if it's vague. Cover:
   - What the project is for, and who uses it.
   - Its parts: services, repos, or workstreams, and which of them this project builds.
   - Who owns which part, and any deadlines, only if the user wants them tracked.
3. **Propose the areas.** For each area, give its name, one sentence about what it owns, and its repo or folder. Label your guesses as guesses. Wait for the user to confirm.
4. **List each area's specs.** Read `references/splitting.md`. Write one line per spec, in build order, with `Needs:` where a spec must wait for another. Make the first feature spec a tracer bullet. Show the list and wait for the user to confirm.
5. **Write the area files** from `references/area-template.md`. If you created STATUS.md, put the areas and the first spec to plan under **Now**.
6. **Hand off.** Run the `progress` script and show the board. Suggest `/plan-feature` for the first spec, ideally in a fresh session.

## Common mistakes

- Writing full specs here. An area file has one line per spec. `plan-feature` writes each spec when it's next.
- Areas by layer ("frontend", "backend") when one feature needs both.
- One area per spec. An area holds several specs.
- An area for a service another team owns.
- Moving files before the user confirms the areas.

Do not commit; the user commits.
