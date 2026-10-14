---
name: skills-lint
description: Use when the user wants to audit their agent skills for name mismatches, invocation-policy problems, or weak or overlapping descriptions, or to check whether skills trigger at the right time.
disable-model-invocation: true
---

# Skills Lint

## Overview

Audit a directory of skills, explain what's wrong, and propose narrowly scoped fixes. The first pass is read-only. Nothing changes until the user confirms specific skills and change items.

## Scope

- Use the directory the user names. If none, the scanner defaults to the agent-skills repo it lives in.
- Inspect every `SKILL.md` below it, plus the adjacent `agents/openai.yaml` when present. That file is optional Codex metadata; its absence is not a finding.
- Report every skill, including ones with no findings.

## Canonical name

The skill's directory name is its canonical name. Frontmatter `name`, and `interface.display_name` in `agents/openai.yaml` if that file exists, must match it exactly. Don't title-case or prettify it.

## Phase 1: read-only audit

1. Run the scanner and treat its JSON as structural evidence:

   ```bash
   ruby <this skill's directory>/scripts/scan_skills.rb [target-directory]
   ```

2. Read `references/invocation-policy.md`, `references/description-rules.md`, and `references/report-format.md`.
3. Group skills by user-facing purpose (the repo's category folders are a good starting point).
4. Decide the right invocation mode for each skill from its description and headings. Read the full `SKILL.md` only when it's still unclear.
5. Check each description against the rules. Propose a replacement for every non-compliant one. Also flag skills whose descriptions overlap so much that the wrong one could be picked.
6. Write the report per `references/report-format.md`, grouped by skill. Keep the scanner's internal IDs out of anything the user sees.
7. End by asking which skills and change items to apply. A skill name alone is not permission to apply all of its suggestions; "apply all for X" or "apply everything" is.

## Phase 2: confirmed fixes

Only after explicit confirmation:

1. Rerun the scanner. If a target changed since the audit, skip it and suggest a fresh audit.
2. Change only the confirmed fields:
   - Name finding: set frontmatter `name` (or `interface.display_name`) to the directory name.
   - Manual-only invocation: Claude `disable-model-invocation: true`; if `agents/openai.yaml` exists or is needed, Codex `policy.allow_implicit_invocation: false`.
   - Implicit invocation: Claude `disable-model-invocation: false` (or remove it); Codex `policy.allow_implicit_invocation: true`.
   - Description finding: replace only the frontmatter `description`.
3. Preserve every other field, file, and instruction. Create `agents/openai.yaml` only when a confirmed fix needs it (a manual-only skill that Codex should also treat as manual-only).

## Verify after fixes

Rerun only the scanner and check that edited YAML parses, confirmed values match the report, edited descriptions start with `Use when ` and are 50–300 characters, and unconfirmed fields are unchanged. Report results per skill as applied, skipped, or unresolved.

Do not commit; the user commits.
