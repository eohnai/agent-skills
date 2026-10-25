#!/usr/bin/env bash
# Print a markdown progress board for every spec under <records>/specs/.
# A spec is specs/<area>/<feature>.md, with the id <area>/<feature>. A spec outside
# an area folder, specs/<name>.md, has the id <name> and is shown under "No area".
#
# Read from the specs themselves (all optional except the checkboxes):
#   - [ ] task / - [x] task       open / done
#   - [ ] task (blocked: reason)  open task that is blocked
#   - [ ] task @name              task owned by name
#   Status: <value>               overrides the derived status (blocked, dropped, done)
#   Due: YYYY-MM-DD               deadline; flagged when close or overdue
#   Needs: <spec>, <spec>         specs that must finish first, shown as "waiting on".
#                                 <feature> alone means a spec in the same area.
#
# Also reads each specs/<area>/area.md: the "# <Area>" title and the "- `<feature>`: ..."
# lines under its "## Specs" heading. The board lists each area's specs in that order,
# with finished specs struck through and "no spec yet" for lines without a file. Specs
# in the folder but not in the list come after them.
#
# Finished specs in no area, and areas whose specs are all finished, are listed on one
# line under the board, not as rows. The Total row counts their done tasks only.
#
# Usage: bash progress.sh [--all] [records-folder]
#   --all: show those as rows too
#   default folder: "." if ./STATUS.md exists, else "docs" if ./docs/STATUS.md or ./docs/specs/ exists, else "."
set -euo pipefail

show_all=0
root=""
for arg in "$@"; do
  case "$arg" in
    --all) show_all=1 ;;
    *) root="$arg" ;;
  esac
done
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
#   S  done  left  blocked  status  due  needs  next-task   (fields split by \037, see below)
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
      if (needs == "" && match(low, /^[*_]*needs[*_]*:/)) needs = field($0, RLENGTH)
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
      print "S\037" done + 0 "\037" left + 0 "\037" blocked + 0 "\037" status "\037" due "\037" needs "\037" next_task
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

closed=""
blocked_list=""
owners=""
total_done=0
total_left=0
total_blocked=0

# First pass: scan every spec, so a spec's Needs can be checked against the others.
# A spec is finished when it is marked dropped, or marked done with every task ticked.
# All tasks ticked without the mark is not enough, because its merge request may still
# be open. Marked done with unticked tasks is not enough either, until the user settles it.
names=()
spec_areas=()
scans=()
known=" "
finished=" "
areas=()

# Adds the spec with id $1 in area $2 (empty for none), read from file $3.
add_spec() {
  local text scan n_left status
  text="$(cat "$3")"
  [ -n "$text" ] || return 0
  scan="$(printf '%s\n' "$text" | scan_spec)"
  names+=("$1")
  spec_areas+=("$2")
  scans+=("$scan")
  known+="$1 "
  IFS=$'\037' read -r _ _ n_left _ status _ _ _ < <(printf '%s\n' "$scan" | grep $'^S\037')
  if printf '%s' "$status" | grep -qi '^dropped' ||
     { printf '%s' "$status" | grep -qi '^done' && [ "$n_left" -eq 0 ]; }; then
    finished+="$1 "
  fi
}

for entry in "$specs"/*; do
  if [ -d "$entry" ]; then
    a="$(basename "$entry")"
    areas+=("$a")
    for file in "$entry"/*.md; do
      [ -f "$file" ] || continue
      feature="$(basename "$file" .md)"
      [ "$feature" = area ] && continue
      add_spec "$a/$feature" "$a" "$file"
    done
  elif [ "${entry%.md}" != "$entry" ]; then
    add_spec "$(basename "$entry" .md)" "" "$entry"
  fi
done

rests=()
kinds=()
for i in "${!names[@]}"; do
  name="${names[$i]}"
  scan="${scans[$i]}"
  IFS=$'\037' read -r _ n_done n_left n_blocked status due needs next < <(printf '%s\n' "$scan" | grep $'^S\037')

  # A need without an area means a spec in the same area, if there is one.
  waiting=""
  for need in $(printf '%s' "$needs" | tr ',`' '  '); do
    id="$need"
    if [ -n "${spec_areas[$i]}" ] && [ "${need#*/}" = "$need" ]; then
      case "$known" in *" ${spec_areas[$i]}/$need "*) id="${spec_areas[$i]}/$need" ;; esac
    fi
    case "$finished" in *" $id "*) ;; *) waiting+="${waiting:+, }$need" ;; esac
  done

  if [ -z "$status" ]; then
    if [ $((n_done + n_left)) -eq 0 ]; then status="no tasks"
    elif [ "$n_left" -eq 0 ]; then status="all ticked"
    elif [ "$n_blocked" -eq "$n_left" ]; then status="blocked (all open tasks)"
    elif [ "$n_done" -eq 0 ] && [ -n "$waiting" ]; then status="waiting on $waiting"
    elif [ "$n_done" -eq 0 ]; then status="not started"
    else status="in progress"
    fi
  elif printf '%s' "$status" | grep -qi '^done' && [ "$n_left" -gt 0 ]; then
    status="$status (but $n_left unticked)"
  fi

  # The row after its name cell, so an area can shorten the name or strike it through.
  rests+=(" $(cell "$status") | $(cell "$(describe_due "$due" "$n_left" "$status")") | $n_done | $n_left | $n_blocked | $(cell "$next") |")

  # A finished spec is closed: its done tasks still count, but its open and blocked
  # tasks don't, because nobody will do them.
  kind=""
  case "$finished" in
    *" $name "*) kind="$(printf '%s' "$status" | grep -oiE '^(done|dropped)' | tr '[:upper:]' '[:lower:]')" ;;
  esac
  kinds+=("$kind")
  total_done=$((total_done + n_done))
  if [ -n "$kind" ]; then continue; fi
  total_left=$((total_left + n_left))
  total_blocked=$((total_blocked + n_blocked))

  blocked_list+="$(printf '%s\n' "$scan" | awk -F'\t' -v s="$name" '$1 == "B" { print "- " s ": " $2 }')"$'\n'
  owners+="$(printf '%s\n' "$scan" | grep '^O' || true)"$'\n'
