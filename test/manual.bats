#!/usr/bin/env bats

load test_helper

@test "the catalog covers every bin script" {
  run "$ROUTINE_REPO_ROOT/bin/routine-manual"
  [ "$status" -eq 0 ]
  for f in "$ROUTINE_REPO_ROOT"/bin/*; do
    n="$(basename "$f")"
    case "$output" in *"$n"*) ;; *) echo "missing: $n"; false ;; esac
  done
}

@test "a contract is assembled from frontmatter, not curated" {
  run "$ROUTINE_REPO_ROOT/bin/routine-manual"
  [ "$status" -eq 0 ]
  # Facts that exist only in frontmatter lines must surface verbatim.
  case "$output" in *"routine-next <ticket-dir>"*) ;; *) false ;; esac
  case "$output" in *"a blocked task blocks the line"*) ;; *) false ;; esac
  case "$output" in *"test/task_line.bats"*) ;; *) false ;; esac
}

@test "a contractless script cannot hide" {
  mroot="$BATS_TEST_TMPDIR/mroot"
  mkdir -p "$mroot/bin"
  printf '%s\n' '#!/usr/bin/env bash' 'printf ok' > "$mroot/bin/naked"
  chmod +x "$mroot/bin/naked"
  run env ROUTINE_ROOT="$mroot" "$ROUTINE_REPO_ROOT/bin/routine-manual"
  [ "$status" -ne 0 ]
  case "$output" in *naked*) ;; *) false ;; esac
}
