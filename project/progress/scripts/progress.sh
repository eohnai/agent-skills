#!/usr/bin/env bash
# Print a markdown progress board for every spec under <records>/specs/.
# A spec is either specs/<name>.md or a folder specs/<name>/ of .md files.
#
# Read from the specs themselves (all optional except the checkboxes):
#   - [ ] task / - [x] task       open / done
#   - [ ] task (blocked: reason)  open task that is blocked
#   - [ ] task @name              task owned by name
#   Status: <value>               overrides the derived status (blocked, dropped, done)
#   Due: YYYY-MM-DD               deadline; flagged when close or overdue
#
# Usage: bash progress.sh [records-folder]
#   default: "." if ./STATUS.md exists, else "docs" if ./docs/STATUS.md or ./docs/specs/ exists, else "."
set -euo pipefail

root="${1:-}"
if [ -z "$root" ]; then
  if [ -f STATUS.md ]; then root=.
  elif [ -f docs/STATUS.md ] || [ -d docs/specs ]; then root=docs
  else root=.
  fi
fi
specs="$root/specs"
if [ ! -d "$specs" ]; then
  echo "No specs/ folder in $root"
  exit 0
fi

# Seconds since epoch for a YYYY-MM-DD date (macOS date first, then GNU date).
to_epoch() {
  date -j -f "%Y-%m-%d" "$1" +%s 2>/dev/null || date -d "$1" +%s 2>/dev/null
}
today_epoch="$(to_epoch "$(date +%Y-%m-%d)")"

# Per spec, emits lines:
#   S  done  left  blocked  status  due  next-task   (fields split by \037, see below)
#   B  task                 (tab-separated; one per blocked task)
#   O  owner  is-blocked    (tab-separated; one per @owner on an open task)
# The S line uses the \037 unit separator because `read` collapses consecutive tabs,
# which would silently drop an empty status or due field and shift the columns.
scan_spec() {
  awk '
    function trim(s) { sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s }
    function field(line, n) { v = substr(line, n + 1); gsub(/[*_]/, "", v); return trim(v) }
    {
      low = tolower($0)
      if (status == "" && match(low, /^[*_]*status[*_]*:/)) status = field($0, RLENGTH)
      if (due == "" && match(low, /^[*_]*due[*_]*:/)) due = field($0, RLENGTH)
      if ($0 ~ /^[[:space:]]*[-*] \[[xX]\]/) { done++; next }
      if (match($0, /^[[:space:]]*[-*] \[ \]/)) {
        task = trim(substr($0, RLENGTH + 1))
        left++
        is_blocked = (tolower(task) ~ /blocked:/) ? 1 : 0
        if (is_blocked) { blocked++; print "B\t" task }
        else if (next_task == "") next_task = task
        if (first_open == "") first_open = task
        rest = " " task
        while (match(rest, /[[:space:]]@[A-Za-z0-9_-]+/)) {
          print "O\t" substr(rest, RSTART + 2, RLENGTH - 2) "\t" is_blocked
          rest = substr(rest, RSTART + RLENGTH)
        }
      }
    }
    END {
      if (next_task == "") next_task = first_open
      print "S\037" done + 0 "\037" left + 0 "\037" blocked + 0 "\037" status "\037" due "\037" next_task
    }
  '
}

describe_due() {
  local due="$1" n_left="$2" status="$3"
  [ -n "$due" ] || { echo "-"; return; }
  local due_epoch
  if ! due_epoch="$(to_epoch "$due")" || [ -z "$due_epoch" ]; then
    echo "$due (not a YYYY-MM-DD date)"; return
  fi
  # Finished or dropped work can't be late.
  if [ "$n_left" -eq 0 ] || printf '%s' "$status" | grep -qiE '^(done|dropped)'; then
    echo "$due"; return
  fi
  # Round to whole days in both directions (bash division truncates toward zero,
  # and DST can make a day 23 or 25 hours).
  local diff=$(( due_epoch - today_epoch )) days
  if [ "$diff" -ge 0 ]; then days=$(( (diff + 43200) / 86400 ))
  else days=$(( -((-diff + 43200) / 86400) ))
  fi
  if [ "$days" -lt 0 ]; then echo "$due (OVERDUE by $(plural $(( -days )) day))"
  elif [ "$days" -eq 0 ]; then echo "$due (due today ⚠)"
  elif [ "$days" -le 7 ]; then echo "$due (in $(plural "$days" day) ⚠)"
  else echo "$due (in $(plural "$days" day))"
  fi
}

plural() { if [ "$1" -eq 1 ]; then echo "1 $2"; else echo "$1 ${2}s"; fi; }

cell() { local s="${1//|/\\|}"; echo "${s:--}"; }

rows=""
blocked_list=""
owners=""
total_done=0
total_left=0
total_blocked=0

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

  scan="$(printf '%s\n' "$text" | scan_spec)"
  IFS=$'\037' read -r _ n_done n_left n_blocked status due next < <(printf '%s\n' "$scan" | grep $'^S\037')

  if [ -z "$status" ]; then
    if [ $((n_done + n_left)) -eq 0 ]; then status="no tasks"
    elif [ "$n_left" -eq 0 ]; then status="all ticked"
    elif [ "$n_blocked" -eq "$n_left" ]; then status="blocked (all open tasks)"
    elif [ "$n_done" -eq 0 ]; then status="not started"
    else status="in progress"
    fi
  elif printf '%s' "$status" | grep -qi '^done' && [ "$n_left" -gt 0 ]; then
    status="$status (but $n_left unticked)"
  fi

  rows+="| $name | $(cell "$status") | $(cell "$(describe_due "$due" "$n_left" "$status")") | $n_done | $n_left | $n_blocked | $(cell "$next") |"$'\n'
  blocked_list+="$(printf '%s\n' "$scan" | awk -F'\t' -v s="$name" '$1 == "B" { print "- " s ": " $2 }')"$'\n'
  owners+="$(printf '%s\n' "$scan" | grep '^O' || true)"$'\n'
  total_done=$((total_done + n_done))
  total_left=$((total_left + n_left))
  total_blocked=$((total_blocked + n_blocked))
done

echo "| Spec | Status | Due | Done | Left | Blocked | Next task |"
echo "|---|---|---|---|---|---|---|"
printf '%s' "$rows"
echo "| **Total** | | | **$total_done** | **$total_left** | **$total_blocked** | |"

if [ -n "$(printf '%s' "$blocked_list" | tr -d '[:space:]')" ]; then
  echo
  echo "**Blocked tasks**"
  printf '%s\n' "$blocked_list" | grep -v '^$'
fi

if [ -n "$(printf '%s' "$owners" | tr -d '[:space:]')" ]; then
  echo
  echo "**By owner**"
  echo "| Owner | Open | Blocked |"
  echo "|---|---|---|"
  printf '%s\n' "$owners" | awk -F'\t' '$1 == "O" { open[$2]++; blocked[$2] += $3 }
    END { for (o in open) printf "| @%s | %d | %d |\n", o, open[o], blocked[o] }' | sort
fi
