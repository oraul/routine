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

# One fixture test per name handed in. The body asserts on real state
# rather than a constant: a tautology would satisfy the token scan while
# still being a test that cannot fail, which is the thing the body rule
# exists to refuse.
fixture() {
  file="$CORPUS/$1"
  shift
  : > "$file"
  for name in "$@"; do
    printf '@test "%s" {\n  [ -f "$BATS_TEST_FILENAME" ]\n}\n' "$name" >> "$file"
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

# why: a bats test passes when its last command exits 0, so a body that
# never touches [, [[, status, output, grep, diff, assert, refute, -eq,
# -ne or a leading ! can never fail and defends no claim.
@test "an assertionless body defends no claim" {
  printf '@test "a clean claim about nothing testable" {\n  x=1\n  y=2\n}\n' \
    > "$CORPUS/a.bats"
  lint
  [ "$status" -eq 1 ]
  [[ "$output" == *"a.bats"* ]]
  [[ "$output" == *"a clean claim about nothing testable"* ]]
  [[ "$output" == *"(body rule)"* ]]
}

@test "every expectation token form the corpus uses is accepted" {
  file="$CORPUS/a.bats"
  : > "$file"
  printf '@test "a bracket condition counts as a claim" {\n  [ "$x" = "y" ]\n}\n' >> "$file"
  printf '@test "a double bracket condition counts as a claim" {\n  [[ "$x" = "y" ]]\n}\n' >> "$file"
  printf '@test "the bats status handle counts as a claim" {\n  x="$status"\n}\n' >> "$file"
  printf '@test "the bats output handle counts as a claim" {\n  x="$output"\n}\n' >> "$file"
  printf '@test "a grep comparison counts as a claim" {\n  grep -q ok here\n}\n' >> "$file"
  printf '@test "a diff comparison counts as a claim" {\n  diff a b\n}\n' >> "$file"
  printf '@test "an assert helper counts as a claim" {\n  assert_success\n}\n' >> "$file"
  printf '@test "a refute helper counts as a claim" {\n  refute_output x\n}\n' >> "$file"
  printf '@test "an eq comparison counts as a claim" {\n  test "$x" -eq 1\n}\n' >> "$file"
  printf '@test "an ne comparison counts as a claim" {\n  test "$x" -ne 2\n}\n' >> "$file"
  printf '@test "a leading negation counts as a claim" {\n  ! true\n}\n' >> "$file"
  lint
  [ "$status" -eq 0 ]
}

@test "the body rule is tagged apart from the naming rule" {
  printf '@test "it works" {\n  [ "$status" -eq 0 ]\n}\n' > "$CORPUS/a.bats"
  printf '@test "a clean name asserts nothing at all" {\n  x=1\n}\n' > "$CORPUS/b.bats"
  lint
  [ "$status" -eq 1 ]
  naming_line="$(printf '%s\n' "$output" | grep "it works")"
  body_line="$(printf '%s\n' "$output" | grep "asserts nothing at all")"
  [[ "$naming_line" == *"(naming rule)"* ]]
  [[ "$naming_line" != *"(body rule)"* ]]
  [[ "$body_line" == *"(body rule)"* ]]
  [[ "$body_line" != *"(naming rule)"* ]]
}

# why: `! grep -q X "$doc"` passes when $doc does not exist, and so does
# `! grep -rq X "$dir"/*/FILE.md` when the glob matches nothing. Neither
# negation has proved the forbidden thing is absent rather than merely
# unlooked-at, unless the same subject is asserted positively too.
@test "a negated grep with no positive counterpart proves nothing" {
  # bang is passed through %s so this file's own source never spells the
  # literal text "! grep" — spelling it here would trip this very rule
  # when routine-test-lint scans its own suite, the same trap a heredoc's
  # column-0 @test sets for the naming pass.
  bang='!'
  printf '@test "a claim about text missing from a lonely file" {\n  doc="$BATS_TEST_TMPDIR/lonely.txt"\n  %s grep -q "forbidden" "$doc"\n}\n' \
    "$bang" > "$CORPUS/a.bats"
  lint
  [ "$status" -eq 1 ]
  [[ "$output" == *"a.bats"* ]]
  [[ "$output" == *"a claim about text missing from a lonely file"* ]]
  [[ "$output" == *"(pairing rule)"* ]]
}

@test "a positive assertion on the same subject pairs the negation" {
  bang='!'
  printf '@test "a claim about required and forbidden text together" {\n  doc="$BATS_TEST_TMPDIR/lonely.txt"\n  grep -q "required" "$doc"\n  %s grep -q "forbidden" "$doc"\n}\n' \
    "$bang" > "$CORPUS/a.bats"
  lint
  [ "$status" -eq 0 ]
}

@test "a positive assertion on a different subject leaves it unpaired" {
  bang='!'
  printf '@test "a claim about one file while negating another" {\n  a="$BATS_TEST_TMPDIR/a.txt"\n  b="$BATS_TEST_TMPDIR/b.txt"\n  grep -q "ok" "$a"\n  %s grep -q "bad" "$b"\n}\n' \
    "$bang" > "$CORPUS/a.bats"
  lint
  [ "$status" -eq 1 ]
  [[ "$output" == *"a claim about one file while negating another"* ]]
  [[ "$output" == *"(pairing rule)"* ]]
}

# why: bats always defines $output after `run`, so a negation against it
# can never pass merely because $output was absent — the exemption is a
# subject test, not a filename or suite carve-out.
@test "a negation against the bats output handle is exempt from pairing" {
  bang='!'
  printf '@test "a claim that the captured run produced no error text" {\n  run true\n  [ "$status" -eq 0 ]\n  %s grep -q "error" "$output"\n}\n' \
    "$bang" > "$CORPUS/a.bats"
  lint
  [ "$status" -eq 0 ]
}

@test "the pairing rule is tagged apart from naming and body rules" {
  bang='!'
  printf '@test "it works right" {\n  [ "$status" -eq 0 ]\n}\n' > "$CORPUS/a.bats"
  printf '@test "a clean name that touches nothing testable at all" {\n  x=1\n}\n' \
    > "$CORPUS/b.bats"
  printf '@test "a claim about text absent from an unpaired file" {\n  doc="$BATS_TEST_TMPDIR/only.txt"\n  %s grep -q "x" "$doc"\n}\n' \
    "$bang" > "$CORPUS/c.bats"
  lint
  [ "$status" -eq 1 ]
  naming_line="$(printf '%s\n' "$output" | grep "it works right")"
  body_line="$(printf '%s\n' "$output" | grep "touches nothing testable at all")"
  pairing_line="$(printf '%s\n' "$output" | grep "absent from an unpaired file")"
  [[ "$naming_line" == *"(naming rule)"* ]]
  [[ "$naming_line" != *"(body rule)"* ]]
  [[ "$naming_line" != *"(pairing rule)"* ]]
  [[ "$body_line" == *"(body rule)"* ]]
  [[ "$body_line" != *"(pairing rule)"* ]]
  [[ "$pairing_line" == *"(pairing rule)"* ]]
  [[ "$pairing_line" != *"(naming rule)"* ]]
  [[ "$pairing_line" != *"(body rule)"* ]]
}

@test "the repository's own suite satisfies the lint" {
  run "$ROUTINE_REPO_ROOT/bin/routine-test-lint" "$ROUTINE_REPO_ROOT/test"
  [ "$status" -eq 0 ]
}

@test "a missing corpus directory is a usage error" {
  run "$ROUTINE_REPO_ROOT/bin/routine-test-lint" "$BATS_TEST_TMPDIR/absent"
  [ "$status" -eq 2 ]
}

# why: gate.bats writes "$tdir/gate.log" as its fixture, then negates a
# grep on it. The subject provably exists, so the negation cannot be
# vacuous — a write establishes a subject exactly as an assertion does.
@test "a fixture write establishes the negated subject" {
  printf '@test "the log starts clean each run" {\n' > "$CORPUS/a.bats"
  printf '  printf %%s stale > "$tdir/gate.log"\n' >> "$CORPUS/a.bats"
  printf '  ! grep -q stale "$tdir/gate.log"\n}\n' >> "$CORPUS/a.bats"
  lint
  [ "$status" -eq 0 ]
}

# why: tdd.bats disjoins on existence — [ ! -f "$f" ] || ! grep -q x "$f"
# — which is the author handling vacuity explicitly. A negated -f is still
# an existence test, so it pairs.
@test "an existence test pairs even when it is negated" {
  printf '@test "no record survives a rejected scenario" {\n' > "$CORPUS/a.bats"
  printf '  [ ! -f "$t/telemetry.jsonl" ] || ! grep -q red "$t/telemetry.jsonl"\n}\n' >> "$CORPUS/a.bats"
  lint
  [ "$status" -eq 0 ]
}

# why: pair-negative-assertions exempted $output on the grounds that bats
# always defines it. Defined is not non-empty — a crashed command leaves
# it empty and a negated grep over an empty string passes, which is the
# very failure that rule exists to catch.
@test "a negation on output needs a status assertion" {
  printf '@test "the queue omits the blocked line" {\n' > "$CORPUS/a.bats"
  printf '  run some-command\n' >> "$CORPUS/a.bats"
  printf '  ! printf %%s "$output" | grep -q blocked\n}\n' >> "$CORPUS/a.bats"
  lint
  [ "$status" -eq 1 ]
  [[ "$output" == *"the queue omits the blocked line"* ]]
}

@test "a status assertion pairs a negation on output" {
  printf '@test "the queue omits the blocked line" {\n' > "$CORPUS/a.bats"
  printf '  run some-command\n' >> "$CORPUS/a.bats"
  printf '  [ "$status" -eq 0 ]\n' >> "$CORPUS/a.bats"
  printf '  ! printf %%s "$output" | grep -q blocked\n}\n' >> "$CORPUS/a.bats"
  lint
  [ "$status" -eq 0 ]
}

# why: bats gives each test its own process and BATS_TEST_TMPDIR, which is
# why order dependence cannot arise in this corpus. A shared tmpdir is the
# only way to opt out of that boundary, so it is refused outright.
@test "a shared suite tmpdir is refused" {
  printf '@test "the fixture is built once for the file" {\n' > "$CORPUS/a.bats"
  printf '  [ -d "$BATS_SUITE_TMPDIR" ]\n}\n' >> "$CORPUS/a.bats"
  lint
  [ "$status" -eq 1 ]
  [[ "$output" == *"isolation rule"* ]]
}

@test "a shared file tmpdir is refused as well" {
  printf '@test "the fixture is built once per file" {\n' > "$CORPUS/a.bats"
  printf '  [ -d "$BATS_FILE_TMPDIR" ]\n}\n' >> "$CORPUS/a.bats"
  lint
  [ "$status" -eq 1 ]
}

@test "a write into the repository root is refused" {
  printf '@test "the doc gains a line under test" {\n' > "$CORPUS/a.bats"
  printf '  printf x > "$ROUTINE_REPO_ROOT/agents/scout.md"\n' >> "$CORPUS/a.bats"
  printf '  [ -f "$ROUTINE_REPO_ROOT/agents/scout.md" ]\n}\n' >> "$CORPUS/a.bats"
  lint
  [ "$status" -eq 1 ]
  [[ "$output" == *"isolation rule"* ]]
}

# why: the content pins grep $ROUTINE_REPO_ROOT on nearly every line and
# must keep doing so. A read cannot make one test depend on another.
@test "reading the repository root stays unrestricted" {
  printf '@test "the scout doc forbids every write" {\n' > "$CORPUS/a.bats"
  printf '  doc="$ROUTINE_REPO_ROOT/agents/scout.md"\n' >> "$CORPUS/a.bats"
  printf '  [ -f "$doc" ]\n' >> "$CORPUS/a.bats"
  printf '  grep -q telemetry "$doc"\n}\n' >> "$CORPUS/a.bats"
  lint
  [ "$status" -eq 0 ]
}
