# Proposal — admit-characterization-scenarios

## Why

Proving run 0002 aborted on a hole no council predicted and only running
found. Task 01-01 pinned an unprotected seam with a characterization
test — the correct move, per the feature calibration — and then could
not be concluded:

- the spec grammar requires every task to carry a scenario label,
- the audit demands a covering `tdd.green` per label on a done task,
- and the agent contracts forbid routing a characterization test
  through `routine-tdd`, whose red phase would refuse it anyway — a
  red that isn't red.

Three rules, individually correct, jointly unsatisfiable. Every agent
followed its contract exactly and the run still had to abort. The full
reasoning is on the record at
`runs/shopapp/tickets/archive/0002/report.md` (aborted, violations
verbatim) — this is the first operationally earned change since the
loop was built.

## What Changes

- The ticket grammar gains a second heading form:
  `## Characterization: <label>`. A task needs at least one scenario of
  either kind; the lint enforces the same body grammar for both.
- The audit covers a characterization label through the task's passing
  developer gate — already required and task-attributed on the record —
  instead of through tdd evidence. A task whose labels are all
  characterization needs no `tdd.green` at all; a `## Scenario:` label
  keeps demanding its red-then-green pair, unchanged.
- The analyst contract emits `## Characterization:` for green-at-birth
  pins; the developer contract routes them to the ordinary suite and
  names the heading.

## Impact

- Affected specs: `spec-grammar`, `audit`, `operation`
- Affected code: `bin/routine-spec-lint`, `bin/routine-audit`,
  `agents/analyst.md`, `agents/developer.md`, and their suites
- The archived abort stays as it is — history is never retrofitted.
