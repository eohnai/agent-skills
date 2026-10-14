# Invocation policy

Decide whether a skill should be available for implicit model selection or only
through an explicit user invocation. This is a semantic judgment, not a keyword
check.

## Cross-harness mapping

| Intended behavior | Claude Code `SKILL.md` | Codex `agents/openai.yaml` |
| --- | --- | --- |
| Implicit model invocation allowed | `disable-model-invocation: false` or omitted | `policy.allow_implicit_invocation: true` or omitted |
| Manual invocation only | `disable-model-invocation: true` | `policy.allow_implicit_invocation: false` |

The fields are not full runtime equivalents across every product feature. They
are the practical mapping for whether normal task wording may select the skill.

## Recommend manual-only invocation

Prefer manual-only when the skill is primarily one of these:

- a mode switch the user should deliberately choose;
- a deployment, commit, publish, send, join, bulk-write, or destructive action;
- a long-running listener or workflow whose timing matters;
- an expensive or exhaustive operation that should not start from a broad match;
- one of several competing visual, writing, or process styles;
- a workflow whose value depends on explicit arguments or an explicit checkpoint.

Do not infer manual-only merely because a skill can eventually write a file. A
well-scoped domain skill may remain implicit when the user's natural-language
request clearly expresses the operation and the skill retains its own safety
gates.

## Recommend implicit invocation

Prefer implicit invocation when the skill is primarily one of these:

- a domain router users naturally request without knowing the skill name;
- background knowledge or a reusable dependency another skill needs;
- a diagnostic, validation, or quality guard that should activate by context;
- a read-heavy lookup or analysis capability with a narrow intent boundary;
- a specialized implementation convention that should apply automatically in
  the matching codebase.

## Evidence and confidence

For every recommendation, cite the user intent or side effect that controls the
decision. Assign:

- `high`: the description and body clearly establish the invocation mode;
- `medium`: the likely mode is clear but depends on how the user operates it;
- `low`: competing interpretations remain; recommend human review and no fix.

Also report structural mismatches independently. If Claude disables implicit
invocation while Codex allows it, or vice versa, the configuration is
inconsistent even before deciding which side is correct.

