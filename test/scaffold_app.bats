#!/usr/bin/env bats

load test_helper

setup_fixture() {
  groot="$BATS_TEST_TMPDIR/groot"
  mkdir -p "$groot"
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt"
  git -C "$tgt" -c init.defaultBranch=main init -q
  git -C "$tgt" -c user.name=test -c user.email=test@example.invalid \
    commit -q --allow-empty -m "root"
}

@test "first scaffold creates state and halts naming developer.sh" {
  setup_fixture
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-scaffold"
  [ "$status" -ne 0 ]
  [ -d "$groot/runs/app/hooks" ]
  [ -d "$groot/runs/app/tickets" ]
  case "$output" in *"runs/app/hooks/developer.sh"*) ;; *) false ;; esac
  grep '"event":"app.scaffold"' "$groot/runs/app/telemetry.jsonl" \
    | grep -q '"exit":1'
}

@test "scaffold is idempotent and passes once the hook exists" {
  setup_fixture
  mkdir -p "$groot/runs/app/hooks"
  printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$groot/runs/app/hooks/developer.sh"
  touch "$groot/runs/app/tickets" 2>/dev/null || mkdir -p "$groot/runs/app/tickets"
  printf 'keep' > "$groot/runs/app/hooks/marker"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-scaffold"
  [ "$status" -eq 0 ]
  [ "$(cat "$groot/runs/app/hooks/marker")" = "keep" ]
  grep '"event":"app.scaffold"' "$groot/runs/app/telemetry.jsonl" \
    | grep -q '"exit":0'
}

@test "deps leaves app-level evidence only when app state exists" {
  setup_fixture
  printf 'gem "rails"\n' > "$tgt/Gemfile"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-deps"
  [ "$status" -eq 0 ]
  [ ! -f "$groot/runs/app/telemetry.jsonl" ]
  mkdir -p "$groot/runs/app"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-deps"
  [ "$status" -eq 0 ]
  grep '"event":"app.deps"' "$groot/runs/app/telemetry.jsonl" | grep -q '"exit":0'
}
