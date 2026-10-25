# Finishing a spec

Read this when a spec's last task is ticked and its checks passed (step 7 of `SKILL.md`).

## 1. Close the spec on its branch

Edit the spec so it says it's done, as the last commit on the spec's branch. Then `main` shows the spec as done exactly when the branch merges, and the results stay in the repo for reports.

- Add `Status: done` to the header lines, under the title.
- Add a **Results** section after **Verify**, with what step 7 ran:

  ```markdown
  ## Results
  Checked 2026-10-25 on `feat/booking-requests` at `4c95eb7`.
  - `npm test`: 42 passed, 0 failed
  - "A client sees the request": `npx playwright test s1-book` passed
  - Not run here: the deploy check, because it needs the production environment
  ```

Use plain `-` bullets, never `- [ ]`, because the `progress` script counts those as tasks.

Give the commands to commit it on its own:

```bash
git add docs/specs/booking-requests.md
git commit -m "docs: mark booking-requests done with its check results"
```

If the review asks for changes, run the checks again after them and update **Results**.

If the records aren't in the repo that has the branch (a workspace with its records at the root), the spec can't merge with the code. Add both edits once the user says the merge request has merged.

## 2. Draft the merge request

Draft it in the chat for the user to open. Don't open it yourself.

- **Source and target:** the spec's branch, into the default branch. If the branch is stacked on a `Needs:` spec that hasn't merged, target that spec's branch and say it must merge first.
- **Title:** `feat: <the spec's goal in a few words>`, or the type that fits the spec better.
- **Description**, in this order:
  - **Goal:** one or two sentences from the spec.
  - **Changes:** one line per ticked task.
  - **How it was checked:** the spec's **Results**.
  - **Decisions:** the spec's Decisions and My calls, so the reviewer sees the choices without opening the spec.
  - **Not in this change:** the spec's Out of scope, in one line.

If the repo is on GitLab and the user wants a command, **REQUIRED:** use `glab` to give them the `glab mr create` command.
