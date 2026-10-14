# Measurability Engine — turning fuzzy aims into countable finish lines

The single hardest and most valuable move in writing a goal: convert "I want it good" into "done = this number / this count / this list is satisfied." Use this when filling the DONE WHEN criteria of the goal block.

## Completion-state families

Pick the family that fits the aim. Each maps to a concrete DONE WHEN criterion and a check command (and the check must print its evidence into the conversation — see `goal-anatomy.md`).

| Family | Example finish line | How it's proven (surface in transcript) |
|---|---|---|
| Test / coverage | ≥90% of unit cases pass; coverage ≥80%; `test/auth` all green | run the suite, print pass/fail counts |
| Build / static | exit 0; 0 type errors; 0 lint warnings | run the command, print exit code |
| Count / threshold | p95 < 120 ms; bundle < 200 kb; 0 `grep` hits | run benchmark / grep, print the number |
| Queue empty | issue backlog empty; every checklist item checked | list remaining items, show count → 0 |
| Equivalence / snapshot | output visually identical; snapshot match; contract tests pass | run diff / snapshot, print result |
| Checklist coverage | covers all N items in a reference list; each section ≥ X instances | per-item checklist table with evidence |
| Rubric score | LLM-judge ≥ 8/10 on a fixed rubric; multi-dim average ≥ 90 with a floor | print the scorecard, one evidence quote per score |
| Graded tiers | every target classified confirmed / approximate / blocked / uncertain | running ledger: target → tier → evidence pointer |

## When the aim is genuinely subjective (quality, depth, "as good as X")

The docs are blunt: don't use a goal to hide uncertainty — *"explicitly define evidence allowances."* Three techniques, in order of preference:

1. **Countable proxy.** Replace "covers the domain well" with "uses all 12 terms in `terms.txt`" and "each H2 section has ≥ 3 concrete examples." Counts are auditable; adjectives are not.
2. **Frozen rubric.** When you truly need a quality judgment, write the rubric *before* starting — dimensions plus anchored descriptors for what each score means — and make "rubric unchanged" itself a success criterion, so the agent can't quietly loosen the bar to flatter itself.
3. **Graded tiers.** When success may be unprovable (research, reproduction), the finish line is *coverage + honest classification*, not *achievement*: "done = every target attempted and sorted into confirmed / approximate / blocked / uncertain, with a report." This lets the run terminate truthfully instead of faking success or thrashing forever.

## Two traps specific to score / rubric goals

- **Average gaming.** "Average ≥ 90" lets the agent push easy dimensions to 100 and abandon a hard one at 70. Add a per-dimension floor ("and every dimension ≥ 85").
- **Self-judging conflict.** The writer scoring its own work inflates. Require **one evidence quote per score** (puts the judgment on the record), and for high stakes run a separate fresh-context judge turn rather than letting the writer grade itself.

## Always pair the finish line with a stop bound

Measurable ≠ reachable. Some criteria turn out impossible — a flaky third-party stub, a hyperparameter the paper never published. Every goal needs, alongside its DONE WHEN criteria:

- a **hard bound** — turns / time / budget, whichever comes first;
- an **escape hatch** — "if X hasn't improved in K turns, stop and report", or "mark blocked and move to the next target".

Otherwise a measurable-but-unreachable target quietly burns hours. The bound and the hatch are not pessimism; they are what makes an autonomous run safe to walk away from.
