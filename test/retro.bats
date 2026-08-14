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
{"ts":"2026-08-11T09:30:00Z","event":"gate.developer.script","script":"caffeine/ruby/rails.sh","ticket":"0001","task":"01-01","exit":0,"ms":40}
{"ts":"2026-08-11T09:31:00Z","event":"gate.developer.script","script":"caffeine/ruby/rails.sh","ticket":"0001","task":"01-01","exit":1,"ms":45}
{"ts":"2026-08-11T09:32:00Z","event":"gate.developer.doc","script":"caffeine/architecture/oop.md","ticket":"0001","task":"01-01","exit":0,"ms":0}
{"ts":"2026-08-11T10:00:00Z","event":"ticket.block","script":"bin/routine-block","ticket":"0001","task":"01-02","exit":0,"ms":0}
{"ts":"2026-08-11T11:00:00Z","event":"ticket.unblock","script":"bin/routine-unblock","ticket":"0001","task":"01-02","exit":0,"ms":0}
{"ts":"2026-08-11T12:00:00Z","event":"spec.lint","script":"bin/routine-spec-lint","ticket":"0001","task":"","exit":1,"ms":5}
{"ts":"2026-08-11T12:05:00Z","event":"spec.lint","script":"bin/routine-spec-lint","ticket":"0001","task":"","exit":0,"ms":5}
{"ts":"2026-08-11T13:00:00Z","event":"spec.defective","script":"bin/routine-defect","ticket":"0001","task":"01-01","exit":0,"ms":2}
{"ts":"2026-08-11T13:10:00Z","event":"spec.lint","script":"bin/routine-spec-lint","ticket":"0001","task":"","exit":1,"ms":5}
{"ts":"2026-08-11T13:20:00Z","event":"spec.lint","script":"bin/routine-spec-lint","ticket":"0001","task":"","exit":0,"ms":5}
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

@test "retro ranks caffeine topics by accumulated failures — the deepening queue" {
  make_telemetry
  run env ROUTINE_ROOT="$groot" "$ROUTINE_REPO_ROOT/bin/routine-retro"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -E '1 +0\.50 +caffeine/ruby/rails\.sh +runs=2' > /dev/null
  printf '%s\n' "$output" | grep -E '0 +0\.00 +caffeine/architecture/oop\.md +runs=1' > /dev/null
  rails_at="$(printf '%s\n' "$output" | grep -nE '^ +1 +0\.50 +caffeine/ruby/rails' | head -1 | cut -d: -f1)"
  oop_at="$(printf '%s\n' "$output" | grep -nE '^ +0 +0\.00 +caffeine/architecture/oop' | head -1 | cut -d: -f1)"
  [ "$rails_at" -lt "$oop_at" ]
}

@test "retro output is deterministic across runs" {
  make_telemetry
  first="$(env ROUTINE_ROOT="$groot" "$ROUTINE_REPO_ROOT/bin/routine-retro")"
  second="$(env ROUTINE_ROOT="$groot" "$ROUTINE_REPO_ROOT/bin/routine-retro")"
  [ "$first" = "$second" ]
  printf '%s\n' "$first" | grep -q 'caffeine topics:'
}

@test "retro aggregates events and script failures across apps" {
  make_telemetry
  before="$(cd "$groot" && find runs -type f -exec cksum {} \; | sort)"
  run env ROUTINE_ROOT="$groot" "$ROUTINE_REPO_ROOT/bin/routine-retro"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -E 'gate\.developer +runs=3 +fails=1' > /dev/null
  printf '%s\n' "$output" | grep -E 'spec\.lint +runs=5 +fails=3' > /dev/null
  printf '%s\n' "$output" | grep -E 'bin/routine-gate +1' > /dev/null
  printf '%s\n' "$output" | grep -E 'bin/routine-spec-lint +3' > /dev/null
  after="$(cd "$groot" && find runs -type f -exec cksum {} \; | sort)"
  [ "$before" = "$after" ]
}

@test "re-specify cost shows episodes, gate-counted lints, and recovery" {
  make_telemetry
  run env ROUTINE_ROOT="$groot" "$ROUTINE_REPO_ROOT/bin/routine-retro"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -E 'app1 0001 +episodes=2 failed_lints=2 worst_episode=1 recovery_s=1200' > /dev/null
}

@test "an unrecovered defect is named and cost never crosses apps" {
  make_telemetry
  cat >> "$groot/runs/app2/tickets/archive/0001/telemetry.jsonl" <<'EOF2'
{"ts":"2026-08-11T11:00:00Z","event":"spec.defective","script":"bin/routine-defect","ticket":"0001","task":"01-01","exit":0,"ms":2}
EOF2
  run env ROUTINE_ROOT="$groot" "$ROUTINE_REPO_ROOT/bin/routine-retro"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -E 'app2 0001 .*unrecovered' > /dev/null
  printf '%s\n' "$output" | grep -E 'app1 0001 .*recovery_s=1200' > /dev/null
}

