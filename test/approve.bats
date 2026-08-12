#!/usr/bin/env bats

load test_helper

make_ticket() {
  ticket="$BATS_TEST_TMPDIR/0001"
  mkdir -p "$ticket"
  printf '{"ts":"2026-01-01T00:00:00Z","event":"ticket.new","script":"bin/routine-ticket-new","ticket":"0001","task":"","exit":0,"ms":1}\n' \
    > "$ticket/telemetry.jsonl"
}

pass_analyst_gate() {
  printf '{"ts":"2026-01-01T00:02:00Z","event":"gate.analyst","script":"bin/routine-gate","ticket":"0001","task":"","exit":0,"ms":10}\n' \
    >> "$ticket/telemetry.jsonl"
}

@test "approval leaves a line and keeps the human's note" {
  make_ticket
  pass_analyst_gate
  run "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket" "ship without the CSV export"
  [ "$status" -eq 0 ]
  tail -1 "$ticket/telemetry.jsonl" | grep -q '"event":"ticket.approve"'
  grep -q "ship without the CSV export" "$ticket/approve.md"
  grep -qE '^## [0-9]{4}-' "$ticket/approve.md"
}

@test "a second approval keeps the first note" {
  make_ticket
  pass_analyst_gate
  "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket" "first pass ok" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket" "re-approved after defect" > /dev/null
  grep -q "first pass ok" "$ticket/approve.md"
  grep -q "re-approved after defect" "$ticket/approve.md"
}

@test "ungated artifacts cannot be approved" {
  make_ticket
  run "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket" "note"
  [ "$status" -ne 0 ]
  case "$output" in *gate.analyst*) ;; *) false ;; esac
}

@test "a note is optional, the evidence is not" {
  make_ticket
  pass_analyst_gate
  run "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket"
  [ "$status" -eq 0 ]
  tail -1 "$ticket/telemetry.jsonl" | grep -q '"event":"ticket.approve"'
}
