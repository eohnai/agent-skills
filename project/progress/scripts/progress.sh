#!/usr/bin/env bash
# Print a markdown progress table for every spec under <records>/specs/.
# A spec is either specs/<name>.md or a folder specs/<name>/ of .md files.
# Progress is counted from "- [ ]" / "- [x]" checkboxes; an optional
# "Status: <value>" line in the spec overrides the derived status.
#
# Usage: bash progress.sh [records-folder]
#   default: "." if ./STATUS.md exists, else "docs" if ./docs/STATUS.md exists, else "."
set -euo pipefail

root="${1:-}"
if [ -z "$root" ]; then
  if [ -f STATUS.md ]; then root=.
  elif [ -f docs/STATUS.md ]; then root=docs
  else root=.
  fi
fi
specs="$root/specs"
if [ ! -d "$specs" ]; then
  echo "No specs/ folder in $root"
  exit 0
fi

open_re='^[[:space:]]*[-*] \[ \]'
done_re='^[[:space:]]*[-*] \[[xX]\]'

echo "| Spec | Status | Done | Left | Next task |"
echo "|---|---|---|---|---|"

total_done=0
total_left=0
for entry in "$specs"/*; do
  if [ -d "$entry" ]; then
    name="$(basename "$entry")"
    text="$(cat "$entry"/*.md 2>/dev/null || true)"
  elif [ "${entry%.md}" != "$entry" ]; then
    name="$(basename "$entry" .md)"
    text="$(cat "$entry")"
  else
    continue
  fi
  [ -n "$text" ] || continue

  n_done=$(printf '%s\n' "$text" | grep -cE "$done_re" || true)
  n_left=$(printf '%s\n' "$text" | grep -cE "$open_re" || true)
  next=$(printf '%s\n' "$text" | grep -m1 -E "$open_re" | sed -E "s/$open_re *//" | cut -c1-70 || true)
  status=$(printf '%s\n' "$text" | grep -m1 -iE '^[*_]*status[*_]*:' | sed -E 's/^[*_]*[Ss]tatus[*_]*:[[:space:]]*//; s/[*_]//g' || true)

  if [ -z "$status" ]; then
    if [ $((n_done + n_left)) -eq 0 ]; then status="no tasks"
    elif [ "$n_left" -eq 0 ]; then status="all ticked"
    elif [ "$n_done" -eq 0 ]; then status="not started"
    else status="in progress"
    fi
  elif printf '%s' "$status" | grep -qi '^done' && [ "$n_left" -gt 0 ]; then
    status="$status (but $n_left unticked)"
  fi

  next="${next//|/\\|}"
  echo "| $name | $status | $n_done | $n_left | ${next:--} |"
  total_done=$((total_done + n_done))
  total_left=$((total_left + n_left))
done

echo "| **Total** | | **$total_done** | **$total_left** | |"
