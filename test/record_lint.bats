#!/usr/bin/env bats

load test_helper

# A fixture root whose caffeine/ tree carries exactly one real topic pair,
# so a Caffeine entry naming it resolves and a Caffeine entry naming
# anything else does not.
make_root() {
  rroot="$BATS_TEST_TMPDIR/rroot"
  mkdir -p "$rroot/caffeine/bash"
  printf '%s\n' '# caffeine: bash/portability' \
    '<!-- caffeine-topic: bash/portability -->' \
    > "$rroot/caffeine/bash/portability.md"
}

make_good_record() {
  rec="$BATS_TEST_TMPDIR/record.md"
  printf '%s\n' \
    '# Release record: v1.2.0' \
    '' \
    '## Caffeine' \
    '- BSD grep has no \b; a literal trailing space is the portable substitute' \
    '  evidence: test/test_lint.bats caught it failing on the macOS runner' \
    '  topic: bash/portability' \
    '' \
    '## Gate' \
    '- coverage dropped and nothing failed the build' \
    '  evidence: runs/2026-08-01/coverage.txt shows 71% vs 75% at the prior tag' \
    '  script: bin/routine-coverage-check (proposed, not yet built)' \
    > "$rec"
}

lint() {
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-record-lint" "$rec"
}

@test "a well-formed record with both sections passes clean" {
  make_root
  make_good_record
  lint
  [ "$status" -eq 0 ]
}

@test "the none floor satisfies a section that improved nothing" {
  make_root
  rec="$BATS_TEST_TMPDIR/record.md"
  printf '%s\n' \
    '# Release record: v1.3.0' \
    '' \
    '## Caffeine' \
    '- none — nothing this release taught the corpus anything new' \
    '' \
    '## Gate' \
    '- none — nothing shipped that a gate should have caught and did not' \
    > "$rec"
  lint
  [ "$status" -eq 0 ]
}

@test "a record missing the gate section is refused by name" {
  make_root
  rec="$BATS_TEST_TMPDIR/record.md"
  printf '%s\n' \
    '# Release record: v1.2.0' \
    '' \
    '## Caffeine' \
    '- BSD grep has no \b' \
    '  evidence: test/test_lint.bats caught it' \
    '  topic: bash/portability' \
    > "$rec"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *missing*"## Gate"*) ;; *) false ;; esac
}

@test "a record missing the caffeine section is refused by name" {
  make_root
  rec="$BATS_TEST_TMPDIR/record.md"
  printf '%s\n' \
    '# Release record: v1.2.0' \
    '' \
    '## Gate' \
    '- coverage dropped and nothing failed' \
    '  evidence: runs/2026-08-01/coverage.txt shows the drop' \
    > "$rec"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *missing*"## Caffeine"*) ;; *) false ;; esac
}

@test "a silently empty section is refused naming the floor" {
  make_root
  rec="$BATS_TEST_TMPDIR/record.md"
  printf '%s\n' \
    '# Release record: v1.2.0' \
    '' \
    '## Caffeine' \
    '' \
    '## Gate' \
    '- coverage dropped and nothing failed' \
    '  evidence: runs/2026-08-01/coverage.txt shows the drop' \
    > "$rec"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *"## Caffeine"*"empty"*"none —"*) ;; *) false ;; esac
}

@test "an entry without an evidence line is refused naming it" {
  make_root
  rec="$BATS_TEST_TMPDIR/record.md"
  printf '%s\n' \
    '# Release record: v1.2.0' \
    '' \
    '## Caffeine' \
    '- BSD grep has no \b' \
    '  topic: bash/portability' \
    '' \
    '## Gate' \
    '- coverage dropped and nothing failed' \
    '  evidence: runs/2026-08-01/coverage.txt shows the drop' \
    > "$rec"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *"BSD grep has no"*"evidence"*) ;; *) false ;; esac
}

@test "a caffeine topic with no matching pair is refused as a false claim" {
  make_root
  rec="$BATS_TEST_TMPDIR/record.md"
  printf '%s\n' \
    '# Release record: v1.2.0' \
    '' \
    '## Caffeine' \
    '- a lesson that was never actually filed anywhere' \
    '  evidence: test/test_lint.bats caught it' \
    '  topic: ruby/nonexistent' \
    '' \
    '## Gate' \
    '- coverage dropped and nothing failed' \
    '  evidence: runs/2026-08-01/coverage.txt shows the drop' \
    > "$rec"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *"ruby/nonexistent"*"resolves to no"*) ;; *) false ;; esac
  case "$output" in *"available topics"*"bash/portability"*) ;; *) false ;; esac
}

@test "a topic resolving via a sidecar with no doc still passes" {
  make_root
  mkdir -p "$rroot/caffeine/js"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$rroot/caffeine/js/vitest.sh"
  rec="$BATS_TEST_TMPDIR/record.md"
  printf '%s\n' \
    '# Release record: v1.2.0' \
    '' \
    '## Caffeine' \
    '- a lesson filed as a sidecar-only topic' \
    '  evidence: test/caffeine_js_vitest.bats caught it' \
    '  topic: js/vitest' \
    '' \
    '## Gate' \
    '- coverage dropped and nothing failed' \
    '  evidence: runs/2026-08-01/coverage.txt shows the drop' \
    > "$rec"
  lint
  [ "$status" -eq 0 ]
}

@test "every violation in a broken record surfaces in one run" {
  make_root
  rec="$BATS_TEST_TMPDIR/record.md"
  printf '%s\n' \
    '# Release record: v1.2.0' \
    '' \
    '## Caffeine' \
    '- a lesson with no evidence at all' \
    '  topic: ruby/nonexistent' \
    > "$rec"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *"evidence"*) ;; *) false ;; esac
  case "$output" in *"ruby/nonexistent"*"resolves to no"*) ;; *) false ;; esac
  case "$output" in *missing*"## Gate"*) ;; *) false ;; esac
}

@test "no argument at all is a usage error" {
  run "$ROUTINE_REPO_ROOT/bin/routine-record-lint"
  [ "$status" -eq 2 ]
}

@test "a file that does not exist is a usage error" {
  run "$ROUTINE_REPO_ROOT/bin/routine-record-lint" "$BATS_TEST_TMPDIR/nope.md"
  [ "$status" -eq 2 ]
  [ ! -e "$BATS_TEST_TMPDIR/nope.md" ]
}
