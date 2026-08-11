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

@test "green path: clean fixture exits 0" {
  make_fixture
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-selfcheck"
  [ "$status" -eq 0 ]
}
