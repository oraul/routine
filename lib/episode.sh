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