done

# Index of the spec called $1 in names, or -1.
index_of() {
  local i
  for i in "${!names[@]}"; do
    if [ "${names[$i]}" = "$1" ]; then echo "$i"; return; fi
  done
  echo -1
}

# The board row for the spec at index $1, named $2 (default: its id), and struck
# through if $3 is set.
spec_row() {
  local name="${2:-${names[$1]}}"
  if [ -n "${3:-}" ]; then name="~~$name~~"; fi
  echo "| $name |${rests[$1]}"
}

# The area file $1 as a "T<tab>title" line, then one "S<tab>feature" line per spec
# listed under its "## Specs" heading, in order.
read_area() {
  [ -f "$1" ] || return 0
  awk '
    /^#/ { in_specs = (tolower($0) ~ /^#+[[:space:]]*specs[[:space:]]*$/) }
    !titled && /^# / { print "T\t" substr($0, 3); titled = 1 }
    /^#/ { next }
    in_specs && match($0, /^[[:space:]]*[-*] `[^`]+`/) {
      s = substr($0, RSTART, RLENGTH); sub(/^[^`]*`/, "", s); sub(/`$/, "", s); print "S\t" s
    }
  ' "$1"
}

board=""
placed=" "
unplanned=0

for a in ${areas[@]+"${areas[@]}"}; do
  title="$a"
  area_rows=""
  area_total=0
  area_done=0

  # The specs the area file lists, in its order, then the other specs in the folder.
  listed=()
  while IFS=$'\t' read -r type value; do
    if [ "$type" = T ]; then title="$value"; else listed+=("$a/${value#"$a"/}"); fi
  done < <(read_area "$specs/$a/area.md")
  for i in "${!names[@]}"; do
    [ "${spec_areas[$i]}" = "$a" ] && listed+=("${names[$i]}")
  done

  for id in ${listed[@]+"${listed[@]}"}; do
    case "$placed" in *" $id "*) continue ;; esac
    placed+="$id "
    area_total=$((area_total + 1))
    i="$(index_of "$id")"
    if [ "$i" -lt 0 ]; then
      area_rows+="| ${id#*/} | no spec yet | - | - | - | - | write its spec with plan-feature |"$'\n'
      unplanned=$((unplanned + 1))
    elif [ -n "${kinds[$i]}" ]; then
      area_rows+="$(spec_row "$i" "${id#*/}" struck)"$'\n'
      area_done=$((area_done + 1))
    else
      area_rows+="$(spec_row "$i" "${id#*/}")"$'\n'
    fi
  done

  [ "$area_total" -gt 0 ] || continue
  if [ "$area_done" -eq "$area_total" ] && [ "$show_all" -eq 0 ]; then
    closed+="${closed:+, }$title (all $(plural "$area_total" spec))"
  else
    board+="| **$title** | $area_done of $(plural "$area_total" spec) finished | | | | | |"$'\n'"$area_rows"
  fi
done

others=""
for i in "${!names[@]}"; do
  case "$placed" in *" ${names[$i]} "*) continue ;; esac
  if [ -n "${kinds[$i]}" ] && [ "$show_all" -eq 0 ]; then
    closed+="${closed:+, }${names[$i]} (${kinds[$i]})"
  else
    others+="$(spec_row "$i")"$'\n'
  fi
done
if [ -n "$board" ] && [ -n "$others" ]; then
  board+="| **No area** | | | | | | |"$'\n'
fi
board+="$others"

total_note=""
[ "$unplanned" -gt 0 ] && total_note="**+$(plural "$unplanned" spec) not written yet**"

echo "| Spec | Status | Due | Done | Left | Blocked | Next task |"
echo "|---|---|---|---|---|---|---|"
printf '%s' "$board"
echo "| **Total** |${total_note:+ $total_note} | | **$total_done** | **$total_left** | **$total_blocked** | |"

if [ -n "$closed" ]; then
  echo
  echo "**Done or dropped:** $closed. Run with \`--all\` to show them as rows."
fi

roadmaps="$(cd "$root" && ls notes/*-roadmap.md 2>/dev/null | tr '\n' ' ' || true)"
if [ -n "$roadmaps" ]; then
  echo
  echo "**Old roadmaps:** ${roadmaps% }. The board no longer reads them. Move each to \`specs/<area>/area.md\` (see \`plan-feature\`)."
fi

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
