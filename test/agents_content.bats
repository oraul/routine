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
  for name in analyst developer scout; do
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

@test "scout output is evidence or nothing" {
  doc="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -qi 'scout' "$doc"
  grep -qi 'transcript' "$doc"
  grep -q 'ROUTINE_TICKET_DIR' "$doc"
}

@test "re-entry is anchor-first, not re-search-first" {
  doc="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -q 'Grounded-at' "$doc"
  grep -q 'rev-parse HEAD' "$doc"
  grep -q 'status --porcelain' "$doc"
  grep -q 'diff --name-only' "$doc"
}

@test "the analyst grounds with claims, ruled-outs, and floors" {
  doc="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -q 'contain or do' "$doc"
  grep -q 'ruled out:' "$doc"
  grep -q -- '- none —' "$doc"
  ! grep -q 'why it matters' "$doc"
}

@test "recovery reads lint.log instead of re-running the gate" {
  grep -q 'lint.log' "$ROUTINE_REPO_ROOT/skills/routine/SKILL.md"
  grep -q 'lint.log' "$ROUTINE_REPO_ROOT/agents/analyst.md"
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

@test "phase 0 resolves state by script, not by inference" {
  doc="$ROUTINE_REPO_ROOT/skills/routine/SKILL.md"
  grep -q 'routine-health' "$doc"
  grep -qi 'exit code' "$doc"
  ! grep -q 'If no active ticket exists' "$doc"
}

@test "crash re-entry is written down, not left to code archaeology" {
  skill="$ROUTINE_REPO_ROOT/skills/routine/SKILL.md"
  grep -qi 're-serves' "$skill"
  grep -qi 'dirty' "$skill"
  dev="$ROUTINE_REPO_ROOT/agents/developer.md"
  grep -qi 're-served' "$dev"
}

@test "the partial-work triage sits on the resume road, not preflight" {
  skill="$ROUTINE_REPO_ROOT/skills/routine/SKILL.md"
  awk '/^## 4\./,/^## 5\./' "$skill" | grep -qi 'uncommitted'
  dev="$ROUTINE_REPO_ROOT/agents/developer.md"
  grep -qi 'uncommitted diff' "$dev"
}

# The tier is declared data, not an instruction anybody must remember.
# Routine checks only what it owns: the field is present and its value is
# one this repository recognises. No script here can observe which model
# actually answered — that assumption is recorded in the change's design.
@test "each agent declares a recognised model tier" {
  for name in analyst developer scout; do
    doc="$ROUTINE_REPO_ROOT/agents/$name.md"
    line="$(grep -m1 '^model:' "$doc")" || { echo "no model tier: $doc"; false; }
    case "$line" in
      "model: inherit"|"model: opus"|"model: sonnet"|"model: haiku") ;;
      *) echo "unrecognised tier in $doc: $line"; false ;;
    esac
  done
}

@test "no skill declares a model for the driving session" {
  # The driver is the human's own session: routine can neither enforce nor
  # verify a tier there, so it declares none.
  [ -n "$(ls "$ROUTINE_REPO_ROOT"/skills/*/SKILL.md 2>/dev/null)" ]
  ! grep -rq '^model:' "$ROUTINE_REPO_ROOT"/skills/*/SKILL.md
}

@test "liveness is read from state, never timed out" {
  doc="$ROUTINE_REPO_ROOT/skills/routine/SKILL.md"
  grep -qi 'returns or' "$doc"
  grep -qi 'never a timeout' "$doc"
  grep -q 'routine-health' "$doc"
}

# The scout is the mechanical tier: one read-only survey per invocation,
# graded only by whether its caller could then do its job. Routine pins
# what it owns — the file registers, declares the cheapest tier, and
# forbids every write it could otherwise reach for.
@test "the scout registers at the cheapest tier" {
  doc="$ROUTINE_REPO_ROOT/agents/scout.md"
  [ "$(head -1 "$doc")" = "---" ] || { echo "no frontmatter: $doc"; false; }
  grep -q '^name: scout$' "$doc"
  grep -qE '^description: .+' "$doc"
  grep -q '^model: haiku$' "$doc"
}

@test "the scout writes nothing" {
  doc="$ROUTINE_REPO_ROOT/agents/scout.md"
  grep -qi 'read-only' "$doc"
  grep -qi 'never load-bearing' "$doc"
  grep -q 'routine-tdd' "$doc"
  grep -q 'telemetry.jsonl' "$doc"
}

@test "the callers name the scout and keep the record for themselves" {
  dev="$ROUTINE_REPO_ROOT/agents/developer.md"
  grep -q 'agents/scout.md' "$dev"
  grep -qi 'never delegate' "$dev"
  grep -qi 'permissive' "$dev"
  ana="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -q 'agents/scout.md' "$ana"
}
