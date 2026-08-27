#!/usr/bin/env bats

load test_helper

checker="bin/routine-change-check"

# Fixture: a routine root holding a live spec plus several change
# directories, each exercising one branch of the carry check. widgets is
# the one capability every change's delta targets.
make_fixture() {
  fixture="$BATS_TEST_TMPDIR/fixture"
  mkdir -p "$fixture/openspec/specs/widgets" \
    "$fixture/openspec/changes/complete-carry/specs/widgets" \
    "$fixture/openspec/changes/dropped-line/specs/widgets" \
    "$fixture/openspec/changes/absent-requirement/specs/widgets" \
    "$fixture/openspec/changes/added-only/specs/widgets" \
    "$fixture/openspec/changes/no-deltas" \
    "$fixture/openspec/changes/declared-removal/specs/widgets" \
    "$fixture/openspec/changes/mixed-removal/specs/widgets" \
    "$fixture/openspec/changes/superfluous-declaration/specs/widgets" \
    "$fixture/runs/app"

  printf '%s\n' \
    '# widgets Specification' \
    '' \
    '## Purpose' \
    '' \
    'Widgets.' \
    '' \
    '## Requirements' \
    '' \
    '### Requirement: Widgets spin' \
    'Widgets SHALL spin when powered.' \
    'Widgets SHALL stop within one second of power loss.' \
    '' \
    '#### Scenario: Power loss' \
    '- **WHEN** power is cut' \
    '- **THEN** the widget stops within one second' \
    > "$fixture/openspec/specs/widgets/spec.md"

  printf '%s\n' \
    '# widgets Specification (delta)' \
    '' \
    '## MODIFIED Requirements' \
    '' \
    '### Requirement: Widgets spin' \
    'Widgets SHALL spin when powered.' \
    'Widgets SHALL stop within one second of power loss. Braking never voids this.' \
    '' \
    '#### Scenario: Power loss' \
    '- **WHEN** power is cut' \
    '- **THEN** the widget stops within one second' \
    '' \
    '#### Scenario: Braking' \
    '- **WHEN** the brake is engaged' \
    '- **THEN** it holds' \
    > "$fixture/openspec/changes/complete-carry/specs/widgets/spec.md"

  printf '%s\n' \
    '# widgets Specification (delta)' \
    '' \
    '## MODIFIED Requirements' \
    '' \
    '### Requirement: Widgets spin' \
    'Widgets SHALL spin when powered.' \
    '' \
    '#### Scenario: Power loss' \
    '- **WHEN** power is cut' \
    '- **THEN** the widget stops within one second' \
    > "$fixture/openspec/changes/dropped-line/specs/widgets/spec.md"

  printf '%s\n' \
    '# widgets Specification (delta)' \
    '' \
    '## MODIFIED Requirements' \
    '' \
    '### Requirement: Widgets teleport' \
    'Widgets SHALL teleport instantly.' \
    > "$fixture/openspec/changes/absent-requirement/specs/widgets/spec.md"

  printf '%s\n' \
    '# widgets Specification (delta)' \
    '' \
    '## ADDED Requirements' \
    '' \
    '### Requirement: Widgets glow' \
    'Widgets SHALL glow softly.' \
    > "$fixture/openspec/changes/added-only/specs/widgets/spec.md"

  printf '%s\n' \
    '# widgets Specification (delta)' \
    '' \
    '## MODIFIED Requirements' \
    '' \
    '### Requirement: Widgets spin' \
    'Widgets SHALL spin when powered.' \
    '' \
    '#### Scenario: Power loss' \
    '- **WHEN** power is cut' \
    '- **THEN** the widget stops within one second' \
    '' \
    '## Removed Lines' \
    '' \
    '- Widgets SHALL stop within one second of power loss.' \
    > "$fixture/openspec/changes/declared-removal/specs/widgets/spec.md"

  printf '%s\n' \
    '# widgets Specification (delta)' \
    '' \
    '## MODIFIED Requirements' \
    '' \
    '### Requirement: Widgets spin' \
    '' \
    '#### Scenario: Power loss' \
    '- **WHEN** power is cut' \
    '- **THEN** the widget stops within one second' \
    '' \
    '## Removed Lines' \
    '' \
    '- Widgets SHALL spin when powered.' \
    > "$fixture/openspec/changes/mixed-removal/specs/widgets/spec.md"

  printf '%s\n' \
    '# widgets Specification (delta)' \
    '' \
    '## MODIFIED Requirements' \
    '' \
    '### Requirement: Widgets spin' \
    'Widgets SHALL spin when powered.' \
    'Widgets SHALL stop within one second of power loss.' \
    '' \
    '#### Scenario: Power loss' \
    '- **WHEN** power is cut' \
    '- **THEN** the widget stops within one second' \
    '' \
    '## Removed Lines' \
    '' \
    '- Widgets SHALL spin when powered.' \
    > "$fixture/openspec/changes/superfluous-declaration/specs/widgets/spec.md"
}

