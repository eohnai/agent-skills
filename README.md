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
| `catch-up` | Start a session: read the records and git, report where things stand |
| `checkpoint` | End a session: update STATUS.md with progress, verification, next steps |
| `record-decision` | Write a `decisions/NNNN-*.md` record for a choice between approaches |
| `draft-report` | Draft a report grounded in decisions, git history, and the code |
| `progress` | Board of what's done, left, due, and blocked per spec, and who owns what, read from the specs |

**dev/**: development workflow

| Skill | Use it to |
|---|---|
| `make-goal` | Turn an aim into a bounded `/goal` block and a per-turn log |
| `explain-issue` | Explain review comments, feedback, or bugs: root cause, evidence, fix (manual: `/explain-issue`) |
| `glab` | Work with GitLab from the command line |

**meta/**: maintaining these skills

| Skill | Use it to |
|---|---|
| `skills-lint` | Audit skill names, invocation policies, and descriptions (manual: `/skills-lint`) |

**design/**: `impeccable` for frontend and UI design; `apple-design` for Apple-style
motion, materials and typography on the web (from
[emilkowalski/skills](https://github.com/emilkowalski/skills), MIT).

**career/**: résumé and job-search skills (`resume-*`, `cover-letter-generator`,
`interview-prep-generator`, `job-description-analyzer`, `offer-comparison-analyzer`, and others).

## Project records

The project skills look for records in one folder: `./` if `./STATUS.md` exists
(a workspace that wraps code repos in `repos/`), otherwise `./docs/` (a normal repo).

```
STATUS.md
decisions/0001-*.md
specs/            # <name>.md or <name>/; tasks as - [ ] open, - [x] done;
                  # optional: Due: YYYY-MM-DD, Status:, @owner, (blocked: reason)
goals/            # <topic>.md goal blocks and <topic>-log.md run logs
notes/
reports/
```

## Global instructions

`global/AGENTS.md` holds rules both tools follow in every session (git rules,
explaining choices). Run `./link.sh --global` to connect it:

- **Codex:** `~/.codex/AGENTS.md` becomes a symlink to it.
- **Claude Code:** `~/.claude/CLAUDE.md` stays a normal file that imports it with
  `@~/Documents/GitHub/agent-skills/global/AGENTS.md`. Machine-specific notes go
  below that line. An import instead of a symlink means that if Claude Code rewrites
  `CLAUDE.md`, the shared rules stay intact in the repo.

`--global` is opt-in, so anyone else using these skills runs plain `./link.sh` and
doesn't get these personal rules.

## Adding a skill

1. Create `<category>/<skill-name>/SKILL.md` with `name` and a `description`
   starting with "Use when".
2. Run `./link.sh`.
3. Optionally run `/skills-lint` to check it.
