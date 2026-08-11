#!/usr/bin/env bats

load test_helper

@test "ROUTINE_ROOT wins when set" {
  run bash -c "ROUTINE_ROOT=/fixture CLAUDE_PLUGIN_ROOT=/plugin; export ROUTINE_ROOT CLAUDE_PLUGIN_ROOT; . '$ROUTINE_REPO_ROOT/lib/paths.sh' && routine_root"
  [ "$status" -eq 0 ]
  [ "$output" = "/fixture" ]
}

@test "CLAUDE_PLUGIN_ROOT is the default when ROUTINE_ROOT is unset" {
  run bash -c "unset ROUTINE_ROOT; CLAUDE_PLUGIN_ROOT=/plugin; export CLAUDE_PLUGIN_ROOT; . '$ROUTINE_REPO_ROOT/lib/paths.sh' && routine_root"
  [ "$status" -eq 0 ]
  [ "$output" = "/plugin" ]
}

@test "falls back to the repo containing lib/" {
  run bash -c "unset ROUTINE_ROOT CLAUDE_PLUGIN_ROOT; . '$ROUTINE_REPO_ROOT/lib/paths.sh' && routine_root"
  [ "$status" -eq 0 ]
  [ "$output" = "$ROUTINE_REPO_ROOT" ]
}
