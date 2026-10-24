# Splitting work into specs

Read this when the Done-when checks fall into more than one group (see **Is it one feature?** in `SKILL.md`), or when an existing spec holds more than one feature.

## 1. Write a roadmap

Big work gets one roadmap file, `notes/<area>-roadmap.md`. It lists the slices in order. A slice is one future spec. The roadmap is not a spec, so use plain `-` bullets and never `- [ ]`. A slice has a spec once `specs/<slice>.md` exists, so the roadmap doesn't record that.

```markdown
# Booking roadmap

## Shared context
- Team specs: `cs302-ops`, branch `docs/redesign-specs`, folder `docs/spec/`
- Questions for the team: ...

## Slices
- `booking-scaffold`: TypeScript skeleton, schema, and a green pipeline.
- `booking-requests`: a client requests a trainer, and the trainer accepts or declines. Needs: booking-scaffold.
- `booking-sessions`: either side cancels a session, and staff end an engagement. Needs: booking-requests.
```

Keep each slice line in this exact shape: `` - `<slice>`: <what it does>. ``, under the `## Slices` heading. The `progress` script reads these lines and shows each slice that has no spec yet.

Context that several specs share goes under **Shared context** once. Examples are links to team documents and questions for the team. Each spec links to the roadmap instead of copying it.

## 2. Find the slices

1. Start from the groups of Done-when checks. Each group is a candidate slice. Describe it by what someone can do ("a client requests a trainer").
2. Split by what someone can do, not by layer (database, API, UI). A layer can't be checked on its own. Each slice cuts a thin path through every layer it needs. Split by layer only when different people or repos own the layers.
3. If a group can't be merged on its own, join it to the slice it depends on. If a slice would need more than about 8 tasks, split it.
4. Setup that every slice needs (a scaffold, a schema, CI) gets its own first slice if it takes more than one task. Otherwise it goes into the first task that needs it.
5. Order the slices. When a slice can't start until another one merges, give it `Needs: <slice>`.
6. Name each slice `<area>-<feature>`, for example `booking-requests`. The spec file is `specs/booking-requests.md`, and the branch is `feat/booking-requests`.

## 3. Make the first feature slice a tracer bullet

The first feature slice is the thinnest path that works end to end, checked on the real thing. For booking, that is one client requesting one trainer and seeing the request, before any decline, expiry, or race handling. It proves that the parts connect before later slices build on them. Later slices widen the path.

## 4. Write specs only for slices you can describe now

Write a full spec for the first slice, and for any other slice whose Done-when checks you can already state. Leave the rest as one line in the roadmap. When a slice merges, running `plan-feature` again writes the next spec from what the code shows then. If the work is already fully described (for example, a team document defines every endpoint), write all the specs now.

## 5. Wide refactors: expand, migrate, contract

A wide refactor is one mechanical change that reaches many callers at once, such as renaming a column or changing a shared type. No feature slice can include it and still keep the tests passing. Do it in three steps instead:

1. **Expand:** add the new form beside the old one, so nothing breaks.
2. **Migrate:** move the callers to the new form in batches, for example one module or folder at a time. Each batch is a task, and the tests pass after each one.
3. **Contract:** delete the old form once no caller uses it.

Put these steps in a spec of their own, or make them the first tasks of the spec that needs the change.

## Splitting an existing spec

Write the roadmap first, then sort the spec's tasks into the new slices. Move each task, ticked or not, to the spec it belongs to, with its `@owner` and `(blocked: reason)`. Copy the old `Due:` line to each new spec, unless the user gives a different date. A slice with only ticked tasks still gets a spec, so `progress` shows it as done. Ask the user before you delete or rename the old file, because its branch may still be open.
