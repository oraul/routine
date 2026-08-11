#!/usr/bin/env bats

load test_helper

@test "plugin manifest exists and is minimal" {
  [ -f "$ROUTINE_REPO_ROOT/.claude-plugin/plugin.json" ]
  grep -q '"name"' "$ROUTINE_REPO_ROOT/.claude-plugin/plugin.json"
  grep -q '"description"' "$ROUTINE_REPO_ROOT/.claude-plugin/plugin.json"
  grep -q '"version"' "$ROUTINE_REPO_ROOT/.claude-plugin/plugin.json"
}

@test "gitignore is the single entry runs/" {
  [ "$(cat "$ROUTINE_REPO_ROOT/.gitignore")" = "runs/" ]
}

@test "bin and lib directories exist" {
  [ -d "$ROUTINE_REPO_ROOT/bin" ]
  [ -d "$ROUTINE_REPO_ROOT/lib" ]
}
