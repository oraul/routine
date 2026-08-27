#!/usr/bin/env bats

load test_helper

# Builds a minimal healthy plugin tree the selfcheck can be pointed at
# via ROUTINE_ROOT (Law 6): one clean script, one lib, one passing test.
make_fixture() {
  fixture="$BATS_TEST_TMPDIR/fixture"
  mkdir -p "$fixture/bin" "$fixture/lib" "$fixture/test"
  printf '%s\n' '#!/usr/bin/env bash' \
    '# routine-script: good' \
    '# routine-description: A clean fixture script' \
    '# routine-exit: 0 — ok printed' \
    '# routine-test: test/pass.bats' \
    'printf ok' > "$fixture/bin/good"
  chmod +x "$fixture/bin/good"
  printf '%s\n' '# shellcheck shell=bash' 'noop() { :; }' > "$fixture/lib/noop.sh"
  printf '%s\n' '@test "good and bad fixture scripts pass" { [ -f "$BATS_TEST_FILENAME" ]; }' \
    > "$fixture/test/pass.bats"
}

# Drops a go.mod plus a cmd/routine package that fails to compile into
# the fixture root, so the core build stage has a module to find and a
# guaranteed compile error to trip over.
add_broken_core_module() {
  mkdir -p "$fixture/cmd/routine"
  printf '%s\n' 'module fixture.local/core' '' 'go 1.21' > "$fixture/go.mod"
  printf '%s\n' 'package main' 'func main() { this is not valid go syntax' \
    > "$fixture/cmd/routine/main.go"
}

# A shellcheck-dirty script whose contract is nonetheless honest.
add_bad() {
  printf '%s\n' '#!/usr/bin/env bash' \
    '# routine-script: bad' \
    '# routine-description: A shellcheck-dirty fixture script' \
    '# routine-exit: 0 — cat output' \
    '# routine-test: test/pass.bats' \
    'cat $1' > "$fixture/bin/bad"
  chmod +x "$fixture/bin/bad"
}

@test "green path: clean fixture without caffeine sidecars exits 0" {
  make_fixture
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -eq 0 ]
}

@test "malformed caffeine topic aborts before shellcheck" {
  make_fixture
  mkdir -p "$fixture/caffeine/ruby"
  printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$fixture/caffeine/ruby/orphan.sh"
  add_bad
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -ne 0 ]
  case "$output" in *caffeine-lint*orphan*) ;; *) false ;; esac
  case "$output" in *"shellcheck failed"*) false ;; *) ;; esac
}

@test "lint failure exits non-zero and skips the test stage" {
  make_fixture
  add_bad
  printf '@test "marker for good and bad" { touch "%s/tests-ran"; }\n' "$fixture" \
    > "$fixture/test/pass.bats"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -ne 0 ]
  [ ! -f "$fixture/tests-ran" ]
}

@test "failing bats suite exits non-zero" {
  make_fixture
  printf '%s\n' '@test "the fixture suite fails on purpose" { [ -f "/routine-absent-on-purpose" ]; }' > "$fixture/test/fail.bats"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -ne 0 ]
}

@test "a lying contract aborts before shellcheck" {
  make_fixture
  printf '%s\n' '#!/usr/bin/env bash' 'printf ok' > "$fixture/bin/naked"
  chmod +x "$fixture/bin/naked"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -ne 0 ]
  case "$output" in *script-lint*naked*) ;; *) false ;; esac
  case "$output" in *"shellcheck failed"*) false ;; *) ;; esac
}

@test "a nameless claim aborts before the suite" {
  make_fixture
  printf '%s\n' '@test "it works" { true; }' > "$fixture/test/bad.bats"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -ne 0 ]
  case "$output" in *test-lint*"it works"*) ;; *) false ;; esac
  [ ! -f "$fixture/tests-ran" ]
}

@test "a malformed release record under evidence aborts before the suite" {
  make_fixture
  mkdir -p "$fixture/evidence"
  printf '%s\n' '# Release record: v0.0.1' '' \
    '## Gate' \
    '- coverage dropped and nothing failed' \
    '  evidence: runs/2026-08-01/coverage.txt shows the drop' \
    > "$fixture/evidence/broken.md"
  printf '@test "marker for release record fixture" { touch "%s/tests-ran"; [ -f "%s/tests-ran" ]; }\n' \
    "$fixture" "$fixture" > "$fixture/test/marker.bats"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -ne 0 ]
  case "$output" in *record-lint*"## Caffeine"*) ;; *) false ;; esac
  [ ! -f "$fixture/tests-ran" ]
}

@test "an absent evidence directory passes selfcheck cleanly" {
  make_fixture
  [ ! -d "$fixture/evidence" ]
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -eq 0 ]
}

@test "a fixture root without a go module skips the core build stage" {
  make_fixture
  [ ! -f "$fixture/go.mod" ]
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -eq 0 ]
  case "$output" in *"core build"*skip*) ;; *) false ;; esac
}

@test "an uncompilable core module fails closed before any lint runs" {
  make_fixture
  add_broken_core_module
  printf '@test "marker for broken core module" { touch "%s/tests-ran"; }\n' "$fixture" \
    > "$fixture/test/pass.bats"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -ne 0 ]
  case "$output" in *"core build"*"failed"*) ;; *) false ;; esac
  case "$output" in *caffeine-lint*) false ;; *) ;; esac
  [ ! -f "$fixture/tests-ran" ]
}

@test "a non-record file under evidence is never linted" {
  make_fixture
  mkdir -p "$fixture/evidence"
  printf '%s\n' '# generated by bin/routine-evidence' \
    'not a release record, and missing every required section' \
    > "$fixture/evidence/retro.txt"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -eq 0 ]
}
