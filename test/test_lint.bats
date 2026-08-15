#!/usr/bin/env bats

load test_helper

# A test name is the only part of a suite most readers ever read, so it
# carries the claim, never the mechanism. Every rule here passes the
# repository's own 336 names unchanged — this lint is a regression pin on
# a convention that is currently unbroken, not a cleanup.
#
# Fixtures are written with printf, never a heredoc, following
# script_lint.bats: a heredoc puts a literal `@test "..."` at column 0 of
# this file, and the lint would then read this suite's fixtures as if they
# were its own tests.

setup() {
  ROUTINE_REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export ROUTINE_REPO_ROOT
  CORPUS="$BATS_TEST_TMPDIR/test"
  mkdir -p "$CORPUS"
}

# One fixture test per name handed in.
fixture() {
  file="$CORPUS/$1"
  shift
  : > "$file"
  for name in "$@"; do
    printf '@test "%s" {\n  true\n}\n' "$name" >> "$file"
  done
}

lint() {
  run "$ROUTINE_REPO_ROOT/bin/routine-test-lint" "$CORPUS"
}

@test "a corpus of claim-shaped names passes" {
  fixture a.bats "a complete run passes and writes nothing" \
                 "green without a prior red is a violation"
  lint
  [ "$status" -eq 0 ]
}

@test "a mechanism-flavored opener is refused" {
  fixture a.bats "it should work correctly"
  lint
  [ "$status" -eq 1 ]
  [[ "$output" == *"a.bats"* ]]
  [[ "$output" == *"it should work correctly"* ]]
}

@test "every mechanism opener in the denylist is caught" {
  for opener in test tests testing check checks verify verifies should it \
                ensure ensures can will does works handles correctly; do
    fixture a.bats "$opener the thing that matters"
    lint
    [ "$status" -eq 1 ] || { echo "opener not caught: $opener"; false; }
  done
}

# why: the first draft matched word boundaries and refused
# "testing/tdd teaches the loop's own discipline" — a caffeine topic
# path, not the word "testing". The rule requires a following space, and
# \b is unavailable in BSD grep anyway.
@test "a topic path is not a mechanism opener" {
  fixture a.bats "testing/tdd teaches the loop's own discipline"
  lint
  [ "$status" -eq 0 ]
}

@test "a name shorter than three words is a label" {
  fixture a.bats "abort refuses"
  lint
  [ "$status" -eq 1 ]
  [[ "$output" == *"abort refuses"* ]]
}

@test "three words is the floor and passes" {
  fixture a.bats "clean target passes"
  lint
  [ "$status" -eq 0 ]
}

@test "a name carrying provenance is refused" {
  fixture a.bats "$(printf 'claim %.0s' $(seq 1 25))"
  lint
  [ "$status" -eq 1 ]
}

@test "a name repeated inside one suite is ambiguous" {
  fixture a.bats "all violations are reported in one run" \
                 "all violations are reported in one run"
  lint
  [ "$status" -eq 1 ]
  [[ "$output" == *"declared twice"* ]]
}

# why: audit.bats and script_lint.bats both claim "all violations are
# reported in one run", and both are correct. bats runs and reports per
# suite, so uniqueness is scoped to the file.
@test "the same claim in two suites is not a duplicate" {
  fixture a.bats "all violations are reported in one run"
  fixture b.bats "all violations are reported in one run"
  lint
  [ "$status" -eq 0 ]
}

@test "all violations are reported in one run" {
  fixture a.bats "it works" "should pass the check"
  lint
  [ "$status" -eq 1 ]
  [[ "$output" == *"it works"* ]]
  [[ "$output" == *"should pass the check"* ]]
}

# why: a one-line body is valid bats, and an extraction anchored to a
# closing brace at end of line would silently skip such a test.
@test "a one-line test body is still linted" {
  printf '@test "it works" { true; }\n' > "$CORPUS/a.bats"
  lint
  [ "$status" -eq 1 ]
  [[ "$output" == *"it works"* ]]
}

@test "the repository's own suite satisfies the lint" {
  run "$ROUTINE_REPO_ROOT/bin/routine-test-lint" "$ROUTINE_REPO_ROOT/test"
  [ "$status" -eq 0 ]
}

@test "a missing corpus directory is a usage error" {
  run "$ROUTINE_REPO_ROOT/bin/routine-test-lint" "$BATS_TEST_TMPDIR/absent"
  [ "$status" -eq 2 ]
}
