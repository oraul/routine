#!/usr/bin/env bats

load test_helper

make_ticket() {
  ticket="$BATS_TEST_TMPDIR/0001"
  mkdir -p "$ticket"
  printf '{"ts":"2026-01-01T00:00:00Z","event":"ticket.new","script":"bin/routine-ticket-new","ticket":"0001","task":"","exit":0,"ms":1}\n' \
    > "$ticket/telemetry.jsonl"
}

pass_analyst_gate() {
  printf '{"ts":"2026-01-01T00:02:00Z","event":"gate.analyst","script":"bin/routine-gate","ticket":"0001","task":"","exit":0,"ms":10}\n' \
    >> "$ticket/telemetry.jsonl"
}

@test "approval leaves a line and keeps the human's note" {
  make_ticket
  pass_analyst_gate
  run "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket" "ship without the CSV export"
  [ "$status" -eq 0 ]
  tail -1 "$ticket/telemetry.jsonl" | grep -q '"event":"ticket.approve"'
  grep -q "ship without the CSV export" "$ticket/approve.md"
  grep -qE '^## [0-9]{4}-' "$ticket/approve.md"
}

@test "a second approval keeps the first note" {
  make_ticket
  pass_analyst_gate
  "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket" "first pass ok" > /dev/null
  "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket" "re-approved after defect" > /dev/null
  grep -q "first pass ok" "$ticket/approve.md"
  grep -q "re-approved after defect" "$ticket/approve.md"
}

@test "ungated artifacts cannot be approved" {
  make_ticket
  run "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket" "note"
  [ "$status" -ne 0 ]
  case "$output" in *gate.analyst*) ;; *) false ;; esac
}

@test "a note is optional, the evidence is not" {
  make_ticket
  pass_analyst_gate
  run "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket"
  [ "$status" -eq 0 ]
  tail -1 "$ticket/telemetry.jsonl" | grep -q '"event":"ticket.approve"'
}

@test "an unanswered operator question blocks the proceed without a note" {
  make_ticket
  pass_analyst_gate
  printf '## Questions\n- does rounding favor the customer or the business — provisional: customer; operator may override\n' \
    > "$ticket/grounding.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *"rounding favor the customer"*) ;; *) false ;; esac
  grep -q '"event":"gate.analyst"' "$ticket/telemetry.jsonl"
  ! grep -q '"event":"ticket.approve"' "$ticket/telemetry.jsonl"
}

@test "a numbered answer earns the proceed and pairs in the record" {
  make_ticket
  pass_analyst_gate
  printf '## Questions\n- does rounding favor the customer or the business — provisional: customer; operator may override\n' \
    > "$ticket/grounding.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket" "1: customer rounding confirmed"
  [ "$status" -eq 0 ]
  tail -1 "$ticket/telemetry.jsonl" | grep -q '"event":"ticket.approve"'
  grep -q '^Q1: does rounding favor the customer' "$ticket/approve.md"
  grep -q '^A1: customer rounding confirmed' "$ticket/approve.md"
  grep -Eq '^Approved-at: [0-9a-f]{8}$' "$ticket/approve.md"
}

@test "a free-text note no longer answers open questions" {
  make_ticket
  pass_analyst_gate
  printf '## Questions\n- does rounding favor the customer — provisional: customer; operator may override\n- are fractional percents allowed — provisional: integers only; operator may override\n' \
    > "$ticket/grounding.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket" "sounds fine to me"
  [ "$status" -ne 0 ]
  case "$output" in *"rounding favor the customer"*) ;; *) false ;; esac
  case "$output" in *"fractional percents"*) ;; *) false ;; esac
  grep -q '"event":"gate.analyst"' "$ticket/telemetry.jsonl"
  ! grep -q '"event":"ticket.approve"' "$ticket/telemetry.jsonl"
}

