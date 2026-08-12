#!/usr/bin/env bats

load test_helper

make_ticket() {
  ticket="$BATS_TEST_TMPDIR/0001"
  mkdir -p "$ticket/briefings/01-auth/tasks/01-login"
  : > "$ticket/index.tsv"
  "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket" > /dev/null
}

@test "red evidence: failing command passes and records its exit" {
  make_ticket
  run env ROUTINE_TICKET_DIR="$ticket" "$ROUTINE_REPO_ROOT/bin/routine-tdd" \
    red "login rejects bad password" -- false
  [ "$status" -eq 0 ]
  grep '"event":"tdd.red"' "$ticket/telemetry.jsonl" \
    | grep '"script":"login rejects bad password"' | grep -q '"exit":1'
  grep '"event":"tdd.red"' "$ticket/telemetry.jsonl" \
    | grep '"ticket":"0001"' | grep -q '"task":"01-01"'
}

@test "a red that isn't red is refused, evidence recorded" {
  make_ticket
  run env ROUTINE_TICKET_DIR="$ticket" "$ROUTINE_REPO_ROOT/bin/routine-tdd" \
    red "scenario" -- true
  [ "$status" -ne 0 ]
  case "$output" in *"red that isn't red"*) ;; *) false ;; esac
  grep '"event":"tdd.red"' "$ticket/telemetry.jsonl" | grep -q '"exit":0'
}

@test "green relays a failing command's exit" {
  make_ticket
  run env ROUTINE_TICKET_DIR="$ticket" "$ROUTINE_REPO_ROOT/bin/routine-tdd" \
    green "scenario" -- bash -c 'exit 7'
  [ "$status" -eq 7 ]
  grep '"event":"tdd.green"' "$ticket/telemetry.jsonl" | grep -q '"exit":7'
}

@test "green passes when the command passes" {
  make_ticket
  run env ROUTINE_TICKET_DIR="$ticket" "$ROUTINE_REPO_ROOT/bin/routine-tdd" \
    green "scenario" -- true
  [ "$status" -eq 0 ]
  grep '"event":"tdd.green"' "$ticket/telemetry.jsonl" | grep -q '"exit":0'
}

@test "refuses without ticket context and on bad usage" {
  run env -u ROUTINE_TICKET_DIR "$ROUTINE_REPO_ROOT/bin/routine-tdd" \
    red "s" -- true
  [ "$status" -ne 0 ]
  case "$output" in *ROUTINE_TICKET_DIR*) ;; *) false ;; esac
  run "$ROUTINE_REPO_ROOT/bin/routine-tdd" purple "s" -- true
  [ "$status" -eq 2 ]
  case "$output" in *usage*) ;; *) false ;; esac
  run "$ROUTINE_REPO_ROOT/bin/routine-tdd" red "s"
  [ "$status" -eq 2 ]
}
