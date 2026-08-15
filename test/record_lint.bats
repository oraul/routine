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

# A fixture repo with two merges either side of a tag — the range
# v0.7.0..HEAD the citation rule reads. #73 merges before the tag, #82
# after it, exactly the shape the bad v0.8.0 draft and the published
# record measured against.
make_range_repo() {
  rroot="$BATS_TEST_TMPDIR/rroot"
  mkdir -p "$rroot/caffeine/bash" "$rroot/evidence"
  printf '%s\n' '# caffeine: bash/portability' \
    '<!-- caffeine-topic: bash/portability -->' \
    > "$rroot/caffeine/bash/portability.md"
  git -C "$rroot" -c init.defaultBranch=main init -q
  g() { git -C "$rroot" -c user.name=t -c user.email=t@example.invalid "$@"; }
  g commit -q --allow-empty -m "root"
  g checkout -q -b change/old
  g commit -q --allow-empty -m "feat: old work"
  g checkout -q main
  g merge -q --no-ff change/old -m "Merge pull request #73: feat: old work — old"
  g tag v0.7.0
  g checkout -q -b change/new
  g commit -q --allow-empty -m "feat: new work"
  g checkout -q main
  g merge -q --no-ff change/new -m "Merge pull request #82: feat: new work — new"
}

@test "an in-range citation adds no violation" {
  make_range_repo
  rec="$rroot/evidence/v0.8.0.md"
  printf '%s\n' \
    '# Release record: v0.8.0' \
    '' \
    '## Caffeine' \
    '- shipped in #82, squarely this release' \
    '  evidence: test/record_lint.bats caught it' \
    '  topic: bash/portability' \
    '' \
    '## Gate' \
    '- none — nothing shipped that a gate should have caught and did not' \
    > "$rec"
  lint
  [ "$status" -eq 0 ]
}

@test "a citation before the previous tag is refused by number" {
  make_range_repo
  rec="$rroot/evidence/v0.8.0.md"
  printf '%s\n' \
    '# Release record: v0.8.0' \
    '' \
    '## Caffeine' \
    '- claims #73 belongs to this release though it shipped earlier' \
    '  evidence: test/record_lint.bats caught it' \
    '  topic: bash/portability' \
    '' \
    '## Gate' \
    '- none — nothing shipped that a gate should have caught and did not' \
    > "$rec"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *"claims #73 belongs"*"#73"*) ;; *) false ;; esac
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
