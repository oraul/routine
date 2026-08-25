#!/usr/bin/env bats

load test_helper

# A fixture root with a real git target and an archived ticket, so the
# replay judges controlled state. The anchor is a real commit of the
# fixture target, one commit behind its HEAD — a replay must check out
# the past, not the present.
make_replay_fixture() {
  fixture="$BATS_TEST_TMPDIR/fixture"
  mkdir -p "$fixture/runs/app/tickets/archive/0002"
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt"
  git -C "$tgt" -c init.defaultBranch=main init -q
  printf 'v1\n' > "$tgt/lib.rb"
  git -C "$tgt" add lib.rb
  git -C "$tgt" -c user.name=t -c user.email=t@example.invalid \
    commit -q -m "v1"
  anchor="$(git -C "$tgt" rev-parse HEAD)"
  printf 'v2\n' > "$tgt/lib.rb"
  git -C "$tgt" add lib.rb
  git -C "$tgt" -c user.name=t -c user.email=t@example.invalid \
    commit -q -m "v2"
  arch="$fixture/runs/app/tickets/archive/0002"
  printf '# Requirement: discounts\nThe order SHALL discount.\n' \
    > "$arch/requirement.md"
  printf 'Grounded-at: %s\n\n## Evidence\n- lib.rb — v1\n' "$anchor" \
    > "$arch/grounding.md"
  printf '%s\n' \
    '{"ts":"2026-01-01T00:00:00Z","event":"ticket.new","script":"bin/routine-ticket-new","ticket":"0002","task":"","exit":0,"ms":1}' \
    '{"ts":"2026-01-01T01:00:00Z","event":"ticket.abort","script":"bin/routine-abort","ticket":"0002","task":"","exit":0,"ms":1}' \
    > "$arch/telemetry.jsonl"
}

replay() {
  run env ROUTINE_ROOT="$fixture" TARGET="$tgt" \
    "$ROUTINE_REPO_ROOT/bin/routine-replay" "$@"
}

@test "the question is held still against the anchored past" {
  make_replay_fixture
  replay "$arch"
  [ "$status" -eq 0 ]
  ticket="$fixture/runs/app/tickets/0003"
  [ -d "$ticket" ]
  cmp -s "$arch/requirement.md" "$ticket/requirement.md"
  wt="$fixture/runs/app/replays/0002-$(printf '%.8s' "$anchor")/app"
  [ "$(git -C "$wt" rev-parse HEAD)" = "$anchor" ]
  grep -q 'v1' "$wt/lib.rb"
  grep -qF "Replay-of: $arch" "$ticket/replay.md"
  grep -qF "Anchor: $anchor" "$ticket/replay.md"
  head -1 "$ticket/telemetry.jsonl" | grep -q '"event":"ticket.new"'
  grep -q '"event":"ticket.replay"' "$ticket/telemetry.jsonl"
  printf '%s\n' "$output" | grep -q 'archived run ended with: ticket.abort'
}

@test "a refused allocation removes the worktree it created" {
  make_replay_fixture
  mkdir -p "$fixture/runs/app/tickets/0009"
  replay "$arch"
  [ "$status" -eq 1 ]
  [ -d "$fixture/runs/app" ]
  [ ! -d "$fixture/runs/app/replays" ]
  [ "$(git -C "$tgt" worktree list | wc -l | tr -d ' ')" -eq 1 ]
}

@test "an existing replay worktree is refused" {
  make_replay_fixture
  mkdir -p "$fixture/runs/app/replays/0002-$(printf '%.8s' "$anchor")"
  replay "$arch"
  [ "$status" -eq 1 ]
  printf '%s\n' "$output" | grep -q 'already exists'
}

@test "no archived ticket argument is a usage error" {
  make_replay_fixture
  replay
  [ "$status" -eq 2 ]
  printf '%s\n' "$output" | grep -q 'usage'
}

@test "an archived ticket without a requirement is refused" {
  make_replay_fixture
  rm "$arch/requirement.md"
  replay "$arch"
  [ "$status" -eq 1 ]
  printf '%s\n' "$output" | grep -q 'requirement.md'
  [ -d "$fixture/runs/app" ]
  [ ! -d "$fixture/runs/app/replays" ]
}

@test "a run that predates the anchor rule cannot be replayed" {
  make_replay_fixture
  printf '## Evidence\n- lib.rb — v1\n' > "$arch/grounding.md"
  replay "$arch"
  [ "$status" -eq 1 ]
  printf '%s\n' "$output" | grep -q 'Grounded-at'
  [ -d "$fixture/runs/app" ]
  [ ! -d "$fixture/runs/app/replays" ]
}

@test "an anchor the target cannot resolve is refused" {
  make_replay_fixture
  printf 'Grounded-at: %s\n' \
    '0000000000000000000000000000000000000000' > "$arch/grounding.md"
  replay "$arch"
  [ "$status" -eq 1 ]
  printf '%s\n' "$output" | grep -q '0000000000000000000000000000000000000000'
  [ -d "$fixture/runs/app" ]
  [ ! -d "$fixture/runs/app/replays" ]
}