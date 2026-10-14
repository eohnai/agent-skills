# Description rules

A compliant description states when a real user needs the skill. It does not
summarize the skill's internal workflow.

## Mechanical rules

1. Start exactly with `Use when `, including the trailing space.
2. Keep the entire description at 500 Unicode characters or fewer. This is the
   hard limit.
3. Aim for 50–300 Unicode characters. Every replacement you propose must land
   in this range.
4. Count every Unicode character as one, including the prefix, spaces, and
   punctuation.
5. Write descriptions in English.

## Length range

The recommended range guides rewrites; falling outside it is not a finding by
itself. The scanner's `description_length_band` shows where each value falls:
`below_recommended`, `recommended`, `above_recommended`, or `over_limit`.

- Below 50 characters, a description often names the intent but omits the
  object or situation that separates it from neighboring skills. Recommend a
  rewrite only when that distinction is actually missing; a short description
  that is already unambiguous stays compliant.
- Above 300 characters, a description usually drifts into workflow steps,
  capability lists, or tool inventories. Recommend a rewrite when removing
  that detail keeps the same intent boundary.
- Above 500 characters, the description is non-compliant and needs a
  replacement.

## Content rules

- Describe a user intent recognizable from a real request.
- Name the object or situation that distinguishes the skill from neighbors.
- Prefer one intent boundary over a list of capabilities.
- Spend extra length on distinguishing detail, such as the objects involved or
  a short "not for" boundary against a competing skill.
- Do not describe scanning, parsing, calling tools, generating intermediate
  files, asking questions, validating steps, or other workflow details.
- Do not use marketing claims, implementation details, tool inventories, or
  broad phrases such as "for any task".

## Overlapping skills

When two skills would both match the same request (for example, two résumé
skills that both handle "ATS formatting"), give each description a boundary
that names what it does not cover and which skill does:

```yaml
description: "Use when the user wants a resume's layout and formatting made ATS-friendly; not for keyword matching against a job posting (use resume-ats-optimizer)"
```

## Recommended forms

```yaml
description: "Use when the user wants to compare job offers side by side, including salary, equity, benefits, and total compensation"
description: "Use when the user wants to audit a directory of agent skills for name, invocation-policy, or description problems"
```

## Non-compliant forms

```yaml
# Describes what the skill does, not when to use it.
description: "Format CVs for academic positions with publications, grants, and teaching"

# Describes workflow rather than intent.
description: "Use when scanning the calendar, parsing attendees, and calling the API to create a meeting"
```

## Rewriting discipline

Preserve the original intent. When a description is too long, shorten it by
removing workflow and implementation detail. When it is too short to
distinguish the skill, add only detail the skill body supports; never widen
the trigger just to reach the recommended length. When the original is
ambiguous, report that ambiguity and lower confidence instead of producing a
confident but speculative replacement.
