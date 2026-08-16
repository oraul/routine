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
    | grep '"script":"login rejects bad password \[' | grep -q '"exit":1'
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

@test "a silent record is impossible: rejected scenario exits 3" {
  make_ticket
  run env ROUTINE_TICKET_DIR="$ticket" "$ROUTINE_REPO_ROOT/bin/routine-tdd" \
    red 'scenario with a " quote' -- false
  [ "$status" -eq 3 ]
  case "$output" in *recorded*) false ;; *) ;; esac
  case "$output" in *"invalid"*|*"rejected"*) ;; *) false ;; esac
  [ ! -f "$ticket/telemetry.jsonl" ] || ! grep -q 'tdd.red' "$ticket/telemetry.jsonl"
}

@test "characterize evidence: passing command records the pass" {
  make_ticket
  run env ROUTINE_TICKET_DIR="$ticket" "$ROUTINE_REPO_ROOT/bin/routine-tdd" \
    characterize "empty order totals zero" -- true
  [ "$status" -eq 0 ]
  grep '"event":"tdd.characterize"' "$ticket/telemetry.jsonl" \
    | grep '"script":"empty order totals zero \[' | grep -q '"exit":0'
}

@test "a red characterization is refused, evidence recorded" {
  make_ticket
  run env ROUTINE_TICKET_DIR="$ticket" "$ROUTINE_REPO_ROOT/bin/routine-tdd" \
    characterize "scenario" -- bash -c 'exit 5'
  [ "$status" -ne 0 ]
  case "$output" in *"characterization is red"*) ;; *) false ;; esac
  grep '"event":"tdd.characterize"' "$ticket/telemetry.jsonl" | grep -q '"exit":5'
}

@test "a refused characterization persists the command's verbatim output" {
  make_ticket
  run env ROUTINE_TICKET_DIR="$ticket" "$ROUTINE_REPO_ROOT/bin/routine-tdd" \
    characterize "scenario" -- bash -c 'echo out-line; echo err-line >&2; exit 1'
  [ "$status" -ne 0 ]
  log="$ticket/briefings/01-auth/tasks/01-login/characterize.log"
  [ -f "$log" ]
  grep -q "out-line" "$log"
  grep -q "err-line" "$log"
}

@test "a refused characterization log is truncated, not appended, per run" {
  make_ticket
  log="$ticket/briefings/01-auth/tasks/01-login/characterize.log"
  env ROUTINE_TICKET_DIR="$ticket" "$ROUTINE_REPO_ROOT/bin/routine-tdd" \
    characterize "scenario" -- bash -c 'echo first-run; exit 1' > /dev/null || true
  [ -f "$log" ]
  env ROUTINE_TICKET_DIR="$ticket" "$ROUTINE_REPO_ROOT/bin/routine-tdd" \
    characterize "scenario" -- bash -c 'echo second-run; exit 1' > /dev/null || true
  grep -q "second-run" "$log"
  ! grep -q "first-run" "$log"
}

@test "the evidence binds red and green to the same command" {
  make_ticket
  env ROUTINE_TICKET_DIR="$ticket" "$ROUTINE_REPO_ROOT/bin/routine-tdd" \
    red "login works" -- false > /dev/null
  env ROUTINE_TICKET_DIR="$ticket" "$ROUTINE_REPO_ROOT/bin/routine-tdd" \
    green "login works" -- true > /dev/null
  red_s="$(grep '"event":"tdd.red"' "$ticket/telemetry.jsonl" | grep -o '"script":"[^"]*"')"
  green_s="$(grep '"event":"tdd.green"' "$ticket/telemetry.jsonl" | grep -o '"script":"[^"]*"')"
  case "$red_s" in *'login works ['*']'*) ;; *) false ;; esac
  [ "$red_s" != "$green_s" ]
  env ROUTINE_TICKET_DIR="$ticket" "$ROUTINE_REPO_ROOT/bin/routine-tdd" \
    green "login works" -- false > /dev/null 2>&1 || true
  same="$(grep '"event":"tdd.green"' "$ticket/telemetry.jsonl" | tail -1 | grep -o '"script":"[^"]*"')"
  [ "$red_s" = "$same" ]
}
