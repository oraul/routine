#!/usr/bin/env bats

load test_helper

WF=".github/workflows/release.yml"

@test "release workflow triggers on dispatch and release/v* pushes only" {
  [ -f "$ROUTINE_REPO_ROOT/$WF" ]
  grep -q 'workflow_dispatch' "$ROUTINE_REPO_ROOT/$WF"
  grep -q 'tag:' "$ROUTINE_REPO_ROOT/$WF"
  grep -q "release/v\*" "$ROUTINE_REPO_ROOT/$WF"
  # The push trigger names only release/v* — no bare or main branches.
  ! grep -A2 'branches:' "$ROUTINE_REPO_ROOT/$WF" | grep -qE 'main|master|\*\*'
}

@test "release workflow runs the gate before any publish step" {
  gate_line="$(grep -n 'routine-release-check' "$ROUTINE_REPO_ROOT/$WF" | head -1 | cut -d: -f1)"
  publish_line="$(grep -n 'gh release create' "$ROUTINE_REPO_ROOT/$WF" | head -1 | cut -d: -f1)"
  [ -n "$gate_line" ]
  [ -n "$publish_line" ]
  [ "$gate_line" -lt "$publish_line" ]
}

@test "release workflow scripts the notes and edits an existing release" {
  notes_line="$(grep -n 'routine-release-notes' "$ROUTINE_REPO_ROOT/$WF" | head -1 | cut -d: -f1)"
  publish_line="$(grep -n 'gh release create' "$ROUTINE_REPO_ROOT/$WF" | head -1 | cut -d: -f1)"
  [ -n "$notes_line" ]
  [ "$notes_line" -lt "$publish_line" ]
  grep -q 'gh release edit' "$ROUTINE_REPO_ROOT/$WF"
  ! grep -q 'generate-notes' "$ROUTINE_REPO_ROOT/$WF"
  grep -q 'fetch-depth: 0' "$ROUTINE_REPO_ROOT/$WF"
}

@test "release workflow gates main, not the trigger branch" {
  grep -q 'ref: main' "$ROUTINE_REPO_ROOT/$WF"
}

@test "release workflow grants only contents write" {
  grep -q 'contents: write' "$ROUTINE_REPO_ROOT/$WF"
  ! grep -qE 'permissions:.*(admin|packages|id-token)' "$ROUTINE_REPO_ROOT/$WF"
}
