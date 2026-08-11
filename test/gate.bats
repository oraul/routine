#!/usr/bin/env bats

load test_helper

# Fixture state root: a fake selfcheck (green by default) and a runs/ dir,
# reached through ROUTINE_ROOT (Law 6). routine-gate sources its libs from
# the real repo but resolves state, selfcheck, and hooks from this root.
make_gate_root() {
  groot="$BATS_TEST_TMPDIR/groot"
  mkdir -p "$groot/bin" "$groot/runs"
  printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$groot/bin/routine-selfcheck"
  chmod +x "$groot/bin/routine-selfcheck"
}

# Fixture target project: a git repo with one commit, clean, on a branch.
make_target() {
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt"
  git -C "$tgt" -c init.defaultBranch=main init -q
  git -C "$tgt" -c user.name=test -c user.email=test@example.invalid \
    commit -q --allow-empty -m "root"
}

@test "hook exit code is relayed verbatim" {
  make_gate_root
  make_target
  mkdir -p "$groot/runs/app/hooks"
  printf '%s\n' '#!/usr/bin/env bash' 'exit 7' > "$groot/runs/app/hooks/developer.sh"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-gate" developer
  [ "$status" -eq 7 ]
}

@test "failing selfcheck stops preflight before the hook" {
  make_gate_root
  make_target
  printf '%s\n' '#!/usr/bin/env bash' 'echo harness red' 'exit 1' > "$groot/bin/routine-selfcheck"
  mkdir -p "$groot/runs/app/hooks"
  printf '#!/usr/bin/env bash\ntouch "%s/hook-ran"\n' "$groot" > "$groot/runs/app/hooks/preflight.sh"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-gate" preflight
  [ "$status" -ne 0 ]
  case "$output" in *"harness red"*) ;; *) false ;; esac
  [ ! -f "$groot/hook-ran" ]
}

@test "missing optional hook logs one line and passes" {
  make_gate_root
  make_target
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-gate" analyst
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c 'no analyst hook')" -eq 1 ]
}

@test "missing developer hook aborts naming the file and an example" {
  make_gate_root
  make_target
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-gate" developer
  [ "$status" -ne 0 ]
  case "$output" in *"runs/app/hooks/developer.sh"*) ;; *) false ;; esac
  case "$output" in *'cd "$TARGET"'*) ;; *) false ;; esac
}

@test "red harness aborts preflight before any target check" {
  make_gate_root
  printf '%s\n' '#!/usr/bin/env bash' 'echo harness red' 'exit 1' > "$groot/bin/routine-selfcheck"
  run env ROUTINE_ROOT="$groot" TARGET="$BATS_TEST_TMPDIR/nonexistent" "$ROUTINE_REPO_ROOT/bin/routine-gate" preflight
  [ "$status" -ne 0 ]
  case "$output" in *"harness red"*) ;; *) false ;; esac
  case "$output" in *worktree*|*branch*) false ;; *) ;; esac
}

@test "preflight passes on a clean target on a branch" {
  make_gate_root
  make_target
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-gate" preflight
  [ "$status" -eq 0 ]
}

@test "preflight fails on a dirty target worktree" {
  make_gate_root
  make_target
  touch "$tgt/untracked-file"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-gate" preflight
  [ "$status" -ne 0 ]
  case "$output" in *worktree*) ;; *) false ;; esac
}

@test "preflight fails on a detached HEAD" {
  make_gate_root
  make_target
  git -C "$tgt" checkout -q --detach HEAD
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-gate" preflight
  [ "$status" -ne 0 ]
  case "$output" in *branch*) ;; *) false ;; esac
}

@test "gate emits one telemetry line when ticket context is set" {
  make_gate_root
  make_target
  tdir="$BATS_TEST_TMPDIR/ticket"
  mkdir -p "$tdir"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" ROUTINE_TICKET_DIR="$tdir" \
    "$ROUTINE_REPO_ROOT/bin/routine-gate" preflight
  [ "$status" -eq 0 ]
  [ "$(wc -l < "$tdir/telemetry.jsonl")" -eq 1 ]
  grep -q '"event":"gate.preflight"' "$tdir/telemetry.jsonl"
}

@test "gate emits nothing without ticket context" {
  make_gate_root
  make_target
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-gate" preflight
  [ "$status" -eq 0 ]
  [ -z "$(find "$BATS_TEST_TMPDIR" -name telemetry.jsonl)" ]
}

@test "missing gate name exits non-zero naming the gates" {
  run "$ROUTINE_REPO_ROOT/bin/routine-gate"
  [ "$status" -ne 0 ]
  case "$output" in *preflight*analyst*developer*) ;; *) false ;; esac
}

@test "unknown gate name exits non-zero naming the gates" {
  run "$ROUTINE_REPO_ROOT/bin/routine-gate" retro
  [ "$status" -ne 0 ]
  case "$output" in *preflight*analyst*developer*) ;; *) false ;; esac
}
