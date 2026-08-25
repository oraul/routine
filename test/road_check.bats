#!/usr/bin/env bats

load test_helper

# Fixture: a routine root with its own roads file and runs evidence, so
# the check judges controlled state rather than the live repository.
# alpha.two lives only in an archived ticket's telemetry, so the clean
# pass also proves nested evidence counts as walked.
make_roads_fixture() {
  fixture="$BATS_TEST_TMPDIR/fixture"
  mkdir -p "$fixture/lib" "$fixture/runs/app/tickets/archive/0001"
  printf '%s\n' \
    '# declared roads' \
    'alpha.one' \
    'alpha.two' \
    'beta.skip — never walked: no live run has needed it yet' \
    > "$fixture/lib/roads.txt"
  printf '%s\n' \
    '{"ts":"2026-01-01T00:00:00Z","event":"alpha.one","script":"bin/x","ticket":"","task":"","exit":0,"ms":1}' \
    > "$fixture/runs/app/telemetry.jsonl"
  printf '%s\n' \
    '{"ts":"2026-01-01T00:00:01Z","event":"alpha.two","script":"bin/x","ticket":"0001","task":"01-01","exit":0,"ms":1}' \
    > "$fixture/runs/app/tickets/archive/0001/telemetry.jsonl"
}

@test "a clean tree passes with walked roads and an honest waiver" {
  make_roads_fixture
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-road-check"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -qi 'walked or waivered'
}

@test "a missing runs directory is a refusal" {
  make_roads_fixture
  rm -rf "$fixture/runs"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-road-check"
  [ "$status" -eq 2 ]
  printf '%s\n' "$output" | grep -q 'runs'
}

@test "a missing roads file is a refusal" {
  make_roads_fixture
  rm "$fixture/lib/roads.txt"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-road-check"
  [ "$status" -eq 2 ]
  printf '%s\n' "$output" | grep -q 'roads'
}

@test "a second argument is a usage error" {
  make_roads_fixture
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-road-check" \
    "$fixture/runs" extra
  [ "$status" -eq 2 ]
  printf '%s\n' "$output" | grep -q 'usage'
}

@test "an undeclared road walked fails naming the event" {
  make_roads_fixture
  printf '%s\n' \
    '{"ts":"2026-01-01T00:00:02Z","event":"gamma.rogue","script":"bin/x","ticket":"","task":"","exit":0,"ms":1}' \
    >> "$fixture/runs/app/telemetry.jsonl"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-road-check"
  [ "$status" -eq 1 ]
  printf '%s\n' "$output" | grep -q 'undeclared road walked: gamma.rogue'
}

@test "a declared road never walked fails naming the waiver form" {
  make_roads_fixture
  printf '%s\n' 'delta.never' >> "$fixture/lib/roads.txt"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-road-check"
  [ "$status" -eq 1 ]
  printf '%s\n' "$output" | grep -q 'declared road never walked: delta.never'
  printf '%s\n' "$output" | grep -q 'never walked: <why>'
}

@test "a stale waiver fails naming the event" {
  make_roads_fixture
  printf '%s\n' \
    '{"ts":"2026-01-01T00:00:03Z","event":"beta.skip","script":"bin/x","ticket":"","task":"","exit":0,"ms":1}' \
    >> "$fixture/runs/app/telemetry.jsonl"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-road-check"
  [ "$status" -eq 1 ]
  printf '%s\n' "$output" | grep -q 'stale waiver: beta.skip was walked'
}

@test "every violation surfaces in one run" {
  make_roads_fixture
  printf '%s\n' 'delta.never' >> "$fixture/lib/roads.txt"
  printf '%s\n' \
    '{"ts":"2026-01-01T00:00:04Z","event":"gamma.rogue","script":"bin/x","ticket":"","task":"","exit":0,"ms":1}' \
    '{"ts":"2026-01-01T00:00:05Z","event":"beta.skip","script":"bin/x","ticket":"","task":"","exit":0,"ms":1}' \
    >> "$fixture/runs/app/telemetry.jsonl"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-road-check"
  [ "$status" -eq 1 ]
  printf '%s\n' "$output" | grep -q 'undeclared road walked: gamma.rogue'
  printf '%s\n' "$output" | grep -q 'declared road never walked: delta.never'
  printf '%s\n' "$output" | grep -q 'stale waiver: beta.skip'
}

@test "the live roads file declares the check's own road and the honest waiver" {
  roads="$ROUTINE_REPO_ROOT/lib/roads.txt"
  grep -qx 'harness.roads' "$roads"
  grep -q '^app.deps — never walked: ' "$roads"
  grep -qx 'ticket.replay' "$roads"
}