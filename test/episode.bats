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

# The developer failure budget is consecutive failing gate.developer
# lines for one task since its last passing one — a pass resets it, and
# another task's history never bleeds in.
make_dev_tele() {
  tele="$BATS_TEST_TMPDIR/dev-telemetry.jsonl"
  : > "$tele"
  printf '%s\n' '{"ts":"2026-01-01T00:00:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-01","exit":1,"ms":5}' >> "$tele"
  printf '%s\n' '{"ts":"2026-01-01T00:01:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-01","exit":1,"ms":5}' >> "$tele"
  printf '%s\n' '{"ts":"2026-01-01T00:02:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-01","exit":0,"ms":5}' >> "$tele"
  printf '%s\n' '{"ts":"2026-01-01T00:03:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-01","exit":1,"ms":5}' >> "$tele"
  printf '%s\n' '{"ts":"2026-01-01T00:04:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-02","exit":1,"ms":5}' >> "$tele"
  printf '%s\n' '{"ts":"2026-01-01T00:05:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-02","exit":1,"ms":5}' >> "$tele"
  printf '%s\n' '{"ts":"2026-01-01T00:06:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-02","exit":1,"ms":5}' >> "$tele"
  printf '%s\n' '{"ts":"2026-01-01T00:07:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-03","exit":1,"ms":5}' >> "$tele"
  printf '%s\n' '{"ts":"2026-01-01T00:08:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-03","exit":1,"ms":5}' >> "$tele"
  printf '%s\n' '{"ts":"2026-01-01T00:09:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-03","exit":0,"ms":5}' >> "$tele"
}

@test "the developer fail counter counts only failures since the last pass" {
  make_dev_tele
  run bash -c '. "$1/lib/episode.sh"; episode_developer_fail_count "$2" "$3"' _ \
    "$ROUTINE_REPO_ROOT" "$tele" "01-01"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "a passing developer gate zeroes the count for that task" {
  make_dev_tele
  run bash -c '. "$1/lib/episode.sh"; episode_developer_fail_count "$2" "$3"' _ \
    "$ROUTINE_REPO_ROOT" "$tele" "01-03"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "developer failures on one task never count toward another" {
  make_dev_tele
  run bash -c '. "$1/lib/episode.sh"; episode_developer_fail_count "$2" "$3"' _ \
    "$ROUTINE_REPO_ROOT" "$tele" "01-02"
  [ "$status" -eq 0 ]
  [ "$output" = "3" ]
}

@test "no telemetry file counts as no developer failures" {
  run bash -c '. "$1/lib/episode.sh"; episode_developer_fail_count "$2" "$3"' _ \
    "$ROUTINE_REPO_ROOT" "$BATS_TEST_TMPDIR/nope.jsonl" "01-01"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

# The defect count is a plain tally of spec.defective lines per task —
# routine-defect will spend it in a later task, this one just reports it.
make_defect_tele() {
  tele="$BATS_TEST_TMPDIR/defect-telemetry.jsonl"
  : > "$tele"
  printf '%s\n' '{"ts":"2026-01-01T00:00:00Z","event":"spec.defective","script":"bin/routine-defect","ticket":"0001","task":"01-01","exit":0,"ms":2}' >> "$tele"
  printf '%s\n' '{"ts":"2026-01-01T00:01:00Z","event":"spec.defective","script":"bin/routine-defect","ticket":"0001","task":"01-01","exit":0,"ms":2}' >> "$tele"
  printf '%s\n' '{"ts":"2026-01-01T00:02:00Z","event":"spec.defective","script":"bin/routine-defect","ticket":"0001","task":"01-02","exit":0,"ms":2}' >> "$tele"
}

@test "the defect counter tallies every return recorded for the task" {
  make_defect_tele
  run bash -c '. "$1/lib/episode.sh"; episode_defect_count "$2" "$3"' _ \
    "$ROUTINE_REPO_ROOT" "$tele" "01-01"
  [ "$status" -eq 0 ]
  [ "$output" = "2" ]
}

@test "defect returns on one task never count toward another" {
  make_defect_tele
  run bash -c '. "$1/lib/episode.sh"; episode_defect_count "$2" "$3"' _ \
    "$ROUTINE_REPO_ROOT" "$tele" "01-02"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "no telemetry file counts as no defect returns" {
  run bash -c '. "$1/lib/episode.sh"; episode_defect_count "$2" "$3"' _ \
    "$ROUTINE_REPO_ROOT" "$BATS_TEST_TMPDIR/nope.jsonl" "01-01"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}
