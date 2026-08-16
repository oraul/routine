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

@test "defect return carries the characterization transcript into defect.md" {
  make_ticket
  clog="$ticket/briefings/01-auth/tasks/01-login/characterize.log"
  printf 'AssertionError: expected total 0 got 300\n  at test_totals.py:12\n' > "$clog"
  run "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "characterization was false: totals miscount on last-item removal"
  [ "$status" -eq 0 ]
  dfile="$ticket/briefings/01-auth/tasks/01-login/defect.md"
  grep -q 'totals miscount on last-item removal' "$dfile"
  grep -q 'AssertionError: expected total 0 got 300' "$dfile"
  grep -q 'test_totals.py:12' "$dfile"
  grep -q 'characterize.log' "$dfile"
}

@test "defect return without a characterization log omits the transcript" {
  make_ticket
  run "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "scenario 3 contradicts the acceptance list"
  [ "$status" -eq 0 ]
  dfile="$ticket/briefings/01-auth/tasks/01-login/defect.md"
  grep -q 'scenario 3 contradicts the acceptance list' "$dfile"
  ! grep -q 'characterize.log' "$dfile"
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

# The return budget is the same shared counter the developer gate spends,
# counted per task rather than per ticket (design.md).
@test "three defect returns for one task still work" {
  make_ticket
  "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "first" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "second" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket" > /dev/null
  run "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "third"
  [ "$status" -eq 0 ]
  [ "$(grep -c '"event":"spec.defective"' "$ticket/telemetry.jsonl")" -eq 3 ]
}

@test "a fourth defect return for one task refuses naming routine-abort" {
  make_ticket
  "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "first" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "second" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "third" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket" > /dev/null
  run "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "fourth"
  [ "$status" -ne 0 ]
  case "$output" in *routine-abort*) ;; *) false ;; esac
  [ "$(grep -c '"event":"spec.defective"' "$ticket/telemetry.jsonl")" -eq 3 ]
  grep -q "^01-01	.*	in_progress	" "$ticket/index.tsv"
}

@test "defect returns on one task never count toward another" {
  ticket="$BATS_TEST_TMPDIR/0003"
  mkdir -p "$ticket/briefings/01-auth/tasks/01-login" "$ticket/briefings/01-auth/tasks/02-logout"
  : > "$ticket/index.tsv"
  "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "a" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "b" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "c" > /dev/null
  # Move task 01 out of the line and bring task 02 in progress directly —
  # only the shared telemetry file matters here, not the normal sequencing.
  run bash -c '. "$1/lib/index.sh"; index_set_status "$2/index.tsv" 01-01 done "2026-01-01T00:00:00Z"; index_set_status "$2/index.tsv" 01-02 in_progress "2026-01-01T00:00:00Z"' _ \
    "$ROUTINE_REPO_ROOT" "$ticket"
  [ "$status" -eq 0 ]
  run "$ROUTINE_REPO_ROOT/bin/routine-defect" "$ticket" "d"
  [ "$status" -eq 0 ]
}
