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

# No-argument mode: WIP is 1, so resolving the active ticket is a script's
# job — a fresh session must never guess which run it is resuming.
make_app() {
  hroot="$BATS_TEST_TMPDIR/hroot"
  # The app key is the target's basename (lib/paths.sh), so the fixture
  # target must be named for the app whose tickets it owns.
  mkdir -p "$hroot/runs/app/tickets" "$BATS_TEST_TMPDIR/work/app"
  tgt="$BATS_TEST_TMPDIR/work/app"
}

plant() {
  mkdir -p "$hroot/runs/app/tickets/$1"
  printf '{"ts":"2026-01-01T00:00:00Z","event":"ticket.new","script":"bin/routine-ticket-new","ticket":"%s","task":"","exit":0,"ms":1}\n' "$1" \
    > "$hroot/runs/app/tickets/$1/telemetry.jsonl"
  : > "$hroot/runs/app/tickets/$1/index.tsv"
}

@test "no active ticket says a new one is legitimate" {
  make_app
  run env ROUTINE_ROOT="$hroot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-health"
  [ "$status" -eq 0 ]
  case "$output" in *"no active ticket"*) ;; *) false ;; esac
  case "$output" in *routine-ticket-new*) ;; *) false ;; esac
}

@test "one active ticket is adopted and reported, never duplicated" {
  make_app
  plant 0001
  run env ROUTINE_ROOT="$hroot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-health"
  [ "$status" -eq 0 ]
  case "$output" in *0001*) ;; *) false ;; esac
  case "$output" in *preflight*) ;; *) false ;; esac
  ! printf '%s' "$output" | grep -q 'routine-ticket-new'
}

@test "two active tickets are themselves the diagnosis" {
  make_app
  plant 0001
  plant 0002
  run env ROUTINE_ROOT="$hroot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-health"
  [ "$status" -eq 1 ]
  case "$output" in *0001*) ;; *) false ;; esac
  case "$output" in *0002*) ;; *) false ;; esac
  case "$output" in *"WIP is 1"*) ;; *) false ;; esac
}

@test "a stale index.tsv.new is named as the mid-write artifact" {
  make_ticket
  : > "$ticket/index.tsv.new"
  health
  case "$output" in *index.tsv.new*) ;; *) false ;; esac
  case "$output" in *"intact"*) ;; *) false ;; esac
}

@test "a surviving gate reason is named by the reader" {
  make_ticket
  tel gate.preflight bin/routine-gate "" 0
  printf 'routine-gate: index row 01-01 has no directory\n' > "$ticket/gate.log"
  health
  case "$output" in *gate.log*) ;; *) false ;; esac
}

# A developer that died mid-task leaves its work uncommitted. The
# resuming session must be told — resuming forward is normal, but the
# replacement developer is stateless and cannot see it otherwise.
make_dirty_target() {
  dtgt="$BATS_TEST_TMPDIR/dirty"
  mkdir -p "$dtgt"
  git -C "$dtgt" -c init.defaultBranch=main init -q
  git -C "$dtgt" -c user.name=t -c user.email=t@example.invalid \
    commit -q --allow-empty -m root
  printf 'half a failing test\n' > "$dtgt/spec_login.rb"
}

@test "a predecessor's partial work is named, without blocking the resume" {
  make_ticket
  make_dirty_target
  tel gate.preflight bin/routine-gate "" 0
  tel gate.analyst bin/routine-gate "" 0
  tel ticket.approve bin/routine-approve "" 0
  row 01-01 in_progress
  tel ticket.next bin/routine-next 01-01 0
  run env TARGET="$dtgt" "$ROUTINE_REPO_ROOT/bin/routine-health" "$ticket"
  [ "$status" -eq 0 ]
  case "$output" in *uncommitted*) ;; *) false ;; esac
  case "$output" in *spec_login.rb*) ;; *) false ;; esac
  case "$output" in *develop*) ;; *) false ;; esac
}

@test "a clean target says nothing about partial work" {
  make_ticket
  make_dirty_target
  rm "$dtgt/spec_login.rb"
  tel gate.preflight bin/routine-gate "" 0
  tel gate.analyst bin/routine-gate "" 0
  tel ticket.approve bin/routine-approve "" 0
  row 01-01 in_progress
  run env TARGET="$dtgt" "$ROUTINE_REPO_ROOT/bin/routine-health" "$ticket"
  [ "$status" -eq 0 ]
  ! printf '%s' "$output" | grep -qi 'uncommitted'
}
