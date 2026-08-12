#!/usr/bin/env bats

load test_helper

TAB="$(printf '\t')"

# A two-task ticket with honest protocol telemetry: 01-01 completed the
# whole loop, 01-02 is in flight.
make_ticket() {
  tickets="$BATS_TEST_TMPDIR/tickets"
  ticket="$tickets/0001"
  mkdir -p "$ticket/briefings/01-auth/tasks/01-login" \
           "$ticket/briefings/01-auth/tasks/02-session"
  printf '%s\n' '# Task: x' '## Scenario: login' '- Given a' '- When b' '- Then c' \
    '## Acceptance' '1. works' '## Caffeine' \
    > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  printf '%s\n' '# Task: x' '## Scenario: session' '- Given a' '- When b' '- Then c' \
    '## Acceptance' '1. works' '## Caffeine' \
    > "$ticket/briefings/01-auth/tasks/02-session/task.md"
  {
    printf '01-01%s01-auth%s01-login%sdone%s2026-01-01T00:00:00Z\n' \
      "$TAB" "$TAB" "$TAB" "$TAB"
    printf '01-02%s01-auth%s02-session%sin_progress%s2026-01-01T00:00:00Z\n' \
      "$TAB" "$TAB" "$TAB" "$TAB"
  } > "$ticket/index.tsv"
  cat > "$ticket/telemetry.jsonl" <<'EOF'
{"ts":"2026-01-01T00:00:00Z","event":"ticket.new","script":"bin/routine-ticket-new","ticket":"0001","task":"","exit":0,"ms":1}
{"ts":"2026-01-01T00:00:30Z","event":"gate.preflight","script":"bin/routine-gate","ticket":"0001","task":"","exit":0,"ms":8}
{"ts":"2026-01-01T00:01:00Z","event":"gate.analyst","script":"bin/routine-gate","ticket":"0001","task":"","exit":0,"ms":10}
{"ts":"2026-01-01T00:02:30Z","event":"ticket.approve","script":"bin/routine-approve","ticket":"0001","task":"","exit":0,"ms":1}
{"ts":"2026-01-01T00:02:00Z","event":"ticket.next","script":"bin/routine-next","ticket":"0001","task":"01-01","exit":0,"ms":2}
{"ts":"2026-01-01T00:03:00Z","event":"tdd.red","script":"login","ticket":"0001","task":"01-01","exit":1,"ms":30}
{"ts":"2026-01-01T00:04:00Z","event":"tdd.green","script":"login","ticket":"0001","task":"01-01","exit":0,"ms":30}
{"ts":"2026-01-01T00:05:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-01","exit":0,"ms":40}
{"ts":"2026-01-01T00:06:00Z","event":"ticket.done","script":"bin/routine-done","ticket":"0001","task":"01-01","exit":0,"ms":2}
{"ts":"2026-01-01T00:07:00Z","event":"ticket.next","script":"bin/routine-next","ticket":"0001","task":"01-02","exit":0,"ms":2}
EOF
}

# Completes 01-02's protocol on the record and marks every row done.
finish_ticket() {
  awk -F'\t' -v OFS='\t' '{$4="done"; print}' "$ticket/index.tsv" \
    > "$ticket/index.tsv.new" && mv "$ticket/index.tsv.new" "$ticket/index.tsv"
  cat >> "$ticket/telemetry.jsonl" <<'EOF'
{"ts":"2026-01-01T00:08:00Z","event":"tdd.red","script":"session","ticket":"0001","task":"01-02","exit":1,"ms":30}
{"ts":"2026-01-01T00:09:00Z","event":"tdd.green","script":"session","ticket":"0001","task":"01-02","exit":0,"ms":30}
{"ts":"2026-01-01T00:10:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-02","exit":0,"ms":40}
{"ts":"2026-01-01T00:11:00Z","event":"ticket.done","script":"bin/routine-done","ticket":"0001","task":"01-02","exit":0,"ms":2}
EOF
}

@test "conclude refuses naming unfinished tasks" {
  make_ticket
  run "$ROUTINE_REPO_ROOT/bin/routine-conclude" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *01-02*) ;; *) false ;; esac
  [ -d "$ticket" ]
  [ ! -d "$tickets/archive/0001" ]
  grep '"event":"ticket.conclude"' "$ticket/telemetry.jsonl" | grep -q '"exit":1'
}

@test "conclude refuses a finished ticket that fails the audit" {
  make_ticket
  awk -F'\t' -v OFS='\t' '{$4="done"; print}' "$ticket/index.tsv" \
    > "$ticket/index.tsv.new" && mv "$ticket/index.tsv.new" "$ticket/index.tsv"
  run "$ROUTINE_REPO_ROOT/bin/routine-conclude" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *audit*) ;; *) false ;; esac
  case "$output" in *01-02*) ;; *) false ;; esac
  [ -d "$ticket" ]
  [ ! -d "$tickets/archive/0001" ]
  grep '"event":"ticket.conclude"' "$ticket/telemetry.jsonl" | grep -q '"exit":1'
}

@test "conclude archives a finished ticket with report and telemetry" {
  make_ticket
  finish_ticket
  run "$ROUTINE_REPO_ROOT/bin/routine-conclude" "$ticket"
  [ "$status" -eq 0 ]
  case "$output" in *"$tickets/archive/0001"*) ;; *) false ;; esac
  [ ! -d "$ticket" ]
  [ -f "$tickets/archive/0001/report.md" ]
  grep -q '01-01' "$tickets/archive/0001/report.md"
  tail -1 "$tickets/archive/0001/telemetry.jsonl" | grep -q '"event":"ticket.conclude"'
}
