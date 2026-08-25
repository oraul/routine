#!/usr/bin/env bats

load test_helper

# A healthy fixture root the harness scripts can be pointed at, plus app
# state so their verdicts have a destination.
make_fixture() {
  fixture="$BATS_TEST_TMPDIR/fixture"
  mkdir -p "$fixture/bin" "$fixture/lib" "$fixture/test" "$fixture/runs/app"
  printf '%s\n' '#!/usr/bin/env bash' \
    '# routine-script: good' \
    '# routine-description: A clean fixture script' \
    '# routine-exit: 0 — ok printed' \
    '# routine-test: test/pass.bats' \
    'printf ok' > "$fixture/bin/good"
  chmod +x "$fixture/bin/good"
  printf '%s\n' '@test "the good fixture script passes" { [ -f "$BATS_TEST_FILENAME" ]; }' > "$fixture/test/pass.bats"
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt"
  git -C "$tgt" -c init.defaultBranch=main init -q
  git -C "$tgt" -c user.name=t -c user.email=t@example.invalid \
    commit -q --allow-empty -m "root"
}

# The repo is its own app: the destination ships as tracked content, so
# repo-context gate verdicts record in every clone instead of depending
# on an accidental scaffold. Only the marker is tracked; session state
# under runs/ stays ignored.
@test "the repository ships its own harness destination" {
  run git -C "$ROUTINE_REPO_ROOT" check-ignore -q runs/routine/README.md
  [ "$status" -ne 0 ]
  run git -C "$ROUTINE_REPO_ROOT" check-ignore -q runs/routine/telemetry.jsonl
  [ "$status" -eq 0 ]
  run git -C "$ROUTINE_REPO_ROOT" check-ignore -q runs/shopapp/telemetry.jsonl
  [ "$status" -eq 0 ]
  [ "$(git -C "$ROUTINE_REPO_ROOT" ls-files runs/)" = "runs/routine/README.md" ]
}

@test "selfcheck records its verdict against existing app state" {
  make_fixture
  run env ROUTINE_ROOT="$fixture" TARGET="$tgt" \
    "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -eq 0 ]
  grep '"event":"harness.selfcheck"' "$fixture/runs/app/telemetry.jsonl" \
    | grep -q '"exit":0'
}

@test "no app state means no invented destination" {
  make_fixture
  rm -rf "$fixture/runs/app"
  run env ROUTINE_ROOT="$fixture" TARGET="$tgt" \
    "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -eq 0 ]
  [ -z "$(find "$fixture" -name telemetry.jsonl)" ]
}

@test "release-check records a refusal with its exit code" {
  make_fixture
  run env ROUTINE_ROOT="$fixture" TARGET="$tgt" \
    "$ROUTINE_REPO_ROOT/bin/routine-release-check" v9.9.9
  [ "$status" -ne 0 ]
  grep '"event":"harness.release"' "$fixture/runs/app/telemetry.jsonl" \
    | grep -q '"exit":1'
}

@test "convention-check records its verdict" {
  make_fixture
  run env ROUTINE_ROOT="$fixture" TARGET="$tgt" \
    "$ROUTINE_REPO_ROOT/bin/routine-convention-check" HEAD
  [ "$status" -eq 0 ]
  grep '"event":"harness.convention"' "$fixture/runs/app/telemetry.jsonl" \
    | grep -q '"exit":0'
}
