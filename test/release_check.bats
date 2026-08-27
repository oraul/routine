#!/usr/bin/env bats

load test_helper

# Fixture release root: a git repo on main with a manifest, a fake green
# selfcheck, a well-formed release record at evidence/v0.1.0.md, and one
# commit so the tree can be clean. lib/roads.txt and an empty runs/ dir
# are present too, the same corpus-less shape a fresh checkout gets in
# production (runs/routine/README.md is committed there, so runs/
# always exists even with no telemetry under it) — this fixture's road
# check decides nothing by default, matching the release spec's
# corpus-less scenario, and individual tests add telemetry to exercise
# the other one.
make_release_root() {
  rroot="$BATS_TEST_TMPDIR/rroot"
  mkdir -p "$rroot/bin" "$rroot/.claude-plugin" "$rroot/evidence" \
    "$rroot/lib" "$rroot/runs"
  printf '%s\n' 'alpha.one' > "$rroot/lib/roads.txt"
  # runs/ is gitignored here the same way it is in this repository, so
  # telemetry a test writes under it later never dirties the worktree.
  printf '%s\n' 'runs/' > "$rroot/.gitignore"
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

@test "previous release's well-formed record does not satisfy the new tag" {
  make_release_root
  printf '%s\n' '{' '  "name": "routine",' '  "version": "0.2.0"' '}' \
    > "$rroot/.claude-plugin/plugin.json"
  git -C "$rroot" add -A
  git -C "$rroot" -c user.name=test -c user.email=test@example.invalid \
    commit -qm "bump version"
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-release-check" v0.2.0
  [ "$status" -ne 0 ]
  case "$output" in *"evidence/v0.2.0.md"*) ;; *) false ;; esac
}

# A render in the fixture root, plus the generator its header names, so
# the release gate's relay of routine-render-check can be exercised
# without touching this repository's own evidence/.
add_render() {
  declared="$1"
  body="$2"
  {
    echo '#!/usr/bin/env bash'
    echo "echo \"# generated by bin/routine-report at \$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
    echo "echo '# corpus: $declared'"
    echo "echo '$body'"
  } > "$rroot/bin/routine-report"
  chmod +x "$rroot/bin/routine-report"
}

commit_render() {
  committed="$1"
  printf '%s\n' \
    '# generated by bin/routine-report at 2020-01-01T00:00:00Z' \
    "# corpus: $2" \
    "$committed" > "$rroot/evidence/report.txt"
  git -C "$rroot" add -A
  git -C "$rroot" -c user.name=test -c user.email=test@example.invalid \
    commit -qm "render"
}

@test "a stale render blocks the release" {
  make_release_root
  add_render "3 telemetry file(s) under runs/" "alpha=1"
  commit_render "alpha=99" "3 telemetry file(s) under runs/"
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-release-check" v0.1.0
  [ "$status" -eq 1 ]
  case "$output" in *"report.txt"*) ;; *) false ;; esac
}

@test "the gate relays the render check's own refusal text" {
  make_release_root
  add_render "3 telemetry file(s) under runs/" "alpha=1"
  commit_render "alpha=99" "3 telemetry file(s) under runs/"
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-release-check" v0.1.0
  [ "$status" -eq 1 ]
  case "$output" in *"refresh with"*) ;; *) false ;; esac
}

@test "a fresh render leaves the release passable" {
  make_release_root
  add_render "3 telemetry file(s) under runs/" "alpha=1"
  commit_render "alpha=1" "3 telemetry file(s) under runs/"
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-release-check" v0.1.0
  [ "$status" -eq 0 ]
}

@test "a render the machine cannot decide does not block the release" {
  make_release_root
  add_render "none — nothing to render from" "alpha=0"
  commit_render "alpha=99" "3 telemetry file(s) under runs/"
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-release-check" v0.1.0
  [ "$status" -eq 0 ]
  case "$output" in *"not decided"*) ;; *) false ;; esac
}

# An undeclared-road telemetry line, written directly rather than
# through telemetry_emit, so the fixture stays independent of the
# writer it is meant to catch disagreeing with.
add_undeclared_road_telemetry() {
  mkdir -p "$rroot/runs/app"
  printf '%s\n' \
    '{"ts":"2026-01-01T00:00:00Z","event":"totally.rogue","script":"bin/x","ticket":"","task":"","exit":0,"ms":1}' \
    > "$rroot/runs/app/telemetry.jsonl"
}

@test "an undeclared road walked refuses the release" {
  make_release_root
  add_undeclared_road_telemetry
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-release-check" v0.1.0
  [ "$status" -eq 1 ]
  case "$output" in *"undeclared road walked: totally.rogue"*) ;; *) false ;; esac
}

@test "the gate relays the road check's own violation text" {
  make_release_root
  add_undeclared_road_telemetry
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-release-check" v0.1.0
  [ "$status" -eq 1 ]
  case "$output" in *"declare it in lib/roads.txt"*) ;; *) false ;; esac
}

@test "a corpus-less release is not blocked by the road check" {
  make_release_root
  run env ROUTINE_ROOT="$rroot" "$ROUTINE_REPO_ROOT/bin/routine-release-check" v0.1.0
  [ "$status" -eq 0 ]
  case "$output" in *"nothing decided"*) ;; *) false ;; esac
}
