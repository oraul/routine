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
  printf '%s\n' '@test "good and bad fixture scripts pass" { true; }' \
    > "$fixture/test/pass.bats"
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
  printf '%s\n' '@test "the fixture suite fails on purpose" { false; }' > "$fixture/test/fail.bats"
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
