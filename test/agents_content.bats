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

@test "the agents register as subagents" {
  for name in analyst developer; do
    doc="$ROUTINE_REPO_ROOT/agents/$name.md"
    [ "$(head -1 "$doc")" = "---" ] || { echo "no frontmatter: $doc"; false; }
    grep -q "^name: $name\$" "$doc" || { echo "name mismatch: $doc"; false; }
    grep -qE '^description: .+' "$doc" || { echo "no description: $doc"; false; }
  done
}

@test "the analyst counts revises the gate's way and never invents vocabulary" {
  doc="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -q '/caffeinate' "$doc"
  grep -qi 'episode' "$doc"
  ! grep -q 'a bug additionally requires' "$doc"
}

@test "the analyst emits labels and never an empty manifest" {
  doc="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -q '## Scenario:' "$doc"
  grep -q 'testing/tdd' "$doc"
  ! grep -q 'Empty beneath the heading' "$doc"
}

@test "the developer records evidence under the task's labels" {
  doc="$ROUTINE_REPO_ROOT/agents/developer.md"
  grep -q '## Scenario:' "$doc"
  grep -qi 'verbatim' "$doc"
}

@test "the unblock skill matches its script's signature" {
  doc="$ROUTINE_REPO_ROOT/skills/unblock/SKILL.md"
  grep -q '<ticket-dir> \[task-id\]' "$doc"
}

@test "the caffeinate skill teaches the enforced generation contract" {
  doc="$ROUTINE_REPO_ROOT/skills/caffeinate/SKILL.md"
  grep -q 'caffeine-mode' "$doc"
  grep -q 'lib/sidecar.sh' "$doc"
  grep -q 'routine-caffeine-lint' "$doc"
  grep -q 'test/caffeine_<ns>_<topic>.bats' "$doc"
  grep -qi 'verbatim' "$doc"
  ! grep -q 'one bats fixture per rule' "$doc"
}

@test "the prompts consult the contract, never recall it" {
  grep -q 'routine-manual' "$ROUTINE_REPO_ROOT/skills/routine/SKILL.md"
  grep -q 'routine-manual' "$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -q 'routine-manual' "$ROUTINE_REPO_ROOT/agents/developer.md"
}

@test "the skill hands agents their payload and aborts by script" {
  doc="$ROUTINE_REPO_ROOT/skills/routine/SKILL.md"
  grep -q 'TARGET' "$doc"
  grep -q 'routine-abort' "$doc"
  grep -qi 'fresh ticket' "$doc"
  ! grep -q 'going back through the rails' "$doc"
}
