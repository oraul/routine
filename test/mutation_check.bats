#!/usr/bin/env bats

load test_helper

# A fixture bin/+test/ tree (never the real bin/): one script whose suite
# actually calls it and checks its output, one whose suite never binds
# to the script it claims to cover.
make_corpus() {
  sroot="$BATS_TEST_TMPDIR/sroot"
  mkdir -p "$sroot/bin" "$sroot/test"

  printf '%s\n' \
    '#!/usr/bin/env bash' \
    '# routine-script: routine-good' \
    '# routine-description: A fixture script whose suite actually calls it' \
    '# routine-exit: 0 — prints the marker' \
    '# routine-test: test/good.bats' \
    'echo "good-marker"' \
    'exit 0' > "$sroot/bin/routine-good"
  chmod +x "$sroot/bin/routine-good"

  printf '%s\n' \
    '#!/usr/bin/env bash' \
    '# routine-script: routine-decorative' \
    '# routine-description: A fixture script whose suite never binds to it' \
    '# routine-exit: 0 — prints the marker' \
    '# routine-test: test/decorative.bats' \
    'echo "decorative-marker"' \
    'exit 0' > "$sroot/bin/routine-decorative"
  chmod +x "$sroot/bin/routine-decorative"

  printf '@test "the good script prints its marker" {\n  run "%s/bin/routine-good"\n  [ "$status" -eq 0 ]\n  [ "$output" = "good-marker" ]\n}\n' \
    "$sroot" > "$sroot/test/good.bats"

  printf '@test "the decorative suite asserts a tautology" {\n  [ -f "$BATS_TEST_FILENAME" ]\n}\n' \
    > "$sroot/test/decorative.bats"
}

check() {
  run "$ROUTINE_REPO_ROOT/bin/routine-mutation-check" "$sroot"
}

@test "a suite that binds to its script is counted as covered" {
  make_corpus
  rm -f "$sroot/bin/routine-decorative" "$sroot/test/decorative.bats"
  check
  [ "$status" -eq 0 ]
  case "$output" in *"1 script"*"mutated"*) ;; *) false ;; esac
  case "$output" in *"1 suite"*"noticed"*) ;; *) false ;; esac
}

@test "a suite that never binds survives and is named with its script" {
  make_corpus
  rm -f "$sroot/bin/routine-good" "$sroot/test/good.bats"
  check
  [ "$status" -eq 1 ]
  case "$output" in *routine-decorative*) ;; *) false ;; esac
  case "$output" in *decorative.bats*) ;; *) false ;; esac
}

@test "the original script content is byte identical after a run" {
  make_corpus
  cp "$sroot/bin/routine-good" "$BATS_TEST_TMPDIR/expected-good"
  cp "$sroot/bin/routine-decorative" "$BATS_TEST_TMPDIR/expected-decorative"
  check
  diff "$BATS_TEST_TMPDIR/expected-good" "$sroot/bin/routine-good"
  diff "$BATS_TEST_TMPDIR/expected-decorative" "$sroot/bin/routine-decorative"
}

@test "the summary prints both the mutated count and the noticed count" {
  make_corpus
  check
  case "$output" in *"2 script"*"mutated"*) ;; *) false ;; esac
  case "$output" in *"1 suite"*"noticed"*) ;; *) false ;; esac
}

@test "a dead suite pointer is reported and skipped, not crashed on" {
  make_corpus
  sed -i.bak 's#test/good.bats#test/missing.bats#' "$sroot/bin/routine-good" \
    && rm -f "$sroot/bin/routine-good.bak"
  rm -f "$sroot/test/good.bats"
  check
  case "$output" in *routine-good*missing.bats*) ;; *) false ;; esac
}

@test "usage error when pointed at a directory that does not exist" {
  run "$ROUTINE_REPO_ROOT/bin/routine-mutation-check" "$BATS_TEST_TMPDIR/nowhere"
  [ "$status" -eq 2 ]
}
