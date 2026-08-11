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
