#!/usr/bin/env bats

load test_helper

# Builds the core binary exactly once for this whole file (never per
# test) into the bats-managed per-file tempdir, stamping the same
# provenance ldflags selfcheck will use. The commit and the binary path
# are handed to tests through plain files rather than exported through
# BATS_FILE_TMPDIR references inside @test bodies.
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
  printf '%s' "$built_commit" > "$BATS_FILE_TMPDIR/built_commit"
}

setup() {
  ROUTINE_REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export ROUTINE_REPO_ROOT
  routine_bin="$BATS_FILE_TMPDIR/routine"
  built_commit="$(cat "$BATS_FILE_TMPDIR/built_commit")"
  build_status="$(cat "$BATS_FILE_TMPDIR/build.status")"
}

@test "the build itself succeeds before any subcommand runs" {
  [ "$build_status" -eq 0 ]
}

@test "version prints a non-empty commit provenance" {
  run "$routine_bin" version
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  case "$output" in *unknown*) false ;; *) ;; esac
}

@test "version prints the exact commit the binary was built with" {
  run "$routine_bin" version
  [ "$status" -eq 0 ]
  case "$output" in *"$built_commit"*) ;; *) false ;; esac
}

@test "an unknown subcommand exits two and names usage on stderr" {
  run "$routine_bin" bogus-subcommand
  [ "$status" -eq 2 ]
  case "$output" in *usage*) ;; *) false ;; esac
}

@test "invoking with no arguments at all exits two naming usage" {
  run "$routine_bin"
  [ "$status" -eq 2 ]
  case "$output" in *usage*) ;; *) false ;; esac
}
