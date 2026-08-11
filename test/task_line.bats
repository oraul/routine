#!/usr/bin/env bats

load test_helper

TAB="$(printf '\t')"

make_ticket() {
  ticket="$BATS_TEST_TMPDIR/0001"
  mkdir -p "$ticket/briefings/01-auth/tasks/01-login" \
           "$ticket/briefings/01-auth/tasks/02-session" \
           "$ticket/briefings/02-api/tasks/01-endpoints"
  : > "$ticket/index.tsv"
}

@test "sync appends missing tasks as pending in file order" {
  make_ticket
  run "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket"
  [ "$status" -eq 0 ]
  [ "$(cut -f1 "$ticket/index.tsv" | tr '\n' ' ')" = "01-01 01-02 02-01 " ]
  [ "$(awk -F'\t' 'NR==1{print $4}' "$ticket/index.tsv")" = "in_progress" ]
  [ "$(awk -F'\t' 'NR==2{print $4}' "$ticket/index.tsv")" = "pending" ]
}

@test "sync preserves existing rows verbatim" {
  make_ticket
  printf '01-01%s01-auth%s01-login%sdone%s2026-01-01T00:00:00Z\n' \
    "$TAB" "$TAB" "$TAB" "$TAB" > "$ticket/index.tsv"
  run "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket"
  [ "$status" -eq 0 ]
  [ "$(awk -F'\t' 'NR==1{print $4"/"$5}' "$ticket/index.tsv")" = "done/2026-01-01T00:00:00Z" ]
}

@test "next returns the first runnable task and marks it in_progress" {
  make_ticket
  run "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket"
  [ "$status" -eq 0 ]
  [ "$output" = "$ticket/briefings/01-auth/tasks/01-login" ]
  run "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket"
  [ "$status" -eq 0 ]
  [ "$output" = "$ticket/briefings/01-auth/tasks/01-login" ]
}

@test "a blocked task blocks the line" {
  make_ticket
  "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket" > /dev/null
  awk -F'\t' -v OFS='\t' '$1=="01-01"{$4="blocked"}{print}' "$ticket/index.tsv" \
    > "$ticket/index.tsv.new" && mv "$ticket/index.tsv.new" "$ticket/index.tsv"
  run "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket"
  [ "$status" -eq 3 ]
  case "$output" in *01-01*) ;; *) false ;; esac
  grep -q "^01-02${TAB}.*${TAB}pending${TAB}" "$ticket/index.tsv"
}

@test "an all-done index exits with its own code" {
  make_ticket
  ts=2026-01-01T00:00:00Z
  {
    printf '01-01%s01-auth%s01-login%sdone%s%s\n' "$TAB" "$TAB" "$TAB" "$TAB" "$ts"
    printf '01-02%s01-auth%s02-session%sdone%s%s\n' "$TAB" "$TAB" "$TAB" "$TAB" "$ts"
    printf '02-01%s02-api%s01-endpoints%sdone%s%s\n' "$TAB" "$TAB" "$TAB" "$TAB" "$ts"
  } > "$ticket/index.tsv"
  run "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket"
  [ "$status" -eq 4 ]
  case "$output" in *done*) ;; *) false ;; esac
}
