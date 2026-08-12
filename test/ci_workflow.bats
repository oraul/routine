#!/usr/bin/env bats

load test_helper

WF=".github/workflows/ci.yml"

@test "the conventions job is not gated to pull requests" {
  [ -f "$ROUTINE_REPO_ROOT/$WF" ]
  # The event gate that skipped every push to main is gone.
  ! grep -q "if: github.event_name == 'pull_request'" "$ROUTINE_REPO_ROOT/$WF"
}

@test "the conventions job resolves a base per event" {
  # PR events diff against the base ref; pushes against the pre-push tip.
  grep -q 'github.base_ref' "$ROUTINE_REPO_ROOT/$WF"
  grep -q 'github.event.before' "$ROUTINE_REPO_ROOT/$WF"
}

@test "the push base has a fallback for zero or unreachable tips" {
  # First push and force push must not break the job or rescan history.
  grep -qE 'HEAD~1' "$ROUTINE_REPO_ROOT/$WF"
  grep -qE '\^0\+\$|0{40}' "$ROUTINE_REPO_ROOT/$WF"
}

@test "the conventions job still runs the checker over full history depth" {
  job="$(awk '/^  conventions:/ {f=1; print; next} /^  [a-z-]+:/ {f=0} f' \
    "$ROUTINE_REPO_ROOT/$WF")"
  printf '%s\n' "$job" | grep -q 'fetch-depth: 0'
  printf '%s\n' "$job" | grep -q 'routine-convention-check'
}