@test "a missing index is refused naming the open question" {
  make_ticket
  pass_analyst_gate
  printf '## Questions\n- does rounding favor the customer — provisional: customer; operator may override\n- are fractional percents allowed — provisional: integers only; operator may override\n' \
    > "$ticket/grounding.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket" "1: customer, confirmed"
  [ "$status" -ne 0 ]
  case "$output" in *"fractional percents"*) ;; *) false ;; esac
  grep -q '"event":"gate.analyst"' "$ticket/telemetry.jsonl"
  ! grep -q '"event":"ticket.approve"' "$ticket/telemetry.jsonl"
}

@test "an answer naming no open question is refused" {
  make_ticket
  pass_analyst_gate
  printf '## Questions\n- does rounding favor the customer — provisional: customer; operator may override\n' \
    > "$ticket/grounding.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket" "$(printf '1: customer\n3: what question is this')"
  [ "$status" -ne 0 ]
  case "$output" in *"3"*) ;; *) false ;; esac
  grep -q '"event":"gate.analyst"' "$ticket/telemetry.jsonl"
  ! grep -q '"event":"ticket.approve"' "$ticket/telemetry.jsonl"
}

@test "a bare proceed still writes its fingerprinted entry" {
  make_ticket
  pass_analyst_gate
  run "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket"
  [ "$status" -eq 0 ]
  grep -Eq '^Approved-at: [0-9a-f]{8}$' "$ticket/approve.md"
}

@test "the fingerprint moves with the artifacts" {
  make_ticket
  pass_analyst_gate
  printf 'v1 of the requirement\n' > "$ticket/requirement.md"
  "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket" > /dev/null
  first="$(grep '^Approved-at: ' "$ticket/approve.md" | tail -1)"
  printf 'v2 — amended after the proceed\n' > "$ticket/requirement.md"
  "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket" > /dev/null
  second="$(grep '^Approved-at: ' "$ticket/approve.md" | tail -1)"
  [ -n "$first" ]
  [ -n "$second" ]
  [ "$first" != "$second" ]
}

@test "a standing ruling stops demanding a fresh answer" {
  make_ticket
  pass_analyst_gate
  printf '## Questions\n- does rounding favor the customer — provisional: customer; operator may override RULED at approve (approve.md A1): customer, per finance\n' \
    > "$ticket/grounding.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket"
  [ "$status" -eq 0 ]
  tail -1 "$ticket/telemetry.jsonl" | grep -q '"event":"ticket.approve"'
  grep -q '^A1: the ruling stands (RULED, not re-answered this proceed)$' "$ticket/approve.md"
}

@test "answering a ruled question records the moved ruling verbatim" {
  make_ticket
  pass_analyst_gate
  printf '## Questions\n- does rounding favor the customer — provisional: customer; operator may override RULED at approve (approve.md A1): customer, per finance\n' \
    > "$ticket/grounding.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket" "1: business, finance reversed the ruling"
  [ "$status" -eq 0 ]
  tail -1 "$ticket/telemetry.jsonl" | grep -q '"event":"ticket.approve"'
  grep -q '^A1: business, finance reversed the ruling$' "$ticket/approve.md"
}

@test "an unruled sibling still blocks beside a ruled question" {
  make_ticket
  pass_analyst_gate
  printf '## Questions\n- does rounding favor the customer — provisional: customer; operator may override RULED at approve (approve.md A1): customer, per finance\n- are fractional percents allowed — provisional: integers only; operator may override\n' \
    > "$ticket/grounding.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *"fractional percents"*) ;; *) false ;; esac
  case "$output" in *"rounding favor the customer"*) false ;; esac
  grep -q '"event":"gate.analyst"' "$ticket/telemetry.jsonl"
  ! grep -q '"event":"ticket.approve"' "$ticket/telemetry.jsonl"
  [ ! -f "$ticket/approve.md" ]
}

@test "a floor of nothing to ask never blocks the proceed" {
  make_ticket
  pass_analyst_gate
  printf '## Questions\n- none — nothing to ask\n' > "$ticket/grounding.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-approve" "$ticket"
  [ "$status" -eq 0 ]
  tail -1 "$ticket/telemetry.jsonl" | grep -q '"event":"ticket.approve"'
}
