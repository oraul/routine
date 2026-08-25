#!/usr/bin/env bats

load test_helper

@test "plugin manifest exists and is minimal" {
  [ -f "$ROUTINE_REPO_ROOT/.claude-plugin/plugin.json" ]
  grep -q '"name"' "$ROUTINE_REPO_ROOT/.claude-plugin/plugin.json"
  grep -q '"description"' "$ROUTINE_REPO_ROOT/.claude-plugin/plugin.json"
  grep -q '"version"' "$ROUTINE_REPO_ROOT/.claude-plugin/plugin.json"
}

# runs/* rather than runs/: git cannot re-include a path whose parent
# directory is excluded, and the repo ships runs/routine/README.md so
# its own harness verdicts always have a destination.
@test "gitignore ignores runs and re-includes only the shipped marker" {
  [ "$(cat "$ROUTINE_REPO_ROOT/.gitignore")" = "runs/*
!runs/routine/
runs/routine/*
!runs/routine/README.md" ]
}

@test "bin and lib directories exist" {
  [ -d "$ROUTINE_REPO_ROOT/bin" ]
  [ -d "$ROUTINE_REPO_ROOT/lib" ]
}
