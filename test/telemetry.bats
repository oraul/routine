#!/usr/bin/env bats

load test_helper

@test "emit appends one line with fixed key order" {
  tfile="$BATS_TEST_TMPDIR/telemetry.jsonl"
  run bash -c ". '$ROUTINE_REPO_ROOT/lib/telemetry.sh' && telemetry_emit '$tfile' gate.preflight bin/routine-gate 0001 01-01 0 842"
  [ "$status" -eq 0 ]
  [ "$(wc -l < "$tfile")" -eq 1 ]
  grep -q '^{"ts":"[0-9T:Z-]*","event":"gate.preflight","script":"bin/routine-gate","ticket":"0001","task":"01-01","exit":0,"ms":842}$' "$tfile"
}

@test "emit is append-only" {
  tfile="$BATS_TEST_TMPDIR/telemetry.jsonl"
  printf '%s\n' '{"existing":"line"}' > "$tfile"
  run bash -c ". '$ROUTINE_REPO_ROOT/lib/telemetry.sh' && telemetry_emit '$tfile' e s t k 1 5"
  [ "$status" -eq 0 ]
  [ "$(wc -l < "$tfile")" -eq 2 ]
  [ "$(head -1 "$tfile")" = '{"existing":"line"}' ]
}
