## Why

`bin/routine-render-check` has emitted `harness.render` since v0.15.0
and `lib/roads.txt` never declared it. `routine-road-check` refuses an
undeclared road the first time it fires, so the registry has been red
for a full release on every machine holding a corpus — and nobody
noticed, because **nothing runs the check**.

The telemetry capability already says where it belongs:

> It SHALL remain a session and release-record instrument rather than a
> clone-time gate, because run evidence is session-local and a fresh
> clone holds nothing to judge.

That ruling stands and this change does not touch it. But it names two
moments, and `bin/routine-release-check` invokes `routine-road-check`
zero times. The release-record half of an existing requirement was
never built, which is the whole reason a registry defect survived a
release.

## What Changes

- `routine-road-check` reports **undecided** where the corpus holds no
  telemetry: it prints that it decided nothing and exits 0, instead of
  reporting every declared road as unwalked. Measured today on a clean
  `git archive` of HEAD — the checkout CI gets — it emits 31 false
  violations and exits 1, because it cannot distinguish "no corpus"
  from "the corpus proves nothing walked".
- `bin/routine-release-check` invokes it and relays its verdict, the
  same relay `routine-record-lint` and `routine-render-check` already
  get.
- `harness.render` is declared, and `ticket.replay` is refiled out of
  the `harness` block — the defect the gate now catches, fixed inside
  the change that catches it.

## What is deliberately not built

- **Not a clone-time gate.** `routine-selfcheck` does not gain this
  check. The telemetry capability ruled against it with a reason that
  is still true, and this change derives from that ruling rather than
  overturning it.
- **No auto-declaration.** The check never writes `lib/roads.txt`; a
  gate that repairs its subject has judged nothing.
- **No new rule for the undecided case.** The shape is taken verbatim
  from `a-render-must-be-fresh`, which established that a check reports
  undecided where its corpus is absent rather than refusing or passing
  in silence. Second user of that rule, not a second invention of it.
