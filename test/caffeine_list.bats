#!/usr/bin/env bats

load test_helper

@test "the catalog lists every topic with mode and lede" {
  run "$ROUTINE_REPO_ROOT/bin/routine-caffeine-list"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -E '^ruby/rails +pair ' > /dev/null
  printf '%s\n' "$output" | grep -E '^architecture/oop +doc-only ' > /dev/null
  n_topics="$(find "$ROUTINE_REPO_ROOT/caffeine" -mindepth 2 -maxdepth 2 -name '*.md' | wc -l | tr -d ' ')"
  [ "$(printf '%s\n' "$output" | grep -c .)" -eq "$n_topics" ]
}

@test "the catalog computes from a fixture root" {
  lroot="$BATS_TEST_TMPDIR/lroot"
  mkdir -p "$lroot/caffeine/js"
  printf '%s\n' '# caffeine: js/probe' '<!-- caffeine-mode: doc-only -->' '' \
    'Loaded when probing.' > "$lroot/caffeine/js/probe.md"
  run env ROUTINE_ROOT="$lroot" "$ROUTINE_REPO_ROOT/bin/routine-caffeine-list"
  [ "$status" -eq 0 ]
  case "$output" in *"js/probe"*"doc-only"*"Loaded when probing."*) ;; *) false ;; esac
}
