# Splitting work into specs

Read this when the Done-when checks fall into more than one group (see **Is it one feature?** in `SKILL.md`), or when an existing spec holds more than one feature.

## 1. List the specs in the area file

The new specs go in the area file's **Specs** list, `specs/<area>/area.md`, in build order (see `area-template.md`). A line with no spec file yet is a planned spec. The board shows it as `no spec yet`.

If the work spans several services or workstreams, each one is its own area with its own area file. Split by area first, then into specs inside each area.

## 2. Find the specs

1. Start from the groups of Done-when checks. Each group is a candidate spec. Describe it by what someone can do ("a client requests a trainer").
2. Split by what someone can do, not by layer (database, API, UI). A layer can't be checked on its own. Each spec cuts a thin path, a vertical slice, through every layer it needs. Split by layer only when different people or repos own the layers.
3. If a group can't be merged on its own, join it to the spec it depends on. If a spec would need more than about 8 tasks, split it.
4. Setup that every spec needs (a scaffold, a schema, CI) gets its own first spec if it takes more than one task. Otherwise it goes into the first task that needs it.
5. Order the specs. When a spec can't start until another one merges, give it `Needs: <feature>`, or `Needs: <area>/<feature>` for a spec in another area.
6. Name each spec after what it does, for example `requests` in the `booking` area. The spec file is `specs/booking/requests.md`, and the branch is `feat/booking-requests`.

## 3. Make the first feature spec a tracer bullet

The first feature spec is the thinnest path that works end to end, checked on the real thing. For booking, that is one client requesting one trainer and seeing the request, before any decline, expiry, or race handling. It proves that the parts connect before later specs build on them. Later specs widen the path.

## 4. Write specs only when you can describe them now

Write a full spec for the first one, and for any other whose Done-when checks you can already state. Leave the rest as one line in the area file. When a spec merges, running `plan-feature` again writes the next spec from what the code shows then. If the work is already fully described (for example, a team document defines every endpoint), write all the specs now.

## 5. Wide refactors: expand, migrate, contract

A wide refactor is one mechanical change that reaches many callers at once, such as renaming a column or changing a shared type. No feature spec can include it and still keep the tests passing. Do it in three steps instead:

1. **Expand:** add the new form beside the old one, so nothing breaks.
2. **Migrate:** move the callers to the new form in batches, for example one module or folder at a time. Each batch is a task, and the tests pass after each one.
3. **Contract:** delete the old form once no caller uses it.

Put these steps in a spec of their own, or make them the first tasks of the spec that needs the change.

## Splitting an existing spec

Add the new specs to the area file first, then sort the spec's tasks into them. Move each task, ticked or not, to the spec it belongs to, with its `@owner` and `(blocked: reason)`. Copy the old `Due:` line to each new spec, unless the user gives a different date. A new spec with only ticked tasks still gets a file, so `progress` shows it as done. Ask the user before you delete or rename the old file, because its branch may still be open.
