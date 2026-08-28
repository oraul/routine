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
  grep -qx 'harness.render' "$roads"
}

@test "an existing runs directory with no telemetry decides nothing" {
  fixture="$BATS_TEST_TMPDIR/fixture"
  mkdir -p "$fixture/lib" "$fixture/runs"
  printf '%s\n' 'alpha.one' > "$fixture/lib/roads.txt"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-road-check"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -qi 'decided nothing\|nothing decided'
  case "$output" in *"never walked"*) false ;; *) ;; esac
  case "$output" in *"undeclared"*) false ;; *) ;; esac
}

@test "an empty telemetry file still counts as no telemetry at all" {
  fixture="$BATS_TEST_TMPDIR/fixture"
  mkdir -p "$fixture/lib" "$fixture/runs/app"
  printf '%s\n' 'alpha.one' > "$fixture/lib/roads.txt"
  : > "$fixture/runs/app/telemetry.jsonl"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-road-check"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -qi 'decided nothing\|nothing decided'
}

@test "a ticket corpus present still reports an unwalked road from the harness tier" {
  fixture="$BATS_TEST_TMPDIR/fixture"
  mkdir -p "$fixture/lib" "$fixture/runs/app/tickets/0001"
  printf '%s\n' 'alpha.one' 'beta.never' 'gamma.ticket' \
    > "$fixture/lib/roads.txt"
  printf '%s\n' \
    '{"ts":"2026-01-01T00:00:00Z","event":"alpha.one","script":"bin/x","ticket":"","task":"","exit":0,"ms":1}' \
    > "$fixture/runs/app/telemetry.jsonl"
  printf '%s\n' \
    '{"ts":"2026-01-01T00:00:01Z","event":"gamma.ticket","script":"bin/x","ticket":"0001","task":"","exit":0,"ms":1}' \
    > "$fixture/runs/app/tickets/0001/telemetry.jsonl"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-road-check"
  [ "$status" -eq 1 ]
  printf '%s\n' "$output" | grep -q 'declared road never walked: beta.never'
  case "$output" in *'never walked: alpha.one'*) false ;; *) ;; esac
}

@test "a harness footprint without ticket telemetry decides nothing" {
  fixture="$BATS_TEST_TMPDIR/fixture"
  mkdir -p "$fixture/lib" "$fixture/runs/fixture"
  printf '%s\n' 'alpha.one' 'harness.roads' > "$fixture/lib/roads.txt"
  printf '%s\n' \
    '{"ts":"2026-01-01T00:00:00Z","event":"harness.roads","script":"bin/routine-road-check","ticket":"","task":"","exit":0,"ms":1}' \
    > "$fixture/runs/fixture/telemetry.jsonl"
  run env ROUTINE_ROOT="$fixture" TARGET="$fixture" \
    "$ROUTINE_REPO_ROOT/bin/routine-road-check"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -qi 'decided nothing\|nothing decided'
  case "$output" in *"never walked"*) false ;; *) ;; esac
  case "$output" in *"undeclared"*) false ;; *) ;; esac
}

# The undeclared-road rule is decided on the strength of one line, with
# or without a run corpus, unlike the unwalked-road rule right above:
# no tickets/ directory exists anywhere in this fixture, yet the rogue
# event must still be caught.
@test "an undeclared road is caught without a run corpus" {
  fixture="$BATS_TEST_TMPDIR/fixture"
  mkdir -p "$fixture/lib" "$fixture/runs/app"
  printf '%s\n' 'alpha.one' > "$fixture/lib/roads.txt"
  printf '%s\n' \
    '{"ts":"2026-01-01T00:00:00Z","event":"zulu.rogue","script":"bin/x","ticket":"","task":"","exit":0,"ms":1}' \
    > "$fixture/runs/app/telemetry.jsonl"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-road-check"
  [ "$status" -eq 1 ]
  printf '%s\n' "$output" | grep -q 'undeclared road walked: zulu.rogue'
  case "$output" in *"never walked"*) false ;; *) ;; esac
}

# A stale waiver is proven false by one line the same way an undeclared
# road is proven true by one — neither needs a whole run corpus, only
# the unwalked-road rule does.
@test "a stale waiver is caught without a run corpus" {
  fixture="$BATS_TEST_TMPDIR/fixture"
  mkdir -p "$fixture/lib" "$fixture/runs/app"
  printf '%s\n' 'alpha.one' \
    'beta.skip — never walked: no live run has needed it yet' \
    > "$fixture/lib/roads.txt"
  printf '%s\n' \
    '{"ts":"2026-01-01T00:00:00Z","event":"beta.skip","script":"bin/x","ticket":"","task":"","exit":0,"ms":1}' \
    > "$fixture/runs/app/telemetry.jsonl"
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/bin/routine-road-check"
  [ "$status" -eq 1 ]
  printf '%s\n' "$output" | grep -q 'stale waiver: beta.skip was walked'
}

@test "two consecutive runs on a corpus-less checkout agree" {
  fixture="$BATS_TEST_TMPDIR/fixture"
  mkdir -p "$fixture/lib" "$fixture/runs/fixture"
  printf '%s\n' 'alpha.one' 'beta.never' > "$fixture/lib/roads.txt"
  run env ROUTINE_ROOT="$fixture" TARGET="$fixture" \
    "$ROUTINE_REPO_ROOT/bin/routine-road-check"
  first_status="$status"
  first_output="$output"
  run env ROUTINE_ROOT="$fixture" TARGET="$fixture" \
    "$ROUTINE_REPO_ROOT/bin/routine-road-check"
  [ "$first_status" -eq 0 ]
  [ "$status" -eq 0 ]
  [ "$status" -eq "$first_status" ]
  printf '%s\n' "$first_output" | grep -qi 'decided nothing\|nothing decided'
  printf '%s\n' "$output" | grep -qi 'decided nothing\|nothing decided'
  case "$output" in *"never walked"*) false ;; *) ;; esac
}