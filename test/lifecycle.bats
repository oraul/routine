#!/usr/bin/env bats

load test_helper

TAB="$(printf '\t')"

make_ticket() {
  ticket="$BATS_TEST_TMPDIR/0001"
  mkdir -p "$ticket/briefings/01-auth/tasks/01-login" \
           "$ticket/briefings/01-auth/tasks/02-session"
  : > "$ticket/index.tsv"
  "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket" > /dev/null
}

@test "each lifecycle step emits exactly one ticket.* line" {
  make_ticket
  touch "$ticket/briefings/01-auth/tasks/01-login/block.md" \
        "$ticket/briefings/01-auth/tasks/01-login/unblock.md"
  "$ROUTINE_REPO_ROOT/bin/routine-block" "$ticket" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-unblock" "$ticket" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-done" "$ticket" > /dev/null
  [ "$(grep -c '"event":"ticket.next"' "$ticket/telemetry.jsonl")" -eq 2 ]
  [ "$(grep -c '"event":"ticket.block"' "$ticket/telemetry.jsonl")" -eq 1 ]
  [ "$(grep -c '"event":"ticket.unblock"' "$ticket/telemetry.jsonl")" -eq 1 ]
  [ "$(grep -c '"event":"ticket.done"' "$ticket/telemetry.jsonl")" -eq 1 ]
}

@test "done marks the in_progress task with a fresh timestamp" {
  make_ticket
  run "$ROUTINE_REPO_ROOT/bin/routine-done" "$ticket"
  [ "$status" -eq 0 ]
  grep -q "^01-01${TAB}.*${TAB}done${TAB}" "$ticket/index.tsv"
  run "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket"
  [ "$output" = "$ticket/briefings/01-auth/tasks/02-session" ]
}

@test "done refuses when nothing is in_progress" {
  make_ticket
  "$ROUTINE_REPO_ROOT/bin/routine-done" "$ticket" > /dev/null
  run "$ROUTINE_REPO_ROOT/bin/routine-done" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *in_progress*) ;; *) false ;; esac
}

@test "block refuses without block.md" {
  make_ticket
  run "$ROUTINE_REPO_ROOT/bin/routine-block" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *block.md*) ;; *) false ;; esac
  grep -q "^01-01${TAB}.*${TAB}in_progress${TAB}" "$ticket/index.tsv"
}

@test "block parks the line and unblock releases it" {
  make_ticket
  touch "$ticket/briefings/01-auth/tasks/01-login/block.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-block" "$ticket"
  [ "$status" -eq 0 ]
  run "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket"
  [ "$status" -eq 3 ]
  run "$ROUTINE_REPO_ROOT/bin/routine-unblock" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *unblock.md*) ;; *) false ;; esac
  touch "$ticket/briefings/01-auth/tasks/01-login/unblock.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-unblock" "$ticket"
  [ "$status" -eq 0 ]
  run "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket"
  [ "$status" -eq 0 ]
  [ "$output" = "$ticket/briefings/01-auth/tasks/01-login" ]
}

@test "unblock addresses a named task or refuses with its status" {
  # Two blocked rows are unreachable through the scripts (the line blocks),
  # so the fixture writes the index state directly, as conclude.bats does.
  ticket="$BATS_TEST_TMPDIR/0001"
  mkdir -p "$ticket/briefings/01-auth/tasks/01-login" \
           "$ticket/briefings/01-auth/tasks/02-session"
  {
    printf '01-01%s01-auth%s01-login%sblocked%s2026-01-01T00:00:00Z\n' \
      "$TAB" "$TAB" "$TAB" "$TAB"
    printf '01-02%s01-auth%s02-session%sblocked%s2026-01-01T00:00:00Z\n' \
      "$TAB" "$TAB" "$TAB" "$TAB"
  } > "$ticket/index.tsv"
  touch "$ticket/briefings/01-auth/tasks/02-session/unblock.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-unblock" "$ticket" 01-99
  [ "$status" -ne 0 ]
  case "$output" in *01-99*) ;; *) false ;; esac
  run "$ROUTINE_REPO_ROOT/bin/routine-unblock" "$ticket" 01-02
  [ "$status" -eq 0 ]
  grep -q "^01-02${TAB}.*${TAB}pending${TAB}" "$ticket/index.tsv"
  grep -q "^01-01${TAB}.*${TAB}blocked${TAB}" "$ticket/index.tsv"
  run "$ROUTINE_REPO_ROOT/bin/routine-unblock" "$ticket" 01-02
  [ "$status" -ne 0 ]
  case "$output" in *pending*) ;; *) false ;; esac
}