@test "a complete carry with an extended line passes" {
  make_fixture
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/$checker" complete-carry
  [ "$status" -eq 0 ]
}

@test "a dropped requirement line fails naming capability and requirement" {
  make_fixture
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/$checker" dropped-line
  [ "$status" -eq 1 ]
  printf '%s\n' "$output" | grep -q 'widgets'
  printf '%s\n' "$output" | grep -q 'Widgets spin'
  printf '%s\n' "$output" \
    | grep -qF 'Widgets SHALL stop within one second of power loss.'
}

@test "modifying a requirement absent from the live spec fails naming it" {
  make_fixture
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/$checker" \
    absent-requirement
  [ "$status" -eq 1 ]
  printf '%s\n' "$output" | grep -q 'Widgets teleport'
}

@test "an added-only delta carries nothing and passes" {
  make_fixture
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/$checker" added-only
  [ "$status" -eq 0 ]
}

@test "a declared removal exempts the dropped line" {
  make_fixture
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/$checker" \
    declared-removal
  [ "$status" -eq 0 ]
}

@test "an undeclared loss fails naming only the undeclared line" {
  make_fixture
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/$checker" \
    mixed-removal
  [ "$status" -eq 1 ]
  printf '%s\n' "$output" \
    | grep -qF 'Widgets SHALL stop within one second of power loss.'
  ! printf '%s\n' "$output" \
    | grep -qF 'lost line: Widgets SHALL spin when powered.'
}

@test "a superfluous declaration on a line still carried still passes" {
  make_fixture
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/$checker" \
    superfluous-declaration
  [ "$status" -eq 0 ]
}

@test "a change with no specs deltas passes untouched" {
  make_fixture
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/$checker" no-deltas
  [ "$status" -eq 0 ]
}

@test "no change id argument is a usage error" {
  make_fixture
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/$checker"
  [ "$status" -eq 2 ]
  printf '%s\n' "$output" | grep -q 'usage'
}

@test "an unknown change id is a usage error" {
  make_fixture
  run env ROUTINE_ROOT="$fixture" "$ROUTINE_REPO_ROOT/$checker" nope-not-real
  [ "$status" -eq 2 ]
  printf '%s\n' "$output" | grep -q 'usage'
}

@test "a passing run records the harness.change telemetry event" {
  make_fixture
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt"
  git -C "$tgt" -c init.defaultBranch=main init -q
  git -C "$tgt" -c user.name=t -c user.email=t@example.invalid \
    commit -q --allow-empty -m "root"
  run env ROUTINE_ROOT="$fixture" TARGET="$tgt" \
    "$ROUTINE_REPO_ROOT/$checker" complete-carry
  [ "$status" -eq 0 ]
  grep '"event":"harness.change"' "$fixture/runs/app/telemetry.jsonl" \
    | grep -q '"exit":0'
}
