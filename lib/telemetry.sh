# shellcheck shell=bash
# Telemetry emission: one JSON line per event, fixed key order
# ts,event,script,ticket,task,exit,ms — we are the only writer, so awk can
# parse without a JSON library. Script-owned, append-only. bash 3.2.

# routine_now_ms — epoch milliseconds where date supports %N (GNU), epoch
# seconds x 1000 where it prints the literal N (BSD). Runtime-detected.
routine_now_ms() {
  _t_now="$(date +%s%N 2>/dev/null || true)"
  case "$_t_now" in
    ''|*[!0-9]*) echo $(( $(date -u +%s) * 1000 )) ;;
    *) echo $(( _t_now / 1000000 )) ;;
  esac
}

# telemetry_emit <file> <event> <script> <ticket> <task> <exit> <ms>
telemetry_emit() {
  _t_file="$1" _t_event="$2" _t_script="$3" _t_ticket="$4" _t_task="$5"
  _t_exit="$6" _t_ms="$7"
  _t_nl='
'
  for _t_v in "$_t_event" "$_t_script" "$_t_ticket" "$_t_task"; do
    case "$_t_v" in
      *\"*|*"$_t_nl"*)
        echo "telemetry_emit: invalid character in value: $_t_v" >&2
        return 1 ;;
    esac
  done
  _t_ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf '{"ts":"%s","event":"%s","script":"%s","ticket":"%s","task":"%s","exit":%d,"ms":%d}\n' \
    "$_t_ts" "$_t_event" "$_t_script" "$_t_ticket" "$_t_task" \
    "$_t_exit" "$_t_ms" >> "$_t_file"
}

# telemetry_harness_emit <event> <script> <exit> <ms>
# App-level wrapper for harness scripts: writes to runs/<app>/telemetry.jsonl
# under the routine root when that app directory already exists; otherwise a
# clean no-op — scripts never invent a destination. Requires lib/paths.sh.
telemetry_harness_emit() {
  _t_root="$(routine_root)"
  _t_app="$(routine_app_key "${TARGET:-$PWD}")"
  [ -d "$_t_root/runs/$_t_app" ] || return 0
  telemetry_emit "$_t_root/runs/$_t_app/telemetry.jsonl" "$1" "$2" "" "" \
    "$3" "$4"
}

# telemetry_gate_emit <event> <script> <exit> <ms>
# Ticket-bound wrapper: writes to $ROUTINE_TICKET_DIR/telemetry.jsonl when a
# ticket context exists; outside one it is a clean no-op — scripts never
# invent a destination. Attribution is derived, never passed: the ticket is
# the directory's basename, the task is the in_progress index row's id, and
# an empty task field means nothing was in progress at emission time.
telemetry_gate_emit() {
  [ -n "${ROUTINE_TICKET_DIR:-}" ] || return 0
  _t_ticket_id="$(basename "$ROUTINE_TICKET_DIR")"
  _t_task_id=""
  if [ -f "$ROUTINE_TICKET_DIR/index.tsv" ]; then
    _t_task_id="$(awk -F'\t' '$4=="in_progress" {print $1; exit}' \
      "$ROUTINE_TICKET_DIR/index.tsv")"
  fi
  telemetry_emit "$ROUTINE_TICKET_DIR/telemetry.jsonl" "$1" "$2" \
    "$_t_ticket_id" "$_t_task_id" "$3" "$4"
}
