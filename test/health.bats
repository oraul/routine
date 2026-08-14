#!/usr/bin/env bats

load test_helper

TAB="$(printf '\t')"

# A ticket frozen at a chosen death point. Telemetry is appended in the
# order the protocol would have written it; line order is time order.
make_ticket() {
  ticket="$BATS_TEST_TMPDIR/app/tickets/0001"
  mkdir -p "$ticket/briefings/01-auth/tasks/01-login"
  : > "$ticket/telemetry.jsonl"
  : > "$ticket/index.tsv"
  tel ticket.new bin/routine-ticket-new "" 0
}

# tel <event> <script> <task> <exit>
tel() {
  printf '{"ts":"2026-01-01T00:00:00Z","event":"%s","script":"%s","ticket":"0001","task":"%s","exit":%s,"ms":1}\n' \
    "$1" "$2" "$3" "$4" >> "$ticket/telemetry.jsonl"
}

row() {
  printf '%s%s01-auth%s01-login%s%s%s2026-01-01T00:00:00Z\n' \
    "$1" "$TAB" "$TAB" "$TAB" "$2" "$TAB" >> "$ticket/index.tsv"
}

health() { run "$ROUTINE_REPO_ROOT/bin/routine-health" "$ticket"; }

@test "a fresh ticket is in preflight and says so" {
  make_ticket
  health
  [ "$status" -eq 0 ]
  case "$output" in *preflight*) ;; *) false ;; esac
  case "$output" in *"next:"*"routine-gate preflight"*) ;; *) false ;; esac
}

@test "past preflight with no analyst gate is specify, with revises shown" {
  make_ticket
  tel gate.preflight bin/routine-gate "" 0
  tel spec.lint bin/routine-spec-lint "" 1
  tel spec.lint bin/routine-spec-lint "" 1
  health
  [ "$status" -eq 0 ]
  case "$output" in *specify*) ;; *) false ;; esac
  case "$output" in *"revises 2/3"*) ;; *) false ;; esac
}

@test "a defect return reopens the budget the reader reports" {
  make_ticket
  tel gate.preflight bin/routine-gate "" 0
  tel spec.lint bin/routine-spec-lint "" 1
  tel spec.lint bin/routine-spec-lint "" 1
  tel spec.defective bin/routine-defect 01-01 0
  health
  case "$output" in *"revises 0/3"*) ;; *) false ;; esac
}

@test "a passed analyst gate with no approval waits for the human" {
  make_ticket
  tel gate.preflight bin/routine-gate "" 0
  tel gate.analyst bin/routine-gate "" 0
  health
  [ "$status" -eq 1 ]
  case "$output" in *approve*) ;; *) false ;; esac
}

@test "an interrupted task is named with the command that resumes it" {
  make_ticket
  tel gate.preflight bin/routine-gate "" 0
  tel gate.analyst bin/routine-gate "" 0
  tel ticket.approve bin/routine-approve "" 0
  row 01-01 in_progress
  tel ticket.next bin/routine-next 01-01 0
  health
  [ "$status" -eq 0 ]
  case "$output" in *develop*) ;; *) false ;; esac
  case "$output" in *01-01*) ;; *) false ;; esac
  case "$output" in *"next:"*routine-next*) ;; *) false ;; esac
}

@test "death between a green gate and done is named as done's turn" {
  make_ticket
  tel gate.preflight bin/routine-gate "" 0
  tel gate.analyst bin/routine-gate "" 0
  tel ticket.approve bin/routine-approve "" 0
  row 01-01 in_progress
  tel ticket.next bin/routine-next 01-01 0
  tel gate.developer bin/routine-gate 01-01 0
  health
  [ "$status" -eq 0 ]
  case "$output" in *"next:"*routine-done*) ;; *) false ;; esac
}

@test "a blocked line needs a human" {
  make_ticket
  tel gate.preflight bin/routine-gate "" 0
  tel gate.analyst bin/routine-gate "" 0
  tel ticket.approve bin/routine-approve "" 0
  row 01-01 blocked
  health
  [ "$status" -eq 1 ]
  case "$output" in *blocked*) ;; *) false ;; esac
  case "$output" in *unblock*) ;; *) false ;; esac
}

@test "every task done points at conclude" {
  make_ticket
  tel gate.preflight bin/routine-gate "" 0
  tel gate.analyst bin/routine-gate "" 0
  tel ticket.approve bin/routine-approve "" 0
  row 01-01 done
  health
  [ "$status" -eq 0 ]
  case "$output" in *conclude*) ;; *) false ;; esac
}

@test "an exhausted budget needs a human" {
  make_ticket
  tel gate.preflight bin/routine-gate "" 0
  for _ in 1 2 3 4; do tel spec.lint bin/routine-spec-lint "" 1; done
  health
  [ "$status" -eq 1 ]
  case "$output" in *abort*) ;; *) false ;; esac
}

@test "the reader writes nothing and repeats itself" {
  make_ticket
  tel gate.preflight bin/routine-gate "" 0
  before="$(cd "$ticket" && find . -type f -exec cksum {} \; | sort)"
  health
  first="$output"
  health
  after="$(cd "$ticket" && find . -type f -exec cksum {} \; | sort)"
  [ "$before" = "$after" ]
  [ "$first" = "$output" ]
}

@test "usage without a ticket" {
  run "$ROUTINE_REPO_ROOT/bin/routine-health" "$BATS_TEST_TMPDIR/nope"
  [ "$status" -eq 2 ]
  case "$output" in *usage*) ;; *) false ;; esac
}
