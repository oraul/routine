#!/usr/bin/env bats

load test_helper

make_ticket() {
  ticket="$BATS_TEST_TMPDIR/0001"
  mkdir -p "$ticket/briefings/01-auth/tasks/01-login"
  : > "$ticket/index.tsv"
  "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket" > /dev/null
}

@test "defect return writes evidence, resets the task, and records the event" {
  make_ticket
  run "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "scenarios 2 and 3 contradict each other"
  [ "$status" -eq 0 ]
  grep -q 'contradict' "$ticket/briefings/01-auth/tasks/01-login/defect.md"
  grep -q "^01-01	01-auth	01-login	pending	" "$ticket/index.tsv"
  [ "$(grep -c '"event":"spec.defective"' "$ticket/telemetry.jsonl")" -eq 1 ]
  grep '"event":"spec.defective"' "$ticket/telemetry.jsonl" | grep -q '"exit":1'
}

@test "defect refuses without a reason" {
  make_ticket
  run "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket"
  [ "$status" -ne 0 ]
  grep -q "^01-01	.*	in_progress	" "$ticket/index.tsv"
}

@test "defect refuses without an in_progress task" {
  make_ticket
  "$ROUTINE_REPO_ROOT/bin/routine-done" "$ticket" > /dev/null
  run "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "reason"
  [ "$status" -ne 0 ]
  case "$output" in *in_progress*) ;; *) false ;; esac
}

@test "a second defect return keeps the first reason" {
  make_ticket
  "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "first: scenario contradicts acceptance" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "second: still contradictory after re-spec" > /dev/null
  dfile="$ticket/briefings/01-auth/tasks/01-login/defect.md"
  grep -q "first: scenario contradicts acceptance" "$dfile"
  grep -q "second: still contradictory after re-spec" "$dfile"
  [ "$(grep -c '^## ' "$dfile")" -eq 2 ]
}
