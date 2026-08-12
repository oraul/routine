#!/usr/bin/env bats

load test_helper

TAB="$(printf '\t')"

# A ticket whose telemetry records one full protocol run for one done task.
make_run() {
  ticket="$BATS_TEST_TMPDIR/0001"
  mkdir -p "$ticket/briefings/01-auth/tasks/01-login"
  printf '%s\n' '# Task: login' '- Given a' '- When b' '- Then c' \
    '## Acceptance' '1. works' '## Caffeine' \
    > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  printf '01-01%s01-auth%s01-login%sdone%s2026-01-01T00:10:00Z\n' \
    "$TAB" "$TAB" "$TAB" "$TAB" > "$ticket/index.tsv"
  cat > "$ticket/telemetry.jsonl" <<'EOF'
{"ts":"2026-01-01T00:00:00Z","event":"ticket.new","script":"bin/routine-ticket-new","ticket":"0001","task":"","exit":0,"ms":1}
{"ts":"2026-01-01T00:00:30Z","event":"gate.preflight","script":"bin/routine-gate","ticket":"0001","task":"","exit":0,"ms":8}
{"ts":"2026-01-01T00:01:00Z","event":"spec.lint","script":"bin/routine-spec-lint","ticket":"0001","task":"","exit":0,"ms":5}
{"ts":"2026-01-01T00:02:00Z","event":"gate.analyst","script":"bin/routine-gate","ticket":"0001","task":"","exit":0,"ms":10}
{"ts":"2026-01-01T00:03:00Z","event":"ticket.next","script":"bin/routine-next","ticket":"0001","task":"01-01","exit":0,"ms":2}
{"ts":"2026-01-01T00:04:00Z","event":"tdd.red","script":"login works","ticket":"0001","task":"01-01","exit":1,"ms":30}
{"ts":"2026-01-01T00:05:00Z","event":"tdd.green","script":"login works","ticket":"0001","task":"01-01","exit":0,"ms":30}
{"ts":"2026-01-01T00:06:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-01","exit":0,"ms":40}
{"ts":"2026-01-01T00:07:00Z","event":"ticket.done","script":"bin/routine-done","ticket":"0001","task":"01-01","exit":0,"ms":2}
EOF
}

@test "a complete run passes and writes nothing" {
  make_run
  before="$(cd "$ticket" && find . -type f -exec cksum {} \; | sort)"
  run "$ROUTINE_REPO_ROOT/bin/routine-audit" "$ticket"
  [ "$status" -eq 0 ]
  after="$(cd "$ticket" && find . -type f -exec cksum {} \; | sort)"
  [ "$before" = "$after" ]
}

@test "first event must be ticket.new" {
  make_run
  sed '1d' "$ticket/telemetry.jsonl" > "$ticket/t.new" \
    && mv "$ticket/t.new" "$ticket/telemetry.jsonl"
  run "$ROUTINE_REPO_ROOT/bin/routine-audit" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *ticket.new*) ;; *) false ;; esac
}

@test "a passing preflight gate must be on record" {
  make_run
  grep -v gate.preflight "$ticket/telemetry.jsonl" > "$ticket/t.new" \
    && mv "$ticket/t.new" "$ticket/telemetry.jsonl"
  run "$ROUTINE_REPO_ROOT/bin/routine-audit" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *gate.preflight*) ;; *) false ;; esac
}

@test "a passing analyst gate must be on record" {
  make_run
  grep -v gate.analyst "$ticket/telemetry.jsonl" > "$ticket/t.new" \
    && mv "$ticket/t.new" "$ticket/telemetry.jsonl"
  run "$ROUTINE_REPO_ROOT/bin/routine-audit" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *gate.analyst*) ;; *) false ;; esac
}

@test "all violations are reported in one run" {
  make_run
  grep -v gate.analyst "$ticket/telemetry.jsonl" | sed '1d' > "$ticket/t.new" \
    && mv "$ticket/t.new" "$ticket/telemetry.jsonl"
  run "$ROUTINE_REPO_ROOT/bin/routine-audit" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *ticket.new*) ;; *) false ;; esac
  case "$output" in *gate.analyst*) ;; *) false ;; esac
}

