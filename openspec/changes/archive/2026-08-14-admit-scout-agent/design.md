# Design — admit-scout-agent

## Superseding a recorded non-goal

Law 9 makes recorded non-goals binding, which is why this change states
the reversal in `proposal.md` instead of silently building past it. The
non-goal was not wrong to record; its earning condition was wrong to
write. "A run that used them" is unobservable from this repository —
`runs/` is gitignored — so the condition could never have been met by
evidence, only asserted. The lesson generalises: an earning condition
must name something a reader of this repository can check.

## The tier still follows the grader

Same rule as `declare-agent-tiers`, applied one step down. A scout's
output is graded by whether the caller could use it — and the caller
verifies every claim it keeps, because an accepted claim becomes an
Evidence bullet naming a real path or a file the caller then opens
itself. A wrong scout answer costs one wasted round trip and is caught
immediately by the work that depends on it. That is the weakest grader
in the loop, so it takes the cheapest tier.

## What a scout may never do

The boundary is not "small tasks" — it is *writes*. A scout reads. The
moment a delegate could write to `TARGET`, record telemetry, or decide
that a test is red, the evidence rails would be running inside a context
nobody graded. So the developer's closed list of non-delegable moves is
stated in `agents/developer.md` and pinned: every `routine-tdd` call,
`routine-defect`, `routine-block`, and the judgment that a test failed
for the right reason.

This is also why the scout is one file rather than two. A "test-runner
scout" would have to run the test command, and a scout that runs the
test command is one prompt away from being the thing that decides red.

## Prompts stay transcript-only

The rule the analyst already lives under extends unchanged: the caller
writes each scout prompt, and the prompt is never load-bearing. Nothing
downstream may depend on its text. What survives a scout is what the
caller wrote down afterwards on the existing rails — an Evidence bullet,
an Assumption, or nothing.

## Assumptions

Unchanged from `declare-agent-tiers` and restated because it now covers
three files: the host honours the `model:` field, and no script here can
observe which model answered. Routine checks presence and a recognised
value; the effect is not verified.

A second one is new: that the host provides delegation to the developer
at all. Where it does not, the developer does the mechanical work
itself and nothing in the loop changes — the admission is permissive,
never required. No task may be written such that it can only be
completed by delegating.

## Non-Goals, with what would earn each

- **A scout budget, count, or depth limit.** Earned when a retro shows
  delegation cost that the run's duration cannot already explain.
- **A `scout` telemetry event.** Same standing reason as every other
  proposed event: earned when a consumer exists that would read it. The
  positional-awk constraint on key order still applies.
- **Scout-authored ticket artifacts.** Never earned by evidence — this
  is the writes boundary above, not a deferred feature.
- **A per-call tier override for the scout.** One tier per role until a
  survey type demonstrably needs a different one.
