# Report format

Return one Markdown report in the conversation. Do not create a report file
unless the user explicitly asks for one.

Refer to skills by directory name. When names collide, append the relative
path. Scanner skill IDs and finding IDs stay internal: never show them in the
report, the confirmation prompt, or fix results.

## 1. Summary

- target directory
- total skills found, and counts per category
- how many have name, structural, invocation, or description findings
- how many are already compliant
- files that could not be parsed
- overlapping skills: pairs or groups whose descriptions would match the same request

## 2. Per-skill details

One subsection per skill, including clean ones. Heading: the skill name, then
its category and overall status. Keep the skill's inventory and all of its
recommendations together.

### Current state

| Check | Current state |
| --- | --- |
| Name | Directory, frontmatter `name`, and Codex `display_name` (or "no openai.yaml") |
| Claude policy | `disable-model-invocation` value, or `unset (implicit)` |
| Codex policy | `allow_implicit_invocation` value, `unset (implicit)`, or "no openai.yaml" |
| Description | Status, length, and length band, e.g. `ok (128, recommended)` or `rewrite (612, over_limit)` |

### Recommendations

One row per independently confirmable change, with a readable label such as
`Frontmatter name`, `Invocation policy`, or `Description`. For a clean skill,
say no changes are recommended and omit the table.

| Change item | Current | Recommendation | Reason | Confidence |
| --- | --- | --- | --- | --- |

- **Description:** put the full replacement in Recommendation, confirm it
  starts with `Use when ` and is 50–300 characters, and state its length.
- **Invocation:** show both target values:

  ```text
  Claude disable-model-invocation: <true|false>
  Codex allow_implicit_invocation: <false|true>
  ```

- **Name:** use the directory name as the exact recommendation. Keep
  frontmatter `name` and `display_name` as separate items.

Explain structural issues (invalid YAML, missing fields, Claude/Codex policy
conflicts) inside the affected skill's subsection, separating structural
evidence from your own judgment.

### Example

#### resume-formatter

career · **1 change recommended**

| Check | Current state |
| --- | --- |
| Name | `resume-formatter` everywhere; no openai.yaml |
| Claude policy | `unset (implicit)` |
| Codex policy | no openai.yaml |
| Description | rewrite (65, recommended) |

| Change item | Current | Recommendation | Reason | Confidence |
| --- | --- | --- | --- | --- |
| Description | `Ensure ATS-friendly formatting and create clean scannable layouts` | `Use when the user wants a resume's layout and formatting made clean and ATS-friendly; not for keyword matching against a job posting (use resume-ats-optimizer)` (156) | Says what, not when; overlaps with resume-ats-optimizer on "ATS" | high |

## 3. Confirmation

End with a short prompt using the real skill names and change labels, e.g.:

> No files have been changed. Reply with "apply the description for
> resume-formatter", "apply all for resume-formatter", or "apply everything".

Silence, general agreement, a bare skill name, or a request for more
explanation is not permission to edit. If a selection is ambiguous, ask.

## Fix results

Group by skill using the same names and labels as the audit. Report applied,
skipped, and unresolved items with reasons. Don't apply anything extra.
