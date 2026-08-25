#!/usr/bin/env bats

load test_helper

checker="bin/routine-pr-body-check"

# A pull request body fixture and a harness telemetry destination shaped
# the way harness_telemetry.bats builds one: TARGET is a real git repo
# whose basename names the runs/<app> directory the fixture ROUTINE_ROOT
# already has waiting.
make_body() {
  body="$BATS_TEST_TMPDIR/body.md"
  printf '%s\n' "$@" > "$body"
}

make_telemetry_fixture() {
  fixture="$BATS_TEST_TMPDIR/fixture"
  mkdir -p "$fixture/runs/app"
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt"
  git -C "$tgt" -c init.defaultBranch=main init -q
  git -C "$tgt" -c user.name=t -c user.email=t@example.invalid \
    commit -q --allow-empty -m "root"
}

@test "an injected session url is caught without echoing it" {
  make_body "Some description of the change." "" \
    "See https://claude.ai/code/session_0000000000000000000000000"
  run "$ROUTINE_REPO_ROOT/$checker" "$body"
  [ "$status" -eq 1 ]
  case "$output" in *"line 3"*) ;; *) false ;; esac
  case "$output" in *"session URL"*) ;; *) false ;; esac
  case "$output" in \
    *"claude.ai/code/session_0000000000000000000000000"*) false ;; \
    *) ;; \
  esac
}

@test "a github token shape is caught as a credential class" {
  make_body "Config note." "" \
    "token = ghp_AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  run "$ROUTINE_REPO_ROOT/$checker" "$body"
  [ "$status" -eq 1 ]
  case "$output" in *"line 3"*) ;; *) false ;; esac
  case "$output" in *"credential"*) ;; *) false ;; esac
}

@test "a clean body with the attribution footer passes" {
  make_body "Fixes the thing described in the issue." "" \
    "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
  run "$ROUTINE_REPO_ROOT/$checker" "$body"
  [ "$status" -eq 0 ]
}

@test "no argument names usage and refuses" {
  run "$ROUTINE_REPO_ROOT/$checker"
  [ "$status" -eq 2 ]
  case "$output" in *"usage"*) ;; *) false ;; esac
}

@test "an unreadable file path is also a usage error" {
  run "$ROUTINE_REPO_ROOT/$checker" "$BATS_TEST_TMPDIR/does-not-exist.md"
  [ "$status" -eq 2 ]
  case "$output" in *"usage"*) ;; *) false ;; esac
}

@test "the run emits one harness dot prbody telemetry line" {
  make_telemetry_fixture
  make_body "Clean prose only."
  run env ROUTINE_ROOT="$fixture" TARGET="$tgt" \
    "$ROUTINE_REPO_ROOT/$checker" "$body"
  [ "$status" -eq 0 ]
  grep '"event":"harness.prbody"' "$fixture/runs/app/telemetry.jsonl" \
    | grep -q '"exit":0'
}
