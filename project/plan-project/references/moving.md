# Moving specs into areas

Read this when specs sit directly in `specs/`, or the project has old `notes/<area>-roadmap.md` files.

1. Propose the areas and which specs go in each. Base them on what each spec changes. Old spec names often start with the area (`booking-requests` → area `booking`). Ask the user to confirm. Ask before you move anything, because open branches and teammates may use the old paths.
2. For each old roadmap, create `specs/<area>/area.md` from it (see `area-template.md`). Rename `## Slices` to `## Specs`, and drop the area from each name (`` `booking-requests` `` → `` `requests` ``). Add a first paragraph that says what the area owns. For an area with no roadmap, write the area file from the template, and list its specs in the order they were built.
3. Move each spec with `git mv`, and drop the area from its file name (`specs/booking-requests.md` → `specs/booking/requests.md`). Its branch name stays the same: `feat/booking-requests`.
4. Update every `Needs:` line. Use `<feature>` for a spec in the same area, or `<area>/<feature>` for a spec in another area.
5. Delete the old roadmap files, and fix links to the old paths (`grep -rn "notes/.*-roadmap\|specs/<old-name>"`).
6. Run the `progress` script. No spec should be left under **No area**, and no **Old roadmaps** line should be printed.
