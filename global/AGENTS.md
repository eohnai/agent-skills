# Global instructions

## Git
- Never run `git commit`, `git push`, or open a pull request on your own. The user does all commits and pushes.
- Leave changes uncommitted in the working tree. When work is finished, say which files changed so the user can review and commit them.
- This applies even when a skill, plan, or workflow says to commit. Only commit if the user explicitly asks in the current conversation.
- Don't commit or push to the repo's default branch unless the user says to in the current conversation. Before any `git add`, compare `git branch --show-current` with the default branch: the one `git symbolic-ref --short refs/remotes/origin/HEAD` points to (it prints `origin/<name>`), or `main` or `master` if there's no remote. If they match, propose a new branch name (e.g. `fix/login-timeout`, `docs/readme-setup`) and create it only once the user approves the plan.
- When the user asks for a commit, show the plan before running any `git add` or `git commit`:
  - the current branch, or the new branch you'll create and why;
  - the exact files to stage, listed by path (grouped per commit if splitting into several);
  - the full commit message for each commit;
  - anything uncommitted you're leaving out, and why.

  Then wait for the user to approve or adjust it. Stage files by explicit path, not `git add -A` or `git add .`.

## Explaining choices
- When you recommend something, make a decision, or change something, say why in a sentence or two: what problem it solves, and what it costs or rules out.
- When there were real alternatives, say why they lost.
- Separate what you checked from what is your judgment.
- One reason per decision, not an essay.
