---
name: update-portfolio
description: Use when a school, personal, or team project is finished or reaches a showable milestone, when an internship or job ends, or when the user wants their resume or personal website updated with a project or role.
---

# Update Portfolio

## Overview

Turn a finished project or role into website content and resume bullets, grounded in what was actually built. The website's YAML is the fact bank; resume bullets are condensed from it, so the two never disagree.

This runs per project or role, not per feature. A feature only gets in if it changes what the project is.

## Where things live

| What | Where |
|---|---|
| Fact bank: projects | `~/Projects/personal-website/src/content/projects.yaml` (`hidden: true` = stored, not shown) |
| Fact bank: jobs | `~/Projects/personal-website/src/content/experiences.yaml` (`exits[].points` are the resume bullets) |
| What the site must not claim | `~/Projects/personal-website/PRODUCT.md` |
| Resume, master | `~/Projects/resume/resume.tex` |
| Resume, variants | `~/Projects/resume/resume-variants/<variant>/resume.tex` (full copies, not shared) |

If a path is missing, ask where it moved; don't recreate it.

## Scope by kind of work

- **School or personal project:** the whole project. If it's a team project, describe the project, but say "built" only for parts the user built; check `git log --author` and ask.
- **Internship or job:** only the user's own work, never the whole product. Add it as an exit on the role in `experiences.yaml`, with a `projects.yaml` entry that has `experience: <role-id>`. Disclose no more than the user approves: no internal names, unreleased features, or figures they haven't cleared.

## Steps

1. **Gather facts** from the source project: its records (`STATUS.md`, `decisions/`, `specs/`, `reports/`), README, git log, and code. For a job, ask the user for what they did and what's cleared; there may be no repo.
2. **Ground every claim.** Same rules as `draft-report`: code wins over plans, and numbers come only from a recorded verification, a file in the repo, or a command you run now. Otherwise ask, or leave the number out. Never estimate a metric.
3. **Draft the fact bank entry** in the file's existing shape: `summary`, `description` points, `tech`, `line`, dates as `YYYY-MM` (`end: null` if ongoing). Update the entry if one already exists.
4. **Draft 2–3 resume bullets** condensed from it, matching the current resume: start with a verb, name the stack, end with the result or scale.
5. **Propose placement.** For the master and each variant, say whether the bullets go in and why (the variant's focus). The resume is one page: name the project each addition replaces. Replaced projects are commented out, not deleted, as the resume already does.
6. **Flag a case study** if the project has depth the resume can't show (an architecture, a hard trade-off, measured results). Don't write it here.
7. **Show the drafts and placement, and wait for approval.** Then edit only what was approved.
8. **Verify:**
   - Resume: `./gen.sh` in the resume repo, then `pdfinfo` on each built PDF to confirm `Pages: 1`.
   - Website: `pnpm check && pnpm build && pnpm test` in the website repo; the build validates the YAML against the schemas.

   Show the results. If a resume runs to two pages, propose what to trim; don't shrink the font or margins.
9. **Hand off.** List changed files in both repos for the user to review and commit.

## Common mistakes

- Adding every feature as it ships. Wait for the project or a milestone worth showing.
- Writing the resume bullet first and the fact bank second, so they drift.
- Claiming team work as solo work, or employer work beyond what's cleared.
- Updating the master resume and forgetting the variants.

Do not commit; the user commits.
