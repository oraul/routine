#!/usr/bin/env bats

load test_helper

# A fixture repo with two PR-style merges, a tag between them, and
# owner-free merge titles — the grammar the notes derive from.
make_history() {
  repo="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$repo"
  git -C "$repo" -c init.defaultBranch=main init -q
  g() { git -C "$repo" -c user.name=t -c user.email=t@example.invalid "$@"; }
  g commit -q --allow-empty -m "root"
  g checkout -q -b change/add-x
  g commit -q --allow-empty -m "feat(bin): x"
  g checkout -q main
  g merge -q --no-ff change/add-x -m "Merge pull request #1: feat: add-x — x exists"
  g tag v0.1.0
  g checkout -q -b change/add-y
  g commit -q --allow-empty -m "feat(bin): y"
  g checkout -q main
  g merge -q --no-ff change/add-y -m "Merge pull request #2: feat: add-y — y exists"
}

@test "notes are merge-subject bullets for the release range" {
  make_history
  run "$ROUTINE_REPO_ROOT/bin/routine-release-notes" v0.2.0 "$repo"
  [ "$status" -eq 0 ]
  case "$output" in *"- feat: add-y — y exists"*) ;; *) false ;; esac
}

@test "range excludes merges before the previous tag" {
  make_history
  run "$ROUTINE_REPO_ROOT/bin/routine-release-notes" v0.2.0 "$repo"
  [ "$status" -eq 0 ]
  case "$output" in *"add-x"*) false ;; *) ;; esac
}

@test "first release covers all history" {
  make_history
  git -C "$repo" tag -d v0.1.0 > /dev/null
  run "$ROUTINE_REPO_ROOT/bin/routine-release-notes" v0.1.0 "$repo"
  [ "$status" -eq 0 ]
  case "$output" in *"add-x"*) ;; *) false ;; esac
  case "$output" in *"add-y"*) ;; *) false ;; esac
}

@test "an existing tag's notes cover previous-tag..tag" {
  make_history
  git -C "$repo" tag v0.2.0
  git -C "$repo" -c user.name=t -c user.email=t@example.invalid \
    commit -q --allow-empty -m "post-release commit"
  run "$ROUTINE_REPO_ROOT/bin/routine-release-notes" v0.2.0 "$repo"
  [ "$status" -eq 0 ]
  case "$output" in *"add-y"*) ;; *) false ;; esac
  case "$output" in *"add-x"*) false ;; *) ;; esac
}

@test "output is owner-free" {
  make_history
  run "$ROUTINE_REPO_ROOT/bin/routine-release-notes" v0.2.0 "$repo"
  [ "$status" -eq 0 ]
  case "$output" in *@*) false ;; *) ;; esac
}

@test "usage on a malformed tag" {
  make_history
  run "$ROUTINE_REPO_ROOT/bin/routine-release-notes" not-a-tag "$repo"
  [ "$status" -eq 2 ]
  case "$output" in *usage*) ;; *) false ;; esac
}
