# shellcheck shell=bash
# Where run telemetry lives — one implementation, shared by every script
# that needs to know. bin/routine-retro reads these files to compute the
# report; bin/routine-evidence counts them to declare the corpus its
# snapshot came from. Two copies of these globs would drift, and a
# render declaring a corpus the retro did not read is exactly the false
# claim this repository keeps building gates against.
#
# Prints one path per line, nothing when the corpus is empty.
routine_telemetry_files() {
  _rc_root="$1"
  for _rc_f in "$_rc_root"/runs/*/tickets/*/telemetry.jsonl \
               "$_rc_root"/runs/*/tickets/archive/*/telemetry.jsonl; do
    [ -f "$_rc_f" ] || continue
    printf '%s\n' "$_rc_f"
  done
}
