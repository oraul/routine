#!/usr/bin/env bats

load test_helper

checker="bin/routine-convention-check"

# A fixture repo with a base commit; tests add commits and check base..HEAD.
make_repo() {
  repo="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$repo"
  git -C "$repo" -c init.defaultBranch=main init -q
  printf 'clean\n' > "$repo/file.txt"
  git -C "$repo" add -A
  fixture_commit "root commit"
  git -C "$repo" tag base
}

fixture_commit() {
  git -C "$repo" -c user.name=test -c user.email=test@example.invalid \
    commit -q --allow-empty -m "$1"
}

add_file_commit() {
  printf '%s\n' "$2" >> "$repo/$1"
  git -C "$repo" add -A
  fixture_commit "$3"
}

@test "clean conventional history passes" {
  make_repo
  add_file_commit file.txt "more" "feat(bin): add a thing

Change: some-change"
  add_file_commit file.txt "docs" "docs: explain the thing"
  run env TARGET="$repo" "$ROUTINE_REPO_ROOT/$checker" base
  [ "$status" -eq 0 ]
}

@test "token-shaped string in the diff is caught" {
  make_repo
  add_file_commit config.txt "token = ghp_AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" \
    "chore: add config"
  run env TARGET="$repo" "$ROUTINE_REPO_ROOT/$checker" base
  [ "$status" -ne 0 ]
  case "$output" in *sensitive*) ;; *) false ;; esac
}

@test "session URL in a commit message is caught" {
  make_repo
  fixture_commit "chore: tidy

See https://claude.ai/code/session_0000000000000000000000000"
  run env TARGET="$repo" "$ROUTINE_REPO_ROOT/$checker" base
  [ "$status" -ne 0 ]
  case "$output" in *message*) ;; *) false ;; esac
}

@test "malformed subject is caught" {
  make_repo
  fixture_commit "updated stuff"
  run env TARGET="$repo" "$ROUTINE_REPO_ROOT/$checker" base
  [ "$status" -ne 0 ]
  case "$output" in *conventional*) ;; *) false ;; esac
}

@test "over-length subject is caught" {
  make_repo
  fixture_commit "chore: $(printf 'x%.0s' $(seq 1 80))"
  run env TARGET="$repo" "$ROUTINE_REPO_ROOT/$checker" base
  [ "$status" -ne 0 ]
  case "$output" in *72*) ;; *) false ;; esac
}

@test "behavior commit without Change trailer is caught; merges exempt" {
  make_repo
  fixture_commit "feat(bin): trailerless feature"
  git -C "$repo" checkout -qb side
  fixture_commit "chore: side work"
  git -C "$repo" checkout -q main 2>/dev/null || git -C "$repo" checkout -q master
  git -C "$repo" -c user.name=test -c user.email=test@example.invalid \
    merge -q --no-ff side -m "Merge anything at all: subjects of merges are never judged"
  run env TARGET="$repo" "$ROUTINE_REPO_ROOT/$checker" base
  [ "$status" -ne 0 ]
  case "$output" in *Change:*) ;; *) false ;; esac
  printf '%s\n' "$output" | grep -c 'never judged' | grep -qx 0
}
