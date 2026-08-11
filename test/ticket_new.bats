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
}

@test "allocation is sequential and skips archived ids" {
  setup_fixture
  mkdir -p "$groot/runs/app/tickets/0001" "$groot/runs/app/tickets/archive/0002"
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
