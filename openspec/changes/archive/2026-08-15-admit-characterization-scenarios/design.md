# Design — admit-characterization-scenarios

## A distinct heading, not a marker on the old one

The label string is the audit's byte-exact join key. Marking
characterization inside a `## Scenario:` heading would put the marker
into the label or demand the audit parse labels apart — both fragile.
A second heading form keeps every existing rule untouched: the audit's
label collector reads `## Scenario:` lines only, so characterization
labels never enter the tdd-pairing universe at all.

## Coverage moves to evidence that already exists

A characterization test's guarantee is "the suite holds this pin and
the suite is green". That is exactly what the developer gate records —
task-attributed, script-owned, already mandatory on every done task
(a skipped gate is an audit violation on its own). So the exemption
adds no new evidence and weakens nothing: it re-routes coverage to a
record the protocol already demands. The one genuinely new audit rule
is subtractive: a task whose every label is characterization no longer
demands a `tdd.green`.

## Why not forbid characterization-only tasks instead

The alternative fix — require every task to carry at least one tdd
scenario — would have made run 0002's decomposition illegal instead of
unconcludable. But pin-the-seam-first is the correct feature-type move,
and a rule that punishes the correct move is a worse rule. The grammar
should express what good decomposition does, not what the audit finds
convenient.

## Non-Goals, with what would earn each

- **A characterization event in telemetry.** Nothing reads it; the gate
  record already carries the coverage. Earned when a consumer exists.
- **Retrofitting ticket 0002.** Never earned — the abort is history and
  the record is append-only.
- **Auto-detecting characterization by running the test before red.**
  `routine-tdd red` already refuses a passing red; that refusal is the
  detector, and the analyst's explicit declaration is the contract.
