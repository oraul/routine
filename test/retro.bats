#!/usr/bin/env bats

load test_helper

# Both apps hold a ticket 0001 — the collision is the point: blocked
# pairing must stay inside one app. app2's block for the same task id
# is bait that a cross-app pairing would wrongly close.
make_telemetry() {
  groot="$BATS_TEST_TMPDIR/groot"
  mkdir -p "$groot/runs/app1/tickets/0001" "$groot/runs/app2/tickets/archive/0001"
  cat > "$groot/runs/app1/tickets/0001/telemetry.jsonl" <<'EOF'
{"ts":"2026-08-11T09:00:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-01","exit":0,"ms":100}
{"ts":"2026-08-11T09:01:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-01","exit":1,"ms":200}
{"ts":"2026-08-11T10:00:00Z","event":"ticket.block","script":"bin/routine-block","ticket":"0001","task":"01-02","exit":0,"ms":0}
{"ts":"2026-08-11T11:00:00Z","event":"ticket.unblock","script":"bin/routine-unblock","ticket":"0001","task":"01-02","exit":0,"ms":0}
EOF
  cat > "$groot/runs/app2/tickets/archive/0001/telemetry.jsonl" <<'EOF'
{"ts":"2026-08-11T09:02:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-01","exit":0,"ms":300}
{"ts":"2026-08-11T09:03:00Z","event":"spec.lint","script":"bin/routine-spec-lint","ticket":"0001","task":"","exit":1,"ms":50}
{"ts":"2026-08-11T10:30:00Z","event":"ticket.block","script":"bin/routine-block","ticket":"0001","task":"01-02","exit":0,"ms":0}
EOF
}

@test "retro computes duration stats and blocked seconds per app" {
  make_telemetry
  run env ROUTINE_ROOT="$groot" "$ROUTINE_REPO_ROOT/bin/routine-retro"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -E 'gate\.developer .*min=100 p50=200 p95=300 max=300' > /dev/null
  printf '%s\n' "$output" | grep -E 'app1 0001 01-02 +3600' > /dev/null
}

@test "retro never pairs colliding ticket ids across apps" {
  make_telemetry
  run env ROUTINE_ROOT="$groot" "$ROUTINE_REPO_ROOT/bin/routine-retro"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -E 'app2 0001 01-02 +still blocked' > /dev/null
  ! printf '%s\n' "$output" | grep -E '01-02 +1800' > /dev/null
}

@test "retro aggregates events and script failures across apps" {
  make_telemetry
  before="$(cd "$groot" && find runs -type f -exec cksum {} \; | sort)"
  run env ROUTINE_ROOT="$groot" "$ROUTINE_REPO_ROOT/bin/routine-retro"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -E 'gate\.developer +runs=3 +fails=1' > /dev/null
  printf '%s\n' "$output" | grep -E 'spec\.lint +runs=1 +fails=1' > /dev/null
  printf '%s\n' "$output" | grep -E 'bin/routine-gate +1' > /dev/null
  printf '%s\n' "$output" | grep -E 'bin/routine-spec-lint +1' > /dev/null
  after="$(cd "$groot" && find runs -type f -exec cksum {} \; | sort)"
  [ "$before" = "$after" ]
}
