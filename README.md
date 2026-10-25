# agent-skills

My personal skills for Claude Code and Codex. This repo is the only real copy;
`link.sh` puts a symlink to each skill in `~/.claude/skills/` (Claude Code) and
`~/.agents/skills/` (Codex), so editing a skill here updates both tools.

## Layout

```
<category>/<skill>/
  SKILL.md        instructions (required)
  scripts/        code the agent runs
  references/     longer docs the agent reads only when needed
  assets/         templates and files that get copied out
  agents/         openai.yaml: optional Codex metadata (display name, manual-only policy)
```

Categories only organize this repo. Each skill is linked under its own name, so
skill names must be unique across categories (`link.sh` stops if they aren't).

## Skills

**project/**: keeping project records

| Skill | Use it to |
|---|---|
| `plan-feature` | Turn an idea into a spec: goal, done-when checks, decisions, session-sized tasks |
| `next-task` | Do one task per session: catch up, plan, do, verify, checkpoint |
| `ketchup` | Start a session: read the records and git, report where things stand |
| `checkpoint` | End a session: update STATUS.md with progress, blockers, next steps |
| `record-decision` | Record a choice between approaches: in the spec, or in `decisions/NNNN-*.md` if it reaches further |
| `draft-report` | Draft a report grounded in decisions, git history, and the code |
| `progress` | Board of what's done, left, due, and blocked per spec, and who owns what, read from the specs |

**dev/**: development workflow

| Skill | Use it to |
|---|---|
| `make-goal` | Turn an aim into a bounded `/goal` block and a per-turn log |
| `debug-issue` | Find a bug's root cause before fixing it: reproduce, narrow down, test one hypothesis, fix, verify |
| `explain-issue` | Explain review comments, feedback, or bugs: root cause, evidence, fix (manual: `/explain-issue`) |
| `how` | Explain how a subsystem or flow works, or where code should live: overview, flow, file map, gotchas |
| `blast-radius` | Find what a change could break beyond its diff, and prove the fact it's safe because of (manual: `/blast-radius`) |
| `glab` | Work with GitLab from the command line |

**meta/**: maintaining these skills

| Skill | Use it to |
|---|---|
| `skills-lint` | Audit skill names, invocation policies, and descriptions (manual: `/skills-lint`) |

**writing/**: `unslop` cuts AI-sounding patterns from a draft (manual: `/unslop`).

`how`, `blast-radius`, and `unslop` are adapted from
[pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT).

**design/**: `impeccable` for frontend and UI design; `apple-design` for Apple-style
motion, materials and typography on the web (from
[emilkowalski/skills](https://github.com/emilkowalski/skills), MIT).

**career/**: `update-portfolio` adds a finished project or role to the website's fact
bank and the resume. Also résumé and job-search skills (`resume-*`, `cover-letter-generator`,
`interview-prep-generator`, `job-description-analyzer`, `offer-comparison-analyzer`, and others).

## Project records

The project skills look for records in one folder: `./` if `./STATUS.md` exists
(a workspace that wraps code repos in `repos/`), otherwise `./docs/` (a normal repo).

```
STATUS.md         # now, next, blockers
decisions/0001-*.md  # choices that reach more than one spec (others go in the spec)
specs/            # one feature per spec: <area>-<feature>.md or <name>/;
                  # tasks as - [ ] open, - [x] done; optional: Due: YYYY-MM-DD,
                  # Needs: <spec>, Status:, @owner, (blocked: reason)
goals/            # <topic>.md goal blocks and <topic>-log.md run logs
notes/            # <area>-roadmap.md (slices of big work), plus briefs and meeting notes
reports/
```

## Global instructions

`global/AGENTS.md` holds rules both tools follow in every session (git rules,
explaining choices). Run `./link.sh --global` to connect it:

- **Codex:** `~/.codex/AGENTS.md` becomes a symlink to it.
- **Claude Code:** `~/.claude/CLAUDE.md` stays a normal file that imports it with
  a line like `@~/Projects/agent-skills/global/AGENTS.md` (`link.sh` writes the
  path of wherever you cloned the repo). Machine-specific notes go
  below that line. An import instead of a symlink means that if Claude Code rewrites
  `CLAUDE.md`, the shared rules stay intact in the repo.

`--global` is opt-in, so anyone else using these skills runs plain `./link.sh` and
doesn't get these personal rules.

## Adding a skill

1. Create `<category>/<skill-name>/SKILL.md` with `name` and a `description`
   starting with "Use when".
2. Run `./link.sh`.
3. Optionally run `/skills-lint` to check it.
