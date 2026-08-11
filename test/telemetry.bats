#!/usr/bin/env bats

load test_helper

@test "emit appends one line with fixed key order" {
  tfile="$BATS_TEST_TMPDIR/telemetry.jsonl"
  run bash -c ". '$ROUTINE_REPO_ROOT/lib/telemetry.sh' && telemetry_emit '$tfile' gate.preflight bin/routine-gate 0001 01-01 0 842"
  [ "$status" -eq 0 ]
  [ "$(wc -l < "$tfile")" -eq 1 ]
  grep -q '^{"ts":"[0-9T:Z-]*","event":"gate.preflight","script":"bin/routine-gate","ticket":"0001","task":"01-01","exit":0,"ms":842}$' "$tfile"
}

@test "gate emit is a clean no-op without ticket context" {
  run bash -c "unset ROUTINE_TICKET_DIR; . '$ROUTINE_REPO_ROOT/lib/telemetry.sh' && telemetry_gate_emit gate.preflight bin/routine-gate 0 5"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "gate emit writes into the ticket dir when set" {
  tdir="$BATS_TEST_TMPDIR/ticket"
  mkdir -p "$tdir"
  run bash -c "ROUTINE_TICKET_DIR='$tdir' ROUTINE_TICKET=0001 ROUTINE_TASK=01-01; export ROUTINE_TICKET_DIR ROUTINE_TICKET ROUTINE_TASK; . '$ROUTINE_REPO_ROOT/lib/telemetry.sh' && telemetry_gate_emit gate.analyst bin/routine-gate 0 7"
  [ "$status" -eq 0 ]
  grep -q '"event":"gate.analyst"' "$tdir/telemetry.jsonl"
}

@test "values with quotes or newlines are rejected" {
  tfile="$BATS_TEST_TMPDIR/telemetry.jsonl"
  run bash -c ". '$ROUTINE_REPO_ROOT/lib/telemetry.sh' && telemetry_emit '$tfile' 'bad\"event' s t k 0 1"
  [ "$status" -ne 0 ]
  [ ! -f "$tfile" ]
}

@test "emit is append-only" {
  tfile="$BATS_TEST_TMPDIR/telemetry.jsonl"
  printf '%s\n' '{"existing":"line"}' > "$tfile"
  run bash -c ". '$ROUTINE_REPO_ROOT/lib/telemetry.sh' && telemetry_emit '$tfile' e s t k 1 5"
  [ "$status" -eq 0 ]
  [ "$(wc -l < "$tfile")" -eq 2 ]
  [ "$(head -1 "$tfile")" = '{"existing":"line"}' ]
}
