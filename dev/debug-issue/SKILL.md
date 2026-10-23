---
name: debug-issue
description: Use when a bug, failing test, error, crash, build failure, or unexpected behavior needs to be found and fixed, before proposing or making any fix, and especially after a fix has already failed.
---

# Debug Issue

## Overview

Find the root cause before changing anything. A fix for a cause you haven't confirmed is a guess, and guesses stack: each one adds a change that hides the next clue.

If the user wants the problem explained rather than fixed, that is `explain-issue`.

## Steps

1. **Reproduce it.** Get the exact command or steps that show the failure, run them, and show the output. Read the whole error: message, stack trace, file and line. If it doesn't reproduce reliably, gather more data (logs, inputs, how often it fails) before going further.
2. **Check what changed.** `git status`, `git diff`, and `git log` since it last worked; new dependencies, config, or environment. A bug that appeared recently usually lives in what changed recently. If it fails only after a restart, check stored state first: config files, caches, lock files, saved sessions.
3. **Narrow it down.** Trace the bad value or state backward from where it shows up to where it starts. Where the data crosses components (frontend → API → database, script → tool), print what goes in and out at each boundary and run once to see which side breaks. If similar code elsewhere in the project works, list every difference between the two.
4. **State one hypothesis**: "X causes this because Y", with the evidence. Test it with the smallest change or probe that would prove it wrong. One variable at a time.
   - Confirmed: go to step 5.
   - Not confirmed: undo the probe and form a new hypothesis from what you learned. Don't build on a failed one.
   - Stuck: say what you don't understand and what evidence would settle it, and ask.
5. **Lock it in with a test.** Before fixing, write a test (or a one-off script if the project has no tests) that fails because of the bug. Run it and show that it fails.
6. **Fix the cause**, in one change. No cleanup or refactoring alongside it; note those for later. First ask whether the bad state is allowed to happen. If it is, the code that broke on it is the cause, so handle the state there. If it should never exist, a guard where it broke only hides the bug, so fix the code that produced the state.
7. **Verify.** Rerun the reproduction from step 1, the new test, and the surrounding test suite. Show the output. "Should work now" is not verification.

## When to stop

- **Two fixes have failed the same check.** Before a third fix, write down the one belief that both fixes assumed. Test that belief directly with an observation that would come out differently if it were false. If the test disproves it, the cause is somewhere else.
- **Three fixes have failed.** Stop before a fourth. Each fix revealing a new problem somewhere else usually means the design is wrong, not the line. Tell the user what you tried and what each attempt showed, and discuss the approach before changing more code.
- **The fix needs a real choice** (change an API, add a dependency, restructure): give the options and let the user pick. If the project has records, **REQUIRED:** use `record-decision`.
- **It can't be fixed this session**: if the project has STATUS.md, add the bug to Blockers with the reproduction command and what's been ruled out, so the next session doesn't start over.

## Common mistakes

- "It's probably X" followed straight by a fix for X, with no step 1 or 4.
- Changing several things at once, so nobody knows which one mattered.
- Editing or skipping the failing test to make it pass.
- Fixing where the error appears instead of where the bad value comes from.
- Calling an intermittent failure "flaky" before finding why it's intermittent.

Do not commit; the user commits.
