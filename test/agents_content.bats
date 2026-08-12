#!/usr/bin/env bats

load test_helper

# Contract truth pinned the mechanical way, the caffeine_content.bats
# convention: load-bearing terms of art present, council-verified-wrong
# claims absent. Never sentences.

@test "the developer's closed list admits what the scripts demand" {
  doc="$ROUTINE_REPO_ROOT/agents/developer.md"
  grep -q 'ROUTINE_TICKET_DIR' "$doc"
  grep -q 'TARGET' "$doc"
  grep -q 'Touchpoints' "$doc"
}

@test "the developer orders its sources and binds red to green" {
  doc="$ROUTINE_REPO_ROOT/agents/developer.md"
  grep -qi 'precedence' "$doc"
  grep -qi 'identical' "$doc"
  grep -qi 'characterization' "$doc"
}

@test "the developer gate loop has a floor and the Never list is grown" {
  doc="$ROUTINE_REPO_ROOT/agents/developer.md"
  grep -q 'runs/<app>/hooks' "$doc"
  grep -q 'routine-done' "$doc"
  ! grep -q 'keep working until it is green' "$doc"
}