# A failure is a failure and nothing else. Deliberate non-zero exits are
# the protocol working: routine-tdd red REQUIRES a failing command, and
# routine-next exits 3 and 4 report a blocked line and an exhausted one.
make_expected_exits() {
  eroot="$BATS_TEST_TMPDIR/eroot"
  mkdir -p "$eroot/runs/app1/tickets/0001"
  cat > "$eroot/runs/app1/tickets/0001/telemetry.jsonl" <<'T'
{"ts":"2026-08-11T09:00:00Z","event":"tdd.red","script":"login rejects a bad password [aa11bb22]","ticket":"0001","task":"01-01","exit":1,"ms":30}
{"ts":"2026-08-11T09:01:00Z","event":"tdd.green","script":"login rejects a bad password [aa11bb22]","ticket":"0001","task":"01-01","exit":0,"ms":31}
{"ts":"2026-08-11T09:02:00Z","event":"ticket.next","script":"bin/routine-next","ticket":"0001","task":"01-02","exit":3,"ms":2}
{"ts":"2026-08-11T09:03:00Z","event":"ticket.next","script":"bin/routine-next","ticket":"0001","task":"","exit":4,"ms":2}
T
}

@test "a correct red and a blocked or exhausted line are not failures" {
  make_expected_exits
  run env ROUTINE_ROOT="$eroot" "$ROUTINE_REPO_ROOT/bin/routine-retro"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -E 'tdd\.red .*fails=0' > /dev/null
  printf '%s\n' "$output" | grep -E 'ticket\.next .*fails=0' > /dev/null
}

@test "a red that passed is named as the anomaly" {
  make_expected_exits
  printf '{"ts":"2026-08-11T09:04:00Z","event":"tdd.red","script":"a red that passed [cc33dd44]","ticket":"0001","task":"01-03","exit":0,"ms":9}\n' \
    >> "$eroot/runs/app1/tickets/0001/telemetry.jsonl"
  run env ROUTINE_ROOT="$eroot" "$ROUTINE_REPO_ROOT/bin/routine-retro"
  case "$output" in *"red that passed"*) ;; *) false ;; esac
}

@test "script failures name scripts, never scenario labels" {
  make_expected_exits
  run env ROUTINE_ROOT="$eroot" "$ROUTINE_REPO_ROOT/bin/routine-retro"
  # The scenario label must not appear in the script-failure section.
  ! printf '%s\n' "$output" | awk '/^script failures:/{a=1;next} /^$/{a=0} a' \
    | grep -q 'bad password'
}

@test "a refused block leaves no phantom" {
  eroot="$BATS_TEST_TMPDIR/broot"
  mkdir -p "$eroot/runs/app1/tickets/0001"
  cat > "$eroot/runs/app1/tickets/0001/telemetry.jsonl" <<'T'
{"ts":"2026-08-11T10:00:00Z","event":"ticket.block","script":"bin/routine-block","ticket":"0001","task":"01-02","exit":1,"ms":1}
T
  run env ROUTINE_ROOT="$eroot" "$ROUTINE_REPO_ROOT/bin/routine-retro"
  [ "$status" -eq 0 ]
  ! printf '%s\n' "$output" | grep -q 'still blocked'
}

@test "the queue ranks by accumulated failures, not by one unlucky run" {
  eroot="$BATS_TEST_TMPDIR/croot"
  mkdir -p "$eroot/runs/app1/tickets/0001"
  : > "$eroot/runs/app1/tickets/0001/telemetry.jsonl"
  # thin/unlucky: one run, one failure (rate 1.00)
  printf '{"ts":"2026-08-11T11:00:00Z","event":"gate.developer.script","script":"caffeine/x/thin.sh","ticket":"0001","task":"01-01","exit":1,"ms":5}\n' \
    >> "$eroot/runs/app1/tickets/0001/telemetry.jsonl"
  # deep: ten runs, four failures (rate 0.40) — more accumulated pain
  for i in 1 2 3 4; do
    printf '{"ts":"2026-08-11T11:0%s:00Z","event":"gate.developer.script","script":"caffeine/x/deep.sh","ticket":"0001","task":"01-01","exit":1,"ms":5}\n' "$i" \
      >> "$eroot/runs/app1/tickets/0001/telemetry.jsonl"
  done
  for i in 5 6 7 8 9; do
    printf '{"ts":"2026-08-11T11:0%s:00Z","event":"gate.developer.script","script":"caffeine/x/deep.sh","ticket":"0001","task":"01-01","exit":0,"ms":5}\n' "$i" \
      >> "$eroot/runs/app1/tickets/0001/telemetry.jsonl"
  done
  run env ROUTINE_ROOT="$eroot" "$ROUTINE_REPO_ROOT/bin/routine-retro"
  deep_at="$(printf '%s\n' "$output" | grep -n 'x/deep' | head -1 | cut -d: -f1)"
  thin_at="$(printf '%s\n' "$output" | grep -n 'x/thin' | head -1 | cut -d: -f1)"
  [ -n "$deep_at" ] && [ -n "$thin_at" ]
  [ "$deep_at" -lt "$thin_at" ]
}
