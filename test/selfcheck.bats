#!/usr/bin/env bats

load test_helper

# Builds a minimal healthy plugin tree the selfcheck can be pointed at
# via ROUTINE_ROOT (Law 6): one clean script, one lib, one passing test.
make_fixture() {
  fixture="$BATS_TEST_TMPDIR/fixture"
  mkdir -p "$fixture/bin" "$fixture/lib" "$fixture/test"
  printf '%s\n' '#!/usr/bin/env bash' 'printf ok' > "$fixture/bin/good"
  chmod +x "$fixture/bin/good"
  printf '%s\n' '# shellcheck shell=bash' 'noop() { :; }' > "$fixture/lib/noop.sh"
  printf '%s\n' '@test "passes" { true; }' > "$fixture/test/pass.bats"
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
  printf '%s\n' '#!/usr/bin/env bash' 'cat $1' > "$fixture/bin/bad"
  chmod +x "$fixture/bin/bad"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -ne 0 ]
  case "$output" in *caffeine-lint*orphan*) ;; *) false ;; esac
  case "$output" in *"shellcheck failed"*) false ;; *) ;; esac
}

@test "lint failure exits non-zero and skips the test stage" {
  make_fixture
  printf '%s\n' '#!/usr/bin/env bash' 'cat $1' > "$fixture/bin/bad"
  chmod +x "$fixture/bin/bad"
  printf '@test "marker" { touch "%s/tests-ran"; }\n' "$fixture" \
    > "$fixture/test/pass.bats"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -ne 0 ]
  [ ! -f "$fixture/tests-ran" ]
}

@test "failing bats suite exits non-zero" {
  make_fixture
  printf '%s\n' '@test "fails" { false; }' > "$fixture/test/fail.bats"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -ne 0 ]
}
