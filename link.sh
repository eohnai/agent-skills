#!/usr/bin/env bash
# Symlink every skill in this repo into Claude Code's and Codex's skill folders.
#
# Skills live in category folders (<category>/<skill>/SKILL.md). The category is
# only for organizing this repo: each skill is linked under its own name, so
# career/resume-tailor becomes ~/.claude/skills/resume-tailor.
#
# Safe to re-run: existing links are refreshed, links left behind by moved or
# deleted skills are removed, and real folders are never replaced.
#
# ./link.sh --global also connects the shared instructions in global/AGENTS.md:
# Codex gets a symlink at ~/.codex/AGENTS.md, and Claude Code's ~/.claude/CLAUDE.md
# imports the file. Opt-in, so someone else using these skills doesn't get your rules.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
targets=("$HOME/.claude/skills" "$HOME/.agents/skills")

link_global() {
  local shared="$repo/global/AGENTS.md"
  local codex="$HOME/.codex/AGENTS.md"
  local claude="$HOME/.claude/CLAUDE.md"
  local import="@${shared/#$HOME/~}"

  mkdir -p "$(dirname "$codex")"
  if [ -L "$codex" ] && [ "$(readlink "$codex")" = "$shared" ]; then
    echo "ok        $codex"
  elif [ -L "$codex" ] || [ ! -e "$codex" ]; then
    ln -sfn "$shared" "$codex"
    echo "linked    $codex"
  else
    echo "SKIPPED   $codex (a real file is there; merge it into global/AGENTS.md, then delete it)" >&2
  fi

  if [ ! -e "$claude" ]; then
    mkdir -p "$(dirname "$claude")"
    printf '%s\n\n<!-- Add anything specific to this machine below. -->\n' "$import" > "$claude"
    echo "created   $claude (imports global/AGENTS.md)"
  elif grep -qxF "$import" "$claude"; then
    echo "ok        $claude (imports global/AGENTS.md)"
  else
    echo "TODO      $claude: add this line at the top: $import" >&2
  fi
}

# Collect skills and refuse to continue if two categories use the same name,
# because both would want the same link.
skills=()
for skill_md in "$repo"/*/*/SKILL.md; do
  [ -f "$skill_md" ] || continue
  skills+=("$(dirname "$skill_md")")
done
dupes="$(for s in "${skills[@]}"; do basename "$s"; done | sort | uniq -d)"
if [ -n "$dupes" ]; then
  echo "Duplicate skill names (rename one of each):" >&2
  echo "$dupes" >&2
  exit 1
fi

for dir in "${targets[@]}"; do
  mkdir -p "$dir"

  # Remove links into this repo whose skill no longer exists.
  for link in "$dir"/*; do
    [ -L "$link" ] || continue
    case "$(readlink "$link")" in
      "$repo"/*) [ -e "$link" ] || { rm "$link"; echo "removed   $link (skill moved or deleted)"; } ;;
    esac
  done

  for skill in "${skills[@]}"; do
    link="$dir/$(basename "$skill")"
    if [ -L "$link" ]; then
      if [ "$(readlink "$link")" = "$skill" ]; then
        echo "ok        $link"
      else
        ln -sfn "$skill" "$link"
        echo "relinked  $link"
      fi
    elif [ -e "$link" ]; then
      echo "SKIPPED   $link (a real folder is already there; move it first)" >&2
    else
      ln -s "$skill" "$link"
      echo "linked    $link"
    fi
  done
done

if [ "${1:-}" = "--global" ]; then
  link_global
fi
