# Worked examples

Four filled-in goals, one per completion-state family in `measurability.md`. Use them as patterns, not text to copy: the numbers, commands, and paths must come from the user's real task. Each goal file is the paste block followed by supporting detail; the matching `-log.md` comes from `assets/goal-log-template.md`.

| Example | Family | What it stresses |
|---|---|---|
| A. Code migration | test % + exit code + grep count | the basic loop, and "don't change the tests" |
| B. Match a reference document | checklist coverage + instance count | turning subjective quality into countable proxies |
| C. Multi-dimension score | rubric average + per-dimension floor | anti-gaming and anti self-inflation |
| D. Reproduce a paper | graded tiers | goals that may not be fully achievable |

---

## A. Code migration: tests at least 90% passing

The interesting design work is in the constraints: "make the tests green" must not turn into "edit the tests".

`goals/payments-fetchclient.md`:

````markdown
GOAL: Migrate src/payments from httpClient to fetchClient.

DONE WHEN all of these hold, shown by command output printed in this conversation:
1. `pnpm test src/payments` → at least 193 of 214 cases pass (≥90%; currently 0)
2. `grep -rn httpClient src/payments` → no output
3. `pnpm tsc --noEmit; echo $?` → 0

EVERY TURN: run the three checks, print their output, state which criteria pass and which fail, and append one row to goals/payments-fetchclient-log.md (turn number, time, criteria passing, what changed). If the log already has rows, continue its numbering.

