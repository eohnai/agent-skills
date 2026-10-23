---
name: how
description: Use when the user asks how a subsystem, feature, or flow in a codebase works, wants a walkthrough before changing it, or asks where some code should live or which module owns it.
---

# How

## Overview

Explain how part of a codebase works, so the user can start working in it. Aim for a working mental model: the parts, the flow between them, and where each part lives. Don't annotate the source line by line.

If the user wants a bug, error, or review comment explained, that is `explain-issue`. If they want to know what a change could break, that is `blast-radius`.

## Steps

1. **Size the question.** If the scope is unclear, state how you read it and start. The user can redirect.
   - **Small:** one module, one utility, or one function. Explore and explain it yourself in one pass. Go to step 4.
   - **Large:** a subsystem across many files or services, a feature that cuts across layers, or a full architecture overview. Go to step 2.

   When in doubt, treat it as small.
2. **Explore in parallel (large only).** Split the question into 2 to 4 angles. Each angle is a separate slice of the subsystem, for example "request entry to the handler", "the data model and storage", "background jobs". Give each angle to its own read-only subagent (in Claude Code, an `Explore` agent), all in one message. Build each prompt from `references/explorer-prompt.md`. If you can't spawn subagents, explore the angles yourself, one at a time.
3. **Combine the findings (large only).** Merge overlapping findings. Where two findings disagree, read the code yourself and settle it. Don't explore again from scratch.
4. **Write the explanation** in the format below.

## Output

Use these sections. Drop any that don't apply.

- **Overview:** 1 or 2 short paragraphs. What it is, what it does, and why it exists. A reader should be able to stop here and know if the rest matters to them.
- **Key concepts:** the types, services, or ideas the rest depends on. Give a short definition of each.
- **How it works:** the longest section. Walk through the flow: what starts it, what happens at each step, where the data goes, and where decisions are made. Name real files and functions with `file:line`. Use prose, not pseudocode, and quote code only when a short snippet makes the point. When several parts talk to each other, add a mermaid diagram. Skip the diagram if the prose already makes the flow clear.
- **Where things live:** a short map of the files and folders someone needs to start working here.
- **Gotchas:** surprising behavior, history, and easy mistakes. Skip it if there is nothing worth saying.
- **Open questions:** what you couldn't trace. Say so instead of guessing.

For a "where should this live" question, lead with the answer and the rule behind it. An example: "In `api/`, because every route handler lives there and calls into `services/`." Then give only the sections that support it.

## Common mistakes

- Listing every function and constant. That is reference, not an explanation.
- Abstract wording ("the service delegates to the client") where a concrete one exists ("`UserService.login` calls `AuthClient.refresh`").
- Padding a simple thing, or describing a complex thing without saying why it is complex.
- Hiding gaps. If you didn't trace a path, say so.
- Spawning explorers for a question that one pass can answer.

Adapted from the `how` skill in [pstack](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan, MIT license (see `LICENSE`).
