#!/usr/bin/env bats

load test_helper

# Evidence is rendered, never recomputed: the panel's lesson was that a
# second derivation of the same number drifts from the first. The body
# must be the retro's output byte for byte.
make_corpus() {
  vroot="$BATS_TEST_TMPDIR/vroot"
  mkdir -p "$vroot/runs/app/tickets/archive/0001"
  cat > "$vroot/runs/app/tickets/archive/0001/telemetry.jsonl" <<'T'
{"ts":"2026-08-11T09:00:00Z","event":"ticket.new","script":"bin/routine-ticket-new","ticket":"0001","task":"","exit":0,"ms":3}
{"ts":"2026-08-11T09:01:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-01","exit":1,"ms":900}
{"ts":"2026-08-11T09:02:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-01","exit":0,"ms":870}
T
  : > "$vroot/runs/app/tickets/archive/0001/index.tsv"
}

@test "the body is the retro, byte for byte" {
  make_corpus
  retro="$(env ROUTINE_ROOT="$vroot" "$ROUTINE_REPO_ROOT/bin/routine-retro")"
  snap="$(env ROUTINE_ROOT="$vroot" "$ROUTINE_REPO_ROOT/bin/routine-evidence")"
  # Strip the header: everything from the first retro line onward is the body.
  body="$(printf '%s\n' "$snap" | awk '/^routine retro$/ {f=1} f')"
  [ "$body" = "$retro" ]
}

@test "the snapshot says what made it and when" {
  make_corpus
  run env ROUTINE_ROOT="$vroot" "$ROUTINE_REPO_ROOT/bin/routine-evidence"
  [ "$status" -eq 0 ]
  case "$output" in *routine-evidence*) ;; *) false ;; esac
  case "$output" in *generated*) ;; *) false ;; esac
  printf '%s\n' "$output" | grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}T'
}

@test "committed evidence exists and carries the generator header" {
  [ -f "$ROUTINE_REPO_ROOT/evidence/retro.txt" ]
  grep -q 'routine-evidence' "$ROUTINE_REPO_ROOT/evidence/retro.txt"
  grep -q '^routine retro$' "$ROUTINE_REPO_ROOT/evidence/retro.txt"
}
