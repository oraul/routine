#!/usr/bin/env bats

load test_helper

TAB="$(printf '\t')"

make_ticket() {
  tickets="$BATS_TEST_TMPDIR/tickets"
  ticket="$tickets/0001"
  mkdir -p "$ticket/briefings/01-auth/tasks/01-login"
  {
    printf '01-01%s01-auth%s01-login%sdone%s2026-01-01T00:00:00Z\n' \
      "$TAB" "$TAB" "$TAB" "$TAB"
    printf '01-02%s01-auth%s02-session%sin_progress%s2026-01-01T00:00:00Z\n' \
      "$TAB" "$TAB" "$TAB" "$TAB"
  } > "$ticket/index.tsv"
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

@test "conclude archives a finished ticket with report and telemetry" {
  make_ticket
  awk -F'\t' -v OFS='\t' '{$4="done"; print}' "$ticket/index.tsv" \
    > "$ticket/index.tsv.new" && mv "$ticket/index.tsv.new" "$ticket/index.tsv"
  run "$ROUTINE_REPO_ROOT/bin/routine-conclude" "$ticket"
  [ "$status" -eq 0 ]
  case "$output" in *"$tickets/archive/0001"*) ;; *) false ;; esac
  [ ! -d "$ticket" ]
  [ -f "$tickets/archive/0001/report.md" ]
  grep -q '01-01' "$tickets/archive/0001/report.md"
  tail -1 "$tickets/archive/0001/telemetry.jsonl" | grep -q '"event":"ticket.conclude"'
}
