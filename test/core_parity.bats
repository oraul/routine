#!/usr/bin/env bats

load test_helper

# Builds the core binary exactly once for this whole file (never per
# test), the same setup_file pattern test/core.bats uses: the build
# status is handed to tests through a plain file, and no @test body
# reads BATS_FILE_TMPDIR directly — only setup() does.
setup_file() {
  repo_root="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  built_commit="$(git -C "$repo_root" describe --always --dirty 2> /dev/null)"
  [ -n "$built_commit" ] || built_commit="unknown"
  build_status=0
  (
    cd "$repo_root" || exit 1
    go build -ldflags "-X main.commit=$built_commit" \
      -o "$BATS_FILE_TMPDIR/routine" ./cmd/routine
  ) > "$BATS_FILE_TMPDIR/build.log" 2>&1 || build_status=$?
  echo "$build_status" > "$BATS_FILE_TMPDIR/build.status"
}

setup() {
  ROUTINE_REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export ROUTINE_REPO_ROOT
  routine_bin="$BATS_FILE_TMPDIR/routine"
  build_status="$(cat "$BATS_FILE_TMPDIR/build.status")"
}

# A fixture repo with two PR-style merges, a tag between them, and
# owner-free merge titles — identical to release_notes.bats's own
# fixture, since parity is proven over the same history that suite
# already watched being born.
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

# Runs the bash script and the binary subcommand over the same
# arguments, capturing stdout, stderr and exit code from each into
# BATS_TEST_TMPDIR so a @test body can diff and compare without ever
# reading BATS_FILE_TMPDIR itself.
run_pair() {
  bash_status=0
  "$ROUTINE_REPO_ROOT/bin/routine-release-notes" "$@" \
    > "$BATS_TEST_TMPDIR/bash.out" 2> "$BATS_TEST_TMPDIR/bash.err" || bash_status=$?
  go_status=0
  "$routine_bin" release-notes "$@" \
    > "$BATS_TEST_TMPDIR/go.out" 2> "$BATS_TEST_TMPDIR/go.err" || go_status=$?
}

@test "the parity binary itself builds before any comparison runs" {
  [ "$build_status" -eq 0 ]
}

@test "merge subject bullets match the bash release notes byte for byte" {
  make_history
  run_pair v0.2.0 "$repo"
  [ "$bash_status" -eq 0 ]
  [ "$go_status" -eq 0 ]
  diff "$BATS_TEST_TMPDIR/bash.out" "$BATS_TEST_TMPDIR/go.out"
}

@test "previous tag exclusion matches across both implementations" {
  make_history
  run_pair v0.2.0 "$repo"
  [ "$bash_status" -eq 0 ]
  [ "$go_status" -eq 0 ]
  diff "$BATS_TEST_TMPDIR/bash.out" "$BATS_TEST_TMPDIR/go.out"
  ! grep -q "add-x" "$BATS_TEST_TMPDIR/go.out"
}

@test "first release history parity covers all commits" {
  make_history
  git -C "$repo" tag -d v0.1.0 > /dev/null
  run_pair v0.1.0 "$repo"
  [ "$bash_status" -eq 0 ]
  [ "$go_status" -eq 0 ]
  diff "$BATS_TEST_TMPDIR/bash.out" "$BATS_TEST_TMPDIR/go.out"
  grep -q "add-x" "$BATS_TEST_TMPDIR/go.out"
  grep -q "add-y" "$BATS_TEST_TMPDIR/go.out"
}

@test "existing tag range parity holds for previous tag to tag" {
  make_history
  git -C "$repo" tag v0.2.0
  git -C "$repo" -c user.name=t -c user.email=t@example.invalid \
    commit -q --allow-empty -m "post-release commit"
  run_pair v0.2.0 "$repo"
  [ "$bash_status" -eq 0 ]
  [ "$go_status" -eq 0 ]
  diff "$BATS_TEST_TMPDIR/bash.out" "$BATS_TEST_TMPDIR/go.out"
}

@test "owner free output parity holds across both implementations" {
  make_history
  run_pair v0.2.0 "$repo"
  [ "$bash_status" -eq 0 ]
  [ "$go_status" -eq 0 ]
  diff "$BATS_TEST_TMPDIR/bash.out" "$BATS_TEST_TMPDIR/go.out"
  ! grep -q "@" "$BATS_TEST_TMPDIR/go.out"
}

@test "malformed tag usage exits two in both implementations" {
  make_history
  run_pair not-a-tag "$repo"
  [ "$bash_status" -eq 2 ]
  [ "$go_status" -eq 2 ]
  diff "$BATS_TEST_TMPDIR/bash.out" "$BATS_TEST_TMPDIR/go.out"
  diff "$BATS_TEST_TMPDIR/bash.err" "$BATS_TEST_TMPDIR/go.err"
}
