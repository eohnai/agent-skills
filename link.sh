#!/usr/bin/env bash
# Symlink every skill in this repo into Claude Code's and Codex's skill folders.
#
# Skills live in category folders (<category>/<skill>/SKILL.md). The category is
# only for organizing this repo: each skill is linked under its own name, so
# career/resume-tailor becomes ~/.claude/skills/resume-tailor.
#
# Safe to re-run: existing links are refreshed, links left behind by moved or
# deleted skills are removed, and real folders are never replaced.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
targets=("$HOME/.claude/skills" "$HOME/.agents/skills")

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
