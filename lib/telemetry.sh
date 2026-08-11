# shellcheck shell=bash
# Telemetry emission: one JSON line per event, fixed key order
# ts,event,script,ticket,task,exit,ms — we are the only writer, so awk can
# parse without a JSON library. Script-owned, append-only. bash 3.2.

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

# telemetry_gate_emit <event> <script> <exit> <ms>
# Ticket-bound wrapper: writes to $ROUTINE_TICKET_DIR/telemetry.jsonl when a
# ticket context exists; outside one it is a clean no-op — scripts never
# invent a destination.
telemetry_gate_emit() {
  [ -n "${ROUTINE_TICKET_DIR:-}" ] || return 0
  telemetry_emit "$ROUTINE_TICKET_DIR/telemetry.jsonl" "$1" "$2" \
    "${ROUTINE_TICKET:-}" "${ROUTINE_TASK:-}" "$3" "$4"
}
