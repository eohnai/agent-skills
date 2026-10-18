# Global instructions

## Git
- Never run `git commit`, `git push`, or open a pull request on your own. The user does all commits and pushes.
- This applies even when a skill, plan, or workflow says to commit. Only commit if the user explicitly asks in the current conversation.
- Leave changes uncommitted in the working tree. When work is finished, list the changed files and give the commands to commit them, for the user to review and run:

  ```bash
  git add src/auth/login.ts tests/auth/login.test.ts
  git commit -m "feat: add login endpoint returning a JWT"
  ```

  Stage by explicit path, quoting paths that contain spaces. If the work splits into separate changes, give one `git add` and `git commit` pair per change.
- Commit messages use Conventional Commits: `<type>: <summary>`. Types: `feat` (new behavior), `fix` (bug fix), `docs`, `refactor` (no behavior change), `test`, `chore` (tooling, dependencies, config), `ci`. Write the summary as a lowercase command ("add", not "added"), 72 characters or fewer. For a body, add a second `-m "..."`.
- Don't commit or push to the repo's default branch unless the user says to in the current conversation. Before any `git add`, compare `git branch --show-current` with the default branch: the one `git symbolic-ref --short refs/remotes/origin/HEAD` points to (it prints `origin/<name>`), or `main` or `master` if there's no remote. If they match, propose a new branch name (e.g. `fix/login-timeout`, `docs/readme-setup`) and create it only once the user approves the plan.
- When the user asks for a commit, show the plan before running any `git add` or `git commit`:
  - the current branch, or the new branch you'll create and why;
  - the exact `git add` and `git commit` commands you'll run, one pair per commit;
  - anything uncommitted you're leaving out, and why.

  Then wait for the user to approve or adjust it. Stage files by explicit path, not `git add -A` or `git add .`.

## Writing
- Write in plain English, based on Simplified Technical English (ASD-STE100), for a reader who is new to the topic:
  - Lead with the answer, then the reason.
  - Start from a concrete example (what happens, to what, when), then the general idea.
  - One new idea per sentence. Explain a technical term the first time you use it.
  - Keep sentences short: 20 words or fewer for instructions, 25 for explanations.
  - One instruction per sentence. Write steps as commands ("Run `pnpm test`").
  - Use active voice and simple tenses. No idioms or slang.
  - Use one word for one meaning, and the same word for the same thing throughout.
- Keep code, commands, file paths, and error messages exact.

## Explaining choices
- When you recommend something, make a decision, or change something, say why in a sentence or two: what problem it solves, and what it costs or rules out.
- When there were real alternatives, say why they lost.
- Separate what you checked from what is your judgment.
- One reason per decision, not an essay.