CONSTRAINTS:
- Only change: src/payments/**
- Do not edit any *.test.ts file, and do not skip or delete failing cases (.skip counts as failing).
- No commits or pushes. No new dependencies.

STOP AND REPORT (do not keep trying) IF:
- 25 turns have passed
- the same failing case survives 3 turns with no new approach (paste its error and your diagnosis)
- the remaining failures are third-party stub issues outside src/payments (list them as blockers)

ON FINISH OR STOP: set the log's Status to done, stopped, or blocked and fill in its Final result; run the checkpoint skill to update STATUS.md; then summarize what passed, what didn't, and why, and list the changed files for the user to review and commit.

---

## Context (read first)
- docs/decisions/0007-use-fetchclient.md (why we're migrating)
- src/core/fetchClient.ts (the target API)
````

---

## B. Match a reference document's quality

"As good as reference-B" is an adjective. The whole value is in breaking it into things that can be counted.

`goals/rewrite-draft-a.md`:

````markdown
GOAL: Rewrite draft-A.md to the quality bar of reference-B.md without changing A's structure.

DONE WHEN all of these hold, shown by output printed in this conversation:
1. All 12 terms in terms.txt are used substantively in draft-A.md → print a 12-row checklist, quoting one line per term
2. Every H2 section has at least 3 concrete examples (code, numbers, or scenarios) → print a "section → example count" table
3. `grep -nE "TODO|TBD|FIXME" draft-A.md` → no output

EVERY TURN: print the checklist, the table, and the grep output, state which criteria pass and which fail, and append one row to goals/rewrite-draft-a-log.md (turn number, time, criteria passing, what changed). If the log already has rows, continue its numbering.

CONSTRAINTS:
- Only change: draft-A.md
- Keep A's H2 headings and their order. reference-B.md is read-only.
- Do not invent facts that aren't in B or the sources to satisfy a term. Do not pad with filler.
- No commits or pushes.

STOP AND REPORT (do not keep trying) IF:
- 15 turns have passed
- a term is genuinely irrelevant to A's topic (mark it blocked with the reason instead of forcing it)

ON FINISH OR STOP: set the log's Status to done, stopped, or blocked and fill in its Final result; run the checkpoint skill to update STATUS.md; then summarize what passed, what didn't, and why, and list the changed files for the user to review and commit.

---

## Context (read first)
- reference-B.md (the quality benchmark)
- terms.txt (if missing, extract the 12 key terms from B on turn 1 and save them before editing A)
````

---

## C. Raise a multi-dimension score above 90 without lopsiding

Two traps unique to score goals: **average gaming** (push easy dimensions to 100, abandon a hard one) and **self-inflation** (the writer grading itself generously). The per-dimension floor and "one evidence quote per score" defend against both. The rubric is frozen before the run starts.

`goals/polish-essay.md`:

````markdown
GOAL: Raise essay.md to an average of at least 90/100 across the 5 rubric dimensions below, with no dimension under 85.

RUBRIC (fixed; do not change):
- Expertise: terms used correctly, claims grounded
- Depth: covers mechanisms, trade-offs, and edge cases, not just definitions (≥5 such details)
- Structure: clear hierarchy, no repetition, headings match content
- Prose: fluent, no filler or stacked buzzwords
- Accuracy: every checkable fact correct, uncertainties flagged

DONE WHEN all of these hold, shown by output printed in this conversation:
1. Average of the 5 scores ≥ 90
2. Every dimension ≥ 85
3. Accuracy has 0 fabricated facts (any fabrication fails the goal)

EVERY TURN: re-score the whole essay against the rubric and print a scorecard: each dimension, its score, and one quoted line as evidence, then the average. State which criteria pass and which fail, and append one row to goals/polish-essay-log.md (turn number, time, criteria passing, what changed). If the log already has rows, continue its numbering.

CONSTRAINTS:
- Only change: essay.md
- Do not change the rubric. Do not invent facts to gain points; flag uncertainty instead.
- Do not delete correct information to make the prose smoother.
- No commits or pushes.

STOP AND REPORT (do not keep trying) IF:
- 20 turns have passed
- the lowest dimension doesn't improve for 3 turns (report which one and why: missing material, or conflicting requirements?)

ON FINISH OR STOP: set the log's Status to done, stopped, or blocked and fill in its Final result; run the checkpoint skill to update STATUS.md; then summarize what passed, what didn't, and why, and list the changed files for the user to review and commit.
````

---

## D. Reproduce a paper's results (graded tiers)

Here "done" is not "everything reproduced". Forcing that on a research task pushes the agent to fake success or thrash forever. Done means every target was attempted and honestly sorted into a tier, with evidence.

`goals/reproduce-paper.md`:

````markdown
GOAL: Attempt every headline result in paper/deep-hedging.pdf listed under TARGETS and classify each one honestly.

TARGETS:
1. Table 2 hedging PnL mean: reported -0.012; confirmed if relative error ≤ 10%
2. Figure 3 convergence: ~3k epochs; confirmed if same order of magnitude
3. ...

TIERS:
- confirmed: reproduced value compared numerically to the paper, within threshold
- approximate: trend or magnitude matches but not within threshold (state the likely cause)
- blocked: missing data, hyperparameter, or compute (state what's missing)
- uncertain: ran, but correctness can't be judged (state why)

DONE WHEN all of these hold, shown by output printed in this conversation:
1. Every target has exactly one tier → print "classified k / N" and the unclassified list
2. Every "confirmed" shows paper value, reproduced value, and relative error
3. REPORT.md has four sections (one per tier), each entry with an evidence pointer (script, output file, or figure)

EVERY TURN: print the results ledger (target → tier → evidence), state which criteria pass and which fail, and append one row to goals/reproduce-paper-log.md (turn number, time, criteria passing, what changed). If the log already has rows, continue its numbering.

CONSTRAINTS:
- Only change: repro/** and REPORT.md. paper/ and data/ are read-only.
- Never mark a result confirmed without a numeric comparison. Never skip a hard target; mark it blocked instead.
- No commits or pushes.

STOP AND REPORT (do not keep trying) IF:
- 60 turns or 8 hours have passed
- one target stalls for 4 turns (mark it blocked with the reason and move to the next one)

ON FINISH OR STOP: set the log's Status to done, stopped, or blocked and fill in its Final result; run the checkpoint skill to update STATUS.md; then summarize what passed, what didn't, and why, and list the changed files for the user to review and commit. A complete tiered report is a valid finish even if few results are confirmed.

---

## Context (read first)
- paper/deep-hedging.pdf (source of truth for results and method)
- repro/README.md (existing setup)
````
