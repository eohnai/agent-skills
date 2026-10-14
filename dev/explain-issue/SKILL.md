---
name: explain-issue
description: Use when the user wants review comments, TA or professor feedback, a confusing bug or error, or an open decision explained in depth, with the root cause, evidence, and a concrete recommended fix.
disable-model-invocation: true
---

# Explain Issue

## Overview

Turn terse or scattered input ("#3 race here", "TA: why does this pass?", a stack trace) into an explanation the user can understand and act on. Establish the facts first, then explain the cause, then recommend a fix. Answer in the chat only; don't write files or change code unless the user asks.

Write for someone who knows the project's purpose but hasn't read the specific code involved.

## Understanding the input

- Accepts a single question, a list of review comments, feedback from a TA or professor, an error message, or an open decision, plus any attached code, docs, or links.
- Use what's already established in the conversation (background, decisions, preferences).
- Split into independent items. Keep the original numbering (`#2`, `#7`); number from 1 if there is none. Shared background is not an item. Don't split one issue into several just to fill a table.
- Ask a short clarifying question only when missing information would change the meaning or the recommendation and you can't find it yourself. Keep working on the parts that don't depend on the answer.

## Checking the facts

Match the depth to the question. A concept question needs the relevant docs. A question about behavior or a proposed code change needs the actual code.

1. **Reconstruct the scenario:** who does what, under which conditions, with what input and state; what was expected and what actually happened.
2. **Trace only the relevant path:** entry point, conditions, where the data or state comes from, what's called next, callbacks and cleanup. Don't turn it into a full codebase audit.
3. **Compare with similar code:** if the project already handles a similar case correctly elsewhere, check how. Similar names alone don't prove it's reusable.
4. **Check what's current:** separate old docs, current code, installed dependency versions, and what was actually run. When they conflict, say so. The code is the truth about what happens; the user's confirmed decisions are the truth about what should happen.
5. **Fix the premise:** if the reported problem has already been fixed, say so first and update the explanation instead of recommending changes for a stale problem.

Label every claim as one of: **verified in code**, **docs say**, **inferred**, or **not verified**. Reading code is not the same as running it. If a source is unavailable, name the missing evidence and narrow the conclusion. Never invent functions, files, versions, or results.

## Explaining the cause and the fix

- Separate the symptom, the root cause, and any real trade-off. The root cause explains *why it happens* and what is actually hard to decide; it must not just repeat the symptom.
- If there is no real dilemma, state the root cause plainly. Don't invent one.
- Lead with the recommended fix, then why, when it applies, and what it costs. Mention an alternative only when it's genuinely worth choosing under some condition.
- Recommend the smallest fix that solves the whole problem. Say what changes where. Avoid vague advice like "refactor the logic" or "handle it consistently".

## Output fields

Use exactly these six fields, in this order:

| Field | Contents |
|---|---|
| **#** | The original number, or 1, 2, 3... |
| **What's happening** | The concrete scenario: what the user did, what they saw, what they expected, and why it matters. |
| **Root cause** | Why it happens, or the real decision to make. Must go one step deeper than "What's happening". |
| **Recommendation** | The recommended fix first, then why, when it applies, its cost, and how to verify it. |
| **Evidence** | What the code, docs, or similar code actually show, and how that supports the conclusion. Label it (verified in code, docs say, inferred, not verified). If there is no evidence, say so. |
| **Where to change** | File and function, with a 1–3 sentence description of each change. For non-code issues, name the doc, setting, or process step. If nothing needs changing, say so. |

### Several items: one table

Use one Markdown table with the six columns, one row per item. Inside cells, use plain sentences, separating sub-points with ①②③. No `<br>`, HTML, lists, or headings inside cells. If one premise affects several items, state it in a short paragraph before the table.

### One item: labeled paragraphs

No table. Use the six bold labels (**#:**, **What's happening:**, ...) as separate paragraphs. Go deeper than a table row: walk through a concrete example of how the problem is triggered, explain the cause and effect, and show how the fix changes the outcome. Length follows complexity. If there are several places to change, a short list is fine.

## Style and references

- Start from the concrete scenario, then introduce terms, and explain each key term in plain words when it first appears. Example: first say "the old request's callback closes the new panel", then explain request identity.
- Reference code as `path/to/file.py:42` or `functionName` in `file.py`. Paths are clickable in the terminal, so keep them.
- Distinguish same-named functions by context ("the frontend's `submitForm`", "the backend's `submitForm`").
- Don't present an old recommendation as the final decision if the user has since decided otherwise.
- If the user only asks for a formatting change, reformat the existing answer without re-investigating.

## Before answering, check

- Could the reader say what happened, why, what's hard about it, what to do, what the evidence is, and where to change it?
- Is it the right mode (table vs. paragraphs), with all six fields in order?
- Is every recommendation backed by evidence, with unknowns marked?
- Do "What's happening" and "Root cause" each add something, and does "Where to change" describe each change?

For calibrated examples of both modes, read `references/output-examples.md`. The examples are fictional; never treat them as facts about a real project.
