#!/usr/bin/env bats

load test_helper

# Fixture release root: a git repo on main with a manifest, a fake green
# selfcheck, a well-formed release record at evidence/v0.1.0.md, and one
# commit so the tree can be clean.
make_release_root() {
  rroot="$BATS_TEST_TMPDIR/rroot"
  mkdir -p "$rroot/bin" "$rroot/.claude-plugin" "$rroot/evidence"
  printf '%s\n' '{' '  "name": "routine",' '  "version": "0.1.0"' '}' \
    > "$rroot/.claude-plugin/plugin.json"
  printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$rroot/bin/routine-selfcheck"
  chmod +x "$rroot/bin/routine-selfcheck"
  printf '%s\n' \
    '# Release record: v0.1.0' \
    '' \
    '## Caffeine' \
    '- none — nothing this release taught the corpus anything new' \
    '' \
    '## Gate' \
    '- none — nothing shipped that a gate should have caught and did not' \
    > "$rroot/evidence/v0.1.0.md"
  git -C "$rroot" -c init.defaultBranch=main init -q
  git -C "$rroot" add -A
  git -C "$rroot" -c user.name=test -c user.email=test@example.invalid \
    commit -qm "root"
}

@test "all conditions met exits 0" {
  make_release_root
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-release-check" v0.1.0
  [ "$status" -eq 0 ]
}

@test "malformed version exits with usage" {
  make_release_root
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-release-check" 0.1.0
  [ "$status" -ne 0 ]
  case "$output" in *vX.Y.Z*|*"v<major>"*) ;; *) false ;; esac
}

@test "manifest mismatch names the versions" {
  make_release_root
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-release-check" v0.2.0
  [ "$status" -ne 0 ]
  case "$output" in *0.2.0*0.1.0*|*0.1.0*0.2.0*) ;; *) false ;; esac
}

@test "dirty worktree blocks the release" {
  make_release_root
  touch "$rroot/uncommitted"
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-release-check" v0.1.0
  [ "$status" -ne 0 ]
  case "$output" in *clean*|*worktree*) ;; *) false ;; esac
}

@test "off-main blocks the release" {
  make_release_root
  git -C "$rroot" checkout -qb feature-branch
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-release-check" v0.1.0
  [ "$status" -ne 0 ]
  case "$output" in *main*) ;; *) false ;; esac
}

@test "red selfcheck blocks the release" {
  make_release_root
  printf '%s\n' '#!/usr/bin/env bash' 'exit 1' > "$rroot/bin/routine-selfcheck"
  git -C "$rroot" add -A
  git -C "$rroot" -c user.name=test -c user.email=test@example.invalid \
    commit -qm "break selfcheck"
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-release-check" v0.1.0
  [ "$status" -ne 0 ]
}

@test "absent release record names the expected path" {
  make_release_root
  rm "$rroot/evidence/v0.1.0.md"
  git -C "$rroot" add -A
  git -C "$rroot" -c user.name=test -c user.email=test@example.invalid \
    commit -qm "drop record"
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-release-check" v0.1.0
  [ "$status" -ne 0 ]
  case "$output" in *"evidence/v0.1.0.md"*) ;; *) false ;; esac
}

@test "malformed record surfaces the lint's own violation line" {
  make_release_root
  printf '%s\n' \
    '# Release record: v0.1.0' \
    '' \
    '## Caffeine' \
    '- none — nothing this release taught the corpus anything new' \
    > "$rroot/evidence/v0.1.0.md"
  git -C "$rroot" add -A
  git -C "$rroot" -c user.name=test -c user.email=test@example.invalid \
    commit -qm "break record"
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-release-check" v0.1.0
  [ "$status" -ne 0 ]
  case "$output" in *"missing '## Gate' section"*) ;; *) false ;; esac
}
