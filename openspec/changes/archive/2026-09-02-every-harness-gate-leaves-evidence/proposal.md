## Why

The telemetry requirement that says which harness scripts leave evidence
names four. Measured at HEAD, ten scripts emit a `harness.*` road and two
do not — and the requirement names neither fact. It was written once,
extended once for `caffeine-lint`, and never again as `script-lint`,
`change-check`, `mutation-check`, `pr-body-check`, `render-check` and
`road-check` joined, each declaring a road in `lib/roads.txt` that the
prose never mentions.

Meanwhile `routine-record-lint` and `routine-test-lint` emit nothing. No
archived change decided that: the two that built them never raise
telemetry in either direction, and they landed three days after their
siblings already carried the convention. Every structural line that might
separate them — relayed by a parent gate, argument-driven, corpus-wide —
is contradicted by a sibling that emits. The retro therefore has hundreds
of lines of pass/fail history for the script lint and none for the test
lint that runs beside it on every preflight.

After this week an undeclared road is a demonstrated live defect class.
A requirement that names fewer emitters than exist is the same class in
prose.

## What Changes

- `routine-record-lint` emits `harness.record` and `routine-test-lint`
  emits `harness.test`, the same shape their siblings use; both roads
  declared in `lib/roads.txt`.
- The telemetry requirement names every harness gate and makes
  `lib/roads.txt` the authoritative list, so the prose can no longer
  drift ahead of or behind the registry `routine-road-check` enforces.

## What is deliberately not built

- No new rule for who is a harness gate beyond the twelve named. Law 7
  says a name comes from a rule where one exists; the registry is that
  rule, and the prose now defers to it rather than competing with it.
- No emission from the pure readers (`retro`, `evidence`, `manual`,
  `release-notes`, `caffeine-list`) or the ticket-scoped scripts, whose
  roads live under other namespaces already.
- No waiver. Both scripts run inside `routine-selfcheck` on every
  preflight, so both roads are walked the first time the gate runs on a
  machine holding a corpus.
