# shellcheck shell=bash
# The specify episode's revise budget, counted once for every consumer.
# A spec.defective line opens a new budget — re-specified work is new
# work — and line order is time order, so only failures after the last
# defect return count. The gate spends this number; readers report it;
# they can never disagree because there is one implementation.

# episode_revise_count <telemetry-file> — prints the count (0 when the
# file is absent, so a fresh ticket needs no special case).
episode_revise_count() {
  if [ ! -f "$1" ]; then
    printf '0\n'
    return 0
  fi
  awk '
    /"event":"spec.defective"/ { n = 0; next }
    /"event":"spec.lint"/ && /"exit":[1-9]/ { n++ }
    END { print n + 0 }' "$1"
}

# episode_developer_fail_count <telemetry-file> <task-id> — consecutive
# failing gate.developer lines for that task since its last passing one
# (0 when the file is absent). A pass resets the count: a developer that
# fails, fixes, and later fails again has not ground the same wall.
# Fields are read positionally with awk -F'"', the same key order every
# other telemetry reader relies on (ts,event,script,ticket,task,exit,ms;
# see bin/routine-health and bin/routine-audit for the field positions).
episode_developer_fail_count() {
  if [ ! -f "$1" ]; then
    printf '0\n'
    return 0
  fi
  awk -F'"' -v task="$2" '
    $8 == "gate.developer" && $20 == task {
      ex = $23; gsub(/[^0-9-]/, "", ex)
      if (ex + 0 == 0) { n = 0 } else { n++ }
    }
    END { print n + 0 }' "$1"
}

# episode_defect_count <telemetry-file> <task-id> — spec.defective lines
# recorded for that task (0 when the file is absent). Every return
# counts, not just consecutive ones: routine-defect spends this to bound
# a task's total returns, per task rather than per ticket.
episode_defect_count() {
  if [ ! -f "$1" ]; then
    printf '0\n'
    return 0
  fi
  awk -F'"' -v task="$2" '
    $8 == "spec.defective" && $20 == task { n++ }
    END { print n + 0 }' "$1"
}
