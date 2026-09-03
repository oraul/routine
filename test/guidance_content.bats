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

@test "the contract separates measured claims from unlabelled predictions" {
  doc="$ROUTINE_REPO_ROOT/CLAUDE.md"
  grep -qi 'measured' "$doc"
  grep -qi 'prediction' "$doc"
  grep -qi 'settles' "$doc"
}

# The motto pins word-bound 'kill': the bare substring already matches
# 'skills' in project.md, so an unbounded grep would be green on the
# un-edited file — a fake red, found by attacking the pin before
# trusting it.
@test "the contract carries the lifecycle motto" {
  doc="$ROUTINE_REPO_ROOT/CLAUDE.md"
  grep -qiw 'kill' "$doc"
  grep -qi 'survives' "$doc"
  grep -qi 'knowledge' "$doc"
}

@test "the conventions carry the motto beside the laws" {
  doc="$ROUTINE_REPO_ROOT/openspec/project.md"
  grep -qiw 'kill' "$doc"
  grep -qi 'survives' "$doc"
  grep -qi 'knowledge' "$doc"
}

@test "the conventions name the seven grounding pillars" {
  doc="$ROUTINE_REPO_ROOT/openspec/project.md"
  grep -qi 'provenance' "$doc"
  grep -qi 'refutation' "$doc"
  grep -qi 'independent instruments' "$doc"
  grep -qi 'freshness' "$doc"
  grep -qi 'symmetric' "$doc"
  grep -qi 'confound' "$doc"
  grep -qi 'exercised roads' "$doc"
}

@test "a pillar is vocabulary and never a gate" {
  doc="$ROUTINE_REPO_ROOT/openspec/project.md"
  grep -qi 'never a gate' "$doc"
  grep -qi 'earned separately' "$doc"
}

@test "the public face distinguishes the scout from the two agents" {
  doc="$ROUTINE_REPO_ROOT/README.md"
  grep -qi 'scout' "$doc"
  grep -qi 'read-only' "$doc"
}

@test "the public face opens with a model, not an install" {
  doc="$ROUTINE_REPO_ROOT/README.md"
  [ -f "$doc" ]
  head -20 "$doc" | grep -qi 'model'
  head -20 "$doc" | grep -qvi 'plugin install'
}

@test "the concept pipeline names who decides and what stops the run" {
  doc="$ROUTINE_REPO_ROOT/README.md"
  [ -f "$doc" ]
  grep -qi 'concept pipeline' "$doc"
  grep -qi 'decides' "$doc"
  grep -qi 'stops the run' "$doc"
}

@test "the public face separates transfer from accident" {
  doc="$ROUTINE_REPO_ROOT/README.md"
  [ -f "$doc" ]
  grep -qi 'carries into' "$doc"
  grep -qi 'accident' "$doc"
}

# --- amend-the-runtime-law: the boundary is the invariant, not bash ---

@test "the boundary binds the executable, not the language" {
  doc="$ROUTINE_REPO_ROOT/openspec/project.md"
  grep -q 'deterministic executable' "$doc"
  ! grep -q 'Bash-only runtime' "$doc"
}

@test "the runtime law states the seam and its destination" {
  doc="$ROUTINE_REPO_ROOT/openspec/project.md"
  grep -qi 'scripted seams' "$doc"
  grep -qi 'zero-setup' "$doc"
  grep -qi 'statically linked' "$doc"
  grep -qi 'commit provenance' "$doc"
  grep -qi 'either side of the seam' "$doc"
}

@test "the destination is built locally and the setup claim is narrowed" {
  doc="$ROUTINE_REPO_ROOT/openspec/project.md"
  grep -q 'built locally from the checkout' "$doc"
  grep -q 'beyond the Go toolchain' "$doc"
  # The old destination is gone, while the seam sentence above proves
  # the law still stands around it.
  ! grep -q 'cross-compiled per release' "$doc"
}

# --- amend-the-seam-boundary: a file's side is location, not language ---

@test "a file's side of the seam is decided by where it lives" {
  doc="$ROUTINE_REPO_ROOT/openspec/project.md"
  grep -q 'is core and destined for the binary' "$doc"
  grep -q 'seam is exactly' "$doc"
  grep -qi 'app hooks' "$doc"
  grep -qi 'caffeine sidecars' "$doc"
}

@test "bash written today is not itself a seam claim" {
  doc="$ROUTINE_REPO_ROOT/openspec/project.md"
  grep -q 'records how far the migration has got' "$doc"
  grep -q 'never a claim about which side of the seam it sits on' "$doc"
}

# --- the dispatch command ---

@test "the dispatch skill declares its name and invocation gate" {
  doc="$ROUTINE_REPO_ROOT/.claude/skills/rdev-dispatch/SKILL.md"
  [ -f "$doc" ]
  grep -q '^name: rdev-dispatch' "$doc"
  grep -q '^disable-model-invocation: true' "$doc"
}

@test "the dispatch skill carries the payload block verbatim" {
  doc="$ROUTINE_REPO_ROOT/.claude/skills/rdev-dispatch/SKILL.md"
  grep -q '^Change: <' "$doc"
  grep -q '^Scope: <' "$doc"
  line="$(grep '^Boundary:' "$doc")"
  [[ "$line" == *commit* ]]
  [[ "$line" == *checkbox* ]]
  [[ "$line" == *git* ]]
}

@test "the dispatch skill restores scope files before trusting green" {
  doc="$ROUTINE_REPO_ROOT/.claude/skills/rdev-dispatch/SKILL.md"
  grep -q 'git show HEAD:' "$doc"
  grep -qi 'red' "$doc"
}

@test "the dispatch skill orders convention check after the commit" {
  doc="$ROUTINE_REPO_ROOT/.claude/skills/rdev-dispatch/SKILL.md"
  grep -q 'convention-check' "$doc"
  grep -qi 'after' "$doc"
}

@test "the dispatch skill forbids a force push" {
  doc="$ROUTINE_REPO_ROOT/.claude/skills/rdev-dispatch/SKILL.md"
  grep -qi 'force-push' "$doc"
}
