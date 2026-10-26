# Spec template

Write each spec as `specs/<area>/<feature>.md`, with the feature name from the area file's **Specs** list, for example `specs/booking/requests.md`.

```markdown
# <Feature name>

Due: YYYY-MM-DD
Needs: scaffold

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
- **Store request expiry as a timestamp, not a Redis TTL.** A TTL can't be queried for "expiring soon". (2026-10-20)
- Use JWT over server sessions: see [D3](../../DECISIONS.md#d3-use-jwt-over-server-sessions)

## My calls
- Choices made without asking, for the user to check

## Tasks
- [ ] First task
- [ ] Second task @alex
```

## Header lines

- Drop the `Due:` line if there's no deadline.
- Drop the `Needs:` line if the spec can start now. Otherwise list the specs that must merge first, separated by commas. Write `<feature>` for a spec in the same area, or `<area>/<feature>` for a spec in another area.
- Leave out `Status:`. `progress` derives it from the checkboxes until someone marks the spec blocked, dropped, or done.

## Sections

- **Goal:** if the area file has shared context, link the area file here instead of copying it.
- **Constraints:** drop the section if there are none.
- **Verify, Seam:** the place the tests drive the feature from, such as an HTTP endpoint, a CLI command, or a public function. Use the highest seam that already exists. Fewer seams are better, and one is best.
- **Verify, Commands:** the test, lint, and run commands for this repo. Copy them from the README, the CI config, or the package scripts. `next-task` starts each task's check from them.
- **Decisions:** choices the user made between options. Each is written here in 1 to 3 lines, or linked here when it lives in the area file or `DECISIONS.md` (see `record-decision`). Drop the section if there are none.
- **My calls:** small choices you made without asking, so the user can check them.
- **Results:** leave it out. `next-task` adds it after **Verify** when the spec is finished, with the final checks and their output.

Use plain `-` bullets everywhere except **Tasks**: the `progress` script counts every `- [ ]` in the file as a task.
