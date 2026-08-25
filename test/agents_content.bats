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

@test "the analyst names a grader for every forecast it makes" {
  doc="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -qi 'forecast' "$doc"
  grep -qi 'grader' "$doc"
  grep -qi 'settles' "$doc"
}

@test "the analyst tries to refute its own decomposition" {
  doc="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -qi 'refute' "$doc"
  grep -qi 'support-gathering' "$doc"
}

@test "the analyst records inconvenient probes at full fidelity" {
  doc="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -qi 'inconvenient' "$doc"
  grep -qi 'fidelity' "$doc"
  grep -qi 'curated' "$doc"
}

@test "a probe quotes its command and output inside the evidence line" {
  doc="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -qi 'quotes' "$doc"
  grep -qi 'fenced' "$doc"
}

# grep -F on the filename pins: a regex dot is any-char and could
# bless a file the pin should redden — the #92 lesson.
@test "re-entry reads the operator's rulings when present" {
  doc="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -qF 'approve.md' "$doc"
  grep -qi 'binds' "$doc"
  grep -qi 'when present' "$doc"
  # Every recorded proceed writes the file now, so the old reading of
  # absence — "no remarks were recorded" — is a contract sentence that
  # outlived its mechanism.
  ! grep -q 'no remarks were recorded' "$doc"
}

@test "re-entry trust is a default, not a prohibition" {
  doc="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -qi 'sampled' "$doc"
  grep -qi 'spot-check' "$doc"
  grep -qi 'never counts' "$doc"
}

@test "the approve phase teaches the per-question answer form" {
  skill="$ROUTINE_REPO_ROOT/skills/routine/SKILL.md"
  awk '/^## 3\./,/^## 4\./' "$skill" | grep -qF '<n>: <answer>'
  awk '/^## 3\./,/^## 4\./' "$skill" | grep -qF 'Approved-at'
}

@test "a causal claim names its confound or drops the cause" {
  doc="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -qi 'confound' "$doc"
  grep -qi 'variable' "$doc"
}

@test "the revise payload hands over the operator's rulings" {
  skill="$ROUTINE_REPO_ROOT/skills/routine/SKILL.md"
  awk '/^## 2\./,/^## 3\./' "$skill" | grep -qF 'approve.md'
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

@test "the contracts name the characterization heading" {
  ana="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -q '## Characterization:' "$ana"
  grep -qi 'developer gate' "$ana"
  dev="$ROUTINE_REPO_ROOT/agents/developer.md"
  grep -q '## Characterization:' "$dev"
  grep -q 'routine-tdd red' "$dev"
}

# Cross-contract: both files describe the same phase, so they must not
# describe it two different ways. The developer's contract already says
# the birth claim "gets proven"; the analyst's contract must name the
# evidence that proves it, rather than denying any evidence exists.
@test "the agent contracts agree on what characterize records" {
  dev="$ROUTINE_REPO_ROOT/agents/developer.md"
  ana="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -qi 'gets proven' "$dev"
  grep -q '## Characterization:' "$ana"
  grep -Fq 'tdd.characterize' "$ana"
  ! grep -q 'records no TDD' "$ana"
}

@test "the developer's closed list admits its own briefing" {
  dev="$ROUTINE_REPO_ROOT/agents/developer.md"
  grep -q 'briefing.md' "$dev"
  grep -q 'conventions in force' "$dev"
  grep -qi 'never another slice' "$dev"
}

@test "the briefing's conventions rank with the target's own" {
  dev="$ROUTINE_REPO_ROOT/agents/developer.md"
  grep -q 'sit with' "$dev"
}

@test "the analyst's briefing carries the conventions in force" {
  ana="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -q 'briefing.md' "$ana"
  grep -q 'conventions in force' "$ana"
}

@test "both delegation steps carry a literal payload template" {
  skill="$ROUTINE_REPO_ROOT/skills/routine/SKILL.md"
  awk '/^## 2\./,/^## 3\./' "$skill" | grep -q '```'
  awk '/^## 4\./,/^## 5\./' "$skill" | grep -q '```'
}

@test "the develop payload template names the task briefing" {
  skill="$ROUTINE_REPO_ROOT/skills/routine/SKILL.md"
  awk '/^## 4\./,/^## 5\./' "$skill" | awk '/^```$/{f=!f; next} f' | grep -q 'briefing.md'
}

@test "the specify revise payload template names the lint log" {
  skill="$ROUTINE_REPO_ROOT/skills/routine/SKILL.md"
  awk '/^## 2\./,/^## 3\./' "$skill" | awk '/^```$/{f=!f; next} f' | grep -q 'lint.log'
}

@test "a red characterization returns to specify as a defect" {
  dev="$ROUTINE_REPO_ROOT/agents/developer.md"
  grep -q 'characterize' "$dev"
  grep -qi 'implemented' "$dev"
}

@test "the analyst and skill point at the captured failure log" {
  ana="$ROUTINE_REPO_ROOT/agents/analyst.md"
  skill="$ROUTINE_REPO_ROOT/skills/routine/SKILL.md"
  grep -q 'characterize.log' "$ana"
  grep -q 'characterize.log' "$skill"
}

@test "the developer narrows scope and names a stolen red" {
  dev="$ROUTINE_REPO_ROOT/agents/developer.md"
  grep -qi 'narrowest' "$dev"
  grep -qi 'stolen' "$dev"
}

@test "a redoing developer may read why its task came back" {
  dev="$ROUTINE_REPO_ROOT/agents/developer.md"
  grep -qi 'merely' "$dev"
}

@test "the re-served rule separates interruption from defect return" {
  dev="$ROUTINE_REPO_ROOT/agents/developer.md"
  grep -qi 'interruption' "$dev"
  grep -qi 'amended' "$dev"
}

@test "the patch account lands in the returned task itself" {
  ana="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -qi 'account' "$ana"
  grep -qi ' itself' "$ana"
}

@test "a question is separated from a derivation by its own heading" {
  ana="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -q '## Questions' "$ana"
  grep -qi 'operator can answer' "$ana"
  grep -q '## Assumptions' "$ana"
}

@test "each question carries the provisional reading it was decomposed against" {
  ana="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -qi 'provisional' "$ana"
  grep -qi 'operator may override' "$ana"
  grep -q -- '- none — <why nothing qualifies>' "$ana"
}

@test "approve shows the questions beside the requirement and briefings" {
  skill="$ROUTINE_REPO_ROOT/skills/routine/SKILL.md"
  awk '/^## 3\./,/^## 4\./' "$skill" | grep -q '## Questions'
  awk '/^## 3\./,/^## 4\./' "$skill" | grep -qi 'operator'
}

@test "the specify payload template carries what the operator cares about" {
  skill="$ROUTINE_REPO_ROOT/skills/routine/SKILL.md"
  awk '/^## 2\./,/^## 3\./' "$skill" | awk '/^```$/{f=!f; next} f' | grep -qi 'context'
  awk '/^## 2\./,/^## 3\./' "$skill" | grep -qi 'operator cares about'
}

@test "a baked ruling carries the marker the gate reads" {
  doc="$ROUTINE_REPO_ROOT/agents/analyst.md"
  grep -qF 'RULED at approve (approve.md A' "$doc"
  grep -qi 'the standing reading' "$doc"
  grep -qi 'kept in place' "$doc"
}
