# Goal Anatomy — what a good `/goal` is made of

Synthesized from the three official docs:

- Claude Code `/goal`: https://code.claude.com/docs/en/goal
- Codex follow-goals: https://developers.openai.com/codex/use-cases/follow-goals
- Codex cookbook: https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex

## The five parts

All three docs describe the same skeleton — the cookbook compresses it to three elements, Claude Code lists three properties, Codex follow-goals asks four questions. Merged, a durable goal has:

1. **Outcome** — one sentence: what is true when complete. *(cookbook: "what should be true when complete"; follow-goals: "What Codex should achieve")*
2. **Measurable end state** — the quantified finish line. Claude Code, verbatim: *"One measurable end state: a test result, a build exit code, a file count, an empty queue."* follow-goals: define *"what done means before it starts."*
3. **Verification surface** — the test / benchmark / artifact that proves it, and how the agent proves it. Claude Code: *"A stated check: how Claude should prove it, such as `npm test` exits 0 or `git status` is clean."*
4. **Constraints** — what must not change or regress on the way there. Claude Code: *"anything that must not change … such as no other test file is modified."*
5. **Stop condition** — when to stop. Claude Code: *"include a turn or time clause … such as `or stop after 20 turns`."* follow-goals: *"When to stop."*

follow-goals gives a one-line template that strings ①→⑤ together:

> `/goal Complete [objective] without stopping until [verifiable end state]`

…then point the agent toward supporting materials (files, docs, logs, plans). Sizing rule: a goal is *"bigger than one prompt but smaller than an open-ended backlog."*

## The asymmetry you must design around

Claude Code `/goal` is a wrapper around a session-scoped prompt-based Stop hook. After each turn the condition + conversation go to a small fast model (default Haiku), which returns yes/no plus a short reason. The reason for a "no" becomes guidance for the next turn. Crucially:

> "The evaluator judges your condition against what Claude has surfaced in the conversation. It doesn't run commands or read files independently, so write the condition as something Claude's own output can demonstrate."

Consequences for how you write the goal:

- The measurable criteria must live in the **condition string** (≤ 4,000 chars), not only in the saved `goals/<topic>.md` file — the evaluator never opens the file.
- Verification evidence must be **printed into the conversation every turn** (run the command, show the output).
- Bound the run **inside the condition** (`or stop after N turns`).

Codex is more autonomous: it *"works in checkpoints with progress logs"* and *"stops when confident the stopping condition is met"*, and it **can** read supporting files. But writing the goal so evidence surfaces every turn also serves Codex (it makes progress auditable), so **design for the Claude constraint and both are covered**.

## From weak to strong (cookbook)

- ❌ Weak: `Improve performance`
- ✅ Strong: `Reduce p95 checkout latency below 120 ms on the checkout benchmark while keeping the correctness test suite green` — threshold + benchmark + regression guard.
- ✅✅ Enhanced: add **scope** (*"Use only the checkout service, benchmark fixtures, and related tests"*) and an **iteration log** (*"record what changed, what the benchmark showed, and the next best experiment to try"*).

## Do / Don't (straight from the docs)

**Do**
- Define a tight contract / *"evidence standards before investigation begins"* — fix the bar before you start.
- Be *"specific enough to audit, broad enough to enable discovery"* of next steps.
- Use the two-step workflow: *"ask Codex to draft a Goal, then tighten before activating."*
- For research, separate completion levels: *"confirmed findings, approximate reconstructions, blocked claims, and remaining uncertainty."*
- Progress reports should name *"checkpoints, verified items, remaining work, and blockers."*

**Don't**
- Vague finish lines: *"make this better without measurable targets."*
- One-line edits or quick questions — use a normal prompt instead.
- *"Using Goals to obscure uncertainty — instead, explicitly define evidence allowances."*

## The essence

A prompt is `ask → work → result → wait`. A goal is `work → check → continue or complete`. Parts ②③⑤ — **measurable + provable + stop** — are the engine that lets it self-drive. Drop any one and the loop either never terminates or terminates on a lie.
