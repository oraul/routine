#!/usr/bin/env bats

load test_helper

# The revise budget has exactly one implementation: the gate that spends
# it and any reader that reports it must never disagree.
make_tele() {
  tele="$BATS_TEST_TMPDIR/telemetry.jsonl"
  cat > "$tele" <<'T'
{"ts":"2026-01-01T00:00:00Z","event":"spec.lint","script":"bin/routine-spec-lint","ticket":"0001","task":"","exit":1,"ms":5}
{"ts":"2026-01-01T00:01:00Z","event":"spec.lint","script":"bin/routine-spec-lint","ticket":"0001","task":"","exit":1,"ms":5}
{"ts":"2026-01-01T00:02:00Z","event":"spec.defective","script":"bin/routine-defect","ticket":"0001","task":"01-01","exit":0,"ms":2}
{"ts":"2026-01-01T00:03:00Z","event":"spec.lint","script":"bin/routine-spec-lint","ticket":"0001","task":"","exit":1,"ms":5}
T
}

@test "the episode counter counts only failures since the last defect return" {
  make_tele
  run bash -c '. "$1/lib/episode.sh"; episode_revise_count "$2"' _ \
    "$ROUTINE_REPO_ROOT" "$tele"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "no telemetry file counts as no revises" {
  run bash -c '. "$1/lib/episode.sh"; episode_revise_count "$2"' _ \
    "$ROUTINE_REPO_ROOT" "$BATS_TEST_TMPDIR/nope.jsonl"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "the gate spends the budget through the shared counter" {
  grep -q 'episode_revise_count' "$ROUTINE_REPO_ROOT/bin/routine-gate"
  ! grep -q 'spec.defective' "$ROUTINE_REPO_ROOT/bin/routine-gate"
}
