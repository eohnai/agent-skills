# Area template

Write each area as `specs/<area>/area.md`. Name the area in lowercase with dashes, for example `booking` or `baseline-detection`. Its specs go in the same folder.

```markdown
# Booking

Owns everything after a client clicks **Request**: the request, the trainer's answer, sessions, and charging. Code: `cs302-booking`.

## Specs
- `scaffold`: TypeScript skeleton, schema, and a green pipeline.
- `requests`: a client requests a trainer, and the trainer accepts or declines. Needs: scaffold.
- `sessions`: either side cancels a session. Needs: requests.

## Shared context
- Team specs: `cs302-ops`, branch `docs/redesign-specs`, folder `docs/spec/`

## Decisions
- **Charge when the session ends, not when it's booked.** Booking-time charges need refunds for every cancellation. (2026-10-20)

## Open questions
- Who owns `cs302-ops`?
```

## Sections

- **Title:** the area's name as the board shows it.
- **First paragraph:** what the area owns, in 1 to 3 sentences, and its repo or folder. A new spec that doesn't fit this paragraph belongs to another area.
- **Specs:** every spec in the area, in build order, including specs not written yet. Keep each line in this exact shape: `` - `<feature>`: <what it does>. ``. The `progress` script reads these lines. It prints the board in this order, crosses off finished specs, and shows `no spec yet` for lines with no file.
- **Shared context:** what several specs need, written once, such as links to team documents. Each spec links to the area file instead of copying it. Drop the section if there is nothing.
- **Decisions:** choices that more than one spec in the area follows, written as `record-decision` says. Drop the section if there are none.
- **Open questions:** questions for the team or the user that affect more than one spec. Drop the section if there are none.

Don't tick specs or mark them done here. Use plain `-` bullets, never `- [ ]`, because the `progress` script counts those as tasks. A spec is finished when its own file says so: `Status: done` with every task ticked, or `Status: dropped`. The board shows that.

## Moving to areas

Read this when specs sit directly in `specs/`, or the project has old `notes/<area>-roadmap.md` files.

1. Propose the areas and which specs go in each. Base them on what each spec changes. Old spec names often start with the area (`booking-requests` → area `booking`). Ask the user to confirm. Ask before you move anything, because open branches and teammates may use the old paths.
2. For each old roadmap, create `specs/<area>/area.md` from it. Rename `## Slices` to `## Specs`, and drop the area from each name (`` `booking-requests` `` → `` `requests` ``). Add a first paragraph that says what the area owns.
3. Move each spec with `git mv`, and drop the area from its file name (`specs/booking-requests.md` → `specs/booking/requests.md`). Its branch name stays the same: `feat/booking-requests`.
4. Update every `Needs:` line. Use `<feature>` for a spec in the same area, or `<area>/<feature>` for a spec in another area.
5. Delete the old roadmap files, and fix links to the old paths (`grep -rn "notes/.*-roadmap\|specs/<old-name>"`).
6. Run the `progress` script. No spec should be left under **No area**, and no **Old roadmaps** line should be printed.
