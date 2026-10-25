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
