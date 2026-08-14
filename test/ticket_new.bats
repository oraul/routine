#!/usr/bin/env bats

load test_helper

setup_fixture() {
  groot="$BATS_TEST_TMPDIR/groot"
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$groot/runs/app/tickets" "$tgt"
  git -C "$tgt" -c init.defaultBranch=main init -q
  git -C "$tgt" -c user.name=test -c user.email=test@example.invalid \
    commit -q --allow-empty -m "root"
}

@test "first ticket is 0001 with an empty index" {
  setup_fixture
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-ticket-new"
  [ "$status" -eq 0 ]
  [ "$output" = "$groot/runs/app/tickets/0001" ]
  [ -f "$groot/runs/app/tickets/0001/index.tsv" ]
  [ ! -s "$groot/runs/app/tickets/0001/index.tsv" ]
  [ "$(grep -c '"event":"ticket.new"' "$groot/runs/app/tickets/0001/telemetry.jsonl")" -eq 1 ]
}

@test "allocation is sequential and skips archived ids" {
  setup_fixture
  # Archived-only history: a live 0001 would be a WIP=1 violation, which
  # the allocator now refuses in its own test below.
  mkdir -p "$groot/runs/app/tickets/archive/0001" "$groot/runs/app/tickets/archive/0002"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-ticket-new"
  [ "$status" -eq 0 ]
  [ "$output" = "$groot/runs/app/tickets/0003" ]
}

@test "refuses before scaffold" {
  groot="$BATS_TEST_TMPDIR/bare"
  mkdir -p "$groot"
  run env ROUTINE_ROOT="$groot" TARGET="$BATS_TEST_TMPDIR" "$ROUTINE_REPO_ROOT/bin/routine-ticket-new"
  [ "$status" -ne 0 ]
  case "$output" in *routine-scaffold*) ;; *) false ;; esac
}

# WIP is 1: a run that died mid-flight must be adopted or ended, never
# orphaned by a second allocation.
@test "a live ticket blocks a second allocation and names both roads" {
  setup_fixture
  env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-ticket-new" > /dev/null
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-ticket-new"
  [ "$status" -eq 3 ]
  case "$output" in *0001*) ;; *) false ;; esac
  case "$output" in *"adopt it"*) ;; *) false ;; esac
  case "$output" in *routine-abort*) ;; *) false ;; esac
  [ ! -d "$groot/runs/app/tickets/0002" ]
}

@test "archived tickets never block allocation" {
  setup_fixture
  env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-ticket-new" > /dev/null
  mkdir -p "$groot/runs/app/tickets/archive"
  mv "$groot/runs/app/tickets/0001" "$groot/runs/app/tickets/archive/"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-ticket-new"
  [ "$status" -eq 0 ]
  case "$output" in *0002*) ;; *) false ;; esac
}
