# Spec template

Write each spec as `specs/<name>.md`. For a slice from a roadmap, the name is the slice name, for example `specs/booking-requests.md`.

```markdown
# <Feature name>

Due: YYYY-MM-DD
Needs: booking-scaffold

## Goal
What this does, for whom, and why, in 2–3 sentences.

## Done when
- Observable check 1
- A check that runs the real thing: `npx playwright test s1-book` passes

## Out of scope
- ...

## Constraints
- Limits and patterns the code must keep ("copy Billing's skeleton", "no new dependencies")

## Verify
- Seam: `POST /requests` over HTTP
- Commands: `npm test`, `npm run lint`

## Decisions
- [0003: Use JWT over server sessions](../decisions/0003-jwt-over-sessions.md)

## My calls
- Choices made without asking, for the user to check

## Tasks
- [ ] First task
- [ ] Second task @alex
```

## Header lines

- Drop the `Due:` line if there's no deadline.
- Drop the `Needs:` line if the spec can start now. Otherwise list the specs that must merge first, separated by commas.
- Leave out `Status:`. `progress` derives it from the checkboxes until someone marks the spec blocked, dropped, or done.

## Sections

- **Goal:** if the spec comes from a roadmap, link the roadmap here instead of copying its shared context.
- **Constraints:** drop the section if there are none.
- **Verify, Seam:** the place the tests drive the feature from, such as an HTTP endpoint, a CLI command, or a public function. Use the highest seam that already exists. Fewer seams are better, and one is best.
- **Verify, Commands:** the test, lint, and run commands for this repo. Copy them from the README, the CI config, or the package scripts. `next-task` starts each task's check from them.

Use plain `-` bullets everywhere except **Tasks**: the `progress` script counts every `- [ ]` in the file as a task.
