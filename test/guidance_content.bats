#!/usr/bin/env bats

load test_helper

# The guidance capability was spec'd from define-claude-md onward and
# enforced by nothing. These pins close that: load-bearing terms, never
# sentences — line wrapping breaks sentence greps and this repository has
# paid for that twice.
#
# The pins below marked CHARACTERIZATION assert contract content that was
# already required and already present. They pass from birth, they belong
# in the ordinary suite, and they are NOT TDD evidence — never route them
# through `routine-tdd red`.

# --- CHARACTERIZATION: the contract as define-claude-md required it ---

@test "the contract states spec-first and the hard rules" {
  doc="$ROUTINE_REPO_ROOT/CLAUDE.md"
  grep -qi 'never vibe' "$doc"
  grep -q 'OpenSpec' "$doc"
  grep -qi 'session URLs' "$doc"
  grep -qi 'rotation' "$doc"
}

@test "the contract points at the Laws and the conventions" {
  doc="$ROUTINE_REPO_ROOT/CLAUDE.md"
  grep -q 'openspec/project.md' "$doc"
  grep -q 'CONTRIBUTING.md' "$doc"
}

@test "the contract names the commands that decide" {
  doc="$ROUTINE_REPO_ROOT/CLAUDE.md"
  grep -q 'bin/routine-selfcheck' "$doc"
  grep -q 'validate --all --strict' "$doc"
  grep -q 'bin/routine-release-check' "$doc"
}

@test "the contract states TDD and the untouchable state" {
  doc="$ROUTINE_REPO_ROOT/CLAUDE.md"
  grep -q 'index.tsv' "$doc"
  grep -q 'telemetry.jsonl' "$doc"
  grep -q 'tasks.md' "$doc"
}

@test "the public face carries the loop, the skills, and the map" {
  doc="$ROUTINE_REPO_ROOT/README.md"
  grep -q '/routine' "$doc"
  grep -q '/unblock' "$doc"
  grep -q '/caffeinate' "$doc"
  grep -q 'openspec/specs' "$doc"
  grep -q 'bin/routine-selfcheck' "$doc"
}

# --- TDD: the delegation model, which the contract did not state ---

@test "the contract states the delegation model" {
  doc="$ROUTINE_REPO_ROOT/CLAUDE.md"
  grep -q 'agents/scout.md' "$doc"
  grep -qi 'who grades' "$doc"
  grep -q 'model:' "$doc"
}

@test "the contract forbids delegating the record" {
  doc="$ROUTINE_REPO_ROOT/CLAUDE.md"
  grep -qi 'never delegated' "$doc"
  grep -q 'routine-tdd' "$doc"
}

@test "the contract admits what routine cannot check" {
  doc="$ROUTINE_REPO_ROOT/CLAUDE.md"
  grep -qi 'which model answered' "$doc"
}
