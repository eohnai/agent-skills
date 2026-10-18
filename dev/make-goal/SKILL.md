---
name: make-goal
description: Use when the user wants to set up a /goal, a long-running or unattended agent task, or a multi-turn grind (fix all failing tests, migrate a module, clear a backlog), or wants a fuzzy aim turned into a measurable finish line with a stop limit.
---

# Make Goal

## Overview

A long-running goal is only as good as its finish line. A vague goal never stops or stops at junk; a bounded, countable one runs unattended and lands where intended. Produce one self-contained goal block the user pastes after `/goal`, plus a log file the run writes to each turn.

In Claude Code, `/goal` completion is judged by a small model that sees only the conversation, never files. So the block must contain every criterion itself, and the agent must print its proof into the conversation each turn. Codex can read files, but designing for Claude's constraint serves both. Details: `references/goal-anatomy.md`.

## Steps

1. **Anchor.** Read the conversation, STATUS.md, and any relevant spec. Don't re-ask what's already known.
2. **Ask only what's missing**, one question at a time, offering concrete options:
   - **Done = what count?** A number, exit code, or checklist. If the aim is subjective ("good", "as deep as X"), read `references/measurability.md` and use a countable proxy, a frozen rubric, or graded tiers.
   - **Proved how?** The exact command that shows it.
   - **Limit?** Default by size: small 15 turns, medium 30, never more than 60 without the user's explicit say-so. Also: stop after the same failure 3 turns running.
3. **Right-size.** One objective, one finish line. If the aim is a whole project, split it and make the goal the first piece.
4. **Write two files** in `goals/` inside the records folder (`./` if `./STATUS.md` exists, else `docs/`):
   - `goals/<topic>.md`: the goal block (template below) followed by any supporting detail (rubric, target list, context to read).
   - `goals/<topic>-log.md`: copied from `assets/goal-log-template.md` with the header filled in.

   `<topic>` is a short kebab-case name, e.g. `fix-payment-tests`. For worked examples of each kind of goal, read `references/examples.md`.
5. **Check the block** is under 4000 characters and contains every criterion, constraint, and limit. Anything only in the file below it is invisible to the checker.
6. **Hand off:** show the block in the chat and tell the user to paste it after `/goal`.

## Goal block template

```text
GOAL: <one-line outcome>

DONE WHEN all of these hold, shown by command output printed in this conversation:
1. `<command>` → <exact pass condition, e.g. "0 failed, ≥42 passed">
2. ...

EVERY TURN: run the check commands, print their output, state which criteria pass and which fail, and append one row to goals/<topic>-log.md (turn number, time, criteria passing, what changed). If the log already has rows, continue its numbering.

CONSTRAINTS:
- Only change: <files/folders in scope>
- Do not edit tests, check scripts, or rubric to make them pass.
- No commits or pushes. No new dependencies unless <condition>.

STOP AND REPORT (do not keep trying) IF:
- <N> turns have passed
- the same criterion fails 3 turns in a row with no new approach
- blocked on: <missing access, a decision only the user can make, an ambiguous spec>

ON FINISH OR STOP: set the log's Status to done, stopped, or blocked and fill in its Final result; run the checkpoint skill to update STATUS.md; then summarize what passed, what didn't, and why, and give the git add and git commit -m "<type>: <summary>" commands for the user to review and run.
```

## Why the log

The conversation shows proof turn by turn, but it doesn't survive a crash, a limit, or a new session. The log does: a resumed run reads it, continues the numbering, and skips work already verified. It also leaves a record of what was tried, which is useful for reports.

## Common mistakes

- "Tests pass" with no command and no count. The checker can't verify it.
- Criteria that live only in the saved file, not in the pasted block.
- No turn limit, or no "stop if blocked" exit, so one impossible criterion burns hours.
- Letting the agent edit the check it is measured by.
- An average score with no per-item floor, so easy items get pushed to 100 while a hard one is abandoned.
