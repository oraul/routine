#!/usr/bin/env bats

load test_helper

WF=".github/workflows/release.yml"

@test "release workflow exists and is dispatch-only with a tag input" {
  [ -f "$ROUTINE_REPO_ROOT/$WF" ]
  grep -q 'workflow_dispatch' "$ROUTINE_REPO_ROOT/$WF"
  grep -q 'tag:' "$ROUTINE_REPO_ROOT/$WF"
  ! grep -qE '^on:.*push|^  push:' "$ROUTINE_REPO_ROOT/$WF"
}

@test "release workflow runs the gate before any publish step" {
  gate_line="$(grep -n 'routine-release-check' "$ROUTINE_REPO_ROOT/$WF" | head -1 | cut -d: -f1)"
  publish_line="$(grep -n 'gh release create' "$ROUTINE_REPO_ROOT/$WF" | head -1 | cut -d: -f1)"
  [ -n "$gate_line" ]
  [ -n "$publish_line" ]
  [ "$gate_line" -lt "$publish_line" ]
}

@test "release workflow grants only contents write" {
  grep -q 'contents: write' "$ROUTINE_REPO_ROOT/$WF"
  ! grep -qE 'permissions:.*(admin|packages|id-token)' "$ROUTINE_REPO_ROOT/$WF"
}
