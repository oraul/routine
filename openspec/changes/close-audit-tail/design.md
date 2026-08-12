## Context

The telemetry law (scripts never invent a destination) is why the three
harness scripts stayed silent: they run at repo level with no ticket
context. `routine-deps` already solved this shape — emit app-level when
`runs/<app>` exists, no-op otherwise.

## Goals / Non-Goals

- **Goals**: no silent scripts left; the audit's chain starts where the
  protocol starts.
- **Non-Goals**: retro aggregation changes (app-level lines live outside
  `tickets/` and stay out of retro's ticket globs by design — they are
  evidence, not yet metrics).

## Decisions

- **`harness.*` events, app-level destination**: the three scripts are
  about harness health, not a ticket; their evidence rides
  `runs/<app>/telemetry.jsonl` next to `app.scaffold`/`app.deps`.
- **Emission is last, exit code preserved**: each script computes its
  verdict first and emits on the way out, so telemetry can never alter
  behavior. Selfcheck's suite runs before any emission — the fixture
  roots used by gate tests carry fake selfchecks, so no recursion.
- **Audit checks presence, not position, of preflight** — the skill runs
  preflight after ticket creation, but dispatch order across phases is
  the skill's concern; the audit demands the evidence exists and passed,
  symmetric with `gate.analyst`.

## Risks / Trade-offs

- [Existing in-flight tickets lack a preflight line and would fail
  conclude] → correct by the same argument as C4: the evidence really
  is missing; re-running `routine-gate preflight` with the ticket
  context supplies it.

## Migration Plan

Additive emissions plus one new audit check. Rollback = revert the
merge commit.
