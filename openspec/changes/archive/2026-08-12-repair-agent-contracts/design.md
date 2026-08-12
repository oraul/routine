# Design — repair-agent-contracts

## Prose is tested like code

The repairs are prompt-file edits, so the red→green evidence is content
pins: `test/agents_content.bats` greps for load-bearing terms of art
(`ROUTINE_TICKET_DIR`, `routine-done`, `caffeine-mode`), never
sentences — the convention `test/caffeine_content.bats` established.
A pin that would break on a reword is a pin on the wrong thing.

## The closed list admits what the scripts already demand

`routine-defect` and `routine-block` take `<ticket-dir>`; the tests run
inside `TARGET`; a bug's reproduction steps live in `requirement.md`'s
typed section. The developer factually uses all three today — the
"closed list" was closed around the wrong boundary, which teaches the
agent to treat necessary context as contraband. The repair widens the
list to the true boundary and keeps it closed there: still no other
tasks, no index, no out-of-manifest caffeine.

## One ladder, no arbitration machinery

Conflicts between sources get a single precedence paragraph
(task > target conventions > calibration > caffeine; earlier manifest
topic first among caffeine docs). No conflict-resolution abstraction:
Law 2 says abstractions are earned from retro evidence, and one retro
conflict (rails vs hexagonal) is arbitration-in-docs, not machinery.

## The gate loop gets a floor, not a counter

The counted revise limit stays the analyst's (gate-enforced). The
developer's off-ramp is stated as judgment with a number attached
(~3 consecutive gate failures, or a fix that leaves the task's scope)
routing to the existing scripted refusals — no new script, because the
gate cannot distinguish "hard task" from "wrong spec" mechanically yet;
that abstraction waits for retro evidence (Law 9 deferral, already
flagged).

## Characterization stays out of TDD evidence

`routine-tdd red` refuses a passing command by design, and
characterization tests pass from birth. The carve-out routes them to
the ordinary suite (the developer gate runs it) instead of teaching the
agent to fake a red. `caffeine/testing/tdd.md` already teaches this;
the agent contract now agrees with it.
