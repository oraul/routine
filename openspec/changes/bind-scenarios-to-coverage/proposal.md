## Why

The audit proves red→green per *recorded string*, but nothing binds the
recorded strings to the task's actual scenarios: a developer can green
one easy scenario, skip the other three, and the run audits clean. The
task file's scenarios and the telemetry's evidence live in two
vocabularies with no join key. Separately, the grammar lets a manifest
be empty — yet `testing/tdd` applies to every task by definition, so an
empty manifest is never honest, only unconsidered.

## What Changes

- **Scenario labels enter the grammar**: every scenario in `task.md`
  lives under a `## Scenario: <label>` heading; `routine-spec-lint`
  rejects a task without one. The label is the join key.
- **The audit demands coverage, not existence**: for every labeled
  scenario in a done task's file there must be a passing `tdd.green`
  recorded under that label (hash-suffixed forms match), each still
  showing its earlier failing red — one pair per scenario, not per
  task.
- **Manifests must be non-empty**: the lint rejects a `## Caffeine`
  section with no topics — `testing/tdd` qualifies for any task, so
  "none apply" never does.
- **The agents speak the labels**: the analyst emits labeled scenarios
  and never an empty manifest; the developer records evidence under
  exactly the task's labels, verbatim.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `spec-grammar`: labeled scenarios and non-empty manifests join the
  lint's structural checks.
- `audit`: the per-task tdd check becomes per-labeled-scenario.
- `operation`: analyst and developer contracts carry the label
  discipline.

## Impact

- Modified: `bin/routine-spec-lint`, `bin/routine-audit`,
  `agents/analyst.md`, `agents/developer.md`, and the fixtures in
  `test/{spec_lint,gate,audit,conclude}.bats`;
  `test/agents_content.bats` gains pins.