@test "green without a prior red for the scenario is a violation" {
  make_run
  grep -v tdd.red "$ticket/telemetry.jsonl" > "$ticket/t.new" \
    && mv "$ticket/t.new" "$ticket/telemetry.jsonl"
  run "$ROUTINE_REPO_ROOT/bin/routine-audit" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *01-01*"login works"*) ;; *) false ;; esac
}

@test "a done task without tdd.green is a violation" {
  make_run
  grep -v tdd.green "$ticket/telemetry.jsonl" > "$ticket/t.new" \
    && mv "$ticket/t.new" "$ticket/telemetry.jsonl"
  run "$ROUTINE_REPO_ROOT/bin/routine-audit" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *01-01*tdd.green*) ;; *) false ;; esac
}

@test "a skipped developer gate is a violation" {
  make_run
  grep -v gate.developer "$ticket/telemetry.jsonl" > "$ticket/t.new" \
    && mv "$ticket/t.new" "$ticket/telemetry.jsonl"
  run "$ROUTINE_REPO_ROOT/bin/routine-audit" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *01-01*gate.developer*) ;; *) false ;; esac
}

@test "missing next or done evidence is a violation" {
  make_run
  grep -v ticket.next "$ticket/telemetry.jsonl" | grep -v ticket.done \
    > "$ticket/t.new" && mv "$ticket/t.new" "$ticket/telemetry.jsonl"
  run "$ROUTINE_REPO_ROOT/bin/routine-audit" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *01-01*ticket.next*) ;; *) false ;; esac
  case "$output" in *01-01*ticket.done*) ;; *) false ;; esac
}

@test "manifest sh topic needs a green sidecar line, doc topic its doc line" {
  make_run
  printf '%s\n' '# Task: login' '- Given a' '- When b' '- Then c' \
    '## Acceptance' '1. works' '## Caffeine' '- ruby/rails' '- architecture/oop' \
    > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-audit" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *01-01*"ruby/rails"*) ;; *) false ;; esac
  case "$output" in *01-01*"architecture/oop"*) ;; *) false ;; esac
  printf '%s\n' \
    '{"ts":"2026-01-01T00:06:30Z","event":"gate.developer.script","script":"caffeine/ruby/rails.sh","ticket":"0001","task":"01-01","exit":0,"ms":9}' \
    '{"ts":"2026-01-01T00:06:31Z","event":"gate.developer.doc","script":"caffeine/architecture/oop.md","ticket":"0001","task":"01-01","exit":0,"ms":0}' \
    >> "$ticket/telemetry.jsonl"
  run "$ROUTINE_REPO_ROOT/bin/routine-audit" "$ticket"
  [ "$status" -eq 0 ]
}

@test "an unreleased block is a violation, a balanced one is not" {
  make_run
  printf '%s\n' \
    '{"ts":"2026-01-01T00:03:30Z","event":"ticket.block","script":"bin/routine-block","ticket":"0001","task":"01-01","exit":0,"ms":1}' \
    >> "$ticket/telemetry.jsonl"
  run "$ROUTINE_REPO_ROOT/bin/routine-audit" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *01-01*block*) ;; *) false ;; esac
  printf '%s\n' \
    '{"ts":"2026-01-01T00:03:40Z","event":"ticket.unblock","script":"bin/routine-unblock","ticket":"0001","task":"01-01","exit":0,"ms":1}' \
    >> "$ticket/telemetry.jsonl"
  run "$ROUTINE_REPO_ROOT/bin/routine-audit" "$ticket"
  [ "$status" -eq 0 ]
}

@test "usage without a ticket dir" {
  run "$ROUTINE_REPO_ROOT/bin/routine-audit" "$BATS_TEST_TMPDIR/nope"
  [ "$status" -eq 2 ]
  case "$output" in *usage*) ;; *) false ;; esac
}
