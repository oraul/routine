#!/usr/bin/env bats

load test_helper

make_ticket() {
  tickets="$BATS_TEST_TMPDIR/tickets"
  ticket="$tickets/0001"
  mkdir -p "$ticket/briefings/01-auth/tasks/01-login"
  printf 'partial requirement\n' > "$ticket/requirement.md"
  : > "$ticket/index.tsv"
  printf '{"ts":"2026-01-01T00:00:00Z","event":"ticket.new","script":"bin/routine-ticket-new","ticket":"0001","task":"","exit":0,"ms":1}\n' \
    > "$ticket/telemetry.jsonl"
}

@test "abort archives with evidence and prints the path" {
  make_ticket
  run "$ROUTINE_REPO_ROOT/bin/routine-abort" "$ticket" "revise limit exhausted on grammar"
  [ "$status" -eq 0 ]
  case "$output" in *"$tickets/archive/0001"*) ;; *) false ;; esac
  [ ! -d "$ticket" ]
  [ -f "$tickets/archive/0001/abort.md" ]
  grep -q "revise limit exhausted on grammar" "$tickets/archive/0001/abort.md"
  [ -f "$tickets/archive/0001/requirement.md" ]
  tail -1 "$tickets/archive/0001/telemetry.jsonl" | grep -q '"event":"ticket.abort"'
  [ ! -f "$tickets/archive/0001/report.md" ]
}

@test "abort without a reason is refused" {
  make_ticket
  run "$ROUTINE_REPO_ROOT/bin/routine-abort" "$ticket"
  [ "$status" -eq 2 ]
  case "$output" in *reason*) ;; *) false ;; esac
  [ -d "$ticket" ]
}

@test "abort on a missing ticket is usage" {
  run "$ROUTINE_REPO_ROOT/bin/routine-abort" "$BATS_TEST_TMPDIR/nope" "why"
  [ "$status" -eq 2 ]
}

@test "an aborted id is never reallocated" {
  make_ticket
  "$ROUTINE_REPO_ROOT/bin/routine-abort" "$ticket" "dead end" > /dev/null
  groot="$BATS_TEST_TMPDIR/groot"
  mkdir -p "$groot/runs/app"
  mv "$tickets" "$groot/runs/app/tickets"
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-ticket-new"
  [ "$status" -eq 0 ]
  case "$output" in *0002*) ;; *) false ;; esac
}
